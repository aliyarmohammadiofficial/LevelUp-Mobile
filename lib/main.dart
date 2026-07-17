import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/router/app_router.dart';
import 'core/services/push_notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'features/settings/presentation/providers/settings_providers.dart';

/// These are read from --dart-define at build time so real keys never live
/// in source control:
///   flutter run \
///     --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
///     --dart-define=SUPABASE_ANON_KEY=xxxx
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL', defaultValue: '');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  // Feature Hive boxes are opened lazily by each feature's local
  // datasource on first use, not here — keeps startup fast and keeps
  // box ownership inside the feature that needs it.

  await PushNotificationService.instance.init();
  // Permission is requested here (rather than lazily on first reminder
  // toggle) so a user who enables reminders during onboarding gets a
  // native prompt right away. If denied, scheduling calls below still
  // succeed at the OS-API level but won't visibly notify — the Reminders
  // screen should surface that via `PushNotificationService.hasPermission`.
  await PushNotificationService.instance.requestPermission();

  if (_supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(url: _supabaseUrl, anonKey: _supabaseAnonKey);
  } else {
    debugPrint(
      'LevelUp: SUPABASE_URL / SUPABASE_ANON_KEY not provided via --dart-define. '
      'Auth calls will fail until these are set.',
    );
  }

  runApp(const ProviderScope(child: LevelUpApp()));
}

class LevelUpApp extends ConsumerWidget {
  const LevelUpApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(effectiveThemeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
