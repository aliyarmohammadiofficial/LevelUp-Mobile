# LevelUp — Flutter Project

Personal health companion app. Premium UI/UX derived from the supplied
Logo and App Preview assets.

## ⚠️ Current status: Core features wired to real persistence

- ✅ Full folder structure (Clean Architecture, feature-first) for all 15
  planned features
- ✅ Design system extracted from the logo/preview: colors, typography,
  spacing, radius, shadows, motion — see `lib/core/theme/`
- ✅ Auth, fully built end-to-end: Supabase-backed, real accounts.
- ✅ Onboarding, fully built: 5-step flow with local persistence via Hive.
- ✅ Fasting, Water, Nutrition, Workout, Progress — **now backed by real
  Hive persistence**, not mock data. Sessions, logs, and history survive
  an app restart. Routine/exercise templates and the food catalog are
  still a static seeded reference set (no "create your own" builder or
  real food database yet) but every user action against them — sets
  logged, food entries, cups of water, fasts started/ended, weight
  entries — is written to disk.
- ✅ Dashboard, fully built and **now a real aggregator**: pulls today's
  live fasting status, workout completion, and calorie/meal state from
  the Fasting/Workout/Nutrition datasources instead of fixed mock
  numbers. Ticks the fasting countdown every second and re-aggregates
  from disk once a minute.
- ✅ Progress now has a working "Log Weight" action (FAB on the Progress
  screen) and a full "Update Measurements" screen (Neck, Shoulders,
  Chest, Waist, Hips, Bicep, Thigh, Calf — grouped by body region, cm/in
  toggle, partial entries supported, prefilled from the last log). Body
  measurements are real Hive-backed history now: the Body tab shows an
  empty state until the first entry, then each site's latest value and
  change since the previous reading. BMI and starting weight still fall
  back to the user's onboarding answers until a manual weight entry
  exists.
- ⛔ Challenges, Community, Subscription — **folders exist, no code, not
  wired into navigation**. Water/Fasting/Progress/Goals mentioned as
  placeholders in an earlier version of this README are now real; this
  file had fallen out of date with the code. Notifications was another
  case of this: the previous version of this README called it
  mock-backed, but the actual code already had real OS pushes, event
  recording, and a live in-app feed wired end-to-end — only the streak-
  milestone achievement was genuinely missing (added this pass).
- ✅ Notifications, fully wired: real OS-level pushes via
  `PushNotificationService` (`flutter_local_notifications`) for Reminders
  (daily/weekly/every-N-hours schedules) and for real app events (water
  goal met, workout/routine completed, fast completed, level up,
  streak milestones at 3/7/14/30/50/100/200/365 days). Every fired event
  notification is mirrored into a Hive-backed in-app feed
  (`NotificationsLocalDataSource`) that the Notifications screen reads
  live — swipe to dismiss, mark-(all)-as-read, unread badge on the
  Dashboard/Profile bell. One documented, unavoidable gap: a *scheduled
  reminder* fires at the OS level even when the app isn't running, so it
  can only be mirrored into the in-app feed retroactively if the user
  taps it (see `PushNotificationService`'s doc comment) — a
  fired-but-never-tapped reminder shows in the OS shade but not in-app.
  The `social` notification category exists for Community activity but
  has nothing to trigger it yet since Community itself is unbuilt.

Persistence pattern: every local datasource follows the same plain
Hive-map approach as the original Onboarding datasource (no generated
TypeAdapters) — keyed boxes per feature, opened lazily on first use.

Everything here was written by hand and checked for balanced
braces/parens and valid relative imports, but **not yet compiled** — I
don't have a Flutter SDK in my sandbox. Run the steps below locally before
building on top of it.

## Setup

```bash
flutter pub get

# Generate code (Freezed/JSON/Hive models) once any exist:
dart run build_runner build --delete-conflicting-outputs

# Run with your Supabase project:
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Without `SUPABASE_URL` / `SUPABASE_ANON_KEY`, the app still launches (so
you can see the Welcome/Login/Signup UI), but any auth call will fail —
you'll see a debug log line saying so.

### Supabase project requirements

- Enable Email/Password auth in Supabase Auth settings.
- Enable Google and Apple OAuth providers if you want social login to
  work (the buttons call `signInWithOAuth` for both).
- Set the redirect URL `io.levelup.app://login-callback` in both your
  Supabase provider config and your app's iOS/Android deep-link setup.

## First thing to check after `pub get`

```bash
flutter analyze
```

I'd expect this to surface a handful of minor issues I couldn't catch by
eye (unused imports, `withValues` API availability on your Flutter
version, etc.) — nothing structural, but worth a look before you build on
top of it.

## Next build phase

Good next targets: a real food database behind Nutrition's search
(currently a ~15-item static catalog), or Challenges/Community/
Subscription, which are still empty folders with zero code.

## Platform scaffolding (added by standardization pass)

This zip originally contained only `lib/`, `assets/`, `test/`, and `pubspec.yaml` —
no `android/`, `ios/`, or `web/` runner folders, so it couldn't be run directly.
The following was added to make it a standard, runnable Flutter project:

- **android/** — full Gradle project (Kotlin `MainActivity`, manifest, launcher
  icons generated from `assets/images/logo.png`, `build.gradle`, wrapper config).
  Application ID: `com.bigblackcat.levelup`.
- **ios/** — `Runner` target source (`AppDelegate.swift`, `Info.plist`, `Podfile`,
  `Assets.xcassets` with app icons + launch image generated from the same logo).
- **web/** — `index.html`, `manifest.json`, and icons generated from the logo.
- **.gitignore** and **.metadata** — standard Flutter project files.

### ⚠️ What still needs a real Flutter/Xcode toolchain (couldn't be hand-generated safely)

A few files are normally auto-generated by `flutter create` or by Xcode itself and
are fragile to hand-write, so they're **not** included — running the commands below
once, on a machine with Flutter installed, will generate them automatically:

```bash
flutter create --org com.bigblackcat --project-name levelup --platforms android,ios,web .
```

Run this **in the project root** — Flutter will detect the existing `lib/`,
`pubspec.yaml`, `android/`, `ios/`, and `web/` folders and only fill in what's
missing (primarily `ios/Runner.xcodeproj/project.pbxproj`,
`ios/Runner.xcworkspace`, and `ios/Flutter/Generated.xcconfig` — the Xcode
project file format is not safe to hand-author). It will not overwrite your
existing Dart code.

Then:

```bash
cp android/local.properties.example android/local.properties
# edit android/local.properties with your actual Android SDK / Flutter SDK paths

flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```
