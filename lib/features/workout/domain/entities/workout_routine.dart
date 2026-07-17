import 'package:equatable/equatable.dart';

/// One of the split-day routines shown as tabs/cards on the Workout screen
/// (Push Day, Pull Day, Leg Day, Full Body in the reference). Each routine
/// owns an ordered list of [WorkoutExercise]s that make up its plan.
class WorkoutRoutine extends Equatable {
  const WorkoutRoutine({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.exercises,
    this.isToday = false,
  });

  final String id;
  final String name; // "Push Day"
  final String subtitle; // "Chest • Shoulders • Triceps"
  final List<WorkoutExercise> exercises;
  final bool isToday;

  int get completedCount => exercises.where((e) => e.isCompleted).length;
  int get totalCount => exercises.length;
  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  @override
  List<Object?> get props => [id, name, subtitle, exercises, isToday];
}

enum MuscleGroup { chest, back, legs, shoulders, arms, core, fullBody }

extension MuscleGroupLabel on MuscleGroup {
  String get label => switch (this) {
        MuscleGroup.chest => 'Chest',
        MuscleGroup.back => 'Back',
        MuscleGroup.legs => 'Legs',
        MuscleGroup.shoulders => 'Shoulders',
        MuscleGroup.arms => 'Arms',
        MuscleGroup.core => 'Core',
        MuscleGroup.fullBody => 'Full Body',
      };
}

/// A single exercise within a routine (e.g. "Bench Press"), including the
/// set/rep prescription and the live in-progress sets once a workout has
/// been started.
class WorkoutExercise extends Equatable {
  const WorkoutExercise({
    required this.id,
    required this.name,
    required this.targetSets,
    required this.repRangeLabel,
    required this.primaryMuscles,
    this.instructions = const [],
    this.sets = const [],
    this.isCompleted = false,
  });

  final String id;
  final String name; // "Bench Press"
  final int targetSets; // 4
  final String repRangeLabel; // "8-12 reps"
  final List<MuscleGroup> primaryMuscles;
  final List<String> instructions;
  final List<WorkoutSet> sets;
  final bool isCompleted;

  /// Whether this exercise was added by the user via "Create Custom
  /// Exercise" rather than shipped in the seeded routines. Drives the
  /// delete affordance shown on custom entries.
  bool get isCustom => id.startsWith('custom-exercise-');

  WorkoutExercise copyWith({List<WorkoutSet>? sets, bool? isCompleted}) {
    return WorkoutExercise(
      id: id,
      name: name,
      targetSets: targetSets,
      repRangeLabel: repRangeLabel,
      primaryMuscles: primaryMuscles,
      instructions: instructions,
      sets: sets ?? this.sets,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, targetSets, repRangeLabel, primaryMuscles, instructions, sets, isCompleted];
}

/// One working set of an exercise, editable live during a workout — mirrors
/// the "Set 2 of 4 / Reps 10 / Weight (kg) 60" tracker on the reference
/// active-set screen.
class WorkoutSet extends Equatable {
  const WorkoutSet({
    required this.setNumber,
    required this.reps,
    required this.weightKg,
    this.isCompleted = false,
  });

  final int setNumber;
  final int reps;
  final double weightKg;
  final bool isCompleted;

  WorkoutSet copyWith({int? reps, double? weightKg, bool? isCompleted}) {
    return WorkoutSet(
      setNumber: setNumber,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [setNumber, reps, weightKg, isCompleted];
}
