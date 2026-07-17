import '../../../../core/utils/result.dart';
import '../entities/fasting_entities.dart';

/// Contract for the Fasting feature. [FastingRepositoryImpl] currently
/// backs this with in-memory mock data (same pattern as Dashboard) — swap
/// the datasource for a Hive/Supabase-backed one later without touching
/// callers.
abstract class FastingRepository {
  /// All plans the user can choose from (16:8, 18:6, 20:4, OMAD, custom).
  List<FastingPlan> get plans;

  /// Emits the current session once, then ticks every second while a fast
  /// or eating window is active so the UI countdown stays live. Emits
  /// null when the user has never started a fast (or the last one was
  /// dismissed), so the UI can show a "start your first fast" state.
  Stream<FastingSession?> watchSession();

  Stream<FastingStats> watchStats();

  Future<Result<FastingSession>> startFast(FastingPlan plan);

  Future<Result<void>> endFastEarly();

  Future<List<FastingHistoryEntry>> getHistory({int limit = 14});
}
