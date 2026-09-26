# nesty_admin

The **Nesty: Doll Sort** admin panel: a Flutter Web app where the owner
authors, solves, simulates, playtests and publishes levels and uploads skins,
themes and museum art (spec §15). It keeps no local data. From M5 everything
lives in Firebase (Auth, Firestore, Storage). Level rules, validation, solving,
simulation and generation must come from
[`nesty_core`](../../packages/nesty_core/README.md), and the playtest board
from [`nesty_render`](../../packages/nesty_render/README.md) (CLAUDE.md
rule 2).

**Status: M0 skeleton.**
- Sign-in, the access policy, and the shell with all nine spec §15 sections
  are wired and tested.
- Every section is a localized "Coming in M5" placeholder.
- There is no real sign-in until M5 (see [Run](#run)).

See [docs/PROGRESS.md](../../docs/PROGRESS.md).

## Run

There is no `lib/main.dart`. Pick the flavor's entry point:

| Flavor | Command (from `apps/admin`) | Browser title |
|---|---|---|
| dev | `flutter run -d chrome -t lib/main_dev.dart` | `[DEV] Nesty Admin` |
| stg | `flutter run -d chrome -t lib/main_stg.dart` | `[STG] Nesty Admin` |
| prod | `flutter run -d chrome -t lib/main_prod.dart` | `Nesty Admin` |

- **Signing in before M5:** add `--dart-define=NESTY_FAKE_SERVICES=true` to
  a **debug** run. The fake auth service then accepts any non-empty email and
  password, and every user is an admin.
- **Without the define** (and in every profile or release build) the real
  environment uses `UnconfiguredAuthService`. Nobody can sign in, and the form
  shows the "can't reach the server" error. This is deliberate: a deployed
  skeleton must never let anyone in.
- **In VS Code**, "Admin [DEV] (Chrome, fake services)" in
  `.vscode/launch.json` passes the define. The dev/stg/prod admin
  configurations don't, so they stop at Login.
- Build: `flutter build web -t lib/main_prod.dart`.

## Routes

URLs use the default hash strategy (`/#/levels`), which works on any static
host without rewrite rules. Path URLs are an open question (Q7).

| URL | Page | Who sees it |
|---|---|---|
| `/#/login` | `LoginPage` | Signed out |
| `/#/not-authorized` | `NotAuthorizedPage` | Signed in, but no `admins/{uid}` document (spec §14.1) |
| `/#/` → `/#/dashboard` | `AdminShellPage` → `DashboardPage` | Admins |
| `/#/levels` | `LevelsPage` (Levels tab stack) | Admins |
| `/#/levels/:levelId` | `LevelEditorPage`, pushed inside the Levels tab | Admins |
| `/#/generator`, `/#/chapters`, `/#/skins`, `/#/themes`, `/#/museum-items`, `/#/daily-overrides`, `/#/export-bundle` | One placeholder page each | Admins |
| anything else | Redirects to `/#/` | Then decided by the guard |

## Folder structure

```text
lib/
  main_dev.dart, main_stg.dart, main_prod.dart   # set FlavorConfig, then bootstrap()
  bootstrap.dart           # error zone, DI, runApp (no orientation lock on web)
  app/
    app.dart               # MaterialApp.router; re-enters the router root on every session change
    session_cubit/         # SessionCubit (app lifetime): who is signed in
  core/
    base/                  # AsyncValue<T>, BaseAsyncCubit<T>, BaseAsyncBloc<E, S>, runGuarded
    common_imports.dart    # barrel for the common imports
    dependency_injection/  # di.dart (`get`), app_env.dart, di.config.dart (generated)
    error/                 # AppException + the admin's AppExceptionKind
    extensions/            # context.localizations, AppException -> localized message
    flavor/                # Flavor, FlavorConfig, FlavorValues
    models/                # AdminUser (freezed)
    router/                # AppRouter, AuthGuard, app_router.gr.dart (generated)
    services/auth/         # AuthService + fake + unconfigured (real env until M5)
    ui/                    # placeholder colors, theme, PlaceholderView (TODO(design))
  features/
    login/         {cubit, pages, widgets}
    not_authorized/{pages}
    shell/         {pages}             # NavigationRail + AutoTabsRouter
    dashboard/, levels/, generator/, chapters/, skins/, themes/,
    museum_items/, daily_overrides/, export_bundle/   {pages}
  l10n/                    # app_en.arb + generated AppLocalizations
test/
  app/, core/              # mirror lib/app and lib/core
  features/<name>/         # flat: <name>_cubit_test.dart
  app_flow_test.dart       # sign-in, access policy, deep links, tabs
  helpers/                 # test_dependencies.dart wires the fake env
web/                       # index.html, manifest.json, icons
```

New features go in `features/<name>/{cubit,pages,widgets,model}`. The
`/feature` skill scaffolds one.

## How it fits together

- **Shared layer.** `core/base`, `AppException`, flavor, DI and bootstrap
  follow the same pattern as `apps/game` (see its
  [README](../game/README.md#how-it-fits-together)). The copies are
  intentional for now; whether to extract a shared package is Q8. The admin's
  error kinds are `invalidCredentials`, `network`, `content`, `cancelled` and
  `unknown`. `AppExceptionL10n.localizedMessage` maps each kind to an ARB
  string, and `message` is never shown to users.
- **Access policy lives only in `AuthGuard`.**
  - The guard sits on the three top-level routes, and each session state has
    exactly one route it may see:
    - signed out → Login;
    - signed in, not an admin → Not authorized;
    - admin → the shell.
  - Any other navigation is replaced with the allowed route. This covers
    bookmarks and typed URLs, so a signed-out `/#/levels/L0024` lands on
    Login.
  - Pages never navigate after sign-in or sign-out. `App` listens to
    `SessionCubit` and re-enters the router root, and the guard decides
    again.
  - After the first sign-in the admin lands on the Dashboard, not the link
    that was first requested (Q6).
- **Auth.**
  - `AuthService` exposes `currentUser` (synchronous, for the guard),
    `userChanges`, `signIn`, `signOut` and `dispose`.
  - `FakeAuthService` serves only the `fake` environment.
  - `UnconfiguredAuthService` serves `real` until M5 replaces it with
    `FirebaseAuthService`; callers don't change.
  - `AdminUser.isAdmin` defaults to `false`, so nobody is an admin by
    accident.
- **Login.** `LoginCubit` is a `BaseAsyncCubit<AdminUser>`. It ignores a
  second submit while one is in flight, trims the email but never the
  password, and neither navigates nor decides access.
- **Shell.** One `NavigationRail` (scrollable, with sign-out at the bottom)
  drives an `AutoTabsRouter` with the nine spec §15 sections, in spec order.
  The Level editor is not a tab; it is pushed inside the Levels stack
  (`levelsTab`). There is no narrow-window layout yet (`TODO(design)`).
- **l10n.** `lib/l10n/app_en.arb` is the source of truth, and every key has
  a description. Read strings with `context.localizations.key`. The admin is
  English-only and has no locale switcher or text-scale clamp.
- **Game rules.** None live here. Each §15 page's doc comment holds its M5
  scope as a `TODO(M5)`. The pages that validate, solve, simulate, generate
  or export (Level editor, Generator, Export bundle) name the `nesty_core`
  API they must call.

## Code generation

```bash
flutter gen-l10n            # after editing lib/l10n/app_en.arb
dart run build_runner build # freezed, injectable, auto_route
```

Run gen-l10n first. Commit the generated files and never edit them by hand;
CI fails on drift. `flutter analyze` skips generated files, so only compiling
(tests or a build) shows errors in them.

## Tests

```bash
flutter test
```

- **What is covered** (8 files, 47 tests): the base cubit and bloc
  (including event order), both auth services, DI in both environments,
  `SessionCubit`, `LoginCubit`, and the app flows:
  - sign in as an admin → Dashboard;
  - sign in as a non-admin → Not authorized, then sign out;
  - signed-out and signed-in deep links, and unknown URLs;
  - form validation and rejected credentials;
  - switching tabs, and opening `/levels/L0024` in the editor.
- **Wiring:** tests use the fake environment through
  `test/helpers/test_dependencies.dart` (`configureTestDependencies()`,
  `resetDependencies()` and `fakeAuth` to set `isAdmin` or
  `failSignInWith`).
- **Viewport:** flow tests use a 1440×900 viewport, the size the design
  brief targets.
- **Log noise:** in debug, `runGuarded` prints every failure it catches, so
  the tests of expected errors (such as rejected credentials) print a few
  lines. They still pass.

## Web

- `web/index.html` and `web/manifest.json` carry the Nesty Admin title and
  description.
- The manifest still has the template's `portrait-primary` orientation and
  `#0175C2` colors (Q21).
- Hosting and the Firebase config (`flutterfire configure`, run by the owner)
  arrive in M5.
