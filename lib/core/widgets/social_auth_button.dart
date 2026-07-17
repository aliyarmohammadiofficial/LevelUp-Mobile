import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SocialProvider { google, apple }

/// Circular outlined icon button for Google/Apple sign-in, matching the
/// two small round buttons shown beneath "or" on the Login/Signup screens.
class SocialAuthButton extends StatelessWidget {
  const SocialAuthButton({
    super.key,
    required this.provider,
    required this.onPressed,
  });

  final SocialProvider provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.ink100, width: 1.5),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onPressed,
        child: SizedBox(
          height: 54,
          width: 54,
          child: Center(
            child: Text(
              provider == SocialProvider.google ? 'G' : '',
              style: TextStyle(
                fontSize: provider == SocialProvider.google ? 20 : 24,
                fontWeight: FontWeight.w700,
                color: AppColors.ink900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
