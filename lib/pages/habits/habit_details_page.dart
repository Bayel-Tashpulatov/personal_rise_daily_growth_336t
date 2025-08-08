// pages/habit_details_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_entry.dart';

class HabitDetailsPage extends StatelessWidget {
  final HabitItem habit;
  final String? frequencyLabel; // 'Everyday' | 'Every Week' ... (для good)
  const HabitDetailsPage({super.key, required this.habit, this.frequencyLabel});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<HabitsCubit>();
    final entries = c.state.entriesOf(habit.id);

    final isGood = habit.kind == HabitKind.good;
    final moneyColor = isGood
        ? const Color(0xFF19D15C)
        : const Color(0xFFFF6B6B);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Habit Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              // TODO: переход в редактирование привычки
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        children: [
          // Заголовок + частота + описание
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // длинные названия — обрежем по многим строкам
                Text(
                  habit.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (isGood && (frequencyLabel?.isNotEmpty ?? false)) ...[
                  SizedBox(height: 4.h),
                  RichText(
                    text: TextSpan(
                      text: 'Frequency: ',
                      style: const TextStyle(color: Colors.white54),
                      children: [
                        TextSpan(
                          text: frequencyLabel!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                Text(
                  habit.subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(.9)),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Goal
          _card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('🧠 Goal'),
                Text(
                  // можно хранить goal в самой модели HabitItem, сейчас берём из subtitle demo
                  'Consistently record expenses every day for at least 21 days to build a lasting habit.',
                  style: TextStyle(color: Colors.white.withOpacity(.9)),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          // Streak + Money
          Row(
            children: [
              Expanded(
                child: _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Streak',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(
                            isGood
                                ? Icons.local_fire_department
                                : Icons.warning_amber_rounded,
                            color: isGood
                                ? Colors.orangeAccent
                                : const Color(0xFFFF3B30),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            '${habit.streak}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGood ? 'Money Saved' : 'Money Lost',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        (isGood ? '\$' : '\$') + habit.money.toString(),
                        style: TextStyle(
                          color: moneyColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Кнопка Mark as Done / I Slipped
          _markButton(
            isGood: isGood,
            onTap: () async {
              // простая форма ввода суммы + заметки
              final res = await _showAmountNoteSheet(context, isGood: isGood);
              if (res == null) return;

              if (isGood) {
                context.read<HabitsCubit>().markGoodDone(
                  habitId: habit.id,
                  amount: res.amount,
                  note: res.note,
                );
              } else {
                context.read<HabitsCubit>().markBadSlip(
                  habitId: habit.id,
                  amountLost: res.amount,
                  note: res.note,
                );
              }
            },
          ),
          SizedBox(height: 12.h),

          // История
          if (entries.isNotEmpty)
            ...entries.map(
              (e) => _entryTile(
                entry: e,
                isGood: isGood,
                onEdit: () async {
                  final edited = await _showAmountNoteSheet(
                    context,
                    isGood: e.type == EntryType.goodDone,
                    initAmount: e.type == EntryType.goodDone
                        ? e.amount
                        : -e.amount,
                    initNote: e.note,
                    title: 'Edit Entry',
                  );
                  if (edited != null) {
                    context.read<HabitsCubit>().editEntry(
                      e.id,
                      amount: edited.amount,
                      note: edited.note,
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  // === Виджеты ===

  Widget _card({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 16,
      ),
    ),
  );

  Widget _markButton({required bool isGood, required VoidCallback onTap}) {
    final color = isGood ? const Color(0xFF19D15C) : const Color(0xFFFF3B30);
    final text = isGood ? 'Mark as Done' : 'I Slipped';
    final icon = isGood ? Icons.add_circle : Icons.remove_circle;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: color, width: 1.2),
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

  Widget _entryTile({
    required HabitEntry entry,
    required bool isGood,
    required VoidCallback onEdit,
  }) {
    final df = DateFormat('d MMM, yyyy');
    final amount = entry.type == EntryType.goodDone
        ? entry.amount
        : -entry.amount;
    final isPositive = entry.type == EntryType.goodDone;
    final color = isPositive
        ? const Color(0xFF19D15C)
        : const Color(0xFFFF6B6B);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: onEdit, // тап по карточке — редактирование
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    df.format(entry.date),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  (isPositive ? '+\$' : '\$') + amount.toString(),
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              entry.note.isEmpty
                  ? (isPositive ? 'Logged action' : 'Slip recorded')
                  : entry.note,
              style: TextStyle(color: Colors.white.withOpacity(.9)),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== простая форма суммы+заметки ======

class _AmountNote {
  final int amount;
  final String note;
  const _AmountNote(this.amount, this.note);
}

Future<_AmountNote?> _showAmountNoteSheet(
  BuildContext context, {
  required bool isGood,
  int? initAmount,
  String? initNote,
  String title = 'Add Entry',
}) async {
  final amountCtrl = TextEditingController(text: initAmount?.toString() ?? '');
  final noteCtrl = TextEditingController(text: initNote ?? '');
  return showModalBottomSheet<_AmountNote>(
    context: context,
    backgroundColor: const Color(0xFF20232B),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (ctx) {
      final color = isGood ? const Color(0xFF19D15C) : const Color(0xFFFF3B30);
      return Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: isGood ? 'Money Saved (\$)' : 'Money Lost (\$)',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF15171D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Note',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF15171D),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  final amt = int.tryParse(amountCtrl.text.trim()) ?? 0;
                  Navigator.pop(
                    ctx,
                    _AmountNote(amt.abs(), noteCtrl.text.trim()),
                  );
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
