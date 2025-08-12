// lib/pages/add_bad_habit_flow.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class BadHabitDraft {
  String name = '';
  String description = '';
  String goal = '';

  bool get isDirty =>
      name.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      goal.trim().isNotEmpty;
}

Future<void> showAddBadHabitFlow(
  BuildContext context, {
  required void Function(BadHabitDraft) onDone,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'add-bad-habit',
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, __, ___) => _AddBadHabitFlow(onDone: onDone),
    transitionBuilder: (_, anim, __, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10 * anim.value,
          sigmaY: 10 * anim.value,
        ),
        child: FadeTransition(opacity: anim, child: child),
      );
    },
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
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  int _step = 0; // 0-intro, 1-name, 2-desc, 3-goal, 4-final

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
        return 'Add habit goal';
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
    final card = _CardShell(
      title: "Let's Add a Bad Habit to Break",
      onBack: _back,
      ctaEnabled: _ctaEnabled,
      ctaText: _ctaText,
      onCta: () {
        if (_step < 4) {
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
    EdgeInsets pad() =>
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom);

    switch (_step) {
      case 0:
        return SingleChildScrollView(
          padding: pad(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                "You're about to track a harmful habit that negatively affects your finances or mindset.\n"
                "Awareness is the first step — name it, understand it, and take control.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.47,
                  letterSpacing: 0.30,
                ),
              ),
            ],
          ),
        );

      case 1:
        return SingleChildScrollView(
          padding: pad(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                "Which habit do you want to quit?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.26,
                ),
              ),
              SizedBox(height: 6.h),
              _AppField(
                controller: _nameCtrl,
                hint: 'Habit Name',
                onChanged: (v) => setState(() => _draft.name = v),
                maxLines: 6,
              ),
            ],
          ),
        );

      case 2:
        return SingleChildScrollView(
          padding: pad(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                "Why is this habit harmful?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.26,
                ),
              ),
              SizedBox(height: 6.h),
              _AppField(
                controller: _descCtrl,
                hint: 'Habit Description',
                onChanged: (v) => setState(() => _draft.description = v),
                maxLines: 6,
              ),
            ],
          ),
        );

      case 3:
        return SingleChildScrollView(
          padding: pad(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                "What result are you aiming for?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.26,
                ),
              ),
              SizedBox(height: 6.h),
              _AppField(
                controller: _goalCtrl,
                hint: 'Goal',
                onChanged: (v) => setState(() => _draft.goal = v),
                maxLines: 6,
              ),
            ],
          ),
        );

      case 4:
        return SingleChildScrollView(
          padding: pad(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 6.h),
              Text(
                "You're about to track a habit that's holding you back.\n"
                "Stay consistent — awareness turns into progress.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w400,
                  height: 1.47,
                  letterSpacing: 0.30,
                ),
              ),
            ],
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

/// Card shell — общий с good-flow: тёмная карточка, divider, CTA-ссылка справа
class _CardShell extends StatelessWidget {
  const _CardShell({
    required this.title,
    required this.child,
    required this.onBack,
    required this.onCta,
    required this.ctaEnabled,
    required this.ctaText,
  });

  final String title;
  final Widget child;
  final VoidCallback onBack;
  final VoidCallback onCta;
  final bool ctaEnabled;
  final String ctaText;

  @override
  Widget build(BuildContext context) {
    final divider = Colors.white.withValues(alpha: .10);

    return Material(
      color: AppColors.backgroundLevel1,
      borderRadius: BorderRadius.circular(12.r),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 343.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: onBack,
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      width: 36.w,
                      height: 36.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundLevel2,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Image.asset(
                        'assets/icons/back.png',
                        width: 28.w,
                        height: 28.w,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: 36.w, width: 8.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.36,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Divider(color: divider, height: 1.h),

              child,

              SizedBox(height: 4.h),
              Align(
                alignment: Alignment.centerRight,
                child: _LinkCTA(
                  text: ctaText,
                  enabled: ctaEnabled,
                  onTap: onCta,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Поле ввода — тёмное, скруглённое, как в good-flow
class _AppField extends StatelessWidget {
  const _AppField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.white,
        fontSize: 15.sp,
        fontFamily: 'SF Pro',
        fontWeight: FontWeight.w400,
        letterSpacing: 0.30,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.30),
          fontSize: 15.sp,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w400,
          letterSpacing: 0.30,
        ),
        filled: true,
        fillColor: AppColors.backgroundLevel2,
        contentPadding: EdgeInsets.all(12.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.textlevel3),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.textlevel3, width: 1.w),
        ),
      ),
    );
  }
}

/// Ссылка-CTA (как в good-flow): текст + синяя круглая стрелка
class _LinkCTA extends StatelessWidget {
  const _LinkCTA({
    required this.text,
    required this.enabled,
    required this.onTap,
  });

  final String text;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(18.r),
      child: Opacity(
        opacity: enabled ? 1 : 0.3,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: AppColors.primaryAccent,
                fontSize: 15.sp,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w700,
                letterSpacing: 0.30,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: AppColors.backgroundLevel2,
                borderRadius: BorderRadius.circular(12.r),
              ),
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icons/arrow_right.png',
                width: 20.w,
                height: 20.w,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
