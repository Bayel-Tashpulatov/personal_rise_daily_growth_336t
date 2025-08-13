// widgets/progress_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class AppProgressBar extends StatelessWidget {
  final double value;
  final double? minHeight;
  const AppProgressBar({super.key, required this.value, this.minHeight});

  @override
  Widget build(BuildContext context) {
    final v = value.isNaN || value.isInfinite ? 0.0 : value.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: LinearProgressIndicator(
        value: v.clamp(0, 1),
        minHeight: minHeight?.h,
        backgroundColor: Color(0xFF002FD8).withValues(alpha: 0.3),
        valueColor: AlwaysStoppedAnimation(AppColors.primaryAccent),
      ),
    );
  }
}
