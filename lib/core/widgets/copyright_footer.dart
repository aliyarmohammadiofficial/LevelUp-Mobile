import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

/// Single-line copyright credit, used at the bottom of legal/info screens
/// (About, Privacy Policy, Personal Information, Goals) so attribution to
/// the app's developer is consistent everywhere it's shown.
class CopyrightFooter extends StatelessWidget {
  const CopyrightFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Text(
        AppConstants.copyrightNotice,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.ink500),
      ),
    );
  }
}
