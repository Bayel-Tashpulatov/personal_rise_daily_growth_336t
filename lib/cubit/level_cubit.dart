// cubit/level_cubit.dart
import 'package:bloc/bloc.dart';
import 'package:personal_rise_daily_growth_336t/models/level_models.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/services/progress_service.dart';

class LevelCubit extends Cubit<LevelState> {
  LevelCubit() : super(const LevelState(level: 1, points: 0, maxScore: 0));

  /// вернёт true если был апгрейд уровня
  bool applyLog(HabitLog log) {
    final before = state;
    final after = ProgressService.applyPoints(state, log);
    emit(after);
    return after.level > before.level;
  }

  void resetForDemo(int level) {
    emit(LevelState(level: level.clamp(1, 5), points: 0, maxScore: 0));
  }
}
