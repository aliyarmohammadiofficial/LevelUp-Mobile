import 'package:equatable/equatable.dart';

/// Real, persisted XP/level state, replacing the previous fixed mock
/// ("Level 12" for everyone). XP is earned from actual app activity —
/// water goal hit, workout exercise completed, fast completed — recorded
/// by [GamificationLocalDataSource] and totalled here.
class GamificationStats extends Equatable {
  const GamificationStats({required this.totalXp});

  final int totalXp;

  /// Level thresholds grow linearly by [xpPerLevel] — level N requires
  /// N * xpPerLevel total XP. Simple and predictable rather than a curve,
  /// matching the rest of the app's straightforward, readable-progress style
  /// (e.g. Water's "cups / goal", Fasting's "hours / target").
  static const int xpPerLevel = 500;

  int get level => (totalXp ~/ xpPerLevel) + 1;

  int get xpIntoLevel => totalXp % xpPerLevel;

  int get xpForNextLevel => xpPerLevel;

  double get levelProgress => xpIntoLevel / xpForNextLevel;

  GamificationStats copyWith({int? totalXp}) {
    return GamificationStats(totalXp: totalXp ?? this.totalXp);
  }

  @override
  List<Object?> get props => [totalXp];
}

/// Points awarded per real event. Centralized so every feature that awards
/// XP (Water, Workout, Fasting) uses the same values and it's obvious at a
/// glance what each activity is worth.
abstract class XpRewards {
  XpRewards._();

  static const int waterGoalMetToday = 20;
  static const int workoutExerciseCompleted = 15;
  static const int workoutRoutineCompleted = 40;
  static const int fastCompleted = 30;
  static const int streakMilestoneBonus = 50;
}
