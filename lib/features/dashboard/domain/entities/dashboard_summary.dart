import 'package:equatable/equatable.dart';

/// Aggregate snapshot of everything the Dashboard/Home screen shows in one
/// glance. Assembled by [DashboardRepository] from several feature sources
/// (fasting, workout, nutrition) — the dashboard itself owns no primary
/// data, only this read-model.
class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.userDisplayName,
    required this.fasting,
    required this.workout,
    required this.calories,
    required this.todaysMeals,
    required this.tip,
  });

  final String userDisplayName;
  final FastingStatus fasting;
  final WorkoutSummary workout;
  final CalorieSummary calories;
  final List<MealSlot> todaysMeals;
  final String tip;

  @override
  List<Object?> get props =>
      [userDisplayName, fasting, workout, calories, todaysMeals, tip];
}

class FastingStatus extends Equatable {
  const FastingStatus({
    required this.isActive,
    required this.planLabel,
    required this.remaining,
    required this.endsAt,
  });

  final bool isActive;
  final String planLabel; // e.g. "16:8"
  final Duration remaining;
  final DateTime endsAt;

  @override
  List<Object?> get props => [isActive, planLabel, remaining, endsAt];
}

class WorkoutSummary extends Equatable {
  const WorkoutSummary({required this.completedCount, required this.totalCount});

  final int completedCount;
  final int totalCount;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  @override
  List<Object?> get props => [completedCount, totalCount];
}

class CalorieSummary extends Equatable {
  const CalorieSummary({required this.consumed, required this.goal});

  final int consumed;
  final int goal;

  double get progress => goal == 0 ? 0 : (consumed / goal).clamp(0, 1);

  @override
  List<Object?> get props => [consumed, goal];
}

enum MealType { breakfast, lunch, dinner, snack }

class MealSlot extends Equatable {
  const MealSlot({
    required this.type,
    required this.label,
    required this.calories,
    required this.isLogged,
  });

  final MealType type;
  final String label;
  final int calories;
  final bool isLogged;

  @override
  List<Object?> get props => [type, label, calories, isLogged];
}
