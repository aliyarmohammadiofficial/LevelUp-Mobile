import 'package:equatable/equatable.dart';

/// Aggregate snapshot for the Progress screen's four tabs (Overview,
/// Weight, Body, Workouts) — read-model only, assembled by
/// [ProgressRepository] from weight logs and workout history.
class ProgressSummary extends Equatable {
  const ProgressSummary({
    required this.currentWeightKg,
    required this.weightChangeKg,
    required this.weightChangePeriodLabel,
    required this.weightHistory,
    required this.goalWeightKg,
    required this.bmi,
    required this.bodyMeasurements,
    required this.bodyMeasurementsUpdatedAt,
    required this.weeklyWorkouts,
  });

  final double currentWeightKg;
  final double weightChangeKg; // negative = lost weight
  final String weightChangePeriodLabel; // e.g. "from last month"
  final List<WeightPoint> weightHistory;
  final double goalWeightKg;
  final double bmi;
  final List<BodyMeasurement> bodyMeasurements;
  final DateTime? bodyMeasurementsUpdatedAt; // null = never logged
  final List<WorkoutLogEntry> weeklyWorkouts;

  @override
  List<Object?> get props => [
        currentWeightKg,
        weightChangeKg,
        weightChangePeriodLabel,
        weightHistory,
        goalWeightKg,
        bmi,
        bodyMeasurements,
        bodyMeasurementsUpdatedAt,
        weeklyWorkouts,
      ];
}

class WeightPoint extends Equatable {
  const WeightPoint({required this.date, required this.weightKg});

  final DateTime date;
  final double weightKg;

  @override
  List<Object?> get props => [date, weightKg];
}

class BodyMeasurement extends Equatable {
  const BodyMeasurement({
    required this.label,
    required this.valueCm,
    required this.changeCm,
  });

  final String label; // e.g. "Chest", "Waist", "Hips", "Arms"
  final double valueCm;
  final double changeCm; // negative = decreased

  @override
  List<Object?> get props => [label, valueCm, changeCm];
}

/// One trackable body measurement site, grouped for the capture form and
/// ordered for consistent display everywhere the list is rendered.
class BodyMeasurementField extends Equatable {
  const BodyMeasurementField(this.label, this.group);

  final String label;
  final String group;

  @override
  List<Object?> get props => [label, group];
}

/// Single source of truth for which body sites LevelUp tracks. Both the
/// capture screen (grouped sections) and the persistence layer (which
/// keys to read/write) key off this list, so adding a new site only
/// means editing it here.
abstract class BodyMeasurementFields {
  BodyMeasurementFields._();

  static const List<BodyMeasurementField> all = [
    BodyMeasurementField('Neck', 'Upper Body'),
    BodyMeasurementField('Shoulders', 'Upper Body'),
    BodyMeasurementField('Chest', 'Upper Body'),
    BodyMeasurementField('Waist', 'Core'),
    BodyMeasurementField('Hips', 'Core'),
    BodyMeasurementField('Bicep', 'Arms & Legs'),
    BodyMeasurementField('Thigh', 'Arms & Legs'),
    BodyMeasurementField('Calf', 'Arms & Legs'),
  ];

  static List<String> get groups =>
      all.map((f) => f.group).toSet().toList(growable: false);

  static List<BodyMeasurementField> inGroup(String group) =>
      all.where((f) => f.group == group).toList(growable: false);
}

class WorkoutLogEntry extends Equatable {
  const WorkoutLogEntry({
    required this.date,
    required this.label,
    required this.durationMinutes,
    required this.completed,
  });

  final DateTime date;
  final String label; // e.g. "Push Day"
  final int durationMinutes;
  final bool completed;

  @override
  List<Object?> get props => [date, label, durationMinutes, completed];
}
