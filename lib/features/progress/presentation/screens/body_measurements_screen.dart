import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../domain/entities/progress_summary.dart';
import '../providers/progress_providers.dart';

enum _MeasurementUnit { cm, inch }

extension on _MeasurementUnit {
  String get suffix => this == _MeasurementUnit.cm ? 'cm' : 'in';

  /// Converts a value stored internally in cm to this unit for display.
  double fromCm(double cm) => this == _MeasurementUnit.cm ? cm : cm / 2.54;

  /// Converts a value entered in this unit back to cm for storage.
  double toCm(double value) => this == _MeasurementUnit.cm ? value : value * 2.54;
}

IconData _groupIcon(String group) {
  switch (group) {
    case 'Upper Body':
      return Icons.accessibility_new_rounded;
    case 'Core':
      return Icons.straighten_rounded;
    case 'Arms & Legs':
      return Icons.directions_run_rounded;
    default:
      return Icons.straighten_rounded;
  }
}

/// Capture form for body measurements (Neck, Shoulders, Chest, Waist,
/// Hips, Bicep, Thigh, Calf — see [BodyMeasurementFields]). Reached from
/// the Progress screen's Body tab. Every site is optional per visit: a
/// site left blank simply keeps its last logged value untouched, so a
/// quick "just waist and hips today" entry is a normal use of this
/// screen, not a partial/invalid one.
class BodyMeasurementsScreen extends ConsumerStatefulWidget {
  const BodyMeasurementsScreen({super.key});

  @override
  ConsumerState<BodyMeasurementsScreen> createState() => _BodyMeasurementsScreenState();
}

class _BodyMeasurementsScreenState extends ConsumerState<BodyMeasurementsScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {
    for (final field in BodyMeasurementFields.all) field.label: TextEditingController(),
  };

  _MeasurementUnit _unit = _MeasurementUnit.cm;
  bool _prefilled = false;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _prefillIfNeeded(Map<String, double> latestCm) {
    if (_prefilled || latestCm.isEmpty) return;
    for (final entry in latestCm.entries) {
      final controller = _controllers[entry.key];
      if (controller != null) {
        controller.text = _unit.fromCm(entry.value).toStringAsFixed(1);
      }
    }
    _prefilled = true;
  }

  void _switchUnit(_MeasurementUnit next) {
    if (next == _unit) return;
    // Re-render every filled field's number in the new unit so what's on
    // screen always reflects the unit label next to it.
    for (final field in BodyMeasurementFields.all) {
      final controller = _controllers[field.label]!;
      final raw = double.tryParse(controller.text.trim());
      if (raw == null) continue;
      final cm = _unit.toCm(raw);
      controller.text = next.fromCm(cm).toStringAsFixed(1);
    }
    setState(() => _unit = next);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final valuesCm = <String, double>{};
    for (final field in BodyMeasurementFields.all) {
      final text = _controllers[field.label]!.text.trim();
      if (text.isEmpty) continue;
      final value = double.parse(text);
      valuesCm[field.label] = double.parse(_unit.toCm(value).toStringAsFixed(1));
    }

    if (valuesCm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one measurement to save.')),
      );
      return;
    }

    setState(() => _saving = true);
    final result = await ref.read(progressRepositoryProvider).logMeasurements(valuesCm);
    if (!mounted) return;
    setState(() => _saving = false);

    result.fold(
      (failure) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        ref.invalidate(progressSummaryProvider);
        ref.invalidate(latestMeasurementsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              valuesCm.length == 1
                  ? 'Measurement saved.'
                  : '${valuesCm.length} measurements saved.',
            ),
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestAsync = ref.watch(latestMeasurementsProvider);

    latestAsync.whenData(_prefillIfNeeded);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Measurements'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.lg),
            child: _UnitToggle(unit: _unit, onChanged: _switchUnit),
          ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl).copyWith(
              top: AppSpacing.lg,
              bottom: AppSpacing.xxxl,
            ),
            children: [
              latestAsync.when(
                data: (latest) => _LastUpdatedBanner(hasData: latest.isNotEmpty),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ).animate().fadeIn(duration: AppMotion.standard),
              const SizedBox(height: AppSpacing.lg),
              for (int i = 0; i < BodyMeasurementFields.groups.length; i++) ...[
                _MeasurementGroupCard(
                  group: BodyMeasurementFields.groups[i],
                  controllers: _controllers,
                  unit: _unit,
                ).animate().fadeIn(
                      delay: (80 * i).ms,
                      duration: AppMotion.standard,
                    ).slideY(begin: 0.04, end: 0, curve: AppMotion.enterCurve),
                const SizedBox(height: AppSpacing.lg),
              ],
              Text(
                'Leave a field blank to keep its last logged value — you '
                'don\'t need to re-measure everything every time.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.md,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        child: AppButton(
          label: 'Save Measurements',
          isLoading: _saving,
          onPressed: _save,
        ),
      ),
    );
  }
}

class _LastUpdatedBanner extends StatelessWidget {
  const _LastUpdatedBanner({required this.hasData});

  final bool hasData;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Row(
        children: [
          Icon(
            hasData ? Icons.history_rounded : Icons.info_outline_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              hasData
                  ? 'Editing today\'s entry updates any site you change '
                      'below and leaves the rest as-is.'
                  : 'First time logging measurements — fill in whichever '
                      'sites you\'d like to start tracking.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.ink700),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.unit, required this.onChanged});

  final _MeasurementUnit unit;
  final ValueChanged<_MeasurementUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: AppRadius.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _UnitSegment(
            label: 'cm',
            selected: unit == _MeasurementUnit.cm,
            onTap: () => onChanged(_MeasurementUnit.cm),
          ),
          _UnitSegment(
            label: 'in',
            selected: unit == _MeasurementUnit.inch,
            onTap: () => onChanged(_MeasurementUnit.inch),
          ),
        ],
      ),
    );
  }
}

class _UnitSegment extends StatelessWidget {
  const _UnitSegment({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.pillRadius,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: selected ? Colors.white : AppColors.ink500,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _MeasurementGroupCard extends StatelessWidget {
  const _MeasurementGroupCard({
    required this.group,
    required this.controllers,
    required this.unit,
  });

  final String group;
  final Map<String, TextEditingController> controllers;
  final _MeasurementUnit unit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fields = BodyMeasurementFields.inGroup(group);

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgRadius,
        boxShadow: AppElevation.card(AppColors.ink900),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_groupIcon(group), size: 18, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(group, style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          for (int i = 0; i < fields.length; i++) ...[
            _MeasurementField(
              label: fields[i].label,
              controller: controllers[fields[i].label]!,
              unit: unit,
            ),
            if (i != fields.length - 1) const SizedBox(height: AppSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _MeasurementField extends StatelessWidget {
  const _MeasurementField({
    required this.label,
    required this.controller,
    required this.unit,
  });

  final String label;
  final TextEditingController controller;
  final _MeasurementUnit unit;

  String? _validate(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return null; // optional per-site
    final parsed = double.tryParse(text);
    if (parsed == null) return 'Enter a number';
    if (parsed <= 0 || parsed > 300) return 'Enter a realistic value';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        Expanded(
          flex: 4,
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.end,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: _validate,
            decoration: InputDecoration(
              isDense: true,
              hintText: '—',
              suffixText: unit.suffix,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            ),
          ),
        ),
      ],
    );
  }
}


