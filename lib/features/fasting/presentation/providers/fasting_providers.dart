import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/fasting_local_datasource.dart';
import '../../data/repositories/fasting_repository_impl.dart';
import '../../domain/entities/fasting_entities.dart';
import '../../domain/repositories/fasting_repository.dart';

final fastingLocalDataSourceProvider = Provider((ref) => FastingLocalDataSource());

final fastingRepositoryProvider = Provider<FastingRepository>((ref) {
  return FastingRepositoryImpl(ref.watch(fastingLocalDataSourceProvider));
});

final fastingPlansProvider = Provider<List<FastingPlan>>((ref) {
  return ref.watch(fastingRepositoryProvider).plans;
});

final fastingSessionProvider = StreamProvider<FastingSession?>((ref) {
  return ref.watch(fastingRepositoryProvider).watchSession();
});

final fastingStatsProvider = StreamProvider<FastingStats>((ref) {
  return ref.watch(fastingRepositoryProvider).watchStats();
});

final fastingHistoryProvider = FutureProvider<List<FastingHistoryEntry>>((ref) {
  return ref.watch(fastingRepositoryProvider).getHistory();
});
