// lib/features/statistics/presentation/widgets/chart_card.dart
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class ChartCard extends StatelessWidget {
  final List<({String label, int saved, int lost})> yearly;
  final int highlightMonth;
  const ChartCard({
    super.key,
    required this.yearly,
    required this.highlightMonth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SizedBox(
        height: 180.h,
        child: Center(
          child: Text(
            'Line chart here\nSaved & Lost',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textlevel1.withOpacity(.6)),
          ),
        ),
      ),
    );
  }
}
