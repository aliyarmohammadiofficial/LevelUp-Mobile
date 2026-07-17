import 'package:hive/hive.dart';
import '../../domain/entities/water_entities.dart';

/// Hive-backed persistence for the Water Tracker, following the same
/// plain-map pattern as [OnboardingLocalDataSource]. One box holds a
/// cup-count entry per day (keyed by ISO date), which doubles as both
/// "today" and the history/stats source — no separate aggregate table
/// needed since a week of daily ints is trivial to scan.
class WaterLocalDataSource {
  static const _boxName = 'water_box';
  static const _goalKey = '_goal';
  static const _cupSizeKey = '_cupSizeMl';
  static const defaultCupGoal = 8;
  static const defaultCupSizeMl = 250;

  Future<Box> _box() => Hive.openBox(_boxName);

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Future<WaterDay> getToday() async {
    final box = await _box();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cups = box.get(_dateKey(today), defaultValue: 0) as int;
    final goal = box.get(_goalKey, defaultValue: defaultCupGoal) as int;
    final cupSize = box.get(_cupSizeKey, defaultValue: defaultCupSizeMl) as int;
    return WaterDay(date: today, cupsLogged: cups, cupGoal: goal, cupSizeMl: cupSize);
  }

  Future<WaterDay> setCupsToday(int cups) async {
    final box = await _box();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final clamped = cups < 0 ? 0 : cups;
    await box.put(_dateKey(today), clamped);
    final goal = box.get(_goalKey, defaultValue: defaultCupGoal) as int;
    final cupSize = box.get(_cupSizeKey, defaultValue: defaultCupSizeMl) as int;
    return WaterDay(date: today, cupsLogged: clamped, cupGoal: goal, cupSizeMl: cupSize);
  }

  Future<List<WaterHistoryEntry>> getWeekHistory() async {
    final box = await _box();
    final now = DateTime.now();
    final goal = box.get(_goalKey, defaultValue: defaultCupGoal) as int;
    return List.generate(7, (i) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
      final cups = box.get(_dateKey(date), defaultValue: 0) as int;
      return WaterHistoryEntry(date: date, cupsLogged: cups, cupGoal: goal);
    });
  }

  Future<WaterStats> getStats() async {
    final history = await getWeekHistory();
    final loggedDays = history.where((h) => h.cupsLogged > 0).toList();

    int streak = 0;
    for (final entry in history.reversed) {
      if (entry.goalMet) {
        streak++;
      } else {
        break;
      }
    }

    final average = loggedDays.isEmpty
        ? 0.0
        : loggedDays.fold<int>(0, (sum, h) => sum + h.cupsLogged) / loggedDays.length;

    return WaterStats(
      currentStreakDays: streak,
      averageCupsPerDay: double.parse(average.toStringAsFixed(1)),
    );
  }
}
