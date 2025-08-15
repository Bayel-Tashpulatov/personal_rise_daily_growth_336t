import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/achievements_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/achievement_models.dart';
import 'package:personal_rise_daily_growth_336t/pages/levels/achievements_page.dart';
import 'package:personal_rise_daily_growth_336t/pages/levels/widgets/show_help.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';
import 'package:personal_rise_daily_growth_336t/widgets/progress_bar.dart';

class LevelScreen extends StatefulWidget {
  const LevelScreen({super.key});

  @override
  State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> {
  final LayerLink _helpLink = LayerLink();
  final GlobalKey _bgKey = GlobalKey();

  Set<String> _lastAchievedIds = const <String>{};
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ach = context.read<AchievementsCubit>().state;
      _lastAchievedIds = _achievedIds(ach);
    });
  }

  Set<String> _achievedIds(AchievementsState s) => s.snapshot.achievements
      .where((a) => a.achieved)
      .map((a) => a.def.id)
      .toSet();

  List<AchievementProgress> _pickNearestThree(List<AchievementProgress> all) {
    final list = all.where((a) => !a.achieved).toList();

    const order = [
      AchievementKind.streakDays,
      AchievementKind.savedMoney,
      AchievementKind.cleanDays,
    ];

    AchievementProgress? pickFor(AchievementKind k) {
      final sameKind = list.where((a) => a.def.kind == k).toList();
      if (sameKind.isEmpty) return null;
      sameKind.sort((a, b) {
        final ra = a.def.target - a.current;
        final rb = b.def.target - b.current;
        if (ra != rb) return ra.compareTo(rb);

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
    final nearest = _pickNearestThree(achCubit.state.snapshot.achievements);

    return Scaffold(
      backgroundColor: AppColors.backgroundLevel1,
      body: Column(
        children: [
          Stack(
            children: [
              SizedBox(
                key: _bgKey,
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
                      AppProgressBar(
                        value: s.progress.clamp(0.0, 1.0),
                        minHeight: 36,
                      )
                    else
                      _maxLevelBanner(s.maxScore),
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
                  link: _helpLink,
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
                    onPressed: () {
                      final level = context.read<LevelCubit>().state;
                      showLevelHelp(
                        context,
                        _helpLink,
                        bgKey: _bgKey,
                        anchorSize: 44,
                        content: HelpContentLevel(
                          goodPoint: 1,
                          badPenalty: 3,
                          target: level.nextTarget ?? 0,
                          current: level.points,
                          total: level.nextTarget ?? level.points,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          Expanded(
            child: ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
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
                        Navigator.of(
                          context,
                        ).push(_slideRightToLeft(const AchievementsPage()));
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
                      (nearest[i].current / nearest[i].def.target)
                          .toDouble()
                          .clamp(0.0, 1.0),
                      dim: i > 0,
                    ),

                  if (nearest.isEmpty) _emptyBox('All Achievements Completed!'),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _maxLevelBanner(int score) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Row(
        children: [
          Text(
            'Max Level!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w900,
              letterSpacing: 0.30,
            ),
          ),
          const Spacer(),
          Text(
            'Your Score: $score',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15.sp,
              fontFamily: 'SF Pro',
              fontWeight: FontWeight.w900,
              letterSpacing: 0.30,
            ),
          ),
        ],
      ),
    );
  }

  Widget _achievementPreview(
    String title,
    String subtitle,
    double value, {
    bool dim = false,
  }) {
    return Opacity(
      opacity: dim ? 0.3 : 1.0,
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
            AppProgressBar(value: value.clamp(0.0, 1.0), minHeight: 16),
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
}

Route<T> _slideRightToLeft<T>(Widget page) => PageRouteBuilder<T>(
  transitionDuration: const Duration(milliseconds: 500),
  reverseTransitionDuration: const Duration(milliseconds: 280),
  pageBuilder: (context, animation, secondaryAnimation) => page,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final ani = Tween<Offset>(
      begin: const Offset(1, 0),
      end: Offset.zero,
    ).chain(CurveTween(curve: Curves.easeOutCubic)).animate(animation);
    return SlideTransition(position: ani, child: child);
  },
);
