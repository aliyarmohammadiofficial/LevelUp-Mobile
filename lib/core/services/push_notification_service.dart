import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;


class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance =
      PushNotificationService._();


  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();


  bool _initialized = false;


  void Function(int?)? onTap;



  static const String _channelId = 'levelup_default';

  static const String _channelName = 'LevelUp';

  static const String _channelDescription =
      'Reminders and activity notifications';



  Future<void> init() async {

    if (_initialized) return;


    tz_data.initializeTimeZones();



    const androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );


    const iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );



    const settings =
        InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );



    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse:
          (response) {

        onTap?.call(response.id);

      },
    );



    const channel =
        AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );



    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);



    _initialized = true;

  }





  Future<bool> requestPermission() async {

    final result =
        await Permission.notification.request();

    // Android 12+ (API 31+) gates exact alarms — the mode `scheduleDaily`
    // and `scheduleWeekly` use below — behind a separate opt-in. On
    // Android 13/14 this normally surfaces as a system settings toggle
    // rather than an in-app dialog; requesting it here is what makes that
    // toggle available/pre-granted where the OS allows it. Skipped on iOS
    // and web, where the permission doesn't exist.
    if (!kIsWeb && Platform.isAndroid) {
      await Permission.scheduleExactAlarm.request();
    }

    return result.isGranted;

  }




  Future<bool> get hasPermission async {

    return Permission.notification.isGranted;

  }

  /// Whether exact-time alarms are available on this device. `true` on
  /// iOS/web, since the restriction is Android-only. When `false` on
  /// Android, [scheduleDaily] and [scheduleWeekly] fall back to inexact
  /// scheduling instead of throwing.
  Future<bool> get hasExactAlarmPermission async {

    if (kIsWeb || !Platform.isAndroid) return true;

    return Permission.scheduleExactAlarm.isGranted;

  }





  /// Resolves to exact scheduling when the OS has actually granted it,
  /// and falls back to inexact (which fires within a short OS-controlled
  /// window instead of precisely on time) otherwise — using
  /// `exactAllowWhileIdle` without the permission throws on Android 12+.
  Future<AndroidScheduleMode> get _preferredScheduleMode async {

    final exact = await hasExactAlarmPermission;

    return exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

  }

  NotificationDetails get _details {


    return const NotificationDetails(

      android:
          AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription:
            _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),


      iOS:
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),

    );

  }






  Future<void> showNow({

    required int id,

    required String title,

    required String body,

  }) async {


    if (!_initialized) {

      await init();

    }



    await _plugin.show(

      id,

      title,

      body,

      _details,

    );

  }







  Future<void> scheduleDaily({

    required int id,

    required String title,

    required String body,

    required int hour,

    required int minute,

  }) async {


    if (!_initialized) {

      await init();

    }




    await _plugin.zonedSchedule(

      id,

      title,

      body,

      _nextTime(
        hour,
        minute,
      ),

      _details,


      androidScheduleMode: await _preferredScheduleMode,


      matchDateTimeComponents:
          DateTimeComponents.time,


    );

  }







  Future<void> scheduleWeekly({

    required int id,

    required String title,

    required String body,

    required int weekday,

    required int hour,

    required int minute,

  }) async {



    if (!_initialized) {

      await init();

    }




    await _plugin.zonedSchedule(

      id,

      title,

      body,

      _nextWeekday(
        weekday,
        hour,
        minute,
      ),

      _details,


      androidScheduleMode: await _preferredScheduleMode,


      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime,


    );

  }







  /// Schedules a reminder every [hours] hours, starting at the next
  /// occurrence of [firstHour]:[firstMinute].
  ///
  /// `flutter_local_notifications`'s `periodicallyShow` only supports the
  /// fixed `RepeatInterval` values (hourly/daily/weekly/etc.) — it cannot
  /// repeat every N hours for an arbitrary N. The previous implementation
  /// called `periodicallyShow(..., RepeatInterval.hourly, ...)` and simply
  /// discarded the `hours` argument, so a "remind me every 3 hours" request
  /// silently fired every 1 hour instead.
  ///
  /// Since there is no native arbitrary-interval repeat, we instead book a
  /// rolling window of one-off `zonedSchedule` calls spaced [hours] apart
  /// ([_rollingWindowCount] of them), each with its own derived id so they
  /// can all be cancelled together via [cancelEveryNHours]. Call this again
  /// (e.g. on app start) to keep the window topped up — a purely
  /// client-scheduled approach can't run forever without the app ever
  /// being opened, which matches how this plugin is meant to be used on
  /// Android 13+/14+/15, where indefinite background alarms are
  /// restricted anyway.
  static const int _rollingWindowCount = 12;

  Future<void> scheduleEveryNHours({

    required int id,

    required String title,

    required String body,

    required int hours,

    required int firstHour,

    required int firstMinute,

  }) async {

    if (hours < 1) {
      throw ArgumentError.value(hours, 'hours', 'must be >= 1');
    }

    if (!_initialized) {

      await init();

    }

    // Clear any previously booked occurrences for this id so repeated
    // calls (e.g. re-toggling the setting) don't stack duplicate alarms.
    await cancelEveryNHours(id);

    var next = _nextTime(firstHour, firstMinute);

    for (var i = 0; i < _rollingWindowCount; i++) {
      await _plugin.zonedSchedule(
        _everyNHoursSlotId(id, i),
        title,
        body,
        next,
        _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      next = next.add(Duration(hours: hours));
    }

  }

  /// Cancels every occurrence previously booked by [scheduleEveryNHours]
  /// for this [id].
  Future<void> cancelEveryNHours(int id) async {

    if (!_initialized) {

      await init();

    }

    for (var i = 0; i < _rollingWindowCount; i++) {
      await _plugin.cancel(_everyNHoursSlotId(id, i));
    }

  }

  // Derives a stable, collision-free notification id for the i-th booked
  // occurrence of an every-N-hours reminder `id`. Multiplying by the
  // window size keeps each reminder's slot ids in their own numeric band.
  int _everyNHoursSlotId(int id, int i) => id * 1000 + i;







  Future<void> cancel(int id) async {


    if (!_initialized) {

      await init();

    }


    await _plugin.cancel(id);

  }







  Future<void> cancelAll() async {


    if (!_initialized) {

      await init();

    }


    await _plugin.cancelAll();

  }








  tz.TZDateTime _nextTime(

    int hour,

    int minute,

  ) {



    final now =
        tz.TZDateTime.now(
          tz.local,
        );



    var date =
        tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );



    if(date.isBefore(now)) {

      date =
          date.add(
            const Duration(
              days:1,
            ),
          );

    }



    return date;

  }







  tz.TZDateTime _nextWeekday(

    int weekday,

    int hour,

    int minute,

  ) {



    var date =
        _nextTime(
          hour,
          minute,
        );



    while(date.weekday != weekday) {


      date =
          date.add(
            const Duration(
              days:1,
            ),
          );

    }



    return date;

  }

}







abstract class NotificationIds {


  static const workoutReminder = 1001;

  static const mealReminder = 1002;

  static const waterReminder = 1003;

  static const bedtimeReminder = 1004;

  static const weeklyReportReminder = 1005;



  static const waterGoalMet = 2001;

  static const workoutCompleted = 2002;

  static const fastCompleted = 2003;

  static const streakMilestone = 2004;

  static const levelUp = 2005;


}