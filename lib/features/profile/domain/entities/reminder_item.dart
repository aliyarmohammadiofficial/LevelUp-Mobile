import 'package:flutter/material.dart';

enum ReminderFrequency { daily, everyNHours, weekly }

/// One reminder row on the Reminders screen — e.g. "Workout Reminder,
/// every day at 6:00 AM". [id] is the persistence key; [frequency] and
/// [intervalHours]/[weekday] describe when it fires, [time] is the
/// time-of-day (or first-fire time for interval reminders).
class ReminderItem {
  const ReminderItem({
    required this.id,
    required this.label,
    required this.icon,
    required this.frequency,
    required this.time,
    required this.isEnabled,
    this.intervalHours,
    this.weekday,
  });

  final String id;
  final String label;
  final IconData icon;
  final ReminderFrequency frequency;
  final TimeOfDay time;
  final bool isEnabled;
  final int? intervalHours;
  final int? weekday; // DateTime.weekday values: 1 = Monday .. 7 = Sunday

  String get subtitle {
    switch (frequency) {
      case ReminderFrequency.daily:
        return 'Every day at ${_formatTime(time)}';
      case ReminderFrequency.everyNHours:
        return 'Every ${intervalHours ?? 1} hours';
      case ReminderFrequency.weekly:
        return 'Every ${_weekdayName(weekday ?? 1)} at ${_formatTime(time)}';
    }
  }

  static String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  static String _weekdayName(int weekday) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[(weekday - 1).clamp(0, 6)];
  }

  ReminderItem copyWith({bool? isEnabled, TimeOfDay? time}) {
    return ReminderItem(
      id: id,
      label: label,
      icon: icon,
      frequency: frequency,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      intervalHours: intervalHours,
      weekday: weekday,
    );
  }
}

/// Default reminder set shown on first launch, matching the reference
/// Reminders screen: Workout, Meal, Water, Bedtime, Weekly Report.
abstract class DefaultReminders {
  DefaultReminders._();

  static const items = [
    ReminderItem(
      id: 'workout',
      label: 'Workout Reminder',
      icon: Icons.fitness_center_rounded,
      frequency: ReminderFrequency.daily,
      time: TimeOfDay(hour: 6, minute: 0),
      isEnabled: true,
    ),
    ReminderItem(
      id: 'meal',
      label: 'Meal Reminder',
      icon: Icons.restaurant_rounded,
      frequency: ReminderFrequency.daily,
      time: TimeOfDay(hour: 12, minute: 30),
      isEnabled: true,
    ),
    ReminderItem(
      id: 'water',
      label: 'Water Reminder',
      icon: Icons.local_drink_rounded,
      frequency: ReminderFrequency.everyNHours,
      time: TimeOfDay(hour: 9, minute: 0),
      isEnabled: true,
      intervalHours: 2,
    ),
    ReminderItem(
      id: 'bedtime',
      label: 'Bedtime Reminder',
      icon: Icons.bedtime_rounded,
      frequency: ReminderFrequency.daily,
      time: TimeOfDay(hour: 23, minute: 0),
      isEnabled: true,
    ),
    ReminderItem(
      id: 'weekly_report',
      label: 'Weekly Report',
      icon: Icons.bar_chart_rounded,
      frequency: ReminderFrequency.weekly,
      time: TimeOfDay(hour: 9, minute: 0),
      isEnabled: true,
      weekday: 1, // Monday (DateTime.weekday: 1=Mon..7=Sun)
    ),
  ];
}
