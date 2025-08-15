import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class HeaderHabitCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String moneyLabel;
  final int moneyValue;
  final double progress;
  final bool positive;

  const HeaderHabitCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.moneyLabel,
    required this.moneyValue,
    required this.progress,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textlevel1,
                    fontSize: 24.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.48,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textlevel1,
                    fontSize: 13.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.26,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  moneyLabel,
                  style: TextStyle(
                    color: AppColors.textlevel1.withValues(alpha: 0.60),
                    fontSize: 13.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.26,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  moneyValue == 0 ? '-' : '\$${moneyValue.toString()}',
                  style: TextStyle(
                    color: positive
                        ? AppColors.successAccent
                        : AppColors.errorAccent,
                    fontSize: 20.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.40,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 110.w,
            height: 110.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 110.w,
                  height: 110.w,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0, 1),
                    strokeWidth: 12.w,
                    backgroundColor: AppColors.primaryAccent.withValues(
                      alpha: 0.30,
                    ),
                    valueColor: AlwaysStoppedAnimation(
                      positive ? AppColors.primaryAccent : Colors.transparent,
                    ),
                  ),
                ),
                Image.asset(
                  positive
                      ? 'assets/icons/fire_ring.png'
                      : 'assets/icons/problem_ring.png',
                  width: 44.w,
                  height: 44.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
