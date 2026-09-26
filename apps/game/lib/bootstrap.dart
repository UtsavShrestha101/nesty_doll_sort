import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:nesty_game/app/app.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/router/app_router.dart';

/// Debug builds can opt into all-fake services with
/// `--dart-define=NESTY_FAKE_SERVICES=true` (CLAUDE.md rule 4). Ignored in
/// profile/release so a stray define can never ship fakes over real services.
const _useFakeServices = bool.fromEnvironment('NESTY_FAKE_SERVICES');

/// Shared startup for every flavor. `lib/main_<flavor>.dart` sets
/// `FlavorConfig` first, then calls this.
void bootstrap() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Portrait only (spec §0).
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

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
