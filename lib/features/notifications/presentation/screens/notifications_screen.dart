import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../providers/notifications_providers.dart';
import '../widgets/notification_tile.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Notifications screen, reached from the bell icon on Dashboard/Profile.
/// Shows reminders, achievements, and community activity in one feed,
/// with swipe-to-dismiss and a "mark all as read" action.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          notificationsAsync.maybeWhen(
            data: (items) => items.any((n) => !n.isRead)
                ? TextButton(
                    onPressed: () => ref.read(notificationsRepositoryProvider).markAllAsRead(),
                    child: const Text('Mark all read'),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          loading: () => const AppLoadingIndicator(),
          error: (error, stack) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Mascot(pose: MascotPose.sad, size: 96),
                const SizedBox(height: AppSpacing.md),
                Text("Couldn't load your notifications.", style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Mascot(pose: MascotPose.sleepy, size: 96),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      "You're all caught up!",
                      style: theme.textTheme.titleMedium?.copyWith(color: AppColors.ink500),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg).copyWith(
                top: AppSpacing.sm,
                bottom: AppSpacing.xxxl,
              ),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: () => ref.read(notificationsRepositoryProvider).markAsRead(notification.id),
                  onDismiss: () => ref.read(notificationsRepositoryProvider).dismiss(notification.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
