import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

class SettingsOption<T> {
  const SettingsOption({required this.value, required this.label, this.subtitle});
  final T value;
  final String label;
  final String? subtitle;
}

/// Shows a modal bottom sheet listing [options] with the current
/// selection checked, and returns the picked value (or null if
/// dismissed). Used by the Units / Theme / Language rows on the
/// Settings screen so each picker is a single line at the call site.
Future<T?> showSettingsOptionPicker<T>({
  required BuildContext context,
  required String title,
  required List<SettingsOption<T>> options,
  required T selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Text(title, style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(height: AppSpacing.sm),
              for (final option in options)
                ListTile(
                  onTap: () => Navigator.of(context).pop(option.value),
                  title: Text(option.label),
                  subtitle: option.subtitle != null ? Text(option.subtitle!) : null,
                  trailing: option.value == selected
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                      : null,
                ),
            ],
          ),
        ),
      );
    },
  );
}
