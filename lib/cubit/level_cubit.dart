import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:personal_rise_daily_growth_336t/models/level_models.dart';
import 'package:personal_rise_daily_growth_336t/models/habit_log.dart';
import 'package:personal_rise_daily_growth_336t/services/progress_service.dart';

class LevelCubit extends Cubit<LevelState> {
  final Box _prefs;

  LevelCubit(this._prefs) : super(_loadFromPrefs(_prefs));

  static LevelState _loadFromPrefs(Box p) {
    final level = (p.get('level') as int?) ?? 1;
    final points = (p.get('points') as int?) ?? 0;
    final maxScore = (p.get('maxScore') as int?) ?? 0;

    final s = LevelState(
      level: level.clamp(1, 5),
      points: points,
      maxScore: maxScore,
    );
    return s;
  }

  void _save(LevelState s) {
    _prefs.put('level', s.level);
    _prefs.put('points', s.points);
    _prefs.put('maxScore', s.maxScore);
  }

  @override
  void onChange(Change<LevelState> change) {
    super.onChange(change);
    _save(change.nextState);
  }

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
