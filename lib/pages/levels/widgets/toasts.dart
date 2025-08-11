import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/achievements_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/pages/levels/achievements_page.dart';
import 'package:personal_rise_daily_growth_336t/pages/levels/widgets/show_help.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';
import 'package:personal_rise_daily_growth_336t/widgets/progress_bar.dart';

void showOverlayLevelToast(BuildContext context, Widget child, {Duration duration = const Duration(seconds: 6)}) {
  final overlay = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      top: 80, // чуть ниже статус-бара
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: child,
      ),
    ),
  );
  overlay.insert(entry);
  Future.delayed(duration, () {
    entry.remove();
  });
}


class LevelUpToast extends StatelessWidget {
  const LevelUpToast({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E37),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: const [
          Text('⭐ ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Level up!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                SizedBox(height: 2),
                Text("Your character has evolved thanks to your discipline.",
                    style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AchievementToast extends StatelessWidget {
  final String title, subtitle;
  const AchievementToast({super.key, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E37),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🏆 ', style: TextStyle(fontSize: 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('New Achievement!',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text('$title — $subtitle',
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
