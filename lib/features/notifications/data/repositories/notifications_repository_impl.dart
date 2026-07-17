import 'dart:async';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_local_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl(this._local) {
    // Any write from any feature (Water/Workout/Fasting/Reminders each hold
    // their own NotificationsLocalDataSource instance) re-reads and
    // re-broadcasts here, so the feed stays live no matter which instance
    // wrote the change.
    _changesSubscription = NotificationsLocalDataSource.changes.listen((_) => refresh());
  }

  final NotificationsLocalDataSource _local;
  late final StreamSubscription<void> _changesSubscription;

  List<AppNotification>? _items;
  final _controller = StreamController<List<AppNotification>>.broadcast();

  Future<List<AppNotification>> _loadCurrent() async => _items ??= await _local.getAll();

  @override
  Stream<List<AppNotification>> watchAll() async* {
    yield await _loadCurrent();
    yield* _controller.stream;
  }

  Future<void> refresh() async {
    _items = await _local.getAll();
    _controller.add(_items!);
  }

  @override
  Future<void> markAsRead(String id) => _local.markAsRead(id);

  @override
  Future<void> markAllAsRead() => _local.markAllAsRead();

  @override
  Future<void> dismiss(String id) => _local.dismiss(id);

  void dispose() {
    _changesSubscription.cancel();
    _controller.close();
  }
}
