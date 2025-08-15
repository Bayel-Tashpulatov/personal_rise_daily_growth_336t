import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/habit_editor_widgets.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class HabitEditorDraft {
  String name = '';
  String description = '';
  String goal = '';
  HabitFrequency? frequency;

  bool get isDirty =>
      name.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      goal.trim().isNotEmpty ||
      frequency != null;
}

Route<T> _bottomToCenterRoute<T>(Widget child) => PageRouteBuilder<T>(
  opaque: false,
  barrierDismissible: false,
  barrierColor: Colors.black.withOpacity(0.001),
  transitionDuration: const Duration(milliseconds: 320),
  reverseTransitionDuration: const Duration(milliseconds: 260),
  pageBuilder: (_, _, _) => child,
  transitionsBuilder: (_, animation, _, child) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final backdrop = FadeTransition(
      opacity: curved,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 12 * curved.value,
          sigmaY: 12 * curved.value,
        ),
        child: Container(color: Colors.black.withOpacity(0.40 * curved.value)),
      ),
    );

    final panel = Align(
      alignment: Alignment.center,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1.0).animate(curved),
          child: child,
        ),
      ),
    );

    return Stack(children: [backdrop, panel]);
  },
);

Future<void> showAddGoodHabitFlow(
  BuildContext context, {
  required void Function(HabitEditorDraft) onDone,
  Habit? initialHabit,
  VoidCallback? onDelete,
}) async => showHabitEditorFlow(
  context,
  kind: HabitKind.good,
  onDone: onDone,
  initialHabit: initialHabit,
  onDelete: onDelete,
);

Future<void> showAddBadHabitFlow(
  BuildContext context, {
  required void Function(HabitEditorDraft) onDone,
  Habit? initialHabit,
  VoidCallback? onDelete,
}) async => showHabitEditorFlow(
  context,
  kind: HabitKind.bad,
  onDone: onDone,
  initialHabit: initialHabit,
  onDelete: onDelete,
);

Future<void> showHabitEditorFlow(
  BuildContext context, {
  required HabitKind kind,
  required void Function(HabitEditorDraft) onDone,
  Habit? initialHabit,
  VoidCallback? onDelete,
}) async {
  await Navigator.of(context).push(
    _bottomToCenterRoute(
      _HabitEditorFlow(
        kind: kind,
        onDone: onDone,
        initialHabit: initialHabit,
        onDelete: onDelete,
      ),
    ),
  );
}

class _HabitEditorFlow extends StatefulWidget {
  const _HabitEditorFlow({
    required this.kind,
    required this.onDone,
    this.initialHabit,
    this.onDelete,
  });

  final HabitKind kind;
  final void Function(HabitEditorDraft) onDone;
  final Habit? initialHabit;
  final VoidCallback? onDelete;

  bool get isEdit => initialHabit != null;
  bool get isGood => kind == HabitKind.good;

  @override
  State<_HabitEditorFlow> createState() => _HabitEditorFlowState();
}

class _HabitEditorFlowState extends State<_HabitEditorFlow> {
  final _draft = HabitEditorDraft();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();

  final HabitEditorDraft _initial = HabitEditorDraft();

  int _dir = 1;

  bool _closing = false;
  int _step = 0;

  @override
  void initState() {
    super.initState();
    final h = widget.initialHabit;
    if (h != null) {
      _draft
        ..name = h.name
        ..description = h.description
        ..goal = h.goal ?? ''
        ..frequency = widget.isGood ? freqFromIndex(h.frequencyIndex) : null;
      _nameCtrl.text = _draft.name;
      _descCtrl.text = _draft.description;
      _goalCtrl.text = _draft.goal;
    }

    _initial
      ..name = _draft.name
      ..description = _draft.description
      ..goal = _draft.goal
      ..frequency = _draft.frequency;

    if (widget.isEdit) _step = 1;
  }

  bool _isDraftDirtyComparedToInitial() {
    if (!widget.isEdit) {
      return _draft.name.trim().isNotEmpty ||
          _draft.description.trim().isNotEmpty ||
          _draft.goal.trim().isNotEmpty ||
          _draft.frequency != null;
    }
    return _draft.name.trim() != _initial.name.trim() ||
        _draft.description.trim() != _initial.description.trim() ||
        _draft.goal.trim() != _initial.goal.trim() ||
        _draft.frequency != _initial.frequency;
  }

  bool get _isLastStep => widget.isGood ? _step == 5 : _step == 4;

  void _next() {
    _dir = 1;
    final last = widget.isGood ? 5 : 4;
    if (_step < last) setState(() => _step++);
  }

  void _back() async {
    if (_step == 1) {
      if (await _confirmExitIfDirty()) {
        if (_closing) return;
        _closing = true;
        if (mounted) Navigator.of(context).pop();
      }
    } else {
      _dir = -1;
      setState(() => _step--);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmExitIfDirty() async {
    if (_closing) return true;

    final dirty = _isDraftDirtyComparedToInitial();
    if (!dirty) return true;

    final res = await showCupertinoDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Hold On!'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text("Looks like you didn't save your work.\nExit anyway?"),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Stay',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(
              'Exit',
              style: TextStyle(
                color: CupertinoColors.activeBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
    return res ?? false;
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
        return widget.isGood ? _draft.frequency != null : true;
      default:
        return true;
    }
  }

  String get _ctaText {
    final isGood = widget.isGood;

    if (widget.isEdit) {
      if (isGood) {
        switch (_step) {
          case 1:
            return 'Edit habit name';
          case 2:
            return 'Edit habit description';
          case 3:
            return 'Edit habit goal';
          case 4:
            return 'Edit frequency';
          case 5:
            return 'Done';
          default:
            return 'Done';
        }
      } else {
        switch (_step) {
          case 1:
            return 'Edit habit name';
          case 2:
            return 'Edit habit description';
          case 3:
            return 'Edit habit goal';
          case 4:
            return 'Done';
          default:
            return 'Done';
        }
      }
    }

    if (isGood) {
      switch (_step) {
        case 0:
          return 'Enter habit name';
        case 1:
          return 'Add habit description';
        case 2:
          return 'Add habit goal';
        case 3:
          return 'Choose frequency';
        case 4:
          return 'Final';
        case 5:
          return 'Done';
        default:
          return 'Done';
      }
    } else {
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
          return 'Done';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGood = widget.isGood;

    return WillPopScope(
      onWillPop: _confirmExitIfDirty,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 560),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) {
                final tween = Tween<Offset>(
                  begin: Offset(_dir.toDouble(), 0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.easeOutCubic));
                return ClipRect(
                  child: SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  ),
                );
              },
              child: KeyedSubtree(
                key: ValueKey('panel_step_$_step'),
                child: CardShellHabit(
                  title: widget.isEdit
                      ? "Let's Edit a ${isGood ? 'Good' : 'Bad'} Habit"
                      : "Let's Add a ${isGood ? 'Good' : 'Bad'} Habit",
                  onBack: _back,
                  ctaEnabled: _ctaEnabled,
                  ctaText: _ctaText,
                  onCta: () {
                    final lastStep = widget.isGood ? 5 : 4;
                    if (_step < lastStep) {
                      _dir = 1;
                      _next();
                    } else {
                      _closing = true;
                      widget.onDone(_draft);
                      Navigator.of(context).pop();
                    }
                  },
                  contentKey: ValueKey(_step),
                  slideForward: _dir == 1,
                  trailingActions: (widget.isEdit && _isLastStep)
                      ? [
                          CupertinoButton(
                            padding: EdgeInsets.zero,
                            onPressed: () async {
                              if (_closing) return;
                              final ok = await showCupertinoDialog<bool>(
                                context: context,
                                useRootNavigator: true,
                                builder: (_) => CupertinoAlertDialog(
                                  title: const Text('Final Confirmation'),
                                  content: const Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      'This will be permanently deleted with no way back. Still want to go on?',
                                    ),
                                  ),
                                  actions: [
                                    CupertinoDialogAction(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: CupertinoColors.activeBlue,
                                        ),
                                      ),
                                    ),
                                    CupertinoDialogAction(
                                      isDestructiveAction: true,
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text(
                                        'Delete',
                                        style: TextStyle(
                                          color: CupertinoColors.destructiveRed,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (ok == true) {
                                _closing = true;
                                if (mounted) {
                                  Navigator.of(context).pop();
                                }

                                WidgetsBinding.instance.addPostFrameCallback((
                                  _,
                                ) {
                                  widget.onDelete?.call();
                                });
                              }
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 36.w,
                                  height: 36.w,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundLevel2,
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Image.asset(
                                    'assets/icons/delete.png',
                                    width: 20.w,
                                    height: 20.w,
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: AppColors.errorAccent,
                                    fontSize: 15.sp,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ]
                      : null,

                  child: _buildStep(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep() {
    final isGood = widget.isGood;
    EdgeInsets pad() =>
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom);

    switch (_step) {
      case 0:
        return IntroTextHabit(
          text: isGood
              ? "You're about to ${widget.isEdit ? 'edit' : 'add'} a positive habit that will help improve your financial well-being or daily routine.\nThink of something simple, clear, and achievable — consistency is key!"
              : "You're about to ${widget.isEdit ? 'edit' : 'track'} a harmful habit that negatively affects your finances or mindset.\nAwareness is the first step — name it, understand it, and take control.",
          pad: pad(),
        );

      case 1:
        return LabeledFieldHabit(
          label: isGood
              ? "What's the habit you want to build?"
              : "Which habit do you want to quit?",
          controller: _nameCtrl,
          hint: 'Habit Name',
          onChanged: (v) => setState(() => _draft.name = v),
          maxLines: 6,
          pad: pad(),
        );

      case 2:
        return LabeledFieldHabit(
          label: isGood
              ? "Why is this habit important to you?"
              : "Why is this habit harmful?",
          controller: _descCtrl,
          hint: 'Habit Description',
          onChanged: (v) => setState(() => _draft.description = v),
          maxLines: 6,
          pad: pad(),
        );

      case 3:
        return LabeledFieldHabit(
          label: isGood
              ? "What result are you aiming for with this habit?"
              : "What result are you aiming for?",
          controller: _goalCtrl,
          hint: 'Goal',
          onChanged: (v) => setState(() => _draft.goal = v),
          maxLines: 6,
          pad: pad(),
        );

      case 4:
        if (!isGood) {
          return IntroTextHabit(
            text:
                "You're about to ${widget.isEdit ? 'save changes to' : 'track'} a habit that's holding you back.\nStay consistent — awareness turns into progress.",
            pad: pad(),
          );
        }

        return FrequencyPickerHabit(
          value: _draft.frequency,
          onChanged: (f) => setState(() => _draft.frequency = f),
          pad: pad(),
        );

      case 5:
        return IntroTextHabit(
          text:
              "You're about to ${widget.isEdit ? 'save changes to' : 'add'} a positive habit that supports your financial well-being or personal growth.\nStay consistent — even small actions lead to big change.",
          pad: pad(),
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
