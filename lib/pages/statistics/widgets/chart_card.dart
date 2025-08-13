// lib/features/statistics/presentation/widgets/chart_card.dart
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class ChartCard extends StatelessWidget {
  final List<({String label, int saved, int lost})>
  yearly; // 12 элементов, Jan..Dec
  final int highlightMonth; // 1..12 (текущий выбранный месяц)

  const ChartCard({
    super.key,
    required this.yearly,
    required this.highlightMonth,
  });

  @override
  Widget build(BuildContext context) {
    // ширина одной «ячейки» месяца — чтобы уместилось ~7 месяцев
    final monthWidth = 58.0.w;
    final chartHeight = 180.0.h;

    // нормализуем вход: всегда 12
    final data = yearly.length == 12
        ? yearly
        : List<({String label, int saved, int lost})>.generate(
            12,
            (i) => i < yearly.length
                ? yearly[i]
                : (label: _monthShort(i + 1), saved: 0, lost: 0),
          );

    // ymax с «красивым» округлением
    final maxVal = data.fold<int>(
      0,
      (m, e) => math.max(m, math.max(e.saved.abs(), e.lost.abs())),
    );
    final yMax = _niceCeil(maxVal);

    // точки
    final savedSpots = <FlSpot>[];
    final lostSpots = <FlSpot>[];
    for (var i = 0; i < 12; i++) {
      savedSpots.add(FlSpot(i.toDouble(), data[i].saved.toDouble()));
      lostSpots.add(FlSpot(i.toDouble(), data[i].lost.toDouble()));
    }

    final chart = SizedBox(
      width: monthWidth * 12, // вся лента на 12 месяцев
      height: chartHeight,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: yMax.toDouble(),
          clipData: const FlClipData.all(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) =>
                FlLine(color: Colors.white.withOpacity(.08), strokeWidth: 1),
            horizontalInterval: yMax == 0 ? 20 : _gridStep(yMax),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.white.withOpacity(.06), width: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) {
                  if (yMax == 0) {
                    // показать 0 и $100 как на пустом мокапе
                    if (v == 0) return _yLabel('\$0');
                    if (v == 100) return _yLabel('\$100');
                    return const SizedBox.shrink();
                  }
                  final step = _gridStep(yMax);
                  // рисуем только кратные шагу
                  if ((v % step).abs() < 0.001) {
                    return _yLabel('\$${v.toInt()}');
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i > 11) return const SizedBox.shrink();
                  final monthIndex = i + 1;
                  final isHi = monthIndex == highlightMonth;
                  return Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Text(
                      data[i].label,
                      style: TextStyle(
                        color: isHi
                            ? AppColors.textlevel1
                            : AppColors.textlevel1.withOpacity(.35),
                        fontWeight: isHi ? FontWeight.w900 : FontWeight.w600,
                        fontSize: isHi ? 13.sp : 12.sp,
                      ),
                    ),
                  );
                },
                interval: 1,
              ),
            ),
          ),
          lineTouchData: LineTouchData(enabled: false),
          lineBarsData: [
            // Saved — зелёная с градиентной заливкой
            LineChartBarData(
              spots: savedSpots,
              isCurved: false,
              color: const Color(0xFF19D15C),
              barWidth: 2.2,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF19D15C).withOpacity(.30),
                    const Color(0xFF19D15C).withOpacity(.02),
                  ],
                ),
              ),
              dotData: const FlDotData(show: false),
            ),
            // Lost — красная тонкая линия без заливки
            LineChartBarData(
              spots: lostSpots,
              isCurved: false,
              color: const Color(0xFFFF3B30),
              barWidth: 2.0,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SizedBox(
        height: chartHeight,
        // скроллится только диаграмма
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: chart,
        ),
      ),
    );
  }
}

/// ————— helpers —————

Widget _yLabel(String t) => Text(
  t,
  style: TextStyle(
    color: Colors.white.withOpacity(.7),
    fontSize: 12.sp,
    fontWeight: FontWeight.w600,
  ),
);

// Округляем вверх до «красивого» значения (100/200/500/1000 …).
int _niceCeil(int v) {
  if (v <= 0) return 100; // пустой график — шкала $0..$100 как в мокапе
  const bases = [1, 2, 5];
  var scale = 1;
  while (true) {
    for (final b in bases) {
      final candidate = b * scale;
      if (v <= candidate) return candidate;
    }
    scale *= 10;
  }
}

// Шаг сетки: 20/50/100/200/500…
double _gridStep(int maxVal) {
  if (maxVal <= 100) return 20;
  if (maxVal <= 200) return 40;
  if (maxVal <= 500) return 100;
  if (maxVal <= 1000) return 200;
  return (maxVal / 5).roundToDouble();
}

String _monthShort(int m) => const [
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
