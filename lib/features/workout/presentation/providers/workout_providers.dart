import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/workout_local_datasource.dart';
import '../../data/repositories/workout_repository_impl.dart';
import '../../domain/entities/workout_routine.dart';
import '../../domain/repositories/workout_repository.dart';

final workoutLocalDataSourceProvider = Provider((ref) => WorkoutLocalDataSource());

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepositoryImpl(ref.watch(workoutLocalDataSourceProvider));
});

/// Bumped by [WorkoutActions] after any write so [workoutRoutinesProvider]
/// (and everything derived from it) refreshes.
final _workoutRefreshTickProvider = StateProvider<int>((ref) => 0);

final workoutRoutinesProvider = StreamProvider<List<WorkoutRoutine>>((ref) {
  ref.watch(_workoutRefreshTickProvider);
  return ref.watch(workoutRepositoryProvider).watchRoutines();
});

/// A single routine looked up by id from the already-loaded routines list,
/// so the Workout Detail screen doesn't need a separate network round trip.
final routineByIdProvider = Provider.family<WorkoutRoutine?, String>((ref, routineId) {
  final routines = ref.watch(workoutRoutinesProvider).asData?.value ?? [];
  for (final routine in routines) {
    if (routine.id == routineId) return routine;
  }
  return null;
});

/// A single exercise looked up from its parent routine.
final exerciseByIdProvider =
    Provider.family<WorkoutExercise?, ({String routineId, String exerciseId})>((ref, args) {
  final routine = ref.watch(routineByIdProvider(args.routineId));
  if (routine == null) return null;
  for (final exercise in routine.exercises) {
    if (exercise.id == args.exerciseId) return exercise;
  }
  return null;
});

/// Tracks which set index (0-based) is currently active on the Active Set
/// screen, per exercise, so navigating back and forth resumes progress.
final activeSetIndexProvider = StateProvider.family<int, String>((ref, exerciseId) => 0);

/// Write-side actions for Workout, mirroring [NutritionActions]'s pattern:
/// kept off the read providers so screens can call
/// `ref.read(workoutActionsProvider).createCustomExercise(...)` without
/// rebuilding on unrelated state changes.
final workoutActionsProvider = Provider((ref) => WorkoutActions(ref));

class WorkoutActions {
  WorkoutActions(this._ref);
  final Ref _ref;

  Future<WorkoutExercise?> createCustomExercise({
    required String routineId,
    required String name,
    required int targetSets,
    required String repRangeLabel,
    required List<MuscleGroup> primaryMuscles,
    List<String> instructions = const [],
  }) async {
    final result = await _ref.read(workoutRepositoryProvider).createCustomExercise(
          routineId: routineId,
          name: name,
          targetSets: targetSets,
          repRangeLabel: repRangeLabel,
          primaryMuscles: primaryMuscles,
          instructions: instructions,
        );
    _ref.read(_workoutRefreshTickProvider.notifier).state++;
    return result.dataOrNull;
  }

  Future<void> deleteCustomExercise({
    required String routineId,
    required String exerciseId,
  }) async {
    await _ref
        .read(workoutRepositoryProvider)
        .deleteCustomExercise(routineId: routineId, exerciseId: exerciseId);
    _ref.read(_workoutRefreshTickProvider.notifier).state++;
  }
}
