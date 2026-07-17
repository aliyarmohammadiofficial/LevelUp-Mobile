import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../fasting/presentation/providers/fasting_providers.dart';
import '../../../nutrition/presentation/providers/nutrition_providers.dart';
import '../../../workout/presentation/providers/workout_providers.dart';
import '../../data/datasources/dashboard_local_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';

final dashboardLocalDataSourceProvider = Provider((ref) {
  return DashboardLocalDataSource(
    ref.watch(fastingLocalDataSourceProvider),
    ref.watch(workoutLocalDataSourceProvider),
    ref.watch(nutritionLocalDataSourceProvider),
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  final displayName = user?.fullName?.trim().isNotEmpty == true ? user!.fullName! : 'there';
  return DashboardRepositoryImpl(
    ref.watch(dashboardLocalDataSourceProvider),
    ref.watch(fastingRepositoryProvider),
    userDisplayName: displayName,
  );
});

final dashboardSummaryProvider = StreamProvider<DashboardSummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).watchSummary();
});
