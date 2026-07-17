import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/app_notification.dart';

String _relativeTime(DateTime timestamp) {
  final diff = DateTime.now().difference(timestamp);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

/// One row in the Notifications list — icon by category, title, body,
/// relative timestamp, and an unread dot. Swipe left to dismiss.
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  Color get _iconColor {
    switch (notification.category) {
      case NotificationCategory.achievement:
        return AppColors.warning;
      case NotificationCategory.reminder:
        return AppColors.primary;
      case NotificationCategory.social:
        return AppColors.success;
      case NotificationCategory.system:
        return AppColors.ink500;
    }
  }

  Color get _iconSurface {
    switch (notification.category) {
      case NotificationCategory.achievement:
        return AppColors.warningSurface;
      case NotificationCategory.reminder:
        return AppColors.primarySurface;
      case NotificationCategory.social:
        return AppColors.successSurface;
      case NotificationCategory.system:
        return AppColors.primarySurfaceAlt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.errorSurface,
          borderRadius: AppRadius.lgRadius,
        ),
        child: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgRadius,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: notification.isRead ? AppColors.surface : AppColors.primarySurface,
            borderRadius: AppRadius.lgRadius,
            boxShadow: AppElevation.card(AppColors.ink900),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _iconSurface, shape: BoxShape.circle),
                child: Icon(notification.icon, size: 20, color: _iconColor),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          _relativeTime(notification.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink500),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
