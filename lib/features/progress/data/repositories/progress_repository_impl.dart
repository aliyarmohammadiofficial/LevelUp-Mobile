import '../../../../core/utils/result.dart';
import '../../../workout/data/datasources/workout_local_datasource.dart';
import '../../domain/entities/progress_summary.dart';
import '../../domain/repositories/progress_repository.dart';
import '../datasources/progress_local_datasource.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl(this._local, this._workoutLocal);

  final ProgressLocalDataSource _local;
  final WorkoutLocalDataSource _workoutLocal;

  @override
  Stream<ProgressSummary> watchSummary() async* {
    final recentDays = await _workoutLocal.getRecentWorkoutDays();
    final weeklyWorkouts = recentDays
        .map((d) => WorkoutLogEntry(
              date: d.date,
              label: d.label,
              durationMinutes: 45,
              completed: true,
            ))
        .toList();
    yield await _local.getSummary(weeklyWorkouts: weeklyWorkouts);
  }

  @override
  Future<Result<void>> logWeight(double weightKg) async {
    await _local.logWeight(weightKg);
    return const Result.success(null);
  }

  @override
  Future<Result<void>> logMeasurements(Map<String, double> valuesCm) async {
    await _local.logMeasurements(valuesCm);
    return const Result.success(null);
  }

  @override
  Future<Map<String, double>> getLatestMeasurements() {
    return _local.getLatestMeasurements();
  }
}
