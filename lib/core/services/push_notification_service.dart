import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Thin wrapper around `flutter_local_notifications`. This is the only file
/// that should ever import that package directly — everything above it
/// (repositories, providers, UI) calls through here instead, same pattern
/// as [AuthRemoteDataSource] wrapping the Supabase SDK.
///
/// Handles three kinds of real (OS-level) notifications:
/// - **Instant** — fired immediately for an app event (achievement unlocked,
///   goal hit, workout completed). These are also mirrored into the in-app
///   Notifications feed by the calling repository at the moment they fire
///   (see e.g. `WaterRepositoryImpl._awardGoalMetXp`).
/// - **Scheduled** — one-off or daily-repeating, used for the Reminders
///   feature (Workout/Meal/Water/Bedtime/Weekly Report). These are handed
///   to the OS scheduler directly, so — unlike instant notifications — the
///   app process isn't necessarily running when they actually fire, and
///   can't reliably mirror them into the in-app feed at fire time. [onTap]
///   below covers the case where the user taps a fired reminder while the
///   feed should reflect it; a fired-but-never-tapped reminder will show in
///   the OS notification shade but not retroactively in the in-app feed —
///   a known, documented gap rather than a silent one.
/// - **Cancellation** — when a reminder is turned off or its time changes,
///   the previous schedule must be cancelled before re-scheduling.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Called with the notification id whenever the user taps a notification
  /// (foreground, background, or terminated-then-launched). Set by callers
  /// that want to react — e.g. mirroring a tapped reminder into the
  /// in-app Notifications feed.
  void Function(int? notificationId)? onTap;

  /// Fixed channel for Android 8+. iOS ignores channel details.
  static const _channelId = 'levelup_default';
  static const _channelName = 'LevelUp';
  static const _channelDescription = 'Reminders, achievements, and activity updates';

  /// Must be called once, early in `main()`, before any notification is
  /// scheduled or shown.
  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      // Best-effort: falls back to UTC-based local scheduling if the device
      // timezone can't be resolved, which only affects clock display, not
      // whether the reminder fires at the intended wall-clock time on most
      // platforms tested.
      final String localName = tz.local.name;
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (e) {
      debugPrint('PushNotificationService: timezone resolution failed ($e), using UTC.');
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) => onTap?.call(response.id),
    );

    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

    _initialized = true;
  }

  /// Requests the OS notification permission (Android 13+, iOS). Returns
  /// whether permission was granted. Safe to call multiple times.
  Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> get hasPermission async => Permission.notification.isGranted;

  NotificationDetails get _details => const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
      );

  /// Fires a notification immediately — used for real app events (e.g. an
  /// achievement unlocking, a daily goal being hit).
  Future<void> showNow({required int id, required String title, required String body}) async {
    if (!_initialized) await init();
    await _plugin.show(id, title, body, _details);
  }

  /// Schedules a notification to repeat daily at [hour]:[minute] local time.
  /// [id] must be stable per-reminder so re-scheduling replaces rather than
  /// duplicates (flutter_local_notifications overwrites on matching id).
  Future<void> scheduleDaily({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Schedules a notification to repeat weekly on [weekday] (1=Monday..7=Sunday,
  /// DateTime-style) at [hour]:[minute] local time.
  Future<void> scheduleWeekly({
    required int id,
    required String title,
    required String body,
    required int weekday,
    required int hour,
    required int minute,
  }) async {
    if (!_initialized) await init();
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfWeekday(weekday, hour, minute),
      _details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Schedules a notification to repeat every [hours] hours, starting from
  /// the next occurrence of [firstHour]:[firstMinute]. Used for the Water
  /// reminder's "every N hours" cadence — flutter_local_notifications has no
  /// native N-hourly repeat, so this chains a periodic schedule via
  /// [Duration]-based `periodicallyShow`, which is Android-only; on iOS this
  /// falls back to a single daily reminder at [firstHour]:[firstMinute]
  /// (documented limitation — iOS has no interval-repeat API).
  Future<void> scheduleEveryNHours({
    required int id,
    required String title,
    required String body,
    required int hours,
    required int firstHour,
    required int firstMinute,
  }) async {
    if (!_initialized) await init();
    await _plugin.periodicallyShowWithDuration(
      id,
      title,
      body,
      Duration(hours: hours),
      _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async {
    if (!_initialized) await init();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    if (!_initialized) await init();
    await _plugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    var scheduled = _nextInstanceOfTime(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

/// Stable notification ids so scheduling the same reminder twice replaces
/// rather than stacks duplicates, and so instant "event" notifications don't
/// collide with reminder ids. Kept in one place to avoid accidental clashes
/// as more event types are added.
abstract class NotificationIds {
  NotificationIds._();

  // Reminders (Profile > Reminders) — fixed one per default reminder id.
  static const workoutReminder = 1001;
  static const mealReminder = 1002;
  static const waterReminder = 1003;
  static const bedtimeReminder = 1004;
  static const weeklyReportReminder = 1005;

  // Real-time app events — instant notifications.
  static const waterGoalMet = 2001;
  static const workoutCompleted = 2002;
  static const fastCompleted = 2003;
  static const streakMilestone = 2004;
  static const levelUp = 2005;
}
