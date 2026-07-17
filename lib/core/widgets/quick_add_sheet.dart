import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// One tappable action in the Quick Add sheet.
class QuickAddAction {
  const QuickAddAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
}

/// Bottom sheet shown from the floating "+" nav button — a fast path to
/// the app's most common logging actions (meal, water, workout, fast)
/// without leaving the current tab. Matches the reference app's pattern
/// of surfacing frequent actions from one central "+" affordance.
class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key, required this.actions});

  final List<QuickAddAction> actions;

  static Future<void> show(BuildContext context, List<QuickAddAction> actions) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => QuickAddSheet(actions: actions),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quick Add', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xl),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 1.3,
              children: [for (final action in actions) _QuickAddTile(action: action)],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({required this.action});

  final QuickAddAction action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        action.onTap();
      },
      borderRadius: AppRadius.lgRadius,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: AppRadius.lgRadius,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: action.color, shape: BoxShape.circle),
              child: Icon(action.icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(action.label, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
