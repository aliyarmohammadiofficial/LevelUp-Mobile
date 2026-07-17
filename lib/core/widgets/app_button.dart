import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

enum AppButtonVariant { primary, outlined, text }

/// Pill-shaped button matching the reference screens' "Sign Up" / "Log In" /
/// "Get Started" buttons: full-width, 54px tall, rounded-pill, with a subtle
/// scale-down press animation and an inline loading spinner that replaces
/// the label without changing the button's size.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;
  final bool expand;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _isDisabled => widget.onPressed == null || widget.isLoading;

  void _setPressed(bool value) {
    if (_isDisabled) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final child = AnimatedScale(
      scale: _pressed ? 0.97 : 1.0,
      duration: AppMotion.instant,
      curve: Curves.easeOut,
      child: SizedBox(
        width: widget.expand ? double.infinity : null,
        height: 54,
        child: _buildByVariant(context),
      ),
    );

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: child,
    );
  }

  Widget _buildByVariant(BuildContext context) {
    final content = widget.isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[widget.icon!, const SizedBox(width: AppSpacing.sm)],
              Text(widget.label),
            ],
          );

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return ElevatedButton(
          onPressed: _isDisabled ? null : widget.onPressed,
          child: content,
        );
      case AppButtonVariant.outlined:
        return OutlinedButton(
          onPressed: _isDisabled ? null : widget.onPressed,
          child: DefaultTextStyle.merge(
            style: const TextStyle(color: AppColors.ink700),
            child: content,
          ),
        );
      case AppButtonVariant.text:
        return TextButton(
          onPressed: _isDisabled ? null : widget.onPressed,
          child: content,
        );
    }
  }
}
