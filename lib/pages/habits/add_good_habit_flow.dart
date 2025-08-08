// lib/pages/add_good_habit_flow.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum HabitFrequency { daily, weekly, biweekly, monthly }

class GoodHabitDraft {
  String name = '';
  String description = '';
  String goal = '';
  HabitFrequency? frequency;

  bool get isDirty =>
      name.isNotEmpty ||
      description.isNotEmpty ||
      goal.isNotEmpty ||
      frequency != null;
}

Future<void> showAddGoodHabitFlow(
  BuildContext context, {
  required void Function(GoodHabitDraft) onDone,
}) async {
  await showGeneralDialog(
    context: context,
    barrierLabel: 'add-good-habit',
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, _, _) {
      return _AddGoodHabitFlow(onDone: onDone);
    },
    transitionBuilder: (_, anim, _, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 6 * anim.value,
          sigmaY: 6 * anim.value,
        ),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
  );
}

class _AddGoodHabitFlow extends StatefulWidget {
  const _AddGoodHabitFlow({required this.onDone});
  final void Function(GoodHabitDraft) onDone;

  @override
  State<_AddGoodHabitFlow> createState() => _AddGoodHabitFlowState();
}

class _AddGoodHabitFlowState extends State<_AddGoodHabitFlow> {
  final _draft = GoodHabitDraft();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  int _step = 0; // 0-intro, 1-name, 2-desc, 3-goal, 4-frequency, 5-final

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmExitIfDirty() async {
    if (!_draft.isDirty) return true;
    final res = await showDialog<bool>(
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
        actionsAlignment: MainAxisAlignment.spaceBetween,
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
    return res ?? false;
  }

  void _back() async {
    if (_step == 0) {
      final ok = await _confirmExitIfDirty();
      if (ok && mounted) Navigator.of(context).pop();
      return;
    }
    setState(() => _step--);
  }

  void _next() {
    if (_step < 5) setState(() => _step++);
  }

  bool get _ctaEnabled {
    switch (_step) {
      case 1:
        return _draft.name.trim().isNotEmpty;
      case 2:
        return _draft.description.trim().isNotEmpty;
      case 3:
        return _draft.goal.trim().isNotEmpty;
      case 4:
        return _draft.frequency != null;
      default:
        return true;
    }
  }

  String get _ctaText {
    switch (_step) {
      case 0:
        return 'Enter habit name';
      case 1:
        return 'Add habit description';
      case 2:
        return 'Next';
      case 3:
        return 'Choose frequency';
      case 4:
        return 'Final';
      case 5:
        return 'Done';
      default:
        return 'Next';
    }
  }

  @override
  Widget build(BuildContext context) {
    final card = _CardShell(
      title: "Let's Add a Good Habit",
      onBack: _back,
      ctaEnabled: _ctaEnabled,
      ctaText: _ctaText,
      onCta: () {
        if (_step < 5) {
          _next();
        } else {
          widget.onDone(_draft);
          Navigator.of(context).pop();
        }
      },
      child: _buildStep(),
    );

    return WillPopScope(
      onWillPop: _confirmExitIfDirty,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: card,
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Divider(),
            const SizedBox(height: 8),
            const Text(
              "You're about to add a positive habit that will help improve your financial well-being or daily routine.\n"
              "Think of something simple, clear, and achievable — consistency is key!",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Divider(),
            const SizedBox(height: 8),
            const Text(
              "What's the habit you want to build?",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            _AppField(
              controller: _nameCtrl,
              hint: 'Habit Name',
              onChanged: (v) => setState(() => _draft.name = v),
              maxLines: 3,
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Divider(),
            const SizedBox(height: 8),
            const Text(
              "Why is this habit important to you?",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            _AppField(
              controller: _descCtrl,
              hint: 'Habit Description',
              onChanged: (v) => setState(() => _draft.description = v),
              maxLines: 5,
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Divider(),
            const SizedBox(height: 8),
            const Text(
              "What result are you aiming for with this habit?",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            _AppField(
              controller: _goalCtrl,
              hint: 'Goal',
              onChanged: (v) => setState(() => _draft.goal = v),
              maxLines: 4,
            ),
          ],
        );

      case 4:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Divider(),
            const SizedBox(height: 8),
            const Text(
              "How often should this habit be tracked?",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            _FreqTile(
              title: 'Everyday',
              selected: _draft.frequency == HabitFrequency.daily,
              onTap: () =>
                  setState(() => _draft.frequency = HabitFrequency.daily),
            ),
            _FreqTile(
              title: 'Every Week',
              selected: _draft.frequency == HabitFrequency.weekly,
              onTap: () =>
                  setState(() => _draft.frequency = HabitFrequency.weekly),
            ),
            _FreqTile(
              title: 'Every Two Week',
              selected: _draft.frequency == HabitFrequency.biweekly,
              onTap: () =>
                  setState(() => _draft.frequency = HabitFrequency.biweekly),
            ),
            _FreqTile(
              title: 'Every Month',
              selected: _draft.frequency == HabitFrequency.monthly,
              onTap: () =>
                  setState(() => _draft.frequency = HabitFrequency.monthly),
            ),
            const SizedBox(height: 6),
            const Text(
              'Note: streak resets if the habit is not marked done within its period '
              '(day/week/two weeks/month).',
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        );

      case 5:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _Divider(),
            SizedBox(height: 8),
            Text(
              "You're about to add a positive habit that supports your financial well-being or personal growth.\n"
              "Stay consistent — even small actions lead to big change.",
              style: TextStyle(color: Colors.white70),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Оболочка карточки (тёмная, с заголовком, back и CTA снизу)
class _CardShell extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onBack;
  final VoidCallback onCta;
  final bool ctaEnabled;
  final String ctaText;

  const _CardShell({
    required this.title,
    required this.child,
    required this.onBack,
    required this.onCta,
    required this.ctaEnabled,
    required this.ctaText,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF20232B),
      borderRadius: BorderRadius.circular(16.r),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 360.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: onBack,
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              child,
              SizedBox(height: 14.h),
              _CtaButton(text: ctaText, enabled: ctaEnabled, onTap: onCta),
            ],
          ),
        ),
      ),
    );
  }
}

/// Поле ввода
class _AppField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String> onChanged;

  const _AppField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF15171D),
        contentPadding: EdgeInsets.all(12.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.white.withOpacity(.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.white.withOpacity(.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Color(0xFF0062FF), width: 1.2),
        ),
      ),
    );
  }
}

class _FreqTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _FreqTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        tileColor: const Color(0xFF15171D),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onTap: onTap,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: Icon(
          selected ? Icons.radio_button_checked : Icons.radio_button_off,
          color: selected ? const Color(0xFF0062FF) : Colors.white54,
        ),
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final bool enabled;
  final String text;
  final VoidCallback onTap;

  const _CtaButton({
    required this.enabled,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0062FF),
          disabledBackgroundColor: Colors.white.withOpacity(.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(text, style: const TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(color: Colors.white.withOpacity(.15), height: 20);
  }
}
