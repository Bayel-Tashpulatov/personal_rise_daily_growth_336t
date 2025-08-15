import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/models/habit.dart';
import 'package:personal_rise_daily_growth_336t/pages/habits/habits_main_page.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class GoodBadHabitCard extends StatelessWidget {
  final HabitVm item;
  final VoidCallback onTap;

  const GoodBadHabitCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGood = item.kind == HabitKind.good;
    final moneyColor = isGood ? AppColors.successAccent : AppColors.errorAccent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundLevel2,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.30,
                          ),
                        ),
                      ),
                      if (item.streak > 0)
                        Row(
                          children: [
                            Image.asset(
                              isGood
                                  ? 'assets/icons/fire.png'
                                  : 'assets/icons/problem.png',
                              width: 20.sp,
                              height: 20.sp,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${item.streak}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15.sp,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.30,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    item.subtitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontFamily: 'SF Pro',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.26,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: isGood ? 'Money Saved ' : 'Money Lost ',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.60),
                            fontSize: 13.sp,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.26,
                          ),
                        ),
                        TextSpan(
                          text: '\$${item.money}',
                          style: TextStyle(
                            color: moneyColor,
                            fontSize: 15.sp,
                            fontFamily: 'SF Pro',
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
