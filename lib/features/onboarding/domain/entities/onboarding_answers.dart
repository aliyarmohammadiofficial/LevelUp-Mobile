import 'package:equatable/equatable.dart';

enum FitnessGoal { loseWeight, buildMuscle, maintain, improveEndurance }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum BiologicalSex { female, male, preferNotToSay }

extension FitnessGoalLabel on FitnessGoal {
  String get label => switch (this) {
        FitnessGoal.loseWeight => 'Lose Weight',
        FitnessGoal.buildMuscle => 'Build Muscle',
        FitnessGoal.maintain => 'Maintain Weight',
        FitnessGoal.improveEndurance => 'Improve Endurance',
      };
}

extension ActivityLevelLabel on ActivityLevel {
  String get label => switch (this) {
        ActivityLevel.sedentary => 'Sedentary',
        ActivityLevel.light => 'Lightly Active',
        ActivityLevel.moderate => 'Moderately Active',
        ActivityLevel.active => 'Very Active',
        ActivityLevel.veryActive => 'Extremely Active',
      };
}

extension BiologicalSexLabel on BiologicalSex {
  String get label => switch (this) {
        BiologicalSex.female => 'Female',
        BiologicalSex.male => 'Male',
        BiologicalSex.preferNotToSay => 'Prefer not to say',
      };
}

/// Everything collected across the Onboarding steps. Built up incrementally
/// by [OnboardingController] as the user answers each screen, then
/// submitted as one profile write at the end.
class OnboardingAnswers extends Equatable {
  const OnboardingAnswers({
    this.sex,
    this.goal,
    this.currentWeightKg,
    this.targetWeightKg,
    this.heightCm,
    this.activityLevel,
    this.workoutDaysPerWeek = 3,
    this.dailyWaterCupsGoal = 8,
  });

  final BiologicalSex? sex;
  final FitnessGoal? goal;
  final double? currentWeightKg;
  final double? targetWeightKg;
  final double? heightCm;
  final ActivityLevel? activityLevel;
  final int workoutDaysPerWeek;
  final int dailyWaterCupsGoal;

  bool get hasWeightGoal =>
      goal == FitnessGoal.loseWeight || goal == FitnessGoal.buildMuscle;

  OnboardingAnswers copyWith({
    BiologicalSex? sex,
    FitnessGoal? goal,
    double? currentWeightKg,
    double? targetWeightKg,
    double? heightCm,
    ActivityLevel? activityLevel,
    int? workoutDaysPerWeek,
    int? dailyWaterCupsGoal,
  }) {
    return OnboardingAnswers(
      sex: sex ?? this.sex,
      goal: goal ?? this.goal,
      currentWeightKg: currentWeightKg ?? this.currentWeightKg,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
      heightCm: heightCm ?? this.heightCm,
      activityLevel: activityLevel ?? this.activityLevel,
      workoutDaysPerWeek: workoutDaysPerWeek ?? this.workoutDaysPerWeek,
      dailyWaterCupsGoal: dailyWaterCupsGoal ?? this.dailyWaterCupsGoal,
    );
  }

  @override
  List<Object?> get props => [
        sex,
        goal,
        currentWeightKg,
        targetWeightKg,
        heightCm,
        activityLevel,
        workoutDaysPerWeek,
        dailyWaterCupsGoal,
      ];
}
