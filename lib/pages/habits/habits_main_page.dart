import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_vm.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/habit_details_page.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/add_habit_button.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/habit_card.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/habit_editor_flow.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/header_habit_card.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/segmented_habit.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class HabitsMainPage extends StatefulWidget {
  const HabitsMainPage({super.key});

  @override
  State<HabitsMainPage> createState() => _HabitsMainPageState();
}

class _HabitsMainPageState extends State<HabitsMainPage> {
  HabitKind _tab = HabitKind.good;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<HabitsCubit>().state;

    final isPositive = _tab == HabitKind.good;
    final habits = isPositive ? s.good : s.bad;
    final vms = _buildVms(habits, s.logs);

    final todayPercent = _todayPercentFor(habits, s.logs, positive: isPositive);
    final weekEarned = _weekMoney(s.logs, positive: true);
    final weekLost = _weekMoney(s.logs, positive: false);

    return Scaffold(
      backgroundColor: AppColors.backgroundLevel1,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(12.w, 16.h, 12.w, 120.h),
          children: [
            HeaderHabitCard(
              title: isPositive ? 'Start Now!' : 'Watch Out!',
              subtitle: isPositive
                  ? (todayPercent > 0
                        ? 'Today You completed ${todayPercent.round()}% of your habbits'
                        : '-')
                  : (todayPercent > 0
                        ? 'Today you triggered ${todayPercent.round()}% of your bad habits.'
                        : '-'),
              moneyLabel: isPositive
                  ? 'This Week You Earned:'
                  : 'This Week You Lost:',
              moneyValue: isPositive ? weekEarned : weekLost,
              progress: isPositive ? (todayPercent / 100).clamp(0, 1) : 0,
              positive: isPositive,
            ),
            SizedBox(height: 24.h),

            Text(
              'My Habbits:',
              style: TextStyle(
                color: AppColors.textlevel1,
                fontSize: 18.sp,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w900,
                letterSpacing: 0.36,
              ),
            ),
            SizedBox(height: 8.h),

            SegmentedHabit(
              tab: _tab,
              onChanged: (k) => setState(() => _tab = k),
            ),
            SizedBox(height: 17.h),

            AddHabitButton(
              positive: isPositive,
              onTap: () {
                isPositive
                    ? showAddGoodHabitFlow(
                        context,
                        onDone: (draft) {
                          context.read<HabitsCubit>().addGood(
                            name: draft.name.trim(),
                            description: draft.description.trim(),
                            goal: draft.goal.trim(),
                            frequency: draft.frequency,
                          );
                        },
                      )
                    : showAddBadHabitFlow(
                        context,
                        onDone: (draft) {
                          context.read<HabitsCubit>().addBad(
                            name: draft.name.trim(),
                            description: draft.description.trim(),
                            goal: draft.goal.trim(),
                          );
                        },
                      );
              },
            ),
            SizedBox(height: 8.h),

            if (vms.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 170.h),
                child: Center(
                  child: Text(
                    isPositive
                        ? 'Add your first positive habbit'
                        : 'Add negative habbit if you have one',
                    style: TextStyle(
                      color: AppColors.textlevel1.withValues(alpha: 0.60),
                      fontSize: 12.sp,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              )
            else ...[
              for (final vm in vms)
                GoodBadHabitCard(
                  title: vm.title,
                  subtitle: vm.subtitle,
                  kind: vm.kind,
                  todayCount: vm.todayCount,
                  money: vm.money,
                  onTap: () {
                    final habit = habits.firstWhere((h) => h.id == vm.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HabitDetailsPage(habit: habit),
                      ),
                    );
                  },
                ),

              SizedBox(height: 12.h),
            ],
          ],
        ),
      ),
    );
  }

  int _todayPercentFor(
    List<Habit> habits,
    List<HabitLog> logs, {
    required bool positive,
  }) {
    if (habits.isEmpty) return 0;

    final today = DateTime.now();
    bool sameDay(DateTime d) =>
        d.year == today.year && d.month == today.month && d.day == today.day;

    final habitIds = habits.map((h) => h.id).toSet();

    final triggeredIds = logs
        .where(
          (l) =>
              sameDay(l.date) &&
              habitIds.contains(l.habitId) &&
              (positive ? l.amount > 0 : l.amount < 0),
        )
        .map((l) => l.habitId)
        .toSet();

    final ratio = triggeredIds.length / habits.length;
    return (ratio * 100).round().clamp(0, 100);
  }

  int _weekMoney(List<HabitLog> logs, {required bool positive}) {
    final now = DateTime.now();
    final from = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(const Duration(days: 6));
    int sum = 0;
    for (final l in logs) {
      final d = DateUtils.dateOnly(l.date);
      if (d.isBefore(from) || d.isAfter(DateUtils.dateOnly(now))) continue;
      if (positive && l.amount > 0) sum += l.amount;
      if (!positive && l.amount < 0) sum += -l.amount;
    }
    return sum;
  }

  List<HabitVm> _buildVms(List<Habit> habits, List<HabitLog> logs) {
    final today = DateUtils.dateOnly(DateTime.now());
    return habits.map((h) {
      final hLogs = logs.where((l) => l.habitId == h.id);
      final todayCount = hLogs
          .where((l) => DateUtils.isSameDay(l.date, today))
          .length;
      final moneyAbs = hLogs.fold<int>(0, (s, l) => s + l.amount).abs();
      return HabitVm(
        id: h.id,
        title: h.name,
        subtitle: h.description,
        kind: h.kind,
        todayCount: todayCount,
        money: moneyAbs,
      );
    }).toList();
  }
}
