# nesty_doll_sort

**Nesty: Doll Sort** is a cozy, offline-first sorting puzzle for Android and
iOS. Players nest colorful wooden matryoshka dolls inside each other, from
biggest to smallest, to complete each family before they run out of space. A
doll only fits into the doll exactly one size bigger, and that size rule is
what sets it apart from ordinary color sorts. The game is built with Flutter +
Flame, and a Flutter Web admin panel backed by Firebase is used to author
levels and upload art. The full game and technical design is in
[docs/GAME_SPEC.md](docs/GAME_SPEC.md).

## Status

The pre-M1 architecture skeleton (M0) is done: workspace, base cubits, DI,
Hive, routing, flavors, l10n, fake services, CI. The design handoff is in
`design/`, and its tokens, art, sound and fonts are wired into the build by
the `nesty_tools` pipelines. M1 (core rules, solver, simulator, generator)
is done. M2 (playable game) is code complete: levels 1–30 play end to end on
the design's art and Lottie animations, and every automated check passes,
including an on-device playthrough. Its acceptance, 60 fps on a mid-range
Android device, is the owner's check on a real phone; the steps are in
[docs/PROGRESS.md](docs/PROGRESS.md) under "M2 acceptance". Milestones,
decisions and open questions are tracked there, and every remaining item in
[docs/BACKLOG.md](docs/BACKLOG.md).

## Repository layout

This is a Dart pub workspace: one `flutter pub get` at the root resolves every
member against the single root `pubspec.lock`.

```text
nesty/
  README.md
  CLAUDE.md                  # rules for Claude Code in this repo
  docs/
    GAME_SPEC.md             # game + tech spec (source of truth)
    DESIGN_BRIEF.md          # brief for the design exports
    PROGRESS.md              # milestone status, decisions, package reasons, open questions
    BACKLOG.md               # every remaining item, one section per milestone, plus owner inputs
    TODO_INDEX.md            # generated index of the TODO(<tag>) markers in code
  design/                    # design handoff (owner-managed, read-only): tokens, art, SFX, prototypes
  packages/
    nesty_core/              # pure Dart: models, rules, solver, generator, simulator, level codec
    nesty_render/            # Flutter (no Flame): doll painters, skins, layout math
  apps/
    game/                    # Flutter + Flame mobile game (Android, iOS), flavors dev/stg/prod
    admin/                   # Flutter Web admin panel
  firebase/                  # Firestore/Storage rules, indexes, emulator config
  tools/                     # nesty_tools: design token/asset/icon pipelines, fonts, TODO index
  .claude/                   # Claude Code settings, hooks, rules, agents, skills
  .github/workflows/ci.yaml  # CI: format, analyze, tests, generated-code drift, builds
  .vscode/                   # launch configs per app and flavor, extension recommendations
```

Each package has its own README: [game](apps/game/README.md),
[admin](apps/admin/README.md), [nesty_core](packages/nesty_core/README.md),
[nesty_render](packages/nesty_render/README.md), [firebase](firebase/README.md),
[tools](tools/README.md).

## Prerequisites

- **Flutter 3.41.2 on the stable channel, with Dart 3.11.** CI pins this
  version, and the committed `pubspec.lock` resolves exactly on it. A newer
  stable re-resolves a few SDK-pinned test packages, so `flutter pub get`
  would change the lock. Upgrading is a deliberate change (PROGRESS.md D15,
  Q23). Use `flutter` and `dart` from your PATH. The repo does **not** use
  FVM.
  - On the owner's machine, `flutter --version` prints `3.43.0-1.0.pre-35`.
    That SDK is 3.41.2 with one local commit on top, not a newer release.
- For Android: Android Studio or the Android SDK (compileSdk 36, minSdk 24)
  and a JDK, plus the NDK and CMake from the SDK manager (the `flutter_soloud`
  audio plugin builds native code).
- For iOS (macOS only): Xcode, CocoaPods and CMake (`brew install cmake`;
  `flutter_soloud`'s pod builds with it). The deployment target is iOS 14.
- Only to rebuild the bundled fonts (`tools/fonts/build_fonts.sh`): `python3`
  and `curl`. The script installs fontTools in a throwaway venv.
- For the admin: Chrome.
- Optional: the Firebase CLI (`npm install -g firebase-tools`, which also
  needs a JDK) for local emulators.

## Setup

```bash
flutter pub get          # at the repo root; resolves all four members
```

CI runs `flutter pub get --enforce-lockfile`, which fails instead of
changing `pubspec.lock`.

Generated code is committed, so a fresh clone runs without running codegen
first.

## Run

The game has no flavorless build. Always pass both `--flavor` and the matching
entry point:

```bash
cd apps/game
flutter run --flavor dev  -t lib/main_dev.dart     # [DEV] Nesty, com.futrix.nesty.dev
flutter run --flavor stg  -t lib/main_stg.dart     # [STG] Nesty, com.futrix.nesty.stg
flutter run --flavor prod -t lib/main_prod.dart    # Nesty, com.futrix.nesty
```

The admin runs in Chrome. Before M5 there is no real sign-in, so debug runs
use the fake auth service:

```bash
cd apps/admin
flutter run -d chrome -t lib/main_dev.dart --dart-define=NESTY_FAKE_SERVICES=true
```

`--dart-define=NESTY_FAKE_SERVICES=true` switches a **debug** build of either
app to all-fake, offline services. Profile and release builds ignore it, so
fakes can never ship over real services.

VS Code users can pick a launch configuration from `.vscode/launch.json`:
- one per app and flavor;
- "Game [DEV] (profile mode, physical device)" for performance checks;
- "Admin [DEV] (Chrome, fake services)", which passes the fake-services
  define, so you can sign in.

The other admin configurations use real services, so they stop at Login
until M5.

Release builds (each line starts from the repo root):

```bash
cd apps/game  && flutter build apk --flavor prod -t lib/main_prod.dart
cd apps/game  && flutter build ipa --flavor prod -t lib/main_prod.dart
cd apps/admin && flutter build web -t lib/main_prod.dart
```

- Android release builds still use debug signing (`TODO(M8)`).
- `flutter build ipa` needs the owner's Apple signing (PROGRESS.md Q11).
- Build iOS through `flutter`, not straight from Xcode. The Xcode build
  fails on purpose when the last `flutter` command used another flavor
  (PROGRESS.md D8).

## Code generation

Run these after changing an `.arb` file or any `@freezed`, `@injectable`,
`@RoutePage` or Hive-annotated source. Run them per app, gen-l10n first
(build_runner resolves imports of the generated localizations). Each line
starts from the repo root:

```bash
cd apps/game  && flutter gen-l10n && dart run build_runner build
cd apps/admin && flutter gen-l10n && dart run build_runner build
```

The design pipelines run from anywhere in the repo (details in
[tools/README.md](tools/README.md)). Each takes `--check`, which writes
nothing and fails on drift:

```bash
dart run nesty_tools:gen_design_tokens    # design/tokens.json → *.gen.dart token files
dart run nesty_tools:sync_design_assets   # design/ art + SFX → apps/game/assets
dart run nesty_tools:gen_nesty_icons      # NestyIcons from the bundled icon font
dart run nesty_tools:todo_index           # docs/TODO_INDEX.md from TODO(<tag>) markers
tools/fonts/build_fonts.sh [--verify]     # bundled fonts from pinned upstream (network)
```

Generated files (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`, `di.config.dart`,
`lib/l10n/app_localizations*.dart`, `*.gen.dart`, `docs/TODO_INDEX.md`, the
synced `apps/game/assets/` folders and fonts) are committed and never edited
by hand.
CI regenerates them and fails if anything changed. build_runner 2.15 always
replaces conflicting outputs, so it needs no `--delete-conflicting-outputs`
flag. It still accepts that flag and ignores it.

## Tests and analysis

Each line starts from the repo root:

```bash
flutter analyze                               # the policy is zero issues
cd packages/nesty_core   && dart test         # must always pass
cd packages/nesty_render && flutter test
cd apps/game             && flutter test      # cubit + widget tests on fake services
cd apps/admin            && flutter test
cd tools                 && dart test         # nesty_tools
```

The on-device playthrough (the dev flavor with every real service: levels 1
and 2 to the win overlay, level 16 into Out of Moves, Pause, Home) needs a
booted simulator or emulator. It saves its screenshots through the driver,
into `$NESTY_SCREENSHOT_DIR` or `apps/game/build/integration_test/screenshots/`:

```bash
cd apps/game && flutter drive --flavor dev --driver test_driver/integration_test.dart \
  --target integration_test/playthrough_test.dart -d <device-id>
```

The 60 fps check (M2's acceptance) runs a profile build on a physical phone:
`cd apps/game && flutter run --profile --flavor dev -t lib/main_dev.dart -d
<device-id>`, then DevTools' Performance view. The flows to play and the pass
bar are in [docs/PROGRESS.md](docs/PROGRESS.md) under "M2 acceptance".

**Troubleshooting.** If an iOS build fails with "NativeAssetsManifest.json
references objective_c, which was not found", `apps/game/build/` was deleted
without `apps/game/.dart_tool/flutter_build/`, whose stamps still say the
native assets are built. Run `flutter clean` in `apps/game` (or delete that
folder too) and build again.

CI (`.github/workflows/ci.yaml`) runs on Flutter 3.41.2, and every job starts
with `flutter pub get --enforce-lockfile`. It has three jobs:
- **Format, analyze and test:** the steps above, plus a format check, with
  `flutter analyze --fatal-infos --fatal-warnings`.
- **Codegen drift:** regenerates code in both apps and the design tokens and
  icons, checks the synced design assets and the TODO index, and fails if any
  file changed or appeared.
- **Build:** the game's dev debug APK and the admin's web build.

iOS isn't built in CI.

## Architecture at a glance

- **Game rules** live only in `nesty_core`, which is pure Dart and
  deterministic (seeded PRNG, no clock). The game, the admin, the solver and
  the generator all call it.
- **Apps** follow a Cubit-first `flutter_bloc` architecture:
  - `BaseAsyncCubit<T>` emitting a freezed `AsyncValue<T>`;
  - `get_it` + `injectable` DI, with `real` and `fake` environments;
  - `auto_route` routing;
  - ARB localization;
  - dev/stg/prod flavors through `lib/main_<flavor>.dart` → `bootstrap()`.
- **Services** (ads, purchases, analytics, Remote Config, levels, save,
  audio, haptics) sit behind interfaces with offline fakes. Every network
  call fails silently, so the game is fully playable offline from first
  launch.
- **Storage:** the game stores device settings in Hive (`hive_ce`), opened
  once at startup.
- **Flame** components only render `nesty_core` state; they never own it.

The details are in the app READMEs, and the reasons are in the decisions log in
[docs/PROGRESS.md](docs/PROGRESS.md).

## Firebase

Firebase is wired in at M4 (game) and M5 (admin). The app config files
(`firebase_options*.dart`, `google-services.json`, `GoogleService-Info.plist`)
are created by the owner with `flutterfire configure`. Never write them by
hand. Rules, indexes and emulator settings are in [firebase/](firebase/README.md):

```bash
cd firebase && firebase emulators:start      # Auth :9099, Firestore :8080, Storage :9199, UI :4000
```

## Contributing

- Read [docs/GAME_SPEC.md](docs/GAME_SPEC.md) before starting a feature, and
  work milestone by milestone (spec §18). Record decisions, package reasons
  and open questions in [docs/PROGRESS.md](docs/PROGRESS.md).
- Use conventional commits (`feat(game): ...`, `fix(core): ...`). Never
  force-push.
- Never commit secrets, real ad unit IDs or signing material.

## Docs

- [docs/GAME_SPEC.md](docs/GAME_SPEC.md): game and technical specification
  (source of truth)
- [docs/PROGRESS.md](docs/PROGRESS.md): milestones, decisions, package
  reasons, open questions
- [docs/BACKLOG.md](docs/BACKLOG.md): every remaining item by milestone, and
  the owner inputs still needed
- [design/README.md](design/README.md): the design handoff (components,
  screens by frame id, motion, sound)
- [docs/DESIGN_BRIEF.md](docs/DESIGN_BRIEF.md): design brief
- [CLAUDE.md](CLAUDE.md): working rules for Claude Code in this repo. Its
  Commands section matches this README.
