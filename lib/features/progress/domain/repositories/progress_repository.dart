import '../../../../core/utils/result.dart';
import '../entities/progress_summary.dart';

/// Contract for the Progress feature. [ProgressRepositoryImpl] reads and
/// writes weight logs, body measurements, and workout history against
/// Hive-backed local datasources — no mock data.
abstract class ProgressRepository {
  Stream<ProgressSummary> watchSummary();
  Future<Result<void>> logWeight(double weightKg);

  /// Persists a body-measurement reading. [valuesCm] maps
  /// [BodyMeasurementFields] labels to a value in centimeters; a partial
  /// map (not every site measured this time) is fine — omitted sites
  /// simply keep their last known value untouched.
  Future<Result<void>> logMeasurements(Map<String, double> valuesCm);

  /// Most recently logged value per site, for prefilling the capture
  /// form. Empty if measurements have never been logged.
  Future<Map<String, double>> getLatestMeasurements();
}
