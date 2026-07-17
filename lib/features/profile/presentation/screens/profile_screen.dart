import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../providers/profile_providers.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_menu_list.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(profileSummaryProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => context.push('/notifications'),
                icon: const Icon(Icons.notifications_none_rounded),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
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
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: summaryAsync.when(
          data: (summary) => ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
              top: AppSpacing.sm,
              bottom: AppSpacing.xxxl,
            ),
            children: [
              ProfileHeaderCard(summary: summary)
                  .animate()
                  .fadeIn(duration: AppMotion.standard)
                  .slideY(begin: -0.06, end: 0, curve: AppMotion.enterCurve),
              const SizedBox(height: AppSpacing.xxl),
              ProfileMenuList(
                items: [
                  ProfileMenuItemData(
                    icon: Icons.person_outline_rounded,
                    label: 'Personal Information',
                    onTap: () => context.push('/profile/personal-information'),
                  ),
                  ProfileMenuItemData(
                    icon: Icons.track_changes_rounded,
                    label: 'Goals',
                    onTap: () => context.push('/profile/goals'),
                  ),
                  ProfileMenuItemData(
                    icon: Icons.notifications_active_outlined,
                    label: 'Reminders',
                    onTap: () => context.push('/profile/reminders'),
                  ),
                  ProfileMenuItemData(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    onTap: () => context.push('/settings'),
                  ),
                  ProfileMenuItemData(
                    icon: Icons.help_outline_rounded,
                    label: 'Help & Support',
                    onTap: () => context.push('/profile/help-support'),
                  ),
                  ProfileMenuItemData(
                    icon: Icons.info_outline_rounded,
                    label: 'About LevelUp',
                    onTap: () => context.push('/profile/about'),
                  ),
                ],
              ).animate().fadeIn(delay: 80.ms, duration: AppMotion.standard),
              const SizedBox(height: AppSpacing.xxl),
              _LogOutButton(onConfirmed: () => ref.read(signOutUseCaseProvider).call())
                  .animate()
                  .fadeIn(delay: 140.ms, duration: AppMotion.standard),
            ],
          ),
          loading: () => const AppLoadingIndicator(),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Mascot(pose: MascotPose.sad, size: 100),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    "Couldn't load your profile.",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: () => ref.invalidate(profileSummaryProvider),
                    child: const Text('Try again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onConfirmed});

  final VoidCallback onConfirmed;

  Future<void> _confirm(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out of LevelUp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log Out', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: () => _confirm(context),
        icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
        label: const Text('Log Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
