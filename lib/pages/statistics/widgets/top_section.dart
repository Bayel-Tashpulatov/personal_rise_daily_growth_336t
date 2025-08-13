// lib/features/statistics/presentation/widgets/top_section.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class TopSection extends StatelessWidget {
  final String title;
  final bool positive;
  final List<({Habit habit, int total})> items;
  const TopSection({
    super.key,
    required this.title,
    required this.positive,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final icon = positive ? 'add_positive.png' : 'add_negative.png';
    final green = const Color(0xFF19D15C);
    final red = const Color(0xFFFF3B30);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset('assets/icons/$icon', width: 18, height: 18),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: AppColors.textlevel1,
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        if (items.isEmpty)
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundLevel2,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'No data',
              style: TextStyle(color: AppColors.textlevel1.withOpacity(.7)),
            ),
          )
        else
          SizedBox(
            height: 96.h,
            child: PageView.builder(
              controller: PageController(viewportFraction: .92),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final it = items[i];
                final color = positive ? green : red;
                final sign = positive ? '+' : '-';
                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLevel2,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.habit.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.textlevel1,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        it.habit.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: AppColors.textlevel1),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '$sign\$${formatMoneyInt(it.total)}',
                          style: TextStyle(
                            color: color,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
