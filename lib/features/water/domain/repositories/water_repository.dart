import '../../../../core/utils/result.dart';
import '../entities/water_entities.dart';

/// Contract for the Water Tracker feature. Backed by in-memory mock data
/// for now (same pattern as Dashboard/Fasting) — swap the datasource for
/// a Hive/Supabase-backed one later without touching callers.
abstract class WaterRepository {
  Stream<WaterDay> watchToday();

  Stream<WaterStats> watchStats();

  Future<List<WaterHistoryEntry>> getWeekHistory();

  /// Adds one cup (or [count] cups) to today's log. Returns the updated day.
  Future<Result<WaterDay>> logCup({int count = 1});

  /// Removes the most recently logged cup, if any.
  Future<Result<WaterDay>> undoCup();
}
