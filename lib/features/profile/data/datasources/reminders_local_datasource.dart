import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/reminder_item.dart';

/// Reads/writes each reminder's enabled flag and time to on-device
/// SharedPreferences, keyed by reminder id — same per-field storage
/// pattern as [SettingsLocalDataSource] so toggling one reminder never
/// re-serializes the whole list.
class RemindersLocalDataSource {
  String _enabledKey(String id) => 'reminder_${id}_enabled';
  String _hourKey(String id) => 'reminder_${id}_hour';
  String _minuteKey(String id) => 'reminder_${id}_minute';

  Future<List<ReminderItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    return DefaultReminders.items.map((defaultItem) {
      final enabled = prefs.getBool(_enabledKey(defaultItem.id)) ?? defaultItem.isEnabled;
      final hour = prefs.getInt(_hourKey(defaultItem.id)) ?? defaultItem.time.hour;
      final minute = prefs.getInt(_minuteKey(defaultItem.id)) ?? defaultItem.time.minute;
      return defaultItem.copyWith(
        isEnabled: enabled,
        time: TimeOfDay(hour: hour, minute: minute),
      );
    }).toList();
  }

  Future<void> saveEnabled(String id, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey(id), enabled);
  }

  Future<void> saveTime(String id, TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_hourKey(id), time.hour);
    await prefs.setInt(_minuteKey(id), time.minute);
  }
}
