// pages/level_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_rise_daily_growth_336t/cubit/achievements_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/pages/levels/achievements_page.dart';
import 'package:personal_rise_daily_growth_336t/widgets/progress_bar.dart';
import 'package:personal_rise_daily_growth_336t/widgets/toast.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  String _title(LevelCubit c) {
    switch (c.state.level) {
      case 1:
        return 'Level 1 — Struggling';
      case 2:
        return 'Level 2 — Stabilizing';
      case 3:
        return 'Level 3 — Improving';
      case 4:
        return 'Level 4 — Thriving';
      case 5:
        return 'Level 5 — Successful';
      default:
        return 'Level';
    }
  }

  @override
  Widget build(BuildContext context) {
    final levelCubit = context.watch<LevelCubit>();
    final achCubit = context.watch<AchievementsCubit>();
    final s = levelCubit.state;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: Column(
        children: [
          // Верхняя несроллящаяся часть
          Stack(
            children: [
              // background персонаж (поставь свой asset)
              SizedBox(
                height: 528,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/level_${s.level}.png',
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _title(levelCubit),
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!s.isMax)
                      AppProgressBar(value: s.progress)
                    else
                      Row(
                        children: [
                          _chip('Max Level!'),
                          const SizedBox(width: 8),
                          _chip('Your Score: ${s.maxScore}'),
                        ],
                      ),
                  ],
                ),
              ),

              // ? — подсказка (Экран 2)
              Positioned(
                top: 56,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.help_outline, color: Colors.white),
                  onPressed: () {
                    _showHelp(context);
                  },
                ),
              ),
            ],
          ),

          // Контент
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Row(
                  children: [
                    const Text(
                      'Achievments:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const AchievementsPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward_ios, size: 16),
                      label: const Text('View All'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(.08),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Ближайшие достижения (несколько карточек)
                ...achCubit.onTheWay
                    .take(3)
                    .map(
                      (a) => _achievementPreview(
                        a.def.title,
                        a.def.desc,
                        a.current / a.def.target,
                      ),
                    ),
                if (achCubit.onTheWay.isEmpty)
                  _emptyBox('All Achievements Completed!'), // Экран 7
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: const Color(0xFF0062FF),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
    ),
  );

  Widget _achievementPreview(String title, String subtitle, double value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(color: Colors.white.withOpacity(.7))),
          const SizedBox(height: 10),
          AppProgressBar(value: value),
        ],
      ),
    );
  }

  Widget _emptyBox(String text) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: const Color(0xFF1A1D24),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Center(
      child: Text(text, style: const TextStyle(color: Colors.white)),
    ),
  );

  void _showHelp(BuildContext context) {
    AppToast.show(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Only good habits increase your level.',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Each good habit = +1 point.',
            style: TextStyle(color: Colors.greenAccent),
          ),
          Text(
            'Bad habits reduce progress by 3 point.',
            style: TextStyle(color: Colors.redAccent),
          ),
          Text(
            'To reach next level earn: 50 / 100 / 150 / 200.',
            style: TextStyle(color: Colors.white),
          ),
          Text(
            'Current resets on level up. Level 5 keeps accumulating.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
