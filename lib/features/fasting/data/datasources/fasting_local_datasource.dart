import 'package:hive/hive.dart';
import '../../domain/entities/fasting_entities.dart';

/// Hive-backed persistence for the Fasting feature, following the same
/// plain-map pattern as [OnboardingLocalDataSource] rather than a
/// generated TypeAdapter: the session is a single small record and history
/// is a bounded append-only list, so codegen overhead isn't worth it here.
///
/// Box layout:
/// - `session_box` / key `current` — the in-progress (or last-ended) session
/// - `fasting_history_box` — one entry per completed fast, keyed by ISO date
class FastingLocalDataSource {
  static const _sessionBoxName = 'fasting_session_box';
  static const _historyBoxName = 'fasting_history_box';
  static const _sessionKey = 'current';

  static const plans = [
    FastingPlan(
      id: '16-8',
      label: '16:8',
      fastHours: 16,
      eatHours: 8,
      description: 'Fast for 16 hours, eat within an 8-hour window. Great for beginners.',
    ),
    FastingPlan(
      id: '18-6',
      label: '18:6',
      fastHours: 18,
      eatHours: 6,
      description: 'A longer daily fast with a tighter 6-hour eating window.',
    ),
    FastingPlan(
      id: '20-4',
      label: '20:4',
      fastHours: 20,
      eatHours: 4,
      description: 'The "Warrior Diet" — one main meal, minimal daytime eating.',
    ),
    FastingPlan(
      id: 'omad',
      label: 'OMAD',
      fastHours: 23,
      eatHours: 1,
      description: 'One meal a day. Advanced — talk to a doctor before starting.',
    ),
  ];

  Future<Box> _sessionBox() => Hive.openBox(_sessionBoxName);
  Future<Box> _historyBox() => Hive.openBox(_historyBoxName);

  FastingPlan _planById(String id) => plans.firstWhere(
        (p) => p.id == id,
        orElse: () => plans.first,
      );

  Future<FastingSession?> getCurrentSession() async {
    final box = await _sessionBox();
    final raw = box.get(_sessionKey);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(raw as Map);
    return FastingSession(
      plan: _planById(map['planId'] as String),
      state: FastingSessionState.values[map['state'] as int],
      startedAt: DateTime.parse(map['startedAt'] as String),
      fastEndsAt: DateTime.parse(map['fastEndsAt'] as String),
      eatingWindowEndsAt: DateTime.parse(map['eatingWindowEndsAt'] as String),
    );
  }

  Future<void> saveSession(FastingSession session) async {
    final box = await _sessionBox();
    await box.put(_sessionKey, {
      'planId': session.plan.id,
      'state': session.state.index,
      'startedAt': session.startedAt.toIso8601String(),
      'fastEndsAt': session.fastEndsAt.toIso8601String(),
      'eatingWindowEndsAt': session.eatingWindowEndsAt.toIso8601String(),
    });
  }

  Future<void> clearSession() async {
    final box = await _sessionBox();
    await box.delete(_sessionKey);
  }

  /// Records a completed (or abandoned) fast into history, keyed by the
  /// day it started so re-saving the same day overwrites rather than
  /// duplicates.
  Future<void> addHistoryEntry(FastingHistoryEntry entry) async {
    final box = await _historyBox();
    final key = _dateKey(entry.date);
    await box.put(key, {
      'date': entry.date.toIso8601String(),
      'planLabel': entry.planLabel,
      'achievedHours': entry.achievedHours,
      'targetHours': entry.targetHours,
      'goalMet': entry.goalMet,
    });
  }

  Future<List<FastingHistoryEntry>> getHistory({int limit = 14}) async {
    final box = await _historyBox();
    final entries = box.values
        .map((raw) {
          final map = Map<String, dynamic>.from(raw as Map);
          return FastingHistoryEntry(
            date: DateTime.parse(map['date'] as String),
            planLabel: map['planLabel'] as String,
            achievedHours: (map['achievedHours'] as num).toDouble(),
            targetHours: map['targetHours'] as int,
            goalMet: map['goalMet'] as bool,
          );
        })
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return entries.take(limit).toList();
  }

  Future<FastingStats> getStats() async {
    final history = await getHistory(limit: 365);
    if (history.isEmpty) {
      return const FastingStats(
        currentStreakDays: 0,
        bestStreakDays: 0,
        averageFastHours: 0,
        completedThisWeek: 0,
      );
    }

    int currentStreak = 0;
    var expected = DateTime.now();
    for (final entry in history) {
      final sameDay = _isSameDay(entry.date, expected);
      final isYesterdayOfExpected =
          _isSameDay(entry.date, expected.subtract(const Duration(days: 1)));
      if (!entry.goalMet) break;
      if (sameDay || (currentStreak == 0 && isYesterdayOfExpected)) {
        currentStreak++;
        expected = entry.date;
      } else if (_isSameDay(entry.date, expected.subtract(const Duration(days: 1)))) {
        currentStreak++;
        expected = entry.date;
      } else {
        break;
      }
    }

    int bestStreak = 0;
    int running = 0;
    DateTime? prevDate;
    final chronological = history.reversed.toList();
    for (final entry in chronological) {
      if (!entry.goalMet) {
        running = 0;
        prevDate = entry.date;
        continue;
      }
      if (prevDate != null &&
          entry.date.difference(prevDate).inDays == 1) {
        running++;
      } else {
        running = 1;
      }
      bestStreak = running > bestStreak ? running : bestStreak;
      prevDate = entry.date;
    }

    final avgHours =
        history.fold<double>(0, (sum, e) => sum + e.achievedHours) / history.length;

    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    final completedThisWeek =
        history.where((e) => e.date.isAfter(weekAgo) && e.goalMet).length;

    return FastingStats(
      currentStreakDays: currentStreak,
      bestStreakDays: bestStreak,
      averageFastHours: double.parse(avgHours.toStringAsFixed(1)),
      completedThisWeek: completedThisWeek,
    );
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
