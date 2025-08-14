
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

/// Кнопка Add New …
class AddHabitButton extends StatelessWidget {
  final bool positive;
  final VoidCallback onTap;
  const AddHabitButton({super.key, required this.positive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.successAccent : AppColors.errorAccent;
    final text = positive ? 'Add New Positive Habit' : 'Add New Negative Habit';
    final icon = positive
        ? 'assets/icons/add_positive.png'
        : 'assets/icons/add_negative.png';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color, width: 1.w),
          color: AppColors.backgroundLevel2,
        ),
        padding: EdgeInsets.all(12.w),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: color,
                  fontSize: 13.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.26,
                ),
              ),
            ),
            Image.asset(icon, width: 20.w, height: 20.h),
          ],
        ),
      ),
    );
  }
}
