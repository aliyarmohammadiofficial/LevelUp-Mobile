import '../../../../core/errors/failures.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/utils/result.dart';
import '../../../notifications/data/datasources/notifications_local_datasource.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../../../profile/data/datasources/gamification_local_datasource.dart';
import '../../../profile/domain/entities/gamification_stats.dart';
import '../../domain/entities/workout_routine.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/workout_local_datasource.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl(
    this._local, [
    GamificationLocalDataSource? gamification,
    NotificationsLocalDataSource? notifications,
  ])  : _gamification = gamification ?? GamificationLocalDataSource(),
        _notifications = notifications ?? NotificationsLocalDataSource();

  final WorkoutLocalDataSource _local;
  final GamificationLocalDataSource _gamification;
  final NotificationsLocalDataSource _notifications;

  @override
  Stream<List<WorkoutRoutine>> watchRoutines() async* {
    yield await _local.getRoutines();
  }

  @override
  Future<Result<WorkoutRoutine>> getRoutine(String routineId) async {
    final routine = await _local.getRoutine(routineId);
    if (routine == null) {
      return const Result.failure(UnknownFailure('Routine not found'));
    }
    return Result.success(routine);
  }

  @override
  Future<Result<WorkoutExercise>> getExercise(String routineId, String exerciseId) async {
    final exercise = await _local.getExercise(routineId, exerciseId);
    if (exercise == null) {
      return const Result.failure(UnknownFailure('Exercise not found'));
    }
    return Result.success(exercise);
  }

  @override
  Future<Result<WorkoutExercise>> logSet({
    required String routineId,
    required String exerciseId,
    required int setNumber,
    required int reps,
    required double weightKg,
  }) async {
    final updated = await _local.logSet(
      routineId: routineId,
      exerciseId: exerciseId,
      setNumber: setNumber,
      reps: reps,
      weightKg: weightKg,
    );
    if (updated == null) {
      return const Result.failure(UnknownFailure('Could not log set'));
    }
    if (updated.isCompleted) {
      await _onExerciseCompleted(routineId, updated);
    }
    return Result.success(updated);
  }

  @override
  Future<Result<void>> markExerciseCompleted({
    required String routineId,
    required String exerciseId,
  }) async {
    await _local.markExerciseCompleted(routineId: routineId, exerciseId: exerciseId);
    final exercise = await _local.getExercise(routineId, exerciseId);
    if (exercise != null) {
      await _onExerciseCompleted(routineId, exercise);
    }
    return const Result.success(null);
  }

  /// Awards XP for the exercise, and — if this exercise completion finished
  /// the whole routine for the day — awards a larger routine-completion
  /// bonus and fires a real notification.
  Future<void> _onExerciseCompleted(String routineId, WorkoutExercise exercise) async {
    final dateKey = _todayKey();
    await _gamification.awardOnce(
      eventKey: 'workout_exercise_${routineId}_${exercise.id}_$dateKey',
      amount: XpRewards.workoutExerciseCompleted,
    );

    final routine = await _local.getRoutine(routineId);
    if (routine == null) return;
    final allDone = routine.exercises.isNotEmpty && routine.exercises.every((e) => e.isCompleted);
    if (allDone) {
      await _gamification.awardOnce(
        eventKey: 'workout_routine_${routineId}_$dateKey',
        amount: XpRewards.workoutRoutineCompleted,
      );
      final title = 'Workout complete! 💪';
      final body = '${routine.name} is done — great work. +${XpRewards.workoutRoutineCompleted} XP';
      await PushNotificationService.instance.showNow(
        id: NotificationIds.workoutCompleted,
        title: title,
        body: body,
      );
      await _notifications.record(
        id: 'workout_routine_${routineId}_$dateKey',
        category: NotificationCategory.achievement,
        title: title,
        body: body,
      );
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<Result<WorkoutExercise>> createCustomExercise({
    required String routineId,
    required String name,
    required int targetSets,
    required String repRangeLabel,
    required List<MuscleGroup> primaryMuscles,
    List<String> instructions = const [],
  }) async {
    final exercise = await _local.createCustomExercise(
      routineId: routineId,
      name: name,
      targetSets: targetSets,
      repRangeLabel: repRangeLabel,
      primaryMuscles: primaryMuscles,
      instructions: instructions,
    );
    return Result.success(exercise);
  }

  @override
  Future<Result<void>> deleteCustomExercise({
    required String routineId,
    required String exerciseId,
  }) async {
    await _local.deleteCustomExercise(routineId: routineId, exerciseId: exerciseId);
    return const Result.success(null);
  }
}
