import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nesty_admin/app/app.dart';
import 'package:nesty_admin/core/dependency_injection/app_env.dart';
import 'package:nesty_admin/core/dependency_injection/di.dart';
import 'package:nesty_admin/core/router/app_router.dart';

/// Debug builds can opt into all-fake services with
/// `--dart-define=NESTY_FAKE_SERVICES=true` (CLAUDE.md rule 4); that is the
/// only way to sign in before M5. Ignored in profile/release so a stray
/// define can never ship fakes over real services.
const _useFakeServices = bool.fromEnvironment('NESTY_FAKE_SERVICES');

/// Shared startup for every flavor. `lib/main_<flavor>.dart` sets
/// `FlavorConfig` first, then calls this.
///
/// Web only: no orientation lock, and the default hash URL strategy
/// (`/#/levels`), which works on any static host without rewrite rules.
void bootstrap() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // TODO(M5): Firebase goes here, before DI:
      //   await Firebase.initializeApp(
      //     options: DefaultFirebaseOptions.currentPlatform,
      //   );
      // importing `firebase_options_<flavor>.dart` chosen by the flavor
      // entry point. Those files are produced by the owner with
      // `flutterfire configure` — never hand-write them. Then point dev at
      // the emulators (firebase/firebase.json) and let FirebaseAuthService
      // restore the persisted session before runApp (see AuthService).

      await configureDependencies(
        environment: kDebugMode && _useFakeServices ? AppEnv.fake : AppEnv.real,
      );

      runApp(App(router: get<AppRouter>()));
    },
    (error, stackTrace) {
      developer.log(
        'Uncaught error',
        name: 'nesty_admin.bootstrap',
        error: error,
        stackTrace: stackTrace,
      );
      // developer.log only reaches DevTools (and is a no-op in release), and
      // this handler replaces the root zone's "Unhandled Exception" print.
      // reportError prints to the `flutter run` terminal / browser console.
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'nesty_admin bootstrap',
        ),
      );
    },
  );
}
