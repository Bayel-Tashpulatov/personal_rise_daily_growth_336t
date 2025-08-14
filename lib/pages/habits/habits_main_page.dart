// pages/habits_main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
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
  HabitKind _tab = HabitKind.good; // Positive / Negative

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
                  : 'Today you triggered ${todayPercent.round()}% of your bad habits.',
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
                            goal: draft.goal.trim(), // ⭐ добавили
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
                  item: vm,
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

  // ===== helpers: расчёты из логов =====

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

    // сколько разных привычек из этого таба были «триггернуты» сегодня
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
      if (!positive && l.amount < 0) sum += -l.amount; // берём модуль для Lost
    }
    return sum;
  }

  List<HabitVm> _buildVms(List<Habit> habits, List<HabitLog> logs) {
  return habits.map((h) {
    final hLogs = logs.where((l) => l.habitId == h.id);
    final moneyAbs = hLogs.fold<int>(0, (s, l) => s + l.amount).abs();

    final streak = (h.kind == HabitKind.good)
        ? _streakGood(h.id, logs)
        : _streakBadClean(h.id, logs);

    return HabitVm(
      id: h.id,
      title: h.name,
      subtitle: h.description,
      kind: h.kind,
      streak: streak,          // <-- ВАЖНО
      money: moneyAbs,
    );
  }).toList();
}

int _streakGood(String habitId, Iterable<HabitLog> logs) {
  final days = logs
      .where((l) => l.habitId == habitId && l.amount > 0)
      .map((l) => DateUtils.dateOnly(l.date))
      .toSet();

  var day = DateUtils.dateOnly(DateTime.now());
  int streak = 0;
  while (days.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

int _streakBadClean(String habitId, Iterable<HabitLog> logs) {
  // дни, когда был “срыв” по этой вредной привычке
  final slipDays = logs
      .where((l) => l.habitId == habitId && l.amount < 0)
      .map((l) => DateUtils.dateOnly(l.date))
      .toSet();

  var day = DateUtils.dateOnly(DateTime.now());
  int streak = 0;
  // считаем, пока подряд нет срывов
  while (!slipDays.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}

  
}

/// Лёгкая VM для карточки
class HabitVm {
  final String id;
  final String title;
  final String subtitle;
  final HabitKind kind;
    final int streak;
  final int money;
  const HabitVm({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.kind,
    required this.streak,
    required this.money,

  });
}
