import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/habit_editor_flow.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/habit_editor_widgets.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/log_editor_sheet.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class HabitDetailsPage extends StatelessWidget {
  final Habit habit;
  const HabitDetailsPage({super.key, required this.habit});

  String? _freqLabel(int? idx) {
    if (idx == null || idx < 0) return null;
    switch (idx) {
      case 0:
        return 'Everyday';
      case 1:
        return 'Every Week';
      case 2:
        return 'Every Two Weeks';
      case 3:
        return 'Every Month';
      default:
        return null;
    }
  }

  String? _goalText(String? goal) {
    final String? g = goal?.trim();
    if (g == null || g.trim().isEmpty) return null;
    return g.trim();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<HabitsCubit>();
    final logs = c.entriesOf(habit.id);

    final isGood = habit.kind == HabitKind.good;
    final money = _sumMoney(logs, isGood: isGood);
    final streak = c.currentStreakForHabit(habit.id, good: isGood);

    final moneyColor = isGood ? AppColors.successAccent : AppColors.errorAccent;

    final today = DateTime.now();
    final hasToday = logs.any(
      (l) =>
          l.date.year == today.year &&
          l.date.month == today.month &&
          l.date.day == today.day &&
          (isGood ? l.amount > 0 : l.amount < 0),
    );

    final freq = _freqLabel(habit.frequencyIndex);
    final goal = _goalText(habit.goal);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.backgroundLevel1,
        appBar: AppBar(
          backgroundColor: AppColors.backgroundLevel1,
          elevation: 0,
          leading: IconButton(
            icon: Image.asset(
              'assets/icons/back.png',
              width: 44.w,
              height: 44.w,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'Habit Details',
            style: TextStyle(
              color: AppColors.textlevel1,
              fontSize: 18.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w900,
              letterSpacing: 0.36,
            ),
          ),
          actions: [
            IconButton(
              icon: Image.asset(
                'assets/icons/edit.png',
                width: 44.w,
                height: 44.w,
              ),
              onPressed: () async {
                await showHabitEditorFlow(
                  context,
                  kind: habit.kind,
                  initialHabit: habit,
                  onDone: (draft) async {
                    final freqIndex = habit.kind == HabitKind.good
                        ? indexFromFreq(draft.frequency)
                        : null;
                    final updated = habit.copyWith(
                      name: draft.name,
                      description: draft.description,
                      goal: draft.goal.isEmpty ? null : draft.goal,
                      frequencyIndex: freqIndex,
                    );
                    await context.read<HabitsCubit>().updateHabit(updated);
                  },
                  onDelete: () async {
                    await context.read<HabitsCubit>().deleteHabit(habit.id);

                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                );
              },
            ),
          ],
        ),

        body: ListView(
          padding: EdgeInsets.fromLTRB(12.w, 24.h, 12.w, 24.h),
          children: [
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    habit.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.40,
                    ),
                  ),
                  if (freq != null) ...[
                    SizedBox(height: 8.h),
                    RichText(
                      text: TextSpan(
                        text: 'Frequency: ',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.60),
                          fontSize: 15.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.30,
                        ),
                        children: [
                          TextSpan(
                            text: freq,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontFamily: 'SF Pro',
                              fontWeight: FontWeight.w400,
                              letterSpacing: 0.30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 8.h),
                  Text(
                    habit.description,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      height: 1.33,
                      letterSpacing: 0.30,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            if (goal != null)
              _card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/goal.png',
                          width: 24.w,
                          height: 24.w,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Goal',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.sp,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.40,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      goal,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontFamily: 'SF Pro',
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.30,
                      ),
                    ),
                  ],
                ),
              ),
            if (goal != null) SizedBox(height: 4.h),

            Row(
              children: [
                Expanded(
                  child: _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Streak',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.30,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Image.asset(
                              isGood
                                  ? 'assets/icons/fire.png'
                                  : 'assets/icons/problem.png',
                              width: 28.w,
                              height: 28.w,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              '$streak',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.sp,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.48,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGood ? 'Money Saved' : 'Money Lost',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.30,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '\$${NumberFormat('#,###').format(money)}',
                          style: TextStyle(
                            color: moneyColor,
                            fontSize: 24.sp,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.48,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Text(
              hasToday
                  ? (isGood ? 'Already marked today' : 'Already recorded today')
                  : (isGood ? 'Not yet marked today' : 'No slips today'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 15.sp,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.30,
              ),
            ),
            SizedBox(height: 6.h),
            _markButton(
              isGood: isGood,
              enabled: !hasToday,
              onTap: () async {
                final res = await showLogEditorSheet(context, isGood: isGood);
                if (res == null) return;

                debugPrint(
                  '➡️ Done pressed: isGood=$isGood amount=${res.amount}',
                );
                try {
                  if (!context.mounted) return;
                  if (isGood) {
                    debugPrint('→ markGoodDone(${habit.id}, ${res.amount})');
                    await context.read<HabitsCubit>().markGoodDone(
                      habitId: habit.id,
                      amount: res.amount,
                      note: res.note,
                    );
                  } else {
                    debugPrint('→ markBadSlip(${habit.id}, ${res.amount})');
                    await context.read<HabitsCubit>().markBadSlip(
                      habitId: habit.id,
                      amountLost: res.amount,
                      note: res.note,
                    );
                  }
                  debugPrint('✔️ saved ok');
                } catch (e, st) {
                  debugPrint('❌ save log failed: $e\n$st');
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to save, try again.')),
                  );
                }
              },
            ),

            SizedBox(height: 12.h),

            ...logs.map((l) => _historyTile(context, l, isGood: isGood)),
          ],
        ),
      ),
    );
  }

  int _sumMoney(List<HabitLog> list, {required bool isGood}) {
    if (isGood) {
      return list.where((l) => l.amount > 0).fold(0, (s, l) => s + l.amount);
    } else {
      return list.where((l) => l.amount < 0).fold(0, (s, l) => s + (-l.amount));
    }
  }

  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }

  Widget _markButton({
    required bool isGood,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    final color = isGood ? AppColors.successAccent : AppColors.errorAccent;
    final text = isGood ? 'Mark as Done' : 'I Slipped';
    final icon = isGood
        ? 'assets/icons/add_positive.png'
        : 'assets/icons/add_negative.png';

    return Opacity(
      opacity: enabled ? 1 : .5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: color, width: 1.w),
          ),
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.26,
                  ),
                ),
              ),
              Image.asset(icon, width: 20.w, height: 20.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyTile(
    BuildContext context,
    HabitLog l, {
    required bool isGood,
  }) {
    final df = DateFormat('d MMM, yyyy');
    final isPositive = l.amount > 0;
    final shown = isPositive ? l.amount : -l.amount;
    final color = isPositive ? AppColors.successAccent : AppColors.errorAccent;

    return InkWell(
      onTap: () async {
        final edited = await showLogEditorSheet(
          context,
          isGood: isPositive,
          isEdit: true,
          initialNote: l.note,
          initialAmount: shown,
        );
        if (edited == null) return;

        if (edited.deleted) {
          await context.read<HabitsCubit>().deleteLog(l.id);
        } else {
          final newAmount = isPositive ? edited.amount : -edited.amount;
          await context.read<HabitsCubit>().editLog(
            l.id,
            newAmount: newAmount,
            newNote: edited.note,
          );
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundLevel2,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        df.format(l.date),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.60),
                          fontSize: 15.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.30,
                        ),
                      ),
                      Text(
                        (isPositive ? '+\$' : '-\$') +
                            NumberFormat('#,###').format(shown),
                        style: TextStyle(
                          color: color,
                          fontSize: 14.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.28,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    (l.note?.trim().isNotEmpty ?? false)
                        ? l.note!.trim()
                        : (isPositive ? 'Logged action' : 'Slip recorded'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
