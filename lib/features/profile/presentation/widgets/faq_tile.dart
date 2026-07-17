import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/entities/faq_entry.dart';

/// Expandable Quick Help row — question header that reveals its answer
/// on tap, matching the "How to track workouts?" style rows in the
/// reference Help & Support screen.
class FaqTile extends StatefulWidget {
  const FaqTile({super.key, required this.entry});

  final FaqEntry entry;

  @override
  State<FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.entry.question, style: theme.textTheme.bodyLarge),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: AppMotion.fast,
                  child: const Icon(Icons.expand_more_rounded, color: AppColors.ink300),
                ),
              ],
            ),
            AnimatedCrossFade(
              duration: AppMotion.fast,
              crossFadeState: _expanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              firstChild: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(
                  widget.entry.answer,
                  style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.ink500),
                ),
              ),
              secondChild: const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
