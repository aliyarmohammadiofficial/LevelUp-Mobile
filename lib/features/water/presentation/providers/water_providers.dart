import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/water_local_datasource.dart';
import '../../data/repositories/water_repository_impl.dart';
import '../../domain/entities/water_entities.dart';
import '../../domain/repositories/water_repository.dart';

final waterLocalDataSourceProvider = Provider((ref) => WaterLocalDataSource());

final waterRepositoryProvider = Provider<WaterRepository>((ref) {
  return WaterRepositoryImpl(ref.watch(waterLocalDataSourceProvider));
});

final waterTodayProvider = StreamProvider<WaterDay>((ref) {
  return ref.watch(waterRepositoryProvider).watchToday();
});

final waterStatsProvider = StreamProvider<WaterStats>((ref) {
  return ref.watch(waterRepositoryProvider).watchStats();
});

final waterWeekHistoryProvider = FutureProvider<List<WaterHistoryEntry>>((ref) {
  // Re-fetches whenever today's log changes, so the week strip stays current.
  ref.watch(waterTodayProvider);
  return ref.watch(waterRepositoryProvider).getWeekHistory();
});
