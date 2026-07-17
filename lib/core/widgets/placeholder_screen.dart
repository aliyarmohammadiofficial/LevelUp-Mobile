import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import 'mascot.dart';

/// Stand-in destination for features scheduled in a later build phase
/// (Dashboard, Onboarding, etc.). Deliberately visible and labeled rather
/// than a silent blank route, so it's obvious in QA which screens are real.
/// Replace each usage with the real screen as that feature is built —
/// do not extend this widget itself.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Mascot(pose: MascotPose.sleepy, size: 100),
              const SizedBox(height: AppSpacing.lg),
              Text(
                '$title is coming in the next build phase',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
