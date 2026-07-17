import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Persistent bottom nav shell wrapping the five main tabs seen across the
/// reference screens: Home, Plan, a floating "+" quick-add action, Progress,
/// and Profile. [child] is swapped by the router per tab (via
/// [StatefulShellRoute] once wired) while this bar and its floating button
/// stay mounted.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onQuickAdd,
  });

  final Widget child;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQuickAdd;

  static const _tabs = [
    _TabSpec(icon: Icons.home_rounded, label: 'Home'),
    _TabSpec(icon: Icons.calendar_today_rounded, label: 'Plan'),
    null, // center floating action slot
    _TabSpec(icon: Icons.show_chart_rounded, label: 'Progress'),
    _TabSpec(icon: Icons.person_rounded, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.surface,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              if (tab == null) {
                // Reserve space for the notch; the FAB sits above it.
                return const SizedBox(width: 56);
              }
              final isSelected = index == currentIndex;
              return _NavItem(
                icon: tab.icon,
                label: tab.label,
                isSelected: isSelected,
                onTap: () => onTabSelected(index),
              );
            }),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onQuickAdd,
        backgroundColor: AppColors.primary,
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class _TabSpec {
  const _TabSpec({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.ink500;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
