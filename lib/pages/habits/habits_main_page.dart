// pages/habits_main_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/add_bad_habit_flow.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/add_good_habit_flow.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/habit_details_page.dart';

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
    final list = isPositive ? s.good : s.bad;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            _HeaderCard(
              title: isPositive ? 'Start Now!' : 'Watch Out!',
              subtitle: isPositive
                  ? (s.todayGoodPercent > 0
                        ? 'Today You completed ${s.todayGoodPercent}% of your habbits'
                        : '-')
                  : '-',
              moneyLabel: isPositive
                  ? 'This Week You Earned:'
                  : 'This Week You Lost:',
              moneyValue: isPositive ? s.weekEarned : s.weekLost,
              progress: isPositive
                  ? s.todayGoodPercent / 100
                  : 0, // круглая диаграмма
              positive: isPositive,
            ),
            SizedBox(height: 18.h),

            Text(
              'My Habbits:', // да, в макете с двумя B :)
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 10.h),

            _Segmented(tab: _tab, onChanged: (k) => setState(() => _tab = k)),
            SizedBox(height: 10.h),

            _AddButton(
              positive: isPositive,
              // внутри HabitsMainPage, в _AddButton(onTap: ...)
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
                          // Сохраняем в Cubit/Hive
                          context.read<HabitsCubit>().addBad(
                            name: draft.name.trim(),
                            description: draft.description.trim(),
                            // goal можно тоже сохранить, если добавил поле в модель
                          );
                        },
                      );
              },
            ),
            SizedBox(height: 12.h),

            if (list.isEmpty)
              Padding(
                padding: EdgeInsets.only(top: 24.h),
                child: Center(
                  child: Text(
                    isPositive
                        ? 'Add your first positive habbit'
                        : 'Add negative habbit if you have one',
                    style: TextStyle(color: Colors.white.withOpacity(.6)),
                  ),
                ),
              )
            else ...[
              for (final h in list)
                _HabitCard(
                  item: h,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HabitDetailsPage(
                          habit: list.firstWhere((item) => item.id == h.id),
                          frequencyLabel:
                              'Everyday', // для good — подставь реальную
                        ),
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
}

/// Хедер с прогресс-кругом и заголовками
class _HeaderCard extends StatelessWidget {
  final String title;
  final String subtitle; // верхняя строка под заголовком
  final String moneyLabel; // "This Week You Earned/Lost:"
  final int moneyValue; // $…
  final double progress; // 0..1
  final bool positive;

  const _HeaderCard({
    required this.title,
    required this.subtitle,
    required this.moneyLabel,
    required this.moneyValue,
    required this.progress,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final accent = positive ? const Color(0xFF19D15C) : const Color(0xFFFF3B30);
    final ring = positive ? const Color(0xFF1977FF) : const Color(0xFF7F1D1D);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(.8)),
                ),
                SizedBox(height: 10.h),
                Text(
                  moneyLabel,
                  style: TextStyle(color: Colors.white.withOpacity(.7)),
                ),
                SizedBox(height: 2.h),
                Text(
                  (positive ? '\$' : '\$') + moneyValue.toString(),
                  style: TextStyle(
                    color: positive ? accent : const Color(0xFFFF6B6B),
                    fontWeight: FontWeight.w900,
                    fontSize: 18.sp,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 92.w,
            height: 92.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 92.w,
                  height: 92.w,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 10.w,
                    backgroundColor: Colors.white.withOpacity(.06),
                    valueColor: AlwaysStoppedAnimation(ring),
                  ),
                ),
                Icon(
                  positive ? Icons.local_fire_department : Icons.report_problem,
                  color: positive ? Colors.orangeAccent : Colors.redAccent,
                  size: 24.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Переключатель Positive / Negative
class _Segmented extends StatelessWidget {
  final HabitKind tab;
  final ValueChanged<HabitKind> onChanged;

  const _Segmented({required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isGood = tab == HabitKind.good;

    return Container(
      height: 40.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E24),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _segBtn(
            'Positive',
            isGood,
            () => onChanged(HabitKind.good),
            activeColor: const Color(0xFF19D15C),
          ),
          _segBtn(
            'Negative',
            !isGood,
            () => onChanged(HabitKind.bad),
            activeColor: const Color(0xFFFF3B30),
          ),
        ],
      ),
    );
  }

  Widget _segBtn(
    String text,
    bool active,
    VoidCallback onTap, {
    required Color activeColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.black : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// Кнопка Add New …
class _AddButton extends StatelessWidget {
  final bool positive;
  final VoidCallback onTap;
  const _AddButton({required this.positive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF19D15C) : const Color(0xFFFF3B30);
    final text = positive ? 'Add New Positive Habit' : 'Add New Negative Habit';
    final icon = positive ? Icons.add : Icons.arrow_forward;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color, width: 1.2),
          color: Colors.transparent,
        ),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ),
            Icon(icon, color: color),
          ],
        ),
      ),
    );
  }
}

/// Карточка привычки (общая для good/bad)
class _HabitCard extends StatelessWidget {
  final HabitItem item;
  final VoidCallback onTap;

  const _HabitCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGood = item.kind == HabitKind.good;
    final moneyColor = isGood
        ? const Color(0xFF19D15C)
        : const Color(0xFFFF6B6B);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                      if (item.todayCount > 0)
                        Row(
                          children: [
                            Icon(
                              isGood
                                  ? Icons.local_fire_department
                                  : Icons.warning_amber_rounded,
                              size: 18.sp,
                              color: isGood
                                  ? Colors.orangeAccent
                                  : const Color(0xFFFF3B30),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${item.todayCount}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.subtitle,
                    style: TextStyle(color: Colors.white.withOpacity(.8)),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    (isGood ? 'Money Saved ' : 'Money Lost ') +
                        (isGood ? '\$${item.money}' : '\$${item.money}'),
                    style: TextStyle(
                      color: moneyColor,
                      fontWeight: FontWeight.w700,
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
