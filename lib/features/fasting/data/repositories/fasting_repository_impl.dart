import 'dart:async';
import '../../../../core/services/push_notification_service.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/streak_milestones.dart';
import '../../../notifications/data/datasources/notifications_local_datasource.dart';
import '../../../notifications/domain/entities/app_notification.dart';
import '../../../profile/data/datasources/gamification_local_datasource.dart';
import '../../../profile/domain/entities/gamification_stats.dart';
import '../../domain/entities/fasting_entities.dart';
import '../../domain/repositories/fasting_repository.dart';
import '../datasources/fasting_local_datasource.dart';

class FastingRepositoryImpl implements FastingRepository {
  FastingRepositoryImpl(
    this._local, [
    GamificationLocalDataSource? gamification,
    NotificationsLocalDataSource? notifications,
  ])  : _gamification = gamification ?? GamificationLocalDataSource(),
        _notifications = notifications ?? NotificationsLocalDataSource();

  final FastingLocalDataSource _local;
  final GamificationLocalDataSource _gamification;
  final NotificationsLocalDataSource _notifications;

  FastingSession? _session;
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _session = await _local.getCurrentSession();
    _loaded = true;
  }

  @override
  List<FastingPlan> get plans => FastingLocalDataSource.plans;

  @override
  Stream<FastingSession?> watchSession() async* {
    await _ensureLoaded();
    yield _session;
    if (_session == null) return;

    // Ticks once a second so the ring + countdown stay live, and persists
    // state transitions (fasting -> eating window -> completed) as they
    // happen so a killed/reopened app resumes from the right phase.
    yield* Stream.periodic(const Duration(seconds: 1), (_) => _session).asyncMap((_) async {
      final current = _session!;
      final now = DateTime.now();

      if (current.state == FastingSessionState.fasting && now.isAfter(current.fastEndsAt)) {
        _session = current.copyWith(state: FastingSessionState.eatingWindow);
        await _local.saveSession(_session!);
      } else if (current.state == FastingSessionState.eatingWindow &&
          now.isAfter(current.eatingWindowEndsAt)) {
        _session = current.copyWith(state: FastingSessionState.completed);
        await _local.saveSession(_session!);
        await _recordHistory(_session!);
      }
      return _session!;
    });
  }

  @override
  Stream<FastingStats> watchStats() async* {
    yield await _local.getStats();
  }

  @override
  Future<Result<FastingSession>> startFast(FastingPlan plan) async {
    final startedAt = DateTime.now();
    _session = FastingSession(
      plan: plan,
      state: FastingSessionState.fasting,
      startedAt: startedAt,
      fastEndsAt: startedAt.add(Duration(hours: plan.fastHours)),
      eatingWindowEndsAt: startedAt.add(Duration(hours: plan.fastHours + plan.eatHours)),
    );
    _loaded = true;
    await _local.saveSession(_session!);
    return Result.success(_session!);
  }

  @override
  Future<Result<void>> endFastEarly() async {
    await _ensureLoaded();
    if (_session != null) {
      final achievedHours =
          DateTime.now().difference(_session!.startedAt).inMinutes / 60.0;
      _session = _session!.copyWith(state: FastingSessionState.eatingWindow);
      await _local.saveSession(_session!);
      final entry = FastingHistoryEntry(
        date: DateTime(_session!.startedAt.year, _session!.startedAt.month, _session!.startedAt.day),
        planLabel: _session!.plan.label,
        achievedHours: double.parse(achievedHours.toStringAsFixed(1)),
        targetHours: _session!.plan.fastHours,
        goalMet: achievedHours >= _session!.plan.fastHours,
      );
      await _local.addHistoryEntry(entry);
      if (entry.goalMet) await _awardFastCompletedXp(entry);
    }
    return const Result.success(null);
  }

  Future<void> _recordHistory(FastingSession session) async {
    final achievedHours =
        session.fastEndsAt.difference(session.startedAt).inMinutes / 60.0;
    final entry = FastingHistoryEntry(
      date: DateTime(session.startedAt.year, session.startedAt.month, session.startedAt.day),
      planLabel: session.plan.label,
      achievedHours: double.parse(achievedHours.toStringAsFixed(1)),
      targetHours: session.plan.fastHours,
      goalMet: achievedHours >= session.plan.fastHours,
    );
    await _local.addHistoryEntry(entry);
    if (entry.goalMet) await _awardFastCompletedXp(entry);
  }

  Future<void> _awardFastCompletedXp(FastingHistoryEntry entry) async {
    final dateKey =
        '${entry.date.year.toString().padLeft(4, '0')}-${entry.date.month.toString().padLeft(2, '0')}-${entry.date.day.toString().padLeft(2, '0')}';
    await _gamification.awardOnce(
      eventKey: 'fast_completed_$dateKey',
      amount: XpRewards.fastCompleted,
    );
    final title = 'Fast complete! ⏱️';
    final body = 'You completed your ${entry.planLabel} fast. +${XpRewards.fastCompleted} XP';
    await PushNotificationService.instance.showNow(
      id: NotificationIds.fastCompleted,
      title: title,
      body: body,
    );
    await _notifications.record(
      id: 'fast_completed_$dateKey',
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
      eventKey: 'fasting_streak_${days}d',
      amount: XpRewards.streakMilestoneBonus,
    );
    final title = '$days-Day Streak! 🔥';
    final body =
        "You've hit your fasting goal $days days in a row. +${XpRewards.streakMilestoneBonus} XP";
    await PushNotificationService.instance.showNow(
      id: NotificationIds.streakMilestone,
      title: title,
      body: body,
    );
    await _notifications.record(
      id: 'fasting_streak_${days}d',
      category: NotificationCategory.achievement,
      title: title,
      body: body,
    );
  }

  @override
  Future<List<FastingHistoryEntry>> getHistory({int limit = 14}) async {
    return _local.getHistory(limit: limit);
  }
}
