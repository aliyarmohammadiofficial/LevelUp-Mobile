import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/mascot.dart';
import '../../domain/entities/nutrition_entities.dart';
import '../providers/nutrition_providers.dart';
import '../widgets/food_list_tile.dart';
import 'create_custom_food_screen.dart';
import '../../../../core/widgets/app_loading_indicator.dart';

/// Search-and-log screen, matching the reference "Add Food" screen: a
/// search field, a "Recent" list before typing, and search results after.
/// [meal] scopes which meal slot a tapped food gets logged against.
class AddFoodScreen extends ConsumerStatefulWidget {
  const AddFoodScreen({super.key, required this.meal});

  final MealType meal;

  @override
  ConsumerState<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends ConsumerState<AddFoodScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _logFood(FoodItem food) async {
    await ref
        .read(nutritionActionsProvider)
        .logFood(meal: widget.meal, food: food, servings: 1);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} added to ${widget.meal.label}')),
    );
    Navigator.of(context).pop();
  }

  Future<void> _openCreateCustomFood() async {
    final created = await Navigator.of(context).push<FoodItem>(
      MaterialPageRoute(builder: (_) => const CreateCustomFoodScreen()),
    );
    if (created != null && mounted) {
      await _logFood(created);
    }
  }

  Future<void> _deleteCustomFood(FoodItem food) async {
    await ref.read(nutritionActionsProvider).deleteCustomFood(food.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(foodSearchQueryProvider);
    final isSearching = query.trim().isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food · ${widget.meal.label}'),
        actions: [
          IconButton(
            tooltip: 'Create Custom Food',
            icon: const Icon(Icons.add_rounded),
            onPressed: _openCreateCustomFood,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (value) =>
                    ref.read(foodSearchQueryProvider.notifier).state = value,
                decoration: InputDecoration(
                  hintText: 'Search food...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _controller.clear();
                            ref.read(foodSearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: isSearching
                    ? _SearchResults(
                        onAdd: _logFood,
                        onDelete: _deleteCustomFood,
                        onCreateCustom: _openCreateCustomFood,
                      )
                    : _RecentFoods(
                        onAdd: _logFood,
                        onDelete: _deleteCustomFood,
                        onCreateCustom: _openCreateCustomFood,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.onAdd, required this.onDelete, required this.onCreateCustom});
  final ValueChanged<FoodItem> onAdd;
  final ValueChanged<FoodItem> onDelete;
  final VoidCallback onCreateCustom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(foodSearchResultsProvider);
    final theme = Theme.of(context);

    return resultsAsync.when(
      data: (results) {
        if (results.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Mascot(pose: MascotPose.sleepy, size: 96),
                const SizedBox(height: AppSpacing.lg),
                Text('No foods found', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: onCreateCustom,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Custom Food'),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          itemCount: results.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final food = results[index];
            return FoodListTile(
              food: food,
              onAdd: () => onAdd(food),
              onDelete: food.isCustom ? () => onDelete(food) : null,
            );
          },
        );
      },
      loading: () => const AppLoadingIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RecentFoods extends ConsumerWidget {
  const _RecentFoods({required this.onAdd, required this.onDelete, required this.onCreateCustom});
  final ValueChanged<FoodItem> onAdd;
  final ValueChanged<FoodItem> onDelete;
  final VoidCallback onCreateCustom;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentFoodsProvider);
    final theme = Theme.of(context);

    return recentAsync.when(
      data: (recent) {
        if (recent.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Start typing to search for food', style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppSpacing.md),
                TextButton.icon(
                  onPressed: onCreateCustom,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('Create Custom Food'),
                ),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Recent', style: theme.textTheme.headlineMedium),
                TextButton.icon(
                  onPressed: onCreateCustom,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Create Custom Food'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ...recent.map(
              (food) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: FoodListTile(
                  food: food,
                  onAdd: () => onAdd(food),
                  onDelete: food.isCustom ? () => onDelete(food) : null,
                ),
              ),
            ),
          ],
        );
      },
      loading: () => const AppLoadingIndicator(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
