import 'package:hive_ce/hive_ce.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../notifications/data/datasources/notifications_local_datasource.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../../domain/entities/gamification_stats.dart';

/// Hive-backed persistence for real XP/level, following the same plain-map
/// pattern as [WaterLocalDataSource] / [FastingLocalDataSource].
///
/// Box layout:
/// - `gamification_box` / key `_totalXp` — running XP total (int).
/// - `gamification_box` / key `awarded_<eventKey>` — a flag per awarded
///   event, so the same event (e.g. "water goal met on 2026-07-16") is
///   never double-counted if the code path that grants it runs again
///   (e.g. re-opening the Water screen, a stream re-emitting).
class GamificationLocalDataSource {
  GamificationLocalDataSource([NotificationsLocalDataSource? notifications])
      : _notifications = notifications ?? NotificationsLocalDataSource();

  static const _boxName = 'gamification_box';
  static const _totalXpKey = '_totalXp';

  final NotificationsLocalDataSource _notifications;

  Future<Box> _box() => Hive.openBox(_boxName);

  Future<GamificationStats> getStats() async {
    final box = await _box();
    final xp = box.get(_totalXpKey, defaultValue: 0) as int;
    return GamificationStats(totalXp: xp);
  }

  /// Awards [amount] XP for [eventKey] exactly once. [eventKey] should
  /// encode enough identity to be unique per real-world occurrence, e.g.
  /// `'water_goal_2026-07-16'` or `'workout_exercise_push-day_bench-press_2026-07-16'`.
  /// Returns the new total, or the unchanged total if this event was
  /// already awarded (no-op — safe to call redundantly). If this award
  /// crosses into a new level, fires a real level-up notification.
  Future<GamificationStats> awardOnce({required String eventKey, required int amount}) async {
    final box = await _box();
    final flagKey = 'awarded_$eventKey';
    if (box.get(flagKey) == true) {
      return getStats();
    }
    await box.put(flagKey, true);
    final current = box.get(_totalXpKey, defaultValue: 0) as int;
    final updated = current + amount;
    await box.put(_totalXpKey, updated);

    final before = GamificationStats(totalXp: current);
    final after = GamificationStats(totalXp: updated);
    if (after.level > before.level) {
      await _notifyLevelUp(after);
    }
    return after;
  }

  Future<void> _notifyLevelUp(GamificationStats stats) async {
    final title = 'Level up! 🎉';
    final body = "You've reached Level ${stats.level}. Keep it going!";
    await PushNotificationService.instance.showNow(
      id: NotificationIds.levelUp,
      title: title,
      body: body,
    );
    await _notifications.record(
      id: 'level_up_${stats.level}',
      category: NotificationCategory.achievement,
      title: title,
      body: body,
    );
  }
}
