// lib/pages/statistics_page.dart
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_entry.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  late DateTime _selectedMonth; // всегда 1-е число месяца

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<HabitsCubit>().state;
    final entries = state.entries;

    // сгруппируем по месяцу
    final byMonth = groupBy(
      entries,
      (HabitEntry e) => DateTime(e.date.year, e.date.month),
    );

    // только доступные месяцы (≤ текущего)
    final now = DateTime.now();
    final maxMonth = DateTime(now.year, now.month);
    final availableMonths =
        byMonth.keys.where((m) => !m.isAfter(maxMonth)).toList()..sort();

    // если выбранный месяц пустой, подвинем на ближайший имеющийся
    if (availableMonths.isNotEmpty &&
        !availableMonths.contains(_selectedMonth)) {
      _selectedMonth = availableMonths.last; // последний доступный
    }

    // данные для графика (12 месяцев вокруг выбранного)
    final monthsRange = _generateYearWindow(_selectedMonth);
    final chartSaved = <double>[];
    final chartLost = <double>[];
    for (final m in monthsRange) {
      final list = byMonth[m] ?? const <HabitEntry>[];
      final saved = list
          .where((e) => e.type == EntryType.goodDone)
          .fold<int>(0, (s, e) => s + e.amount);
      final lost = list
          .where((e) => e.type == EntryType.badSlip)
          .fold<int>(0, (s, e) => s + (-e.amount));
      chartSaved.add(saved.toDouble());
      chartLost.add(lost.toDouble());
    }

    // агрегаты по выбранному месяцу
    final selectedList = byMonth[_selectedMonth] ?? const <HabitEntry>[];
    final monthSaved = selectedList
        .where((e) => e.type == EntryType.goodDone)
        .fold<int>(0, (s, e) => s + e.amount);
    final monthLost = selectedList
        .where((e) => e.type == EntryType.badSlip)
        .fold<int>(0, (s, e) => s + (-e.amount));

    // топы (по сумме за выбранный месяц)
    final savedByHabit = <String, int>{};
    final lostByHabit = <String, int>{};
    for (final e in selectedList) {
      if (e.type == EntryType.goodDone) {
        savedByHabit[e.habitId] = (savedByHabit[e.habitId] ?? 0) + e.amount;
      } else {
        lostByHabit[e.habitId] = (lostByHabit[e.habitId] ?? 0) + (-e.amount);
      }
    }

    List<_HabitAgg> topGood = savedByHabit.entries
        .map((kv) => _HabitAgg(_findHabit(state, kv.key)!, kv.value))
        .sorted((a, b) => b.amount.compareTo(a.amount))
        .take(3)
        .toList();

    List<_HabitAgg> topBad = lostByHabit.entries
        .map((kv) => _HabitAgg(_findHabit(state, kv.key)!, kv.value))
        .sorted((a, b) => b.amount.compareTo(a.amount))
        .take(3)
        .toList();

    final hasAny = entries.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
          children: [
            // Заголовок + пикер месяца
            Row(
              children: [
                const Text(
                  '🎉 Statistics',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    final picked = await _showMonthPicker(
                      context,
                      availableMonths,
                      _selectedMonth,
                    );
                    if (picked != null) setState(() => _selectedMonth = picked);
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        DateFormat('MMM, yyyy').format(_selectedMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // График или плейсхолдер
            _ChartCard(
              months: monthsRange,
              saved: chartSaved,
              lost: chartLost,
              highlightMonth: _selectedMonth,
              isEmpty: !hasAny,
            ),
            SizedBox(height: 12.h),

            // Суммарные карточки
            Row(
              children: [
                Expanded(
                  child: _TotalCard(
                    label: 'Money Saved',
                    value: monthSaved,
                    positive: true,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _TotalCard(
                    label: 'Money Lost',
                    value: monthLost,
                    positive: false,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            if (!hasAny) ...[
              const SizedBox(height: 24),
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Add habbits to see more statistics!',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ] else ...[
              _SectionHeader(
                icon: Icons.add_circle,
                text: 'Top Positive Habits',
                color: const Color(0xFF19D15C),
              ),
              if (topGood.isEmpty)
                _EmptyRow(text: 'No positive activity this month'),
              ..._buildTopList(topGood, positive: true),
              SizedBox(height: 14.h),

              _SectionHeader(
                icon: Icons.remove_circle,
                text: 'Top Negative Habits',
                color: const Color(0xFFFF3B30),
              ),
              if (topBad.isEmpty)
                _EmptyRow(text: 'No negative activity this month'),
              ..._buildTopList(topBad, positive: false),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTopList(List<_HabitAgg> list, {required bool positive}) {
    if (list.isEmpty) return const [];
    // свайп между карточками — PageView с точками
    return [
      SizedBox(
        height: 120.h,
        child: _SwipeCards(items: list, positive: positive),
      ),
    ];
  }

  HabitItem? _findHabit(HabitsState s, String id) {
    return s.good.firstWhereOrNull((h) => h.id == id) ??
        s.bad.firstWhereOrNull((h) => h.id == id);
  }

  List<DateTime> _generateYearWindow(DateTime anchor) {
    // от Jan до Dec того же года (для простоты как в макете)
    final year = anchor.year;
    return List.generate(12, (i) => DateTime(year, i + 1));
  }
}

// ===== Вспомогательные виджеты/модалки =====

class _ChartCard extends StatelessWidget {
  final List<DateTime> months;
  final List<double> saved;
  final List<double> lost;
  final DateTime highlightMonth;
  final bool isEmpty;
  const _ChartCard({
    required this.months,
    required this.saved,
    required this.lost,
    required this.highlightMonth,
    required this.isEmpty,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: isEmpty
          ? _EmptyChart()
          : LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: _niceStep(
                    max(saved.fold(0, max), lost.fold(0, max)),
                  ),
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) =>
                      FlLine(color: Colors.white12, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      reservedSize: 36,
                      showTitles: true,
                      interval: _niceStep(
                        max(saved.fold(0, max), lost.fold(0, max)),
                      ),
                      getTitlesWidget: (v, _) => Text(
                        '\$${v.toInt()}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= months.length)
                          return const SizedBox.shrink();
                        final m = months[i];
                        final label = DateFormat('MMM').format(m);
                        final bold =
                            m.month == highlightMonth.month &&
                            m.year == highlightMonth.year;
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: bold
                                  ? FontWeight.w800
                                  : FontWeight.w400,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(
                      saved.length,
                      (i) => FlSpot(i.toDouble(), saved[i]),
                    ),
                    isCurved: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.withOpacity(.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    color: const Color(0xFF19D15C),
                    barWidth: 3,
                  ),
                  LineChartBarData(
                    spots: List.generate(
                      lost.length,
                      (i) => FlSpot(i.toDouble(), lost[i]),
                    ),
                    isCurved: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.red.withOpacity(.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    color: const Color(0xFFFF3B30),
                    barWidth: 3,
                  ),
                ],
              ),
            ),
    );
  }

  double _niceStep(double maxVal) {
    if (maxVal <= 100) return 20;
    if (maxVal <= 300) return 50;
    if (maxVal <= 1000) return 200;
    return 500;
  }
}

class _EmptyChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Container()), // просто держатель
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                '\$0',
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add habbits to see statistics',
                style: TextStyle(color: Colors.white38),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TotalCard extends StatelessWidget {
  final String label;
  final int value;
  final bool positive;
  const _TotalCard({
    required this.label,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? const Color(0xFF19D15C) : const Color(0xFFFF3B30);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 6),
          Text(
            (positive ? '\$' : '\$') + NumberFormat('#,###').format(value),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  const _SectionHeader({
    required this.icon,
    required this.text,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 6),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRow extends StatelessWidget {
  final String text;
  const _EmptyRow({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF171A20),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(color: Colors.white54)),
    );
  }
}

class _HabitAgg {
  final HabitItem habit;
  final int amount;
  _HabitAgg(this.habit, this.amount);
}

class _SwipeCards extends StatefulWidget {
  final List<_HabitAgg> items;
  final bool positive;
  const _SwipeCards({required this.items, required this.positive});

  @override
  State<_SwipeCards> createState() => _SwipeCardsState();
}

class _SwipeCardsState extends State<_SwipeCards> {
  final _controller = PageController(viewportFraction: .92);
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    final color = widget.positive
        ? const Color(0xFF19D15C)
        : const Color(0xFFFF3B30);
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: widget.items.length,
            itemBuilder: (_, i) {
              final it = widget.items[i];
              return Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF171A20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      it.habit.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      it.habit.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    Text(
                      (widget.positive ? '+\$' : '-\$') +
                          NumberFormat('#,###').format(it.amount),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(widget.items.length, (i) {
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: i == _page ? Colors.white70 : Colors.white24,
                shape: BoxShape.circle,
              ),
            );
          }),
        ),
      ],
    );
  }
}

Future<DateTime?> _showMonthPicker(
  BuildContext context,
  List<DateTime> available,
  DateTime selected,
) async {
  if (available.isEmpty) return null;

  final months = available..sort();
  int initial = months.indexWhere(
    (m) => m.year == selected.year && m.month == selected.month,
  );
  if (initial < 0) initial = months.length - 1;

  int current = initial;

  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: const Color(0xFF20232B),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 180,
              child: CupertinoPicker(
                itemExtent: 36,
                scrollController: FixedExtentScrollController(
                  initialItem: initial,
                ),
                onSelectedItemChanged: (i) => current = i,
                children: months
                    .map(
                      (m) => Center(
                        child: Text(
                          DateFormat('MMMM  yyyy').format(m),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, null),
                    child: const Text('Go Back'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, months[current]),
                    child: const Text(
                      'Apply',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

extension on DateTime {
  bool isAfter(DateTime other) {
    if (year != other.year) return year > other.year;
    return month > other.month;
  }
}
