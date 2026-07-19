import 'package:flutter_test/flutter_test.dart';
import 'package:levelup/core/services/push_notification_service.dart';

void main() {
  group('PushNotificationService.scheduleEveryNHours input validation', () {
    // This exercises the guard added alongside the fix for the bug where
    // `scheduleEveryNHours` silently ignored its `hours` argument and
    // always repeated hourly (via periodicallyShow(RepeatInterval.hourly)).
    // The plugin itself needs platform channels to run, so the full
    // scheduling path isn't unit-testable here — but the argument
    // validation that guards it is, and is worth locking in.
    test('rejects hours < 1', () {
      // `scheduleEveryNHours` is `async`, so the ArgumentError thrown
      // before its first `await` is delivered as a rejected Future, not
      // a synchronous exception — pass the Future itself to throwsA
      // rather than a closure.
      final result = PushNotificationService.instance.scheduleEveryNHours(
        id: 1,
        title: 'x',
        body: 'x',
        hours: 0,
        firstHour: 9,
        firstMinute: 0,
      );

      expect(result, throwsA(isA<ArgumentError>()));
    });
  });

  group('NotificationIds', () {
    test('every id is unique', () {
      final ids = [
        NotificationIds.workoutReminder,
        NotificationIds.mealReminder,
        NotificationIds.waterReminder,
        NotificationIds.bedtimeReminder,
        NotificationIds.weeklyReportReminder,
        NotificationIds.waterGoalMet,
        NotificationIds.workoutCompleted,
        NotificationIds.fastCompleted,
        NotificationIds.streakMilestone,
        NotificationIds.levelUp,
      ];

      expect(ids.toSet().length, ids.length);
    });
  });
}
