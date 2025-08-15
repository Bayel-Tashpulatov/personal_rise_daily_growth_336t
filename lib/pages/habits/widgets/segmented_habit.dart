import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class SegmentedHabit extends StatelessWidget {
  final HabitKind tab;
  final ValueChanged<HabitKind> onChanged;

  const SegmentedHabit({super.key, required this.tab, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isGood = tab == HabitKind.good;
    return Container(
      height: 36.h,
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          _segBtn(
            'Positive',
            isGood,
            () => onChanged(HabitKind.good),
            activeColor: AppColors.successAccent,
          ),
          _segBtn(
            'Negative',
            !isGood,
            () => onChanged(HabitKind.bad),
            activeColor: const Color(0xFFCF0B00),
          ),
        ],
      ),
    );
  }

  Widget _segBtn(
    String text,
    bool active,
    VoidCallback onTap, {
    required Color activeColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 360),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? activeColor : AppColors.backgroundLevel2,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textlevel1,
              fontSize: 15.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w700,
              letterSpacing: 0.30,
            ),
          ),
        ),
      ),
    );
  }
}
