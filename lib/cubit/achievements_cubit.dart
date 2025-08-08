// cubit/achievements_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:personal_rise_daily_growth_336t/cubit/level_cubit.dart';
import 'package:personal_rise_daily_growth_336t/models/achievement_models.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/services/progress_service.dart';

class AchievementsState {
  final ProgressSnapshot snapshot;
  AchievementsState(this.snapshot);
}

class AchievementsCubit extends Cubit<AchievementsState> {
  final LevelCubit levelCubit;
  final List<HabitLog> _logs = [];

  AchievementsCubit(this.levelCubit)
    : super(
        AchievementsState(
          ProgressService.buildSnapshot(
            level: levelCubit.state,
            logs: const [],
          ),
        ),
      );

  void addLog(HabitLog log) {
    _logs.add(log);
    // Hive: тут можно сохранять _logs
    final snap = ProgressService.buildSnapshot(
      level: levelCubit.state,
      logs: _logs,
    );
    emit(AchievementsState(snap));
  }

  List<AchievementProgress> get onTheWay =>
      state.snapshot.achievements.where((a) => !a.achieved).toList();

  List<AchievementProgress> get achieved =>
      state.snapshot.achievements.where((a) => a.achieved).toList();

  int get topSaved => state.snapshot.totalSaved;
  int get topWasted => state.snapshot.totalWasted;
}
