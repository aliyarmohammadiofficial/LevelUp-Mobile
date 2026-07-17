import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../providers/nutrition_providers.dart';

/// Form for editing the daily calorie goal and macro targets, reached from
/// the Plan tab's edit icon / "Edit Plan" button.
class EditPlanScreen extends ConsumerStatefulWidget {
  const EditPlanScreen({super.key, required this.day});

  final NutritionDay day;

  @override
  ConsumerState<EditPlanScreen> createState() => _EditPlanScreenState();
}

class _EditPlanScreenState extends ConsumerState<EditPlanScreen> {
  late final _calorieController =
      TextEditingController(text: widget.day.calorieGoal.toString());
  late final _proteinController =
      TextEditingController(text: widget.day.macroTargets.proteinG.toString());
  late final _carbsController =
      TextEditingController(text: widget.day.macroTargets.carbsG.toString());
  late final _fatController =
      TextEditingController(text: widget.day.macroTargets.fatG.toString());

  bool _isSaving = false;

  @override
  void dispose() {
    _calorieController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await ref.read(nutritionActionsProvider).updatePlan(
          calorieGoal: int.tryParse(_calorieController.text) ?? widget.day.calorieGoal,
          macroTargets: MacroTargets(
            proteinG: int.tryParse(_proteinController.text) ?? widget.day.macroTargets.proteinG,
            carbsG: int.tryParse(_carbsController.text) ?? widget.day.macroTargets.carbsG,
            fatG: int.tryParse(_fatController.text) ?? widget.day.macroTargets.fatG,
          ),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Plan')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Daily Calorie Goal (kcal)',
                controller: _calorieController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Protein Target (g)',
                controller: _proteinController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Carbs Target (g)',
                controller: _carbsController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Fat Target (g)',
                controller: _fatController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.xxl),
              AppButton(
                label: 'Save Plan',
                isLoading: _isSaving,
                onPressed: _save,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
