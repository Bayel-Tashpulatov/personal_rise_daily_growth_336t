import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

extension _MonthNames on MonthKey {
  static const names = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static String label(int m) => names[m - 1];
}

/// Двухколёсный Month/Year picker «как в макете»
/// - Центр экрана
/// - Единая синяя лента на обе колонки
/// - Видны все месяцы/годы, но выбрать можно только из options и не позже now.
/// - Недоступные — приглушены и не фиксируются: колесо отщёлкивает к ближайшему доступному.
Future<MonthKey?> pickMonth(
  BuildContext context, {
  required List<MonthKey> options,
  required MonthKey initial,
}) async {
  if (options.isEmpty) return null;

  // ---- ограничение по "не позже текущего"
  final now = DateTime.now();
  bool _notAfterNow(MonthKey mk) =>
      (mk.y < now.year) || (mk.y == now.year && mk.m <= now.month);

  // финальный набор допустимых (и существующих в данных, и не позже текущего)
  final allowedSet = {
    for (final mk in options)
      if (_notAfterNow(mk)) mk,
  };

  // года (все, что в options), но будем помечать те, где нет допустимых месяцев
  final years = SplayTreeSet<int>()..addAll(options.map((e) => e.y));
  final yearsList = years.toList();

  // доступные месяцы с учётом now
  Set<int> allowedMonthsForYear(int y) =>
      allowedSet.where((e) => e.y == y).map((e) => e.m).toSet();

  // стартовые индексы
  int yearIndex = (yearsList.indexOf(initial.y)).clamp(0, yearsList.length - 1);
  int selectedYear = yearsList[yearIndex];
  int selectedMonth = initial.m;

  // если старт недопустим — прижать к ближайшему допустимому
  MonthKey _nearestAllowed(int y, int m) {
    // 1) попытаться в том же году
    final inYear = allowedMonthsForYear(y).toList()..sort();
    if (inYear.isNotEmpty) {
      int best = inYear.first, bestDist = (best - m).abs();
      for (final a in inYear) {
        final d = (a - m).abs();
        if (d < bestDist || (d == bestDist && a < best)) {
          best = a;
          bestDist = d;
        }
      }
      return MonthKey(y, best);
    }
    // 2) найти ближайший год с данными
    int bestYear = y, bestYearDist = 1 << 30;
    for (final yy in yearsList) {
      if (allowedMonthsForYear(yy).isEmpty) continue;
      final d = (yy - y).abs();
      if (d < bestYearDist || (d == bestYearDist && yy < bestYear)) {
        bestYear = yy;
        bestYearDist = d;
      }
    }
    if (allowedMonthsForYear(bestYear).isEmpty) {
      // вообще нет допустимых (все позже now) — вернём null-подобное
      return MonthKey(y, m);
    }
    // ближний месяц в найденном году
    final list = allowedMonthsForYear(bestYear).toList()..sort();
    int mm = list.first, dist = (mm - m).abs();
    for (final a in list) {
      final d = (a - m).abs();
      if (d < dist || (d == dist && a < mm)) {
        mm = a;
        dist = d;
      }
    }
    return MonthKey(bestYear, mm);
  }

  // поджать старт, если нельзя
  if (!allowedSet.contains(MonthKey(selectedYear, selectedMonth))) {
    final near = _nearestAllowed(selectedYear, selectedMonth);
    if (allowedSet.contains(near)) {
      selectedYear = near.y;
      selectedMonth = near.m;
      yearIndex = yearsList.indexOf(selectedYear);
    }
  }

  final yearCtrl = FixedExtentScrollController(initialItem: yearIndex);
  final monthCtrl = FixedExtentScrollController(initialItem: selectedMonth - 1);

  void snapMonth(StateSetter setState) {
    final near = _nearestAllowed(selectedYear, selectedMonth);
    if (!allowedSet.contains(MonthKey(selectedYear, selectedMonth)) &&
        allowedSet.contains(near)) {
      if (near.y != selectedYear) {
        // сменить год, если пришлось
        selectedYear = near.y;
        yearCtrl.animateToItem(
          yearsList.indexOf(selectedYear),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
      selectedMonth = near.m;
      setState(() {});
      monthCtrl.animateToItem(
        selectedMonth - 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      HapticFeedback.selectionClick();
    } else {
      setState(() {});
    }
  }

  bool yearIsDisabled(int y) => allowedMonthsForYear(y).isEmpty;
  bool monthIsDisabled(int y, int m) => !allowedMonthsForYear(y).contains(m);

  return showCupertinoModalPopup<MonthKey>(
    context: context,
    barrierDismissible: true,
    builder: (_) => SafeArea(
      top: false,
      child: Center(
        // жёстко центрируем карточку
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
          child: StatefulBuilder(
            builder: (context, setState) {
              final pickerCard = Container(
                width: 343.w,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLevel2,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                child: SizedBox(
                  height: 190.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        children: [
                          // ---------- MONTH wheel
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 24.h,
                              squeeze: 1.1,
                              useMagnifier: true,
                              magnification: 1.05,
                              scrollController: monthCtrl,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (i) {
                                selectedMonth = i + 1;
                                // если запрещено — сразу отщёлкнуть
                                if (monthIsDisabled(
                                  selectedYear,
                                  selectedMonth,
                                )) {
                                  snapMonth(setState);
                                } else {
                                  setState(() {});
                                }
                              },
                              children: List.generate(12, (i) {
                                final m = i + 1;
                                final disabled = monthIsDisabled(
                                  selectedYear,
                                  m,
                                );
                                return Center(
                                  child: Text(
                                    _MonthNames.label(m),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: disabled ? 14.sp : 23.sp,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: 'SF Pro Display',
                                      height: 1.22,
                                      letterSpacing: 0.70,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          // ---------- YEAR wheel
                          Expanded(
                            child: CupertinoPicker(
                              itemExtent: 36.h,
                              squeeze: 1.1,
                              useMagnifier: true,
                              magnification: 1.05,
                              scrollController: yearCtrl,
                              selectionOverlay: const SizedBox.shrink(),
                              onSelectedItemChanged: (i) {
                                final newYear = yearsList[i];
                                final disabled = yearIsDisabled(newYear);
                                if (disabled) {
                                  // нельзя зафиксировать такой год — отщёлкнуть обратно к ближайшему
                                  // ищем ближайший год с допустимыми месяцами
                                  int bestIdx = i, bestDist = 1 << 30;
                                  for (int k = 0; k < yearsList.length; k++) {
                                    if (yearIsDisabled(yearsList[k])) continue;
                                    final d = (k - i).abs();
                                    if (d < bestDist ||
                                        (d == bestDist && k < bestIdx)) {
                                      bestIdx = k;
                                      bestDist = d;
                                    }
                                  }
                                  yearCtrl.animateToItem(
                                    bestIdx,
                                    duration: const Duration(milliseconds: 180),
                                    curve: Curves.easeOut,
                                  );
                                  selectedYear = yearsList[bestIdx];
                                  snapMonth(setState);
                                  HapticFeedback.selectionClick();
                                } else {
                                  selectedYear = newYear;
                                  // если выбранный месяц в этом году запрещён — отщёлкнем
                                  if (monthIsDisabled(
                                    selectedYear,
                                    selectedMonth,
                                  )) {
                                    snapMonth(setState);
                                  } else {
                                    setState(() {});
                                  }
                                }
                              },
                              children: [
                                for (final y in yearsList)
                                  Center(
                                    child: Text(
                                      '$y',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // ---------- единая синяя лента
                      IgnorePointer(
                        child: Container(
                          height: 36.h,
                          margin: EdgeInsets.symmetric(horizontal: 8.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent,
                            borderRadius: BorderRadius.circular(7.r),
                          ),
                        ),
                      ),

                      // ---------- активные подписи поверх ленты
                      Positioned.fill(
                        child: Row(
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  _MonthNames.label(selectedMonth),
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '${yearsList[yearIndex = yearsList.indexOf(selectedYear)]}',
                                  style: TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );

              final bottomButtons = Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLevel2,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => Navigator.pop(context, null),
                      child: Text(
                        'Go Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.32,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),
                  Container(
                    width: double.infinity,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        final near = _nearestAllowed(
                          selectedYear,
                          selectedMonth,
                        );
                        if (allowedSet.contains(near)) {
                          Navigator.pop(context, near);
                        } else {
                          Navigator.pop(context, null);
                        }
                      },
                      child: Text(
                        'Apply',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.32,
                        ),
                      ),
                    ),
                  ),
                ],
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  pickerCard,
                  SizedBox(height: 10.h),
                  bottomButtons,
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
}
