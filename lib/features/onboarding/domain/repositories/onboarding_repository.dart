import '../../../../core/utils/result.dart';
import '../entities/onboarding_answers.dart';

/// Persists the completed onboarding profile. The real implementation
/// writes to the user's Supabase profile row; until that table/schema is
/// defined, [OnboardingRepositoryImpl] persists locally via Hive so the
/// flow is fully functional and the answers survive app restarts.
abstract class OnboardingRepository {
  Future<Result<void>> completeOnboarding(OnboardingAnswers answers);
  Future<bool> hasCompletedOnboarding();

  /// The persisted answers, if onboarding has been completed on this
  /// device — read by the Profile tab's Personal Information / Goals
  /// screens so they show the user's real data instead of placeholders.
  Future<OnboardingAnswers?> loadSavedAnswers();
}
