import 'dart:async';
import 'package:hive/hive.dart';
import '../../domain/entities/app_notification.dart';

/// Hive-backed persistence for the in-app Notifications feed. Every real
/// event that also fires an OS push (via `PushNotificationService`) is
/// recorded here too, so the Notifications screen shows the same real
/// history the device notification shade shows — no more fixed mock list.
///
/// Box layout:
/// - `notifications_box` — key `<id>`, holds one entry per notification
///   (category, title, body, timestamp, read flag).
///
/// [changes] is a process-wide broadcast stream (not tied to any one
/// instance) so a write from any repository — Water, Workout, Fasting,
/// Reminders — is picked up immediately by whichever [NotificationsRepositoryImpl]
/// instance the Notifications screen is watching, without those repositories
/// needing a reference to each other.
class NotificationsLocalDataSource {
  static const _boxName = 'notifications_box';

  static final _changesController = StreamController<void>.broadcast();

  /// Emits once after every write (record/markAsRead/markAllAsRead/dismiss).
  static Stream<void> get changes => _changesController.stream;

  Future<Box> _box() => Hive.openBox(_boxName);

  Future<List<AppNotification>> getAll() async {
    final box = await _box();
    final entries = box.keys.map((key) {
      final raw = box.get(key);
      final map = Map<String, dynamic>.from(raw as Map);
      return AppNotification(
        id: key as String,
        category: NotificationCategory.values[map['category'] as int],
        title: map['title'] as String,
        body: map['body'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        isRead: map['isRead'] as bool? ?? false,
      );
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  /// Records a new notification into the feed. [id] should be stable per
  /// real-world occurrence (e.g. `'water_goal_2026-07-16'`) so the same
  /// event logged twice (a redundant call, a stream re-emitting) overwrites
  /// rather than duplicates — same idempotency approach as
  /// [GamificationLocalDataSource.awardOnce].
  Future<void> record({
    required String id,
    required NotificationCategory category,
    required String title,
    required String body,
    DateTime? timestamp,
  }) async {
    final box = await _box();
    await box.put(id, {
      'category': category.index,
      'title': title,
      'body': body,
      'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
      'isRead': false,
    });
    _changesController.add(null);
  }

  Future<void> markAsRead(String id) async {
    final box = await _box();
    final raw = box.get(id);
    if (raw == null) return;
    final map = Map<String, dynamic>.from(raw as Map);
    map['isRead'] = true;
    await box.put(id, map);
    _changesController.add(null);
  }

  Future<void> markAllAsRead() async {
    final box = await _box();
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw == null) continue;
      final map = Map<String, dynamic>.from(raw as Map);
      map['isRead'] = true;
      await box.put(key, map);
    }
    _changesController.add(null);
  }

  Future<void> dismiss(String id) async {
    final box = await _box();
    await box.delete(id);
    _changesController.add(null);
  }
}
