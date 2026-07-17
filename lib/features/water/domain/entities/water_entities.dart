import 'package:equatable/equatable.dart';

/// Today's hydration snapshot — cups logged against a daily cup goal,
/// matching the reference "6 / 8 Cups" ring screen.
class WaterDay extends Equatable {
  const WaterDay({
    required this.date,
    required this.cupsLogged,
    required this.cupGoal,
    required this.cupSizeMl,
  });

  final DateTime date;
  final int cupsLogged;
  final int cupGoal;
  final int cupSizeMl;

  double get progress => cupGoal == 0 ? 0 : (cupsLogged / cupGoal).clamp(0, 1).toDouble();
  bool get goalReached => cupsLogged >= cupGoal;
  int get totalMl => cupsLogged * cupSizeMl;

  WaterDay copyWith({int? cupsLogged}) {
    return WaterDay(
      date: date,
      cupsLogged: cupsLogged ?? this.cupsLogged,
      cupGoal: cupGoal,
      cupSizeMl: cupSizeMl,
    );
  }

  @override
  List<Object?> get props => [date, cupsLogged, cupGoal, cupSizeMl];
}

/// One day in the weekly hydration history strip.
class WaterHistoryEntry extends Equatable {
  const WaterHistoryEntry({
    required this.date,
    required this.cupsLogged,
    required this.cupGoal,
  });

  final DateTime date;
  final int cupsLogged;
  final int cupGoal;

  bool get goalMet => cupsLogged >= cupGoal;

  @override
  List<Object?> get props => [date, cupsLogged, cupGoal];
}

/// Aggregate stats for the Water tab, e.g. current streak of goal-met days.
class WaterStats extends Equatable {
  const WaterStats({
    required this.currentStreakDays,
    required this.averageCupsPerDay,
  });

  final int currentStreakDays;
  final double averageCupsPerDay;

  @override
  List<Object?> get props => [currentStreakDays, averageCupsPerDay];
}
