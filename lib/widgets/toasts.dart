import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/achievements_cubit.dart';
import 'package:personal_rise_daily_growth_336t/main.dart';
import 'package:personal_rise_daily_growth_336t/models/level_models.dart';


class GlobalToasts extends StatefulWidget {
  const GlobalToasts({super.key, required this.child});
  final Widget child;

  @override
  State<GlobalToasts> createState() => _GlobalToastsState();
}

class _GlobalToastsState extends State<GlobalToasts> {
  Set<String> _lastAchieved = const {};
  
  @override
  void initState() {
    super.initState();
    // первичная инициализация после первого кадра
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ach = context.read<AchievementsCubit>().state;
      _lastAchieved = _achievedIds(ach);
    });
  }

  Set<String> _achievedIds(AchievementsState s) =>
      s.snapshot.achievements.where((a) => a.achieved).map((a) => a.def.id).toSet();

  void _showOverlayToast(Widget child, {Duration duration = const Duration(seconds: 6)}) {
    final overlay = appNavigatorKey.currentState?.overlay; // root overlay
    if (overlay == null) return;
    final entry = OverlayEntry(builder: (_) {
      return SafeArea(
        child: IgnorePointer(
          ignoring: true,
          child: Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(top: 12),
            child: Material(color: Colors.transparent, child: child),
          ),
        ),
      );
    });
    overlay.insert(entry);
    Future.delayed(duration, () { try { entry.remove(); } catch (_) {} });
  }

  Widget _toastContainer({required Widget leading, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFF2A2E37), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          leading, const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(subtitle, style: const TextStyle(color: Colors.white70), maxLines: 2, overflow: TextOverflow.ellipsis),
          ])),
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Уровень вырос — тост в любом месте приложения
        BlocListener<LevelCubit, LevelState>(
          listenWhen: (prev, curr) => prev.level != curr.level,
          listener: (_, _) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showOverlayToast(_levelUpToast(), duration: const Duration(seconds: 10));
            });
          },
        ),
        // Закрыта новая ачивка — тост
        BlocListener<AchievementsCubit, AchievementsState>(
          listenWhen: (prev, curr) =>
              _achievedIds(curr).length > _achievedIds(prev).length,
          listener: (_, curr) {
            final now = _achievedIds(curr);
            final diff = now.difference(_lastAchieved);
            if (diff.isNotEmpty) {
              final newly = curr.snapshot.achievements.firstWhere(
                (a) => a.achieved && diff.contains(a.def.id),
                orElse: () => curr.snapshot.achievements.firstWhere((a) => a.achieved),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _showOverlayToast(_achievementToast(newly.def.title, newly.def.desc));
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
