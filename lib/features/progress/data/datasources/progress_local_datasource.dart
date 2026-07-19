import 'package:hive_ce/hive_ce.dart';
import '../../../onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../domain/entities/progress_summary.dart';

/// Hive-backed persistence for Progress.
///
/// Weight entries and body measurements are both real, user-logged data
/// (`logWeight`, `logMeasurements`) — every entry is written keyed by the
/// calendar day it was recorded, so a re-log on the same day overwrites
/// that day's reading rather than duplicating it, and the full history
/// survives an app restart. BMI, starting weight, and change-since-last
/// figures fall back to the user's onboarding answers only until a real
/// log entry exists.
class ProgressLocalDataSource {
  static const _weightBoxName = 'progress_weight_box';
  static const _measurementsBoxName = 'progress_measurements_box';

  final OnboardingLocalDataSource _onboarding = OnboardingLocalDataSource();

  Future<Box> _weightBox() => Hive.openBox(_weightBoxName);
  Future<Box> _measurementsBox() => Hive.openBox(_measurementsBoxName);

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  // -- Weight ---------------------------------------------------------

  Future<void> logWeight(double weightKg) async {
    final box = await _weightBox();
    await box.put(_dateKey(DateTime.now()), weightKg);
  }

  Future<List<WeightPoint>> _weightHistory() async {
    final box = await _weightBox();
    final entries = box.toMap().entries.map((e) {
      final date = DateTime.parse(e.key as String);
      return WeightPoint(date: date, weightKg: (e.value as num).toDouble());
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return entries;
  }

  // -- Body measurements -----------------------------------------------
  //
  // Each entry is stored as `{dateKey: {label: valueCm, ...}}`. A log call
  // merges into the current day's map (Hive plain-map pattern, no
  // TypeAdapters) rather than requiring every site to be re-measured
  // every time.

  Future<Map<String, Map<String, double>>> _measurementEntries() async {
    final box = await _measurementsBox();
    final result = <String, Map<String, double>>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        result[key as String] = raw.map((k, v) => MapEntry(k as String, (v as num).toDouble()));
      }
    }
    return result;
  }

  Future<void> logMeasurements(Map<String, double> valuesCm) async {
    if (valuesCm.isEmpty) return;
    final box = await _measurementsBox();
    final key = _dateKey(DateTime.now());
    final existing = box.get(key);
    final merged = <String, double>{
      if (existing is Map)
        ...existing.map((k, v) => MapEntry(k as String, (v as num).toDouble())),
      ...valuesCm,
    };
    await box.put(key, merged);
  }

  Future<Map<String, double>> getLatestMeasurements() async {
    final entries = await _measurementEntries();
    if (entries.isEmpty) return {};
    final sortedKeys = entries.keys.toList()..sort();
    return entries[sortedKeys.last]!;
  }

  /// Builds the display list for every tracked site: the latest value
  /// (if ever logged) and its change vs. the previous reading of that
  /// same site. Sites with no history yet are omitted rather than shown
  /// as a fabricated zero.
  Future<(List<BodyMeasurement>, DateTime?)> _bodyMeasurements() async {
    final entries = await _measurementEntries();
    if (entries.isEmpty) return (const <BodyMeasurement>[], null);

    final sortedKeys = entries.keys.toList()..sort();
    final measurements = <BodyMeasurement>[];

    for (final field in BodyMeasurementFields.all) {
      double? latest;
      double? previous;
      for (final key in sortedKeys.reversed) {
        final value = entries[key]![field.label];
        if (value == null) continue;
        if (latest == null) {
          latest = value;
        } else {
          previous = value;
          break;
        }
      }
      if (latest == null) continue;
      measurements.add(BodyMeasurement(
        label: field.label,
        valueCm: latest,
        changeCm: previous == null
            ? 0
            : double.parse((latest - previous).toStringAsFixed(1)),
      ));
    }

    return (measurements, DateTime.parse(sortedKeys.last));
  }

  // -- Summary ----------------------------------------------------------

  Future<ProgressSummary> getSummary({List<WorkoutLogEntry> weeklyWorkouts = const []}) async {
    final onboarding = await _onboarding.load();
    var history = await _weightHistory();

    // Seed the log with the onboarding weight so the chart/current value
    // has a real starting point instead of a hardcoded mock number.
    if (history.isEmpty && onboarding?.currentWeightKg != null) {
      history = [WeightPoint(date: DateTime.now(), weightKg: onboarding!.currentWeightKg!)];
    }

    final currentWeight = history.isNotEmpty
        ? history.last.weightKg
        : (onboarding?.currentWeightKg ?? 0);

    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    final monthAgoPoint = history.where((p) => !p.date.isAfter(monthAgo)).toList();
    final baselineWeight =
        monthAgoPoint.isNotEmpty ? monthAgoPoint.last.weightKg : history.first.weightKg;
    final weightChange = history.length > 1 ? currentWeight - baselineWeight : 0.0;

    final heightM = (onboarding?.heightCm ?? 170) / 100;
    final bmi = heightM > 0 ? currentWeight / (heightM * heightM) : 0.0;

    final (bodyMeasurements, bodyMeasurementsUpdatedAt) = await _bodyMeasurements();

    return ProgressSummary(
      currentWeightKg: currentWeight,
      weightChangeKg: double.parse(weightChange.toStringAsFixed(1)),
      weightChangePeriodLabel: 'from last month',
      weightHistory: history,
      goalWeightKg: onboarding?.targetWeightKg ?? currentWeight,
      bmi: double.parse(bmi.toStringAsFixed(1)),
      bodyMeasurements: bodyMeasurements,
      bodyMeasurementsUpdatedAt: bodyMeasurementsUpdatedAt,
      weeklyWorkouts: weeklyWorkouts,
    );
  }
}
