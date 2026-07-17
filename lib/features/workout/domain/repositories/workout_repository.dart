import '../../../../core/utils/result.dart';
import '../entities/workout_routine.dart';

/// Contract for reading routines/exercises and recording set progress.
/// [WorkoutRepositoryImpl] currently backs this with an in-memory mock
/// source; swapping to Hive/Supabase later requires no changes to callers.
abstract class WorkoutRepository {
  Stream<List<WorkoutRoutine>> watchRoutines();

  Future<Result<WorkoutRoutine>> getRoutine(String routineId);

  Future<Result<WorkoutExercise>> getExercise(String routineId, String exerciseId);

  /// Marks a single set of an exercise as completed with the given
  /// reps/weight, returning the updated exercise.
  Future<Result<WorkoutExercise>> logSet({
    required String routineId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    required double weightKg,
  });

  Future<Result<void>> markExerciseCompleted({
    required String routineId,
    required String exerciseId,
  });

  /// Adds a user-defined exercise to the given routine — matches the
  /// "Create Custom Exercise" flow reachable from Workout.
  Future<Result<WorkoutExercise>> createCustomExercise({
    required String routineId,
    required String name,
    required int targetSets,
    required String repRangeLabel,
    required List<MuscleGroup> primaryMuscles,
    List<String> instructions,
  });

  Future<Result<void>> deleteCustomExercise({
    required String routineId,
    required String exerciseId,
  });
}
