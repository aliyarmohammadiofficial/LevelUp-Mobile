import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/workout_routine.dart';
import '../providers/workout_providers.dart';

/// Lets the user define their own exercise (name, target sets, rep range,
/// primary muscles) and add it to a routine — reachable from Workout
/// Detail via "Create Custom Exercise".
class CreateCustomExerciseScreen extends ConsumerStatefulWidget {
  const CreateCustomExerciseScreen({super.key, required this.routineId});

  final String routineId;

  @override
  ConsumerState<CreateCustomExerciseScreen> createState() =>
      _CreateCustomExerciseScreenState();
}

class _CreateCustomExerciseScreenState extends ConsumerState<CreateCustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _setsController = TextEditingController(text: '3');
  final _repRangeController = TextEditingController(text: '8-12 reps');
  final _instructionsController = TextEditingController();

  final Set<MuscleGroup> _selectedMuscles = {};
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _setsController.dispose();
    _repRangeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _requiredSets(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Target sets is required';
    final parsed = int.tryParse(v);
    if (parsed == null || parsed <= 0) return 'Enter a valid number of sets';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedMuscles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick at least one muscle group')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final instructions = _instructionsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final exercise = await ref.read(workoutActionsProvider).createCustomExercise(
          routineId: widget.routineId,
          name: _nameController.text.trim(),
          targetSets: int.parse(_setsController.text.trim()),
          repRangeLabel: _repRangeController.text.trim(),
          primaryMuscles: _selectedMuscles.toList(),
          instructions: instructions,
        );
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (exercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save this exercise. Try again.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${exercise.name} added to your routine')),
    );
    Navigator.of(context).pop(exercise);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Custom Exercise')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screenPadding.add(
              const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxxl),
            ),
            children: [
              Text(
                'Add a move that isn\'t in this routine. It will show up in the '
                'exercise list and can be logged just like the others.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Exercise name',
                controller: _nameController,
                hint: 'e.g. Cable Crossover',
                textInputAction: TextInputAction.next,
                validator: (v) => _requiredText(v, 'Exercise name'),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Target sets',
                      controller: _setsController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      validator: _requiredSets,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Rep range',
                      controller: _repRangeController,
                      hint: 'e.g. 8-12 reps',
                      textInputAction: TextInputAction.next,
                      validator: (v) => _requiredText(v, 'Rep range'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Primary muscles', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: MuscleGroup.values.map((group) {
                  final selected = _selectedMuscles.contains(group);
                  return FilterChip(
                    label: Text(group.label),
                    selected: selected,
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          _selectedMuscles.add(group);
                        } else {
                          _selectedMuscles.remove(group);
                        }
                      });
                    },
                    selectedColor: AppColors.primarySurface,
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Instructions (optional, one step per line)',
                controller: _instructionsController,
                hint: 'e.g. Stand between the pulleys and step forward.',
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: 'Save Exercise',
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
