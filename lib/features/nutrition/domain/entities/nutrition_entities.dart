import 'package:equatable/equatable.dart';

/// Which meal slot a [FoodEntry] belongs to — mirrors
/// `MealType` on the Dashboard's [MealSlot] so the two features read
/// consistently, but kept local (not imported) since Nutrition owns this
/// concept and Dashboard only borrows a summary of it.
enum MealType { breakfast, lunch, dinner, snack }

extension MealTypeLabel on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Breakfast',
        MealType.lunch => 'Lunch',
        MealType.dinner => 'Dinner',
        MealType.snack => 'Snack',
      };
}

/// A food item as it appears in search results / the food database, before
/// it's logged against a specific meal. Quantities here are "per serving"
/// defaults; [FoodEntry] carries the actual logged amount.
class FoodItem extends Equatable {
  const FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPerServing,
    required this.servingLabel,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.isRecent = false,
  });

  final String id;
  final String name; // "Grilled Chicken Breast"
  final int caloriesPerServing;
  final String servingLabel; // "100g", "1 cup"
  final double proteinG;
  final double carbsG;
  final double fatG;
  final bool isRecent;

  /// Whether this food was added by the user via "Create Custom Food"
  /// rather than shipped in the built-in catalog. Drives the delete
  /// affordance shown on custom entries in Add Food.
  bool get isCustom => id.startsWith('custom-food-');

  @override
  List<Object?> get props =>
      [id, name, caloriesPerServing, servingLabel, proteinG, carbsG, fatG, isRecent];
}

/// One logged ingredient/food line within a meal (e.g. "Grilled Chicken —
/// 150g — 250 kcal" inside today's Lunch). Distinct from [FoodItem] because
/// a food can be logged at a different quantity than its base serving.
class FoodEntry extends Equatable {
  const FoodEntry({
    required this.id,
    required this.foodName,
    required this.quantityLabel,
    required this.calories,
  });

  final String id;
  final String foodName; // "Grilled Chicken"
  final String quantityLabel; // "150g"
  final int calories;

  @override
  List<Object?> get props => [id, foodName, quantityLabel, calories];
}

/// A single meal slot for a given day, holding zero or more [FoodEntry]
/// lines — matches "Breakfast / Oatmeal with Berries — 320 kcal ✓" rows on
/// the reference Nutrition Plan and Today screens.
class MealLog extends Equatable {
  const MealLog({
    required this.type,
    required this.entries,
    required this.targetCalories,
  });

  final MealType type;
  final List<FoodEntry> entries;
  final int targetCalories; // planned budget for this slot, e.g. 400 kcal

  int get loggedCalories => entries.fold(0, (sum, e) => sum + e.calories);
  bool get isLogged => entries.isNotEmpty;

  MealLog copyWith({List<FoodEntry>? entries}) {
    return MealLog(
      type: type,
      entries: entries ?? this.entries,
      targetCalories: targetCalories,
    );
  }

  @override
  List<Object?> get props => [type, entries, targetCalories];
}

/// Daily macro targets in grams — matches the "Macro Targets: Protein
/// 150g / Carbs 220g / Fat 70g" block on the reference Nutrition Plan
/// screen.
class MacroTargets extends Equatable {
  const MacroTargets({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final int proteinG;
  final int carbsG;
  final int fatG;

  @override
  List<Object?> get props => [proteinG, carbsG, fatG];
}

/// Macro grams actually consumed so far today, paired against
/// [MacroTargets] to drive the three progress bars/rings on Today and
/// Insights.
class MacroProgress extends Equatable {
  const MacroProgress({
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double proteinG;
  final double carbsG;
  final double fatG;

  @override
  List<Object?> get props => [proteinG, carbsG, fatG];
}

/// Full snapshot for the Nutrition "Today" tab: calorie ring, macro bars,
/// and the day's meals — matches the reference "Nutrition / Today" screen.
class NutritionDay extends Equatable {
  const NutritionDay({
    required this.date,
    required this.calorieGoal,
    required this.macroTargets,
    required this.macroProgress,
    required this.meals,
  });

  final DateTime date;
  final int calorieGoal;
  final MacroTargets macroTargets;
  final MacroProgress macroProgress;
  final List<MealLog> meals;

  int get caloriesLogged => meals.fold(0, (sum, m) => sum + m.loggedCalories);
  double get calorieProgress =>
      calorieGoal == 0 ? 0 : (caloriesLogged / calorieGoal).clamp(0, 1);
  int get caloriesRemaining => (calorieGoal - caloriesLogged).clamp(0, calorieGoal);

  NutritionDay copyWith({List<MealLog>? meals, MacroProgress? macroProgress}) {
    return NutritionDay(
      date: date,
      calorieGoal: calorieGoal,
      macroTargets: macroTargets,
      macroProgress: macroProgress ?? this.macroProgress,
      meals: meals ?? this.meals,
    );
  }

  @override
  List<Object?> get props =>
      [date, calorieGoal, macroTargets, macroProgress, meals];
}

/// One point in the weekly calorie-intake history shown on the Insights
/// tab (mirrors the bar-chart shape used on Progress/Insights elsewhere in
/// the app).
class NutritionHistoryPoint extends Equatable {
  const NutritionHistoryPoint({
    required this.date,
    required this.caloriesConsumed,
    required this.calorieGoal,
  });

  final DateTime date;
  final int caloriesConsumed;
  final int calorieGoal;

  @override
  List<Object?> get props => [date, caloriesConsumed, calorieGoal];
}

/// Aggregate weekly stats surfaced at the top of the Insights tab (average
/// intake, best day, current logging streak) — same "Average / Best Day /
/// Streak" pattern as the Progress screen's weight card.
class NutritionInsights extends Equatable {
  const NutritionInsights({
    required this.history,
    required this.averageCalories,
    required this.bestDayCalories,
    required this.loggingStreakDays,
  });

  final List<NutritionHistoryPoint> history;
  final int averageCalories;
  final int bestDayCalories;
  final int loggingStreakDays;

  @override
  List<Object?> get props =>
      [history, averageCalories, bestDayCalories, loggingStreakDays];
}
