import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/home_widget/home_widget_bridge.dart';
import 'package:nesty_game/core/services/reminder/daily_reminder.dart';
import 'package:nesty_game/core/services/save/save_lifecycle_flusher.dart';
import 'package:nesty_game/core/services/welcome_back/welcome_back_tracker.dart';

/// Debug builds can opt into all-fake services with
/// `--dart-define=NESTY_FAKE_SERVICES=true` (CLAUDE.md rule 4). Ignored in
/// profile/release so a stray define can never ship fakes over real services.
const _useFakeServices = bool.fromEnvironment('NESTY_FAKE_SERVICES');

/// Shared startup for every flavor. `lib/main_<flavor>.dart` sets
/// `FlavorConfig` first, then calls this.
///
/// [beforeRunApp] is a test seam: it runs after DI is configured and before
/// `runApp`, so a fault scenario can re-register a service (GetIt's
/// `allowReassignment`) without a fault flag in app code. No caller in
/// `lib/` passes it.
void bootstrap({@visibleForTesting Future<void> Function()? beforeRunApp}) {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Portrait only (spec §0).
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      _registerFontLicenses();

      // TODO(M4): Firebase + Crashlytics go here, before DI:
      //   await Firebase.initializeApp(
      //     options: DefaultFirebaseOptions.currentPlatform,
      //   );
      // importing `firebase_options_<flavor>.dart` chosen by the flavor
      // entry point. Those files are produced by the owner with
      // `flutterfire configure` — never hand-write them. Firebase init must
      // fail silently offline (CLAUDE.md rule 3): wrap it and continue.

      // Registers every service and — via DatabaseModule's @preResolve —
      // initialises Hive and opens every box exactly once. If Hive can't
      // open, it logs and falls back to in-memory settings rather than
      // blocking startup (see HiveDatabaseService.openOrFallback).
      await configureDependencies(
        environment: kDebugMode && _useFakeServices ? AppEnv.fake : AppEnv.real,
      );

      // Flushes the save on `paused`/`detached` (m3-design §3.2). Started
      // here, not resolved lazily on first use, so it is listening before
      // the app can ever go to the background.
      get<SaveLifecycleFlusher>().start();

      // The opt-in daily reminder (E4; m7-design P3.10) follows its
      // settings from here: it re-syncs the OS schedule on resume and on a
      // settings or language change. It never asks for the permission and
      // never schedules on a fresh install (the reminder is off).
      get<DailyReminder>().start();

      // Welcome back (local habit 1): notes the open before Home's first
      // frame, so the gap is read before anything overwrites lastOpenDate.
      get<WelcomeBackTracker>().start();

      await beforeRunApp?.call();

      // The home-screen widget's snapshot (local habit 4): written now, on
      // each resume, when the daily changes and when the language does. It
      // never throws and nothing waits on it. Started after the test seam:
      // the bridge holds the LevelResolver, which takes the generator, so
      // resolving it first kept faults_test's generator from ever being
      // used (D314).
      get<HomeWidgetBridge>().start();

      runApp(App(router: get<AppRouter>()));
    },
    (error, stackTrace) {
      // TODO(M4): FirebaseCrashlytics.instance.recordError(error, stackTrace).
      developer.log(
        'Uncaught error',
        name: 'nesty.bootstrap',
        error: error,
        stackTrace: stackTrace,
      );
      // developer.log only reaches DevTools (and is a no-op in release), and
      // this handler replaces the root zone's "Unhandled Exception" print.
      // reportError prints in the `flutter run` terminal and, in release, a
      // one-line summary to logcat / the device console.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'nesty bootstrap',
        ),
      );
    },
  );
}

/// The bundled fonts' licences, shown on Flutter's licence page. The OFL
/// (Fredoka, Nunito, Baloo 2, M PLUS Rounded 1c) and Apache 2.0 (Material
/// Symbols) both require shipping the licence text with the font; the files
/// come from the pinned upstream commits in tools/fonts/build_fonts.sh
/// (M PLUS Rounded 1c's is composed there from its METADATA.pb copyright and
/// the M+ family's OFL text, as its folder ships none).
const _fontLicenses = <(List<String>, String, String?)>[
  (['Fredoka'], 'assets/fonts/Fredoka-OFL.txt', null),
  (['Nunito'], 'assets/fonts/Nunito-OFL.txt', null),
  (
    ['Baloo 2'],
    'assets/fonts/Baloo2-OFL.txt',
    'Modified: the app ships Devanagari subsets of static instances of '
        'Baloo 2, renamed Baloo 2 Display and Baloo 2 Body, made with '
        'tools/fonts/build_fonts.sh.',
  ),
  (
    ['M PLUS Rounded 1c'],
    'assets/fonts/MPLUSRounded1c-OFL.txt',
    'Modified: the app ships Japanese subsets of M PLUS Rounded 1c, renamed '
        'M PLUS Rounded 1c Display and M PLUS Rounded 1c Body, made with '
        'tools/fonts/build_fonts.sh.',
  ),
  (
    ['Material Symbols Rounded'],
    'assets/fonts/MaterialSymbols-LICENSE.txt',
    // Apache 2.0 §4(b): say that the shipped file was changed.
    'Modified: the app ships NestySymbolsRounded.ttf, a glyph subset and '
        'static instance (FILL 1, wght 600, GRAD 0, opsz 24) of Material '
        'Symbols Rounded with its filled glyph variants mapped directly, made '
        'with tools/fonts/build_fonts.sh.',
  ),
];

// Lazy: the stream only runs when the licence page is opened.
void _registerFontLicenses() {
  LicenseRegistry.addLicense(() async* {
    for (final (packages, asset, notice) in _fontLicenses) {
      final text = await rootBundle.loadString(asset);
      yield LicenseEntryWithLineBreaks(
        packages,
        notice == null ? text : '$notice\n\n$text',
      );
    }
  });
}
