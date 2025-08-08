// lib/pages/add_bad_habit_flow.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BadHabitDraft {
  String name = '';
  String description = '';
  String goal = '';
  bool get isDirty =>
      name.isNotEmpty || description.isNotEmpty || goal.isNotEmpty;
}

Future<void> showAddBadHabitFlow(
  BuildContext context, {
  required void Function(BadHabitDraft) onDone,
}) async {
  await showGeneralDialog(
    context: context,
    barrierLabel: 'add-bad-habit',
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(.45),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (_, __, ___) => _AddBadHabitFlow(onDone: onDone),
    transitionBuilder: (_, anim, __, child) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
      child: FadeTransition(opacity: anim, child: child),
    ),
  );
}

class _AddBadHabitFlow extends StatefulWidget {
  const _AddBadHabitFlow({required this.onDone});
  final void Function(BadHabitDraft) onDone;

  @override
  State<_AddBadHabitFlow> createState() => _AddBadHabitFlowState();
}

class _AddBadHabitFlowState extends State<_AddBadHabitFlow> {
  final _draft = BadHabitDraft();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _goal = TextEditingController();
  int _step = 0; // 0:intro 1:name 2:desc 3:goal 4:final

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _goal.dispose();
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
      if (await _confirmExitIfDirty()) Navigator.of(context).pop();
    } else {
      setState(() => _step--);
    }
  }

  void _next() {
    if (_step < 4) setState(() => _step++);
  }

  bool get _ctaEnabled {
    switch (_step) {
      case 1:
        return _draft.name.trim().isNotEmpty;
      case 2:
        return _draft.description.trim().isNotEmpty;
      case 3:
        return _draft.goal.trim().isNotEmpty;
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
        return 'Final';
      case 4:
        return 'Done';
      default:
        return 'Next';
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _confirmExitIfDirty,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: Material(
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
                            onPressed: _back,
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              "Let's Add a Bad Habit to Break",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const _Divider(),
                      _buildStep(),
                      SizedBox(height: 14.h),
                      _CtaButton(
                        text: _ctaText,
                        enabled: _ctaEnabled,
                        onTap: () {
                          if (_step < 4) {
                            _next();
                          } else {
                            widget.onDone(_draft);
                            Navigator.of(context).pop();
                          }
                        },
                        // для визуального соответствия — синяя кнопка, макет не красит CTA
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return const Text(
          "You're about to track a harmful habit that negatively affects your finances or mindset.\n"
          "Awareness is the first step toward change — name it, understand it, and take control.",
          style: TextStyle(color: Colors.white70),
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Enter a name for the habit you want to quit",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            _AppField(
              controller: _name,
              hint: 'Habit Name',
              maxLines: 3,
              onChanged: (v) => setState(() => _draft.name = v),
            ),
          ],
        );
      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Describe why this habit is harmful",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            _AppField(
              controller: _desc,
              hint: 'Habit Description',
              maxLines: 5,
              onChanged: (v) => setState(() => _draft.description = v),
            ),
          ],
        );
      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "What's your goal with this habit?",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            _AppField(
              controller: _goal,
              hint: 'Goal',
              maxLines: 4,
              onChanged: (v) => setState(() => _draft.goal = v),
            ),
          ],
        );
      case 4:
        return const Text(
          "You're about to track a habit that's holding you back.\n"
          "Awareness is the first step — now it's time to take control and move forward.",
          style: TextStyle(color: Colors.white70),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Текстовое поле (тёмное, как в good-flow)
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
  Widget build(BuildContext context) =>
      Divider(color: Colors.white.withOpacity(.15), height: 20);
}
