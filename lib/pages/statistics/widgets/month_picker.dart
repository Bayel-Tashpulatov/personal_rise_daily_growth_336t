import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';

/// Короткое имя месяца (как на макете)
extension _MonthFmt on MonthKey {
  static String monthShort(int m) => const [
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
  ][m - 1];
}

/// Двухколёсный month picker с единым синим selection-band
Future<MonthKey?> pickMonth(
  BuildContext context, {
  required List<MonthKey> options,
  required MonthKey initial,
}) async {
  if (options.isEmpty) return null;

  // ---- данные: доступные годы и месяцы
  final years = SplayTreeSet<int>()..addAll(options.map((e) => e.y));
  final yearsList = years.toList();
  Set<int> monthsForYear(int y) =>
      options.where((e) => e.y == y).map((e) => e.m).toSet();

  // начальные индексы
  int yearIndex = (yearsList.indexOf(initial.y)).clamp(0, yearsList.length - 1);
  int monthIndex = (initial.m - 1).clamp(0, 11);

  int selectedYear = yearsList[yearIndex];
  int selectedMonth = initial.m;

  final yearCtrl = FixedExtentScrollController(initialItem: yearIndex);
  final monthCtrl = FixedExtentScrollController(initialItem: monthIndex);

  int _nearestAllowedMonth(int y, int m) {
    final allowed = monthsForYear(y);
    if (allowed.contains(m)) return m;
    if (allowed.isEmpty) return m;
    int best = allowed.first, bestDist = (best - m).abs();
    for (final a in allowed) {
      final d = (a - m).abs();
      if (d < bestDist || (d == bestDist && a < best)) {
        best = a;
        bestDist = d;
      }
    }
    return best;
  }

  void _snapMonthIfNeeded() {
    final target = _nearestAllowedMonth(selectedYear, selectedMonth);
    if (target != selectedMonth) {
      selectedMonth = target;
      monthCtrl.animateToItem(
        target - 1,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
      HapticFeedback.selectionClick();
    }
  }

  final bgCard = const Color(0xFF121418);
  final pillBg = const Color(0xFF1A1D24);
  final bandColor = const Color(0xFF0A84FF); // синий как в макете
  final textOnBand = CupertinoColors.white;

  return showCupertinoModalPopup<MonthKey>(
    context: context,
    builder: (_) => SafeArea(
      top: false,
      child: Center(
        child: Container(
          width: 343.w,
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(16.r),
          ),
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 8.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== Вилка с единым selection-band =====
              SizedBox(
                height: 180.h,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      children: [
                        // MONTH wheel
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36.h,
                            useMagnifier: true,
                            magnification: 1.05,
                            scrollController: monthCtrl,
                            selectionOverlay:
                                const SizedBox.shrink(), // общий band сверху
                            onSelectedItemChanged: (i) {
                              selectedMonth = i + 1;
                            },
                            children: List.generate(12, (i) {
                              final m = i + 1;
                              final enabled = monthsForYear(
                                selectedYear,
                              ).contains(m);
                              return Center(
                                child: Text(
                                  _MonthFmt.monthShort(m),
                                  style: TextStyle(
                                    color: enabled
                                        ? CupertinoColors.white
                                        : CupertinoColors.white.withOpacity(
                                            0.25,
                                          ),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // YEAR wheel
                        Expanded(
                          child: CupertinoPicker(
                            itemExtent: 36.h,
                            useMagnifier: true,
                            magnification: 1.05,
                            scrollController: yearCtrl,
                            selectionOverlay: const SizedBox.shrink(),
                            onSelectedItemChanged: (i) {
                              yearIndex = i;
                              selectedYear = yearsList[i];
                              _snapMonthIfNeeded();
                            },
                            children: [
                              for (final y in yearsList)
                                const Center(
                                  child: Text(
                                    '', // текст зададим ниже через builder
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // общий синий band на обе колонки
                    IgnorePointer(
                      child: Container(
                        height: 36.h,
                        margin: EdgeInsets.symmetric(horizontal: 6.w),
                        decoration: BoxDecoration(
                          color: bandColor,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    // поверх — тексты активной строки, чтобы быть "на синем"
                    Positioned.fill(
                      child: Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Text(
                                _MonthFmt.monthShort(selectedMonth),
                                style: TextStyle(
                                  color: textOnBand,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${yearsList[yearIndex]}',
                                style: TextStyle(
                                  color: textOnBand,
                                  fontSize: 16,
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

              SizedBox(height: 8.h),

              // ===== Кнопки =====
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44.h,
                      decoration: BoxDecoration(
                        color: pillBg,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context, null),
                        child: const Text(
                          'Go Back',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: CupertinoButton.filled(
                        borderRadius: BorderRadius.circular(12.r),
                        onPressed: () => Navigator.pop(
                          context,
                          MonthKey(selectedYear, selectedMonth),
                        ),
                        child: const Text(
                          'Apply',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
