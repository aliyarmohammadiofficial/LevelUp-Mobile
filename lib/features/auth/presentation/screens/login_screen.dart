import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/social_auth_button.dart';
import '../providers/auth_form_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(logInControllerProvider.notifier).submit(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(logInControllerProvider, (previous, next) {
      if (next.failure != null && next.failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure!.message)),
        );
      }
      if (next.succeeded && previous?.succeeded != true) {
        context.go('/dashboard');
      }
    });

    final formState = ref.watch(logInControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
                ).animate().fadeIn(duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.xxl),
                Text('Welcome back!', style: theme.textTheme.displayMedium)
                    .animate()
                    .fadeIn(delay: 80.ms, duration: AppMotion.standard)
                    .slideY(begin: 0.15, end: 0, curve: AppMotion.enterCurve),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Log in to continue',
                  style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.ink500),
                ).animate().fadeIn(delay: 140.ms, duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  autofillHints: const [AutofillHints.email],
                ).animate().fadeIn(delay: 180.ms, duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hint: '••••••••',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  autofillHints: const [AutofillHints.password],
                  onSubmitted: (_) => _submit(),
                ).animate().fadeIn(delay: 220.ms, duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: 'Log In',
                  isLoading: formState.isSubmitting,
                  onPressed: _submit,
                ).animate().fadeIn(delay: 260.ms, duration: AppMotion.standard),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text('or', style: theme.textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialAuthButton(
                      provider: SocialProvider.google,
                      onPressed: () => ref.read(logInControllerProvider.notifier).submitGoogle(),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    SocialAuthButton(
                      provider: SocialProvider.apple,
                      onPressed: () => ref.read(logInControllerProvider.notifier).submitApple(),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxxl),
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
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
