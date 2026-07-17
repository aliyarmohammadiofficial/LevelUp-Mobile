import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/nutrition_providers.dart';

/// Lets the user define their own food (name, serving size, calories,
/// and macros) so it can be searched and logged just like the built-in
/// catalog — reachable from the Add Food screen via "Create Custom Food".
class CreateCustomFoodScreen extends ConsumerStatefulWidget {
  const CreateCustomFoodScreen({super.key});

  @override
  ConsumerState<CreateCustomFoodScreen> createState() => _CreateCustomFoodScreenState();
}

class _CreateCustomFoodScreenState extends ConsumerState<CreateCustomFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingController = TextEditingController(text: '100g');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _servingController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  String? _requiredText(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _requiredInt(String? value, String label) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return '$label is required';
    final parsed = int.tryParse(v);
    if (parsed == null || parsed < 0) return 'Enter a valid $label';
    return null;
  }

  String? _optionalDouble(String? value, String label) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return null;
    final parsed = double.tryParse(v);
    if (parsed == null || parsed < 0) return 'Enter a valid $label';
    return null;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);
    final food = await ref.read(nutritionActionsProvider).createCustomFood(
          name: _nameController.text.trim(),
          servingLabel: _servingController.text.trim(),
          caloriesPerServing: int.parse(_caloriesController.text.trim()),
          proteinG: double.tryParse(_proteinController.text.trim()) ?? 0,
          carbsG: double.tryParse(_carbsController.text.trim()) ?? 0,
          fatG: double.tryParse(_fatController.text.trim()) ?? 0,
        );
    if (!mounted) return;

    setState(() => _isSaving = false);

    if (food == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't save this food. Try again.")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} added to your foods')),
    );
    Navigator.of(context).pop(food);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Custom Food')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screenPadding.add(
              const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxxl),
            ),
            children: [
              Text(
                'Add a food that isn\'t in the catalog. It will show up in search '
                'and Recent so you can log it anytime.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Food name',
                controller: _nameController,
                hint: 'e.g. Homemade Lentil Soup',
                textInputAction: TextInputAction.next,
                validator: (v) => _requiredText(v, 'Food name'),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Serving size',
                controller: _servingController,
                hint: 'e.g. 100g, 1 cup, 1 bowl',
                textInputAction: TextInputAction.next,
                validator: (v) => _requiredText(v, 'Serving size'),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Calories per serving',
                controller: _caloriesController,
                hint: 'e.g. 250',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                validator: (v) => _requiredInt(v, 'calories'),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text('Macros (optional, grams per serving)', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Protein',
                      controller: _proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      validator: (v) => _optionalDouble(v, 'protein'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Carbs',
                      controller: _carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.next,
                      validator: (v) => _optionalDouble(v, 'carbs'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Fat',
                      controller: _fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textInputAction: TextInputAction.done,
                      validator: (v) => _optionalDouble(v, 'fat'),
                      onSubmitted: (_) => _save(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: 'Save Food',
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
