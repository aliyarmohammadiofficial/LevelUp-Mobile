import '../../../../core/utils/result.dart';
import '../entities/dashboard_summary.dart';

/// Contract for assembling the Dashboard's aggregate view. The real
/// implementation composes data from the Fasting, Workout, and Nutrition
/// features once those exist; for now [DashboardRepositoryImpl] returns
/// locally-held mock data so the screen is fully navigable and visually
/// complete ahead of those features landing.
abstract class DashboardRepository {
  Stream<DashboardSummary> watchSummary();
  Future<Result<void>> endFastEarly();
}
