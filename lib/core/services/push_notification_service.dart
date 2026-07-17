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


    return result.isGranted;

  }




  Future<bool> get hasPermission async {

    return Permission.notification.isGranted;

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


      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,


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


      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle,


      matchDateTimeComponents:
          DateTimeComponents.dayOfWeekAndTime,


    );

  }







  Future<void> scheduleEveryNHours({

    required int id,

    required String title,

    required String body,

    required int hours,

    required int firstHour,

    required int firstMinute,

  }) async {



    if (!_initialized) {

      await init();

    }



    await _plugin.periodicallyShow(

      id,

      title,

      body,


      RepeatInterval.hourly,


      _details,


      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,


    );

  }







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