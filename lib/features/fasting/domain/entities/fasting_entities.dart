import 'package:equatable/equatable.dart';

/// A fasting protocol the user can start a session with, e.g. "16:8".
class FastingPlan extends Equatable {
  const FastingPlan({
    required this.id,
    required this.label,
    required this.fastHours,
    required this.eatHours,
    required this.description,
  });

  final String id;
  final String label; // "16:8"
  final int fastHours;
  final int eatHours;
  final String description;

  @override
  List<Object?> get props => [id, label, fastHours, eatHours, description];
}

enum FastingSessionState { notStarted, fasting, eatingWindow, completed }

/// The user's current (or most recently ended) fasting session.
class FastingSession extends Equatable {
  const FastingSession({
    required this.plan,
    required this.state,
    required this.startedAt,
    required this.fastEndsAt,
    required this.eatingWindowEndsAt,
  });

  final FastingPlan plan;
  final FastingSessionState state;
  final DateTime startedAt;
  final DateTime fastEndsAt;
  final DateTime eatingWindowEndsAt;

  bool get isActive => state == FastingSessionState.fasting;

  Duration remainingIn(DateTime now) {
    final target = state == FastingSessionState.eatingWindow ? eatingWindowEndsAt : fastEndsAt;
    final remaining = target.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double progressAt(DateTime now) {
    final totalSeconds = plan.fastHours * 3600;
    final elapsed = now.difference(startedAt).inSeconds;
    return (elapsed / totalSeconds).clamp(0, 1).toDouble();
  }

  FastingSession copyWith({
    FastingSessionState? state,
    DateTime? startedAt,
    DateTime? fastEndsAt,
    DateTime? eatingWindowEndsAt,
  }) {
    return FastingSession(
      plan: plan,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      fastEndsAt: fastEndsAt ?? this.fastEndsAt,
      eatingWindowEndsAt: eatingWindowEndsAt ?? this.eatingWindowEndsAt,
    );
  }

  @override
  List<Object?> get props =>
      [plan, state, startedAt, fastEndsAt, eatingWindowEndsAt];
}

/// One completed day in the fasting history list.
class FastingHistoryEntry extends Equatable {
  const FastingHistoryEntry({
    required this.date,
    required this.planLabel,
    required this.achievedHours,
    required this.targetHours,
    required this.goalMet,
  });

  final DateTime date;
  final String planLabel;
  final double achievedHours;
  final int targetHours;
  final bool goalMet;

  @override
  List<Object?> get props => [date, planLabel, achievedHours, targetHours, goalMet];
}

/// Aggregate stats shown at the top of the History tab / summary strip.
class FastingStats extends Equatable {
  const FastingStats({
    required this.currentStreakDays,
    required this.bestStreakDays,
    required this.averageFastHours,
    required this.completedThisWeek,
  });

  final int currentStreakDays;
  final int bestStreakDays;
  final double averageFastHours;
  final int completedThisWeek;

  @override
  List<Object?> get props =>
      [currentStreakDays, bestStreakDays, averageFastHours, completedThisWeek];
}
