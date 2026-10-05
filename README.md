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
[docs/PROGRESS.md](docs/PROGRESS.md) under "M2 acceptance". After M2, the
designer's v3 Lottie export and the audio delivery (two music loops, three
jingles and the final sound effects) were imported and wired in (PROGRESS
"Post-M2 round", D59–D61). M3 (the app shell and meta: the save, the
economy, chapters, the Museum, Bonus Endless, the Daily, the tutorial, Home,
Settings and the Shop) is code complete: the kill-and-resume and the
same-date daily pass on an iOS simulator and an Android emulator, and its
last checks are the owner's on physical phones (PROGRESS "M3 acceptance").
Milestones,
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
    TEST_COVERAGE.md         # what `nesty-test` checks for each feature, on the host and on a device
  design/                    # design handoff (owner-managed, read-only): tokens, art, Lottie, SFX, music, prototypes
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
  audio plugin builds native code). Never set `NO_XIPH_LIBS` in either
  build: the plugin decodes the OGG music and jingles with the Ogg/Vorbis
  libraries it bundles.
- For iOS (macOS only): Xcode, CocoaPods and CMake (`brew install cmake`;
  `flutter_soloud`'s pod builds with it). The deployment target is iOS 14.
  - `Podfile.lock`'s `SPEC CHECKSUMS` are the SHA-1 of each plugin's podspec
    as CocoaPods stores it in JSON (`Pods/Local Podspecs/`), and Ruby's
    `json` writes an empty list as `[]` in 2.9.1 (Homebrew's `pod`, on
    Ruby 3.4) but over three lines in 2.7.1 (a gem-installed `pod` on
    Ruby 3.3). The owner's machine has both on PATH, so a `pod install`
    through the other one rewrites every plugin's checksum with no version
    change. Check `which pod` before reading such a diff as a dependency
    change (M7 review R5).
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
dart run nesty_tools:sync_design_assets   # design/ art, UI art, audio, Lottie → apps/game/assets, + the Android notification icon
dart run nesty_tools:gen_nesty_icons      # NestyIcons from the bundled icon font
dart run nesty_tools:gen_font_subsets     # the hi/ja font subset lists (tools/fonts/subset/); then build_fonts.sh
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
cd apps/game             && flutter test test/overflow --dart-define=NESTY_TEST_LOCALE=de   # the overflow suite in one locale (de es fr hi id ja pt pt_BR tr; nesty-test and CI loop all nine)
cd apps/admin            && flutter test
cd tools                 && dart test         # nesty_tools
```

**One command for everything:** `tools/scripts/nesty-test` (the owner's
shell has it as the `nesty-test` alias) runs the host checks, then boots an
iPhone 16 Pro simulator and shows it,
installs the app fresh and runs the on-device checks below: the
playthrough with its screenshots, the kill-and-resume, the daily
fingerprint against nesty_core's own level, M7 phase 4's five files
(board layouts, race loss, meta screens, daily states, overlays) and phase
5's two (failure states, the screen readers' tour), each scenario from a
fresh install. It prints a PASS/FAIL summary
and exits 1 if any step failed; logs, screenshots and `summary.txt` go to
`apps/game/build/nesty-test/<timestamp>/` (`latest` links the newest run).

The host checks are CI's, except codegen drift, which would rewrite the
generated files:
- `dart format` and `flutter analyze --fatal-infos --fatal-warnings`;
- every test suite;
- nesty_core's web parity on node, chrome and dart2wasm, each shown as SKIP
  when node or Chrome isn't installed;
- the design, asset, FX and TODO-index drift checks;
- the level bundle and solver fixtures;
- the admin's web build.

It stops early, with a message, when the disk has less than 8 GB free
(`NESTY_TEST_MIN_FREE_GB` changes that). A full disk otherwise fails the
playthrough deep inside `flutter drive`. A step whose log shows "No space
left on device" says so. Each device step starts `flutter drive`'s
command log (`build/flutter_driver_commands_0.log`, which holds every
screenshot's data) empty. A step that hangs at attach (the app is up, but
`flutter drive` never connects, so its `--timeout` never starts) is stopped
and fails after 8 minutes at its build line (`NESTY_TEST_ATTACH_HANG_S`).
Only the newest 5 runs are kept in `apps/game/build/nesty-test/`
(`NESTY_TEST_KEEP_RUNS`).

[docs/TEST_COVERAGE.md](docs/TEST_COVERAGE.md) lists what checks each
feature, on the host and on a device. Every new feature adds its device step
and its row there (CLAUDE.md "Testing", D169).

```bash
tools/scripts/nesty-test                    # everything, on the iPhone 16 Pro simulator
tools/scripts/nesty-test --device-only      # skip the host checks
tools/scripts/nesty-test --android          # the flutter_emulator AVD, with its window
tools/scripts/nesty-test --device 87BDED37-4095-49C4-811A-3E2B7D5FB38B --only playthrough   # the iPhone 16e (390x844), by UDID
tools/scripts/nesty-test --device-only --only board,race,meta,daily_states,overlays   # phase 4's files
tools/scripts/nesty-test --device-only --only faults,semantics   # phase 5's files
tools/scripts/nesty-test --device-only --only locales            # de, hi, ja on a device (5B)
tools/scripts/nesty-test --android --android-size 1170x2532@480 --device-only   # the emulator at 390x844 dp
tools/scripts/nesty-test --android --only reminder   # the optional Android reminder check
tools/scripts/nesty-test --help             # every option
```

`--device` takes a simulator name or UDID (iOS) or an AVD name or running
serial (Android). Pass a UDID when several simulators share a name, and
never one that is in use for something else. `NESTY_TEST_IOS_DEVICE` and
`NESTY_TEST_ANDROID_DEVICE` set the default behind `--device` for each
platform. `--android-size WxH@dpi` (or `NESTY_TEST_ANDROID_SIZE`) sets the
emulator's screen with `adb shell wm size` and `wm density` after boot, and
the exit trap resets both, only if the run set them: `1170x2532@480` is 390
x 844 dp, the iPhone 16e's size, for side-by-side comparisons with the
design frames.

The on-device checks run the dev flavor with every real service (Hive, the
isolate solver and generator, SoLoud, the Lottie files) on a booted
simulator or emulator, through `flutter drive`. Start the playthrough and
the resume's phase A from a fresh install (`xcrun simctl uninstall <udid>
com.futrix.nesty.dev` or `adb -s <serial> uninstall com.futrix.nesty.dev`):
they expect a fresh save.

The playthrough goes Splash → level 1, faded in (frame 10.8), through the
scripted tutorial's "STEP n OF 3" (a fresh install opens it with no screen
in between, E9: the run fails if the router stacks any other route on the
way; E13's times, from `main()` to level 1's first playable frame and until
it is alone on screen, are printed as `NESTY_E13` and written to
`playthrough.json` and to `e13.json` beside the screenshots) with its 3
stars on the win card → Home after the first win → Chapters from Home's
chapter card (level 1 at 3 stars), its level card and a 4-move replay of
level 1 (2 stars and "3 stars at 3 moves or fewer", the level keeping its 3)
and Records with its stats grid → the shell tabs, the Museum and its modals,
the Shop with its "Not enough coins" dialog and an equip, Settings with its
language sheet and the inline Reduce motion control → level 2 → level 9's
hint and two extra slots up to the limit → level 16's towers card, Hint
popup and Out of Moves → Pause → Settings and back → level 21's chapter
ribbon → level 20's chapter complete and the earned Museum → vs Computer
against rival 1 (Home's tile, rival select, the race board before and
during the race, the solver's moves to "You won the race!" and +20 coins,
then system back through "New rival unlocked!", the Computer tag on every
rival screen) → level 30's milestone chest → level 31's glass card and case
→ the Daily (5.1, 5.3–5.5), whose win card shows Share (never tapped: the
OS share sheet can't be dismissed from `flutter drive`) and whose solved
card opens the one-time reminder offer, answered "No thanks" (never "Yes,
remind me": iOS's permission alert can't be tapped either) → Settings with
the reminder row off → levels 51 (ice and its card), 71 (size 5) and 130
(size 6, then its chest) → Chapters at chapter 7 → level 200's chapter
complete, All Levels Done and the bonus pill. The Daily comes after level
31 so that levels 16, 31 and 51 each open on their own mechanic's intro
card, as for a player who skips the daily. It can't listen, so it checks
the music through `SoLoudMusicService`'s state (the loop on each screen and
each overlay's duck), and fails if any sound, music or Lottie file didn't
load: start an Android emulator with audio (no `-no-audio`), or SoLoud
can't open its output and the run fails at once. It saves its screenshots
through the driver, into `$NESTY_SCREENSHOT_DIR` or
`apps/game/build/integration_test/screenshots/`. The fixed date makes the
daily's board the same on every run and device, and the slowed rival makes
the race a sure win for the solver's moves:

```bash
cd apps/game && NESTY_SCREENSHOT_DIR=/some/dir flutter drive --flavor dev \
  --driver test_driver/integration_test.dart \
  --target integration_test/playthrough_test.dart \
  --dart-define=NESTY_FAKE_DATE=20260926 \
  --dart-define=NESTY_RACE_PACE_MS=600000 -d <device-id>
```

`--dart-define=NESTY_RACE_PACE_MS=<ms>` sets every rival's pace to one move
every `<ms>` milliseconds (± the `race_pace_jitter_pct` jitter) in place of
`race_pace_ms_<n>` (m7-design P2.5). Like `NESTY_FAKE_DATE`, only a debug
build of the dev flavor honours it; profile and release builds, and the stg
and prod flavors, ignore it (`RaceRules.parsePaceOverride`, pinned by
`test/core/services/race/race_rules_test.dart`). The playthrough fails at the
race if it isn't set to 600000 (10 minutes a move); `nesty-test` passes it.

The dev flavor's boosters never run out, which hides every coin price. The
playthrough turns that off with `InMemorySaveService.debugUnlimitedBoosters`
(debug builds only; profile and release ignore it) to reach the Hint popup
and the Out-of-Moves sheet's priced +1 Slot row. +1 Slot itself stays free
in debug builds (m3-design §7.3).

Kill mid-level and resume (M3's acceptance) is two runs with a real kill
between them. `flutter test` and a plain `flutter drive` stop and uninstall
the app when they finish, which wipes its data, so phase A keeps it running;
installing phase B's build over it keeps the data:

```bash
cd apps/game
flutter drive --flavor dev --keep-app-running --driver test_driver/integration_test.dart \
  --target integration_test/resume_phase_a_test.dart -d <device-id>
xcrun simctl terminate <udid> com.futrix.nesty.dev      # iOS
adb -s <serial> shell am force-stop com.futrix.nesty.dev # Android
flutter drive --flavor dev --driver test_driver/integration_test.dart \
  --target integration_test/resume_phase_b_test.dart -d <device-id>
```

Phase A wins level 1 (the splash opens it on a fresh install) and level 2,
opens level 3 from Home's PLAY, makes two
moves, an undo, a +1 Slot and a move onto it; phase B taps Home's PLAY and
asserts the same board, undos left and extra slots. Each phase writes its
values (`level`, `freeUndosLeft`, `extraSlotCount` and the session's
canonical JSON as `fingerprint`) to `apps/game/build/integration_response_data.json`
and a `NESTY_RESUME` log line; the two must be equal.

The daily puzzle must be the same level on every device (M3's acceptance):

```bash
cd apps/game && flutter drive --flavor dev --driver test_driver/integration_test.dart \
  --target integration_test/daily_fingerprint_test.dart \
  --dart-define=NESTY_FAKE_DATE=20260926 -d <device-id>
```

It writes the day's generated level as canonical JSON (`fingerprint` in
`apps/game/build/integration_response_data.json`, and a `NESTY_DAILY` log
line). Run it on two devices: the two strings must be equal, and their
Hash64 must match the core's golden for that date
(`packages/nesty_core/test/generator/golden_test.dart`, `'daily 20260926'`).

M7 phase 4's five device files each seed their own save
(`integration_test/support/seeded_save.dart`) before `app.main()`, so start
each from a fresh install; `nesty-test` uninstalls first. Their screenshots
are prefixed `b_`, `r_`, `meta-`, `d_` and `ov_`:

```bash
cd apps/game
T="flutter drive --flavor dev --driver test_driver/integration_test.dart -d <device-id>"
$T --target integration_test/board_layouts_test.dart   # levels 31-200's layouts
$T --target integration_test/race_loss_test.dart \
  --dart-define=NESTY_RACE_SCENARIO=loss --dart-define=NESTY_RACE_PACE_MS=250
$T --target integration_test/race_loss_test.dart \
  --dart-define=NESTY_RACE_SCENARIO=oom --dart-define=NESTY_RACE_PACE_MS=600000
$T --target integration_test/race_loss_test.dart \
  --dart-define=NESTY_RACE_SCENARIO=restart --dart-define=NESTY_RACE_PACE_MS=1000
$T --target integration_test/meta_screens_test.dart \
  --dart-define=NESTY_META_SCENARIO=returning   # or finale, complete
$T --target integration_test/daily_states_test.dart \
  --dart-define=NESTY_FAKE_DATE=20260926 --dart-define=NESTY_DAILY_SCENARIO=chest  # or paused, saved, settings
$T --target integration_test/overlays_test.dart   # the win card, chests, 12.5-12.9, the undo, intro loops
```

`board_layouts_test` finds its levels by scanning the bundle (a size-5, the
tall preset, a tall glass case, a top-shelf tower, an iced tower, two +1
Slots), then opens chapters 7–10's first levels for their ribbons and their
own shelf wood. `race_loss_test`'s `loss` lets the computer finish first,
then Rematch, Pause with Settings, Leave race's confirm and New race, with
the rival's portrait reacting on the strip and the card; `oom` seeds rival 1
at race 5, so Start makes race 6 (races 1–5's roomy boards reach no dead
end), walks core's shortest line to Out of Moves and shoots the sheet at
1.3× text too; `restart` races rival 2's race 39 at stage 20, the race whose
rival restarts first (its 7th step), and shoots the strip's "Starting over"
(9.3c), around it checking rival select's pick on a new visit (the rival
last raced). `meta_screens_test`'s `returning` walks a returning player's
screens (a purchase with no card included), `finale` shoots Home with level
60's Super Hard PLAY (12.1) and `complete` Home past level 200 and the
Museum with all ten families (12.2, 6.1c). `daily_states_test`'s `chest`
seeds a 6-day streak and opens the day-7 chest and the offer's time picker,
`paused` relights a paused flame and sees Home's badge glow once, `saved`
lets a freeze cover yesterday (the toast and the streak card's freeze line,
5.2), and `settings` toggles every row and plays a relaxed board.
`overlays_test` replays level 1 three ways (1, 2 and 3 stars) for the win
card's heights. The resume pair also runs with
`--dart-define=NESTY_RESUME_SCENARIO=l1` on both phases (E9): one move on
level 1 during its tutorial, the kill, and the splash reopening level 1
with the same board.

M7 phase 5's two device files run one scenario per launch, each from a
fresh install. `faults_test` (screenshots `f_`) installs a fault through
the test-only seam `bootstrap(beforeRunApp:)`: decorators in
`integration_test/support/fault_services.dart`, registered over the real
services with GetIt's `allowReassignment`, and nothing in `lib/`. Its
reminder scenarios go on to Settings: `reminder_granted` the Time row, a
new time's app-wide toast and the switch off and on, `reminder_denied` the
blocked row's Turn off.
`semantics_tour_test` (screenshots `s_`) walks each screen's semantics tree
in traversal order and writes it to the response data (`semantics`). It
fails on a tap target with no label, a label read twice in a row, a rival
named without "Computer", or a page reachable under a modal overlay. With
`--dart-define=NESTY_A11Y_HOLD=1` it waits on each screen for a TalkBack
pass:

```bash
$T --target integration_test/faults_test.dart \
  --dart-define=NESTY_FAULT_SCENARIO=storage   # or content, race_failed, generating,
                                               # bonus_failed, reminder_granted, reminder_denied
$T --target integration_test/semantics_tour_test.dart \
  --dart-define=NESTY_A11Y_SCENARIO=game        # or meta (with NESTY_FAKE_DATE), race
                                                # (NESTY_RACE_PACE_MS=600000), race_loss (=250)
```

The daily reminder's optional Android check (M7 phase 3) turns "Daily
reminder" on in Settings and expects the one pending reminder, then off and
expects none. `POST_NOTIFICATIONS` is granted before the app first runs, so
no OS dialog opens; `nesty-test --android --only reminder` does all of it
(it never runs by default, and iOS skips it: `simctl privacy` can't grant
notifications, so the owner checks a delivered reminder on a phone):

```bash
cd apps/game
adb -s <serial> uninstall com.futrix.nesty.dev
flutter build apk --debug --flavor dev -t integration_test/reminder_test.dart
adb -s <serial> install -r build/app/outputs/flutter-apk/app-dev-debug.apk
adb -s <serial> shell pm grant com.futrix.nesty.dev android.permission.POST_NOTIFICATIONS
flutter drive --flavor dev --driver test_driver/integration_test.dart \
  --target integration_test/reminder_test.dart \
  --use-application-binary build/app/outputs/flutter-apk/app-dev-debug.apk \
  -d <serial>
```

Two harness facts for widget tests: `Bloc.close()` never completes inside
`testWidgets`' fake-async zone, so never await it there (use
`tester.runAsync`); and real Hive I/O started from that zone only finishes
by alternating `tester.runAsync` with `pump` (`settle` in
`apps/game/test/app_flow_test.dart`).

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
  audio, music, haptics) sit behind interfaces with offline fakes. Every network
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
