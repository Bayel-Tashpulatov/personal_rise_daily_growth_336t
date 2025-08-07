import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/pages/pr_splash_screen.dart';

void main() {
  runApp(const PersonalRiseDailyGrowth());
}

class PersonalRiseDailyGrowth extends StatelessWidget {
  const PersonalRiseDailyGrowth({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(home: const PrSplashScreen()),
    );
  }
}
