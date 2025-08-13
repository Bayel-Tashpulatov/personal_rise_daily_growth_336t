import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/pages/statistics/statistics_page.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class TotalCard extends StatelessWidget {
  final String title;
  final int value;
  final bool positive;
  const TotalCard({
    super.key,
    required this.title,
    required this.value,
    required this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = positive ? AppColors.successAccent : AppColors.errorAccent;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textlevel1,
              fontSize: 13.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w900,
              letterSpacing: 0.26,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '\$${formatMoneyInt(value)}',
            style: TextStyle(
              color: color,
              fontSize: 24.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w900,
              letterSpacing: 0.48,
            ),
          ),
        ],
      ),
    );
  }
}
