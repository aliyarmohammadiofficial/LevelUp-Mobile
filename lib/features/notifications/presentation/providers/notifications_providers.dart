import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/notifications_local_datasource.dart';
import '../../data/repositories/notifications_repository_impl.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';

final notificationsLocalDataSourceProvider = Provider((ref) => NotificationsLocalDataSource());

final notificationsRepositoryProvider = Provider<NotificationsRepository>((ref) {
  final repo = NotificationsRepositoryImpl(ref.watch(notificationsLocalDataSourceProvider));
  ref.onDispose(repo.dispose);
  return repo;
});

final notificationsProvider = StreamProvider<List<AppNotification>>((ref) {
  return ref.watch(notificationsRepositoryProvider).watchAll();
});

final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).asData?.value ?? const [];
  return notifications.where((n) => !n.isRead).length;
});
