import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key, required this.userName});

  final String userName;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$_greeting, $userName!',
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink500),
              ),
              Text("Let's crush your\ngoals today!", style: theme.textTheme.headlineLarge),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => context.push('/notifications'),
              icon: const Icon(Icons.notifications_none_rounded),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                shape: const CircleBorder(),
                fixedSize: const Size(44, 44),
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
