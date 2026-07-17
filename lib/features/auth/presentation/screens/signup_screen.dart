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

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    ref.read(signUpControllerProvider.notifier).submit(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen(signUpControllerProvider, (previous, next) {
      if (next.failure != null && next.failure != previous?.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.failure!.message)),
        );
      }
      if (next.succeeded && previous?.succeeded != true) {
        context.go('/onboarding');
      }
    });

    final formState = ref.watch(signUpControllerProvider);

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
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text('Create Account', style: theme.textTheme.displayMedium)
                    .animate()
                    .fadeIn(duration: AppMotion.standard)
                    .slideY(begin: 0.15, end: 0, curve: AppMotion.enterCurve),
                const SizedBox(height: AppSpacing.xxxl),
                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hint: 'Your name',
                  textInputAction: TextInputAction.next,
                  validator: Validators.fullName,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  hint: 'you@example.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hint: 'At least 8 characters',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: Validators.password,
                  autofillHints: const [AutofillHints.newPassword],
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.xxl),
                AppButton(
                  label: 'Sign Up',
                  isLoading: formState.isSubmitting,
                  onPressed: _submit,
                ),
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
                    Text('Already have an account?', style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Log In'),
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
