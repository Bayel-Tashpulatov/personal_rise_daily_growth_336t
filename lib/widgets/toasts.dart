import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/achievements_cubit.dart';
import 'package:personal_rise_daily_growth_336t/main.dart';
import 'package:personal_rise_daily_growth_336t/models/level_models.dart';
import 'package:personal_rise_daily_growth_336t/theme/app_colors.dart';

class GlobalToasts extends StatefulWidget {
  const GlobalToasts({super.key, required this.child});
  final Widget child;

  @override
  State<GlobalToasts> createState() => _GlobalToastsState();
}

class _GlobalToastsState extends State<GlobalToasts> {
  Set<String> _lastAchieved = const {};
  final Set<String> _toastsShown = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ach = context.read<AchievementsCubit>().state;
      _lastAchieved = _achievedIds(ach);
    });
  }

  Set<String> _achievedIds(AchievementsState s) => s.snapshot.achievements
      .where((a) => a.achieved)
      .map((a) => a.def.id)
      .toSet();

  void _showToast(
    Widget content, {
    Duration duration = const Duration(seconds: 6),
  }) {
    final overlay = appNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          IgnorePointer(
            ignoring: true,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(top: 12.h),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Material(
                    color: Colors.transparent,
                    child: _AnimatedToastBanner(
                      onDone: () {
                        try {
                          entry.remove();
                        } catch (_) {}
                      },
                      duration: duration,
                      child: content,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LevelCubit, LevelState>(
          listenWhen: (prev, curr) => prev.level != curr.level,
          listener: (_, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showToast(
                _ToastSurface(
                  height: 120.h,
                  leading: Image.asset(
                    'assets/icons/star.png',
                    width: 24.w,
                    height: 24.w,
                  ),
                  title: 'Level up!',
                  subtitle:
                      'Your character has evolved thanks to your discipline.',
                ),
                duration: const Duration(seconds: 10),
              );
            });
          },
        ),

        BlocListener<AchievementsCubit, AchievementsState>(
          listenWhen: (prev, curr) =>
              _achievedIds(curr).length != _achievedIds(prev).length,
          listener: (_, curr) {
            final now = _achievedIds(curr);
            final diff = now.difference(_lastAchieved);

            final fresh = diff
                .where((id) => !_toastsShown.contains(id))
                .toList();
            if (fresh.isNotEmpty) {
              final newly = curr.snapshot.achievements.firstWhere(
                (a) => a.achieved && fresh.contains(a.def.id),
              );
              _toastsShown.add(newly.def.id);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showToast(
                  _ToastSurface(
                    height: 100.h,
                    leading: Image.asset(
                      'assets/icons/cup.png',
                      width: 24.w,
                      height: 24.w,
                    ),
                    title: 'New Achievement!',
                    subtitle: '${newly.def.title} — ${newly.def.desc}',
                  ),
                );
              });
            }
            _lastAchieved = now;
          },
        ),
      ],
      child: widget.child,
    );
  }
}

class _ToastSurface extends StatelessWidget {
  const _ToastSurface({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.height = 64,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final double height;

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final maxW = screenW.clamp(0, 420).toDouble();

    return Container(
      constraints: BoxConstraints(maxWidth: maxW, maxHeight: height),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLevel2,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          width: 1.w,
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24.w,
            height: 24.w,
            child: FittedBox(child: leading),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.40,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontFamily: 'SF Pro',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedToastBanner extends StatefulWidget {
  const _AnimatedToastBanner({
    required this.child,
    required this.onDone,
    required this.duration,
  });

  final Widget child;
  final VoidCallback onDone;
  final Duration duration;

  @override
  State<_AnimatedToastBanner> createState() => _AnimatedToastBannerState();
}

class _AnimatedToastBannerState extends State<_AnimatedToastBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0.25, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));
  late final Animation<double> _fade = CurvedAnimation(
    parent: _ac,
    curve: Curves.easeOut,
  );

  @override
  void initState() {
    super.initState();
    _ac.forward();

    Future.delayed(widget.duration, () async {
      if (!mounted) return;
      await _ac.reverse();
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(opacity: _fade, child: widget.child),
      ),
    );
  }
}
