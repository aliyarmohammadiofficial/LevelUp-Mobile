import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/fasting/presentation/screens/fasting_screen.dart';
import '../../features/water/presentation/screens/water_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/nutrition/domain/entities/nutrition_entities.dart';
import '../../features/nutrition/presentation/screens/add_food_screen.dart';
import '../../features/nutrition/presentation/screens/nutrition_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/profile/presentation/screens/about_screen.dart';
import '../../features/profile/presentation/screens/goals_screen.dart';
import '../../features/profile/presentation/screens/help_support_screen.dart';
import '../../features/profile/presentation/screens/personal_information_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/reminders_screen.dart';
import '../../features/progress/presentation/screens/body_measurements_screen.dart';
import '../../features/progress/presentation/screens/progress_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/workout/presentation/screens/active_set_screen.dart';
import '../../features/workout/presentation/screens/exercise_detail_screen.dart';
import '../../features/workout/presentation/screens/workout_detail_screen.dart';
import '../../features/workout/presentation/screens/workout_screen.dart';
import '../widgets/app_shell.dart';
import '../widgets/quick_add_sheet.dart';

/// Route paths as constants to avoid magic strings scattered across screens.
abstract class AppRoutes {
  AppRoutes._();
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const onboarding = '/onboarding';
  static const dashboard = '/dashboard';
  static const plan = '/plan';
  static const workout = '/workout';
  static const nutrition = '/nutrition';
  static const fasting = '/fasting';
  static const water = '/water';
  static const progress = '/progress';
  static const bodyMeasurements = '/progress/measurements';
  static const profile = '/profile';
  static const settings = '/settings';
  static const notifications = '/notifications';

  /// The five bottom-nav destinations, in tab order (index 2 is the
  /// floating "+" action, which navigates contextually rather than
  /// holding a tab of its own — see [AppShell.onQuickAdd]).
  static const List<String?> shellTabs = [dashboard, plan, null, progress, profile];
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.welcome,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final isLoggedIn = authState.asData?.value != null;
      final loggingInPaths = {
        AppRoutes.welcome,
        AppRoutes.login,
        AppRoutes.signup,
        AppRoutes.forgotPassword,
      };
      final isOnAuthScreen = loggingInPaths.contains(state.matchedLocation);

      // Still resolving the initial auth check — don't redirect yet.
      if (authState.isLoading) return null;

      if (!isLoggedIn && !isOnAuthScreen) return AppRoutes.welcome;
      if (isLoggedIn && isOnAuthScreen) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(path: AppRoutes.welcome, builder: (context, state) => const WelcomeScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (context, state) => const SignUpScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingFlowScreen(),
      ),

      // Main tabbed area. Each of the five bottom-nav destinations is a
      // top-level route (so it's independently deep-linkable) wrapped in
      // the shared [AppShell] chrome.
      ShellRoute(
        builder: (context, state, child) {
          final currentIndex = AppRoutes.shellTabs.indexOf(state.matchedLocation);
          return AppShell(
            currentIndex: currentIndex == -1 ? 0 : currentIndex,
            onTabSelected: (index) {
              final path = AppRoutes.shellTabs[index];
              if (path != null) context.go(path);
            },
            onQuickAdd: () => QuickAddSheet.show(context, [
              QuickAddAction(
                icon: Icons.restaurant_rounded,
                label: 'Log Meal',
                onTap: () => context.push('${AppRoutes.nutrition}/add-food?meal=snack'),
              ),
              QuickAddAction(
                icon: Icons.local_drink_rounded,
                label: 'Log Water',
                color: const Color(0xFF3BA7F0),
                onTap: () => context.push(AppRoutes.water),
              ),
              QuickAddAction(
                icon: Icons.fitness_center_rounded,
                label: 'Start Workout',
                onTap: () => context.push(AppRoutes.workout),
              ),
              QuickAddAction(
                icon: Icons.timer_rounded,
                label: 'Start Fast',
                onTap: () => context.push(AppRoutes.fasting),
              ),
            ]),
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.plan,
            builder: (context, state) => const WorkoutScreen(),
          ),
          GoRoute(
            path: AppRoutes.progress,
            builder: (context, state) => const ProgressScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Profile sub-pages — pushed on top of the shell (bottom nav stays
      // hidden while browsing these, same as the Workout sub-routes above).
      GoRoute(
        path: '${AppRoutes.profile}/personal-information',
        builder: (context, state) => const PersonalInformationScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.profile}/goals',
        builder: (context, state) => const GoalsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.profile}/reminders',
        builder: (context, state) => const RemindersScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.profile}/help-support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.profile}/about',
        builder: (context, state) => const AboutScreen(),
      ),

      // Settings — reached from the Profile menu.
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.settings}/privacy-policy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // Workout and its sub-routes (routine detail, exercise detail, active
      // set) — pushed on top of the shell rather than living inside it, so
      // the bottom nav bar stays hidden while a workout is in progress.
      // Also reachable directly from the Dashboard's Workout stat card.
      GoRoute(
        path: AppRoutes.workout,
        builder: (context, state) => const WorkoutScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.workout}/:routineId',
        builder: (context, state) => WorkoutDetailScreen(
          routineId: state.pathParameters['routineId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.workout}/:routineId/:exerciseId',
        builder: (context, state) => ExerciseDetailScreen(
          routineId: state.pathParameters['routineId']!,
          exerciseId: state.pathParameters['exerciseId']!,
        ),
      ),
      GoRoute(
        path: '${AppRoutes.workout}/:routineId/:exerciseId/set',
        builder: (context, state) => ActiveSetScreen(
          routineId: state.pathParameters['routineId']!,
          exerciseId: state.pathParameters['exerciseId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.nutrition,
        builder: (context, state) => const NutritionScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.nutrition}/add-food',
        builder: (context, state) {
          final mealParam = state.uri.queryParameters['meal'];
          final meal = MealType.values.firstWhere(
            (m) => m.name == mealParam,
            orElse: () => MealType.snack,
          );
          return AddFoodScreen(meal: meal);
        },
      ),
      GoRoute(
        path: AppRoutes.fasting,
        builder: (context, state) => const FastingScreen(),
      ),
      GoRoute(
        path: AppRoutes.water,
        builder: (context, state) => const WaterScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.bodyMeasurements,
        builder: (context, state) => const BodyMeasurementsScreen(),
      ),
    ],
  );
});
