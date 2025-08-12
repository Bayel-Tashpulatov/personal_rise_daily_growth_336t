// lib/widgets/log_editor_sheet.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class LogEditorResult {
  final String note;
  final int amount;
  final bool deleted; // true если нажали Delete в edit-режиме
  LogEditorResult(this.note, this.amount, {this.deleted = false});
}

Future<LogEditorResult?> showLogEditorSheet(
  BuildContext context, {
  required bool isGood,
  String? initialNote,
  int? initialAmount,
  bool isEdit = false,
}) async {
  final noteCtrl = TextEditingController(text: initialNote ?? '');
  final amountCtrl = TextEditingController(
    text: initialAmount != null ? initialAmount.toString() : '',
  );

  bool isDirty() =>
      noteCtrl.text.trim().isNotEmpty || amountCtrl.text.trim().isNotEmpty;

  Future<bool> confirmExit() async {
    if (!isDirty()) return true;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF23262F),
        title: const Text(
          'Hold On!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: const Text(
          "Looks like you didn't save your work.\nExit anyway?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  final title = isEdit
      ? 'Edit Mark'
      : (isGood
            ? 'Ready to mark this habit as done?'
            : "What went wrong today?");

  final hintNote = isGood
      ? 'How was your day with this habit?'
      : 'How did today go with this bad habit?';
  final hintAmount = isGood ? 'Money Saved' : 'Money Lost';
  final accent = isGood ? const Color(0xFF19D15C) : const Color(0xFFFF3B30);

  return showGeneralDialog<LogEditorResult>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'log-editor',
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, __, ___) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8 * anim.value,
          sigmaY: 8 * anim.value,
        ),
        child: Opacity(
          opacity: anim.value,
          child: Center(
            child: WillPopScope(
              onWillPop: confirmExit,
              child: Material(
                color: const Color(0xFF20232B),
                borderRadius: BorderRadius.circular(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: StatefulBuilder(
                      builder: (ctx, setSt) {
                        bool ctaEnabled() {
                          final a = int.tryParse(amountCtrl.text.trim()) ?? 0;
                          return a > 0;
                        }

                        Future<void> submit() async {
                          final a = int.tryParse(amountCtrl.text.trim()) ?? 0;
                          Navigator.pop(
                            ctx,
                            LogEditorResult(
                              noteCtrl.text.trim(),
                              a.abs() *
                                  (isGood
                                      ? 1
                                      : 1), // положительное число; знак ставим в Cubit
                            ),
                          );
                        }

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // header
                            Row(
                              children: [
                                InkWell(
                                  onTap: () async {
                                    if (await confirmExit())
                                      Navigator.pop(ctx, null);
                                  },
                                  child: const Icon(
                                    Icons.arrow_back_ios,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.white.withOpacity(.12)),
                            const SizedBox(height: 6),

                            // Note
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                hintNote,
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: noteCtrl,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Note',
                                hintStyle: const TextStyle(
                                  color: Colors.white38,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF15171D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Amount
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'How much money did you ${isGood ? 'save' : 'lose'}?',
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: amountCtrl,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setSt(() {}),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: hintAmount,
                                suffixIcon: const Padding(
                                  padding: EdgeInsets.only(right: 12),
                                  child: Icon(
                                    Icons.attach_money,
                                    color: Colors.white70,
                                  ),
                                ),
                                suffixIconConstraints: const BoxConstraints(
                                  minWidth: 0,
                                  minHeight: 0,
                                ),
                                filled: true,
                                fillColor: const Color(0xFF15171D),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),

                            const SizedBox(height: 12),

                            Row(
                              children: [
                                if (isEdit)
                                  TextButton.icon(
                                    onPressed: () async {
                                      final ok = await showDialog<bool>(
                                        context: ctx,
                                        barrierDismissible: false,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: const Color(
                                            0xFF23262F,
                                          ),
                                          title: const Text(
                                            'Final Confirmation',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          content: const Text(
                                            'This will be permanently deleted with no way back. Still want to go on?',
                                            style: TextStyle(
                                              color: Colors.white70,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        Navigator.pop(
                                          ctx,
                                          LogEditorResult('', 0, deleted: true),
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                    ),
                                    label: const Text('Delete'),
                                  ),
                                const Spacer(),
                                TextButton(
                                  onPressed: ctaEnabled() ? submit : null,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Done',
                                        style: TextStyle(
                                          color: ctaEnabled()
                                              ? Colors.white
                                              : Colors.white38,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: ctaEnabled()
                                            ? accent
                                            : Colors.white24,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
