// lib/cubit/achievements_cubit.dart
import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/cubit/habits_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/achievement_models.dart';
import 'package:personal_rise_daily_growth_336t/services/progress_service.dart';

class AchievementsState {
  final ProgressSnapshot snapshot;
  AchievementsState(this.snapshot);
}

class AchievementsCubit extends Cubit<AchievementsState> {
  final LevelCubit levelCubit;
  final HabitsCubit habitsCubit;
  late final StreamSubscription _sub;

  AchievementsCubit(this.levelCubit, this.habitsCubit)
    : super(
        AchievementsState(
          ProgressService.buildSnapshot(
            level: levelCubit.state,
            logs: habitsCubit.state.logs,
          ),
        ),
      ) {
    _sub = habitsCubit.stream.listen((hs) {
      final snap = ProgressService.buildSnapshot(
        level: levelCubit.state,
        logs: hs.logs,
      );
      emit(AchievementsState(snap));
    });
  }

  @override
  Future<void> close() async {
    await _sub.cancel();
    return super.close();
  }

  // Удобные геттеры для UI
  List<AchievementProgress> get onTheWay =>
      state.snapshot.achievements.where((a) => !a.achieved).toList();

  List<AchievementProgress> get achieved =>
      state.snapshot.achievements.where((a) => a.achieved).toList();

  int get topSaved => state.snapshot.totalSaved;
  int get topWasted => state.snapshot.totalWasted;
}
