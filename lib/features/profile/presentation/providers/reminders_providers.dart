import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/push_notification_service.dart';
import '../../data/datasources/reminders_local_datasource.dart';
import '../../data/repositories/reminders_repository_impl.dart';
import '../../domain/entities/reminder_item.dart';
import '../../domain/repositories/reminders_repository.dart';

final remindersLocalDataSourceProvider = Provider((ref) => RemindersLocalDataSource());

final remindersRepositoryProvider = Provider<RemindersRepository>((ref) {
  return RemindersRepositoryImpl(
    ref.watch(remindersLocalDataSourceProvider),
    PushNotificationService.instance,
  );
});

/// Loads persisted reminders once and exposes mutators that update both
/// storage and in-memory state together — same shape as
/// [SettingsController] so the Reminders screen behaves consistently
/// with Settings.
class RemindersController extends AsyncNotifier<List<ReminderItem>> {
  @override
  Future<List<ReminderItem>> build() {
    return ref.watch(remindersRepositoryProvider).loadReminders();
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final repo = ref.read(remindersRepositoryProvider);
    await repo.setEnabled(id, enabled);
    state = AsyncData([
      for (final item in state.requireValue)
        if (item.id == id) item.copyWith(isEnabled: enabled) else item,
    ]);
  }

  Future<void> setTime(String id, TimeOfDay time) async {
    final repo = ref.read(remindersRepositoryProvider);
    await repo.setTime(id, time);
    state = AsyncData([
      for (final item in state.requireValue)
        if (item.id == id) item.copyWith(time: time) else item,
    ]);
  }
}

final remindersControllerProvider =
    AsyncNotifierProvider<RemindersController, List<ReminderItem>>(RemindersController.new);
