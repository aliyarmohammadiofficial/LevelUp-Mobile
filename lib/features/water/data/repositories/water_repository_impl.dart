import 'dart:async';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/streak_milestones.dart';
import '../../../notifications/data/datasources/notifications_local_datasource.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../../../profile/data/datasources/gamification_local_datasource.dart';
import '../../../profile/domain/entities/gamification_stats.dart';
import '../../domain/entities/water_entities.dart';
import '../../domain/repositories/water_repository.dart';
import '../datasources/water_local_datasource.dart';

class WaterRepositoryImpl implements WaterRepository {
  WaterRepositoryImpl(
    this._local, [
    GamificationLocalDataSource? gamification,
    NotificationsLocalDataSource? notifications,
  ])  : _gamification = gamification ?? GamificationLocalDataSource(),
        _notifications = notifications ?? NotificationsLocalDataSource();

  final WaterLocalDataSource _local;
  final GamificationLocalDataSource _gamification;
  final NotificationsLocalDataSource _notifications;

  WaterDay? _today;
  final _todayController = StreamController<WaterDay>.broadcast();

  Future<WaterDay> _loadToday() async => _today ??= await _local.getToday();

  @override
  Stream<WaterDay> watchToday() async* {
    yield await _loadToday();
    yield* _todayController.stream;
  }

  @override
  Stream<WaterStats> watchStats() async* {
    yield await _local.getStats();
  }

  @override
  Future<List<WaterHistoryEntry>> getWeekHistory() async {
    return _local.getWeekHistory();
  }

  @override
  Future<Result<WaterDay>> logCup({int count = 1}) async {
    final current = await _loadToday();
    final wasGoalReached = current.goalReached;
    final updated = await _local.setCupsToday(current.cupsLogged + count);
    _today = updated;
    _todayController.add(updated);

    // Award XP + notify exactly once per day, at the moment the goal is
    // first crossed (not on every cup logged after it).
    if (!wasGoalReached && updated.goalReached) {
      await _awardGoalMetXp(updated);
    }
    return Result.success(updated);
  }

  Future<void> _awardGoalMetXp(WaterDay day) async {
    final dateKey =
        '${day.date.year.toString().padLeft(4, '0')}-${day.date.month.toString().padLeft(2, '0')}-${day.date.day.toString().padLeft(2, '0')}';
    await _gamification.awardOnce(
      eventKey: 'water_goal_$dateKey',
      amount: XpRewards.waterGoalMetToday,
    );
    final title = 'Hydration goal reached! 💧';
    final body =
        "You've hit your ${day.cupGoal}-cup goal for today. +${XpRewards.waterGoalMetToday} XP";
    await PushNotificationService.instance.showNow(
      id: NotificationIds.waterGoalMet,
      title: title,
      body: body,
    );
    await _notifications.record(
      id: 'water_goal_$dateKey',
      category: NotificationCategory.achievement,
      title: title,
      body: body,
    );

    final stats = await _local.getStats();
    final milestone = matchedStreakMilestone(stats.currentStreakDays);
    if (milestone != null) await _awardStreakMilestone(milestone);
  }

  Future<void> _awardStreakMilestone(int days) async {
    await _gamification.awardOnce(
      eventKey: 'water_streak_${days}d',
      amount: XpRewards.streakMilestoneBonus,
    );
    final title = '$days-Day Streak! 🔥';
    final body =
        "You've hit your water goal $days days in a row. +${XpRewards.streakMilestoneBonus} XP";
    await PushNotificationService.instance.showNow(
      id: NotificationIds.streakMilestone,
      title: title,
      body: body,
    );
    await _notifications.record(
      id: 'water_streak_${days}d',
      category: NotificationCategory.achievement,
      title: title,
      body: body,
    );
  }

  @override
  Future<Result<WaterDay>> undoCup() async {
    final current = await _loadToday();
    final updated = await _local.setCupsToday(current.cupsLogged - 1);
    _today = updated;
    _todayController.add(updated);
    return Result.success(updated);
  }
}
