import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/widgets/habit_editor_widgets.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class HabitEditorDraft {
  String name = '';
  String description = '';
  String goal = '';
  HabitFrequency? frequency; // используется только для good

  bool get isDirty =>
      name.trim().isNotEmpty ||
      description.trim().isNotEmpty ||
      goal.trim().isNotEmpty ||
      frequency != null;
}

/// Удобные врапперы
Future<void> showAddGoodHabitFlow(
  BuildContext context, {
  required void Function(HabitEditorDraft) onDone,
  Habit? initialHabit, // если не null — режим редактирования
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

/// Универсальный flow (good/bad + create/edit)
Future<void> showHabitEditorFlow(
  BuildContext context, {
  required HabitKind kind,
  required void Function(HabitEditorDraft) onDone,
  Habit? initialHabit,
  VoidCallback? onDelete,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'habit-editor',
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => _HabitEditorFlow(
      kind: kind,
      onDone: onDone,
      initialHabit: initialHabit,
      onDelete: onDelete,
    ),
    transitionBuilder: (_, anim, _, child) => BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 10 * anim.value,
        sigmaY: 10 * anim.value,
      ),
      child: FadeTransition(opacity: anim, child: child),
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

  bool _closing = false;

  // шаги: good => 0..5; bad => 0..4 (без frequency)
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

    // EDIT: пропускаем только интро (0), начинаем с name (1)
    if (widget.isEdit) {
      _step = 1;
    }
  }

  bool get _isLastStep => widget.isGood ? _step == 5 : _step == 4;

  void _next() {
    final last = widget.isGood ? 5 : 4;
    if (_step < last) setState(() => _step++);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _goalCtrl.dispose();
    super.dispose();
  }

  Future<bool> _confirmExitIfDirty() async {
    if (_closing) return true; // уже закрываемся — не спрашиваем
    final dirty = widget.isEdit || _draft.isDirty;
    if (!dirty) return true;

    // Показываем системный (root) диалог, чтобы не «мешать» анимации showGeneralDialog
    final res = await showCupertinoDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (_) => const CupertinoAlertDialog(
        title: Text('Hold On!'),
        content: Text("Looks like you didn't save your work.\nExit anyway?"),
        actions: [
          CupertinoDialogAction(isDefaultAction: true, child: Text('Stay')),
          CupertinoDialogAction(isDestructiveAction: true, child: Text('Exit')),
        ],
      ),
    );

    // кнопки сами Navigator.pop(dialog, value) вызывают — res уже здесь
    return res ?? false;
  }

  void _back() async {
    if (_step == 0) {
      if (await _confirmExitIfDirty()) {
        if (_closing) return;
        _closing = true;
        if (mounted) Navigator.of(context).pop(); // закрываем сам редактор
      }
    } else {
      setState(() => _step--);
    }
  }

  bool get _ctaEnabled {
    switch (_step) {
      case 1: // name
        return _draft.name.trim().isNotEmpty;
      case 2: // description
        return _draft.description.trim().isNotEmpty;
      case 3: // goal (и для bad тоже)
        return _draft.goal.trim().isNotEmpty;
      case 4: // frequency только для good
        return widget.isGood ? _draft.frequency != null : true;
      default:
        return true; // intro/final
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
            return 'Next';
        }
      } else {
        // bad: без frequency
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
            return 'Next';
        }
      }
    }

    // create flow (как было)
    if ((isGood && _step == 5) || (!isGood && _step == 4)) return 'Done';
    switch (_step) {
      case 0:
        return 'Enter habit name';
      case 1:
        return 'Add habit description';
      case 2:
        return 'Add habit goal';
      case 3:
        return isGood ? 'Choose frequency' : 'Final';
      case 4:
        return isGood ? 'Final' : 'Done';
      default:
        return 'Next';
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
            child: CardShellHabit(
              title: widget.isEdit
                  ? "Let's Edit a ${isGood ? 'Good' : 'Bad'} Habit"
                  : "Let's Add a ${isGood ? 'Good' : 'Bad'} Habit",
              onBack: _back,
              ctaEnabled: _ctaEnabled,
              ctaText: _ctaText,
              onCta: () {
                final lastStep = isGood ? 5 : 4;
                if (_step < lastStep) {
                  _next();
                } else {
                  widget.onDone(_draft);
                  Navigator.of(context).pop();
                }
              },
              trailingActions: (widget.isEdit && _isLastStep)
                  ? [
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () async {
                          if (_closing) return;
                          final ok = await showCupertinoDialog<bool>(
                            context: context,
                            useRootNavigator: true,
                            builder: (_) => const CupertinoAlertDialog(
                              title: Text('Final Confirmation'),
                              content: Text(
                                'This will be permanently deleted with no way back. Still want to go on?',
                              ),
                              actions: [
                                CupertinoDialogAction(child: Text('Cancel')),
                                CupertinoDialogAction(
                                  isDestructiveAction: true,
                                  child: Text('Delete'),
                                ),
                              ],
                            ),
                          );

                          if (ok == true) {
                            _closing = true;
                            // 1) Закрываем сам редактор
                            if (mounted) Navigator.of(context).pop();

                            // 2) Выполняем onDelete ПОСЛЕ закрытия (следующий кадр)
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              // onDelete уже сам решит: удалить из Hive и, например, закрыть HabitDetailsPage
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
          // Bad: финальный текст
          return IntroTextHabit(
            text:
                "You're about to ${widget.isEdit ? 'save changes to' : 'track'} a habit that's holding you back.\nStay consistent — awareness turns into progress.",
            pad: pad(),
          );
        }
        // Good: выбор частоты
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
