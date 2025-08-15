import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

enum HabitFrequency { daily, weekly, biweekly, monthly }

HabitFrequency? freqFromIndex(int? i) {
  switch (i) {
    case 0:
      return HabitFrequency.daily;
    case 1:
      return HabitFrequency.weekly;
    case 2:
      return HabitFrequency.biweekly;
    case 3:
      return HabitFrequency.monthly;
  }
  return null;
}

int? indexFromFreq(HabitFrequency? f) {
  switch (f) {
    case HabitFrequency.daily:
      return 0;
    case HabitFrequency.weekly:
      return 1;
    case HabitFrequency.biweekly:
      return 2;
    case HabitFrequency.monthly:
      return 3;
    default:
      return null;
  }
}

class CardShellHabit extends StatelessWidget {
  const CardShellHabit({
    super.key,
    required this.title,
    required this.child,
    required this.onBack,
    required this.onCta,
    required this.ctaEnabled,
    required this.ctaText,
    this.trailingActions,
    this.contentKey, 
    this.slideForward = true, 
    this.switchDuration = const Duration(milliseconds: 280), 
  });

  final String title;
  final Widget child;
  final VoidCallback onBack;
  final VoidCallback onCta;
  final bool ctaEnabled;
  final String ctaText;
  final List<Widget>? trailingActions;

  
  final Key? contentKey;

  
  final bool slideForward;

  
  final Duration switchDuration;

  @override
  Widget build(BuildContext context) {
    final divider = Colors.white.withValues(alpha: .10);

    
    SlideTransition _slide(BuildContext _, Animation<double> anim, Widget ch) {
      final inTween = Tween<Offset>(
        begin: Offset(slideForward ? 1 : -1, 0),
        end: Offset.zero,
      ).chain(CurveTween(curve: Curves.easeOutCubic));

      final outTween = Tween<Offset>(
        begin: Offset.zero,
        end: Offset(slideForward ? -1 : 1, 0),
      ).chain(CurveTween(curve: Curves.easeInCubic));

      
      final isOutgoing = anim.status == AnimationStatus.reverse;
      final tween = isOutgoing ? outTween : inTween;

      return SlideTransition(position: anim.drive(tween), child: ch);
    }

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
              SizedBox(height: 8.h),
              Divider(color: divider, height: 1.h),

              
              AnimatedSwitcher(
                duration: switchDuration,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (ch, anim) =>
                    ClipRect(child: _slide(context, anim, ch)),
                child: KeyedSubtree(
                  key: contentKey ?? const ValueKey('__static__'),
                  child: child,
                ),
              ),

              SizedBox(height: 4.h),
              Row(
                children: [
                  if (trailingActions != null) ...trailingActions!,
                  const Spacer(),
                  LinkCTAHabit(
                    text: ctaText,
                    enabled: ctaEnabled,
                    onTap: onCta,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class IntroTextHabit extends StatelessWidget {
  const IntroTextHabit({super.key, required this.text, required this.pad});
  final String text;
  final EdgeInsets pad;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: pad,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15.sp,
          fontFamily: 'SF Pro',
          fontWeight: FontWeight.w400,
          height: 1.47,
          letterSpacing: 0.30,
        ),
      ),
    );
  }
}

class LabeledFieldHabit extends StatelessWidget {
  const LabeledFieldHabit({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.pad,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final ValueChanged<String> onChanged;
  final EdgeInsets pad;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 13.sp),
          ),
          SizedBox(height: 6.h),
          _AppField(
            controller: controller,
            hint: hint,
            onChanged: onChanged,
            maxLines: maxLines,
          ),
        ],
      ),
    );
  }
}

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

class FreqTileHabit extends StatelessWidget {
  const FreqTileHabit({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ListTile(
        onTap: onTap,
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontFamily: 'SF Pro',
            fontWeight: FontWeight.w400,
            letterSpacing: 0.30,
          ),
        ),
        trailing: _RadioRing(selected: selected),
      ),
    );
  }
}

class _RadioRing extends StatelessWidget {
  const _RadioRing({required this.selected});
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white70, width: 1.6.w),
        color: Colors.transparent,
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        margin: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? AppColors.textlevel1 : Colors.transparent,
        ),
      ),
    );
  }
}

class LinkCTAHabit extends StatelessWidget {
  const LinkCTAHabit({
    super.key,
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

class FrequencyPickerHabit extends StatelessWidget {
  const FrequencyPickerHabit({
    super.key,
    required this.value,
    required this.onChanged,
    required this.pad,
  });

  final HabitFrequency? value;
  final ValueChanged<HabitFrequency> onChanged;
  final EdgeInsets pad;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          const Text(
            "How often should this habit be tracked?",
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 6.h),
          FreqTileHabit(
            title: 'Everyday',
            selected: value == HabitFrequency.daily,
            onTap: () => onChanged(HabitFrequency.daily),
          ),
          SizedBox(height: 8.h),
          FreqTileHabit(
            title: 'Every Week',
            selected: value == HabitFrequency.weekly,
            onTap: () => onChanged(HabitFrequency.weekly),
          ),
          SizedBox(height: 8.h),
          FreqTileHabit(
            title: 'Every Two Week',
            selected: value == HabitFrequency.biweekly,
            onTap: () => onChanged(HabitFrequency.biweekly),
          ),
          SizedBox(height: 8.h),
          FreqTileHabit(
            title: 'Every Month',
            selected: value == HabitFrequency.monthly,
            onTap: () => onChanged(HabitFrequency.monthly),
          ),
        ],
      ),
    );
  }
}
