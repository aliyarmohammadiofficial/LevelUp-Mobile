import 'package:flutter/material.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../../notifications/data/datasources/notifications_local_datasource.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../../domain/entities/reminder_item.dart';
import '../../domain/repositories/reminders_repository.dart';
import '../datasources/reminders_local_datasource.dart';

/// Bridges the persisted [ReminderItem] list to real OS-level scheduled
/// notifications: on load, every enabled reminder is (re-)scheduled so a
/// fresh app install / reinstall picks up the saved schedule; on toggle or
/// time change, the previous schedule is cancelled and replaced.
class RemindersRepositoryImpl implements RemindersRepository {
  RemindersRepositoryImpl(
    this._localDataSource, [
    PushNotificationService? pushService,
    NotificationsLocalDataSource? notifications,
  ])  : _push = pushService ?? PushNotificationService.instance,
        _notifications = notifications ?? NotificationsLocalDataSource() {
    // Reminders fire at the OS level even when the app isn't running, so
    // there's no in-app callback at fire time — mirroring into the feed on
    // tap is the closest reliable substitute. See PushNotificationService's
    // class doc for the known gap (fired-but-never-tapped).
    _push.onTap = _handleTap;
  }

  final RemindersLocalDataSource _localDataSource;
  final PushNotificationService _push;
  final NotificationsLocalDataSource _notifications;

  static const _notificationIds = {
    'workout': NotificationIds.workoutReminder,
    'meal': NotificationIds.mealReminder,
    'water': NotificationIds.waterReminder,
    'bedtime': NotificationIds.bedtimeReminder,
    'weekly_report': NotificationIds.weeklyReportReminder,
  };

  int? _idFor(String reminderId) => _notificationIds[reminderId];

  void _handleTap(int? notificationId) {
    if (notificationId == null) return;
    String? reminderId;
    for (final entry in _notificationIds.entries) {
      if (entry.value == notificationId) {
        reminderId = entry.key;
        break;
      }
    }
    if (reminderId == null) return;
    final resolvedId = reminderId;
    _localDataSource.load().then((items) {
      final item = _findById(items, resolvedId);
      if (item == null) return;
      _notifications.record(
        id: '${resolvedId}_reminder_${DateTime.now().toIso8601String()}',
        category: NotificationCategory.reminder,
        title: item.label,
        body: _bodyFor(item),
      );
    });
  }

  @override
  Future<List<ReminderItem>> loadReminders() async {
    final items = await _localDataSource.load();
    // Re-sync the OS schedule with persisted state every time the list is
    // loaded (app start, returning to the Reminders screen), so a reminder
    // enabled before an app reinstall/reboot is guaranteed to be scheduled.
    for (final item in items) {
      if (item.isEnabled) {
        await _schedule(item);
      } else {
        final id = _idFor(item.id);
        if (id != null) await _push.cancel(id);
      }
    }
    return items;
  }

  @override
  Future<void> setEnabled(String id, bool enabled) async {
    await _localDataSource.saveEnabled(id, enabled);
    final notifId = _idFor(id);
    if (notifId == null) return;
    if (enabled) {
      final items = await _localDataSource.load();
      final item = _findById(items, id);
      if (item != null) await _schedule(item);
    } else {
      await _push.cancel(notifId);
    }
  }

  @override
  Future<void> setTime(String id, TimeOfDay time) async {
    await _localDataSource.saveTime(id, time);
    final items = await _localDataSource.load();
    final item = _findById(items, id);
    if (item != null && item.isEnabled) {
      // Re-schedule at the new time — flutter_local_notifications replaces
      // any existing notification with the same id, so no explicit cancel
      // is needed here.
      await _schedule(item);
    }
  }

  ReminderItem? _findById(List<ReminderItem> items, String id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  Future<void> _schedule(ReminderItem item) async {
    final id = _idFor(item.id);
    if (id == null) return;
    switch (item.frequency) {
      case ReminderFrequency.daily:
        await _push.scheduleDaily(
          id: id,
          title: item.label,
          body: _bodyFor(item),
          hour: item.time.hour,
          minute: item.time.minute,
        );
        break;
      case ReminderFrequency.weekly:
        await _push.scheduleWeekly(
          id: id,
          title: item.label,
          body: _bodyFor(item),
          weekday: item.weekday ?? 1,
          hour: item.time.hour,
          minute: item.time.minute,
        );
        break;
      case ReminderFrequency.everyNHours:
        await _push.scheduleEveryNHours(
          id: id,
          title: item.label,
          body: _bodyFor(item),
          hours: item.intervalHours ?? 2,
          firstHour: item.time.hour,
          firstMinute: item.time.minute,
        );
        break;
    }
  }

  String _bodyFor(ReminderItem item) {
    switch (item.id) {
      case 'workout':
        return "Today's workout is ready — let's keep the streak going.";
      case 'meal':
        return 'Time to log your meal.';
      case 'water':
        return "Stay hydrated — log a cup of water.";
      case 'bedtime':
        return 'Wind down — bedtime is coming up.';
      case 'weekly_report':
        return 'Your weekly progress report is ready to view.';
      default:
        return item.subtitle;
    }
  }
}
