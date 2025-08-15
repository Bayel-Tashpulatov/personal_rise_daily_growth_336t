import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 80.h, 16.w, 24.h),
        child: Column(
          children: [
            SettingSection(title: 'Privacy Policy', onTap: () {}),
            SizedBox(height: 8.h),
            SettingSection(title: 'Terms Of Use', onTap: () {}),
            SizedBox(height: 8.h),
            SettingSection(title: 'Support', onTap: () {}),
          ],
        ),
      ),
    );
  }
}

class SettingSection extends StatelessWidget {
  const SettingSection({super.key, required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundLevel2,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.textlevel1,
                  fontSize: 20.sp,
                  fontFamily: 'SF Pro',
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.40,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
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
