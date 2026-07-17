import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../data/datasources/progress_local_datasource.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/entities/progress_summary.dart';
import '../../domain/repositories/progress_repository.dart';

final progressLocalDataSourceProvider = Provider((ref) => ProgressLocalDataSource());

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepositoryImpl(
    ref.watch(progressLocalDataSourceProvider),
    ref.watch(workoutLocalDataSourceProvider),
  );
});

final progressSummaryProvider = StreamProvider<ProgressSummary>((ref) {
  return ref.watch(progressRepositoryProvider).watchSummary();
});

/// Which of the four tabs (Overview, Weight, Body, Workouts) is active.
final progressTabProvider = StateProvider<int>((ref) => 0);

/// Latest logged value per body-measurement site, used to prefill the
/// capture form so re-measuring is an edit rather than starting blank.
final latestMeasurementsProvider = FutureProvider<Map<String, double>>((ref) {
  return ref.watch(progressRepositoryProvider).getLatestMeasurements();
});
