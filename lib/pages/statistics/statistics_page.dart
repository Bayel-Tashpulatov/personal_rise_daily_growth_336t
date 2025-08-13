import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/application/stats_selectors.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/widgets/chart_card.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/widgets/month_picker.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/widgets/top_section.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/widgets/total_card.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class MonthKey {
  final int y, m;
  const MonthKey(this.y, this.m);

  @override
  bool operator ==(Object other) =>
      other is MonthKey && other.y == y && other.m == m;

  @override
  int get hashCode => Object.hash(y, m);

  @override
  String toString() => '$y-${m.toString().padLeft(2, '0')}';

  static String monthShort(int m) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][m - 1];
}

String formatMoneyInt(int v) {
  final s = v.abs().toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final idx = s.length - 1 - i;
    buf.write(s[idx]);
    if ((i + 1) % 3 == 0 && idx != 0) buf.write(',');
  }
  return buf.toString().split('').reversed.join();
}

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});
  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late MonthKey selected;

  @override
  void initState() {
    super.initState();
    final hc = context.read<HabitsCubit>();
    final opts = hc.availableMonths();
    final now = DateTime.now();
    selected = opts.isNotEmpty ? opts.last : MonthKey(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final hc = context.watch<HabitsCubit>();
    final opts = hc.availableMonths();
    if (!opts.contains(selected) && opts.isNotEmpty) {
      selected = opts.last;
    }

    final totals = hc.totalsFor(selected);
    final topGood = hc.topHabits(mk: selected, positive: true);
    final topBad = hc.topHabits(mk: selected, positive: false);
    final yearly = hc.seriesForYear(selected.y);

    return Scaffold(
      backgroundColor: AppColors.backgroundLevel1,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 120.h),
          children: [
            Row(
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/goal.png',
                      width: 24.w,
                      height: 24.w,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Statistics',
                      style: TextStyle(
                        color: AppColors.textlevel1,
                        fontSize: 20.sp,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.40,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final mk = await pickMonth(
                      context,
                      options: opts,
                      initial: selected,
                    );
                    if (mk != null) setState(() => selected = mk);
                  },
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/icons/calendar.png',
                        width: 24.w,
                        height: 24.w,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${MonthKey.monthShort(selected.m)}, ${selected.y}',
                        style: TextStyle(
                          color: AppColors.textlevel1,
                          fontSize: 15.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            ChartCard(yearly: yearly, highlightMonth: selected.m),

            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TotalCard(
                    title: 'Money Saved',
                    value: totals.saved,
                    positive: true,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: TotalCard(
                    title: 'Money Lost',
                    value: totals.lost,
                    positive: false,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),
            TopSection(
              title: 'Top Positive Habits',
              positive: true,
              items: topGood,
            ),
            SizedBox(height: 24.h),
            TopSection(
              title: 'Top Negative Habits',
              positive: false,
              items: topBad,
            ),

            if (hc.state.habits.isEmpty) ...[
              SizedBox(height: 70.h),
              Center(
                child: Text(
                  'Add habbits to see more statistics!',
                  style: TextStyle(
                    color: AppColors.textlevel1,
                    fontSize: 12.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.24,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Image.asset(
                'assets/images/empty_stats.png',
                width: 160.w,
                height: 160.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
