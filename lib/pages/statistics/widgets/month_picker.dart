// lib/features/statistics/presentation/widgets/month_picker.dart
import 'package:flutter/cupertino.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';

Future<MonthKey?> pickMonth(
  BuildContext context, {
  required List<MonthKey> options,
  required MonthKey initial,
}) async {
  if (options.isEmpty) return null;
  final initIndex = options.indexOf(initial).clamp(0, options.length - 1);
  int sel = initIndex;

  return showCupertinoModalPopup<MonthKey>(
    context: context,
    builder: (_) => Container(
      height: 320,
      color: const Color(0xFF121418),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: CupertinoPicker(
              itemExtent: 36,
              scrollController: FixedExtentScrollController(
                initialItem: initIndex,
              ),
              onSelectedItemChanged: (i) => sel = i,
              children: [
                for (final m in options)
                  Center(
                    child: Text(
                      '${MonthKey.monthShort(m.m)} ${m.y}',
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: CupertinoButton(
                  onPressed: () => Navigator.pop(context, null),
                  child: const Text('Go Back'),
                ),
              ),
              Expanded(
                child: CupertinoButton.filled(
                  onPressed: () => Navigator.pop(context, options[sel]),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
