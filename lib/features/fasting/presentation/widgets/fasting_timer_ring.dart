import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/fasting_entities.dart';

/// Large hero countdown ring for the Fasting screen — the full-size
/// counterpart to the compact ring on the Dashboard's [FastingCard],
/// sharing the same gradient sweep so the two feel like one component.
class FastingTimerRing extends StatelessWidget {
  const FastingTimerRing({
    super.key,
    required this.session,
    required this.now,
    this.size = 240,
  });

  final FastingSession session;
  final DateTime now;
  final double size;

  String _format(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remaining = session.remainingIn(now);
    final isEatingWindow = session.state == FastingSessionState.eatingWindow;
    final isCompleted = session.state == FastingSessionState.completed;
    final progress = isEatingWindow || isCompleted ? 1.0 : session.progressAt(now);

    final statusLabel = switch (session.state) {
      FastingSessionState.fasting => 'Fasting',
      FastingSessionState.eatingWindow => 'Eating Window',
      FastingSessionState.completed => 'Complete',
      FastingSessionState.notStarted => 'Not Started',
    };

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(progress: progress, isEatingWindow: isEatingWindow),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(session.plan.label, style: theme.textTheme.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(
                _format(remaining),
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                statusLabel,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isEatingWindow ? AppColors.warning : AppColors.ink500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.progress, required this.isEatingWindow});
  final double progress;
  final bool isEatingWindow;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 14;
    const strokeWidth = 16.0;

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
      ..shader = SweepGradient(
        colors: isEatingWindow
            ? [AppColors.warning, AppColors.warning]
            : [AppColors.primaryLight, AppColors.primary, AppColors.primaryDark],
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
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isEatingWindow != isEatingWindow;
}
