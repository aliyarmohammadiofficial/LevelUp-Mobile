import 'package:flutter/material.dart';
import '../entities/reminder_item.dart';

abstract class RemindersRepository {
  Future<List<ReminderItem>> loadReminders();
  Future<void> setEnabled(String id, bool enabled);
  Future<void> setTime(String id, TimeOfDay time);
}
