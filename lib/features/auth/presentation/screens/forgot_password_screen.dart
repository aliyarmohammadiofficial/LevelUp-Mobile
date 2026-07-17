import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/mascot.dart';
import '../providers/auth_form_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(forgotPasswordControllerProvider.notifier).submit(_emailController.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formState = ref.watch(forgotPasswordControllerProvider);

    ref.listen(forgotPasswordControllerProvider, (previous, next) {
      if (next.failure != null && next.failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure!.message)),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: formState.succeeded ? _buildSuccessState(theme) : _buildFormState(theme, formState),
        ),
      ),
    );
  }

  Widget _buildFormState(ThemeData theme, AuthFormState formState) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppSpacing.xxl),
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primarySurface,
                shape: const CircleBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Forgot Password', style: theme.textTheme.displayMedium)
                .animate()
                .fadeIn(duration: AppMotion.standard)
                .slideY(begin: 0.15, end: 0, curve: AppMotion.enterCurve),
            const SizedBox(height: AppSpacing.sm),
            Text(
              "Enter your email and we'll send you a link to reset your password.",
              style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink500),
            ),
            const SizedBox(height: AppSpacing.huge),
            Center(child: Mascot(pose: MascotPose.wave, size: 140))
                .animate()
                .fadeIn(delay: 100.ms, duration: AppMotion.slow)
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1), curve: AppMotion.bounceCurve),
            const SizedBox(height: AppSpacing.huge),
            AppTextField(
              label: 'Email',
              controller: _emailController,
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              validator: Validators.email,
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppButton(
              label: 'Send Reset Link',
              isLoading: formState.isSubmitting,
              onPressed: _submit,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account?", style: theme.textTheme.bodyMedium),
                TextButton(
                  onPressed: () => context.push('/signup'),
                  child: const Text('Sign Up'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Mascot(pose: MascotPose.celebrate, size: 160)
              .animate()
              .fadeIn(duration: AppMotion.slow)
              .scale(begin: const Offset(0.7, 0.7), end: const Offset(1, 1), curve: AppMotion.bounceCurve),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'Check your inbox!',
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 150.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(
            "We've sent a reset link to ${_emailController.text.trim()}",
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink500),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 220.ms),
          const SizedBox(height: AppSpacing.huge),
          AppButton(
            label: 'Back to Login',
            onPressed: () => context.go('/login'),
          ).animate().fadeIn(delay: 280.ms),
        ],
      ),
    );
  }
}
