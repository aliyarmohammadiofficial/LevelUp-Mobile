import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/onboarding_local_datasource.dart';
import '../../data/repositories/onboarding_repository_impl.dart';
import '../../domain/entities/onboarding_answers.dart';
import '../../domain/repositories/onboarding_repository.dart';

final onboardingLocalDataSourceProvider = Provider((ref) => OnboardingLocalDataSource());

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(ref.watch(onboardingLocalDataSourceProvider));
});

/// The user's real saved onboarding answers (sex, goal weight, height,
/// activity level, ...) — consumed by the Profile tab's Personal
/// Information and Goals screens. Null if onboarding hasn't been
/// completed on this device yet.
final savedOnboardingAnswersProvider = FutureProvider<OnboardingAnswers?>((ref) {
  return ref.watch(onboardingRepositoryProvider).loadSavedAnswers();
});
