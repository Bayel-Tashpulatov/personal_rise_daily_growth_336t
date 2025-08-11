import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/achievements_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/achievement_models.dart';
import 'package:personal_rise_daily_growth_336t/models/level_models.dart';
import 'package:personal_rise_daily_growth_336t/pages/levels/achievements_page.dart';
import 'package:personal_rise_daily_growth_336t/pages/levels/widgets/show_help.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';
import 'package:personal_rise_daily_growth_336t/widgets/progress_bar.dart';

class LevelScreen extends StatelessWidget {
  const LevelScreen({super.key});

  int _achievedCount(AchievementsState s) =>
      s.snapshot.achievements.where((a) => a.achieved).length;

  Set<String> _achievedIds(AchievementsState s) => s.snapshot.achievements
      .where((a) => a.achieved)
      .map((a) => a.def.id)
      .toSet();

  List<AchievementProgress> _pickNearestThree(List<AchievementProgress> all) {
    // только незакрытые
    final list = all.where((a) => !a.achieved).toList();

    // приоритет категорий как в макете
    const order = [
      AchievementKind.streakDays,
      AchievementKind.savedMoney,
      AchievementKind.cleanDays,
    ];

    AchievementProgress? pickFor(AchievementKind k) {
      final sameKind = list.where((a) => a.def.kind == k).toList();
      if (sameKind.isEmpty) return null;
      sameKind.sort((a, b) {
        final ra = a.def.target - a.current; // сколько осталось
        final rb = b.def.target - b.current;
        if (ra != rb) return ra.compareTo(rb);
        // равные — берём с меньшей целью (проще)
        return a.def.target.compareTo(b.def.target);
      });
      return sameKind.first;
    }

    final result = <AchievementProgress>[];
    for (final k in order) {
      final p = pickFor(k);
      if (p != null) result.add(p);
      if (result.length == 3) break;
    }
    // если категорий не хватило — добьём любыми ближайшими
    if (result.length < 3) {
      final rest =
          list.where((a) => !result.any((r) => r.def.id == a.def.id)).toList()
            ..sort(
              (a, b) => (a.def.target - a.current).compareTo(
                b.def.target - b.current,
              ),
            );
      for (final a in rest) {
        if (result.length == 3) break;
        result.add(a);
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final levelCubit = context.watch<LevelCubit>();
    final achCubit = context.watch<AchievementsCubit>();
    final s = levelCubit.state;
    final LayerLink helpLink = LayerLink();
    final GlobalKey bgKey = GlobalKey();
    final nearest = _pickNearestThree(achCubit.state.snapshot.achievements);
    return MultiBlocListener(
      listeners: [
        // LEVEL UP
        BlocListener<LevelCubit, LevelState>(
          listenWhen: (prev, curr) => prev.level != curr.level,
          listener: (context, state) {
            _showOverlayToast(
              context,
              _levelUpToast(),
              duration: const Duration(seconds: 10),
            );
          },
        ),
        // ACHIEVEMENT UNLOCKED
        BlocListener<AchievementsCubit, AchievementsState>(
          listenWhen: (prev, curr) =>
              _achievedCount(curr) > _achievedCount(prev),
          listener: (context, curr) {
            // найдём «новую» ачивку по id
            final before = _achievedIds(
              context.read<AchievementsCubit>().state,
            );
            final nowIds = _achievedIds(curr);
            final newId = (nowIds.difference(before).isNotEmpty)
                ? nowIds.difference(before).first
                : null;

            final newly = curr.snapshot.achievements.firstWhere(
              (a) => a.achieved && (newId == null || a.def.id == newId),
              orElse: () =>
                  curr.snapshot.achievements.firstWhere((a) => a.achieved),
            );

            _showOverlayToast(
              context,
              _achievementToast(newly.def.title, newly.def.desc),
            );
          },
        ),
      ],

      child: Scaffold(
        backgroundColor: AppColors.backgroundLevel1,
        body: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  key: bgKey,
                  height: 560.h,
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/level_${s.level}.png',
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  left: 16.w,
                  right: 16.w,
                  bottom: 16.h,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _levelTitle(levelCubit),
                        style: TextStyle(
                          color: AppColors.textlevel1,
                          fontSize: 24.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.48,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      if (!s.isMax)
                        AppProgressBar(value: s.progress, minHeight: 36)
                      else
                        Row(
                          children: [
                            _chip('Max Level!'),
                            const SizedBox(width: 8),
                            _chip('Your Score: ${s.maxScore}'),
                          ],
                        ),
                      SizedBox(height: 10.h),
                      Text(
                        _levelDescription(s.level),
                        style: TextStyle(
                          color: AppColors.textlevel1,
                          fontSize: 15.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.30,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 52.h,
                  right: 12.w,
                  child: CompositedTransformTarget(
                    link: helpLink,
                    child: IconButton(
                      icon: Container(
                        width: 44.w,
                        height: 44.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLevel2,
                          borderRadius: BorderRadius.circular(34.r),
                        ),
                        child: Image.asset(
                          'assets/icons/question_mark.png',
                          color: AppColors.textlevel1,
                          width: 16.sp,
                          height: 16.sp,
                        ),
                      ),
                      onPressed: () => showLevelHelp(
                        context,
                        helpLink,
                        bgKey: bgKey,
                        anchorSize: 44,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 24.h),
                children: [
                  Row(
                    children: [
                      Text(
                        'Achievments:',
                        style: TextStyle(
                          color: AppColors.textlevel1,
                          fontSize: 18.sp,
                          fontFamily: 'SF Pro',
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.36,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AchievementsPage(),
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text(
                              'View All',
                              style: TextStyle(
                                color: AppColors.textlevel1,
                                fontSize: 15.sp,
                                fontFamily: 'SF Pro',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.30,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Image.asset(
                              'assets/icons/arrow_right.png',
                              width: 24.w,
                              height: 24.w,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  ...[
                    for (int i = 0; i < nearest.length; i++)
                      _achievementPreview(
                        nearest[i].def.title,
                        nearest[i].def.desc,
                        nearest[i].current / nearest[i].def.target,
                        dim: i > 0, // первая — норм, остальные — тусклее
                      ),
                    if (nearest.isEmpty)
                      _emptyBox('All Achievements Completed!'),
                  ],
                ],
              ),
            ),
          ],
        ),
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
  Widget _achievementPreview(
    String title,
    String subtitle,
    double value, {
    bool dim = false,
  }) {
    return Opacity(
      opacity: dim ? 0.1 : 1.0,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundLevel2,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: AppColors.textlevel1,
                fontSize: 16.sp,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w900,
                letterSpacing: 0.32,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: AppColors.textlevel1,
                fontSize: 15.sp,
                fontFamily: 'SF Pro',
                fontWeight: FontWeight.w400,
                letterSpacing: 0.30,
              ),
            ),
            SizedBox(height: 4.h),
            AppProgressBar(value: value, minHeight: 16),
          ],
        ),
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

  String _levelTitle(LevelCubit c) {
    switch (c.state.level) {
      case 1:
        return 'Level 1 — Struggling';
      case 2:
        return 'Level 2 — Stabilizing';
      case 3:
        return 'Level 3 — Progressing';
      case 4:
        return 'Level 4 — Comfortable';
      case 5:
        return 'Level 5 — Successful';
      default:
        return 'Level';
    }
  }

  String _levelDescription(int level) {
    switch (level) {
      case 1:
        return "You're at the beginning of your journey — it's tough, but every good habit counts.";
      case 2:
        return "Your current level: Stabilizing. You're starting to get things under control. Keep building good habits to move forward.";
      case 3:
        return "Your current level: Progressing. Your efforts are paying off — your habits are reshaping your future.";
      case 4:
        return "Your current level: Comfortable. You’ve built a strong foundation. Now it’s time to aim higher.";
      case 5:
        return "YYour current level: Successful. You’ve become your best financial self — maintain it and inspire your future.";
      default:
        return '';
    }
  }

  void _showOverlayToast(
    BuildContext context,
    Widget child, {
    Duration duration = const Duration(seconds: 6),
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (ctx) => SafeArea(
        child: IgnorePointer(
          ignoring: true, // клики проходят сквозь
          child: Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(top: 12),
            child: Material(
              color: Colors.transparent,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: 1,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    Future.delayed(duration, () {
      entry.remove();
    });
  }

  Widget _toastContainer({
    required Widget leading,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2E37),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelUpToast() => _toastContainer(
    leading: const Text('⭐', style: TextStyle(fontSize: 18)),
    title: 'Level up!',
    subtitle: 'Your character has evolved thanks to your discipline.',
  );

  Widget _achievementToast(String title, String desc) => _toastContainer(
    leading: const Text('🏆', style: TextStyle(fontSize: 18)),
    title: 'New Achievement!',
    subtitle: '$title — $desc',
  );
}
