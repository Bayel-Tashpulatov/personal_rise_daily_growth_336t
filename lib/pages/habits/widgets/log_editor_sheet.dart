import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class LogEditorResult {
  final String note;
  final int amount;
  final bool deleted;
  LogEditorResult(this.note, this.amount, {this.deleted = false});
}

Future<LogEditorResult?> showLogEditorSheet(
  BuildContext context, {
  required bool isGood,
  String? initialNote,
  int? initialAmount,
  bool isEdit = false,
}) async {
  final String _initNote = (initialNote ?? '').trim();
  final String _initAmount = initialAmount?.toString() ?? '';

  final noteCtrl = TextEditingController(text: _initNote);
  final amountCtrl = TextEditingController(text: _initAmount);

  bool _isDirty() {
    final note = noteCtrl.text.trim();
    final amount = amountCtrl.text.trim();

    if (!isEdit) {
      return note.isNotEmpty || amount.isNotEmpty;
    } else {
      return note != _initNote || amount != _initAmount;
    }
  }

  Future<bool> confirmExit() async {
    if (!_isDirty()) return true;
    final ok = await showCupertinoDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Hold On!'),
        content: const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text("Looks like you didn't save your work.\nExit anyway?"),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Stay',
              style: TextStyle(color: CupertinoColors.activeBlue),
            ),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
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

  return showGeneralDialog<LogEditorResult>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'log-editor',
    transitionDuration: const Duration(milliseconds: 180),
    pageBuilder: (_, _, _) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, _, _) {
      return BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 8 * anim.value,
          sigmaY: 8 * anim.value,
        ),
        child: Opacity(
          opacity: anim.value,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Center(
              child: WillPopScope(
                onWillPop: confirmExit,
                child: Material(
                  color: AppColors.backgroundLevel1,
                  borderRadius: BorderRadius.circular(12.r),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
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
                              LogEditorResult(noteCtrl.text.trim(), a.abs()),
                            );
                          }

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      if (await confirmExit()) {
                                        Navigator.pop(ctx, null);
                                      }
                                    },
                                    child: Container(
                                      width: 36.w,
                                      height: 36.w,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.backgroundLevel2,
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Image.asset(
                                        'assets/icons/back.png',
                                        width: 28.w,
                                        height: 28.w,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
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
                              Divider(
                                color: Colors.white.withValues(alpha: 0.1),
                                height: 1.h,
                              ),
                              SizedBox(height: 10.h),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  hintNote,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.26,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              TextField(
                                controller: noteCtrl,
                                maxLines: 3,
                                cursorColor: AppColors.textlevel1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.30,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Note',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.30),
                                    fontSize: 15.sp,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.30,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.backgroundLevel2,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(12.w),
                                ),
                              ),
                              SizedBox(height: 10),

                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'How much money did you ${isGood ? 'save' : 'lose'}?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13.sp,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.26,
                                  ),
                                ),
                              ),
                              SizedBox(height: 6.h),
                              TextField(
                                controller: amountCtrl,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                onChanged: (_) => setSt(() {}),
                                cursorColor: AppColors.textlevel1,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontFamily: 'SF Pro',
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.30,
                                ),
                                decoration: InputDecoration(
                                  hintText: hintAmount,
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.30),
                                    fontSize: 15.sp,
                                    fontFamily: 'SF Pro',
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.30,
                                  ),
                                  suffixIcon: Padding(
                                    padding: EdgeInsets.only(right: 12.w),
                                    child: Icon(
                                      Icons.attach_money,
                                      color: Colors.white,
                                    ),
                                  ),
                                  suffixIconConstraints: const BoxConstraints(
                                    minWidth: 0,
                                    minHeight: 0,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.backgroundLevel2,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.all(12.w),
                                ),
                              ),

                              SizedBox(height: 20.h),

                              Row(
                                children: [
                                  if (isEdit)
                                    CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () async {
                                        final ok = await showCupertinoDialog<bool>(
                                          context: ctx,
                                          barrierDismissible: false,
                                          builder: (_) => CupertinoAlertDialog(
                                            title: const Text(
                                              'Final Confirmation',
                                            ),
                                            content: const Padding(
                                              padding: EdgeInsets.only(top: 8),
                                              child: Text(
                                                'This will be permanently deleted with no way back. Still want to go on?',
                                              ),
                                            ),
                                            actions: [
                                              CupertinoDialogAction(
                                                onPressed: () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                                child: const Text(
                                                  'Cancel',
                                                  style: TextStyle(
                                                    color: CupertinoColors
                                                        .activeBlue,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              CupertinoDialogAction(
                                                isDestructiveAction: true,
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                                child: const Text(
                                                  'Delete',
                                                  style: TextStyle(
                                                    color: CupertinoColors
                                                        .destructiveRed,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (ok == true) {
                                          Navigator.pop(
                                            ctx,
                                            LogEditorResult(
                                              '',
                                              0,
                                              deleted: true,
                                            ),
                                          );
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
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
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
                                  const Spacer(),
                                  Opacity(
                                    opacity: ctaEnabled() ? 1.0 : 0.3,
                                    child: CupertinoButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: ctaEnabled() ? submit : null,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Done',
                                            style: TextStyle(
                                              color: AppColors.primaryAccent,
                                              fontSize: 15.sp,
                                              fontFamily: 'SF Pro',
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0.30,
                                            ),
                                          ),
                                          SizedBox(width: 10.w),
                                          Container(
                                            width: 36.w,
                                            height: 36.w,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: AppColors.backgroundLevel2,
                                              borderRadius:
                                                  BorderRadius.circular(12.r),
                                            ),
                                            child: Image.asset(
                                              'assets/icons/arrow_right.png',
                                              width: 20.w,
                                              height: 20.w,
                                            ),
                                          ),
                                        ],
                                      ),
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
        ),
      );
    },
  );
}
