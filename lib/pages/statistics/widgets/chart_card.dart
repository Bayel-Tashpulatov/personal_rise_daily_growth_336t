import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class ChartCard extends StatelessWidget {
  final List<({String label, int saved, int lost})> yearly;
  final int highlightMonth;

  const ChartCard({
    super.key,
    required this.yearly,
    required this.highlightMonth,
  });

  @override
  Widget build(BuildContext context) {
    final double monthCell = (24.0 + 12.0).w;
    final double chartHeight = 180.h;
    final double yAxisGutter = 44.w;

    final data = List<({String label, int saved, int lost})>.generate(
      12,
      (i) => i < yearly.length
          ? yearly[i]
          : (label: _monthShort(i + 1), saved: 0, lost: 0),
    );

    final maxVal = data.fold<int>(
      0,
      (m, e) => math.max(m, math.max(e.saved.abs(), e.lost.abs())),
    );
    final yMax = _niceCeil(maxVal);

    final savedSpots = <FlSpot>[];
    final lostSpots = <FlSpot>[];
    for (int i = 0; i < 12; i++) {
      savedSpots.add(FlSpot(i.toDouble(), data[i].saved.toDouble()));
      lostSpots.add(FlSpot(i.toDouble(), data[i].lost.toDouble()));
    }

    final chart = SizedBox(
      width: monthCell * 12,
      height: chartHeight,
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: 11,
          minY: 0,
          maxY: yMax.toDouble(),
          clipData: const FlClipData(
            top: true,
            bottom: true,
            left: false,
            right: false,
          ),

          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(
              color: Colors.white.withValues(alpha: 0.10),
              strokeWidth: 1.w,
            ),
            horizontalInterval: yMax == 0 ? 20 : (yMax / 5).toDouble(),
          ),

          borderData: FlBorderData(
            show: true,
            border: Border.symmetric(
              horizontal: BorderSide(
                color: Colors.white.withValues(alpha: 0.10),
                width: 1.w,
              ),
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i > 11) return const SizedBox.shrink();
                  final isHi = (i + 1) == highlightMonth;
                  return Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      data[i].label,
                      style: TextStyle(
                        color: isHi
                            ? AppColors.textlevel1
                            : AppColors.textlevel1.withValues(alpha: 0.30),
                        fontWeight: isHi ? FontWeight.w900 : FontWeight.w400,
                        fontSize: 12.sp,
                        fontFamily: 'SF Pro',
                        letterSpacing: 0.24,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: savedSpots,
              isCurved: false,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF00BB22), const Color(0xFF00BB22)],
              ),
              barWidth: 3.4,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF00BB22).withValues(alpha: 0.8),
                    const Color(0xFF00BB22).withValues(alpha: 0.0),
                  ],
                ),
              ),
              dotData: const FlDotData(show: false),
            ),

            LineChartBarData(
              spots: lostSpots,
              isCurved: false,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFFEE362B), const Color(0xFFEE362B)],
              ),
              barWidth: 3.0,
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFEE362B).withValues(alpha: 0.8),
                    const Color(0xFFEE362B).withValues(alpha: 0.0),
                  ],
                ),
              ),
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
        child: Stack(
          children: [
            Positioned.fill(
              left: yAxisGutter,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                child: chart,
              ),
            ),

            Positioned.fill(
              left: 0,
              right: null,
              child: _YAxisFixed(yMax: yMax, gutter: yAxisGutter),
            ),
          ],
        ),
      ),
    );
  }
}

class _YAxisFixed extends StatelessWidget {
  final int yMax;
  final double gutter;
  const _YAxisFixed({required this.yMax, required this.gutter});

  @override
  Widget build(BuildContext context) {
    const double bottomPad = 20.0;
    const double labelH = 14.0;

    final List<double> ticks = yMax == 0
        ? <double>[0, 100]
        : List<double>.generate(6, (i) => (yMax / 5.0) * i);

    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;
        final usable = h - bottomPad;
        final range = (yMax == 0) ? 100.0 : yMax.toDouble();

        return SizedBox(
          width: gutter,
          child: Stack(
            children: [
              for (final v in ticks)
                Positioned(
                  left: 0,

                  bottom:
                      ((v / range) * (usable - labelH)).clamp(
                        0.0,
                        usable - labelH,
                      ) +
                      bottomPad,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2),
                    child: _yLabel('\$${v.toInt()}'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

Widget _yLabel(String t) => Padding(
  padding: const EdgeInsets.only(left: 2),
  child: Text(
    t,
    style: TextStyle(
      color: Colors.white,
      fontSize: 12.sp,
      fontFamily: 'SF Pro',
      fontWeight: FontWeight.w400,
      letterSpacing: 0.24,
    ),
    textAlign: TextAlign.right,
  ),
);

int _niceCeil(int v) {
  if (v <= 0) return 100;
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
