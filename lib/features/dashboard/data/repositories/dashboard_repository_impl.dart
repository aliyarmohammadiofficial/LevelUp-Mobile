import 'dart:async';
import '../../../../core/utils/result.dart';
import '../../../fasting/domain/repositories/fasting_repository.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_local_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  DashboardRepositoryImpl(this._local, this._fastingRepository, {required String userDisplayName})
      : _userDisplayName = userDisplayName;

  final DashboardLocalDataSource _local;
  final FastingRepository _fastingRepository;
  final String _userDisplayName;

  @override
  Stream<DashboardSummary> watchSummary() async* {
    var summary = await _local.getSummary(userDisplayName: _userDisplayName);
    yield summary;

    // Ticks the fasting countdown once a second so the home screen timer
    // is live without a separate timer widget owning the state. Re-reads
    // workout/nutrition from disk once a minute (cheap, and picks up
    // changes made from those tabs) rather than on every tick.
    var secondsSinceRefresh = 0;
    yield* Stream.periodic(const Duration(seconds: 1), (_) => null).asyncMap((_) async {
      secondsSinceRefresh++;
      if (secondsSinceRefresh >= 60) {
        secondsSinceRefresh = 0;
        summary = await _local.getSummary(userDisplayName: _userDisplayName);
        return summary;
      }

      final remaining = summary.fasting.remaining - const Duration(seconds: 1);
      summary = DashboardSummary(
        userDisplayName: summary.userDisplayName,
        fasting: FastingStatus(
          isActive: summary.fasting.isActive && remaining > Duration.zero,
          planLabel: summary.fasting.planLabel,
          remaining: remaining > Duration.zero ? remaining : Duration.zero,
          endsAt: summary.fasting.endsAt,
        ),
        workout: summary.workout,
        calories: summary.calories,
        todaysMeals: summary.todaysMeals,
        tip: summary.tip,
      );
      return summary;
    });
  }

  @override
  Future<Result<void>> endFastEarly() async {
    return _fastingRepository.endFastEarly();
  }
}
