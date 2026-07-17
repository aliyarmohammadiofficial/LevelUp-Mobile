import '../entities/app_notification.dart';

/// Contract for the Notifications feature. Backed by real, persisted
/// notifications recorded whenever a reminder fires or an app event (water
/// goal met, workout completed, fast completed, level up) triggers a real
/// OS push via `PushNotificationService` — see [NotificationsLocalDataSource].
abstract class NotificationsRepository {
  Stream<List<AppNotification>> watchAll();

  Future<void> markAsRead(String id);

  Future<void> markAllAsRead();

  Future<void> dismiss(String id);
}
