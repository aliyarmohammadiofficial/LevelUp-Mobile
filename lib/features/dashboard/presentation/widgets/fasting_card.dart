import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/dashboard_summary.dart';

/// Large fasting card with a circular progress ring and live countdown,
/// matching the "16:8 / 10:24:36 Remaining / End Fast" card at the top of
/// the reference Dashboard screen.
class FastingCard extends StatelessWidget {
  const FastingCard({super.key, required this.status});

  final FastingStatus status;

  String get _formattedRemaining {
    final h = status.remaining.inHours.toString().padLeft(2, '0');
    final m = (status.remaining.inMinutes % 60).toString().padLeft(2, '0');
    final s = (status.remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String get _endsAtLabel {
    final hour = status.endsAt.hour % 12 == 0 ? 12 : status.endsAt.hour % 12;
    final period = status.endsAt.hour >= 12 ? 'PM' : 'AM';
    final minute = status.endsAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // 16:8 plan → 16h fast; used only to compute ring progress.
    const totalFastSeconds = 16 * 3600;
    final elapsedFraction =
        1 - (status.remaining.inSeconds.clamp(0, totalFastSeconds) / totalFastSeconds);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: CustomPaint(
              painter: _FastingRingPainter(progress: elapsedFraction),
              child: Center(
                child: Text(status.planLabel, style: theme.textTheme.titleLarge),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.isActive ? 'Fasting Ends' : 'Fast Complete',
                  style: theme.textTheme.bodySmall,
                ),
                Text('Today, $_endsAtLabel', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _formattedRemaining,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text('Remaining', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/fasting'),
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primarySurface,
              shape: const CircleBorder(),
            ),
          ),
        ],
      ),
    );
  }
}

class _FastingRingPainter extends CustomPainter {
  _FastingRingPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 6;
    const strokeWidth = 8.0;

    final trackPaint = Paint()
      ..color = AppColors.chartTrackWeak
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress.clamp(0, 1),
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _FastingRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
