// pages/achievements_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/achievements_cubit.dart';
import '../widgets/progress_bar.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  int _tab = 0; // 0=On the Way, 1=Achieved

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AchievementsCubit>();
    final list = _tab == 0 ? c.onTheWay : c.achieved;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'ACHIEVEMENTS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _segBtn('On the Way', _tab == 0, () => setState(() => _tab = 0)),
              const SizedBox(width: 8),
              _segBtn('Achieved', _tab == 1, () => setState(() => _tab = 1)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Text(
                      'No Achievements Completed',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: .75,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final a = list[i];
                      final active = a.achieved;
                      return Container(
                        decoration: BoxDecoration(
                          color: active
                              ? const Color(0xFF0A46C9)
                              : const Color(0xFF1A1D24),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 26,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              a.def.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              a.def.desc,
                              style: TextStyle(
                                color: Colors.white.withOpacity(.8),
                                fontSize: 12,
                              ),
                            ),
                            const Spacer(),
                            if (!active)
                              AppProgressBar(value: a.current / a.def.target),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _segBtn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF0062FF)
              : Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
