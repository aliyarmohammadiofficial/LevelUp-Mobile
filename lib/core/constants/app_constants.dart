abstract class AppConstants {
  AppConstants._();

  static const String appName = 'LevelUp';
  static const String tagline = 'Level up your health.\nOne day at a time.';

  static const int minPasswordLength = 8;

  static const Duration splashMinDuration = Duration(milliseconds: 900);
  static const Duration toastDuration = Duration(seconds: 3);

  // ---------------------------------------------------------------------
  // App identity / credits — surfaced on the About screen (Profile tab).
  // ---------------------------------------------------------------------
  static const String appVersion = '0.1.0';
  static const String buildNumber = '1';
  static const String developerName = 'Ali Yarmohammadi';
  static const String developerSite = 'forteenclub.ir';
  static const String supportEmail = 'support@levelup.app';
  static const String copyrightNotice =
      '© 2026 Ali Yarmohammadi. All rights reserved.';
}

abstract class AssetPaths {
  AssetPaths._();

  static const String logo = 'assets/images/logo.png';
  static const String mascotBase = 'assets/illustrations/mascot_wave.svg';
  static const String mascotCelebrate = 'assets/illustrations/mascot_celebrate.svg';
  static const String mascotSad = 'assets/illustrations/mascot_sad.svg';
  static const String emptyState = 'assets/illustrations/empty_state.svg';

  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String successAnimation = 'assets/animations/success.json';
  static const String confettiAnimation = 'assets/animations/confetti.json';
}
