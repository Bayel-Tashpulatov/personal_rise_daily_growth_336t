// lib/features/statistics/presentation/widgets/total_card.dart
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
    final color = positive ? const Color(0xFF19D15C) : const Color(0xFFFF3B30);
    final sign = positive ? '+' : '-';
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.textlevel1.withOpacity(.8)),
          ),
          SizedBox(height: 6.h),
          Text(
            '$sign\$${formatMoneyInt(value)}',
            style: TextStyle(
              color: color,
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
