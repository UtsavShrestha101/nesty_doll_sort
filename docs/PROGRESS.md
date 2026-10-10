# Progress — Nesty: Doll Sort

The running record of the project (CLAUDE.md "Workflow"): milestone status,
decisions with their reasons, why each package is here (CLAUDE.md rule 9), and
open questions. The spec is [GAME_SPEC.md](GAME_SPEC.md); milestones and their
acceptance criteria come from spec §18. The work still to do is tracked in
[BACKLOG.md](BACKLOG.md), item by item and milestone by milestone. This file
doesn't copy it.

Last updated: 2026-10-10 (D315: the device run after stage 4, part two: Android's widget cold link fixed in `nesty-test` (flutter drive's uninstall), every new shot judged on both platforms, the close review's P2 fixes; the local habits are code complete. Before that: D313–D314: stage 3's device run, the date fix, the bridge after the test seam, the d_43 sizes, watch-run's FAIL lines. Before that: D312: stage 4, the home-screen widget, built: snapshot v1 through the `home_widget` channel, the `<scheme>://daily` link, the iOS WidgetKit extension and the Android AppWidget provider, `gen_widget_strings`, JUnit for the Kotlin tests. Before that: D311: stage 3, the last 7 dailies, built: save schema 4, the window, the resolver's gate, the picker, the past day's card, board and win, the `archive` device step. Before that: D310: §7.5c approved (Q189–Q191); stage 3 starts; commits allowed when needed. Before that: D309: m7-6's device run passed on both platforms and its shots match the frames, with three fixes from the judging. Before that: D304–D308: Claude Design's m7-6 imported: tokens v6, the copy in nine locales, the habits' final look, Part 2's items and the host gate. D303: auto-compact at 400k tokens. Before that: D300 and Q192–Q193: the retention research, round 3, with proposals RR1–RR7 in [plans/retention-research.md](plans/retention-research.md) and BACKLOG. Before that: D297–D299 and Q189–Q191: the local habits started, stage 0's plan written with §7.5c for the owner, `home_widget` researched and not taken. Before that: the local habits' Claude Code prompt and Claude Design's m7-6 request written, and BACKLOG's design items that m7-5 answered ticked. Before that, D281–D296: Claude Design's m7-5 imported: the daily gift's final look (section 13) and Part 2's answers wired in four lanes plus a font lane, Turkish titles in Baloo 2, the owner's watcher rule; every on-device check passes on the iPhone 16e and the Android emulator, and the shots match section 13; see "m7-5, Device run and fidelity"). Before that: 2026-10-05 (D276–D280 and Q186–Q188: the daily gift built in four stages: its rules, the `login_gift_track` key and save schema 3; the cubit, Home's button, the sheet and Day 7's chest on `TODO(design)` stand-ins, 20 strings in nine locales with the Opus review, the ethics test; `nesty-test --only gift` passed on both devices; the review's fixes. Before that: D274, D275: Q162 answered (all four local habits, in order) and Q184 in part (wave 1 first). Before that: D272, D273: the owner's answers to Q185 (the daily gift starts next) and Q183 (the loss card keeps its hop). Before that: M7 code complete: the `/milestone M7` gate passed on both devices with its reruns, the results in "Phase 5, 5C", the 5B and 5f placeholders closed, Q185. Before that: D270's second pass: the themes, characters and story doc checked against the code and deepened (TC11–TC14, TC-FX, TC-DATA, the story in detail, the calendar), Q184 widened, and the proposals' Status row added. Before that: D271: M7 5C, the review and its fixes, and the race strip keeping the word "Computer"; the `/milestone M7` gate is next. Before that: D270, Q183–Q184: the themes, characters and story proposals and the loss-card question. Before that: D269: local first, backend last, data-driven for the admin. Before that: D268 and Q182: the daily gift, a login reward the owner asked for and approved with Q182's defaults; plan, research and the Claude Design request written; it starts after M7. Before that: 2026-10-05 (D261–D267 and Q175–Q181: M7 phase 5B, the translations: nine locales, the script fonts, the fit, the language sheet and the follow-ups that landed with them; the draft round and the integration are done, the device run's results are pending; the 5B questions were renumbered from the plan's Q162–Q167. Before that: 2026-10-04 (D259–D260 and Q173–Q174: the engagement research and its proposals ER1–ER11 in [plans/engagement-research.md](plans/engagement-research.md) and BACKLOG; under-13s become a target (a mixed audience) with the kid path's items in BACKLOG; Q86 annotated. Before that: 2026-10-04, D235–D236 logged and D241–D258, Q158–Q159 answered and Q168–Q172: M7 phase 5's m7-4 stage: the wiring, the device run, the TalkBack pass, the fidelity audit and its fixes, the 5B draft round; the 5f reruns' results are pending. Before that: 2026-10-04, D238–D240: the owner's rules for working within Claude's usage limits, for being proactive, and the documented efficiency practices, in CLAUDE.md "Workflow" and "Compact instructions". Before that: 2026-10-02, D237 and Q162: after M7, the local-habit proposals; M4, M5, M6 and M8 stay at the end. Before that: 2026-10-01, D210–D234 and Q160–Q161: M7 phase 5A built: the fidelity fixes from the scenes' CSS, the animated undo, lane O's splash, scrim, chest and relit card, the device seams, `faults` and `semantics` in `nesty-test`; the device run is blocked on disk (16 GB of the 20 GB floor), so the audit and the TalkBack pass wait. Before that: 2026-09-30, D209 and Q159: M7 phase 4's device run passed on both platforms, with seven test fixes and six app fixes; phase 5 is next. Before that: D202–D208 and Q158: phase 4 integrated: the lanes' cross-lane edits, E1, `di_test`, `app_flow_test` and the playthrough on m7-3, the five new device files in `nesty-test` and TEST_COVERAGE, the Claude Design follow-up; the device stage is next. Before that: D179–D201 and Q156–Q157: phase 4's contracts stage (C4b): the frozen shapes for Claude Design's m7-3 delivery, copy.md in the ARB, the five lanes; 20 design-answered questions marked answered, with Q72's Forest Bear part and Q73's catalog copy. Before that: D173–D178: phase 4's tooling stage: tokens v3, the 35 Lottie files, the UI art and the generated Android notification icon, the 68-glyph font. Before that: D171–D172: Claude Design's whole M7 delivery checked and copied into `design/` at the owner's request, and the +1 Slot kept on the bottom shelf (D22); phase 4, the integration, is next. Before that: D170: the HUD's "Replay" tag removed. Before that: D169, the owner's rule that `nesty-test` covers every feature: CI's host checks added, docs/TEST_COVERAGE.md and its test. Before that: M7 phase 5, the device run after the review: every device check passes on both platforms, the reminder in Europe/Amsterdam too, and one layout fix to the win card's button, D168. Before that: M7 review pass, round 2: four deep lenses, 33 findings, 32 fixed and one left to the owner, the accessibility audit closed, the pass-and-play proposal, D165–D167 and Q154–Q155. Before that: M7 review pass, round 1: five lenses, five findings, four fixed and one deferred, D163–D164 and Q153. Before that: M7 phase 3 integrated: star ratings, the daily share card and the opt-in reminder, D144–D161 and Q137–Q151; its device run is next. Before that: M7 phase 2 done: vs Computer, D132–D143 and Q124–Q136, passed on both devices. Before that: M7 phase 1 integrated: levels 31–200 and E1, E2, E5–E9, E12–E14 with the owner's simulator review, D113–D124, Q99–Q115; its device run is next. Earlier today: the M7 contracts, D95–D110 and Q88–Q98; D111–D112, the owner's review; D92–D93, the offline-game brainstorm, Q76–Q87; D91, Large color symbols by default; D90, M7 runs before M4–M6. M3 code complete, acceptance pending).

## Status

| Milestone | Status | Acceptance criteria (spec §18) |
|---|---|---|
| **M0 — Architecture skeleton** | ✅ Done 2026-09-26, no open blocker | Analyze clean, every test passes, every app builds. All met: analyze clean, tests 32/5/53/47, every flavor's APK, the iOS dev/prod builds and the admin web build succeed (see [Verification](#verification-2026-09-26-in-the-repo)) |
| **M1 — Core (`nesty_core`)** | ✅ Done 2026-09-26 (see [M1](#m1--core-nesty_core--done-2026-09-26)); owner questions Q30–Q38 confirmed 2026-09-26 | All §4 rules unit-tested. Solver fixtures pass. Generator is deterministic. 100 generated levels pass validation and solve. All met |
| M2 — Playable game (placeholder art; the design art was pulled in, D23) | **Code complete 2026-09-27; acceptance waits on the owner's device check.** Built: the nesty_render foundation, the 30 authored levels and `bundle check` in CI, the phase-4 Lottie contracts (D40–D52), every Lottie lane, the services, the bloc, the UI kit, the Flame board and the screens (D53–D57), then a review fix pass (12 of 13 findings fixed, D58). Every automated gate passes, including the on-device playthrough of L1, L2 and L16. Left: the 60 fps profile on a real mid-range Android (the owner's, steps in [M2 acceptance](#m2-acceptance-spec-18)) and the manual L1–30 pass (see [M2](#m2--playable-game--code-complete-acceptance-pending)). **Post-M2 round 2026-09-27:** Claude Design's v3 Lottie export and the audio delivery (music, jingles, SFX v2) imported and wired in, the owner's Level 9 hint and +1 Slot report fixed, every gate green again (see [Post-M2 round](#post-m2-round-claude-design-v3-and-audio-2026-09-27), D59–D61) | Levels 1–30 playable start to finish at 60 fps on a mid-range Android device |
| M3 — App shell and meta | **Code complete 2026-09-28; acceptance waits on the owner's two physical-device checks.** Built: the save (Hive, migrations, the board in progress), the economy and boosters' coin path, chapters, the Museum, Bonus Endless, the Daily with its streak, the tutorial and intro cards, the shell, Home, Settings and the Shop (D63–D80). The integration fixed five app bugs (D81, D84, D85); a three-lens review found 23 issues, 22 fixed in its pass and the last in the close-out (D86–D89). Both criteria pass on the iPhone 16 Pro simulator and the API 35 emulator (see [M3 acceptance](#m3-acceptance-spec-18)) | Kill the app mid-level and it resumes exactly where it was. The daily puzzle is identical on two devices on the same date |
| M7 — Art and polish, plus the offline game: content, modes and engagement | **Code complete 2026-10-05; acceptance waits on the owner:** the design sign-off (Q161), the VoiceOver pass ([plans/voiceover-checklist.md](plans/voiceover-checklist.md)) and Claude Design's follow-up (§1–§14). Started 2026-09-28; D90, D92, D93; plan [plans/plan-m7.md](plans/plan-m7.md). The owner moved it ahead of M4–M6 and widened it: levels 31–200 on the chapter plan, chapter themes 7–10, the catalog copy, the vs Computer race (approved in principle, D93) and eight engagement features under the respect rules (D92). The rules are in [plans/spec-proposals-m7.md](plans/spec-proposals-m7.md) until the owner pastes them into the spec; the art and copy come from Claude Design ([BACKLOG M7](BACKLOG.md)). Phases 1–5 are done, and the `/milestone M7` gate passed on both devices (2026-10-05, [Phase 5, 5C](#phase-5-5c-the-review-and-its-fixes-2026-10-05)). D237 keeps the backend after this close and after the local-habit proposals | Matches the design screens. No layout overflows on 5 test screen sizes (small Android, standard phone, tall phone, small iPhone, iPad portrait) |
| Local habits | **Picked: all four, in order, the widget last (D274, Q162). Started 2026-10-08 with M7's and the gift's sign-offs open (D297). Stage 0, the plan, is done: [plans/plan-local-habits.md](plans/plan-local-habits.md) (D298, D299); §7.5c is approved (Q189–Q191, D310). Stages 1 and 2 (welcome back, the month) are built on stand-ins and pass on the host and the iPhone 16e (D302); Claude Design's m7-6 is copied into `design/` (D301) and imported (D304–D308): the habits' final look for the welcome card, the month and 12.14, and Part 2's items are built, the host gate passed, and every device check passes on both platforms with the shots matching the frames (D309). Stage 3 (the last 7 dailies) is built and passes on the host (D311). Stage 4 (the home-screen widget) is built on m7-6's widget frames and passes on the host, the Kotlin JVM tests included (D312). **Code complete 2026-10-10:** the full device run after stages 3 and 4 passes on the iPhone 16e and the Android emulator with every new shot judged (iOS's cold link is SKIP behind the system's prompt), and the close review's fixes are in (D313–D315). Left with the owner: the widget on a real phone, the App Groups (no Apple Developer account yet, D313) and the design gaps.** The prompt that starts the build is [plans/local-habits-claude-code-prompt.md](plans/local-habits-claude-code-prompt.md), and Claude Design's request is [plans/claude-design-request-m7-6.md](plans/claude-design-request-m7-6.md) (section 14 and the 21 questions m7-5 left open), both 2026-10-08. After the daily gift, before M4. Reasoning: [plans/local-habits-brainstorm.md](plans/local-habits-brainstorm.md) | Each habit passes its host tests and its device step on both platforms (D169); the archive rule (§7.5c) needs the owner's approval first |
| Daily gift (a login reward) | **Code complete 2026-10-05 (D276–D280); the final look is in (m7-5, D281–D294). Every on-device check passes on both platforms and the shots match section 13 (D296). Acceptance now waits on the owner's sign-off and the paste of §7.5b.** Built: `LoginGiftRules`, the `login_gift_track` key, save schema 3, `LoginGiftCubit`, Home's button and the sheet, Day 7's chest, 20 strings in nine locales with the Opus review, the ethics test and `nesty-test --only gift`, which passed on the iPhone 16e and the Android emulator. Work list: BACKLOG "Daily gift". [plans/plan-login-gift.md](plans/plan-login-gift.md) | The owner's sign-off of the final look (Claude Design's section 13, wired in m7-5) and the paste of §7.5b |
| Engagement research and the kid path | Proposals ER1–ER11 (D259, Q173): not started, and not rules. The kid path (D260, Q174): decided, not started; its local part (the age question, the parent area) lands before M4, and its M4, M6 and M8 parts are in those sections. After M7 and the local habits. [plans/engagement-research.md](plans/engagement-research.md) | None for the proposals until the owner picks. The kid path ships before release |
| Themes, characters and story | Proposals TC1–TC14 and the enablers TC-FX and TC-DATA (D270, Q184): not started, and not rules. Original characters only; a licence (TC-L) waits until after M8. After M7 and the local habits, beside the engagement research's wave 2. [plans/themes-characters-story.md](plans/themes-characters-story.md) | None until the owner picks |
| Retention research, round 3 | Proposals RR1–RR7 (D300, Q192–Q193): not started, and not rules. All local except RR6 (M8). [plans/retention-research.md](plans/retention-research.md) | None until the owner picks |
| M4 — Firebase content | Not started; after M7 and the local habits (D90, D237) | Airplane mode on first launch: fully playable. Levels published in the admin appear on the next app resume |
| M5 — Admin panel | Not started; after M4 (D90, D237) | The owner can build, solve, simulate, playtest and publish a level, and upload a skin that then shows up in the game |
| M6 — Monetization | Not started; after M5 (D90, D237) | Every §9.1 pacing rule is unit-tested with a fake clock. Offline ad buttons fall back to coins correctly |
| M8 — Release prep | Not started; after M6 (D237) | Release builds run on real Android and iOS devices with production Firebase |

M0 is not in spec §18. It is the pre-M1 architecture pass the owner asked for:
"internal setups like base cubits, Hive, folder architecture, packages". No
game rule, solver, generator or codec was written, and the UI is unstyled
placeholders until the owner adds the `design/` exports.

### Blocker B1 (resolved 2026-09-26): auto_route 11.2.0 does not compile on the installed Flutter

- **Symptom:** `auto_route-11.2.0/lib/src/router/widgets/eager_page_view.dart:283`
  passes `Viewport(scrollCacheExtent: ...)`. The local SDK (Flutter 3.41.2
  underneath, see D15) only has `cacheExtent`/`cacheExtentStyle`. auto_route
  still declares `flutter: >=3.16.0`, so pub accepted it.
- **Impact while open:** anything that imported the router failed to compile:
  `flutter run`, every app build and 2 test files per app
  (`app_flow_test.dart`, `di_test.dart`). `flutter analyze` did not catch it,
  because it doesn't compile dependencies.
- **Fix (applied 2026-09-26, Q1):** `auto_route: 11.1.0` (exact, no caret) in
  both `apps/game/pubspec.yaml` and `apps/admin/pubspec.yaml`, then
  `flutter pub get` at the root.
  - The lock diff was auto_route 11.2.0 → 11.1.0, plus dropping
    `material_ui` and `cupertino_ui` 0.0.1, which only 11.2.0 pulled in.
  - Codegen output stayed byte-identical. Every app test and build passes
    (see Verification).
- **This is the rule-9 reason for the pin** (see the auto_route row under
  Package reasons). Revisit it when the local Flutter is upgraded (Q23) to
  an SDK that has `Viewport.scrollCacheExtent`. Bump auto_route in the same
  change, then update this entry, that row and `.claude/rules/auto-route.md`.

## M0 — Architecture skeleton — done (2026-09-26)

The skeleton was built on 2026-09-25. On 2026-09-26 B1 was fixed, an
infrastructure pass finished `.claude/`, CI, hooks, launch configs,
`firebase/` and `.gitignore`, and a review and fix pass followed (see
[Review pass](#review-pass-2026-09-26)).

### Done

**Workspace and tooling**
- Dart pub workspace at the root with four members: `packages/nesty_core`,
  `packages/nesty_render`, `apps/game` and `apps/admin`. Members use
  `resolution: workspace`, and the only lockfile is the root `pubspec.lock`.
- Strict `analysis_options.yaml` in every member.
- `.github/workflows/ci.yaml` pins Flutter `3.41.2` on the stable channel
  (D15). Every job starts with `flutter pub get --enforce-lockfile`. It has
  three jobs:
  - Format, analyze and test: format check, `flutter analyze --fatal-infos
    --fatal-warnings`, and the tests of all four members.
  - Codegen drift: gen-l10n and build_runner per app, then
    `git diff --exit-code` plus a check for new untracked files.
  - Build: the game's dev debug APK (JDK 17) and the admin's web build. iOS
    needs a macOS runner, so it is built locally.
- `.claude/`:
  - `settings.json` with permissions, and commit/PR attribution turned off.
    Write/Edit of signing material (`*.pem`, `*.keystore`, `*.jks`,
    `*.p12`, `*.p8`, `key.properties`) is denied.
  - Hooks:
    - `block-secrets` blocks secret-looking content and secret paths (env
      files, keystores, service-account JSON, flutterfire output).
    - `block-generated` blocks edits to generated files, Flutter tool
      outputs, `pubspec.lock` and `design/`.
    - `format-on-write` formats Dart files as they are written.
    - `test-on-stop` runs the core tests when core changed. It needs no git,
      and it is skipped before the first `pub get`.
  - Rules per topic, agents, and 13 skills (`/plan`, `/feature`, `/test`,
    `/milestone`, `/debug`, `/perf-profile`, `/review`, `/pr`, `/commit`
    and others).
- `.vscode/launch.json`:
  - Game: one config per flavor, plus "Game [DEV] (profile mode, physical
    device)".
  - Admin: one config per flavor, plus "Admin [DEV] (Chrome, fake
    services)", which passes `--dart-define=NESTY_FAKE_SERVICES=true`.
- `firebase/` holds the rules (the spec §14.3 sketch, semantics unchanged),
  the `levels(status, order)` index, emulator config and
  `.firebaserc.example`. The rules were checked once on the emulators (see
  Verification). The gaps found are in `firebase/README.md` and Q20.
- `.gitignore` covers build outputs, Flutter tool outputs, secrets,
  `CLAUDE.local.md` and `.claude/settings.local.json`. Generated Dart,
  `Podfile.lock`, the root `pubspec.lock`, the Xcode schemes and
  `gradle-wrapper.properties` are tracked. A scan of everything a scratch
  `git init` copy would commit found no secrets, real ad unit ids or local
  `/Users` paths. The Gradle wrapper scripts are the exception to the
  tracking list (Q27).
- `tools/README.md` lists the planned scripts. None is implemented.
- Docs:
  - Root `README.md`, and a README for each app and package.
  - `CHANGELOG.md` at `0.1.0 — skeleton` in both packages.
  - This file.
  - Spec §13.1 and §13.2 amended for D1/D2, and nothing else in the spec.

**`packages/nesty_core`** (pure Dart)
- `DollColor` covers the 11 colors of spec §12.3, each with a stable codec
  `id`. Gold has `isWild` (§3.5). A strict `fromId` throws
  `FormatException` for anything else.
- An architecture guard test fails if `lib/` does any of these:
  - imports Flutter, Flame, `dart:ui` or a platform-specific `dart:` library;
  - references `dart:math` `Random` or constructs an unseeded `Random`;
  - reads the clock (`DateTime.now()`, `DateTime.timestamp()` or
    `Stopwatch`).

  It also fails if the pubspec gains a Flutter SDK dependency. A self-test
  proves that each guard fires.
- `test/fixtures/README.md` sets the solver fixture convention.
- The README lays out the planned M1 modules.

**`packages/nesty_render`** (Flutter, no Flame)
- `DollPalette.of(DollColor)` returns a const `DollSwatch` with the exact
  §12.3 hex values. Gold uses a placeholder gradient.
- The `DollRenderer` interface (§12.6) has `prepare`, `paintDoll` and
  `dispose`. The painters themselves come in M2 and M7.
- The template `Calculator` is removed.

**`apps/game`** (Flutter + Flame, Android + iOS)
- **Startup:** `lib/main_dev|stg|prod.dart` sets `FlavorConfig`, then calls
  `bootstrap()`. bootstrap runs in `runZonedGuarded`, locks portrait, awaits
  `configureDependencies`, then calls `runApp`. Uncaught errors go through
  `FlutterError.reportError` (D17).
- **Base layer** (`lib/core/base/`):
  - `AsyncValue<T>`, a freezed sealed union.
  - `BaseAsyncCubit<T>` and `BaseAsyncBloc<E, S>`, which share one
    `runGuarded` implementation. `BaseAsyncBloc` handles events one at a
    time, in order (D16).
  - `AppException` with an `AppExceptionKind`. `AppExceptionL10n`
    (`core/extensions/`) maps each kind to an ARB string, as in the admin.
- **DI:** injectable environments `real` and `fake`. Hive is opened once
  through the `@preResolve` `DatabaseModule`.
- **Hive** (`hive_ce`): one `settings` box of primitives, holding the §13.3
  defaults. There is a typeId registry, and the game falls back to in-memory
  settings when Hive can't open.
- **Services:** all eight rule-4 services, plus `DatabaseService`, sit behind
  interfaces with offline fakes. Real implementations exist for Haptics,
  Remote Config (the 17 hard-coded §9.4 defaults) and the database.
- **Screens:**
  - An auto_route router with Splash → Home → Gameplay.
  - `GameplayPage` hosts a Flame `NestyGame` with an empty `BoardComponent`,
    between a placeholder top bar and booster bar. The booster bar fits
    320–393 dp wide phones at 1.3× text.
  - `LanguageCubit` persists the locale.
  - English ARB with 10 keys.
  - Placeholder theme tokens and a text-scale clamp at 1.3× (§16).
- **Native flavors:** dev, stg and prod on Android (product flavors) and iOS
  (9 build configurations and 3 schemes).
  - Bundle ids: `com.futrix.nesty.dev`, `com.futrix.nesty.stg` and
    `com.futrix.nesty`.
  - Minimum OS: Android minSdk 24, iOS 14.0.
  - Portrait only. Android sets `appCategory="game"` so the portrait lock
    also holds on large screens.
  - iOS stops the build when the Dart entry point or flavor doesn't match
    the scheme (D8).
- **Tests:** 13 test files (53 tests). They cover:
  - the base cubit and bloc, including event order and misuse of `on<>`;
  - DI in both environments;
  - a database contract suite shared by the Hive and fake implementations,
    plus the Hive locale stream on delete and on rollback;
  - the Remote Config defaults, haptics and the error-message mapper;
  - the cubits;
  - the booster bar at three phone sizes and two text scales;
  - the full Splash → Home → Gameplay flow with the real `GameWidget`.

**`apps/admin`** (Flutter Web)
- **Shared layer:** the same base layer, flavors, DI and bootstrap as the
  game, but no Hive and no orientation lock.
- **Auth:**
  - `AuthService` has two implementations. `FakeAuthService` serves the fake
    env. `UnconfiguredAuthService` serves the real env until M5, and nobody
    can sign in with it.
  - `AuthGuard` holds the whole access policy: signed out goes to Login,
    non-admin to Not authorized, admin to the shell.
  - `SessionCubit` follows auth changes, and `App` re-enters the router root
    whenever the session changes.
- **Screens:**
  - Login, with a form and `LoginCubit`.
  - Not authorized.
  - A `NavigationRail` shell with nine spec §15 sections. The Levels tab is
    a nested stack that includes `/levels/:levelId`.
  - Every section is a localized "Coming in M5" placeholder.
- **Tests:** 8 test files (47 tests), including 11 guard and flow tests.

### Verification (2026-09-26, in the repo)

These are the final results after the fix pass. "Docs pass" rows were re-run
at the very end, on the files as they are now. The "Fix pass" rows ran after
the last code change. The "Infrastructure pass" rows ran before the fix
pass changed code.

| Command | Outcome | Run in |
|---|---|---|
| `flutter pub get --enforce-lockfile` (root) | exit 0; `pubspec.lock` unchanged | Docs pass |
| `flutter gen-l10n` + `dart run build_runner build` in each app | 0 outputs written; all 15 generated files byte-identical | Docs pass |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found | Docs pass |
| `dart format --output=none --set-exit-if-changed` (all non-generated Dart) | 141 files, 0 changed | Docs pass |
| `cd packages/nesty_core && dart test` | 32/32 pass | Docs pass |
| `cd packages/nesty_render && flutter test` | 5/5 pass | Docs pass |
| `cd apps/game && flutter test` | 53/53 pass | Docs pass |
| `cd apps/admin && flutter test` | 47/47 pass | Docs pass |
| `flutter build apk --flavor prod -t lib/main_prod.dart` (release) | Builds (45.7 MB). aapt2: `com.futrix.nesty`, label `Nesty` | Docs pass |
| `flutter build apk --debug --flavor dev\|stg\|prod -t lib/main_<f>.dart` | All three build. aapt2: `com.futrix.nesty.dev` `[DEV] Nesty`, `com.futrix.nesty.stg` `[STG] Nesty`, `com.futrix.nesty` `Nesty` | Fix pass |
| `flutter build ios --debug --no-codesign --flavor dev\|prod -t lib/main_<f>.dart` | Both build. dev: `com.futrix.nesty.dev`, `[DEV] Nesty`; prod: `com.futrix.nesty`, `Nesty`. `pod install` left `project.pbxproj` and `Podfile.lock` unchanged | Fix pass |
| `xcodebuild -scheme dev -configuration Debug-dev` with `Generated.xcconfig` on prod | Fails as intended: "FLUTTER_TARGET=lib/main_prod.dart does not match the dev configuration" (D8) | Fix pass |
| `cd apps/admin && flutter build web -t lib/main_prod.dart` | Builds | Fix pass |
| The `ci.yaml` steps on a clean copy with Flutter 3.41.2 (macOS arm64) | With nesty_render's floor at `>=3.41.0` (the fix the fix pass then applied): `--enforce-lockfile` passes, format, analyze and tests are clean (30/5/42/45, before the fix pass added tests), codegen is identical, and the web build and dev debug APK build | Infrastructure pass |
| Firestore and Storage rules on the emulators (firebase-tools 13.35.1 in a scratch copy of `firebase/`) | Both compile; 34/34 allow/deny checks as expected | Infrastructure pass |
| `block-generated` and `block-secrets` fed Claude Code JSON for Write, Edit and MultiEdit | 116/116 block/allow cases as expected. `format-on-write` and `test-on-stop` scenarios also behave as intended | Infrastructure pass |

Not verified yet:
- `flutter run` on a device.
- iOS profile and release builds, `flutter build ipa` (needs the owner's
  signing, Q11) and Xcode Archive.
- The VS Code launch configs.
- `firebase emulators:start` from `firebase/` itself, including the Auth
  emulator. The Firebase CLI is not installed on this machine.
- CI on GitHub: there is no git repository or remote yet. The simulation
  above ran on macOS, not `ubuntu-latest`, so the Linux-only
  `grep -z`/`xargs --no-run-if-empty` format step and `setup-java` were not
  exercised. actionlint 1.7.7 passed, but without shellcheck.

## Review pass (2026-09-26)

**What was reviewed.** After the infrastructure pass, five reviews ran in
parallel over the whole repo:
- parity with the aquabuildr reference app;
- CLAUDE.md rules and spec compliance;
- Dart code in the apps and packages;
- the native Android and iOS projects;
- infrastructure: CI, hooks, settings and docs.

Each finding was then checked by a separate verifier.

| Review | Findings | Confirmed | Refuted | Uncertain |
|---|---|---|---|---|
| aquabuildr parity | 8 | 8 | 0 | 0 |
| Rules and spec | 9 | 6 | 2 | 1 |
| Dart | 6 | 5 | 1 | 0 |
| Native | 2 | 2 | 0 | 0 |
| Infrastructure | 10 | 10 | 0 | 0 |
| **Total** | **35** | **31** | **3** | **1** |

The 31 confirmed findings break down as follows:
- **2 blockers**, both with the same cause: CI pinned Flutter 3.41.2, but
  `nesty_render` required `>=3.43.0-0`.
- **2 majors:** the documented "Flutter 3.43+ stable" does not exist, and
  `BaseAsyncBloc` did not keep event order.
- **25 minors and 2 nits.**

The uncertain finding became Q28.

**Fixed in code** (the fix pass; each new regression test failed on the old
code first):
- **CI blocker:** nesty_render's floor is now `flutter: ">=3.41.0"`. The only
  lock change is `sdks.flutter`, and `--enforce-lockfile` passes (D15).
- **Bloc order:** `BaseAsyncBloc` in both apps now handles events strictly
  in order (D16). Before the fix, a fast event overtook a slow one added
  before it (`[20, 10]` instead of `[10, 20]`).
- **Booster bar:** it no longer overflows on narrow phones or at 1.3× text.
  The old bar overflowed by 170 px at 360×640.
- **Hive locale stream:** `HiveDatabaseService.languageStream` now emits the
  default locale when the key is deleted or a write rolls back. Before, it
  re-emitted the deleted or rolled-back value as if it were stored.
- **Error output:** errors now show in the `flutter run` terminal (D17).
- **iOS flavor guard:** iOS builds stop when the entry point or flavor
  doesn't match the scheme (D8).
- **Core guard:** it now bans `Stopwatch` in `nesty_core`.
- **Error messages:** the game got the admin's `AppExceptionL10n` error
  mapper, and `RetryView` takes the exception.
- **Tooling docs** in `.claude/`:
  - the copyWith idiom and unseeded cubits (D1);
  - the app-lifetime Cubit exception (D14);
  - the canonical example feature (`apps/game/lib/features/home/`);
  - the analytics fake (log-only until M4);
  - `AIza…` keys inside flutterfire output being expected;
  - the test-layout examples.

Result: tests went from 30/5/42/45 to 32/5/53/47. Generated files are
unchanged.

**Fixed in docs** (this pass): B1, Q1, Q2, Q13 and Q22 are now marked
resolved. The SDK version is corrected in CLAUDE.md, README and PROGRESS.
The CI description, the fake-services launch config, the emulator
statements and the iOS archive note are updated. D14–D17 are added.

**Not applied:**
- The `rm -rf` deny globs in `.claude/settings.json`. Changing permission
  settings is the owner's call (Q24).
- Two findings were overtaken by the infrastructure pass: the `/plan` skill
  now exists, and the tooling now describes the flat test layout the tests
  already use.

**Known gaps (not questions):**
- The hooks guard only Write/Edit/MultiEdit. A Bash redirect such as
  `echo … > .env` bypasses them, and the `settings.json` deny list doesn't
  cover it.
- The three `.metadata` files record Flutter revision `5408e0f…`, a local
  commit that doesn't exist upstream (Q23).
- The bootstrap zone handler's `FlutterError.reportError` call has no test,
  because no test calls `bootstrap()`.
- In debug, `runGuarded` prints every non-cancelled failure. Tests that
  exercise expected failures print a few extra lines.

## M1 — Core (`nesty_core`) — done (2026-09-26)

Built in parallel steps from [plans/m1-core-design.md](plans/m1-core-design.md)
(contracts, PRNG + Hash64 + parity harness, codec + validator + fixtures,
rules kernel + session, solver, simulator, generator + curve, bundle codec +
`nesty_levels`), then reviewed, fixed and integrated. The design-foundation
render work (plan phase 3: `BoardLayout`, the skin pipeline and renderers,
`BoardSprites` and `ThemeBackground`) and the 30 authored M2 levels were built
in the same round. Decisions are D26–D39; the owner confirmed their open
questions Q30–Q38 on 2026-09-26.

### Acceptance (spec §18)

| Criterion | Evidence | Result |
|---|---|---|
| All §4 rules are unit-tested | `test/rules/` and `test/session/`: every rule, every `InvalidMoveReason` with its precedence, towers, locks (first completion only), ice (cracked vs shattered), the exact event order and payloads, `legalMoves` order and completeness, won and out of moves, the §5.1 example as a 4-move scenario, undo, restart and extra slots | Pass |
| Solver fixtures pass | 8 solvable (optimal 2/3/4/5/3/2/2/12 moves), 3 unsolvable (lock deadlock, never-thawing ice, no space), and solvable 008 gives `unknown` at a 50-node budget. Every value was worked out by hand and confirmed by an independent Python implementation of §4; every solution replays through `Rules.tryMove` to `Won` | Pass |
| The generator is deterministic | 21 golden cases (level digest, attempt, tier, bot wins, solution length, nodes) and a parity suite, identical on the VM, node (dart2js), Chrome and dart2wasm; same seed + params give the same bytes | Pass |
| 100 generated levels pass validation and solve | `dart test -t slow`: bonus levels 1–100 (seed 1 000 000 + n) pass rules 1–8 on a fresh admin-budget solve and replay to `Won` (the bundle step also checked it with `nesty_levels generate --bonus 1 --count 100 --verify`) | Pass |

M1 is **done**. The benchmark targets of design §5 are not §18 criteria; two
of them are missed on exhaustive searches (below, Q32).

### M1 review and fix pass

A review of the finished M1 core and render work raised 19 findings. Each
was confirmed against the code before it was fixed (1 blocker, 3 major, 10
minor, 5 nits).

| Finding | Confirmed | Change |
|---|---|---|
| SPEC-01 (blocker) towerless L3–L15 can't meet the §6.6 pattern and A32 | Yes (proof in D26) | `BundlePolicy.checkTier` accepts a `tierOverride` on open-slot-only boards (D26, Q30); tests for both cases; `bundle check` passes |
| SPEC-02 / DETERMINISM-003 ice ≥ 2^31 wraps in `Int32List` | Yes (2^31 and 2^32 validated as solvable) | `LayoutLimits.maxIce` = 2^31 − 1: the validator reports `schema.valueOutOfRange`, `BoardLayout` refuses larger counters |
| SPEC-03 device-generated levels can be expert only | Yes (bonus 40 and 99 of 1–100) | Documented on `GeneratorSuccess.simulation`; test pins bonus 40's flag; the policy is an owner question (Q31). No behaviour change |
| DETERMINISM-001 CI never runs the web parity | Yes | CI step: `dart test -p node test/parity test/generator/golden_test.dart`, `-p chrome test/parity`, `-p chrome -c dart2wasm test/parity` |
| DETERMINISM-002 issue order and args differ on dart2js | Yes | Unknown keys reported sorted by code unit; `schema.invalidJson` has no args (the parser text stays in the message); new `test/parity/codec_parity_test.dart` |
| DETERMINISM-004 decoding quadratic in the issue count | Yes | Both decoders count errors as they are added |
| DETERMINISM-005 admin search above 64 MB; growth holds both arrays | Yes (72.3 MiB at 500k on a 72-cell board; the reviewer measured ~86 MiB for the store alone during its last doubling) | `NodeStore` grows in 1,024-row chunks (never copied, no transient); `AStarSearch.peakBytes` bounds the peak (43.6 MB for the 435k proof); the worst-case board is in the solver benchmark. 72.3 MiB held (80.3 MB peak) on that board remains: Q33 |
| DETERMINISM-006 exhaustive throughput and admin time targets | Yes (187–191k nodes/s, 2.3 s for 435,588 nodes) | `Kernel.applyLegal` skips re-checking kernel-listed moves (~3 %); the remaining gap is Q32 |
| DETERMINISM-007 guards miss the web-safe arithmetic rules | Yes (no violations in lib today) | Guards for `~`, 64-bit typed lists and `HashMap`/`HashSet`, with self-tests |
| DETERMINISM-008 snapshot decode accepts contradicting `completedSets` | Yes (RangeError from the queue) | `decode` checks that the cells lost only whole sets and that they add up to `completedSets`; FormatException tests |
| RENDER-1 the host's rim is painted over the guest | Yes | `DollPart.interior` and `DollPart.bodyFront`, `DollPaintParams.shadow`; the z-order of the design's nest frame (D37); pixel tests |
| RENDER-2 +Slot flashes the placeholder | Yes | `DollRenderer.canPaint`; `FallbackDollRenderer` uses it; re-layout test |
| RENDER-3 sealed/frozen dolls overflow on 5–6-slot rows | Yes | Dolls shrink with the crowded row's pieces (D36); the crowded test now checks sealed and frozen dolls |
| RENDER-4 top-shelf silhouettes reach the HUD | Yes | `buriedBaseY(depth, buried:)` compresses the step only when needed (D36, `TODO(design)`); top-row towers in the crowded test |
| RENDER-5 golden gate can't see the subtle symbol | Yes (all goldens passed with it removed) | Gate ≥ 99.9 % / mean < 0.5, a symbol-box gate, and negative controls (missing symbol, 100 % ink); a mutation that drops the symbol now fails 22 tests |
| RENDER-6 `BoardSprites.image` keeps every scale asked for | Yes | A miss rasterizes only when nothing held is within 10 % |
| RENDER-7 gold layers rasterized for every height | Yes (23 % of layer bytes) | Not fixed: needs a gold flag through `DollRenderer.prepare` and the cache key; deferred (BACKLOG v1.1) |
| RENDER-8 hot-path guard misses allocating constructs | Yes (no violations today) | Patterns for typed lists, `Offset & Size`, Rect/Offset makers, image/mask filters and closures, with self-tests |
| RENDER-9 dolls on fractional device pixels | Yes | Upright, unscaled dolls snap their base to the device grid |

### Benchmarks (2026-09-26, this Mac, VM JIT unless noted)

| Target (design §5) | Measured | Met? |
|---|---|---|
| Hint 30k ≤ 100 ms VM, ≤ 400 ms dart2js | 35–38 ms VM; 52–57 ms dart2js on node | Yes |
| Soft-stuck 20k ≤ 70 ms | 20–22 ms VM; 30–32 ms node | Yes |
| Solver ≥ 300k nodes/s VM | 1.28M nodes/s on a budget-limited search (the widest generator board); 191–289k nodes/s when every node is expanded | Budget-limited only (Q32) |
| Admin 500k ≤ 2 s VM, ≤ 8 s Chrome | 435,588-node exhaustive proof 2.28 s VM, 3.48 s dart2js on node | Web yes, VM no (Q32) |
| Heap ≤ 64 MB | 43.6 MB peak (37.1 MB held) for the 435k proof; 80.3 MB peak on the widest generator board (Q33) | Typical boards only |
| Simulator ≤ 250 ms/level | worst 82.7 ms (19 slots, 5 towers), mean 7.7 ms | Yes |
| Generator median ≤ 1.5 s, p95 ≤ 5 s | bonus 1–300: median 14 ms, p95 101 ms, max 252 ms; dailies 2027: median 23 ms, p95 72 ms | Yes |
| Kernel apply ≤ 1 µs, `tryMove` facade ≤ 20 µs | 45 ns, 0.4 µs (kernel step, scratch benchmark; BACKLOG M1 leftovers) | Yes |

`dart run benchmark/{solver,simulator,generator}_benchmark.dart` reproduce
them; timings vary ±15 % between runs. Memory is typed-list bytes, not RSS.

### Verification (2026-09-26, final)

| Command | Outcome |
|---|---|
| `flutter pub get --enforce-lockfile` (root) | exit 0, `pubspec.lock` unchanged |
| `dart run nesty_tools:gen_design_tokens --check` / `sync_design_assets --check` / `gen_nesty_icons --check` | all unchanged |
| `dart run nesty_tools:todo_index` then `--check` | regenerated; unchanged (83 tagged markers) |
| `dart run nesty_tools:nesty_levels bundle check` | 30 levels: OK (0 errors, 0 warnings) |
| `dart run nesty_tools:nesty_levels fixtures check` | 11 fixtures OK |
| `flutter analyze --fatal-infos --fatal-warnings` (root); `dart analyze --fatal-infos` (core, tools) | No issues found |
| `dart format --output=none --set-exit-if-changed` (all non-generated Dart) | 0 changed |
| `cd packages/nesty_core && dart test -x slow` / `-t slow` / `dart test` | 1,200 / 128 / 1,328 pass |
| `dart test -p node test/parity test/generator/golden_test.dart` / `-p chrome test/parity` / `-p chrome -c dart2wasm test/parity` | 66 / 42 / 42 pass |
| `cd packages/nesty_core && dart test -p node` (the whole suite in dart2js; VM-only files skipped) | 1,219 pass |
| `cd tools && dart test` | 183 pass |
| `flutter test` in nesty_render / apps/game / apps/admin | 466 / 63 / 47 pass |

Not run in this pass: app builds (no app code changed), the Stop hook, CI on
GitHub.

## M2 — Playable game — code complete, acceptance pending

Started 2026-09-26 (D23). The nesty_render foundation and the 30 authored
levels were built with M1 (above); phase 4 built and integrated the game
(below), and a review fix pass followed on 2026-09-27. The acceptance status
is in [M2 acceptance](#m2-acceptance-spec-18); what is left is in
[BACKLOG.md](BACKLOG.md) under "M2".

### Phase 4 C0: Lottie contracts (2026-09-26)

The owner decided that every animation ships as Lottie (D40). The contracts
stage turned that decision, `design/lottie/LOTTIE.md` and the verified
lottie 3.6.1 behaviour in `docs/plans/lottie-analysis/` into one design and a
set of frozen Dart contracts, so the phase-4 lanes can build in parallel.

- **Design:** [plans/m2-lottie-design.md](plans/m2-lottie-design.md), which is
  authoritative for everything animated and supersedes those parts of
  [plans/design-foundation-m2-design.md](plans/design-foundation-m2-design.md).
  It covers:
  - the mapping from each event to its file, with start times, cues and
    reservations (clack 537 ms, complete t0 667, unlocks and ice at t0 + 700,
    the counter at t0 + 1250, the win at the batch end + 250);
  - image-slot compensation, including the callback for animated scales;
  - the `DollPartRasters` spec, BoardFit placement and the travel-hold fix;
  - paused glass and ice compositions, text overlays, pools and reduced
    motion;
  - the hand-coded gap motions and the hand-off rules;
  - which files are M2 and which M3, lane ownership and the test plan.
- **Designer request:**
  [plans/lottie-reexport-request.md](plans/lottie-reexport-request.md).
- **Package:** `lottie: 3.6.1`, pinned exactly in `apps/game`. It adds
  `archive` 4.3.0 and `posix` 6.5.2 transitively; no locked version changed.
  See D41 and "Package reasons".
- **Frozen contracts:**
  - `apps/game/lib/features/fx/`: `FxId` (29 files), `FxSpec`
    (frames, markers, canvas, anchor, kind, travel with its holds, roles,
    image layers), `FxCue` and `FxTiming`, `FxImageSource` (`FxImageSlot`,
    `FxRaster`, `FxImageRequest`), `FxLibrary`, and `FakeFxLibrary`
    (registered for both environments).
  - `nesty_render`: the `DollPartRasters` / `DollPartSet` API. `DollPartSet`
    is complete; `prepare` is stubbed for the render lane.
  - `features/gameplay/bloc/`: the `…Effect` hierarchy, `GameplayEvent`,
    `GameplayState` (freezed), and a `GameplayBloc` skeleton with
    `GameplayStarted` implemented.
  - Service interfaces:
    - `AudioService.play(effect, {dollSize, comboStep})`;
    - `HapticPattern` with `win`, `unlock`, `iceCrack` and `button`;
    - new `SolverService` (latest wins) and `SkinService` / `LevelSkin`,
      each with a fake registered for both environments;
    - `LevelRepository.entryAt(order)`.
- **C0 probes** (scratchpad `lt/test/{anim_scale_comp,tail_hold,precomp_comp}_test.dart`):
  - a scale callback compensates the animated-scale image layers
    (`glow_ring`, `extra_slot`, `ice_shatter`) within 1 px at 3×;
  - precomp children compensate through the key path `[precomp, child]`;
  - lottie skips the travel callback only on interior holds, never after the
    last keyframe (so `doll_invalid` is fine).

#### Verification (2026-09-26)

| Command | Outcome |
|---|---|
| `flutter pub add --directory=apps/game lottie:3.6.1`, then `flutter pub get` (root) | exact pin added; path dependencies unchanged; the lock gains `lottie` 3.6.1, `archive` 4.3.0 and `posix` 6.5.2 only |
| `cd apps/game && dart run build_runner build` | 30 outputs (`gameplay_bloc.freezed.dart`, `di.config.dart`) |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `cd apps/game && flutter test` | all pass (new: fx, bloc, solver, skin, repository, DI) |
| `cd packages/nesty_render && flutter test` | all pass (new: `doll_part_rasters_test.dart`) |

### Phase 4: lanes and integration (2026-09-26)

The stage B and C lanes of [plans/m2-lottie-design.md](plans/m2-lottie-design.md)
§16 built everything against the frozen contracts; the integrator then wired
and verified the whole app. BACKLOG "M2" has the ticked items and what is
left.

- **Tools:** `sync_design_assets` ships the 29 `design/lottie/*.json` byte for
  byte to `apps/game/assets/lottie/` (never `images/` or LOTTIE.md; a stray
  PNG is removed) and validates them on sync and `--check`: the contract
  table, the hooks the game drives, and the features lottie 3.6.1 can't draw.
  `gen_fx_spec` writes `fx_spec.gen.dart` (`fxSpecs`, `fxSpecOf`), drift-checked
  in tools, in the game and in CI. The asset manifest test covers the 29 files
  (parsed with `fromBytes`, no PNG) and `bundle.json`.
- **Render:** `DollPartRasters.prepare`/`preparePlaceholder` split lid and body
  on a whole pixel row (`splitRowPx`, within half a pixel of art y 400) by
  erasing rows after drawing, because any clip changed Skia's edge
  anti-aliasing by up to 32/255. Parity with `SvgSkinRenderer` is 100 % within
  8/255 outside 388–412. `PartRasterDollRenderer` draws the rest sprites with
  the Lottie's own transform (60 dolls: 64 µs per frame). Also
  `BoardFit.toReference`/`boardSpaceOrigin`, `BoardSpriteImage.cropOrigin`,
  the glass and ice composition origins, and `SymbolRaster` for the padlock
  symbol. Classic at 150 dp × DPR 3: five colours and the silhouette are
  5.94 MB, prepared in 35 ms.
- **FX runtime:** `AssetFxLibrary` (one file per event-loop turn, the loader
  first; a file that doesn't match its spec is left out), `FxImages`,
  `FxDelegates` (every workaround of D43), the pure `FxPlayer`/`FxPlan`,
  `LottieFxComponent` (driven by the board's tick, with a cached rest picture
  for glass and ice), `LottieFxView` with the Flutter text overlay (D44), and
  fixed pools. The equivalence sweep fails 32 cases when the compensation is
  broken on purpose.
- **Timeline:** `BoardTimeline` is pure Dart and plans each effect from the
  files' frames: the §7 times are pinned by 86 tests (clack 536.7 ms, bonk 180,
  complete 666.7, dust and sparkles from 1366.7, counter 1916.7, Won at the
  batch end + 250). Sprite hand-offs are counted hides plus `SyncSlot`
  commands; a later plan for a clip cancels the earlier one's pending commands;
  sparkle tails don't delay Won (Q53). `WinOverlaySchedule` times the win
  overlay.
- **Services:** `SoLoudAudioService` (the clack rate precomputed per size,
  silent failure), token haptic patterns, `IsolateSolverService` (one worker,
  latest wins), `BundledLevelRepository` (validator rules 1–7 at splash; an
  invalid level is skipped, Q43), `InMemorySaveService` with the booster
  wallet, `SymbolsMode.large`, and `AssetSkinService` + `LevelSkinImages` (the
  `FxImageSource`) with a placeholder fallback chain that never throws (D54).
- **Bloc:** every §11 handler on `GameSession`, `tap_policy.dart`,
  `win_reward.dart`, `NextLevelPressed` and `GameplayStatus.allLevelsDone`
  (D55). A hint is charged only when it arrives; results for an older
  `moveSeq` are dropped.
- **UI:** `AppTheme` from the tokens, the tactile component kit
  (`core/ui/nesty_ui.dart`: surfaces painted as the prototypes' box shadows,
  buttons, pills, booster buttons, sheets, banners, toggles), the Lottie label
  painter, and all 62 M2 ARB keys.
- **Flame board:** `NestyGame` and `BoardComponent` (input forwarded only, 48 dp
  column hit tests, the drag clamped to the board frame), `ShelfLayer`,
  `SlotComponent` (paused glass and ice with cached rest pictures, static
  fallbacks), `NestComponent`, `FxLayer`, `HintLayer`, and reconciliation with
  core's state at every idle. It handles Flame's one-tick delay for adding and
  removing components (a new level, a late library, a resize during the
  re-pitch).
- **Screens:** the gameplay page (frame 2.2) with the HUD, booster bar,
  soft-stuck banner and chapter ribbon; the win overlay (2.8), out-of-moves
  sheet (3.5), Pause (3.9) and All Levels Done (4.9); Splash (1.1) with real
  load progress; the Home hero (2.1); the dev level picker; and a guard that
  keeps Home and Gameplay behind the loaded levels (D56).

#### Integration (stage D)

- **DI:** the real environment resolves `SoLoudAudioService`,
  `SystemHapticsService`, `IsolateSolverService`, `BundledLevelRepository`,
  `AssetSkinService`, `AssetFxLibrary` and `InMemorySaveService`; the fake
  environment the fakes, with `FakeLevelRepository.fixtures()` (levels 1–3).
  `di_test` checks both.
- **`test/app_flow_test.dart`** runs Splash → Home → PLAY → the laid-out board
  (2 shelves × 3 slots, one component per slot) → a tap on red2's column that
  goes Flutter gestures → Flame → the bloc and selects it → Pause → Home. It
  replaces the screens lane's `home_flow_test.dart`, which covered the same
  path without the board checks.
- **On-device playthrough** (D57): `integration_test/playthrough_test.dart`
  runs the dev flavor with every real service. It plays L1 and L2 to the win
  overlay and L16 into Out of Moves (one move: the r1c1 tower's top onto the
  only empty stand, the shortest Out-of-Moves line a breadth-first search found
  in levels 1–30), then Restart, Pause and Home. Taps land on slot centres
  from `BoardLayout`, checked against the board's own layout;
  mid-animation screenshots are taken at a fixed time of the board's timeline
  with the engine paused. `test_driver/integration_test.dart` saves the 18
  screenshots on the host.
- **iOS flavor guard (D8 amended):** the Run Script accepted only
  `main_<flavor>.dart`, so `flutter drive` failed. It now also accepts an
  `integration_test/*.dart` target, in `Debug-<flavor>` only. `pod install`
  added the `integration_test` pod and a "[CP] Embed Pods Frameworks" phase
  (`Podfile.lock`, `project.pbxproj`).
- **Package:** `integration_test` and `flutter_driver` (SDK) as game dev
  dependencies (rule-9 rows below).
- No compile or analyzer error needed fixing: the lanes left the tree green
  except the two expected failures (`di_test`'s real-environment flips and the
  old `app_flow_test`).

#### On-device playthrough results (2026-09-26)

Both runs pass with no Flutter error, no overflow and no board
reconciliation: every slot's view matched core's state at every idle.

- **iPhone 16 simulator, iOS 18.3** (393×852): 28 s for the whole flow.
- **Android emulator, API 35, 1080×1920 at 420 dpi** (411×731 dp, 1.5 GB
  RAM): 32 s. Google Play services crash-loop on this image ("NetworkCapability
  37 out of range"); the game is unaffected.

Compared with the App Flow frames at 390×844 (the renders of 1.1–4.9):
- Splash (1.1) and Home (2.1) match, minus the M3 pieces (tiles, bottom nav,
  the coin pill's "+", an enabled gear) and plus the dev picker. The splash's
  first frames drew the placeholder dolls until the skin loaded (Q58, since
  fixed: they fade in with the art).
- The board (2.2), a selection (2.3), the nest (2.4, the lid up and the mover
  dropping in), the completion (2.5, the hop, then the flight with the dust
  puff) and the swallow (1.6's move, the lid open mid-air) match. The booster
  badges are absent because the dev flavor's boosters never run out.
- The win overlay (1.5, 2.8) matches, minus the ×3 button (M6) and the locked
  figurine art (M3). The HUD's coin pill already shows the new balance while
  the overlay counts "+10" up (Q57, since fixed: the HUD holds the old
  balance until the next level).
- Out of Moves (3.5) and Pause (3.9) match; the Undo row has no "Free · N
  left" chip in the dev flavor, the +1 Slot row no price (M3/M6), and Settings
  is disabled until M3.

#### Verification (2026-09-26, integration)

| Command | Outcome |
|---|---|
| `flutter pub get` (root), then `flutter pub get --enforce-lockfile` | The lock gains `flutter_driver`, `fuchsia_remote_debug_protocol`, `integration_test` (SDK), `process` 5.0.6, `sync_http` 0.3.1 and `webdriver` 3.2.0; no locked version changed |
| `gen_design_tokens`, `sync_design_assets`, `gen_fx_spec`, `gen_nesty_icons` with `--check` | all unchanged (29 Lottie files, 29 specs, 48 glyphs) |
| `dart run nesty_tools:todo_index`, then `--check` | regenerated after the lanes (100 markers) and again after the integration's test changes: 98 tagged markers; unchanged |
| `dart run nesty_tools:nesty_levels bundle check` | 30 levels OK, 0 errors, 0 warnings |
| `cd apps/game && flutter gen-l10n && dart run build_runner build` | no generated file changed (hashes compared) |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `dart format --set-exit-if-changed` over every non-generated Dart file | 0 changed |
| `cd packages/nesty_core && dart test -x slow` | 1,200 pass |
| `cd packages/nesty_render && flutter test` | 520 pass |
| `cd apps/game && flutter test` | 903 pass |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` | 269 pass |
| `flutter drive --flavor dev --driver test_driver/integration_test.dart --target integration_test/playthrough_test.dart` on the iPhone 16 simulator and on the API 35 emulator | both pass, 18 screenshots each |
| `flutter build apk --debug --flavor dev\|stg\|prod -t lib/main_<f>.dart` | all three build: `com.futrix.nesty.dev` `[DEV] Nesty`, `.stg` `[STG] Nesty`, `com.futrix.nesty` `Nesty`; 29 Lottie files, no PNG |
| `flutter build ios --debug --no-codesign --flavor dev\|prod -t lib/main_<f>.dart` | both build; prod: `com.futrix.nesty`, `Nesty` |
| `cd apps/admin && flutter build web -t lib/main_prod.dart` | builds |

### M2 review and fix pass (2026-09-27)

A review of the integrated game raised 13 findings: 2 major, 9 minor and 2
nits. Each was confirmed with a probe on a snapshot of the tree before it was
fixed, and each fix comes with a regression test. Twelve are fixed and one
is the owner's call (Q59). The behaviour decisions are D58.

| Finding | Severity | Outcome |
|---|---|---|
| PERF-RULES-1: a looping widget Lottie repaints its whole page layer at 60 fps | major | **Fixed.** `LottieFxView` paints in its own `RepaintBoundary`, so a playing clip repaints only itself and a resting one replays its layer. The probe's sibling surface went from 31 paints in 30 frames to 1 (`lottie_fx_view_test`) |
| CORRECTNESS-1: Continue shows the next level with the previous level's skin, whose missing colours draw nothing | major | **Fixed.** The win overlay prefetches the next level's art for the layout the board will give it (`LevelSkinLoader.prefetch`, `GameplayBoard.layoutFor`). Continue waits for it (at most 2 s), and the layout the board reports adopts it in the same update, so the level's first frame draws its own dolls (`level_skin_loader_test`, `gameplay_view_test`; the playthrough now checks it on the device) |
| CORRECTNESS-2: Undo or Restart pressed mid-drag leaves the drag live, and its release applies a phantom move | minor | **Fixed.** The bloc ends the drag with the reset; the board's reset ends the live drag, and its release sends nothing (bloc and board tests) |
| CORRECTNESS-3: a drag released while paused keeps the nest selected and parks the doll where the finger was | minor | **Fixed.** A drop while paused puts the doll down (`SelectionChangedEffect(previous, byDrag)`), which flies it home on Resume. The dragged doll stays where it is drawn while paused (bloc and board tests) |
| CORRECTNESS-4: +1 Slot twice within the 300 ms re-pitch makes the bottom row jump | minor | **Fixed.** A second re-pitch waits for the running one and starts from its end layout, where the row really is; a queued re-pitch that a resize overtook is skipped (timeline and board tests; the step went from 29 px to at most 4.4 px per frame) |
| FIDELITY-1: the 1.5× `fx_sparkle` over the counter when a family lands is never drawn | minor | **Fixed.** `onFamilyLanded` carries the scale to the HUD, and `FamilyCounter` bursts a 96 × 96 `fx_sparkle` on the counter's centre with the bump, drawn only while it plays |
| FIDELITY-2: the winning batch greys the pause button and the boosters for about 2.4 s | minor | **Fixed.** At Won the HUD and the booster bar keep their look and only swallow touches (`locked`), as frame 2.5 draws them |
| FIDELITY-3: the subtle belly symbol lacks the cream disc the App Flow boards draw | minor | **Not changed: owner decision Q59 (2026-09-27), bare ink.** The prototype preview art has the disc; tokens.json, README §3, the generator and `skins/classic/renders` don't |
| FIDELITY-4: every return to Home flashes placeholder dolls | minor | **Fixed.** Home keeps the showcase rasters while a level covers it (D58: the part-raster cache holds them anyway) |
| FIDELITY-5: after L30, Home's PLAY reads "Level 31" | minor | **Fixed.** It reads "PLAY · All done!" (screen reader: "You've finished all levels!") and opens All Levels Done. `TODO(design)` until M3's Bonus Endless |
| FIDELITY-6: soft stuck suggests Undo when Undo is impossible | minor | **Fixed.** With nothing to undo the banner suggests Restart ("Try Restart? You can keep playing too.") and Undo doesn't glow. What it suggests holds while it slides out. `TODO(design)` |
| PERF-RULES-2: `LottieLabelPainter.paint` allocates an `Offset` per frame | nit | **Fixed.** The text origin is computed per layout; the file is under the FX hot-path guard |
| PERF-RULES-3: percent semantics and the "+N" tag built outside ARB | nit | **Fixed for the percent** (`progressPercent`, the locale's percent format). The "+N" tag and ice badge digits are `TODO(M7)` for the translations, since every launch language writes "+3" the same way |

Also in this pass:
- The four `TODO(M2)` markers moved to their milestones. The unlock-symbol
  raster swap went to M5, because the first locked levels (L31+) ship with its
  bundle. The tabular figures went to M7 (Q29), and the load-failure copy to
  `TODO(design)`.
- Three ARB keys were added: `progressPercent`, `homeAllLevelsDone` and
  `softStuckBodyRestart`, each with a description. The game now has 65 M2
  keys.
- `GameplayBoard` gained `layoutFor`, and
  `GameplayBoardCallbacks.onFamilyLanded` gained the sparkle scale. Both are
  page-internal seams.

### M2 acceptance (spec §18)

Spec §18 M2: "Levels 1–30 can be played start to finish at 60 fps on a
mid-range Android device."

| Part | Status | Evidence |
|---|---|---|
| Levels 1–30 are valid, solvable and on the §3.7/§6.6 schedule | **Pass** | `nesty_levels bundle check`: 30 levels, 0 errors, 0 warnings (CI runs it) |
| They play start to finish in the app | **Pass on the automated path; the manual pass is open** | The playthrough plays L1 and L2 to the win overlay (with Continue and each next level's own art) and L16 into Out of Moves on the iPhone 16 simulator; `app_flow_test` plays Splash → Home → a board tap → Pause → Home; the bloc and board suites cover every §2–§4 flow. The manual L1–30 pass on the dev flavor (BACKLOG M2) is still to do |
| At 60 fps on a mid-range Android | **Needs the owner's device** | A simulator, an emulator and a debug build don't count (`.claude/rules/flame.md`), so this can't be measured here. The code side is ready: the hot paths are guarded against allocation, widget Lotties no longer repaint their pages, and the solver runs in an isolate |

**How to run the 60 fps check (the owner, with `/perf-profile`):**
1. Use a physical Android phone, mid-range or better yet the 2 GB phone rule 8
   targets. Note its model, RAM and Android version.
2. From `apps/game`, run
   `flutter run --profile --flavor dev -t lib/main_dev.dart -d <device>`, or
   the VS Code config "Game [DEV] (profile mode, physical device)". Keep
   Impeller (the default).
3. Open DevTools from the URL `flutter run` prints (Performance, then
   Memory), or press `P` for the performance overlay.
4. Play these flows three times each:
   - Splash → Home, with the idle dolls and twinkles for 10 s;
   - L1 → L2 by Continue, with the completion (hops, flight, dust, sparkle
     trail, the counter bump and its sparkle) and the win overlay (ribbon,
     confetti, hopping families, coin burst);
   - L16, with the tower reveals and an invalid move onto a tower;
   - a drag, +1 Slot twice, and Pause → Resume;
   - Home ↔ a level, twice.
   The dev flavor's "Jump to a level" reaches L16 and any other level.
5. It passes when the UI and raster threads both stay under 16.7 ms per frame
   during moves, completions and the win overlay (no red bars, no GC spike
   during a move), and a level's GPU images stay near the §4 budget (about
   12 MB typical, 25 MB at most).
6. Record the device, the build and the frame numbers here, then tick the two
   M2 items in BACKLOG. If a flow misses, `/perf-profile <flow>` walks
   through the usual suspects.

#### Verification (2026-09-27, fix and close)

| Command | Outcome |
|---|---|
| probes of the review (`scratchpad/rv/nesty/apps/game/test/zz_review/`) on a snapshot of the tree | every finding reproduced before the fixes |
| `flutter pub get --enforce-lockfile` (root) | passes: no dependency or lock change |
| `cd apps/game && flutter gen-l10n && dart run build_runner build` | the 3 new ARB keys generated; build_runner changed no file (hashes compared) |
| `gen_design_tokens`, `sync_design_assets`, `gen_fx_spec`, `gen_nesty_icons` with `--check` | all exit 0 and unchanged (29 Lottie files, 29 specs, 48 glyphs) |
| `dart run nesty_tools:todo_index`, then `--check` | 102 tagged markers (4 new; the 4 `TODO(M2)` retagged), unchanged on the check |
| `dart run nesty_tools:nesty_levels bundle check` | 30 levels OK, 0 errors, 0 warnings |
| `dart format --output=none --set-exit-if-changed` over every non-generated Dart file | 593 files, 0 changed |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `cd packages/nesty_core && dart test -x slow` | 1,200 pass |
| `cd packages/nesty_render && flutter test` | 520 pass |
| `cd apps/game && flutter test` | 929 pass (903 before the pass; 26 new regression tests) |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` | 269 pass |
| `NESTY_SCREENSHOT_DIR=… flutter drive --flavor dev --driver test_driver/integration_test.dart --target integration_test/playthrough_test.dart` on the iPhone 16 simulator (iOS 18.3) | passes in 118 s with 18 fresh screenshots (scratchpad `m2_screens_final/ios/`); Continue to L2 and L3 now also asserts each level's own skin in its first laid-out frame. The first attempt failed to build: the integration's cleanup had deleted `apps/game/build/` but not `apps/game/.dart_tool/flutter_build/`, whose stamps still said the iOS native assets were built (README "Troubleshooting", BACKLOG "Tech debt") |
| `flutter build ios --debug --no-codesign --flavor dev -t lib/main_dev.dart` | builds (after the same stamp cleanup) |
| `flutter build apk --debug --flavor dev -t lib/main_dev.dart` | builds `app-dev-debug.apk` |
| `cd apps/admin && flutter build web -t lib/main_prod.dart` | builds |

The screenshots match the integration's, with the fixes visible: the HUD and
the booster bar at full strength while the set flies (05b), level 2's blue
dolls drawn from its first frame (07), and Home's shelf with its skin art on
the way back (13). Afterwards the simulator was shut down, and the build
folders were removed together with `apps/game/.dart_tool/flutter_build/`.
Nothing was committed.

## Post-M2 round: Claude Design v3 and audio (2026-09-27)

After M2 was committed (2351b1e, 2f17181), Claude Design delivered two
exports: the audio export (two music loops, three jingles, the SFX v2 WAVs,
`AUDIO.md` and new `sound` tokens; the owner's zip (3)) and the v3 overlay
(the Lottie files and PNGs re-exported against our v2 request, LOTTIE.md v3,
re-rendered jingles, two token wording changes; zip (5)). The check workflow
verified both ([plans/claude-design-v3-check.md](plans/claude-design-v3-check.md)),
the owner answered the open points, and four lanes imported and wired them
in. The decisions are D59 (v3), D60 (the v3 Lottie runtime) and D61 (music
and jingles); the owner's audio answers are Q61–Q63. BACKLOG "Post-M2 round"
has the ticked items and what is left.

- **Import and tools** (D59): `design/` rebuilt in overlay order (repo ←
  audio export ← v3), hash-identical to the checked staging (381 files);
  `export/` removed; the designer's notes and our analyses copied under
  `docs/plans/`. The Lottie contract follows LOTTIE.md v3 (3× board pieces,
  `doll_reveal` 31 f with its `drop` null, `fx_ice` 150 f with `rest_n` and
  `crack_hit_n`, 410-wide ribbons, six new parent nulls), and the validator
  now rejects what v3 promises away (`hold`, `imageTransform`).
  `sync_design_assets` ships the 5 OGGs next to the 17 WAVs and checks both
  formats byte by byte (WAV: 44.1 kHz mono 16-bit PCM; OGG: one Vorbis
  stream, 44.1 kHz stereo, every page's CRC) and each loop's length against
  its `frames` token. `gen_design_tokens` maps the new `sound` leaves
  (`jingleFiles`, `musicFiles`, `clackBakedSemitones`, the loops, fades and
  ducks) and the reworded `motion.reveal.type` and `layout.towerSilhouettes`.
- **Lottie runtime** (D60): every v1 workaround is gone (the travel-hold
  fix, the `padlock_ping` rest hide, the 11 dp glass settle, the reveal
  silhouette hide, the hand-coded reveal drop and the animated-scale
  callbacks). `doll_reveal` drops the new top from its own buried step;
  an ice hit with no stage change plays `crack_hit_n`; every jump re-seeks
  lottie cleanly (the frame-99 double draw); the ribbons use the 410-wide
  canvases, their text boxes and `min(1, W/390)` on screen. Buried nests
  draw the wood-grain blank for every skin (3e), and the reveal wipe grows
  from art (256, 476) (3d).
- **Audio** (D61): one `SoLoudEngineHost`; the SFX v2 at 0 baked
  semitones; `JinglePlayer` on the SFX bus; `MusicService` with a real
  SoLoud implementation (streamed loops, crossfade, ducks, pause reasons,
  the Music setting) and a fake; `MusicRouteObserver`, `MusicDuck` and
  `JingleCues`; the iOS `.ambient` session (Q61); low latency in prod only
  (Q63).
- **The owner's Level 9 report** (device screenshots, 2026-09-27): the hint
  arrow sat up and left of its doll, the glow ring at the shelf's left end,
  the +1 pads were slivers, and the arc's head pointed at an empty stand.
  The first three were one bug, the raster units after the move to v3's 3×
  image sizes (D60 "Root cause"); the arc now arrives on the source's side
  of the target (D60 "Hint arc"). `board_pieces_l9_test` pins all of it to
  `BoardLayout`.

#### Integration

- **Handoffs applied:** the skin service passes its board library to
  `DollPartRasters` (`DollPartSource.prepare(board:)`), so decision 3e shows
  in the running game; `app_flow_test` follows the music (home after the
  splash, game in the level, ducked under Pause, home again);
  `SlotGeometry.unlockedDollBaseY`'s comment says the v3 file lands the doll
  itself; `docs/TODO_INDEX.md` regenerated (102 markers: the audio lane's
  `TODO(M3)`/`TODO(M6)` hooks in, the SFX placeholders' `TODO(M7)`s and
  `FxTiming.revealDropMs`'s out); the READMEs' audio, playthrough and
  status notes.
- **Self-review against the hard rules:** `_Drop.position` (a per-frame
  Lottie callback) built two `Offset`s per call; it now builds the one the
  callback must return (D42). The new hot paths (`FxPlayer.epoch`,
  `FxDrawable.draw`'s re-seek, the hint arc, `RevealDropTween`) allocate
  nothing per frame, and the re-seek only runs on a jump (the splash
  loader's seeks follow load progress, not frames). Every service added
  has a fake registered for `AppEnv.fake` (`FakeMusicService`,
  `FakeAudioService` as the `JinglePlayer`); no user-facing string was
  added outside ARB; every new `TODO` is tagged. No package was added
  (Package reasons).
- **The playthrough** now also plays Level 9 (Hint, +1 Slot twice, a doll
  onto an extra slot: frames 3.1 and 3.6), shows Level 16's tower reveal,
  toggles Music off and on in Pause and opens Level 21's chapter ribbon. It
  checks the real `SoLoudMusicService`'s state on each screen (`music_home`
  on Home, `music_game` in a level, ducked to 0.3 under the win overlay, 0.4
  under Out of Moves, 0.5 under Pause, silent with Music off), that every
  Lottie file, the 17 SFX and the 3 jingles loaded, that neither loop failed,
  and that nothing was logged under `[nesty.audio]`, `[nesty.music]` or
  `[nesty.fx]`.

#### On-device playthrough results (2026-09-27)

Both runs pass with every real service, and nothing was logged under
`[nesty.audio]`, `[nesty.music]` or `[nesty.fx]`.

- **iPhone 16 simulator, iOS 18.3** (393×852): 166 s with the build, 46 s
  for the flow, 25 screenshots.
- **Android emulator, API 35, 1080×1920 at 420 dpi** (411×731 dp): 177 s
  with the Gradle build, 70 s for the flow, 25 screenshots. At the end
  `flutter drive` fails to uninstall `com.futrix.nesty` (the dev flavor
  installs `com.futrix.nesty.dev`); the test had already passed.

Compared with the App Flow frames and the `Lottie FX` prototype (served
over http and rendered headless):
- **Level 9's hint (3.1):** the arrow at full size over brown3 (r0c1), the
  glow ring on brown2's stand (r1c0), and the dashed arc from brown3's upper
  body to beside brown2's head, its arrowhead heading into it, as 3.1 draws
  its arc. The owner's device screenshots had the arrow up and left, the
  ring at the shelf's end and the arrowhead at the empty r1c1. One
  difference remains: Level 9's top-row doll is taller than any in the
  frames (the board-wide clamp, BACKLOG "Design gaps"), so at the top of its
  bob the arrow grazed the family counter pill's left edge. Fixed after the
  round by D62: it now steps off the pill and under the pause row.
- **+1 Slot twice (3.6):** two green "+1" pads at stand size on the bottom
  shelf, as 3.6 and the `ui_extra_slot` preview draw them; with five slots
  on that row the dolls shrink board-wide (D36). A doll moved onto the
  first pad stands on it with the pad drawn under it.
- **Ribbons:** "Level Complete!" and "CHAPTER 2 · Rainy Café Corner" fit
  their bands, which match the v3 previews; at rest the tails end 6.7 dp
  inside each edge of the 393 dp screen. The chapter ribbon sits where
  frame 4.7 puts its card, over the top row's heads, for its 2 s (Q50 is
  still the look).
- **Level 16's tower reveal:** the Android shot caught the new top as the
  wood blank on the stand after its drop (3e), the iOS shot the colour wipe
  with its splash drops; the deeper silhouettes are the wood blank too.
- **Glass and ice** first appear at L31 and L51, so the playthrough can't
  show them. `fx_workarounds_test` checks the freed doll landing at canvas
  y 174 in the shipped file; `fx_spec_drift_test`, `board_effects_test` and
  `board_timeline_complete_test` check the ice's `rest_n` and `crack_hit_n`
  segments.

#### Verification (2026-09-27, post-M2 round)

| Command | Outcome |
|---|---|
| design/ hashed against the checked v3 staging | 381 files, identical, no `.DS_Store`; `export/` gone |
| `flutter pub get --enforce-lockfile` (root) | passes: no dependency or lock change |
| `cd apps/game && flutter gen-l10n && dart run build_runner build` | no generated file changed (hashes compared) |
| `gen_design_tokens`, `sync_design_assets`, `gen_fx_spec`, `gen_nesty_icons` with `--check` | all exit 0 and unchanged (496 token leaves, 473 emitted; audio 22 files, Lottie 29; 29 specs; 48 glyphs) |
| `dart run nesty_tools:todo_index`, then `--check` | 102 tagged markers, unchanged |
| `dart run nesty_tools:nesty_levels bundle check` | 30 levels OK, 0 errors, 0 warnings |
| `dart format --output=none --set-exit-if-changed` over every non-generated Dart file | 620 files, 0 changed |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `cd packages/nesty_core && dart test -x slow` | 1,200 pass |
| `cd packages/nesty_render && flutter test` | 526 pass (520 before the round) |
| `cd apps/game && flutter test` | 1,045 pass (932 before the round) |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` | 299 pass (269 at the M2 close) |
| `NESTY_SCREENSHOT_DIR=… flutter drive --flavor dev --driver test_driver/integration_test.dart --target integration_test/playthrough_test.dart` on the iPhone 16 simulator (iOS 18.3) | passes in 166 s, 25 screenshots; the dev build compiles `AppDelegate.swift`'s `.ambient` session |
| the same on the API 35 emulator | passes in 177 s, 25 screenshots |

Afterwards the iPhone 16 simulator and the emulator were shut down. Nothing
was committed.

## M3 — App shell and meta — code complete, acceptance pending

Started 2026-09-27 (D63–D65), before M2's device checks, at the owner's
request. The contracts stage froze [plans/m3-design.md](plans/m3-design.md)
(D66–D80); the stage-2 lanes (core codec, UI kit and ARB, services, the
gameplay bloc) and the stage-3 lanes (gameplay screens, shop, daily and
museum, shell/Home/Settings) built it; the integrator ran the gates and the
device checks on 2026-09-28; a three-lens review (fidelity, correctness,
rules) and its fix pass followed. What is left is in
[BACKLOG.md](BACKLOG.md) under "M3" (the owner's two physical-device checks)
and the later sections it moved items to.

### Done

- **Save (D63, D67, D68):** `HiveSaveService` over `DatabaseService`'s
  `save` box: one JSON document, schema 1 with migrations and backups that
  are never overwritten, a lenient codec, a serial coalescing write queue,
  `SaveLifecycleFlusher` on paused/detached, and the in-memory fallback
  when Hive can't open. The in-progress board (`GameSessionCodec` format 1,
  D69) is written after every move, undo, restart and +1 Slot and restored
  when the request, level id and `levelVersion` match; a generated board
  restores from its embedded level. A restored board takes its status from
  core, so a saved out-of-moves or won board reopens its sheet or its win
  (D88).
- **Economy (§7.3, D64, D72, D73):** the rewards and prices from Remote
  Config (`reward_medium` defaults to 10), the booster inventory with the
  starter gift, the coin path of Undo, Hint and +1 Slot with the buy popup
  (3.2, 3.3) and the priced Out-of-Moves rows (3.5); a win, a chapter and
  the daily each pay once, in one save update.
- **Progression:** chapters of 20 with their themes, Chapter complete (4.6)
  with the figurine, the Museum (6.1–6.3) with collected dates, Bonus
  Endless (4.9, 4.10) through `DefaultLevelResolver` and the isolate
  `IsolateLevelGeneratorService` (D70, D74).
- **Daily (§7.5, D76):** `seed = yyyymmdd` through the injected `AppClock`
  (`NESTY_FAKE_DATE` in debug), unlocked after Level 2, the streak with the
  weekly freeze (`StreakDailyService`), and the screens 5.1–5.6.
- **Onboarding (D78):** the scripted L1/L2 tutorial (1.3–1.6) and the
  mechanic intro cards (4.1–4.3), each once per save.
- **Menus:** the shell (Shop · Home · Museum), Home (2.1), Settings (8.1)
  with the language sheet (8.2), the Shop (7.3, 7.4, 7.7; Coins and No Ads
  show the store-closed card until M6, D75), `AppInfoService`,
  `LinkLauncher`, every string in ARB, and the jingles and music by screen.
- **Integration (2026-09-28)** found and fixed five app bugs, each with a
  regression test that fails without the fix: Home's refresh looped forever
  once a move changed the save (`StreakDailyService` fired `changes` on
  every refresh, D81); the Daily route threw on open (a test-only
  constructor parameter reached DI; `di_test` now resolves every page
  cubit); "Back to Daily" never left the level (D85); the Out-of-Moves sheet
  showed 0-coin prices; and Home's tiles sat under the nav on a 16:9
  Android body (D84).
- **Review and fix pass (2026-09-28):** 23 findings (fidelity 12, 6 major;
  correctness 8, 2 major; rules 3 minor), no blocker. 22 were fixed in three
  parallel lanes, each with a regression test that failed first; the 23rd
  (five `TODO(design)` markers without a BACKLOG line) was fixed in the
  close-out. The majors: a restored out-of-moves board came back "playing";
  the showcase cache disposed a skin rasterizer still in use, so Shop cards
  fell back to placeholder dolls (now reference-counted); Chapter complete
  titled the chapter instead of the figurine; the Daily preview drew
  placeholder dolls; no theme read "In use" while matching the chapter; the
  L1 tutorial drew no arc; the skin detail panel was Ocean's for every skin;
  and the intro cards lacked their board pieces. One residual (the Daily
  preview's chapter background) moved to M7.
- **The owner's report (2026-09-28): no hand on the L2 swallow step (1.6).**
  `ui_drag_hand` is a board-space file (390×844, LOTTIE.md) but was drawn
  in a 58 px box, which shrank its whole canvas to a speck. It now covers
  the board with its `travel` remapped from the tap point on the big doll
  to the target's surface − 0.4 × its height ("Travel remap"), and
  `ui_tap_hand` draws at its 128×144 canvas with the fingertip (48, 32) on
  the doll. Three regression tests in `tutorial_overlay_test.dart`.
- **Device checks** on the iPhone 16 Pro simulator (iOS 18.3) and the API 35
  emulator: the two-phase kill and resume, the daily fingerprint and the
  playthrough (49 screenshots each), all passing after the fix pass (see
  the Verification table). README "Testing" has the commands.

### M3 acceptance (spec §18)

| Criterion | Status | Evidence |
|---|---|---|
| Kill the app mid-level and it resumes exactly where it was | **Pass on the simulator and the emulator; the physical-phone check is the owner's** | Round-trip tests (codec, Hive, bloc, `app_flow_test` (a) through a real Hive directory). On device: `resume_phase_a_test` wins L1–L2, opens L3 from Home's PLAY, plays two moves, an undo and a +1 Slot and a move onto it; the app is killed (`xcrun simctl terminate` / `adb shell am force-stop`); `resume_phase_b_test` taps PLAY and gets the same board. iOS phase A/B and Android phase A/B: level 3, 1 free undo left, 1 extra slot, the same 822-character session fingerprint (sha1 `6cb23b8be4544166`) all four times |
| The daily puzzle is identical on two devices on the same date | **Pass on the simulator and the emulator; the two-phone check is the owner's** | The 28-date goldens on the VM, node, chrome and wasm. `daily_fingerprint_test` at `NESTY_FAKE_DATE=20260926`: the iOS and the Android level JSON are byte-equal to the core's own `generateWithRetries(dailyParams(20260926))`, Hash64 `7716bec2334e7d9a`, the committed golden |

The owner's steps are the two items at the top of BACKLOG "M3".

### Decisions

D81–D89 (below, in the Decisions log).

### Packages added

`package_info_plus` 10.2.1 and `url_launcher` 6.3.2 (D80; reasons under
"Package reasons"); `hive_ce_generator` removed. The fix pass added none.

### Open questions

None new. Q67–Q75 (the M3 defaults) stay open with their defaults shipped.

### Verification (2026-09-28, after the fix pass)

| Command | Outcome |
|---|---|
| `flutter pub get` (root) | the lock is unchanged |
| `cd apps/game && flutter gen-l10n && dart run build_runner build`; the same in `apps/admin` | no generated file changed (checksums before and after); the admin tree unchanged |
| `gen_design_tokens`, `gen_nesty_icons`, `sync_design_assets`, `gen_fx_spec` with `--check` | all exit 0, unchanged |
| `dart run nesty_tools:todo_index`, then `--check` | 103 tagged markers, no `TODO(M3)`, unchanged on the check |
| `dart run nesty_tools:nesty_levels bundle check` / `fixtures check` | 30 levels OK / 11 fixtures OK, 0 errors, 0 warnings |
| `dart format --output=none --set-exit-if-changed`, CI's exclusions, tracked and untracked files | 768 files, 0 changed |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `cd packages/nesty_core && dart test` | 1,506 pass |
| `dart test -p node test/parity test/generator/golden_test.dart`; `-p chrome test/parity`; `-p chrome -c dart2wasm test/parity` | 73 / 49 / 49 pass |
| `cd packages/nesty_render && flutter test` | 530 pass |
| `cd apps/game && flutter test --timeout 90s` | 1,526 pass (three full runs green; the Daily and Settings suites also 3/3 under load) |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` | 304 pass |
| `flutter drive --keep-app-running … resume_phase_a_test.dart`, the real kill, then `… resume_phase_b_test.dart`, on each device | pass on iOS and Android; the four fingerprints equal |
| `flutter drive … daily_fingerprint_test.dart --dart-define=NESTY_FAKE_DATE=20260926`, on each device | pass; both `7716bec2334e7d9a`, equal to the core's |
| `NESTY_SCREENSHOT_DIR=… flutter drive … playthrough_test.dart --dart-define=NESTY_FAKE_DATE=20260926`, from a fresh install | iOS passes in 144 s, Android in 175 s, 49 screenshots each, compared with the App Flow frames |
| `flutter build apk --debug --flavor dev -t lib/main_dev.dart`; `flutter build apk --flavor prod -t lib/main_prod.dart`; `flutter build ios --no-codesign --flavor dev -t lib/main_dev.dart`; admin `flutter build web -t lib/main_prod.dart` | all build: `app-dev-debug.apk`, `app-prod-release.apk` (73.3 MB, every ABI; BACKLOG M8 has the per-ABI size check), `Runner.app` (28.3 MB) and `build/web` |

Afterwards the simulator and the emulator this round booted were shut down
(the owner's booted iPhone 15 Pro Max was left alone), and the build folders
were removed with `flutter clean`. The first iOS build updated
`apps/game/ios/Podfile.lock` for the two new pods. Nothing was committed.


## M7 — the offline game — phase 1 integrated (2026-09-28)

Started 2026-09-28 (D90, D92, D93), ahead of M4–M6. The contracts stage wrote
the authoritative [plans/m7-design.md](plans/m7-design.md) and froze its
phase-1 contracts (D95–D110, Q88–Q98). Seven parallel lanes built phase 1
(levels, meta-services, gameplay-bloc, menus, gameplay-ui, board-fx,
overflow); an H/S level review and its fix pass followed; three owner lanes
answered the owner's simulator review (D111, D112); the integrator made every
cross-lane edit and ran the gates. Phases 2 (vs Computer), 3 (share card,
reminder) and 5 (the close) are next. What is left is in [BACKLOG.md](BACKLOG.md)
under "M7".

### Done

- **Levels 31–200 (D113–D115):** 170 new levels on the brainstorm §4
  chapter plan (glass from L31, ice from L51, size 5 from L71, size 6 in the S
  slots L130–L200), hand-tuned at L31, L51, L71, L130 and the finales (22 → 35
  moves, strictly rising); 68 easy, 68 medium, 17 hard and 17 super hard; the
  smart bot wins at least 75 % of runs on every new level; every one solves
  from its start within the device's 20,000-node budget. The H/S review's
  fix pass re-picked or re-tuned 23 of them. E12's gates (a layout signature
  per level, no expert-only level from L31, size 6 only on super hard slots)
  are in `bundle check`.
- **Engagement:** E2, the gentle streak (a miss pauses the flame and never
  lowers the count, D98); E5, the milestone chest at level 10 of every
  chapter and every 10th bonus level, paid in the win's save update, with
  an animated opening both chests share (D103, D120); E6, relaxed mode (free
  unlimited undo, read live, D104); E7, replay from Chapters with best moves
  per level id and version (D100, D102); E8, Records and the twelve badges
  with their toast (D105, D106); E9, first launch opens Level 1 and the first
  win goes Home (D107, D123); E14, reduce motion at the app root (D108); E1,
  the copy and reward-randomness tests and `/review`'s ethics lens (D110,
  D124). E13's timing is reported by the playthrough (D123).
- **The owner's simulator review (D111, D112, D118–D120):** Home's three
  tiles, the Chapters stand-in v2, the Museum's clarity pass and its "Classic
  · soon" with 20/20 bug, the Shop's "Equipped" after an equip, the "Not
  enough coins" dialog, the dev level picker at 200 levels (and `NestySheet`'s
  clip), and the chest opening.
- **Board (D116):** +1 Slot plays one button sound, its pad's loop starts at
  its 100 % scale, and the "+N" tower tag and ice digits come from the ARB.
- **Integration:** the 200-level repository test; E9's routing in the splash
  page, with the whole-app widget tests seeded past Level 1; `NestyToast`
  cancels its timer; the bundle's decode and rules 1–7 on a worker isolate
  (D122); the day-7 chest's coins fly to the Daily screen's coin pill
  (D124); the playthrough, resume and daily device tests rewritten for E9,
  E13 and one segment per new mechanic (not yet run on a device); the
  Chapters, Daily and chest overflow sweeps widened; the design request's
  new gaps.

### Decisions

D113–D124 (below, in the Decisions log).

### Open questions

Q99–Q115 (below), each shipped with its default.

### Verification (2026-09-28, phase-1 integration)

| Command | Outcome |
|---|---|
| `LANE=integrator codegen.sh all` (gen-l10n, then build_runner through the M7 lock) | exit 0 |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `dart format --output=none --set-exit-if-changed`, CI's exclusions, tracked and untracked files | 840 files, 0 changed |
| `cd packages/nesty_core && dart test` | 1,506 pass |
| `cd packages/nesty_render && flutter test` | 530 pass |
| `cd apps/game && flutter test --timeout 120s` | 2,489 pass |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` (with `claude_md_test` and the new level checks) | 330 pass |
| `nesty_levels bundle check` / `fixtures check` | 200 levels OK / 11 fixtures OK, 0 errors, 0 warnings |
| `gen_design_tokens`, `gen_nesty_icons`, `sync_design_assets`, `gen_fx_spec` with `--check` | all exit 0, unchanged |
| `dart run nesty_tools:todo_index`, then `--check` | 111 tagged markers (ten comments in `gameplay_view.dart` that cited fixed bugs as `TODO(M7)` reworded), unchanged on the check |

Not run in this stage: the app builds and the device checks (the next
stage runs the rewritten `integration_test/` on the iPhone 16 Pro simulator
and the API 35 emulator).

### Device stage (2026-09-28, phase-1 device run)

Both platforms all PASS from fresh installs. The iPhone 16 Pro simulator (iOS 18.3) and API 35 emulator ran the playthrough (E9, E13, a segment per new mechanic through L200), the kill-and-resume check (phase A = phase B) and the daily fingerprint test. E13 recorded the time from `main()` to L1's first playable frame (iOS 2,349 ms) and to L1 alone on screen (2,609 ms); the Android emulator was too variable. Two app bugs found and fixed with regression tests: the chapter ribbon on daily and bonus boards, and the Museum's locked-shelf labels cut by an ellipsis. Eight deferrals proposed (badge toast, replay reason line, chest coin chip, bonus win card, iced tower tag, Museum label size, `GameplayPage` bloc reuse, optional E9 kill check). Device stage closes with eight findings reviewed, including icon visibility through ice, text rendering and the speed of app startup on the 15 Pro Max (unconfirmed; Q114 asks the owner).

| Command | Platform | Result |
|---|---|---|
| `flutter drive … --device-only --device F039555C-…` (iPhone 16 Pro sim) | iOS | All PASS: playthrough 401 s (78 screenshots), E13 2,349/2,609 ms, phase A 65 s, phase B 42 s, daily 47 s |
| `flutter drive … --android --device-only --device emulator-5554` (API 35 emu) | Android | All PASS: playthrough 448 s (78 screenshots), E13 17,336 ms (swapping), phase A 119 s, phase B 86 s, daily 82 s |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | host | No issues found |
| `cd apps/game && flutter test --timeout 120s -r failures-only` (after last code edit) | host | +2 new tests, 2,489→2,499 pass (the ribbon and Museum label fixes) |

All files in order: `apps/game/lib/features/gameplay/pages/gameplay_view.dart` (D129, ribbon), `apps/game/lib/features/museum/widgets/museum_cabinet.dart` (D130, label), `test/features/gameplay/` (ribbon regression), `test/features/museum/` (label regression), `integration_test/playthrough_test.dart` (E9/E13 updates, D126–D128), `integration_test/support/board_probe.dart` (timeouts describe errors), `test_driver/integration_test.dart` (`e13.json` output), `tools/scripts/nesty-test` (audio on emulator, D131), `README.md` (playthrough route, E13 outputs).

### Phase 2: vs Computer, integrated (2026-09-28)

The contracts stage froze phase 2 (D132–D139, m7 P2.1–P2.15); race-core
had built the core ahead of it; race-services, race-bloc and race-ui built
the rest in parallel; the integrator wired it, fixed what the device would
have shown (D140, D141) and wrote the rival-1 playthrough segment and E1's
race test (D142). The race's screens are `TODO(design)` stand-ins until
Claude Design's section C lands. Owner questions: Q124–Q135, each shipped
with its default.

- **Built:** `PlayRequest.race`, the resolver's race case, `beginRace` and
  `recordRaceWin` (no schema step), `RaceRules` and `FrameTicker`;
  `RaceCubit` (the mirrored rival, the frame clock, the seeded jitter, the
  holds, the result and the tie) and the bloc's race mode (undo free, Hint
  and +1 Slot off, no level record or events); Home's tile, rival select,
  the rival strip, the Start and Undo/Restart bar, 9.4–9.6, Pause and out of
  moves in a race; "Computer" on every rival surface.
- **Verification:** see the phase-2 integrator's gate in
  [plans/m7-design.md](plans/m7-design.md) P2.15. Left: the device run of
  the rival-1 segment on the iPhone 16 Pro simulator and the API 35
  emulator.

### Phase 3: star ratings, the share card and the reminder, integrated (2026-09-29)

The contracts stage froze phase 3 (D144–D155, m7 P3.1–P3.15); five lanes
built it in parallel (stars-core, stars-app, stars-ui, reminder, share;
D156–D160); the integrator made the cross-lane edits, wrote E1's two phase-3
tests, `di_test`'s and `app_flow_test`'s checks, the playthrough's star,
share and offer steps and the optional Android reminder check, fixed the
phase-2 rival strip item, and ran the gate (D161). Every surface is a
`TODO(design)` stand-in until Claude Design's sections K, I.1, I.2 and I.10
land. Owner questions: Q137–Q151, each shipped with its default.

- **Built:** star ratings (spec-prop §7.10, D125): `StarRating` in core
  and par in the bundle (par 2–35), the schema-2 fields `levelStars`,
  `starTipShown`, `daily.lastSolve` and `inProgress.hinted` with the silent
  backfill, the bloc's stars with the hint and +1 Slot cap, and `StarRow`
  on the win card, Chapters and Records; E3, the Daily's Share button with
  a spoiler-free text through `share_plus`; E4, the opt-in daily reminder
  (one inexact repeating notification, the one-time offer on the solved
  card, Settings' switch and time, the OS asked only after Yes).
- **Verification:** the integrator's gate is in
  [plans/m7-design.md](plans/m7-design.md) P3.15. Left: the device run
  (the playthrough's new steps and the optional Android reminder check),
  then the owner's phone check of the reminder.

### M7 review pass (2026-09-29)

Phase 5's design-independent part: a review of the whole M7 diff (199
tracked files, +46.0k/−1.6k, and 266 untracked files since `edc884f`) with a
fix pass, in two rounds. Round 1 comes first; [round 2](#round-2-2026-09-29)
follows it. In round 1, five read-only lenses ran in parallel: logic (core and game
logic), ui (the UI, l10n, rule 8 and the accessibility audit), platform
(services, platform and offline), security and ethics. Their findings were
merged and routed by path to three fixers (logic, ui and platform), which
confirmed each one and then fixed or deferred it. The gate stage applied
the fixers' docs edits and ran every gate.

- **Counts:** 5 found (0 P0, 1 P1, 4 P2); 4 fixed, 0 needed no change, 1
  deferred. Security and ethics found nothing. The ethics lens checked
  every row of m7-design's ethics checklist against the code, not only
  against its tests, and no answer is contradicted.
- **Clean by the lenses' own checks:** no rule outside core (rule 2); no
  `DateTime.now` or unseeded `Random` in core or on a reward path (rule 7);
  `Generator.version` stays 1 through the `stepRun` refactor, with goldens
  and parity; the schema 1→2 migration and the Hive contract; the race's
  tie, 250 ms clamp and single payment; every new platform call fails
  silently (rule 3); interface, real and fake for each new service, both
  envs in `di_test` (rule 4); every new Remote Config key has a default
  (rule 6); the four packages' reasons (rule 9); the dev-only defines
  gated on debug and dev; both notification receivers `exported=false`;
  the share text is spoiler-free and carries no personal data; no
  hardcoded string, and all 316 ARB keys have a description.

| Id | Severity | Lens | File:line | Outcome | Test |
|---|---|---|---|---|---|
| R1 | P1 (a11y) | ui | `apps/game/lib/features/gameplay/overlays/race_result_overlay.dart:243`, `:328` | Fixed: the race win and loss cards' rival row never said "Computer" to a screen reader (spec-prop §1.1 rule 5), because `ComputerTag` excludes its own semantics. A private `_RivalIdentity` wraps the row in `Semantics(label: raceRivalSemantics(name))` over `ExcludeSemantics`, as rival select does. No ARB change | `test/features/gameplay/overlays/race_result_overlay_test.dart`, group `the rival row reads "{name}, Computer" to a screen reader`: `RaceWinCard`, `RaceLossCard` (both failed before) |
| R2 | P2 (correctness) | logic | `apps/game/lib/core/services/daily/streak_daily_service.dart:165` | Fixed (D163): a clock rolled back behind `lastDate` granted a freeze for the older ISO week, one per round trip. `_reconcile` now returns the progress unchanged, which covers both `refresh` and `_solve`. The paused case is Q153 | `test/core/services/daily/streak_daily_service_test.dart`: "reconcile on a date before lastDate (the clock went back) changes nothing, and grants no freeze for the older week"; "a solve on a date before lastDate pays and records it, but grants no freeze for the older week"; "rolling the clock back and forth never mints an extra weekly freeze" (all three failed before) |
| R3 | P2 (docs) | ui | `apps/game/lib/features/fx/chest/reward_flight.dart:48` | Fixed: the doc said nothing was allocated per frame and named an `Interval` the code doesn't use. It now says what is computed once and that only the sprites' small widget tree rebuilds per tick (Flutter UI, not rule 8's Flame hot path) | none (a comment) |
| R4 | P2 (design) | platform | `apps/game/lib/core/services/notifications/reminder_notification_details.dart:39` | Deferred to Claude Design's I.2: the Android reminder's stand-in accent (`AppColorTokens.primary`, `TODO(design) I.2`) had no BACKLOG line of its own. BACKLOG M7 now ties the swap to I.2's icon sync | none |
| R5 | P2 (docs) | platform | `apps/game/ios/Podfile.lock:46` | Fixed (docs): four existing plugins' `SPEC CHECKSUMS` changed with no version change. The cause is two `pod` 1.16.2 installs whose `json` gems write an empty list differently (D154). README "Prerequisites" says so; the lock is left as it is | none |

**The accessibility audit (the ui lens).** It covers the M7 surfaces;
BACKLOG M7's "Accessibility audit" item stays open for the rest (D164).

| Screen or overlay | Semantics labels | 48 dp targets | Reduce motion | Large symbols | Text scale |
|---|---|---|---|---|---|
| Chapters grid (`chapter_level_cell.dart`) | Pass: one label per cell (won, current, locked; stars appended) | Pass: 64 dp cells on `TactileSurface` | n/a (the auto-scroll has no animation) | n/a (no dolls) | Pass (`FittedBox`) |
| Records (`records_page.dart`, `badge_grid.dart`, `record_stat_row.dart`) | Pass: `MergeSemantics` rows, earned and locked badge labels | n/a (only the reused best-moves `SettingsRow` is tappable) | n/a | n/a | Not checked on its own (overflow test only) |
| Rival select (`rival_select_page.dart`) | Pass: one container label per card; reward chip and Race read separately | Pass (`TactileButton`) | n/a | n/a | Pass (`Flexible`, `maxLines`) |
| Race board and rival strip (`rival_strip.dart`) | Pass: one label, plus a live region throttled to 2 s | n/a (`IgnorePointer`) | Pass: the moved beat and counter bump read `context.reduceMotion` | n/a (the strip draws no board; the player's board is the usual pipeline with `symbolsMode`) | Pass: the state line drops below 340 dp, tested |
| Race action bar (`race_action_bar.dart`) | Pass (`BoosterButton`, `TactileButton`) | Pass | n/a | n/a | Not checked on its own |
| Race win and loss cards (`race_result_overlay.dart`) | **Failed, fixed (R1):** "Rival N, Computer" | Pass | Pass (`WinOverlaySchedule`, `MotionSpec`) | n/a | Not checked on its own |
| Milestone and day-7 chests (`chest_reward_sequence.dart`, `milestone_chest_modal.dart`) | Pass: the contents row; Open and Collect | Pass | Pass: a reduced branch in every phase | n/a | Pass (`milestone_chest_modal_overflow_test`) |
| Star row (`star_row.dart`) | Pass: one `starsSemantics(count)` node | n/a (not tappable) | Pass: half the pop gap, no flourish | n/a | Not checked on its own (fixed canvas sizes) |
| Reminder offer and Settings rows (`reminder_offer_card.dart`, `reduce_motion_sheet.dart`) | Pass: `TactileButton`, `OverlayTextLink`, `NestyCloseButton`'s "Close" | Pass: the 32 dp close button hits 48 × 48 through `TouchTarget` | Pass (the app-wide `AnimatedSwitcher` halving) | n/a | Pass (`settings_overflow_test`, 5 sizes × 2 scales) |
| Board decor (`slot_decor.dart`, `board_scene.dart`) | n/a (Flame canvas) | n/a | n/a | n/a | `TextScaler.noScaling` for "+N" and the ice digits, as the board's other text (not a regression) |

Rule 8 (the same lens): `RaceCubit`'s tick does only `Duration` arithmetic
until a move is due; `SlotDecor`'s labels are recomputed only in
`_layoutDecor`; `StarRow` caches its paths and paints. No per-frame
allocation on a Flame hot path.

#### Decisions and questions

D163–D164 (below, in the Decisions log); Q153 (below), shipped with its
default.

#### Verification (2026-09-29, the review gate)

| Command | Outcome |
|---|---|
| `LANE=review-gate codegen.sh all` (gen-l10n, then build_runner, through the M7 lock) | exit 0; `git status` and the diff stat identical before and after |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `dart format --output=none --set-exit-if-changed`, CI's exclusions, tracked and untracked files | 917 files, 0 changed |
| `cd packages/nesty_core && dart test` | 1,662 pass |
| `dart test -p node test/parity test/generator/golden_test.dart` | 84 pass |
| `cd packages/nesty_render && flutter test` | 530 pass |
| `cd apps/game && flutter test --timeout 120s` | 3,066 pass (+5: R1's two, R2's three) |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` (with `claude_md_test`) | 344 pass |
| `nesty_levels bundle check` / `fixtures check` | 200 levels OK / 11 fixtures OK, 0 errors, 0 warnings |
| `gen_design_tokens`, `gen_nesty_icons`, `sync_design_assets`, `gen_fx_spec` with `--check` | all exit 0, unchanged |
| `dart run nesty_tools:todo_index`, then `--check` | 125 tagged markers, unchanged |
| `flutter build apk --debug --flavor dev -t lib/main_dev.dart`; `flutter build apk --release --flavor prod -t lib/main_prod.dart`; `flutter build ios --no-codesign --flavor dev -t lib/main_dev.dart`; admin `flutter build web -t lib/main_dev.dart` and `-t lib/main_prod.dart` | all build: `app-dev-debug.apk`, `app-prod-release.apk` (79.8 MB), `Runner.app` (31.3 MB) and `build/web`; `Podfile.lock` and every tracked file unchanged by the builds |
| `cd tools && dart test` and `todo_index --check`, again after the docs and CLAUDE.md edits | 344 pass; unchanged |

Not run in this stage: the device checks. What the close's device run
should look at is in the gate's report: the race cards' screen-reader
label (R1) is the one fix a device shows, and only with VoiceOver or
TalkBack on.

#### Round 2 (2026-09-29)

Round 1 traced the main paths and found them clean, so round 2 went deeper
and adversarially. Four read-only lenses built concrete sequences meant to
break the code: orderings, interleavings, lifecycle events, bad or old data
and platform edge cases. The lenses were the save and player data; the race
and the bloc's lifecycle; the reminder, share and platform; and the rest of
the accessibility audit (the pre-M7 screens). Their 34 findings merged to 33
(R6–R38; the audit's P2 B1 merged into R7) and were routed by path to the
three fixers, as in round 1. The gate applied the fixers' cross-path edits:
R7's `app.dart` wiring, R8's view guard and view test, and R30's offer
check. It then ran every gate (D165).

- **Counts:** 33 found (2 P0, 22 P1, 9 P2).
  - Outcomes: 32 fixed, 0 needed no change, 1 deferred (R12, an owner decision, Q154).
  - By lens: save 3, race 3, reminder 4, accessibility 23.
  - Every fix except four has a regression test that fails without it.
  - The four: R33, whose allocation no test can see, and R31, R32 and R36, which add tests to code that was already right. R31's tests were mutation-checked.
- **Tried and held:**
  - Save: a real schema-1 M3 save; 16 damaged or odd documents (wrong types, huge numbers, stray boards, odd schemas); a kill between the backup write and the document write; every interleaving of the write paths; the once-only paths (chests, badges, `records.dailies`, restored won boards, the replay and race exclusions); and the Hive box names, keys and typeIds against HEAD.
  - Race: the tie in both directions; the rival finishing on the frame the out-of-moves sheet opens; two board reports; `close()` with the ticker running; the background; Rematch or New race under an overlay; the `raceNo` cap; dead-board restarts; `NESTY_RACE_PACE_MS`; and the router reusing the page.
  - Reminder: quick toggling; enable during a refresh; revoke then resume; a language change while off; Android 13's denied states; an app update with id 1 pending; and share with a null iPad origin, a dismissed sheet and a double share.
  - API use matches the pub-cache sources of `flutter_local_notifications` 22.3.1, `timezone`, `flutter_timezone` and `share_plus`.

| Id | Severity | Lens | File:line | Outcome | Test |
|---|---|---|---|---|---|
| R6 | P0 (correctness, save) | save | `apps/game/lib/core/services/daily/streak_daily_service.dart:65` | Fixed: a daily won after midnight counted toward the streak. With the Daily screen's countdown reconciling the new day mid-puzzle, it also burned the held freeze, restarted the run at 1 and said "Streak relit!". That broke m3 §8.2, D76, Q70's default and m7 §8. `progressAfterSolve` now solves only today's date; any other date adds to `done` only (it still pays through `recordLevelWin`) | `test/core/services/daily/streak_daily_service_test.dart` "a daily won after midnight pays and records its date only" (4 cases); `test/features/gameplay/bloc/gameplay_bloc_test.dart` "a daily won after midnight pays but neither extends nor relights the streak" (all failed before) |
| R7 | P0 (a11y) | a11y | `apps/game/lib/app/app.dart:99` | Fixed (D167): iOS's Reduce Motion reaches Flutter only as `AccessibilityFeatures.reduceMotion`, which `MediaQuery` doesn't carry, so the default System never reduced motion on iOS (spec-prop §16). New `core/ui/theme/reduce_motion_override.dart` reads both flags and rebuilds on `didChangeAccessibilityFeatures`. The merged B1 (Android's Remove animations plus the in-app Off still runs controllers at 5 %) is deferred with a `TODO(v1.1)` and a BACKLOG line | `test/core/ui/reduce_motion_override_test.dart` (7); `test/app/app_test.dart` "System follows iOS's Reduce Motion…" (failed before) and "Off keeps full motion under iOS's Reduce Motion too" |
| R8 | P1 (correctness, a11y) | race | `apps/game/lib/features/race/cubit/race_cubit.dart:158`, `:196` | Fixed: a Pause hold set while a Rematch or New race board was loading was lost when the board landed, so Start ran the rival under Pause. `playerBoardLoaded` keeps `held` from the holds, and `start()` reads the holds. The view's guard (defence in depth) lifts a Pause that 9.5 replaces | `test/features/race/cubit/race_cubit_test.dart` "a hold set while waiting (Rematch\|New race) still holds…" (2); `test/features/gameplay/pages/gameplay_view_race_test.dart` "Pause opened while a Rematch board loads keeps its hold…" (all failed before) |
| R9 | P1 (platform) | reminder | `apps/game/lib/core/services/notifications/local_notification_service.dart:10` | Fixed (D166): in 132 common zones that `latest_10y` lacks (Europe/Amsterdam, Asia/Calcutta, GMT…), the fallback was named `Nesty/Fixed+HHMM`. Android's `ZoneId.of` refused it, so the reminder was never scheduled. The fallback is now named after the device's own id, else `GMT±HH:MM`. The skip memo keys on name and offset. Q155 asks about `latest_all` | `test/core/services/notifications/local_notification_service_test.dart` group "the zone name the platform receives"; `reminder_notification_details_test.dart` (`fixedOffsetLocation`, `reminderZoneKey`) (both failed before) |
| R10 | P1 (platform) | reminder | `apps/game/lib/core/services/notifications/reminder_notification_details.dart:41` | Fixed (D166): every iOS reminder was silent, because FLN attaches no sound when `presentSound` is false and `sound` is unset. That contradicts P3.10's "the alert and the sound". `sound: ''` gives the default sound in the background; the foreground stays silent | `local_notification_service_test.dart` "iOS: the reminder carries a sound for the background…" (failed before); `reminder_notification_details_test.dart` "iOS: a sound for the background" |
| R11 | P1 (a11y) | a11y | `apps/game/lib/features/gameplay/overlays/overlay_entrance.dart:92`, `gameplay_view.dart:1222` | Fixed: no in-page overlay was announced or modal, and behind the out-of-moves sheet the booster bar still undid. New `ModalSemanticsScope` wraps every `OverlayEntrance`, the two chests and the figurine modal; the titles name the route | `gameplay_view_test.dart` group "screen readers: an overlay is a route of its own…"; `daily_page_test.dart`, `museum_page_test.dart` modal cases |
| R12 | P1 (a11y) | a11y | `apps/game/lib/features/gameplay/pages/gameplay_board.dart:135` | Deferred (Q154): the Flame board has no semantics, so VoiceOver and TalkBack can't play a level. Screen-reader play is not in spec §16 or spec-prop §16. It needs a board input path and about 20 strings from Claude Design, so it is the owner's scope decision. `TODO(v1.1)` at the board, BACKLOG M7 | none |
| R13 | P1 (a11y) | a11y | `apps/game/lib/core/ui/widgets/tabs/nesty_segmented_tabs.dart:95`, `nav/nesty_bottom_nav.dart:92` | Fixed: the Shop tabs and the bottom nav read each label twice; `excludeSemantics` | `test/core/ui/a11y_kit_test.dart` "labels read once (R13)" (2) |
| R14 | P1 (a11y) | a11y | `apps/game/lib/features/shop/widgets/skin_grid_card.dart:170` | Fixed: a skin card hid Equipped, Owned, the price and its Equip or Buy. The node's value is the state, and Equip or Buy are its own actions. New key `shopOwned`, a stand-in | `test/features/shop/shop_page_test.dart` "a screen reader hears each card's state…" |
| R15 | P1 (a11y) | a11y | `apps/game/lib/core/ui/widgets/home/home_tile.dart:91` | Fixed: a locked Home tile never said why; its value is now "After Level N" | `test/features/home/home_page_test.dart` "a locked tile tells a screen reader why…" |
| R16 | P1 (a11y) | a11y | `apps/game/lib/features/settings/widgets/language_sheet.dart:129`, `reduce_motion_sheet.dart:60` | Fixed: neither sheet exposed the selected row; `selected` on `SheetRow` and the language row | `settings_page_test.dart`, `language_sheet_test.dart`, `a11y_kit_test.dart` selected cases |
| R17 | P1 (a11y) | a11y | `apps/game/lib/core/ui/widgets/header/screen_header.dart:46` | Fixed: the header's Back or Close was 46 dp on every pushed screen; `IconTactileButton.minTouchSize` 48 | `a11y_kit_test.dart` "ScreenHeader's 46 px back button is a 48 dp target"; the overflow suite's new check |
| R18 | P1 (a11y) | a11y | `apps/game/lib/features/home/pages/home_page.dart:501`, `core/ui/widgets/coins/coin_pill.dart:45` | Fixed: Home's gear was 46 dp and the coin pill 27.7–42 dp; 48 dp targets outside the pill's `FittedBox` | `test/overflow/home_shell_overflow_test.dart` under `expectAccessibleLayout` |
| R19 | P1 (a11y) | a11y | `nesty_segmented_tabs.dart:105`, `apps/game/lib/features/shop/widgets/theme_grid_card.dart:191` | Fixed: Shop tabs 38, Use 30, compact price 38; 48 dp segments, and `TouchSlop` in the fixed-height cards | `a11y_kit_test.dart` (tabs, `TouchSlop`); `shop_page_test.dart` "the card's 38 px price answers across 48 dp…" |
| R20 | P1 (a11y) | a11y | `apps/game/lib/features/gameplay/widgets/soft_stuck_banner.dart:128` | Fixed: the soft-stuck action was 38 dp; a 48 dp target around its 38 dp face | `soft_stuck_banner_overflow_test.dart` under the new check |
| R21 | P1 (a11y) | a11y | `apps/game/lib/core/ui/widgets/settings/settings_rows.dart:88`, `language_sheet.dart:127` | Fixed: Settings rows 47 dp, language rows 46; a 48 dp minimum | `a11y_kit_test.dart` "SettingsRow is at least 48 dp tall"; `language_sheet_test.dart` |
| R22 | P1 (a11y) | a11y | `apps/game/lib/features/race/pages/rival_select_page.dart:178`, `daily/widgets/puzzle_card.dart:531` | Fixed: rival select's Race (38) and Daily's Share (46), M7 surfaces round 1 passed | `race_overflow_test.dart`, `daily_overflow_test.dart` under the new check |
| R23 | P1 (a11y) | a11y | `apps/game/lib/features/gameplay/overlays/win_overlay.dart:329` | Fixed: at 360 × 640 and 1.3× the scaled card shrank Continue to 46 dp and Back to Chapters to 40; only the block above the button scales now | `win_overlay_overflow_test.dart` under the new check |
| R24 | P1 (a11y) | a11y | `apps/game/lib/core/ui/widgets/buttons/nesty_close_button.dart:36` | Fixed: the Close node was 36 dp (32 on the reminder card) though its hit box was 48; the node is the target now | `a11y_kit_test.dart` "NestyCloseButton's node is its 48 dp target" |
| R25 | P1 (a11y, text scale) | a11y | `apps/game/lib/features/records/widgets/badge_grid.dart:56` | Fixed: badge names cut at 1.3×, against m7 §15.2; new `ShrinkToFitText` | `a11y_kit_test.dart` "ShrinkToFitText: a badge name fits 2 lines…"; the cut-text check |
| R26 | P1 (a11y, text scale) | a11y | `apps/game/lib/features/gameplay/overlays/win_chapter_card.dart:196` | Fixed: the chest countdown was cut at 1.3× on every phone | `win_chapter_card_test.dart` "the chest countdown is never cut at 1.3×…" |
| R27 | P1 (a11y, text scale) | a11y | `apps/game/lib/features/daily/widgets/puzzle_card.dart:71` | Fixed: the puzzle title was cut even at 1.0× on 360 dp; it scales, or the chip moves under it | `daily_overflow_test.dart`'s cut-text check (54 cases cut before) |
| R28 | P1 (a11y, text scale) | a11y | `rival_select_page.dart:139`, `:170` | Fixed: the rival name and "Ready to race" were cut; they scale down | `race_overflow_test.dart`'s cut-text check |
| R29 | P1 (a11y, text scale) | a11y | `screen_header.dart:99`, `theme_grid_card.dart:94` | Fixed: "Chapte…" and the theme names at 1.3×; they scale down | `a11y_kit_test.dart` "ScreenHeader: 'Chapters' at 1.3×…"; `shop_overflow_test.dart` |
| R30 | P2 (offline) | save | `apps/game/lib/core/services/reminder/daily_reminder.dart:128` | Fixed (D166): on the Hive in-memory fallback, the reminder's sync cancelled the player's real OS reminder, and the one-time offer could show again. A `SessionOnlyDatabase` marker: refresh never cancels over it, `disable` still does, and the offer stays hidden | `daily_reminder_test.dart` group "over the in-memory fallback"; `reminder_offer_cubit_test.dart` "hidden over the session fallback…" (both failed before) |
| R31 | P2 (tests) | save | `apps/game/test/core/services/save/save_document_codec_test.dart:155` | Fixed: bad-value reads of `levelStars`, `starTipShown`, `daily.lastSolve` and `inProgress.hinted`; a mutation of each guard fails them | the four new "schema 2" tests in that file |
| R32 | P2 (tests) | race | `apps/game/lib/features/gameplay/pages/gameplay_view.dart:332` | Fixed: the view's lifecycle holds and the tie through the real bloc, as m7's race-ui test plan asks | `gameplay_view_race_test.dart` group "the view's lifecycle holds and the tie…" (3) |
| R33 | P2 (rule 8) | race | `race_cubit.dart:269` | Fixed: the tick allocated a `Duration` each frame, contrary to P2.5's "no allocation"; the clock is int microseconds now, and `RaceRules.maxFrameDeltaMs` is 250 | none (no test sees an allocation); the 58 race tests pin the behaviour |
| R34 | P2 (platform) | reminder | `reminder_notification_details.dart:88` | Fixed (D166): a 02:xx time scheduled within a day before a spring-forward change became 03:xx and repeated there; `nextDailyOccurrence` skips a day on which the time doesn't exist | `reminder_notification_details_test.dart` group "a time inside the spring-forward gap" (5) |
| R35 | P2 (correctness) | reminder | `apps/game/lib/features/settings/cubit/settings_cubit.dart:72` | Fixed: a double tap on the toggle during Android 13's prompt showed a false "blocked" toast; a second on while one is in flight is ignored | `settings_cubit_test.dart` "a second on while the OS asks is ignored…" (failed before) |
| R36 | P2 (tests) | a11y | `apps/game/test/features/support/screen_harness.dart:194` | Fixed: nothing tested targets, labels or cut text. `expectAccessibleLayout` adds Android's tap-target and the labelled-target guidelines and a cut-text sweep; all 58 overflow call sites use it (855 cases) | `test/features/support/screen_harness_test.dart` |
| R37 | P2 (a11y, clarity) | a11y | `win_chapter_card.dart:149`, `museum/widgets/figurine_modal.dart:270`, `museum_cabinet.dart:141` | Fixed: bare percentages; the bars are named, and the next shelf reads "15/20" | `win_chapter_card_test.dart`, `museum_page_test.dart` |
| R38 | P2 (a11y, dev only) | a11y | `home_page.dart:335` | Fixed: the dev picker button was 38 dp | `home_shell_overflow_test.dart` (dev) under the new check |

**The accessibility audit, round 2: the pre-M7 screens.** Each cell gives
what the audit found and, for a failure, the finding that fixed it. Round
1's table above covers the M7 surfaces. R16, R17, R21, R22, R24–R26, R28
and R29 also fix M7 surfaces that round 1 passed or didn't check on their
own.

| Screen or overlay | Semantics labels | 48 dp targets | Reduce motion | Large symbols (D91) | Text scale 1.3× |
|---|---|---|---|---|---|
| Splash | Pass | n/a | **Failed on iOS, fixed (R7)**; this holds for every screen below | Pass | Pass |
| Tab shell, bottom nav | **Failed, fixed (R13):** "Shop" read twice | Pass | Pass | n/a | Pass |
| Home | **Failed, fixed (R15):** a locked tile's "After Level N" | **Failed, fixed (R18):** gear 46, coin pill ≤ 42 | Pass | Pass | Pass |
| Gameplay HUD, booster bar | Pass | Pass | Pass | n/a | Pass |
| Flame board | **Failed, deferred (R12, Q154):** no nodes | Pass for touch (the whole column) | Pass | Pass | n/a (canvas) |
| Soft-stuck banner | Pass (live region) | **Failed, fixed (R20):** 38 | Pass | n/a | Pass |
| Pause, out of moves, booster popup | **Failed, fixed (R11):** not announced, not modal; boosters acted behind the sheet | **Popup Close 36, fixed (R24)** | Pass | n/a | Pass |
| Win card | Labels pass; **fixed (R11, R37):** not announced, the chest bar unlabelled | **Failed, fixed (R23):** 40–46 at 360 × 640 | Pass | Pass | **Failed, fixed (R26):** the chest countdown |
| Chapter complete, all levels done, intro | Labels pass; **fixed (R11):** not announced | Pass | Pass | Pass | Pass |
| Tutorial | Readable text; play waits on R12 | n/a | Pass | n/a | Pass |
| Daily: streak card, calendar | Pass | n/a | n/a | n/a | Pass |
| Daily: puzzle card | Pass | **Fixed (R17, R22):** Back 46, Share 46 | Pass | Pass | **Failed, fixed (R27):** the title |
| Daily: day-7 chest | **Failed, fixed (R11):** not modal | Pass | Pass | n/a | Pass |
| Museum and figurine modal | **Fixed (R11, R37):** not modal; a bare "75%"; "15/20" unread | **Fixed (R17, R24):** Back 46, Close 36 | Pass | n/a | Pass |
| Shop, skin detail | **Failed, fixed (R13, R14):** tabs read twice; the skin cards hid state and actions | **Failed, fixed (R17, R19):** Back 46, tabs 38, Use 30, price 38 | Pass | Pass | **Failed, fixed (R29):** theme names |
| Not enough coins | Pass (a real dialog route) | **Close 36, fixed (R24)** | Pass | n/a | Pass |
| Settings and its sheets | **Failed, fixed (R16):** no "selected" | **Failed, fixed (R17, R21):** Close 46, rows 47 and 46 | Pass | Pass | Pass |
| Toasts | Pass (live region) | n/a | Pass | n/a | Pass |
| Dev level picker | Pass | **Fixed (R38):** 38 | n/a | n/a | not in the suite |

The four text-scale checks round 1 didn't run on their own, at 1.3× on the
five sizes:
- Records failed (R25, fixed).
- The race action bar, the race win and loss cards, and `StarRow` pass.

The overflow suite now checks every screen for targets, labels and cut text
(R36), so a regression fails CI. The audit's two host limits remain: host
tests prove the semantics tree, not what VoiceOver or TalkBack say, and R12
is the owner's call. BACKLOG's audit item is ticked, and the device pass is
a new item.

#### Decisions and questions (round 2)

D165–D167 (below, in the Decisions log); Q154–Q155 (below), each shipped
with its default.

#### Verification (2026-09-29, the round-2 gate)

| Command | Outcome |
|---|---|
| `LANE=review2-gate codegen.sh all` (gen-l10n, then build_runner, through the M7 lock) | exit 0; `git status` and the diff stat identical before and after |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `dart format --output=none --set-exit-if-changed`, CI's exclusions, tracked and untracked files | 924 files, 0 changed |
| `cd packages/nesty_core && dart test` | 1,662 pass |
| `dart test -p node test/parity test/generator/golden_test.dart` | 84 pass |
| `cd packages/nesty_render && flutter test` | 530 pass |
| `cd apps/game && flutter test --timeout 120s` | 3,136 pass (+70 over round 1's 3,066) |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` (with `claude_md_test`) | 344 pass, after the docs and CLAUDE.md edits |
| `nesty_levels bundle check` / `fixtures check` | 200 levels OK / 11 fixtures OK, 0 errors, 0 warnings |
| `gen_design_tokens`, `gen_nesty_icons`, `sync_design_assets`, `gen_fx_spec` with `--check` | all exit 0, unchanged |
| `dart run nesty_tools:todo_index`, then `--check` | 127 tagged markers (+2 `TODO(v1.1)`: R12 at the board, R7's note); `--check` unchanged |
| `flutter build apk --debug --flavor dev`; `apk --release --flavor prod`; `ios --no-codesign --flavor dev`; admin `build web` (`main_dev`, `main_prod`) | all build: `app-dev-debug.apk`, `app-prod-release.apk` (79.9 MB), `Runner.app` (31.3 MB) and `build/web` (both entry points); no tracked file changed by the builds |

Not run in this stage: the device checks. What the close's device run
should look at (R7, R8, R10, R11, R14, R23 and the new 48 dp targets) is in
the gate's report. That run passed on both platforms, with one fix to R23's
button (D168).

### Phase 4: Claude Design's m7-3 delivery, integrated (2026-09-30)

Two contracts stages ran first: C4a did the tooling (tokens v3, the 35
Lottie files, the UI art and the generated Android notification icon, the
68-glyph font; D173–D178) and C4b froze the shapes and put copy.md in the
ARB (D179–D201). Five lanes then built on them in parallel: B the board, R
vs Computer, M the meta screens, D the daily and Settings, O the overlays.
The integrator made the cross-lane edits, updated E1, `di_test`,
`app_flow_test` and the playthrough, wired the five new device files into
`nesty-test` and docs/TEST_COVERAGE.md, wrote the Claude Design follow-up,
and ran the gate (D202–D208). Owner questions: Q156–Q158, each shipped with
its default.

- **Built:** m7-3 replaces every M7 stand-in: the fit rule and presets for
  levels 31–200, the tall glass case, tall ice, the top-shelf tower and the
  iced tower, rows of 5 and 6 for the +1 Slot (D172), the tap nudge, the
  drag hover and the hint arcs; section 09's race screens with the Computer
  tag, portraits, the strip in the HUD, 9.6's card, Leave race's confirm and
  the race jingles; Home's chapter card and Records button, Chapters and
  the level card, the Museum, Records, the Shop's theme crops and Forest
  Bear; the reminder dialog, Settings' tiled rows with the inline Reduce
  motion and "Open phone settings" (a platform channel), the streak's
  looks and the day-7 chest; the win card with `ui_stars`, the helper note,
  the daily win card's Share, the chest moment on `ui_chest`, the splash's
  fade and error cards, 12.5–12.9, relaxed mode's badge, the tutorial's
  "STEP n OF 3", the intro loops and the palette-tinted ribbon.
- **Verification:** the integrator's gate is in the report
  (`scratchpad/m7/reports/integrator-p4.md`). The device run passed on
  both platforms (D209): the playthrough, resume, the daily fingerprint and
  the five new files on the iPhone 16 Pro simulator and the API 35
  emulator, and `--android --only reminder`, after seven test fixes and six
  app fixes. Next: phase 5.

### Phase 5A: the fidelity fixes, the animated undo and the device seams, built (2026-10-01)

Phase 5 is the close of M7. Its first part, 5A, built what the fidelity audit
and the animation pass could decide without a phone: a contracts stage (the
cream page, the header alignment, the sunk colours, the bootstrap seam), then
lane B (the animated undo), lane O (the splash, the tutorial scrim, the chest
card and its flights, the relit card, the count-up), lane RD (rival select, the
Daily and Settings, and dropping `DailyCubit.share`) and lane M (Chapters, the
Museum, Records, the Shop, "Not enough coins", Home's type). The integrator
(5a-i) then added the device steps `faults` and `semantics`, the splash and
fault shots, the `l1` resume pair, `--android-size`, the pairing scripts and
`talkback.sh`. D210-D234 are its decisions; Q160 and Q161 are its owner
questions, each shipped with its default.

- **Verification:**
  - the integrator's gate (5a-i): `flutter analyze --fatal-infos
    --fatal-warnings` clean, `nesty_core` 1,662 tests, `nesty_render` 600,
    `apps/game` 4,049, `apps/admin` 47, `tools` 391, `todo_index --check`
    clean;
  - the close's gate (5a-fix): `codegen.sh all` wrote 0 outputs, `dart
    format` 0 changed, `flutter analyze --fatal-infos --fatal-warnings` clean,
    `apps/game` 4,049 tests passed, `tools` 391 passed, `todo_index` and
    `--check` unchanged (100 markers); no code changed in this stage, so the
    core, render and admin suites are the integrator's;
  - the device run (5a-dev) did not happen: it had 16 GB free against the
    20 GB floor and stopped after rendering the 132 design frames at 1170x2532
    (`frames-screen/`). So no frame was compared with a screen, no TalkBack
    finding exists, and E13, `skinLandMs` and the `l1` resume pair are
    unjudged.
- **Left:** free the disk (at least 20 GB: `flutter clean` in `apps/game`, or
  Xcode's DerivedData, or the owner's simulator apps), then rerun the device
  stage (5a-dev from step 2), the audit and the fixes it finds. Then 5B
  (translations) and 5C (the review and the `/milestone M7` gate).

### Phase 5, m7-4: wired, device-run and fixed (2026-10-02 to 2026-10-04)

Claude Design's m7-4 went into `design/` on 2026-10-01 (D235; D236 keeps
D172). Stage by stage:

- **Wiring (2026-10-02, four lanes, D241-D244):** 5m-tool (tokens v4, the two
  new Lottie contracts, chapters 7-10's board wood synced), 5m-copy (copy.md
  m7-4 in the English ARB), 5m-game (the board, the tutorial, the race and
  the overlays) and 5m-menus (the menus' fidelity). 5d-i integrated them
  (D245): the stale integration strings, a vacuous check, the relit glow
  fixed, the new device steps, 139 frames re-rendered and 123 pairs. It
  left 27 ARB keys unread: 11 short forms (5B's), 8 screen-reader strings
  and 6 visible strings (5f-fa, 5f-fb and 5f-fd wired or retired all 14).
- **Device run and triage (5d-dev, 5d-tri, D246):** the first run on the
  iPhone 16e and the API 35 emulator found two app bugs in the first hour
  (the Shop's purchase burst during a build; a failed Bonus or Daily open
  showing the splash's retry view) and a third (the Museum modal named a
  figurine twice), plus test bugs. The TalkBack pass ran on the 411x731 dp
  emulator: 26 of 36 screens match node for node, the rest are expected
  (off-screen nodes, the Shop's fourth row, the board's keyboard `Focus`
  node), and it raised T1 (D249) and T2 (Q171).
- **Fidelity audit (5d-aud, four Sonnet judges over 123 pairs, then 5f-fj-1
  on 31 re-shot frames):** the fixes are D247-D258: the menus (5f-fa), the
  game and shared widgets (5f-fb), the device steps (5f-fc) and the keys,
  the Bonus chip and the `LottieFxView` audit (5f-fd). The 5f-fj-1 judge
  found 20 frames fixed, 8 by design, 2 still differing (f9-4 and f9-5, the
  versus ribbon's 336 dp band: only a new Lottie fixes it, Claude Design
  request 12.1) and 0 regressions.
- **5B draft round (2026-10-04, D239):** the eight locales were drafted and
  reviewed in `build/m7-p5/l10n-drafts` while the device run used the tree
  (reports 5b-T1 to T4, 5b-R1 to R4, 5b-spot, 5b-full-a, 5b-full-b). The
  Sonnet reviewers made 2-6 fixes per language pair; the Opus spot-check and
  full pass then found about 150 more they had missed (D240's addendum). The
  integrator (5B-5) has not run: nothing is in `apps/game/lib/l10n/` yet,
  and `prompts/5b-integrate-additions.txt` lists its additions (the pt-BR
  `=0` plural branches, the diff of the English that changed after the draft
  source).

- **Verification (2026-10-04):**
  - 5f device run (`nesty-test --device-only`, `runs/5f.status`):
    - iPhone 16e 390x844 (`runs/5f-ios`): 17 of 25 results passed (E13 counted). Eight
      failed and none was an app fault: `board_layouts` (the shake poll on
      a bare slot), `meta_screens complete` (a predicate for Images that the
      idle clips replaced), `daily_states chest` and `faults reminder_granted`
      (the time picker is now the iOS wheel), `faults bonus_failed` and
      `race_failed` (the NBSP in the failure card), and `daily_states saved`
      and `settings`, which never ran (`pub.dev` lookup failed). The test
      fixes are in `5f-board-shake.md` and `5f-step-fixes.md`.
    - Android 1170x2532@480 (`runs/5f-android-390`): 24 of 25 results passed (E13 counted);
      `board_layouts` passed both tests, and then the driver lost the device
      ("device offline", an emulator dropout) before its shots were saved.
    - Android 411x731 (`runs/5f-android-731`): 6 of 7 passed;
      `meta_screens returning` expected 3 purchase sparkles at a fixed 250 ms
      and found 1; the lead's fix waits up to 900 ms for all three.
    - E13 (launch to level 1 playable): iPhone 16e 3,169 ms (5d-dev: 2,483),
      Android 10,025 ms (5d-dev: 3,906). The emulator was booted just before
      the run and probably still busy; the playthrough rerun measures it
      again with a warm emulator. Re-measuring.
    - Reruns of the failed steps (2026-10-04, `CK/runs/5f.status`): iOS,
      Android at 390x844 and at 731 dp all pass. The playthrough rerun:
      E13 3,785 ms on the iPhone and 7,724 ms on the warm emulator at 390.
      The `/milestone M7` gate measured it again (Phase 5, 5C).
  - Host gate after 5f-fd: `flutter analyze --fatal-infos --fatal-warnings`
    clean; `apps/game` 4,311 passed with 9 skipped (the whole overflow suite
    included); `nesty_render` 617 passed; `todo_index --check` unchanged (82
    markers); `sync_design_assets --check` unchanged.
  - 5d-dev's first run: iPhone 16e 16 of 24 passed, then 21 of 21 on the
    rerun; Android 390 22 of 24, then 2 of 2; Android 731 7 of 7.
  - The TalkBack harness is `CK/bin/talkback.sh`: with TalkBack on, it
    dumps the accessibility tree with `uiautomator` at each screen of the
    semantics tour and compares it, node by node, with the app's own
    semantics dump. API 35's TalkBack logs no speech and its focus can't be
    driven from the shell, so the tree is the evidence (D224's method, as far
    as it goes). The 4th run covered race, race_loss, game and meta: 26 of 36
    screens matched, the other 10 were off-screen nodes, the Shop's fourth
    row, the board's keyboard `Focus` node, or the splash.
- **Left:** the 5f-fj-2 judgement of the frames the reruns re-shot, E13's
  warm-emulator number, the owner's VoiceOver and TalkBack listening checks
  ([plans/voiceover-checklist.md](plans/voiceover-checklist.md)), then 5B
  (translations: integrate, overflow, device, visual) and 5C (the review and
  the `/milestone M7` gate).

### Phase 5, 5B (translations): the nine locales, the script fonts and the fit (2026-10-02 to 2026-10-05)

The owner's phase 5 instruction asked for es, pt-BR, id, hi, de, fr, tr and
ja, with the respect rules per locale, "Computer" on every rival surface,
fonts for hi and ja, the overflow suite at every locale, the language picker
and a device step per locale family. The plan is `build/m7-p5/p5/l10n.md`
(with lead notes 16-24, which win where they differ). Stage by stage:

- **5B-1, the foundations (2026-10-02, three lanes):**
  - 5b-locale: the `system` value of the `locale` setting, `AppLocaleResolver`,
    the cubit that follows the phone, the reminder's locale, iOS
    `CFBundleLocalizations` (D261).
  - 5b-fonts: Baloo 2 and M PLUS Rounded 1c as role families, the generated
    fallback lists, `gen_font_subsets`, the coverage checks in pure Dart
    (D262).
  - 5b-tests: the locale axis of the test harness: ARB parity, plural shape,
    respect rules per locale, the readability floor, `locales_test.dart`
    (D266).
- **5B-2, 5b-copy:** the English freeze (sha256 `1162e29f...`, lead note 24):
  `FitText` and the 11 short forms wired, the language sheet of frames
  8.2 and 8.2b, the screen-reader joins as ARB keys, `locale_script.dart`
  (D263, D264).
- **5B-3 and 5B-4, the draft round (2026-10-04, D239):** the eight locales
  were drafted (5b-T1 es and pt-BR, T2 fr and de, T3 tr and id, T4 hi and ja)
  and reviewed (5b-R1 to R4) in `build/m7-p5/l10n-drafts` while the 5f device
  run used the tree. Two Opus passes over the Latin six followed: a spot
  check of 272 high-risk keys (102 fixes) and a full pass over the 133 keys
  it didn't sample (5b-full-a for es, pt and fr, 5b-full-b for tr, de and
  id). The model lesson is D240's addendum; it isn't repeated here.
- **5B-5, the integrator (5b-int):**
  - Phase A copied the nine ARBs and the rules files, translated the English
    delta (`a11yJoinList`, `a11yJoinSentences`, `museumNextFamilyKicker`),
    retired `languageComingSoon`, added the pt `=0` branches (D265), and set
    `requireAllLaunchLocales`. The real gates found: id and tr allow lists,
    the es `one` branches that hid the number, a duplicate ja rule, and the
    placeholder scan false positives of the drafts' `check_arb.py`.
  - Phase B1 rebuilt the subsets from the translators' kanji, measured the
    sizes (below) and wired `nesty-test --only locales`, the per-locale
    overflow loop and `gen_font_subsets --check` into the drift step and CI.
  - Phase B2 applied the overflow lanes' shortenings, flipped the readability
    floor to `gate` and fixed three layouts (the Home tiles, the Computer tag
    and the pause header).
- **The overflow lanes:** 5b-om (menus) and 5b-og (game) ran the suite in
  all nine locales: ShrinkToFitText's `overflowLines` and `fixedWidth`,
  chapter names that wrap, the Museum cabinet, the Shop tabs, the race
  strips, and the HUD pill laid out in the room between its neighbours
  (D263).
- **5b-copycheck, the last Opus check** of the 106 strings written after the
  reviewed drafts: 3 string fixes (fr's no-break space before the "!", ja's
  `museumAllHome`, pt's `ao Sol`) and 2 code fixes found on the way (the
  join's closing marks and the rival-unlocked card's English ". "; D264).
- **Phase-5 follow-ups that landed with 5B** (D267): 5f-fix2's seven frames,
  5f-startup's E13 investigation and 5f-e13's poller.

**App size (§4.7, `build/m7-p5/5b-fonts-size/measure.sh`):**

| | before (2026-10-02, arm64) | after 5B (2026-10-05) |
|---|---|---|
| Script fonts (nine TTF, subset) | none | 2,233,548 B (budget 2.5 MB; 1,814,936 B before the ja kanji) |
| `app-prod-release.apk`, arm64 | 39,344,068 B | 40,951,271 B (+1,607,203) |
| `Runner.app` (iOS release, no codesign) | 32,548 KB | 35,000 KB |
| `App.framework` | 19,424 KB | 21,876 KB |

The growth is the fonts, the nine catalogs and the M7 work since the
"before", not the fonts alone. The whole build stays well under the < 60 MB
budget (M8's check). gen-l10n logs "pt_BR: 407 untranslated message(s)":
`app_pt_BR.arb` is `@@locale` only, a regional overlay of `app_pt`, so nothing
is untranslated.

**Verification (2026-10-05):**
- Host gates after 5B-5 phase B2 (5b-int): `LANE=... codegen.sh all` ok;
  `flutter analyze --fatal-infos --fatal-warnings` clean; `apps/game`
  4,523 passed (9 skipped); `test/l10n`, `test/ethics` and
  `arb_keys_m7_test` 255 passed; `tools` `dart test` 435 passed;
  `gen_font_subsets --check`, `build_fonts.sh --verify` and
  `todo_index --check` unchanged. The overflow suite passes in all nine
  locales with the readability floor in `gate` mode (en, de, hi and ja at
  the full matrix: 1,184 tests; the rest at 360x640 and 375x667: 476).
- 5b-copycheck: `test/l10n`, `test/ethics`, `arb_keys_m7_test` 255 passed;
  the overflow suite at fr, ja, pt, pt_BR and hi passed.
- Device run (`nesty-test --device-only --only locales,board,meta,faults,playthrough`
  on the iPhone 16e and the Android emulator at 390x844,
  `build/m7-p5/runs/5b.status`): stopped on iOS, "Failed to load dynamic
  library objective_c.framework" (stale native assets after an iOS release
  build). After a `flutter clean`, the `/milestone M7` gate's device stage
  took its place: locales de, hi and ja, board, meta, faults and the
  playthrough pass on both platforms (Phase 5, 5C).

### Phase 5, 5C: the review and its fixes (2026-10-05)

`/review` ran over the M7 working tree in four Sonnet code lanes
(`build/m7-p5/reports/5c-r1..r4.md`), the security scanner (`5c-sec.md`)
and the ethics lens on Opus (`5c-eth.md`); a verify pass (`5c-verify.md`)
kept what reproduced.

- **Security:** clean (no secret, no real AdMob id, no rules loosened).
- **Code:** no P0; 10 findings verified and fixed in the scratchpad copy
  (`5c-fix.md`), then applied to the repo as one patch
  (`build/m7-p5/runs/5c-fix.patch`, 38 files):
  - every on-device check but `locales` and `daily_fingerprint` pins the
    phone's language to English (`support/phone_language.dart`);
  - the chapters' chest cells and the win card's chest cycle come from
    `MilestoneChest`, not a copy of its numbers;
  - `DailyReminder.setTime` returns whether the store took the time, and
    Settings toasts only then;
  - `RivalReact` follows a reduce-motion toggle mid-race;
  - the Pause dialog's two literal colours are tokens;
  - `ChapterOrders` (`firstOrder`, `doneAt`) replaces four copies of the
    chapter-start sum;
  - new tests for `RecordsCubit`, the iOS wheel's Cancel and dragged Done,
    and the `relitGlowSeen` and `lastRival` settings.
- **Ethics:**
  - P1, the word "Computer" on the race strip at 360 dp and up: D271.
  - P1, the loss card's confetti hop: the owner's call, Q183, answered: keep it (D273) (default: as
    designed).
  - P2, es, pt and ja read "the computer's rival": now "rival controlado
    por la computadora", "rival controlado pelo computador" and
    コンピューターライバル in the five screen-reader and badge strings (the
    lead's Opus copy pass).
  - P2, the +1 Slot outline beside a priced row after a fail: no change now;
    M6 decides with its ▶ row (BACKLOG M6).

**Verification (2026-10-05):** the fix lane's tree: `apps/game` 4,601
passed, `tools` 435 passed, root analyze clean. After the patch and D271 in
the repo: the race, UI, Home and gameplay suites 1,600 passed, `test/l10n`
with Settings and Records 696 passed, and the overflow suite passes in all
nine locales in `gate` mode.

**The `/milestone M7` gate (2026-10-05, `build/m7-p5/bin/m7_gate.sh all`,
`runs/gate.status`):**
- **Host, all pass:**
  - `pub get` with the lock unchanged; codegen with no drift;
  - format: 1,067 files, none changed; `analyze --fatal-infos
    --fatal-warnings`: clean;
  - tests: core 1,662, core web parity 84, render 617, game 4,741,
    admin 47, tools 435;
  - the asset, Lottie spec, font subset and TODO index checks unchanged;
  - `bundle check`: 200 levels OK;
  - the overflow suite in all nine locales.
- **Builds, all pass:** the dev debug APK; the prod release APK (84.7 MB,
  every ABI); iOS `--no-codesign` (Runner.app 35.2 MB); the admin web.
- **Devices, from fresh installs:** the iPhone 16e, and the Android
  emulator at 411x731. Every check passes in the end; the reruns are
  `runs/gate-*-rerun*`. The first passes failed for these reasons, none
  an app bug except the language sheet:
  - E13's in-app check never saw level 1 playable on the iPhone. Its 4 ms
    timer walked the tree only every ~38 ms and missed the short window
    before the tutorial locks the board. It now looks after every frame
    and reports its frames and errors, and its check moved to the end of
    the playthrough, so a clock fault no longer stops the other checks.
  - The language sheet showed "Deutsch" twice in German (日本語 in
    Japanese, and so on), and a screen reader heard it twice. A row whose
    name in the app's language is its autonym now shows it once
    (`language_sheet.dart`, with a host test in de and ja).
  - `locales_test`'s Home check wanted the tag's exact word. Under D271 the
    tile's label carries it, so the check now matches text containing the
    word.
  - `faults` `splash_loaded` started from the default seeded save, so it
    went Home. It is now a fresh install, as its doc says. It also says
    where it stopped if level 1 doesn't come.
  - `meta_screens` on Android:
    - the purchase sparkles' 900 ms window now counts from the first
      sparkle, not from the save;
    - the Language row is scrolled into view (y 753 on a 731 dp screen).
  - On the iPhone, `flutter drive` hung at attach twice (meta finale,
    faults content). The app launched, the tool never found its VM
    service, and `--timeout` never started. The lead's watchdog
    (`CK/bin/drive_watchdog.sh`) stopped such steps during the gate. After
    the runs, `nesty-test` itself stops one after 8 minutes at its build
    line, with its whole process tree, and fails it
    (`NESTY_TEST_ATTACH_HANG_S`; tested with a fake hanging step). It also
    starts each device step's driver log empty (README "Tests").
  - Android lost 23 steps in Gradle. `~/.gradle/caches` was deleted
    outside the repo about 12:20, not by Claude. nesty's 8.14 daemon was
    restarted, and a fresh build re-downloaded the dependencies.
- **Disk:** under the 20 GB floor once (16 GB at 12:15). Mostly flutter
  drive's debug log of driver commands, which carries every screenshot
  (1.1 GB); emptied with the unused build outputs inside the repo. The
  watchdog now empties it under the floor.
- **E13** (main() to level 1 playable):
  - iPhone 3,700 ms (`noisy`: levels check 552 ms against a quiet 200);
  - Android 12,150 ms on the gate's busy host (2,496 against 550);
  - Android 6,569 ms on a warm emulator with the host quiet (590 against
    550, not `noisy`), the playthrough alone after every other run
    (`runs/gate-android-quiet`).
- **skinLand:** iPhone 130 ms (route done 422 ms, within the 400 ms fade).
  The warm emulator 659 ms with the route done at 660 ms: inside the
  transition, which the emulator runs slower than its 400 ms. On the busy
  host it was 776 ms.
- **Frames:** the 16 re-shot frames are re-judged (`reports/5c-rj.md`): 15
  fixed, f2-6 by design, none still differing, no regression.
- **Locales:** the 94 screenshots (de, hi, ja on both platforms) are
  reviewed (`reports/5c-loc-*.md`). All are ok; ja's "DAY" and "NEW" are
  the translation review's choices. "Computer" shows beside every rival
  name.

### m7-5, Device run and fidelity (stages C–E, 2026-10-07 to 10-08)

Both platforms pass every on-device check. Every long run went detached under `tools/scripts/watch-run` (D295); each alert below was caught at once and fixed or rerun. Logs in `build/m7-5/logs/` (git-ignored).

- **Host (stage C):** analyze 0 issues; core, render, admin, tools and the game suite pass (5,003 + the 56 ethics tests that a slow Hindi check had cut off, D293); the overflow suite in all nine locales; every generator `--check` and the level bundle check.
- **iPhone 16e** (by UDID; 390×844): the full run passed 88 of 89 steps. `meta_screens_test returning` failed on a stale device expectation (m7-4's two folded Chapters rows; item 21 makes it three, D296). After the fix the rerun of `--only meta,gift` passed 8 of 8.
- **Android emulator** (API 35, 411×731 dp): the host was swapping (18 GB RAM, about 92 M swap-outs; another project's tests at load 15–25), so the emulator starved. Board layouts, two daily states, overlays and the splash fault froze or never attached to `flutter drive`. A stalled run was stopped and rerun on a cold-booted emulator (90 s warm-up), then the last two (daily `saved`, locale `hi`) once more on another cold boot. Every step has passed on a healthy emulator: the playthrough, resume, the daily fingerprint, board, race (3), meta (3), daily states (4), the gift (5, `hint` included), overlays, faults (8), the semantics tours (4) and the locales (3).
- **Fidelity (stage E;** `build/m7-5/reports/e-fidelity-ios.md`, `e-fidelity-android.md`; frames rendered with a rebuilt headless renderer**):**
  - The gift: 12 of 15 iPhone pairs match section 13, 2 differ in a minor way (the chest card's ribbon size, by design D285; the rays' hard wedges, the Lottie), 1 has no frame. On the 731 dp emulator the gift matches 13.1b, 2.1b and 13.3b within about 3 dp.
  - Part 2: the 290 win ribbon (9.4, 5.4), the chapter ribbon (4.7), the race strip (9.3) and the figurine modal (6.2) match.
  - The respect rules hold in every gift shot.
  - Two app fixes came from the shots (D296): the tally's text had the debug underline, and the all-home Museum headline wrapped.
  - Not bugs: the splash's placeholder dolls at 1.5 s (phase 5 F-SPL), the Day 7 card about 12 dp higher (the 16e's 47 dp inset against the frames' 59), and the tutorial hand without its ring (the shot's timing).

## Decisions log

D1–D13 are dated 2026-09-25, D14–D57 2026-09-26, D58–D80 2026-09-27 and D81–D124 2026-09-28
(D26–D39 are the M1 and render build and review decisions; D40–D52 are the
M2 Lottie decisions, the owner's of 2026-09-26 and the contracts stage's;
D53–D57 are the M2 phase-4 lanes' and the integration's; D58 is the M2
review fix pass's; D59–D61 are the post-M2 round's, recording the owner's
calls and deliveries of 2026-09-26; D63–D65 open M3; D66–D80 are the M3
contracts stage's, recording [plans/m3-design.md](plans/m3-design.md), each
default flagged with its question; D81–D89 are M3's integration, device
checks and review fix pass's; D90 is the owner's reordering and D91 the
owner's Color symbols default; D92–D93 are the offline-game brainstorm's; D94 is the
owner's CLAUDE.md rule; D95–D110 are the M7 phase-1 contracts stage's, recording
[plans/m7-design.md](plans/m7-design.md), each default flagged with its question; D111–D112 are the
owner's simulator review; D113–D124 are the M7 phase-1 lanes', owner lanes' and integration's). D1, D8 and D12 were
amended on 2026-09-26. D18–D23 are the owner's decisions for the round that
covers the design foundation, M1 and M2, copied from its approved plan.

- **D1. aquabuildr stack instead of Riverpod / go_router (owner decision).**
  The owner asked for "base cubits" and "Hive" on the pattern of the team's
  existing aquabuildr app. So the app layer uses:
  - Cubit-first `flutter_bloc`, with `BaseAsyncCubit<T>` and the freezed
    `AsyncValue<T>`.
  - `get_it` + `injectable` (annotations only; the generated `di.config.dart`
    is never edited).
  - `auto_route` (one `app_router.dart` per app).
  - freezed models and states.
  - dev/stg/prod flavors with `main_<flavor>.dart`, `FlavorConfig` and
    `bootstrap.dart`.
  - ARB l10n through `context.localizations`.
  - A `common_imports.dart` barrel and feature-first folders.

  This replaces the original "Riverpod" in CLAUDE.md rule 10 and the
  `go_router`/Riverpod in spec §13.1. Spec §13.1 and §13.2 are amended to
  match, and §13.3 is unchanged (see Q3). CLAUDE.md's rule 10, Commands and
  Conventions were updated on 2026-09-26 (Q2). Every other hard rule still
  applies, including the second half of rule 10: Flame components never own
  game truth.

  Deliberate differences from aquabuildr's base layer (amended 2026-09-26):
  - **Method name:** `runguarded` is `runGuarded`. The bloc version is
    `runGuarded(emit, body)`, and both versions share one `resolveGuarded`
    body, so they can't drift apart.
  - **Error case:** `AsyncValue.error` carries a typed
    `AppException exception` (an `AppExceptionKind` plus a log-only
    `message`) instead of `String message` + `int? statusCode`. There is no
    REST backend (D3), and the UI maps the kind to an ARB string instead of
    showing text. As a result, `errorMessage`/`getErrorStatus` are replaced
    by `exceptionOrNull`, and `onError` receives the `AppException`.
  - **Pattern matching:** the union is `sealed` and its case classes are
    public (`AsyncValueData` and the others), so pages can use exhaustive
    `switch`es. The `initial` getter is renamed `isInitial`.
  - **Cancellation:** `AppExceptionKind.cancelled` replaces
    `NetworkExceptionTypes.cancel`. The bloc also swallows it and supports
    `onError`.
  - **No seeding:** cubits start unseeded (`AsyncValue.initial()` with no
    data), where aquabuildr emits `AsyncValue.initial(data: FooState())` in
    an init method. `state.data` is therefore null until the first data
    emit. Never write `state.data!`; the idiom is in
    `.claude/rules/bloc-cubit.md`.
  - **Bloc order:** `BaseAsyncBloc` registers its only handler itself (D16).
- **D2. Hive via `hive_ce`, game only.** The owner asked for Hive.
  `hive`/`hive_generator` 2.x can't resolve against analyzer 10, which the
  current freezed 3, injectable 3 and auto_route_generator 10 need.
  `hive_ce` is the maintained fork with the same API.
  - The admin is Flutter Web and keeps its data in Firestore, so it has no
    local database.
  - The game has one `settings` box of primitives under
    `<documents>/hive`, so there are no adapters yet.
  - `HiveTypeIds` records the typeId/field-index contract and reserves 200
    and 201 for `hive_ce_flutter`.
  - `hive_ce_generator` is declared but produces nothing today.
- **D3. What was deliberately not copied from aquabuildr, and why.**
  - `dio` / `retrofit`: there is no REST backend. Content comes from
    Firestore and Storage (spec §13.4, §14).
  - `flutter_screenutil`: board layout is spec math in logical pixels
    (§10.3, `BoardLayout` in `nesty_render`), and menus must honour system
    text scaling up to 1.3× (§16). Global scale factors would fight both.
  - `flutter_gen`: no assets exist yet. Revisit when levels, audio or skins
    land (M2/M3/M7).
  - Sentry: crashes go to Firebase Crashlytics (spec §13.2, §14.4), and no
    DSN may be committed (rule 5).
  - FVM: one SDK, `flutter`/`dart` from PATH.
  - Firebase, `google_mobile_ads`, `in_app_purchase` and audio packages are
    postponed to M3, M4 and M6. `google_mobile_ads` crashes at launch without
    native App IDs.
- **D4. UI kept minimal until the owner supplies `design/`.** Pages are
  unstyled placeholders that exist so routing and flows are wired and tested.
  `AppColors` are placeholder tokens (`TODO(design)`, to be replaced by
  `design/tokens.json`). Fonts are not bundled yet. Claude never creates
  `design/`.
- **D5. Fakes first, swapped by DI environment.**
  - Each implementation declares its injectable environments.
  - A service without a real implementation registers its offline fake for
    both `real` and `fake`. The milestone that adds the real one removes
    `real` from the fake, and callers don't change.
  - bootstrap picks `fake` only when `kDebugMode &&
    NESTY_FAKE_SERVICES=true`, so a release build can never run on fakes.
  - The fakes used in the real env behave like a device with no network or
    store: no ads are ready, purchases are declined, and there are 0 levels.
    Nothing is handed out for free if a build ships early.
  - The admin is the exception: its real env uses `UnconfiguredAuthService`,
    because `FakeAuthService` accepts any credentials.
- **D6. The base layer is duplicated in both apps.** These are copied
  between `apps/game` and `apps/admin`, and differ only in package name and
  error kinds:
  - `core/base`
  - the `AppException` shape
  - flavor
  - `context_extension`
  - the test helper

  Extracting a shared package is Q8.
- **D7. Bundle id `com.futrix.nesty`.**
  - The Android `namespace` and `applicationId` are `com.futrix.nesty`.
  - dev and stg add the suffixes `.dev` and `.stg` on both platforms.
  - `MainActivity` moved to `com/futrix/nesty`.
  - minSdk is pinned to 24 and the iOS deployment target is 14.0 (spec §0).
  - Store ids are permanent once published, so Q10 asks the owner to confirm.
- **D8. Flavors dev / stg / prod.**
  - **App names:** `[DEV] Nesty`, `[STG] Nesty` and `Nesty: Doll Sort` in
    Dart (`FlavorValues.appTitle`). On the launcher they are `[DEV] Nesty`,
    `[STG] Nesty` and `Nesty`.
  - **iOS:** `Debug-/Profile-/Release-<flavor>` configurations on the base
    Flutter xcconfigs, and every configuration is mapped in the Podfile.
    `FLUTTER_TARGET` is deliberately not pinned per configuration, so `-t`
    keeps working. Always build with
    `--flavor <f> -t lib/main_<f>.dart`; a flavorless build fails fast.
  - **iOS flavor guard (amended 2026-09-26):** each of the 9 Runner
    configurations sets `NESTY_FLAVOR`.
    - The Run Script phase fails the build when `FLUTTER_TARGET` or `FLAVOR`
      in `Flutter/Generated.xcconfig` don't match it, for example after a
      `flutter run` of another flavor. The error message names the right
      command.
    - An Xcode Archive or a fastlane `build_app(scheme:)` lane must
      therefore first run `flutter build ipa --flavor <f> -t
      lib/main_<f>.dart`, or `flutter build ios --config-only` with the same
      flags.
    - A plain flavorless `flutter build ios` now also fails at this step.
    - **Amended again (2026-09-26, D57):** an `integration_test/*.dart`
      target is accepted too, in the `Debug-<flavor>` configurations only,
      so `flutter drive` runs the on-device playthrough while an Archive can
      never ship a test entry point.
    - Only debug device builds were tried. Profile, release and Archive
      were not.
  - **Android:** `appCategory="game"`, because Android 16 ignores portrait
    locks on large screens for other app categories.
- **D9. Generated code is committed.** CI regenerates it and fails on any
  difference, and a hook blocks hand edits. Codegen order: `flutter gen-l10n`
  first, then `dart run build_runner build`. build_runner 2.15 ignores
  `--delete-conflicting-outputs`.
- **D10. Admin access policy lives only in `AuthGuard`.** Navigation after a
  session change is centralised in `App`: it re-enters the router root and
  lets the guard decide. `resolver.redirectUntil` is not used, because
  `replaceAll` would leave held resolvers pending forever. So after the first
  sign-in the admin lands on the Dashboard rather than the deep link (Q6).
  URLs use the default hash strategy (Q7).
- **D11. The `nesty_core` purity rules are enforced by a test, not by
  review.** Core must also compile for the web admin (Solve / Simulate /
  Playtest in the browser). So only platform-neutral `dart:` libraries are
  allowed, and spawning the solver isolate is the game's job (rule 8).
- **D12. B1 fixed by pinning `auto_route: 11.1.0` exactly (amended
  2026-09-26).** Dependency sections were frozen for the skeleton pass on
  2026-09-25. The verified pin was applied in both apps on 2026-09-26 (Q1),
  instead of upgrading Flutter. The pin stays until the local SDK is
  upgraded (Q23).
- **D13. The save document (spec §13.3) is not built.** `SaveService`
  exposes only `load()` and `currentLevel` until M3 decides where the save
  lives (Q3).
- **D14. App-lifetime cubits that mirror a store extend `Cubit<S>`
  directly.** The game's `LanguageCubit` (persisted locale) and the admin's
  `SessionCubit` (auth stream) seed synchronously from their store and then
  follow its stream. So they always hold a value, and there is no initial or
  data-less state for `AsyncValue` to model.
  - `LanguageCubit` does an optimistic update with rollback, and
    `LanguageState` carries its own `isLoading`/`hasError` flags.
  - Every other async cubit, including the M3 Settings toggles, extends
    `BaseAsyncCubit<T>`.
  - The exception is written down in `.claude/rules/bloc-cubit.md`. Whether
    CLAUDE.md rule 10 should mention it is Q25.
- **D15. CI pins Flutter 3.41.2, and every member's `flutter:` bound stays at
  or below it.**
  - The local SDK prints "3.43.0-1.0.pre-35", but it is Flutter 3.41.2
    stable plus one local commit that only edits the SDK's own
    `pubspec.lock` (`git describe`: `3.41.2-1-g5408e0f3048`; same engine and
    Dart 3.11.0).
  - That version string is not a published release, so CI can't install it.
    3.41.2 is the published stable it is built on, and on it every package
    resolves to the committed lock.
  - nesty_render's `>=3.43.0-0` floor was accepted locally but rejected by a
    real 3.41.2, so it was relaxed to `>=3.41.0`, which is flame 1.38.2's
    floor. The only lock change was `sdks.flutter`.
  - Newer stables (3.44+, Dart 3.12+) re-resolve 5 SDK-pinned test packages
    (matcher, meta, test, test_api, test_core), which
    `--enforce-lockfile` rejects.
  - Upgrading means bumping the pin and committing the re-resolved lock in
    one change (Q23). This closes Q13.
- **D16. `BaseAsyncBloc` handles events strictly in order.**
  - bloc 9 runs handlers concurrently. Each `on<...>` registration also has
    its own subscription, so even a sequential transformer per event type
    doesn't order events of different types.
  - So the base class registers one handler over the base event type,
    through `asyncExpand`. This is FIFO without adding `bloc_concurrency`.
  - Subclasses implement `handleEvent` with an exhaustive `switch`, and
    calling `on<>` throws a `StateError`.
- **D17. Error output until Crashlytics (M4).**
  - `runGuarded` logs failures with `developer.log`, and in debug builds
    also with `debugPrint`, so they reach the `flutter run` terminal.
  - It does not use `FlutterError.reportError`: expected failures (a
    rejected sign-in, a failed load) aren't framework errors, and tests
    exercise them.
  - The bootstrap zone handler, which sees only uncaught errors, does call
    `FlutterError.reportError`. That prints in the `flutter run` terminal,
    and in release it logs a one-line summary to logcat or the device
    console.
  - Hive's in-memory fallback and `LanguageCubit`'s persist failure also
    `debugPrint` in debug.
- **D18. The design handoff is in `design/` (2026-09-26, commit 3a8dfca).**
  - **The move:**
    - The owner's `design_handoff_nesty/` went into `design/`: its `design/*`
      folders, `prototypes/` as `design/prototypes/`, and `README.md` as
      `design/README.md`.
    - The `.DS_Store` files and `design_handoff_nesty/` were deleted.
    - `design/` stays owner-managed and read-only (D4).
  - **What it contains:**
    - `tokens.json`, 7 layered skins, board pieces, 11 symbols and the
      ch01–ch06 backgrounds.
    - Museum figurines as SVG and PNG, and store icons.
    - 17 placeholder WAVs, and the reference generators `nesty-doll.js` and
      `nesty-sfx.js`.
    - 62 HTML frames in 8 flows (`design/prototypes/Nesty App Flow.dc.html`).
    - No fonts and no music.
  - **The screens are HTML prototypes,** not the PNGs `docs/DESIGN_BRIEF.md`
    asked for. The `.claude` agents and skills now point at
    `design/prototypes/`.
  - **Sources of truth:** rules come from GAME_SPEC.md. Look, layout, motion,
    sound and copy come from `design/`. Precedence inside the handoff is in
    D22.
  - **Closed questions:** this ends D4's wait and resolves Q15. For Q14, the
    handoff says to bundle the Fredoka and Nunito TTFs but ships none, so
    tooling fetches the OFL files.
  - **Audit findings that shaped the plan:**
    - Every SVG embeds a ~7.7 KB C2PA `<metadata>` block. It is stripped when
      the file is copied into app assets.
    - The museum and store SVGs use nested `<svg>` and mix-blend-mode, which
      flutter_svg can't render. The museum uses `design/museum/png/`, and the
      store art will be re-exported for M8.
    - `design/store/icon_1024.png` has an alpha channel.
    - There is no Android adaptive icon and no 512 px Play icon.
  - The remaining gaps are in [BACKLOG.md](BACKLOG.md) under "Owner inputs
    needed".
- **D19. The handoff's "Decisions to confirm" are accepted (owner,
  2026-09-26).**
  - A family counter under the level pill is the fly-in target for a
    completed set.
  - A "Privacy choices" row in Settings lets players change UMP consent later.
  - Gold uses a gradient-map tint, per stop and pre-rasterized, not modulate.
  - `DollColor` stays a fixed enum. Open-ended playable colors would be a
    spec change (BACKLOG "Later"). New skins, symbols and cosmetic variants
    need no code change.
  - There is no "watch a video for coins" shop row, because §9.1 lists no
    such placement.
  - **Placeholder SFX:** the 17 WAVs are the SFX until final audio (M7).
    - Their clacks have +1 semitone baked in.
    - So the game plays them at `2^(−2(size−3)/12)` instead of the README's
      `2^(−2(size−3.5)/12)`.
    - **Superseded 2026-09-27 by D61:** the SFX v2 WAVs replaced the
      placeholders, with their clacks baked at 0 semitones
      (`SoundTokens.clackBakedSemitones`), so the rate is the README's.
  - The settings `symbols` value for large symbols is `large`, replacing
    `assist` (Q4). A stored `assist` is read as `large`.
  - Also accepted from the README's list: Level 56 (Hard) is the flow's
    example level, and frames 1.2, 8.6 and 8.7 show system UI for placement
    only.
- **D20. All art is bundled, a deviation from spec §13.5.**
  - **What:** all 7 skins and the 6 chapter themes ship in the app. §13.5
    bundles only Classic and ch01.
  - **Why:**
    - The handoff delivers all of them.
    - They then work offline from the first launch (rule 3).
    - Storage delivery isn't built until M4.
  - **Cost:** app size, checked against the < 60 MB budget in M8.
  - Storage download (M4) remains for skins and themes added after release.
- **D21. Towers follow spec §3.2, not the design (owner).**
  - Buried nests are wood silhouettes at their true size: their size shows,
    their color doesn't.
  - Each is raised 18 dp per depth behind the top nest so it stays visible.
  - The design's walnut "+N" tag is kept.
  - The design itself draws every buried nest at `topHeight + 18 × depth`.
  - This resolves Q18.
- **D22. Gaps between the spec and the design resolve "according to the
  design" (owner).**
  - **Tap policy (frame 2.6).** This replaces §2.2's "tapping a different
    pickable nest switches the selection".
    - Tapping the selected nest cancels, and tapping a legal target moves.
    - Any other tap is invalid, including a pickable nest of the wrong color
      or size: the target shakes, the nest drifts back and the selection
      clears.
    - Drag: a drop on a legal target moves, a drop on any other slot is
      invalid, and a drop on nothing cancels.
  - **Extra slot.**
    - It is always appended to the bottom shelf, which re-pitches, instead of
      going below the shelf when it is full (§3.6). The layout shrinks stands
      and dolls if the row gets tight.
    - At most 2 per level ("Two per level at most").
    - It stays for the rest of the level, including after Restart ("Add a
      stand for this level").
  - **Gold.** The design marks it v1.1, "only if it ships". The gold rendering
    is built now. The gold rules are hooked into core, but the validator
    rejects gold until v1.1.
  - **Soft stuck.** The response is frame 3.4's banner ("Hmm, this looks
    stuck / Try Undo?…") plus a glowing Undo. When the solver says the level
    is stuck, Hint gives no move and charges nothing.
  - **Precedence inside the handoff:** `tokens.json`, then the App Flow
    frames, then the README, then the Design System sheet.
    - The sheet is stale. Where it differs, tokens win: counter bump 1.22,
      wobble period 400 ms, win dance 1400 ms with a 120 ms stagger.
  - **Undesigned boards** (1 or 4 shelves, 5-slot rows, maxSize 6 on 3
    shelves) extend the design's system through `BoardLayout` scaling, marked
    `TODO(design)`.
- **D23. This round's scope is the design foundation, M1 and M2 (owner).**
  - M3 (museum, daily, shop, settings, tutorial, save and resume) is the next
    round.
  - **Pulled into M2:**
    - M7's design integration: tokens, the Classic and other skin SVG
      pipeline, chapter themes, fonts and icons.
    - The SFX and haptics parts of the M3 audio and haptics service.
  - M2 is therefore no longer "placeholder art". `PlaceholderDollPainter`
    (§12.5) stays as the fallback when a skin can't load.
  - The M2 acceptance criterion is unchanged.
  - Item-level status is in BACKLOG under "Design foundation", "M1" and "M2".
- **D24. Remaining work is tracked in [BACKLOG.md](BACKLOG.md) (owner
  request, 2026-09-26).** The owner asked for every future-milestone to-do to
  be tracked, so none is lost.
  - **BACKLOG.md is the curated checklist:**
    - one section per milestone, then v1.1, Later, Owner inputs needed and
      Tech debt;
    - every item names its source.
  - **In code,** deferrals carry `TODO(<tag>)`, where the tag is `M1`…`M8`,
    `design`, `v1.1` or `later`.
    - `dart run nesty_tools:todo_index` generates `docs/TODO_INDEX.md` from
      them.
    - CI fails on an untagged TODO.
  - Every deferral gets a BACKLOG item, a tagged TODO, or both.
  - PROGRESS.md keeps the history (what was done, decisions, questions) and
    points at BACKLOG rather than copying it.
  - The `/milestone` skill and CLAUDE.md's Workflow read BACKLOG at each
    milestone's start and update it at the end.
- **D25. Design foundation pipelines (plan P1, done 2026-09-26).** Everything
  the game takes from `design/` is generated and committed, and CI checks it
  for drift. The commands are in `tools/README.md` and CLAUDE.md "Commands".
  - **Tokens:** `gen_design_tokens` emits only `static const` values. Their
    types are hand-written next to the output (`render_token_types.dart`,
    `ui_token_types.dart`), so helpers can be added without touching generated
    files. Each of the 466 tokens.json leaves is emitted, or it is on a tested
    list of 21 documented-only leaves (prose, font sources, and `haptics.*`,
    which the haptics service hand-writes). An unmapped leaf or an unknown
    value shape fails the codegen.
  - **Assets:** `sync_design_assets` owns `apps/game/assets/{skins,symbols,
    board,themes,audio}`. It strips the C2PA `<metadata>` block at the text
    level, so each SVG is otherwise byte-identical to the export. The spec
    §12.2 allowlist validator is Flutter-free
    (`package:nesty_render/svg_tools.dart`), so the admin upload can reuse it
    in M5.
  - **Fonts:** `tools/fonts/build_fonts.sh` builds them from pinned upstream
    commits. It checks each input's SHA-256, runs fontTools 4.60.1 in a
    throwaway venv, and its output is byte-reproducible (`--verify`). The icon
    font is exactly the README's 48 glyphs. At FILL 1, Material Symbols swaps
    most icons for `<name>.fill` glyphs through GSUB, which subsetting drops.
    So `bake_feature_variations.py` points the cmap at those glyphs first.
    This was a review fix: before it, the outline glyphs only looked filled
    because their holes collapsed into cancelling contours.
  - **TODO index:** only comments and Markdown prose are scanned. `design/`,
    `.claude/` (its docs describe the marker convention), build output and
    generated files are skipped. A combined tag such as `M3/M4` is listed under
    each milestone.
  - **Audio plugin:** `flutter_soloud` is pinned to 4.1.7, because 5.x can't
    resolve on Flutter 3.41.2 ("Package reasons"). It builds native code, so
    iOS builds need CMake on the Mac.

- **D26. Towerless levels keep their §6.6 tier by `tierOverride` (M1 review
  SPEC-01; owner-confirmable, Q30).** Spec §3.7 allows no towers before L16,
  no locks before L31 and no ice before L51, and §6.6 plus design A24 give
  L3, 5, 6, 7, 9, 10, 13 and 15 a medium, hard or superhard tier. On a board
  of open slots without ice every color that isn't complete holds the same
  number k of dolls of each size, so for every size s > 1 the nests whose
  inner doll is s are as many as those whose outer doll is s − 1: there is
  always a legal merge, every merge lowers the nest count by 1, and the
  casual bot (a merge 70 % of the time) wins 300 of 300. No towerless board
  can satisfy A32, so `BundlePolicy.checkTier` lets an open-slot-only board
  (every slot an `OpenSlot` with ice 0) keep its declared tier with a
  `tierOverride` reason, like the tutorials; anywhere else an override is
  still an error. The levels keep their §6.6 badges and coins (§7.3). The
  alternatives (declare them easy and relax the pattern for towerless
  boards; move towers before L16, against §3.7) are the owner's call.
- **D27. The core public API as built (M1).** Design §1 holds, with these
  additions and deviations (every one is exported and tested):
  - `MoveResult` has `move`; `MoveApplied({move, state, events,
    completedSet})`, `MoveRejected({move, reason})` with `targetId` =
    `move.to`. `NestDirection { inside, swallow }`. `BoardPosition` lives in
    `slot_id.dart`; `UndoEntry`, `UndoResult` and `ExtraSlotAdded` in
    `session_types.dart`. Event payloads carry what the animations need
    (`Picked.fromTower/leftEmptyTower`, `NestedInto.moving/target/merged`,
    `Revealed.hiddenBelow`, `Completed.setsCompleted/totalSets`, …).
  - Rejection precedence (tested, owner-confirmable in Q35): unknown slot,
    same slot, source frozen, source locked, source empty, target frozen,
    target locked, color, size. `targetOccupied` is §4's `else invalid`
    branch, unreachable in play.
  - `Rules.legalMoves` lists by source, then target, in `slotIds` order: the
    simulator's and the fallback hint's determinism depend on it.
  - `GameSession.restore(level, state, history, {undosUsed})`; `restart()`
    keeps `undosUsed` and the extra slots (per level, D22; Q35).
  - `Solver.hintFrom`, `SolverTask`, `SolverSnapshot.start/decode`,
    `SolverRun.maxBudget`, `SimulationResult.fromStats/isExpertOnly`,
    `Generator.buildAttempt/defaultId/maxSetsPerColor`,
    `DifficultyCurve.dailyTier/maxLevelNumber`, `LevelSolver`,
    `ValidationOptions.solver` (default `Solver.solve`),
    `LayoutLimits.maxIce`.
  - Name clash for M2: core exports `MoveApplied`, `MoveRejected`,
    `Completed`, `Won`, `Placed`; the game's `BoardEffect` names must differ
    or import core with a prefix.
- **D28. PRNG and Hash64 definitions (resolves Q9; frozen under
  `Generator.version` 1).** `Prng` is xoshiro128** 1.1. Seeding: lo = seed
  mod 2^32, hi = seed ÷ 2^32; splitmix32 streams A from lo and B from
  hi ^ 0x510E527F; state (A1, A2^B1, A3^B2, A4^B3), so distinct seeds give
  distinct states and the all-zero state is impossible.
  `derive(seed, a, [b])` = MurmurHash3_x86_32 over the little-endian words
  [lo, hi, a, b] with seed 0xA54FF53A. `nextInt` rejection-samples (no
  modulo bias, no 64-bit product); `shuffle` is Durstenfeld. `Hash64` is two
  MurmurHash3_x86_32 halves (seeds 0x6A09E667 / 0xBB67AE85) in web-safe u32
  arithmetic, no `fixnum`. Reference vectors come from an independent Python
  implementation checked against the upstream C.
- **D29. Codec and validator semantics (M1, review DETERMINISM-002,
  SPEC-02).** Integers are read by value (`3.0` is `3`; fractions and
  |x| > 2^53 − 1 are `schema.wrongType`), so the browser and the VM agree.
  The codec reports only what a `Level` can't hold; the validator reports
  everything a `Level` can hold, so code-built and JSON levels get the same
  checks. Issue order is document order with the known fields in canonical
  order, then unknown keys **sorted by code unit** (JSON key order isn't
  portable), and `schema.invalidJson` has no args (the parser's text differs
  by platform). Ice above `LayoutLimits.maxIce` (2^31 − 1, a representation
  limit, not a game rule) is `schema.valueOutOfRange`, and `BoardLayout`
  refuses it, so a counter never wraps and plays as thawed. Rule 8 without a
  solver is `solver.unproven` as an error; `generatorVersion` must be ≥ 1;
  rule 6 applies per lock, literally (mutual deadlocks are rule 8's).
  Decoders count errors as they go (linear, DETERMINISM-004).
- **D30. The rules engine (M1).** Nest code `gold << 10 | color << 6 |
  outer << 3 | length` in a `Uint16List`; `BoardLayout` compiled once per
  `Level` (Expando cache), up to 28 authored slots + 2 reserved extras
  (looser than the validator's 22, so rule 7 never throws on a rule-2
  failure; Q35); current ice and per-color completions are derived. Gold is
  merged per §3.5 in the kernel, but the `Nest` view drops it (v1.1).
  `Kernel.applyLegal` applies a move the kernel itself listed without
  re-checking (the solver's inner loop).
- **D31. The solver (M1, review DETERMINISM-005/008).** Deviation from design
  §3: stored nodes are packed canonical keys (three 10-bit codes per word
  without gold), a visited-table hit is confirmed by comparing them, and the
  solution is rebuilt by replaying on the real start board (first legal move
  reaching the next stored state). This halved search time. Pruning adds a
  free-pair merge symmetry (A30). Fallback step 3 (A3) takes the first
  non-pointless placement, then the first placement. A won root is `solved`
  with no moves; the root is always stored. Snapshot format v1 is
  self-contained, and `decode` rejects cells that contradict
  `completedSets`. The node arena grows in 1,024-row chunks, never copied,
  and `peakBytes` bounds the search's memory.
- **D32. The simulator (M1; owner-confirmable, Q35).** Default seed =
  `Hash64.ofString(board JSON).lo` over `schemaVersion`, `maxSize` and
  `shelves` only, so renaming a level or the generator's metadata can't move
  its tier. Run i of bot b (casual 0, smart 1) uses `Prng(derive(simSeed, b,
  i))`. Casual: one `nextInt(100)` only when merges exist. Smart (A17
  reading): candidates minus pointless moves, score (alive, rank,
  mergesAfter) with "alive" extended to boards that have a non-pointless
  move, ties by PRNG. A board with only pointless moves is a loss at once.
  Expert only = smart wins < 150/300.
- **D33. The generator and curve (M1; owner-confirmable, Q31, Q34).** Draw
  order per attempt stream `Prng(derive(seed, i))`: colors (one palette
  shuffle), segment cuts, roles, segments (≤ ⌊towers/2⌋ mergeable tower tops,
  20 deals, best kept), locks (a lock never opens on a color that waits on
  the sealed color when one set per color), ice (never on a lock). Bottom
  shelf = `min(slotsPerShelf, 4)`. Attempts are validated with
  `Validator.validate` (rules 1–8, admin budget) and simulated; closest tier
  by tier distance, then band centre, then earliest. `bonusParams(n)` takes
  the global level number. `dailyParams` uses the 31–50 boards with medium on
  weekdays and hard on weekends, and `dailySeed` rejects dates that don't
  exist. The stage table is the A16 default in `DifficultyCurve`'s doc (Q34).
  An expert-only result is returned with `simulation.expertOnly` set; the
  generator doesn't reject it (§6.5 step 4 matches tier only; Q31).
- **D34. Level bundle and `nesty_levels` (M1/M2).** `LevelBundleCodec` decode
  semantics (format and version first; entries with errors skipped;
  duplicate orders and ids skipped; one `bundle.orderGap` per gap; unknown
  top-level keys are errors but the bundle loads). Manifest schema in
  `tools/levels/README.md` (order = position, id = file name, every
  authored file listed). `bundle build` refuses an edited board whose
  `version` wasn't raised. `BundlePolicy` formalizes §3.7 ("introduces at
  Ln": absent before, present at Ln; maxSize 6 is only a cap; L3–9 ≤ 4
  colors), applies the M2 layout (2–3 shelves, ≤ 4 slots) to every bundled
  level, and treats expert only as a warning (Q36). CI runs `bundle check`.
- **D35. The 30 authored M2 levels.** One set per color everywhere, maxSize 3
  for L1–9 and 4 from L10, no locks, ice or gold, chapters 1–20 / 21–30.
  L1/L2 are the design tutorials and carry no override (both simulate easy).
  The towerless medium/hard/superhard levels (D26) are "harder" by more
  nests, split families and one empty slot. L16 is a 4,3 board with two
  depth-4 towers (the design's 4,3,3 TOWER16 board can only simulate easy, so
  it is L18); L16–L20 use depth-4 towers (Q37). Tiers were tuned with the
  same Validator, Solver and Simulator `bundle check` runs.
- **D36. Board layout extensions (render R1, review RENDER-3/4).** The doll
  clamp gap is 8/3 dp (the design's own TUT1 gap), not design §1's 4, which
  would shrink the designed tutorial. Undesigned rows and presets scale every
  slot piece by `q = min(standScaleForPitch, preset.pieceScale)`. On 5–6-slot
  rows the dolls shrink at least by that row's piece shrink × the 4-slot
  clamp, so a sealed doll keeps its case's proportions and a frozen one its
  ice's. On the top shelf the D21 18 dp step per buried nest shrinks only
  when the deepest of the tower's buried nests would reach the HUD
  (`buriedBaseY(depth, buried:)`, `TODO(design)`). The kind enum is
  `SlotShapeKind`; the whole column is the ≥ 48 dp hit area.
- **D37. Doll rendering (render R2, review RENDER-1/2/5/9).** `DollRenderer`
  adds `canPaint(h)` (any prepared raster, resampled) next to the exact
  `isReadyFor(h)`; `FallbackDollRenderer` uses `canPaint`, so a re-layout
  keeps the skin on screen. Nest z-order follows the design's nest frame
  with `DollPart.interior` and `DollPart.bodyFront` and a `shadow` flag:
  inside = host lid → host interior → guest (no shadow) → host bodyFront.
  `prepare` is additive (LRU past 8 heights); rasters are keyed by artboard
  pixel height; 9 layers; the symbol atlas holds both sizes per exact
  height; the shine sweep crosses the whole doll over its duration (Q38).
  Upright, unscaled dolls snap to device pixels. Goldens compare every
  classic reference render (≥ 99.9 % within 8/255, mean < 0.5, plus the
  symbol box).
- **D38. Board sprites and themes (render R3, review RENDER-6).**
  `BoardSpriteLibrary` (parsed once per app) is split from `BoardSprites` (one
  board's images). `prepare` rasterizes the plank, stands, glow ring, hint
  arrow and the intact glass case at every scale on the board; glass and ice
  frames are lazy (`also:`, `ensure`, or a miss). A miss rasterizes only when
  nothing held is within 10 %. Sprites are cropped once to their alpha. Theme
  backgrounds swap when the new image is ready; `ChapterTheme.forChapter`
  cycles ch01–ch06 until chapters 7–10 have art (Q38).
- **D39. VM/web parity in CI and web-safe arithmetic guards (review
  DETERMINISM-001/007).** CI runs the parity suites on node, Chrome and
  dart2wasm (and the generator goldens on node), because each parity case
  compares with a VM-computed constant and the VM run can't see a web-only
  divergence. The architecture guard also bans `~`, 64-bit typed lists and
  `HashMap`/`HashSet` in core's `lib/`.
- **D40. Every animation ships as Lottie (owner, 2026-09-26).**
  - All 29 files in `design/lottie/` ship. LOTTIE.md says 28; the folder and
    its own table hold 29.
  - Widget transitions that wrap live content stay Flutter animations on
    `tokens.motion.ui`: tactile press, sheet, modal, tab lift and banners.
  - The board timeline still owns the event order, the sound and haptic cues
    and input gating, and a Lottie never changes game state.
  - **Timing comes from each file's frame count, at 60 fps.** Examples: the
    clack lands at 537 ms (the move's 16 frames plus the lid's 16.2), a
    completion starts at 667 ms, and its unlocks and ice at t0 + 700.
  - **Motions with no file are hand-coded** (m2-lottie-design §9):
    - the tower reveal's 18 dp drop, with deeper silhouettes shifting down
      (towers show their true size);
    - the 11 dp settle after an unlock;
    - the case, ice and silhouette shake on an invalid move;
    - drag cancel and drag invalid;
    - the 300 ms re-pitch;
    - the tag and badge counts;
    - the coin count-up.
  - **Split between milestones:**
    - M2: the splash loader, idle dolls, twinkles, the toggles in Pause and
      the chapter ribbon (L21 opens ch02).
    - M3: the tutorial hands, the Settings toggles and the spinner.
- **D41. `lottie: 3.6.1`, pinned exactly; no `flame_lottie` (rule 9).**
  - **Why lottie:** the owner decided every animation is Lottie. It is a
    pure-Dart player.
  - **Why 3.6.1:** it is the newest release that resolves on Flutter
    3.41.2 / Dart 3.11. 3.4.0–3.5.1 need Flutter 3.44 and 3.6.0 is
    retracted. It adds only `archive` 4.3.0 and `posix` 6.5.2 to the lock,
    and no locked version changes.
  - **Why pinned exactly:** it is 8 days old, and the workarounds (D43) depend
    on its internals. The equivalence tests pin them.
  - **No `flame_lottie`:** it can't play segments, pause on a frame, change
    speed or swap delegates on a pooled component.
  - **Where it draws:** board clips use our `LottieFxComponent` over
    `LottieDrawable`, inside Flame for z-order, pooling and same-frame
    hand-off. The HUD, overlays and screens use our `LottieFxView`.
- **D42. Rule-8 exception, scoped.** lottie allocates inside its own draw:
  - a `Paint` per fill;
  - a `LottieFrameInfo` per callback evaluation;
  - two `Rect`s per image;
  - trim-path metrics.

  Our position and scale callbacks must return a new `Offset`, which is the
  API's type. Everything else in our code is allocation-free per frame:
  - delegates built once per pooled drawable;
  - mutable per-clip state;
  - prebuilt rasters;
  - cached rest pictures and text painters.

  Text layers are hidden (D44) because they were the hot spot.
- **D43. Export defects are worked around in code.** The owner decided this,
  and a re-export request went to the designer
  (`docs/plans/lottie-reexport-request.md`). The workarounds:
  - **Image-slot compensation.** lottie 3.6.1 draws images at their pixel
    size, so each image layer's scale becomes `k / rasterScale` and its anchor
    `(a − origin) × rasterScale`. Animated-scale layers get a callback over the
    authored value.
  - **The travel-hold fix.** An anchor delegate stands in whenever the
    position callback was skipped.
  - **`padlock_ping` hidden at rest.**
  - **The 11 dp settle** is blended into the unlock's last hop.
  - **`doll_reveal`'s silhouette** is hidden after the wipe, so its shadow
    isn't drawn twice.
  - **BoardFit placement** (D46).
  - **Loading.** Compositions load with `LottieComposition.fromBytes`, and
    unused roles get a 1×1 blank image.
  - **lottie 3.6.1 quirks** also handled: construct a drawable before setting
    its delegates; never share a `ValueDelegate`; clamp marker ends; use
    inferred-type closures, since `LottieFrameInfo` isn't exported.
  - **Amended 2026-09-27 (D59, D60):** the designer's v3 export fixed the
    defects behind the travel-hold fix, the `padlock_ping` hide, the 11 dp
    settle, the silhouette hide and the animated-scale callbacks, and they
    were deleted. The image-slot compensation (now by `FxImageSlot.density`),
    BoardFit placement, loading and the quirks stay; the validator rejects a
    later export that brings a fixed defect back.
- **D44. Localized text is drawn by Flutter, not by the Lottie text layers.**
  - Text layers cost 0.4–2.3 ms per frame, can't be resized with a
    `textStyle` delegate, and are LTR-only. So the counter and ribbon files
    are drawn with their text hidden (a text delegate that returns '').
  - A cached `TextPainter` with the ARB string follows the `counter` or
    `ribbon` null's transform, captured in the same paint.
  - Too-long strings scale to fit the band instead of wrapping.
- **D45. The lid and body split hard at art y 400 everywhere (owner; impact
  I.1).**
  - `DollPartRasters` builds, per colour, a full-artboard lid (y < 400) and
    body (y ≥ 400), plus the silhouette (shadow included), at
    `artHeightPx = tallest doll × DPR`. The height is rounded up to a multiple
    of 3 so the width is whole.
  - Gold uses the ramp-rewritten masks, and the bodies bake the symbols mode.
  - Rest sprites draw the same rasters through `PartRasterDollRenderer`, so
    hand-offs are pixel-identical.
  - The goldens exclude the 388–412 band.
  - D37's `interior` / `bodyFront` nest passes and the SVG layer rasters are
    no longer used by the game; they stay for the admin and the goldens.
- **D46. Everything on the board is placed through BoardFit (owner; impact
  I.2).**
  - **Board-space files:** translated to `(originX, originY − 142·s)` and
    scaled by `s`, with the travel remap in reference units.
  - **In-place files:** doll files scale by `s`, board pieces by the slot's
    `s·q`.
  - **Doll size:** `doll_size = h / (150·scale)`.
  - Every authored motion distance scales with the board. At 390×844 this is
    exactly LOTTIE.md, and nothing clips on other screens. The dragged doll's
    drawn position is clamped to the board frame.
- **D47. Win families hop (owner; impact I.5).** The overlay plays
  `doll_win_hop` per completed family with a 150 ms stagger (App Flow 2.8).
  `doll_win_dance` ships but is unused in M2: the board is empty at Won.
- **D48. Reduced motion (owner; impact I.6).**
  - One-shot clips, tweens, cue offsets and staggers run at half duration.
  - The shakes are removed: static position delegates on `doll_invalid`'s
    `target` and `fx_ice`'s `ice`, and the hand-coded shake is off.
  - No confetti. `doll_pick` holds the end of `lift` instead of wobbling.
  - Ambient loops (idle, twinkle, the win hop) pause on frame 0.
  - Loops that carry information (select glow, hint arrow, booster glow,
    extra slot, spinner, tutorial hands) stay at 1×.
- **D49. `IceShattered` has no haptic.** This follows LOTTIE.md and
  `tokens.haptics`. The earlier M2 design said medium.
- **D50. The placeholder PNGs are not shipped (owner; impact I.7).**
  - They are the wrong sizes for lottie-flutter, take 1.79 MB on disk and
    8.2 MiB decoded.
  - `design/lottie/images/` stays in `design/` only.
  - `LottieComposition.fromBytes` never decodes them.
- **D51. Ice stages follow `BoardLayout.iceFrame` (owner; impact I.4).**
  - A crack segment plays only when the stage advances. Stage `n` rests on
    frame `16n`; the shatter always starts at frame 48.
  - An `IceCracked` that doesn't advance the stage still fires its cue and
    counts the badge down.
  - The M5 editor caps authored ice at 3.
- **D52. The M2 bloc contract.**
  - **Effect names.** The game's effects are `SelectionChangedEffect`,
    `MoveAppliedEffect(MoveApplied)`, `MoveRejectedEffect`,
    `BoardResetEffect`, `HintShownEffect`, `HintClearedEffect` and
    `ExtraSlotAddedEffect(ExtraSlotAdded)`. The `…Effect` suffix resolves
    D27's name clash with core's exports.
  - Each new effect bumps `GameplayState.effectSeq`.
  - `LevelRepository.entryAt(order)` returns core's `LevelBundleEntry`, so
    the state carries the level's order, chapter, tier, version and reward.
  - `SolverService` has one request in flight at a time (latest wins).
    Superseded or failed requests complete with null, and results come back
    as events tagged with their move sequence.
  - Owner-confirmed on 2026-09-26: the recorded M1 and render defaults
    Q30–Q38. Early towerless levels keep their §6.6 tier labels.
- **D53. The FX runtime and the timeline keep separate types.** The runtime's
  pooled, mutable types are `FxDrawable`, `FxDrawableParams`, `FxRange` and
  `FxLayout`; the timeline's immutable descriptors are `FxClip`,
  `FxClipParams`, `FxSegment` and `FxPlacement`.
  - `features/fx` never imports the gameplay folder, so the Flame board maps
    one onto the other: a hold or speed 0 becomes `FxPlan.rest(from)`, a loop
    `FxPlan(FxRange(from, to), loop: true)`; the params go to `setSize`,
    `setTravel`, `targetPos`, the rim and tint colours and
    `reducedMotion = !shake`. Q54 asks whether to keep one segment type.
  - Clips are driven, never self-running (`autoAdvance` false): each tick the
    board advances the live clips, then `timeline.advance(dt)`, then schedules
    the queued effects, so a clip starts in the frame its sprite hides (§10.1).
- **D54. The M2 services.**
  - The frozen interfaces grew, additively: `dispose()` on `AudioService`,
    `SaveService` and `SkinService` (injectable types the dispose hook on the
    interface), `SkinService.background`, and the save's wallet:
    `currentLevel`, `coins`/`addCoins`/`spendCoins`, `recordWin`,
    `boosterCount`/`useBooster`/`addBoosters` (a starter gift of 3 hints and
    2 slots, §8), `freeUndosPerLevel`, `unlimitedBoosters` (the dev flavor)
    and `changes`.
  - `InMemorySaveService` is the real save until M3 (D13). A fresh launch
    starts at level 1 with 0 coins (Q46).
  - `entryAt(order)` returns the first playable entry at or after `order`, so
    an invalid bundled level never blocks progress (Q43).
  - Sounds load from memory; `SoLoud.instance` is touched only in `init`, so
    DI and tests never load the native library. In the background voices
    pause and resume on return (Q45).
  - The skin service's fallback chain is part rasters, then placeholder
    rasters, then the placeholder painter; it never throws (rule 3).
- **D55. The gameplay bloc beyond the frozen contract.**
  - Constructor: (`LevelRepository`, `SolverService`, `RemoteConfigService`,
    `SaveService`, `AnalyticsService`); +1 Slot is free in debug builds.
  - A drag that starts on another pickable nest switches the selection
    (Q40). A drop on nothing, or back on the nest's own slot, cancels. Any tap
    or drag start clears a visible hint first.
  - The soft-stuck check runs 300 ms after a move, an undo or +1 Slot (Q41)
    and is skipped while a hint for the same board is pending.
  - A hint is charged only when it arrives; a null result uses
    `Solver.fallbackHint`; no move with an unsolvable verdict sets soft stuck
    and charges nothing.
  - A win pays `winRewardFor(tier)`: medium reads `reward_easy` until Q5 is
    decided, clamped at 0 or above, and calls `SaveService.recordWin`.
  - `NextLevelPressed` (only when won) loads the next entry;
    `GameplayStatus.allLevelsDone` follows the last level (Bonus Endless is
    M3). Analytics log the §14.4 events, with `booster_use{source: free}`
    for every M2 use (Q42).
- **D56. The gameplay page.**
  - The page builds `NestyGame` once, behind the `GameplayBoard` seam
    (`NestyGameBoard`; page tests use a recording fake).
  - The board's reports time the overlays: `onFamilyLanded` bumps the
    counter, `onWon` opens the win overlay, `onOutOfMoves` the sheet (a
    dismissed sheet stays closed until the board runs out again).
  - Every layout the board reports prepares the level's art
    (`LevelSkinLoader`: the latest request wins, a failure keeps the current
    art).
  - Continue sends `NextLevelPressed` and stays on the page (Q49). Pause
    pauses the bloc and the engine; the back button and the app going to the
    background open it.
  - Chapter numbers come from the bundle's `chapterId`s. The splash weights
    its progress (Lottie 45 %, skin 35 %, save and levels 15 %, audio 5 %);
    only a save or level failure offers a retry.
- **D57. The on-device playthrough.**
  - `apps/game/integration_test/playthrough_test.dart` runs the real
    `main_dev.dart` under the integration binding with the `fullyLive` frame
    policy, and `test_driver/integration_test.dart` saves its screenshots
    through `flutter drive` (`NESTY_SCREENSHOT_DIR`, by default
    `build/integration_test/screenshots/`).
  - Effects are scheduled in Flame's next tick, so the test waits until the
    board's latest scheduled state equals the bloc's and its timeline is idle.
    Mid-animation screenshots pause the engine at a timeline time.
  - `integration_test` and `flutter_driver` (SDK) are game dev dependencies,
    and the D8 guard accepts an `integration_test/` target in `Debug-<flavor>`
    only. CI doesn't run it (it needs a device).
  - `test/app_flow_test.dart` is the widget-level flow on fakes; it absorbed
    the screens lane's `home_flow_test.dart`.
- **D58. The M2 review fix pass (2026-09-27).** The behaviour the fixes chose
  (see [M2 review and fix pass](#m2-review-and-fix-pass-2026-09-27)):
  - **The next level's art is prepared during the win overlay.** The page
    prefetches it for `GameplayBoard.layoutFor(GameState.initial(next))`,
    the same layout the board computes on the same viewport. Continue waits
    for it, at most `GameplayView.nextArtWait` (2 s, rule 3), and the
    board's `onLayout` for that level adopts it synchronously, in the same
    Flame update as the reset. A skin holds only its own level's colours,
    so this is what keeps a new colour from drawing nothing.
  - **A reset ends a drag,** in the bloc and on the board: undo, restart
    and a new level. The finger's release then sends nothing. A drag
    released while paused puts the doll down: the bloc emits the drag
    cancel, and the doll flies home from where it is drawn on Resume.
  - **A second +1 Slot during the re-pitch is queued, not dropped.** Its
    re-pitch starts when the first ends, from that layout, and input stays
    locked through both. Each press of an enabled booster is honoured (it
    spends one in stg/prod); Q60 asks whether to ignore the second press
    instead.
  - **Won locks the chrome without greying it.** The pause button and the
    booster bar keep the look they had and take no touch (`IgnorePointer`),
    through the winning batch and under the win overlay. Undo still shows
    disabled after the winning completion, as after any completion (§2.4).
  - **Soft stuck with nothing to undo suggests Restart** (always free), and
    Undo doesn't glow. The banner fixes its suggestion when it shows and
    keeps it while it slides out. No frame shows it (`TODO(design)`).
  - **Home keeps the showcase rasters while a level covers it.** The
    part-raster cache (24 MB) keeps its own handles of them anyway, so
    releasing them freed little and cost a placeholder flash on every
    return. The worst case adds about 5 MB to a level (17.6 + 5.2 MB, under
    §4's 25 MB).
  - **Home past the last level** reads "PLAY · All done!" and opens All
    Levels Done; M3's Bonus Endless replaces it.
  - **Every `LottieFxView` is its own repaint boundary** (rule 8): a clip
    never repaints its neighbours, and a resting one costs nothing when they
    repaint.
- **D59. Claude Design v3 replaces our v2 re-export (owner, 2026-09-26).**
  The designer answered our v2 request with a v3 overlay, and the check
  workflow recommended importing it as delivered
  ([plans/claude-design-v3-check.md](plans/claude-design-v3-check.md)).
  - **Import.** `design/` = the repo's `design/`, then the audio export
    (`export/nesty-audio/design`, the owner's zip (3)), then the v3 overlay
    (`export/nesty-v3/design`, zip (5)): 381 files, hash-identical to the
    checked staging. This round was the only one allowed to write into
    `design/`; `export/` was removed afterwards.
  - **The designer's answers:**
    - 3c: the host rim under the host body in `doll_nest`/`doll_swallow` is
      intended. No change.
    - 3d: the reveal wipe grows from the doll's centre at art (256, 476):
      `MotionTokens.revealWipeCenter`, which `DollArt.revealCenter` now
      reads.
    - 3e: buried tower nests show the wood-grain blank
      `board/doll-silhouette.svg` for every skin
      (`BoardTokens.towerSilhouetteSprite`). `DollPartRasters` draws it on
      the 512×768 artboard when the skin service passes its board library
      (`prepare(board:)`); without it a set keeps the skin's own silhouette
      (rule 3).
  - **Accepted as delivered:** the ribbon tails may pass a 390 dp screen
    edge by up to 6 dp for about 100 ms during the 106 % pop; the
    re-rendered jingles (−17 RMS; `jingle_reward`'s limiting is an owner
    listening check).
  - **The tools now enforce what v3 promises,** so a later export can't
    bring a workaround back silently: issue `hold` (equal consecutive keys
    or `h: 1` on `travel` or `drop`), issue `imageTransform` (an animated
    anchor, position, scale or rotation on any image layer; opacity may
    animate), the `drop` null checked like `travel`, and the six new parent
    nulls required. `gen_fx_spec` no longer emits holds or animated scales.
  - **What this supersedes:** D43's list keeps only the image-slot
    compensation (raster and doll size), BoardFit placement, loading and
    the lottie 3.6.1 quirks. D40's hand-coded motions lose the tower
    reveal's drop and the 11 dp settle; the deeper silhouettes' shift stays.
- **D60. The v3 Lottie runtime (2026-09-27).**
  - **Raster units.** `FxRaster.scale` and `origin` stay in the slot's box
    units, which is what `LevelSkinImages` and `AssetSkinService` produce.
    `FxImageSlot` keeps the JSON's asset sizes (`assetWidth`/`assetHeight`,
    3× for the board pieces and the unlock symbol) and a `density` (3 for
    those, 1 for dolls), and `declaredWidth`/`declaredHeight` return the box.
    The compensation uses `r = raster.scale / density`: scale `k / r`, anchor
    `(a − origin × density) × r`.
  - **Root cause of the owner's Level 9 report (2026-09-27, device
    screenshots).** An earlier attempt of the lane had moved `FxImageSlot`
    to the 3× sizes but still read the raster scale as per 3× pixel, so
    every board piece drew at a third of its size with its anchor pushed
    three times too far: the hint arrow up and left of its doll, the glow
    ring at the shelf's left end, the +1 pads as slivers.
    `board_pieces_l9_test` renders Level 9 with the real skin images and
    Lotties and pins the arrow, the glow, both pads and a doll on a pad to
    `BoardLayout`; 4 of its tests fail with the old compensation.
  - **Hint arc.** It arrives on the source's side of the target (the board's
    middle when both are in one column), ending 48·s beside the target's
    head, 6·s below the top of its top doll (for an empty target, the
    moving nest's head). It starts 16·s toward the target and min(66·s,
    ⅔ of the doll) below the source doll's top. The control point is 0.4 ×
    the chord off its middle toward the arrival side, upward for a flat
    chord. This reproduces frame 3.1 (the MAIN-board test still gives about
    (352, 480)); on Level 9 the arrowhead now heads into brown2's head
    instead of the empty stand beside it. Other moves stay a
    `TODO(design)` generalization (Q64 asks about the start).
  - **The reveal.** `doll_reveal` plays its whole 31 frames from the move,
    and its `drop` null starts at the tower's own buried step (the
    authored (0, −18) scaled by that step). `RevealDropTween` only shifts
    the nests still buried, over the drop's 7 frames with easeOut. A
    source reveal now ends at 517 ms (the drop was a separate 120 ms
    before the 400 ms reveal). Without the file the new top shows at once
    (rule 3).
  - **Ice.** An `IceCracked` that advances the stage plays `crack_n`; one
    that doesn't plays `crack_hit_n` for the stage shown. Either then rests
    on `rest_n` (frame 16n in an export without markers).
  - **A clean seek on every jump.** `FxPlayer.epoch` changes on start,
    rest, seek and reset, and the next draw then seeks lottie to 0 before
    the target frame. lottie 3.6.1 otherwise draws `ice_0` and `ice_1`
    together when a reused drawable goes from 98.5 to 99 (verdict issue 1).
    Continuous playback never re-seeks.
  - **Ribbons.** 410-wide canvases with the anchors (205, 55) and (205, 50);
    text boxes 312×40 (win, Fredoka Bold 24) and 312×32 (chapter, 20),
    the label scaled down to fit the box's width and height. On screen the
    canvas is centred at `min(1, W/390)` (`LottieRibbonFit`,
    `ChapterRibbon.rectIn`), so it is 1:1 on the design's 390 dp phone and
    only ever scales down.
  - **Deleted:** the travel-hold fix, the `padlock_ping` rest hide, the
    11 dp glass settle, the reveal silhouette hide (the silhouette now ends
    at frame 19), the hand-coded reveal drop and the animated-scale
    callbacks (the `glow_pulse`, `slot_pulse` and `shatter_burst` nulls
    carry the pulses), together with `FxHold`, `FxTravel.holds`,
    `FxImageLayer.scaleAnimated` and `FxTiming.revealDropMs`.
- **D61. Music and jingles ship as OGG Vorbis in `design/audio` (owner
  delivery 2026-09-26; [plans/audio-integration.md](plans/audio-integration.md)).**
  - **Files.** `music_home` (Toy Shop Waltz, 66.667 s, 3/4 at 108 bpm),
    `music_game` (Quiet Shelves, 68.571 s, 4/4 at 84 bpm), `jingle_chapter`,
    `jingle_reward` and `jingle_oom`. The 17 SFX were replaced in place by
    the v2 WAVs, whose clacks are baked at 0 semitones
    (`SoundTokens.clackBakedSemitones`). That supersedes D19's +1 offset:
    the clack rate is now `2^(semitonesBySize/12)`. `SoundTokens.allFiles`
    stays the 17 WAVs; `jingleFiles` and `musicFiles` list the OGGs.
  - **Loading.** The loops stream: `loadMem(..., LoadMode.disk)`, never
    `loadAsset`, which leaves a 1.9 MB temp copy per launch. Each loads on
    first use, and the other one loads once the first has, so a crossfade
    never waits. The SFX and the jingles decode into memory; the jingles
    load after the SFX and the splash doesn't wait for them.
  - **One engine.** `SoLoudEngineHost` starts SoLoud once for whichever
    caller comes first and stops it only in its own dispose, after both
    services have freed their sounds. `SfxEngine.setPaused` and `dispose`
    now touch only the SFX's own sounds, and the music voices are
    protected, so a burst of SFX can't take their slots. An `AudioBackend`
    interface wraps the flutter_soloud calls both engines make; the tests
    run a fake with SoLoud's timing rules (fades and scheduled pauses only
    advance while a voice plays).
  - **Jingles** are a `JinglePlayer` interface implemented by the SFX
    service: the SFX bus (`jingleBus` 'sfx'), gated by the Sound setting.
    `AudioModule` registers the one instance under both interfaces.
  - **`MusicService`** (`SoLoudMusicService`, `FakeMusicService`) reconciles
    from state rather than a log of commands:
    - an 800 ms crossfade that parks the outgoing loop; a parked loop
      resumes where it stopped;
    - ducks counted per reason, the lowest factor wins (win 0.3, out of
      moves 0.4, reward 0.4, pause 0.5);
    - pause reasons as a set {background, ad}, faded back in over 600 ms;
    - the Music setting followed through
      `DatabaseService.musicEnabledChanges`: off is silent within 300 ms,
      and with Music off at launch it loads nothing;
    - silent failure (a loop that can't load stays silent until the next
      launch), and nothing per frame.
  - **Wiring.** `MusicRouteObserver` picks the track (Splash none, a level
    `music_game`, everything else `music_home`). `MusicDuck` ducks while
    the win overlay, the out-of-moves sheet (plus `jingle_oom` after the
    200 ms duck-in) and Pause are up. Pause's toggles only write the
    settings. `JingleCues.reward()` and `chapterComplete()` wait for their
    M3 and M6 callers.
  - **The owner's answers** (Q61–Q63): the iOS session is `.ambient`;
    chapter complete plays only `jingle_chapter`; SoLoud's low-latency
    output only in prod.
- **D62. The hint arrow keeps clear of the HUD (owner, 2026-09-27).** On
  boards whose top-row dolls are taller than any in the frames (the
  board-wide clamp: maxSize 3 on 3 shelves, L3 and L5–L9), the designed arrow
  (`cx, dollTop − 33·fs`) reached the HUD at the top of its 10·fs bob: the
  pause row (it ends 51 below the safe top) and, over a 4-slot row's inner
  columns, the family counter's 70 × 26 pill (it ends at 83). The owner
  chose "nudge + small push" over a full clamp, which would cover the
  doll's face on 6 levels. `SlotGeometry.hintArrowCenterX/Y` (from a
  `HudClearance` per layout, in screen dp because the HUD isn't scaled):
  - over the pill, the arrow steps sideways off it by at most a quarter of
    the pitch (Level 9's inner columns: about 10 dp);
  - then it moves down to stay 4 dp under whatever HUD piece is still above
    it, by at most 16·fs, so its tip reaches 8·fs into the doll's top at
    most (Level 9: about 13 dp on 390 × 844);
  - an arrow that clears the HUD keeps the design's place, frame 3.1's
    included.
  The middle column of an odd row can't step off the pill, so on L3, L5,
  L8 and L21–L23 its arrow drops the 16·fs and still tucks under the pill
  by 10–33 dp on a 393 × 852 screen (BACKLOG "Design gaps", a question for
  Claude Design). The
  Lottie arrow and the static fallback sprite share the rule.

- **D63. The save document lives in a Hive box (owner, 2026-09-27, Q3).**
  Spec §13.3's document (schema version, forward migrations, a save on every
  move and on app pause, restore only when `levelVersion` matches) is kept in
  a Hive box behind `DatabaseService`, not in a temp-file-and-rename JSON
  file. How it is stored (one JSON document under one key in a `save` box)
  is in [plans/plan-m3.md](plans/plan-m3.md) and the M3 design.
- **D64. `reward_medium` is a Remote Config key (owner, 2026-09-27, Q5).**
  Spec §9.4 gains `reward_medium`, default 10 (§7.3's medium payout), so a
  medium win no longer reads `reward_easy`.
- **D65. M3 starts before M2's acceptance (owner, 2026-09-27).** CLAUDE.md's
  workflow waits for the current milestone's criteria. The owner started M3
  anyway, with M2's device checks still on their side: the 60 fps profile,
  the manual L1–30 pass and the post-M2 audio and board checks. M2 stays
  "code complete; acceptance pending" until they are recorded.

- **D66. The M3 design and its frozen contracts (2026-09-27).**
  [plans/m3-design.md](plans/m3-design.md) is authoritative for M3 (BACKLOG
  cites it as "m3 §n"). The contracts stage froze, compile-clean and
  tested: `GameSessionCodec`'s API and `Generator.generateWithRetries` in
  core; `PlayRequest`, `PlayEntry`, `BoosterType`, `IntroMechanic`,
  `AppClock`/`SystemClock`/`FakeClock`/`LocalDate`, the whole `SaveService`
  and `SaveDocument` with its lenient codec and migration registry, the raw
  save accessors on `DatabaseService`, `CatalogRepository` (bundled data
  complete), `LevelGeneratorService`, `LevelResolver`, `DailyService` (fakes
  for both environments until the services lane), the route tree, and the
  M3 fields and events of the gameplay bloc. The lanes run as M2's did:
  core-codec, services, gameplay-bloc and ui-kit-arb in parallel
  (ui-kit-arb owns codegen), then four screen lanes (shell-home-settings
  owns codegen), then the integrator, one reviewer and fix-and-close
  (m3 §2, §14).
- **D67. The save document's shape (m3 §3.1, §3.4).** One JSON text, schema
  1, under `doc` in the new Hive box `save`, with §13.3's fields plus six
  additions: `museumCollected` (a date per figurine, frame 6.2, D22),
  `seenIntros`, `tutorialDone`, `bonus.next`, `daily.inProgress` and
  `playerId`. Two recorded §13.3 deviations: the `settings` object stays in
  the `settings` box (Pause, the music and the locale already follow it
  there), and §13.3's `inProgress.state`/`undo` sit inside
  `inProgress.session` (the core codec's JSON). `inProgress` holds the main
  line (a campaign or a bonus board) and `daily.inProgress` today's daily;
  generated boards also store their level JSON and tier, so a resume never
  regenerates them. The model is freezed 3; the codec is hand-written.
- **D68. How the save reads and writes (m3 §3.2, §3.3).** Reads are lenient
  and never throw (a wrong type or range is that field's default; a bad
  booster count inside a real inventory is 0, never the gift again; unknown
  top-level keys are kept and written back). Schema 0 means "no document"
  (M2 never persisted a save). A migrated, newer or unreadable document is
  backed up under `doc_backup_v<schema>` or `doc_backup_invalid` before the
  first overwrite, never replacing an earlier backup; a newer schema is
  read leniently and written back as schema 1. Writes go through one serial
  queue that coalesces changes, and the box is flushed on
  `AppLifecycleState.paused`/`detached`. If Hive can't open, the save runs
  on the in-memory database fallback and the game stays playable.
- **D69. The in-progress session's JSON (m3 §4).** `GameSessionCodec`
  format 1 stores each board as readable slot contents (the level codec's
  doll tokens, bottom to top) plus `moves`, `sets`, `extra` and `opened`,
  and the history as `{before, move}`, oldest first. The events are
  re-derived on decode with `Rules.tryMove`, which also proves the history
  replays to the saved board. Not the solver snapshot's `Int32List`: the
  engine's nest codes and `DollColor` indexes would become a contract with
  players' devices.
- **D70. Device generation (m3 §5, §6.3).** On a `GeneratorFailure` the app
  retries with `Prng.derive(seed, 'RETR', r)` for r = 1..3; a first-try
  success is exactly `generate`'s output, so no golden moves and
  `Generator.version` stays 1. Generation runs in `Isolate.run` per request
  and brings the level back as level JSON. The BACKLOG's `SolverSnapshot`
  "generate" task is dropped: `Isolate.run` copies `GeneratorParams` with
  no encoding.
- **D71. Resume (m3 §3.4, §6.4; default — Q69).** After a kill the app
  relaunches to the splash, then Home; PLAY (Level N, a bonus level or, from
  Daily, the daily) reopens the saved board exactly: the board, the undo
  history, the free undos left and the extra slots. The selection and the
  hint are not saved. A board restores only when its request, level id and
  version match (§13.3); otherwise the level restarts. The bloc saves after
  every applied move, undo, restart and +1 Slot.
- **D72. Chapters complete, and pay `reward_chapter` (m3 §6.2, §9.3;
  default — Q68).** A campaign win completes its chapter when the next
  level is in another chapter, or when no level follows and the chapter has
  its 20 levels, so with the 30-level bundle L20 completes ch01 and L30
  completes nothing. The first completion adds the figurine with the date
  and pays the new Remote Config key `reward_chapter` (default 150, like
  Q5), in the same save update as the win. Win → Continue → Chapter
  complete (4.6, `JingleCues.chapterComplete`) → Continue (`playGame`) →
  the next level.
- **D73. Coins and boosters (m3 §7).** Every earn and spend reads Remote
  Config (`reward_*`, `reward_chapter`, `daily_reward`, `streak7_reward`,
  `price_*`) and skins and themes read the catalog. A booster with no free
  use or inventory left opens the purchase popup (the bloc's
  `BoosterOffer`); a coin hint is charged only when a move arrives (D22).
  `booster_use{source}` is `free` for free and inventory uses (Q42's
  default) and `coins` when bought. M3 has no ads (the fakes behave
  offline), so the popups and the out-of-moves rows show the coin price
  only. Starting coins stay 0 (Q46); the starter gift is 3 hints and 2
  slots; the dev flavor keeps unlimited boosters.
- **D74. Bonus Endless sits outside the chapters (m3 §7.4; default —
  Q71).** No chapter progress or figurine, the last chapter's theme;
  `currentLevel` stays `levelCount + 1` and Bonus Level N is
  `bonusParams(levelCount + N)`, so levels published later are played
  first and never skipped. An expert-only level plays as its simulated tier
  (Q31). Home's PLAY names the bonus level; All Levels Done (4.9) offers it.
- **D75. The catalog and the Shop's unfinished tabs (m3 §9.1, §10.7;
  defaults — Q72, Q73, Q75).** Prices come from frames 7.3 and 7.7, plus
  Space 1,200 and ch02/ch03 at 800/1,000 before their chapter;
  `forest-bear` ships unsold. Chapters 7–10 cycle the six themes (Q38) and
  have no names. Figurines 4–10 are "The <Name> Family" with no flavor text
  until supplied (Q47). The Shop shows all four tabs; Coins and No Ads show a
  store-closed card until M6. Theme ownership follows frame 7.7: bought, or
  its chapter reached.
- **D76. The daily (m3 §8; defaults — Q67, Q70).** The date is the device's
  local date from the injected `AppClock` (the dev flavor's debug builds take
  `NESTY_FAKE_DATE=yyyymmdd`); the puzzle is `dailyParams(yyyymmdd)` with the
  retries. It unlocks once Level 2 is won. A missed day resets the streak
  unless a held freeze covers it; at most one is held, granted once per ISO
  week; a frozen day keeps the streak without adding to it; every 7th
  streak day opens the 300-coin chest; only today's date counts. A solve
  pays `daily_reward` with no ×3 and returns to Daily.
- **D77. Analytics' `level` for generated boards (m3 §12).** §14.4's events
  keep their exact parameters. `level` is the campaign order, `levelCount +
  n` for Bonus Level n (the curve's number) and the date `yyyymmdd` for the
  daily; `bonus_level_start{n}` and `daily_complete{streak}` tell them apart.
- **D78. The tutorial and the intro cards (m3 §10.4).** A script for L0001
  and L0002 gates input to one move at a time, by tap or drag, with
  legality still from core; the step follows the board's move count, so a
  restored tutorial resumes. L1's third step (the last Cherry into the
  nest) has no frame (`TODO(design)`). Intro cards show once, on the first
  board of any kind that has the mechanic, in the order towers, glass,
  ice, and lock input until "Got it".
- **D79. Settings (m3 §10.2; default — Q74).** Version and build come from
  `package_info_plus` and the links open through `url_launcher`, each
  behind a service with a fake. Privacy Policy and Support are hidden while
  their links are empty (until the owner supplies them); Restore Purchases
  and Privacy choices show disabled until M6. The language sheet lists the 9
  launch languages, only English selectable until M7. The Player ID is a
  local random id kept in the save.
- **D80. M3 packages (rule 9).** `package_info_plus` 10.2.1 and
  `url_launcher` 6.3.2 are added to the game (reasons under "Package
  reasons"); `hive_ce_generator` is removed, because the save is one JSON
  document and no type needs a Hive adapter.
- **D81. `DailyService.changes` fires only on a real change (M3
  integration).** `StreakDailyService.refresh` published its status on
  every call, and Home re-reads the status (through `refresh`) on every
  change, so the first save change on a loaded Home started a microtask
  loop that froze the app (the first move of any level, with Home mounted
  under the board). The interface already promised "after every change";
  the service now publishes only when the status differs.
- **D82. The device kill runs through `flutter drive --keep-app-running`
  (M3 integration).** `flutter test` and a plain `flutter drive` stop and
  uninstall the app when they finish (`IntegrationTestTestDevice.kill`,
  `DriveService.stop`), which wipes its data. Phase A keeps the app
  running, the OS kill follows, and phase B's install over it keeps the
  data. The scenario is the player's path: L1 and L2 won through the
  tutorial, L3 opened and reopened by Home's PLAY.
- **D83. The playthrough runs at `NESTY_FAKE_DATE=20260926` and turns the
  dev flavor's unlimited boosters off for its priced screens (M3
  integration).** The fixed date makes the daily (and so its intro cards)
  the same every run. `InMemorySaveService.debugUnlimitedBoosters` is a
  runtime override that only debug builds honour; it reaches the Hint
  popup and the priced +1 Slot row. +1 Slot itself stays free in debug
  builds (m3 §7.3), so its own popup stays covered by widget tests only.
- **D84. Home on a short screen (M3 device run; `TODO(design)`).** Frame
  2.1 places the tiles at a fixed y, which put them under the nav on a
  16:9 Android body (about 630 tall). The tiles now keep the frame's y
  where it fits and otherwise sit 12 above the nav, and the hero scales
  down into what is left. A design for short screens is a BACKLOG gap.
- **D85. "Back to Daily" pops unconditionally (M3 device run).** The
  gameplay page's `PopScope` turns system back into Pause, and it vetoed
  the win overlay's `maybePop`, so the button did nothing. It uses
  `router.pop()`, which a `PopScope` doesn't veto.
- **D86. Prices the player can't afford (M3 review FIDELITY-7).** Frames
  7.3 and 7.7 draw every price in orange whatever the balance, so the skin
  and theme cards and the skin detail keep them orange and enabled, and a
  tap the balance can't cover opens the Shop's Coins tab.
- **D87. A purchase confirm needs the offer that is up (M3 review
  CORRECTNESS-7).** `BoosterPurchaseConfirmed` is ignored unless it matches
  `state.offer`, and coins are spent only when the booster can apply, so a
  repeated confirm never charges twice. m3 §7.3's mention of a confirm
  from an Out-of-Moves row without an offer is superseded: the rows open
  the popup first.
- **D88. A restored board takes its status from core (M3 review
  CORRECTNESS-1).** `_begin` derives won or out of moves as a move does, a
  restored board still in play gets its soft-stuck check, the view opens
  the matching overlay for a restore, and the winning move is never saved
  as the board in progress. A board saved won by an older build records
  its win once on restore.
- **D89. Previews show a spinner until their art is ready (M3 review
  fix pass).** The Daily card, the Shop's skin cards and the skin detail
  show `FxSpinner` (`ui_spinner`) while the skin prepares, never a flash of
  the placeholder dolls, which draw only when the art can't be prepared
  (rule 3).
- **D90. The offline game before any backend (owner, 2026-09-28).** The
  owner asked to finish everything the game can do without a backend before
  Firebase: new levels, themes, modes (player vs computer first, player vs
  player later) and the art polish. So M7 (Art and polish, which needs no
  backend) runs next, ahead of M4 (Firebase content), M5 (the admin, which
  needs Firebase) and M6 (ads and purchases, which need their accounts).
  M7 gains the offline content (levels 31–200 in the bundle on the §3.7 and
  §6.6 schedule, chapter themes 7–10, the Q73 catalog copy) and the modes.
  The spec has no competitive mode, so vs Computer starts as a written
  proposal the owner approves (its rules then go into nesty_core, rule 2);
  the spec text it needs is proposed for the owner to add, never edited
  here. Local pass-and-play is a later proposal, online player vs player
  waits for Firebase. The golden doll (L101, §3.5) stays v1.1. The art and
  copy come from Claude Design in one request
  (`docs/plans/claude-design-request-m7.md`). The M2 and M3 device checks
  stay open for the owner.
- **D91. Large color symbols by default, and every doll preview follows the
  setting (owner, 2026-09-28).** The owner asked for Large to be selected on
  a fresh install and to show everywhere once chosen. This departs from
  spec §12.3 ("always visible (subtly)") and §13.3 (`"symbols": "subtle"`);
  the spec text stays as it is (BACKLOG "Owner inputs → Decisions").
  - `SettingsDefaults.symbols` is `large`. Only a fresh install, or a player
    who never picked a mode, changes: a stored `subtle` stays. An unknown
    stored value now reads as the default (`SymbolsMode.fromStorage`'s
    `fallback`).
  - Settings opens over screens that stay mounted, and their art bakes the
    symbols in (D45), so each kept the mode it was first prepared in until a
    restart: Home's shelf (`ShowcaseDolls`, prepared on the splash), the
    Shop tab's skin cards and the Daily card under a level. Only the board
    re-read it (review CORRECTNESS-4).
  - `DatabaseService.symbolsModeChanges` emits each stored mode, like
    `musicEnabledChanges`. `ShowcaseDolls` follows it, and the widgets use
    the `FollowsSymbolsMode` mixin (Home through `SymbolsModeBuilder`). The
    old art stays up until the new art lands, except on the Daily card,
    which shows its spinner (D89). The splash's placeholder dolls take the
    stored mode too.
- **D92. The offline game's engagement: audience, respect rules and eight
  features (owner, 2026-09-28).** The owner asked for a researched brainstorm
  of what keeps players coming back, before any backend.
  - **How it was made:** two read-only research workflows (six web
    researchers, two code mappers, clustered critics), then the lead checked
    every claim against the repo. Result and sources:
    [plans/offline-game-brainstorm.md](plans/offline-game-brainstorm.md).
  - **Audience:** spec §1 is unchanged: 13+, with an all-ages feel, and not
    made for or marketed to under-13s. Engagement is still designed as if
    children may play, because the UK Children's Code judges by who is likely
    to use a service, not by its rating. So non-essential notifications are
    off until the player opts in, copy is value-framed and nothing nudges.
  - **Respect rules (E1):**
    - no paid or unpaid randomness in rewards;
    - no lives or energy, and no timers in normal levels;
    - no countdown, scarcity or fail-triggered offers, and no streak saves;
    - computer rivals always labelled;
    - every level winnable from its start with no booster (§5.3 rule 8);
    - a missed day never takes anything away;
    - notifications opt-in and at most one a day.

    M6 inherits all of it. Every M7 feature passes the six-question ethics
    checklist (brainstorm §5).
  - **Approved in principle:**
    - the gentle streak (E2);
    - the daily share card (E3);
    - the opt-in daily reminder (E4);
    - the milestone chest (E5);
    - relaxed mode (E6, moved up from §19);
    - replay with best moves (E7);
    - Records and badges (E8);
    - first launch opens L1 (E9).

    Also the chapter plan for L31–200 (E11), two new `bundle check` gates
    (E12), a time-to-first-win measure (E13) and an in-app reduce-motion row
    (E14).
  - **Rules:** each rule is written for the owner to paste into GAME_SPEC.md
    in [plans/spec-proposals-m7.md](plans/spec-proposals-m7.md). Claude
    never edits the spec. Until the owner pastes it, that text as approved
    here is the rule (Q85), the same way D19–D22 settled deviations. Numbers
    are defaults behind Remote Config keys (rule 6): Q76–Q87.
  - **Planned packages** (rule-9 reasons; each gets its row below when it's
    added):
    - `share_plus`: the OS share sheet for E3;
    - `flutter_local_notifications`: local, offline daily scheduling for E4;
    - `timezone` and `flutter_timezone`: its local-time daily schedule needs
      them.

    None needs a network.
  - **Deliberately not in M7 (brainstorm §6, §7):** a home-screen widget, a
    weekly puzzle, stars and par, a diorama, micro-expressions and time
    attack. Rejected: lives, loot boxes, streak saves, an expert bot, and
    alternating turns against the computer.
  - **Corrections the research needed:** only two bots exist; pitched clacks
    and combo chimes are already built; the §7.5 streak reset is a rule, not
    a bug.
- **D93. vs Computer is a race against three computer rivals (owner,
  2026-09-28).** Approved in principle; the full rules are in
  [plans/mode-vs-computer.md](plans/mode-vs-computer.md) (spec-prop §7.7).
  - **The race:** the player and the rival solve identical copies of one
    generated board, and whoever completes every family first wins.
  - **Rivals:**
    - rival 1: the casual bot, about 3.0 s per move, easy boards;
    - rival 2: the smart bot, 2.4 s, medium boards;
    - rival 3: the smart bot, 1.6 s, medium boards.

    They unlock in turn after Level 20. Only spec §6.4's two bots are used:
    no new policy, so the simulator and `Generator.version` are untouched.
  - **Fairness:** in a race undo and restart are free, and hint and +1 Slot
    are off, so a race can't be won with coins or ads. The rival restarts
    itself when its run dies, and pausing pauses it.
  - **Results:** a win pays coins (20/30/40). A loss costs nothing. Rematch
    replays the same board and the same rival moves.
  - **Saving:** a race never resumes.
  - **Labelling:** every rival surface says "Computer" (Skillz v. Papaya:
    bots posing as humans).
  - **Core:** a public, seeded rival API over `BotPlayer`, with the restart
    rule and the race board params. The app owns the clock (rule 7).
  - **Not picked:** a ghost race and alternating turns stay later (the
    latter is the hot-seat proposal's basis).
- **D94. CLAUDE.md is kept current in the same change (owner, 2026-09-28).**
  The owner asked that a session never need to read the whole repo to
  orient itself, and that CLAUDE.md always stay up to date.
  - CLAUDE.md gained "Current state", a Code map with a services table, and
    the missing commands and folders.
  - Its "Keeping this file current" section says what triggers an update.
    Any session keeps the facts current (state, layout, Code map, Commands).
    Its rules change only when the owner asks.
  - `tools/test/claude_md_test.dart` fails CI when a workspace member,
    top-level folder, `nesty_tools` script, `.claude/rules` file, game
    feature folder or DI-bound interface is missing from it.
  - `/milestone` (step 7) and `/feature` (step 9) include the update.
  - The docs-writer agent and the M7 kickoff prompt no longer forbid
    editing CLAUDE.md's facts.
- **D95. The M7 design and its phase-1 contracts (2026-09-28).**
  [plans/m7-design.md](plans/m7-design.md) is authoritative for every M7
  lane (BACKLOG cites it as "m7 §n"; where it and plan-m7 differ, it wins).
  The phase-1 contracts stage froze, compile-clean and tested: save schema 2
  with its migration, the settings keys `relaxed` and `reduceMotion`, the ten
  spec-prop §9.4 Remote Config keys, `PlayRequest.replay` and its resolver
  case, the records, badge and chest rules, `ChaptersRoute` and
  `RecordsRoute` with their cubits, the new gameplay, Home, Settings, Daily
  and splash state fields, the bloc's `DatabaseService` dependency, Home's
  `RemoteConfigService` one, `SkinService.selectedSkinChanges`,
  `BadgeToast`, the phase-1 ARB keys and the two E1 tests (m7 §1). The lanes
  run in parallel on exclusive paths (levels, meta-services, gameplay-bloc,
  menus, gameplay-ui, board-fx, overflow), every codegen run goes through
  one lock script, and the integrator does every cross-lane edit (m7 §2,
  §18). No new service: the meta rules are pure Dart over `SaveService`,
  like M3's streak.
- **D96. Save schema 2 (m7 §3; plan-m7 decision 1).** One migration step,
  1 → 2, carries every M7 field, the race's included, so players migrate
  once. New keys: `levelBests` (`"<id>@<version>"` → fewest moves),
  `records` (`families`, `dolls`, `dailies`, `longestRun`, `badges`),
  `chests` (`opened`, `bonusOpened`), `race.rivals` (three, `unlocked`,
  `wins`, `raceNo`; rival 1 unlocked on a fresh save), and `daily.lit` and
  `daily.run`. The step sets `lit = streak > 0`, `run = longestRun =
  streak`, `dailies` = the distinct dates in `done`, the rest empty; the
  badges the save implies are granted on load. The raw schema-1 text is
  backed up under `doc_backup_v1`. Reads stay lenient: a `lit`/`run` pair
  that disagrees reads as paused, unknown badge ids are kept, there are
  always three rivals, and a replay board in progress is dropped.
- **D97. Bonus chests are kept apart (m7 §3.1, §9; default — Q93).**
  Spec-prop §13.3 shows only `chests.opened`. Bonus chests go in
  `chests.bonusOpened` (bonus numbers), so a chapter M4 publishes later
  (L210) can never collide with a bonus number already opened.
- **D98. The gentle streak's state machine (m7 §8; plan-m7 decision 4;
  defaults — Q96, Q97).** `streak` counts the days solved on their own
  date and never drops; `run` is the unbroken run (a frozen day keeps it);
  `lit == (run > 0)`. A miss a freeze covers keeps the flame lit; a miss
  without one pauses it (`lit` false, `run` 0, `lastDate` null, the count
  kept); the next solve relights it (`streak + 1`, `run` 1). The chest stays
  on every 7th counted day, and `records.longestRun` keeps the longest run.
  "Relit" is a moment (`DailyProgress.relitOn`: `run == 1 && streak > 1` on
  that date), shown on the daily win card, never a stored flag or a Daily
  toast. The paused look recolors the whole card and badge neutral, never
  red. The worked table in m7 §8 is the meta-services lane's test.
- **D99. Settings keys `relaxed` and `reduceMotion` (m7 §4; plan-m7
  decision 2).** In the `settings` box, never renamed or reused: `relaxed`
  (bool, false) and `reduceMotion` (`system` | `on` | `off`, `system`), with
  `DatabaseService` getters, setters and change streams in Hive and the
  fake. They are not save fields, so no schema step. Phase 3 adds the
  reminder's keys under other names.
- **D100. Replay is its own request kind and is never saved (m7 §6;
  plan-m7 decision 5; default — Q90).** `PlayRequest.replay(order)`
  (`PlayKind.replay`), so no code that means "the campaign" matches a
  replay by accident. Only a won level replays (`order < highestLevel`);
  the resolver gives its campaign board paying 0 and completing no chapter,
  and nothing follows it. The save never stores its board (a kill loses
  only the replay), the codec drops a stored one, no tutorial cue or intro
  card shows, and Continue pops back to Chapters. Replays log spec §14.4's
  level events like their campaign level (`level` = the order, D77's
  convention), with no new event.
- **D101. The win path stays one save update and reports what it did (m7
  §7).** `SaveService.recordLevelWin` now returns a `LevelWinOutcome`
  (`bestMoves`, `previousBest`, `chestPaid`, `newBadges`). The record gains
  `bestKey`, `chest`, `families`, `dolls` and `boardBadges`; the bloc fills
  them from pure rules (`LevelBests`, `MilestoneChest`, `RecordRules`,
  `BadgeRules`). In the same update the save pays the level's coins (0 for a
  replay, whatever the record says), moves the progress (none for a
  replay), pays the chest once, keeps the best, adds the records and grants
  the badges. `stats.wins` counts every win, replays included.
- **D102. Best moves per bundled level id and version (m7 §11; plan-m7
  decision 6; default — Q88).** Campaign levels and replays only, first play
  or replay, keyed `L0024@2`, so a new version starts a new best. Daily,
  bonus and race boards keep none; their win card shows "Moves N". Moves are
  never shown during play.
- **D103. The milestone chest (m7 §9; plan-m7 decision 7; defaults — Q76,
  Q89, Q93).** Level 10 of every chapter (`(order − 1) % 20 + 1 == 10`) and
  every 10th bonus level; `chest_coins` 100 and `chest_hints` 1, fixed and
  shown before it opens; paid in the win's update, once per level number,
  never on a replay, a daily or a race. The modal only shows it, after
  Continue and before Chapter complete. The win card counts down to it
  while it is the nearer goal (positions 1–9 of a chapter, always in Bonus
  Endless), otherwise it shows the figurine bar; the HUD's coin hold
  subtracts its coins.
- **D104. Relaxed mode is read live (m7 §10; plan-m7 decision 8; Q84).**
  `GameplayBloc` takes `DatabaseService` (its ninth constructor argument)
  and follows `relaxedModeChanges` (`RelaxedModeChanged`), so a toggle from
  Pause → Settings applies at once. With it on, undo is free and unlimited
  in every mode: no popup, no spend, the badge shows "∞", the Out-of-Moves
  row says "Always free". Hint and +1 Slot are unchanged.
- **D105. Records per won board, every mode (m7 §12; plan-m7 decision 10;
  default — Q91).** Families add each won board's `totalSets`; "dolls
  nested" (the dolls that go inside another) adds `totalSets × (maxSize −
  1)`, the dolls that end inside another, so undo, restart and the route
  never change it. Campaign, replay, bonus, daily and (phase 2) won races
  count; only won boards add. Levels won is derived (campaign behind
  `highestLevel` plus bonus levels), dailies count one per date, and the
  longest streak is the longest run.
- **D106. The twelve badges (m7 §12; defaults — Q83, Q94).** The brainstorm
  §3 E8 list with exact triggers. Four come from the won level (a glass
  case, ice that thaws, `maxSize ≥ 5`, `maxSize 6`) and eight are derivable
  from the save (`first_family`, level 100 and 200 won, 7 and 30 dailies,
  a race won, every rival beaten, the ten launch figurines). They are
  granted only in a win's update (then toasted, one each) and on load
  (silently). Badges pay nothing and are never taken away.
- **D107. First launch opens Level 1 (m7 §13; plan-m7 decision 11).** While
  no level is won (`highestLevel <= 1`) the splash replaces itself with L1's
  board, with no Home underneath; a kill during L1 comes back to it; the
  first win's Continue goes to Home. Returning players are unchanged. The
  router and app-flow widget tests and the device playthroughs that tap
  Home's PLAY first are rewritten.
- **D108. Reduce motion at the app root (m7 §14; plan-m7 decision 9).** The
  app root overrides `MediaQuery.disableAnimations` from `reduceMotion`
  (system = the OS value), so `context.reduceMotion`, `LottieFxView`, the UI
  kit and the board's `MotionSpec` follow it unchanged. Sounds and haptics
  keep their strength.
- **D109. Entry points (m7 §15.8, §15.9; plan-m7 decision 12; defaults —
  Q92, Q98; `TODO(design)`).** A row of Chapters and Records buttons under
  Home's header, a Chapters button on the Museum screen, and a fourth Home
  tile, "vs Computer": locked with "After Level 20" (`race_unlock_level`)
  until that level is won, then "Coming soon" until phase 2 ships the race.
  `SkinService.selectedSkinChanges` is added so Home's shelf follows a skin
  equip (the M7 fix).
- **D110. The E1 copy rewrites and respect tests (m7 §8, §16, §17; plan-m7
  decision 4; default — Q95).** "Play today to keep your streak" → "Play
  today to add to your streak", "Streak saved!" → "Freeze used", and frame
  5.2's "0 left" → "No freeze". Two tests guard the rules from now on:
  every streak, freeze and chest string against a deny-list of loss, guilt,
  urgency and scarcity wording (phase 3 adds the reminder's), and no reward
  path reads an unseeded random source or the wall clock (phase 2 adds the
  race's). All new copy is a placeholder until Claude Design's copy.md.
- **D111. Home drops the Museum tile (owner, 2026-09-28, simulator
  review).** The bottom nav's Museum tab is already the way in, so Home's
  tiles are Daily, Remove Ads (hidden once bought) and vs Computer. This
  departs from spec §10.2 #2 ("Tiles for Daily …, Museum … and Remove Ads")
  and frame 2.1; the spec text stays as it is, and the design request asks
  Claude Design for 2.1 without the tile.
- **D112. A price the balance can't cover opens a dialog first (owner,
  2026-09-28, simulator review).** Replaces D86's direct jump to the Shop's
  Coins tab, on the Shop's skin cards, theme cards and skin detail. The
  dialog names the price, how many more coins are needed and where coins
  come from (wins, the daily, chests), with "Go to Shop" (the Coins tab) and
  "Not now". It opens only on the player's own tap on a price, so it isn't a
  fail-triggered offer (spec-prop §1.1 rule 4), and its copy is
  value-framed. The prices stay orange and enabled (frames 7.3, 7.7). The
  booster popup keeps its disabled coin button (frames 3.2, 3.8) unless
  Claude Design says otherwise (design request J.3).
- **D113. Levels 31–200 (M7 phase 1, levels lane; defaults — Q102–Q106).**
  Generated with `nesty_levels generate` from each order's curve row
  (±1 colour, another uniform shape, towers ±1, plus the knobs a chapter
  twist names), seeds `5_000_000 + order × 100 + k`, and picked by a scored
  search over about 41,700 analysed drafts: valid and solved at the admin
  budget, the declared tier simulated, smart ≥ 150/300, a signature unlike
  both neighbours, at least the moves of the level 10 before it and fewer
  than its finale. Every new level also solves from its start within 20,000
  nodes (spec §6.3's soft-stuck budget), a selection rule pinned by
  `repo_levels_test`. The intro levels leave their rows to teach each
  mechanic alone (L31, L51, L71: no towers, 3–4 colours). Chapter 5 has no
  empty slot at the start. The finales rise 22 → 35 moves, each the longest
  of its chapter. Every new level is version 1; `levelsVersion` stays 0
  until M4's manifest reads it. L1–L30 are byte-identical to what shipped.
- **D114. E12's `bundle check` gates (levels lane; defaults — Q99–Q101).**
  A layout signature per level: the slots per shelf, the sorted tower
  depths, the glass cases, the iced slots, the colour count and `maxSize`
  (colours, positions and set cuts are a reskin, so they are left out). Two
  consecutive levels with one signature are an error from L3 (L3–L30
  already differ, so no warning band). An expert-only level (smart under
  half) is an error from L31, and `maxSize` 6 on any slot but a super hard
  one is an error (spec §3.7 "occasional maxSize 6 super hard levels").
- **D115. The H/S review fix pass (levels-fix; defaults — Q107–Q109).** The
  review played every hard and super hard level through its solution and a
  casual run and raised 7 concerns. 23 levels were re-picked or re-tuned: the
  review's four near duplicates, 17 more found by a measure calibrated on
  them, L160 (casual 0 → 7/300) and L170 (casual 0 → 27/300, smart 300/300).
  L200 stays the one level the casual bot never wins (smart 300/300): no
  single swap keeps it longer than L180 and lets it win. Four side-by-side
  easy pairs stay alike, since the chapter plan leaves no knob to separate
  them. Two repo tests pin the result (no near duplicates within two levels
  but those pairs; from L31 only L200 has casual 0/300); the measure is not
  a `bundle check` gate.
- **D116. The board fixes (board-fx; defaults — Q110, Q111).** +1 Slot plays
  one button sound: the booster's own tactile feedback stays and the
  timeline's cue for `ExtraSlotAddedEffect` goes, which covers both tap
  sites (the booster bar and the buy popup). The `ui_extra_slot` loop now
  starts 24 frames in (`StartClip.phaseMs`, `FxTiming.extraSlotRestFrame`),
  where its scale is exactly the static pad's 100 %; its opacity is still
  about 88 % there, a smaller pop than before (design request E.21). The
  "+N" tower tag and the ice digits come from `boardTowerHidden` and
  `boardIceCount` with the locale's text direction (`BoardLabels`, handed to
  the board by `GameplayView`).
- **D117. The gameplay bloc's M7 details (gameplay-bloc).** `dailyRelit` is
  read against the daily's own date, the one `progressAfterSolve` was given,
  not the clock's today. Relaxed mode turning on mid-level closes a pending
  undo offer, and `_confirmPurchase` never charges for undo while relaxed. A
  replay shows no tutorial cue and no intro card and skips
  `_persistProgress`, whatever the save says.
- **D118. The Museum and Chapters derive "earned" (menus, owner-home; the
  owner's review; default — Q113, Q115).** A chapter whose levels are all
  won reads earned (collected, or `done ≥ total`) on the Museum and on the
  Chapters emblem, so the dev picker (or anything that moves progress
  without a win) can't leave "Classic · soon" on a 20/20 chapter. Nothing is
  written to the save; a silent load-time catch-up of `museum` is a BACKLOG
  item. The Chapters stand-in v2 adds each chapter's emblem (theme colour
  and its family, collected or a silhouette), its progress bar, the current
  level's glow and play badge, a finished chapter folded into a compact
  row, the scroll to the current chapter on open, the chest and finale
  marks, the hard and super hard edges on won and current cells, "Level N of
  200" under the header and a staggered fade-in that reduce motion skips.
  Home keeps `onMuseum` on its constructor, unused since D111; Chapters,
  Records and the Museum keep their direct router calls, and their tests
  check the wiring.
- **D119. The Shop and the dev picker (owner-fixes; D112).** `ShopCubit` and
  `SkinDetailCubit` also follow `SkinService.selectedSkinChanges`, which
  fires once an equip has landed (the real `AssetSkinService` rasterizes
  first), so "Equipped" moves at once. `buySkin`/`buyTheme` return
  `PurchaseOutcome`, and `needsCoins` opens `NotEnoughCoinsDialog` only from
  the player's own tap on a price. Its "Not now" is the standalone `notNow`
  key, outside the respect test's prefixes (its deny-list word "now" targets
  urgency copy). The picker groups its tiles by chapter, has a close
  button, and opens at Home's current level (`currentOrder`); `NestySheet`'s
  scroll area clips, so a scrolled row never paints over the title.
- **D120. The chest opening (owner-chest).** One `ChestRewardSequence`
  (`features/fx/chest/`) behind both chests: arrival (600 ms), a looping
  idle with the contents shown from the start, Open (a 480 ms wiggle, then a
  750 ms burst with the chips popping and the reward jingle), and Collect,
  which flies six coin sprites to the HUD's coin pill and the hint to the
  Hint button, then fades out. It grants nothing (the win or `collectChest`
  already paid), its buttons are phase-guarded and a second tap skips to the
  end; reduce motion crossfades with no wiggle or flights. Stand-in choices
  until Claude Design's I.3: `whoosh` for the lid, six sprites whatever the
  amount, a glow on the Hint button rather than a count bump, the
  `complete` haptic, and a private `RibbonTitle` subclass for the drop.
- **D121. The overflow suite (overflow lane, integrator; default — Q112).**
  `test/overflow/` pumps every screen and overlay at the five M7 sizes
  (`overflowScreenSizes`: 360 × 640, 390 × 844, 430 × 932, 375 × 667,
  768 × 1024) and both text scales with `expectNoLayoutErrors`, over
  worst-case data. The shell is swept as its chrome (`NestyBottomNav`) and
  `HomeView` apart. The integration added Chapters late in the game (every
  won cell's best moves and the tier edges), the paused and long lit Daily
  streak (the sweep had been all paused, since `DailyStatus.lit` defaults
  to false) and the day-7 chest's open step.
- **D122. The splash checks the bundle on a worker isolate (integrator;
  CLAUDE.md rule 8).** At 200 levels the decode and rules 1–7 took 57–75 ms
  AOT and 232–354 ms JIT on the dev Mac (6–12 ms for 30), several frames on
  the splash. `BundledLevelRepository` now hands the asset text to
  `checkInBackground` (`compute`, isolate `nesty.levels.check`), which runs
  the pure `checkBundle` (nesty_core's codec and `Validator`, no rule of its
  own) and returns plain data, and it logs the time and the isolate. The
  checker is injectable, so a test can prove the work leaves the caller's
  isolate.
- **D123. E9 in the splash page, and the device checks' M7 flow
  (integrator; default — Q114).** The splash replaces itself with
  `GameplayRoute(PlayRequest.campaign(1))` while `opensFirstLevel`. The
  whole-app widget tests whose subject starts at Home seed a save past Level
  1 (`seedSavePastFirstLevel`). The playthrough starts in Level 1, reports
  E13 as the time from `main()` to Level 1's first playable frame
  (`NESTY_E13`, `playthrough.json`), and adds Chapters with a replay,
  Records, the Shop's dialog and an equip, the reduce-motion sheet, the
  L30 and L130 chests, one segment per new mechanic on the levels lane's
  teaching orders (checked with `Rules.tryMove`) and L200 into All Levels
  Done. The fixed date's daily keeps introducing glass, so L31 shows no
  card; L51 shows ice's. Resume phase A starts in Level 1, and the daily
  fingerprint works from either Home or Level 1.
- **D124. E1 and the chests, integration details (integrator).** The
  reward-randomness test also scans the chest opening (`fx/chest/` and both
  chest modals), since the amounts it shows and counts up must be the ones
  paid, and fails if a scanned path disappears. `/review` gains an ethics
  lens (step 5: spec-prop §1.1 and the six questions; a failing answer is a
  P0). The day-7 chest's coins fly to the Daily header's coin pill
  (`ScreenHeader.coinPillKey`), which adds each coin as it lands and hands
  over to the paid balance at Collect. `NestyToast` cancels its dismiss
  timer when its tree goes away.
- **D125. Star ratings: 1 to 3 stars per level (owner, 2026-09-28).** The
  owner asked for star ratings "like other games, 3 stars the highest". This
  reverses D92's "stars and par are not in M7" (brainstorm §6), and the owner
  chose each rule from four options:
  - stars come from moves against par, with slack: 3★ within par + 20 %,
    2★ within par + 60 %, and 1★ for any win (`star3_slack_pct`,
    `star2_slack_pct`);
  - a hint or an extra slot caps the win at 2★, so stars can't be bought,
    while undo and restart never count;
  - stars appear on levels 1–200 and their replays (the win card, Chapters,
    Records), and the daily, bonus and race boards keep moves only;
  - stars are cosmetic only: no pay, no unlock, no gate, nothing during
    play.

  Par is the solver's optimal solution (A*, spec §6.3). It is written into
  the bundle at build time and checked by `bundle check`, and no level's
  data or version changes. Each level keeps its best stars. The rule text
  is spec-prop §7.10 (with lines in §7.8, §9.4, §10.2, §13.3 and §18), and
  it counts as spec until pasted (Q85). The plan is
  [plans/star-rating.md](plans/star-rating.md), which also covers keeping a
  1★ win a win, the swap points and the tests. The art is design request K.
  It is built in phase 3, and its smaller defaults are Q116–Q120.
- **D126. The Daily runs after L31 in the playthrough (device stage, M7 phase 1).** The task asks for L31's glass card, which the fixed date's daily showed first; a player who skips the daily meets each card on its schedule level (L16, L31, L51).
- **D127. E13 reports two times (device stage, M7 phase 1).** The navigator keeps the splash mounted while L1 slides in, so "playable" and "alone on screen" differ (by 2–190 ms here); the owner can pick the headline (question Q121).
- **D128. The mechanic segments finish with the solver helper after the teaching moves (device stage, M7 phase 1).** The task asks for it, and L31, L51, L71 and L130 are on the owner's re-tune list (Q107), which would break a fully scripted line. `solveWithHints` is called after the teaching moves in the playthrough.
- **D129. The ribbon shows only on bundled boards (device stage, M7 phase 1).** Design README 4.7 ("on the first level"); replays keep it, since nothing says otherwise. Fix: `_showRibbon = state.play.request.isBundled && chapter.opensWithRibbon`. Regression: `gameplay_view_test.dart` "a daily/bonus board in a later chapter theme opens without a chapter ribbon".
- **D130. The Museum label scales down instead of wrapping (device stage, M7 phase 1).** The shelf face is a fixed 104 px and a second line would overflow it; m7-design §15's shared rule. Fix: `FittedBox(scaleDown)` inside a 3 dp horizontal inset, with `TODO(design)` for J.2. Regression: `museum_page_test.dart` "every cabinet label shows whole at W × H S".
- **D131. nesty-test boots the emulator with audio (device stage, M7 phase 1).** The playthrough requires every sound to load. Fixed in `tools/scripts/nesty-test`.
- **D132. vs Computer's phase-2 design and contracts (M7 phase 2, contracts
  stage).** [plans/m7-design.md](plans/m7-design.md) "Phase 2" (P2.1–P2.15)
  is authoritative for the race lanes, and its frozen files compile, are
  documented and have minimal tests (`test/contracts/m7_phase2_test.dart`).
  The race core that the race-core lane built ahead of the workflow was
  reviewed against spec-prop §7.7 and frozen as is (no core change). Lanes:
  race-services, race-bloc and race-ui in parallel on exclusive paths
  (P2.13), then the integrator; codegen only through the lock. The
  architecture proposal was adopted with the departures P2.14 lists.
- **D133. Plan-m7 decision 14, as built: the race core (m7 P2.3; defaults —
  Q127).** Core gains a public `RivalBot` over the simulator's run loop
  (`BotPlayer.stepRun`, which `BotPlayer.play` now repeats), `RivalStep`
  (`moved`, `finished`, `restarted`) and `SimBot` (exported alone); the
  engine and `BotPlayer` stay internal. The restart rule is core's: at the
  250-move cap or with no useful move, a step restarts the run with no
  move (a restart takes a step of its own). Run seeds are
  `Prng.derive(raceSeed, 'RVL0' + policy.index, run)`: a departure from
  decision 14's `Prng.derive(raceSeed, policy, run)`, whose casual run 0
  would be the generator's attempt 0 of the same seed, often the stream
  that built the board (accepted by the lead). `Generator.version` stays 1:
  every existing golden is unchanged. As decision 14 says, the app owns the
  clock through an injected ticker, the rival steps on the UI isolate (a
  move step allocates nothing; worst smart step 4.8 µs AOT), and choosing a
  rival or New race starts `raceNo + 1` while Rematch keeps it.
- **D134. Race boards (m7 P2.3, P2.4; defaults — Q125, Q126, Q130).**
  `DifficultyCurve.raceSeed(rival, raceNo)` = `3_000_000 + rival × 100_000
  + raceNo` for rivals 1–3 and raceNo 1–99,999 (`maxRaceNo`), so each
  rival's seeds keep their own block; `racePolicy` (1 casual, 2 and 3
  smart) and `raceTier` (1 easy, 2 and 3 medium, Q80) sit in core with the
  seed (rule 2); `raceParams(rival:, raceNo:, highestWonLevel:)` is the
  stage board of the rival's tier with id `race-<rival>-<raceNo>`. The app
  passes the highest level won (`RaceRules.stageLevel` = `highestLevel − 1`,
  at least 1). Race-core's sweep generated 1,500 race boards with no
  failure and every tier on target.
- **D135. `PlayRequest.race` (m7 P2.4).** A race is its own request kind
  (`PlayKind.race`, never stored), generated on the device and never saved
  in progress: the save ignores it, the codec drops one, and
  `recordLevelWin` records nothing for it. `DefaultLevelResolver._race`
  refuses a race while the mode or the rival is locked or its numbers are
  out of range; otherwise it generates `raceParams` in the isolate, paying
  `race_reward_<rival>`, on the current chapter's theme (Q129), cached so a
  Rematch gets the same `Level`. Nothing follows a race (`next` is null). A
  board that can't be made shows the page's failure card, which leads back
  to rival select.
- **D136. `RaceCubit` beside the gameplay bloc (m7 P2.5; defaults — Q124,
  Q127).** The race is the gameplay page with a race request (plan-m7
  "Rejected: a separate race page and bloc"): the page provides a
  `RaceCubit` next to the bloc. It mirrors the rival in a second
  `GameSession` of the player's own `Level`, steps it on an injected
  `FrameTicker` (a raw Flutter `Ticker`), at most once per frame, with each
  frame's time clamped to 250 ms, draws the jitter from the race's own
  `'PACE'` stream (`RaceRules`), stops on any hold (Pause, a sheet or
  overlay, the app in the background), records the player's win once, and
  settles a tie by frame order: a player's move lands in its input task,
  before the next frame's rival step, so on the same frame the player wins.
  Rematch and New race stay on the page. `NESTY_RACE_PACE_MS` sets the pace
  in a dev debug build only.
- **D137. The gameplay bloc's race mode (m7 P2.6; defaults — Q128).** In a
  race, board input waits for `RaceGateChanged(open: true)` (the page sends
  it while the race runs); undo is free and unlimited, restart is free, and
  Hint and +1 Slot give no offer and spend nothing; no tutorial, intro
  card, restore or in-progress save; the win records nothing through the
  level path (no best moves, Q88), and no spec §14.4 level event is logged.
- **D138. The save's race API (m7 P2.7; defaults — Q124, Q126).**
  `SaveService.beginRace(rival)` stores the next raceNo when the race is
  chosen, so a quit or a kill never hands the same board back as a new
  race; `recordRaceWin` pays `race_reward_n`, adds the win, unlocks the next
  rival (1 → 2 → 3), counts `stats` and the records (Q91) and grants the
  badges (`first_race`, `all_rivals`) in one update, through the badge step
  both win paths share. A loss writes nothing. Schema 2's `race.rivals`
  already holds every field, so there is no schema step and no Hive change.
- **D139. Rival select, the race stand-ins and E1 (m7 P2.8, P2.10–P2.12;
  defaults — Q131–Q134).** `RivalSelectRoute` with `RivalSelectCubit` (the
  three rivals, their rewards shown before the race, wins, locks); the
  ui-designer's stand-ins adjusted to the frozen names (P2.10); 31 ARB
  placeholders; "Computer" on every rival surface, pinned by
  `arb_keys_m7_test`; the respect copy test covers `race*`, and the
  randomness test the race's paths. Home's vs Computer tile opens rival
  select once unlocked, and its "Coming soon" footer retires (Q98's
  default runs its course).
- **D140. The race page's hand-offs, fixed at integration (m7 P2.4, P2.5,
  P2.10; integrator).** The lanes' page passed its widget tests but would
  have failed on a device, where the Flame board reports the win after the
  winning batch: that report opened 2.8's "Level Complete!" and its
  Continue over the race. Now a race's won board opens 9.4 (only when the
  race is the player's; a move landing just after the computer finished
  keeps 9.5), and the computer's finish opens 9.5 at once over a frozen
  board. Back to rivals, Quit race and the failure card now `pop` (the
  page's `PopScope` vetoed `maybePop`, which reopened Pause or did
  nothing). A race board that can't be made, on the first load or on
  Rematch or New race, shows the failure card with Try again and Back to
  rivals (P2.4) instead of a dead page; Rematch and New race ignore a
  second tap. The HUD's coin pill shows the save's live balance in a race
  (P2.10 "no coin hold"). The rival strip lets taps through to the board,
  since it sits in the top shelf's hit band. Regression tests:
  `gameplay_view_race_test.dart` and `app_flow_test.dart` (i), which runs
  the tile, rival select, a won race, Back to rivals and Quit race on the
  real router and the real Flame board.
- **D141. Race stand-ins brought back to m7-design (P2.9, P2.10;
  integrator; default — Q135).** 9.4 plays 2.8's celebration as P2.10
  lists (race-ui's stand-in had dropped it): `fx_confetti` (none with
  reduce motion), the `win` cue and haptic, then `fx_coin_burst`, the
  `coins` cue and the count-up, timed by `WinOverlaySchedule`, on 2.8's
  own pill (`WinCoinPill`, made public). Both results duck the music as
  2.8 does until C.7's jingles land. The strip's counter bumps once when a
  rival family lands (`motion.complete.counterBump`), and a separate
  portrait nudge is its per-move "moved" beat (P2.9); the state line drops
  below 340 dp (race-ui's call, Q135). Rival select no longer hides its
  Race button and reward from screen readers: each card is labelled
  "Rival N, Computer" and its reward, wins and Race button stay readable
  and actionable.
- **D142. The rival-1 playthrough segment and E1's race test (m7 P2.12,
  P2.13; integrator).** `_raceRival1` in `integration_test/playthrough_test.dart`
  runs after level 20's chapter complete and the Museum visit, where
  `highestLevel` is 21, so the board is `race-1-1@20` (checked against
  `Generator.generateWithRetries(raceParams(1, 1, 20))`). A race has no
  Hint, so the player's moves are `Solver.solve`'s solution, tapped one by
  one. The test requires `NESTY_RACE_PACE_MS=600000` (one rival move every
  10 minutes ± 20 %), which `nesty-test` passes and README documents; only
  a dev debug build honours it (`race_rules_test`). It checks "You win!",
  +20 coins, rival 2 unlocked, "New rival unlocked!", "Computer" on every
  rival screen and no Hint or +1 Slot, and takes screenshots 25–25f.
  `test/ethics/race_respect_test.dart` runs a race through the real bloc
  and cubit (no offer or spend, coins only rise by the reward, a loss and a
  quit write nothing, nothing in `RaceState` counts down), and
  `respect_copy_test` checks every string a race shows, its reused keys
  included, against the deny-list and a taunt list. `homeVsComputerSoon`
  is retired.

- **D143. The phase-2 device run (2026-09-28, device stage).** The rival-1
  segment and every device check pass from fresh installs on the iPhone 16
  Pro simulator (iOS 18.3; playthrough 430 s, 85 screenshots) and the API 35
  emulator (420 s). Resume phase A matched phase B in all four runs, and the
  daily's fingerprint is the same on iOS, Android and in nesty_core
  (daily-20260926). The screenshots found two stand-in bugs, each fixed with
  a regression test:
  - The strip's counter pill drew squashed, about 33×9 dp, because its
    painter maps the counter's 120×60 canvas onto whatever box it gets. It
    now draws at 0.8× (`rival_strip_test`).
  - 9.4's moves line, rival row and actions couldn't be read on the scrim.
    They now sit on a ModalCard, like 9.5's (`race_result_overlay_test`).

  Left as design gaps and BACKLOG items:
  - the toasts on 9.4 (Q136);
  - the strip's state line on screens under 404 dp (Q135);
  - the strip over the top shelf's tall doll;
  - "Thinking…" after the player wins;
  - a race loss run on a device.
- **D144. Phase 3's design and contracts (M7 phase 3, contracts stage,
  2026-09-29).** [plans/m7-design.md](plans/m7-design.md) "Phase 3"
  (P3.1–P3.15) is authoritative for star ratings (D125), the daily share
  card (E3) and the opt-in reminder (E4), and its frozen files compile,
  are documented and have minimal tests (`test/contracts/m7_phase3_test.dart`,
  core's `star_rating_test` and `level_bundle_par_test`). Lanes:
  stars-core, stars-app, stars-ui, reminder and share in parallel on
  exclusive paths (P3.13), then the integrator; codegen only through the
  lock. Phase 2's shapes are unchanged: a race records nothing through
  `recordLevelWin`, its `_win` branch returns before the star code, and
  `isBundled` excludes it, so races have no stars. The architecture
  proposal and the ui-spec were adopted with the lead's notes and the
  departures P3.14 lists.
- **D145. The star rule's API (m7 P3.3, P3.5).** `StarRating` in
  nesty_core (rule 2): `threshold(par, slackPct)` = `par + (par × slackPct
  + 99) ~/ 100`, `starsFor` (3 at moves ≤ t3, else 2 at ≤ t2, else 1; at
  most `assistedMaxStars` 2 when assisted; applied literally, so a star2
  slack below star3 only makes 2★ unreachable) and `starsForWin`, which
  reads the move count and the extra slots from the board so no caller can
  forget the extra-slot cap. `maxSlackPct` 1000 is a technical bound that
  keeps the arithmetic exact everywhere. Remote Config gains
  `star3_slack_pct` 20 and `star2_slack_pct` 60 (31 keys), clamped into
  0..1000 by `StarRules.slackOf`.
- **D146. Par in the bundle (m7 P3.3).** `LevelBundleEntry.par` is
  written after `rewardCoins` only when present, so a par-less bundle
  encodes as before, and read leniently: a bad par is one warning
  (`schema.wrongType` or `schema.valueOutOfRange`) and no par, and the
  entry is kept, so a bad par never makes a level unplayable. `bundle
  build` writes the solver's optimum at the admin budget
  (`build.parUnproven` otherwise), `bundle check` recomputes it from the
  rule-8 solve it already runs (`bundle.parMismatch`), and `report --stars`
  prints the bots' star shares (never a gate). No level's data or version
  moves.
- **D147. Stars in schema 2, with no schema 3 (m7 P3.4; defaults — Q117,
  Q119, Q120).** Schema 2 hasn't shipped, so `levelStars` (level id →
  best, never lowered), `starTipShown`, `daily.lastSolve` (`DailySolve`:
  date, moves, families, the minute) and `inProgress.hinted` join it with
  lenient reads; the 1 → 2 step writes nothing new. `recordLevelWin`
  keeps the highest stars per id in its one update, sets the one-time tip
  on the first win below 3★, and keeps `lastSolve` on a daily's first
  solve of its date (only the win path writes it). The splash calls the
  silent, idempotent `backfillLevelStars` once the save and the bundle
  are loaded: a level won before stars gets what its best moves earn (1★
  without a best), and nothing is ever lowered. Stars change no coins,
  chest, progress, record or badge.
- **D148. The assisted flag and the win's stars (m7 P3.6; default —
  Q116, Q118).** A win is assisted after a charged hint shown since the
  last Restart (a dead-end hint that costs nothing doesn't count), kept
  across a kill in `inProgress.hinted`, or with an extra slot on the board
  (read by core). The bloc's state carries `stars`, `previousStars`,
  `starTarget` (t3, only on a replay below 3★ whose moves were over it)
  and `starTip`; `starsNewBest` is a replay that raised them. Undo,
  Restart and relaxed mode reach the rule only through the move count.
- **D149. `StarRow` and the win card's stars (m7 P3.7; default — Q146).**
  One widget, `core/ui/widgets/stars/star_row.dart`, is every star
  surface's swap point for design request K, with the architecture's API
  and sizes (44, 20, 11). The stand-in is a painted rounded star (the
  icon subset has no outlined star): coin gold with a darker edge, and an
  empty star in the ui-spec's warm `surfaceTrack` with a soft
  `surfaceEdge` outline, never grey or red. On the win card the stars sit
  directly above the chapter card, and "New best!", the target and the tip
  go in the card under the moves line. The reveal starts at 1,300 ms, when
  the coin count-up ends (`win` is loud for its first 600 ms and `coins`
  from 700 to 1,100 ms; the ui-spec's 300 ms and the proposal's 1,000 ms
  each fell on one), 120 ms apart, with the clack at rising pitches
  (sizes 3, 2, 1) and a selection haptic each, then one `fx_twinkle` and
  the success haptic at 3★. Under reduce motion every star shows at once
  with no pop or twinkle, and the cues still fire at half the stagger
  (the owner's D48; the ui-spec's lead note 7 over the proposal's single
  cue). Stars-ui owns the whole win overlay.
- **D150. The star totals and Records' icons (m7 P3.5, P3.7; default —
  Q147).** A total counts only bundled levels with a par: 3 × the
  chapter's (60) in Chapters, 3 × the bundle's (600) in Records
  (`RecordsSummary.of(…, starLevels:)`, `StarRules.levelsWithPar`).
  Records' "Stars" and "Levels with 3 stars" rows use `NestyIcons.star`,
  so the best-moves link moves to `NestyIcons.extension`.
- **D151. The share card (m7 P3.8, P3.9; default — Q144).** A Share
  button on the Daily screen's solved card (frame 5.5), not on the daily
  win card (5.4): spec-prop §10.2 #11 names the Daily screen. It shares
  plain text through `ShareService` (share_plus): the date, one 🪆 per
  family completed (at most 12), the families, the moves and the streak
  count. No board, colour or move list, so no colour-to-emoji map is
  needed (the ui-spec's lead note 3 is superseded). Its data comes from
  `daily.lastSolve` through `DailyStatus.solve`, so a day an older build
  solved shows no Share. The result shows nothing, it pays nothing and
  it logs no event. The store link lands in M8.
- **D152. The reminder's settings keys (m7 P3.10).** `reminderOn`
  (false), `reminderHour` (19), `reminderMinute` (0) and `reminderOffered`
  (false), flat in the settings box (spec-prop §13.3 nests them as
  `reminder`; the box is flat), never renamed or reused, with no schema
  step. `DatabaseService.reminder`, `setReminder` (one `putAll`) and
  `reminderChanges` (quiet on an unchanged write) in Hive and the fake,
  with the shared contract test.
- **D153. `NotificationService` and `DailyReminder` (m7 P3.10; defaults
  — Q137–Q143).** One repeating, inexact local reminder a day (id 1, no
  exact-alarm permission) at the chosen local time, re-synced at launch,
  on resume, on a settings change and on a language change; no badge;
  nothing shown while the app is open on iOS; Android's default
  importance. The permission is asked only after the player's Yes. The
  one-time offer under the Daily screen's solved card is marked offered at
  its first appearance, with the solve's hour as the time (Q81), which
  also becomes the Settings default. Denied from Settings, the toggle
  stays off with a toast; revoked later while on, the row keeps the
  "Notifications are off" line and the schedule stays. There is no
  button to the OS settings in phase 3. `LocalNotificationService` is
  frozen as a safe stub (never prompts, schedules nothing) because
  `bootstrap` starts `DailyReminder` in the real env, and the offer is
  frozen hidden, until the reminder lane builds them.
- **D154. Phase 3's packages and the Android build (m7 P3.1, P3.10).**
  `share_plus` 13.3.0, `flutter_local_notifications` 22.3.1, `timezone`
  0.11.1 and `flutter_timezone` 5.1.0 (reasons under "Package reasons").
  share_plus 13 needs AGP ≥ 8.12.1, so the Android Gradle plugin goes
  from 8.11.1 to 8.12.1 (Gradle 8.14 already meets its 8.13 minimum), and
  flutter_local_notifications needs core-library desugaring
  (`desugar_jdk_libs` 2.1.4). A dev debug APK and an iOS dev build built
  right after the bump, so share_plus stays and the native share-channel
  fallback isn't needed. The lock only gained entries; `pod install`
  added three pods. Its four existing plugin checksums changed too, with
  no version change: this `pod install` ran the gem-installed `pod` (Ruby
  3.3, json 2.7.1), which writes an empty podspec list over three lines
  where Homebrew's `pod` (Ruby 3.4, json 2.9.1) writes `[]` (README
  "Prerequisites", M7 review R5).
- **D155. Phase 3's E1 and copy (m7 P3.11, P3.12).** `respect_copy_test`
  checks the `reminder`, `settingReminder`, `dailyShare`, `stars`,
  `winStars`, `chaptersStars`, `recordsStars` and `recordsThreeStar` keys
  against the deny-list. It also checks the star keys against a
  star-shaming list ("fail", "try again", "poor", "not enough" and more)
  and that no reminder string names the streak. `reward_randomness_test`
  scans `core/ui/widgets/stars`. The 26 ARB keys name the copy.md item
  that replaces each (G.6, G.7, G.11, I.1). The integrator adds
  `stars_gate_nothing_test` and `reminder_opt_in_test`.
- **D156. The share lane's build (m7 P3.13).** `SharePlusShareService`
  maps `share_plus`'s `ShareResultStatus` to `ShareOutcome` and swallows
  every failure under `nesty.share` (rule 3); `FakeShareService` records
  what it was asked to share. `DailyCubit.share` is a pure delegate: no
  save field, coin or analytics event. The Share button sits in
  `PuzzleCard`'s `_SolvedFooter`, shown only when `DailyView` builds a
  non-null `onShare` from `shareDataOf(state.status)` (null unless
  `solvedToday` and `DailyStatus.solve` is known), and captures its own
  global rect for the iPad popover origin the same way the day-7 chest's
  coin flight already does (`GlobalKey` + `findRenderObject`). No glyph
  for Share exists in the bundled subset (design request I.10): the
  stand-in is `NestyIcons.download` (`TODO(design)`), the nearest
  outward-arrow shape already bundled and not otherwise used in this
  flow.
- **D157. The stars-core build (m7 P3.3, P3.13).** The contracts'
  `StarRating` and the bundle codec passed every new test unchanged, so
  core's `lib/` is untouched. The expected values come from outside the
  implementation: an independent Python reference
  (`test/rules/reference/starref.py`, its digests matched on the VM, node,
  Chrome and dart2wasm) and a breadth-first oracle, which agrees with the
  solver's par on every solvable fixture (`par_oracle_test`).
  `LevelAnalysis.par` is the tools' one source of par, so `bundle build`,
  `bundle check` and `report --stars` can't disagree; `bundle check`
  reports `bundle.parMismatch` beside `bundle.drift`, and `report --stars`
  runs `RivalBot`s and never gates. `bundle.json` was rebuilt with only its
  200 `par` lines added (par 2–35); L1–L30's data digest is pinned, and
  each tutorial's scripted moves are pinned on an optimal line, so Q148
  doesn't arise.
- **D158. The stars-app build (m7 P3.6).** The hint flag is saved as the
  charged hint arrives, because a hint changes no board: a kill right
  after one would otherwise lose the cap. `_restoreSession` returns the
  saved flag with the session, and Restart clears it. `FixtureLevels`
  carry the solver's pars (2, 3, 5), pinned by a test. The splash runs the
  backfill right after the save and the bundle load, and never after a
  failed load.
- **D159. The stars-ui build (m7 P3.7).** A chapter's and Records' total
  is `StarsTotal`, a sibling of `StarRow` in its file (one 20 dp star and
  the numbers), because the frozen API has only `StarRow` and
  `StarRow.reveal`. The 3★ flourish's glow is painted in the UI kit, which
  never imports `features/fx`, and its haptic goes through the overlay's
  cue path. Under reduce motion `onStar` still fires three times, 60 ms
  apart. The target line, "New best!" and the tip sit under the moves
  caption, in that order. Chapters' `ListView` builds with a 5,000 dp cache
  extent: every card now carries a total, which pushed the current chapter
  past the default cache on a small phone and silently broke D111's scroll
  to it (a regression test).
- **D160. The reminder lane's build (m7 P3.10; Q149).** `enable`'s denied
  branch still stores the chosen time and `offered`; only `on` differs
  from a grant, so a denial never loses the player's time. `SettingsCubit`
  applies `DailyReminder.status` right after its own calls, since a
  broadcast event can land a microtask after the awaited call returns.
  `didChangeAppLifecycle` is public and `@visibleForTesting`, as in
  `SaveLifecycleFlusher`. The offer and both Settings rows use
  `calendarToday` until I.10 names a bell and a clock; the time picker is
  Flutter's own. The manifest removes any merged exact-alarm permission
  (`tools:node="remove"`) as a guard; the plugin asks for neither.
- **D161. Phase 3's integration (m7 P3.12, P3.13).** The E1 tests: a scan
  of the reward, unlock and gate paths for the star names, plus a
  behavioural check that twenty 1★ wins and twenty 3★ wins leave the same
  save apart from the stars; and the reminder's opt-in rules on the fake
  services, with source checks that the one `requestPermission` call is
  `DailyReminder.enable` (reached from the offer's Yes and Settings'
  toggle) and that the real service schedules only `reminderId`. The
  playthrough's L1 replay line is `r0c2>r0c1 r0c1>r1c2 r1c2>r0c0 r1c1>r0c0`,
  checked with `Rules.tryMove` before it is played. The real notification
  service has no request counter, so the playthrough checks "No thanks"
  as offered, off and nothing pending; the fake-env tests pin the request
  count. The optional Android check (`nesty-test --android --only
  reminder`) builds the test APK, installs it, grants
  `POST_NOTIFICATIONS` with `pm grant` and drives it with
  `--use-application-binary`; `adb install -r` keeps the grant. It never
  runs by default, and iOS skips it. The phase-2 rival strip fix: once the
  race is over and the rival didn't finish, the strip's state line goes
  blank (`RivalStripData.over`) until design request C.9 says what it shows.

- **D162. The phase-3 device run (2026-09-29, device stage).** The star,
  share and offer steps and every device check pass from fresh installs on
  the iPhone 16 Pro simulator (iOS 18.3) and the API 35 emulator. Each took
  90 screenshots, and the daily's fingerprint is the same on iOS, Android
  and in core.

  The optional Android reminder check passed on its first run: on gives one
  pending reminder, off none, and the `pm grant` survives `flutter drive`'s
  `install -r`. The simulator's log shows no notification authorization
  request from the app.

  The screenshots found two UI bugs, each fixed with a regression test
  (`m3_ui_kit_test`, `win_overlay_test`; game suite +3061):
  - `NestyToast`'s overlay entry sits outside every Material, so its text
    took MaterialApp's fallback style, a yellow double underline. It now
    carries the body `DefaultTextStyle`.
  - The replay card's reason line sat on the scrim and couldn't be read. It
    now sits on the coin pill's cream surface.

- **D163. A clock that went back grants no freeze (M7 review R2; Q153).**
  When today is before `daily.lastDate`, `StreakDailyService._reconcile`
  returns the progress unchanged: nothing is reconciled and no freeze is
  granted. Before, the missed-day loop was skipped but `grant(d, T)` still
  ran, and it compares only `freezeWeek == T`'s ISO week. A clock rolled
  back to an older week granted that week's freeze and moved `freezeWeek`
  backwards, so the real week granted again: one extra freeze per round
  trip, past m3 §8.2's once-per-ISO-week cap. The guard is in `_reconcile`,
  not only in `_solve` as the finding proposed, because Home and Daily
  call `refresh()` on open, which grants before any solve. An honest
  clock never sees the change: while `lastDate` is in the future no
  missed day can be covered, and the equality grant resumes once today
  passes `lastDate`. The grant isn't made monotonic (`week > freezeWeek`),
  because after a clock wrongly set far into the future is corrected,
  that would stop every weekly grant until that week. m7-design §8's
  `reconcile` pseudocode gains the line. A paused streak has no
  `lastDate`, so the same rollback still grants there (Q153).
- **D164. The review pass and the accessibility audit (M7 review,
  2026-09-29).** The review ran as five read-only lenses whose findings
  were merged, routed by path to three fixers on disjoint paths, and each
  confirmed before a fix. A fix needed a test that fails without it,
  unless it changed only a comment or a doc. The ui lens's accessibility
  audit covers the M7 surfaces, and R1 fixed its one failure. BACKLOG M7's
  "Accessibility audit" item stays open, with what is left written under
  it: the pre-M7 screens, the text-scale checks the audit didn't run on
  their own, and a VoiceOver and TalkBack pass on a device. The iOS
  `Podfile.lock` is left as it is (R5): running `pod install` again
  through the other `pod` would only flip the four checksums back until
  the next install with the first.
- **D165. The review pass, round 2, and the audit's close (M7 review,
  2026-09-29).** Round 2 ran four read-only lenses, deeper than round 1:
  the save, the race and the bloc's lifecycle, the reminder and platform,
  and the rest of the accessibility audit. Each built concrete sequences
  meant to break the code and reported only confirmed failures. The same
  three fixers confirmed, fixed or deferred each finding. The gate applied
  their cross-path edits and ran every gate. Two things change how later
  work is checked:
  - the overflow suite's `expectAccessibleLayout` (R36) fails a target
    under 48 dp, an unlabelled tap target and cut text on every screen it
    lays out, so the audit's measurements are now a CI gate;
  - BACKLOG M7's "Accessibility audit" item is ticked, because rounds 1
    and 2 together cover every screen and all their fixes are in but one.

  The exception is R12, screen-reader play on the Flame board. It is not
  in spec §16 or spec-prop §16, and it needs a board input path and about
  20 strings from Claude Design, so it is left to the owner (Q154) with its
  own BACKLOG item. What a host test can't prove, what VoiceOver and
  TalkBack actually say, is a new item for the close's device stage.
- **D166. The reminder's platform fixes (M7 review R9, R10, R30, R34;
  m7 P3.10).** P3.10's text stands; these make it hold on real devices:
  - **The zone fallback.** When `latest_10y` doesn't know the device's
    zone id, the fixed-offset location is named after that id, which the
    platform that reported it can resolve with its own DST rules. With no
    id, it is named `GMT±HH:MM`. `Nesty/Fixed+HHMM` was refused by
    Android's `ZoneId.of`, so the reminder was never scheduled in 132
    common zones (R9). Whether to load `latest_all` instead is Q155.
  - **The skip memo.** `scheduleDaily`'s skip memo keys the zone on its
    name and its current offset (`reminderZoneKey`), so a DST change still
    reschedules a fallback that keeps its name.
  - **iOS sound.** The iOS details carry `sound: ''`, so the OS plays its
    default sound in the background. FLN attaches none when `presentSound`
    is false and no sound is set. Nothing shows or sounds in the foreground,
    as before (R10).
  - **The spring-forward gap.** `nextDailyOccurrence` returns the first
    day, from today, on which the chosen wall-clock time exists. A gap day
    is skipped instead of firing an hour late; the fall-back overlap keeps
    its first occurrence (R34).
  - **The Hive fallback.** The in-memory store is marked
    `SessionOnlyDatabase`. Over it, `refresh` never cancels the OS
    schedule, because its "off" is only a default. `disable` still
    cancels, because that off is the player's own. The one-time offer
    stays hidden, because "offered" can't be kept (R30; spec-prop §7.9
    "offered once").
- **D167. E14's System follows iOS's Reduce Motion too (M7 review R7;
  spec-prop §16).** On iOS, Flutter reports Reduce Motion only as
  `AccessibilityFeatures.reduceMotion`, which `MediaQueryData` has no field
  for. So System, the default, never reduced motion on an iPhone.
  - `ReduceMotionOverride` (`core/ui/theme/`) resolves System from
    Android's `disableAnimations` or iOS's `reduceMotion`, read from the
    view. It rebuilds on `didChangeAccessibilityFeatures`. On and Off are
    unchanged, and m7-design §14 says so.
  - One limit is deferred. Under Android's Remove animations, the in-app
    Off can't restore full motion, because `AnimationController` runs at
    5 % whenever the platform flag is set. It errs toward less motion, so
    the fix (`AnimationBehavior.preserve` on the app's controllers) waits,
    with a `TODO(v1.1)` and a BACKLOG item.
- **D168. The device run after the review (2026-09-29, phase 5's device
  stage).** Every device check passes from fresh installs on the iPhone 16
  Pro simulator (iOS 18.3) and the API 35 emulator, before and after the
  run's one fix. Each run took 90 screenshots, resume phase A equals phase
  B, and the daily's fingerprint is the same on iOS, Android and in core.
  Round 2's semantics changes broke none of the integration tests' finders:
  R11's modal overlays, R13's single labels and the 48 dp targets.

  `nesty-test --android --only reminder` passes. It passes again with the
  emulator's zone set to Europe/Amsterdam, which `latest_10y` lacks: the log
  shows the fallback, and on still gives one pending reminder, so R9's
  fallback name reaches Android's scheduler.

  Each screenshot was paired by name with its phase-3 twin. Most show only
  the expected changes:
  - the back, close and gear faces move 1 dp inside their 48 dp targets;
  - the rival cards are a few dp taller around Race;
  - Settings rows are 1 dp taller, and the Language sheet's rows 2 dp, so
    the sheet rises about 18 dp;
  - Daily's Share target takes 1 dp from "Play Level N".

  One regression, fixed with three tests in `win_overlay_test` (two failed
  before; game suite +3139):
  - Since R23 the win card's button no longer scales with the block above
    it. So where the block scales down, the button stood wider than the
    card: about 10 dp on each side on the 16:9 emulator (411 × 731), and
    51 dp at 360 × 640 at 1.3×. Frame 2.8 draws the card and Continue at
    one width.
  - `_BlockOverButton` now lays the button out at the scaled card's width
    and its own full height, so R23's 48 dp target stays. Where the block
    fits, as on the iPhone, nothing moves.

  Not covered by this run:
  - the VoiceOver and TalkBack pass (the simulator has no VoiceOver;
    TalkBack is installed on the emulator);
  - iOS Reduce Motion (R7);
  - R8's Rematch under Pause by hand;
  - the race-loss segment.

- **D169. `nesty-test` covers every feature (owner, 2026-09-29).** The owner
  asked whether `nesty-test` covers every feature's tests, and asked for a
  rule that it covers each new one.

  The host checks already ran every test suite. They now also run CI's other
  checks except codegen drift, which would rewrite the generated files. That
  adds about 4 minutes:
  - `dart format`;
  - nesty_core's web parity on node, chrome and dart2wasm, recorded as SKIP
    without the tool;
  - the design, asset, FX and TODO-index drift checks;
  - the level bundle and the solver fixtures;
  - the admin's web build.

  The device checks cover most features' flows. `docs/TEST_COVERAGE.md` now
  lists each feature's host tests, its device step and screenshots, and what
  a device run can't drive yet.

  The rule, in CLAUDE.md "Testing": a new or changed feature ships with its
  host tests, a device step in `nesty-test` and its row in
  TEST_COVERAGE.md. `tools/test/test_coverage_test.dart` checks the rows,
  and checks that `nesty-test` runs every integration test. The `/feature`,
  `/milestone` and `/review` skills apply the rule.

  The owner's first run with the new checks failed in the playthrough.
  `flutter drive` hit "No space left on device": the data volume was 97 %
  full. So `nesty-test` now checks the free space at the start and before
  the device steps, and stops below 8 GB (`NESTY_TEST_MIN_FREE_GB`). A step
  whose log shows a full disk now says so. Separately, an edit made to the
  script while a run was reading it broke that run with a bash syntax
  error; the file itself parses.

  The open device gaps are in BACKLOG M7:
  - undo on a campaign board, and the soft-stuck banner;
  - relaxed mode's free undo, and the Color symbols, Sound and Haptics
    toggles;
  - using or buying a theme, and the 10th bonus level's chest;
  - the day-7 chest, and a paused or relit streak;
  - in a race: a loss, Pause and Quit, Rematch, New race, and Out of Moves.

- **D170. No "Replay" tag on a replay's board (owner, 2026-09-29).** The
  owner reported that the "Replay" button didn't work. It was the tag on the
  level pill (`hudReplayChip`, m7-design §11), which was only a label that a
  replay pays no coins. It was drawn on the raised surface the real buttons
  use, so it looked tappable. The owner chose "remove the tag if it does
  nothing". The tag, its ARB key and its `TODO(design)` note are gone, and
  `arb_keys_m7_test` keeps the key out. The win card still says "A replay
  for fun: coins come from new levels.", which is what spec-prop §7.1 needs:
  a replay pays no coins, and no marker during play is required. Regression
  tests: `gameplay_view_test` (a replay shows no tag) and the playthrough's
  replay step.
- **D171. Claude Design's M7 delivery is in `design/` (owner, 2026-09-30).**
  Claude Design delivered the round in three cumulative parts:
  `nesty-design-m7-1` (A, B, G), then `nesty-design-m7-3`, which holds every
  part. The check against the request's "Delivery" format passed:
  - every item in A–K is there. The two optional ones not delivered say why:
    C.6's rival reaction Lottie and A.5's per-theme shelf art;
  - the App Flow has 132 frames, with the new sections 09–12;
  - every new SVG passes the §12.2 subset, the 36 in `ui/` included;
  - the 8 new sounds pass the format and `tokens.json` `sound` checks;
  - `tokens.json` v3 only adds values (722 new, none changed or removed);
  - all 23 glyphs in its `icons` map exist in the pinned Material Symbols
    font (17 are new to `nesty_symbols.txt`);
  - nothing is removed or renamed.

  `design/` is the owner's. At the owner's request ("please do it"), Claude
  copied m7-3 in once with `rsync -rc`, which adds and overwrites and deletes
  nothing: 44 new entries and 15 changed files. Afterwards `diff -rq` against
  the export is empty. This was a one-off, and the rule stands: Claude never
  creates or edits anything in `design/` on its own.

  Small gaps, none blocking:
  - `shopOwned` ("Owned") still has no copy;
  - copy.md's `oom_undo_spent` writes the 2 free undos into the text, so the
    ARB takes the count as a placeholder (`free_undos_per_level` is a Remote
    Config key);
  - DELIVERY.md leaves out one reworded line in the Motion & Sound
    prototype.

  The integration is phase 4 (m7-design "Phase 4").
- **D172. The +1 Slot stays on the bottom shelf (owner, 2026-09-30).** The
  delivery's B.6 moves the extra-slot pad to the lowest shelf with fewer
  than 4 slots, and makes the bottom shelf a row of 5 only when every shelf
  holds 4 (`tokens.json` `layout.extraSlot.placement`). That contradicts
  spec §3.6 ("the right end of the bottom shelf") and D22 ("always appended
  to the bottom shelf, which re-pitches"). The owner kept D22. The pad
  always joins the bottom shelf. Its re-pitch uses B.6's row-of-5 numbers
  (`layout.boardPresets.rowOfFive`, `motion.rowOfFive`), and a second pad
  extends them to a row of 6 through `BoardLayout`'s scaling, with a
  `TODO(design)`. The rest of the delivery's `extraSlot` values (the limit
  of 2, the pop-in) apply as drawn.
- **D173. Phase 4's tooling: tokens v3 codegen policy (C4a, 2026-09-30).**
  `gen_design_tokens` reads all 1,218 leaves of tokens.json v3 (722 new):
  1,021 emitted and 197 documented, each on purpose
  (`design_tokens_codegen_test` pins the documented set).
  - Numbers become constants. The shelf keys parse as `Nshelves` or
    `3shelvesTall` (`BoardTokens.plankTopsThreeShelvesTall`); the board
    sections get `GlassCaseTallTokens`, `BoardFitTokens`,
    `BoardPresetTokens` (with the design's own fit results), `TowerStackTokens`,
    `IcedTowerTokens`, `HintArcTokens`, `FallbackDollTokens` and
    `ChapterThemeTokens` (ten chapters, `ChapterPalette`, the Shop crop).
  - A generic emitter (`tools/lib/src/tokens/screen_tokens_codegen.dart`)
    makes one class per screen section (16 `layout.*`, plus `shop`,
    `chestModal`, `settings`, `textLink`), typing each leaf by its shape
    (tools/README "gen_design_tokens"). Prose is read by strict parsers or
    listed with its reason; an unknown string fails the build.
  - Rules the design repeats (`versus.*`, `chest.*`,
    `layout.extraSlot.limitPerLevel`, `settings.reduceMotion.default`) are
    documentation only, and the game's `rule_tokens_test` pins each to its
    source (RemoteConfigKeys, MilestoneChest, LayoutLimits,
    SettingsDefaults): rules never come from tokens. `layout.extraSlot.
    placement` is documented as contradicting spec §3.6 (D172).
  - Formulas the hand-written code follows (the fit's limits and rule, the
    tower stack, the iced tower's tag, the tall glass case's Lottie) are
    pinned word for word (`TokenReader.documentedExact`): a reworded formula
    fails until the code is re-read.
  - Values that repeat another source are cross-checked: a preset's planks
    against `layout.board.planksY`, the row of 5's stand against the
    board's × `standScale`, `hudClearY` against the family counter, the
    theme crops against `thumbBox`, the chapters' 20-level blocks and
    figurine order, and the star, chest, ice and extra-slot frames against
    their Lottie markers (the tools test).
  - `textLink.minTapHeight` (44) is documented, not emitted: text links keep
    a 48 dp hit box (phase 4 lead note 3). `color.starEmpty` is an art
    reference (`ui/stars/star_empty.svg`), documented.
- **D174. The Lottie contract for m7-3 (C4a, 2026-09-30).** Six rows in
  LOTTIE.md order: `fx_glass_unlock_tall` after `fx_glass_unlock` (anchor
  (100, 212), the `case_size` null in the new `scaleNulls`, emitted as
  `FxSpec.scaleNulls`), then `ui_stars` (segmented, placed by its canvas),
  `ui_chest` (segmented, anchor (100, 186)) and the three `ui_intro_*` loops
  (in place on the card's 302×230 box, one whole-file `loop` marker).
  `ui_extra_slot` now has its `rest` marker at frame 0. `LottieRole` gains
  `revealed`, `family`, `family2` (whose slots and null are `family_2_*`, so
  roles carry an explicit prefix) and `freed`; `lottieImageSlots` and the
  game's `FxImageSlot` gain 16 slots (the tall case at 279×456, the stars
  132 and the glow 220, the chests 390×325, the intro roles' parts).
  A lone rest marker or a whole-file `loop` doesn't make a file segmented.
  The game's `FxId` has 35 members; the tall case pools one clip per slot,
  like `fx_glass_unlock`.
- **D175. The intro loops author their own doll sizes (C4a, 2026-09-30).**
  The export animates `mover_size`, `family_size` and `family_2_size` in the
  three `ui_intro_*` files (the family shrinks into the counter), which
  LOTTIE.md's "Doll size" rule (the game overrides every `<role>_size`)
  would reject, and a scale delegate would freeze. The contract marks them
  `sizesAuthored`: the size nulls must still be exactly the roles, their
  scale may animate, and their `FxSpec` lists no roles, so the runtime
  installs no size delegate. The image slots still say which role (colour)
  each part is (`FxImageRequest.revealed`, `family`, `family2`, `freed`).
  Claude Design is asked to say so in LOTTIE.md (the follow-up request).
- **D176. The UI art and the notification icon ship from `design/ui/`
  (C4a, 2026-09-30).** `sync_design_assets` copies
  `design/ui/{badges,chest,rivals,sprites,stars}/*.svg` (35) into
  `apps/game/assets/ui/`, stripped and validated like the board art, and
  flutter_svg compiles every one (`bundled_svg_render_test`). A file in
  `design/ui/icons/` or an unknown folder is an issue. The notification
  icon is a platform output: `tools/lib/src/assets/android_vector.dart`
  converts `design/ui/notification/ic_notification.svg` into
  `res/drawable/ic_notification.xml` (the main source set, all flavors),
  replacing phase 3's traced stand-in; only white-filled paths convert, and
  `--check` compares the bytes. The themes ch07–ch10, the tall glass case
  and the 8 new sounds go through the existing families; the pubspec lists
  the nine new folders.
- **D177. The icon font has 68 glyphs (C4a, 2026-09-30).** The 18 glyphs
  tokens.json `icons` adds (D171 counted 17) and the splash errors'
  `sd_card_alert` and `inventory_2` (phase 4 lead note 2; not yet in
  `icons`) are appended to `tools/fonts/nesty_symbols.txt`.
  `build_fonts.sh` ran with the pinned sources (the network was open) and
  `--verify` reproduces every byte; only the two NestySymbols lines of
  `SHA256SUMS` changed. The icon tests read design/README's v1 list and its
  "m7 adds" list, and every glyph tokens.json names is in the font.
- **D178. m7-3's `ui_extra_slot` curve (C4a note for lane B, 2026-09-30).**
  The synced file rests on the static pad's pose at frame 0 (100 % → 104 %
  at 24 → 96 % at 72 → 100 % at 96). Until lane B's §2.5 makes
  `FxTiming.extraSlotRestFrame` the `rest` marker (0), the game still starts
  the loop at D116's frame 24, now the 104 % peak, and
  `board_pieces_l9_test`'s three +1 Slot cases fail: that is expected, and
  it is B's to close (with E.16's stop under a doll).
- **D179. Phase 4's design: two contracts stages, five lanes (C4b,
  2026-09-30).** Claude Design's m7-3 delivery goes in as M7 phase 4 (m7-design
  "Phase 4", P4.1–P4.10). C4a did the tooling (tokens v3, the Lottie contract,
  the asset sync, the font; D173–D178). C4b froze the shared shapes (P4.1) and
  put copy.md in the ARB. Five lanes then run in parallel on exclusive paths:
  B (the board), R (vs Computer), M (the meta screens), D (the daily and
  Settings) and O (the overlays), with the integrator owning the cross-lane
  edits, the device files' wiring, the ethics tests and the docs. Lead note 1
  folds the architecture's T lane into C4a. Codegen goes through the lock
  script, and only C4a, C4b and the integrator run the nesty_tools
  generators. Why: every lane edits `gameplay_view.dart`'s neighbourhood and
  the ARB, so the shapes and the copy had to exist before any lane started,
  as in phases 2 and 3.
- **D180. The design's fit rule and presets replace the h·2/3 clamp (lane B,
  recorded 2026-09-30).** `layout.boardFit` and `layout.boardPresets`: the
  preset follows the shelves and maxSize (3 shelves with maxSize 6 take
  `threeShelvesTall`); one factor
  `k = min(1, min(V, HUD, H) / heightOf(maxSize))` per level; stands at
  `min(90, pitch − 2.4)`, pips unscaled; `dollMinGap` and the RENDER-3
  `pieceShrink` go (m7-design P4.3). `board_fit_test` pins every preset's
  limits and heights within 0.1 dp, and `bundle_layout_fit_test` checks all
  200 levels. Why: the design owns doll sizes, and its rule is exact where
  the clamp was a stand-in.
- **D181. D172 as built: rows of 5 and 6 on the bottom shelf (lane B).** The
  +1 Slot stays on the bottom shelf (the owner, D172). 4 → 5 slots is
  `rowOfFive` (pitch 74.4, stands at 0.8); 5 → 6 uses the same formulas (pitch
  62, stands at 0.662) with a `TODO(design)`, since the design draws no row of
  6. The re-pitch takes `motion.rowOfFive` (280 ms `easeInOut`), then the pad
  pops.
- **D182. The tall glass case and tall ice (lane B; C4b froze the shapes).** A
  sealed doll taller than `GlassCaseTallTokens.minDollHeight` (117.5 dp at
  pieceScale 1, sizes 5 and 6) gets the tall case (`BoardSprite.glassCaseTall*`,
  93×152) and `fx_glass_unlock_tall`, whose `case_size` null follows the doll
  through `FxDrawableParams.caseScale`. `SlotShape.lockedSize` carries the
  sealed size from core's slot view. The tall ice (`threeShelvesTall` only)
  plays `fx_ice` at (1, 1.05) with its doll compensated. The board sprite
  cache's key stride went from 16 to 32 (18 sprites), and its memory test
  counts the normal and tall glass sets apart: a case is one or the other.
- **D183. The tower stack and the iced tower's tag (lane B).**
  `layout.towerStack`: a step of up to 18, at least 9, else fewer drawn
  silhouettes, with the "+N" tag keeping the real count. `layout.icedTower`:
  the tag is hidden while iced and pops in with the shatter (frame 48).
- **D184. `ui_extra_slot` rests on frame 0 and stops under a doll (lane B;
  Q65, Q111 answered).** The loop starts at the `rest` marker (0), which undoes
  D116's frame 24; it fades to rest over 150 ms when a doll lands on the pad
  and restarts from frame 0 once the pad is empty (`motion.extraSlot`).
- **D185. Tap feedback, drag hover, hint arcs and the counter's yield (C4b
  froze, lane B plays; Q39 answered).** A tap on an unpickable slot with
  nothing lifted is `TapPolicy`'s `NudgeSlot`, its kind read from core's slot
  view (a sealed case first, since its padlock is on top, then ice, else an
  empty stand; an id the board doesn't have stays ignored). The bloc emits a
  `SlotNudgeEffect` and changes nothing else; the board plays the stand's
  2 dp dip with a light haptic, the padlock's 1.15× ping or the ice counter's
  1.2× bump, never the invalid shake. `GameplayState.dropTargets` holds
  `Rules.legalTargets` for a lifted nest, computed once on the pick in
  `_withEffect` and cleared once nothing is lifted, for E.14's 60 % glow; it
  never decides a move (rule 2). Hint arcs become `layout.hintArc`'s cubics.
  Over the middle top stand the hint keeps its rest pose, and
  `GameplayBoard.familyCounterYield` fades the counter (3.1b), replacing D62's
  drop for that case only.
- **D186. The UI art layer draws through `nesty_render`, with no SVG widget in
  the game (C4b).** `core/ui/art/`: `UiArt` names each of the 35 `ui/**` files
  with its viewBox; `UiArtLibrary` rasterizes an art once per (art, logical
  box, pixel ratio) with `nesty_render`'s `loadSvgPicture` and
  `Picture.toImageSync` (`AssetUiArtLibrary` real, `FakeUiArtLibrary` fake,
  a lazy singleton in both envs); `UiArtImage` draws the raster in its box
  (empty until it lands, labelled or excluded); `UiArtImageSource` fills
  `ui_stars`' and `ui_chest`'s slots (`FxImageSlot.art`). The architecture
  sketched `UiArtImage` as a `SvgPicture.asset` wrapper, but `flutter_svg`
  isn't a game dependency. Adding it would be a new package (rule 9), and it
  would parse per widget instead of once, so the rasters also serve dense
  grids without per-frame work (rule 8). `ChestIcon` now draws the chest art.
- **D187. One toast queue (C4b; Q122 and Q136 answered).** `ToastHost` holds a
  `ToastQueue`: one toast at a time, 2.5 s each, 300 ms apart
  (`motion.toast`), no touch, and a fade with no slide under reduce motion.
  The app root holds one at 58 below the safe top, where frames 5.2 and 8.3
  put toasts. A result card adds a scoped host (badge and race toasts at top
  60, above the ribbon), and its toasts leave with it. `NestyToast.show`
  queues on the nearest host; with none (a bare test page) it inserts its
  overlay entry as before. `BadgeToast.show` queues "Badge earned · {name}"
  with the badge's line and its 38 dp art. The four kinds' colours
  (success, info, badge, warning) are frame-only apart from warning, so they
  are named constants with a `TODO(design)`.
- **D188. Share moves to the daily win card, with G.6's text (Q144 and Q151
  answered; Q-P4-1 settled by lead note 10).** This supersedes D151's
  placement and text. Frame 10.1 puts Share above Back to Daily, and 5.5
  has none. The text is three lines: "Nesty Daily · {date}" (`MMMd`), one
  belly-symbol emoji per family in board order (at most 12, joined by
  spaces), then "Solved in N moves · Day D 🔥", or the no-streak line when
  the streak is 0 or paused. `DailyShareData` is
  `({date, families, moves, streakDay, streakLit})`. C4b removed the solved
  card's wiring and `shareDataOf` with it: only the win knows the families'
  colours. Lane O places the button and lane D owns the text. The glyph is
  `IconUses.shareFor` (`ios_share` on iOS, `share` elsewhere).
- **D189. "Open phone settings" through a platform channel (C4b froze, lane D
  builds; Q140 answered).** `SystemSettingsService.openNotificationSettings`,
  on `MethodChannel('com.futrix.nesty/system_settings')`, never throws and
  answers false when nothing opened. The native side is lane D's:
  `MainActivity.kt` (API 26+ the app's notification page, 24–25 its app
  details) and `AppDelegate.swift` (iOS 16+
  `openNotificationSettingsURLString`, else `openSettingsURLString`). No
  package: `app_settings` would be a dependency for about 20 lines (rule 9).
- **D190. A denied Yes keeps the reminder on and blocked; the three lines
  rotate (lane D; Q143 answered; Q-P4-4 and Q-P4-5 settled by lead note
  10).** This supersedes D160's `on: false` after a denied Yes. G.7's denied
  body promises "your note will arrive at {time}", so the reminder stays on
  and shows as blocked until the phone allows it. Settings' blocked row
  offers Open phone settings. The notification title is "Nesty". Its body
  cycles through G.7's three lines by `epochDay(nextFire) % 3` at each
  re-plan (launch, resume, a settings change). It is still one repeating
  trigger with id 1, so a player who never opens the app sees one line.
- **D191. Stars from `ui_stars`: one reduce-motion cue, the helper note, and
  the tip marked when shown (C4b froze, lane O builds; Q145 and Q146
  answered; Q-P4-6 settled by lead note 10).**
  - The reveal plays `star_1…star_n` from 1,300 ms, with `SoundEffect.starN`
    and a light haptic each, then the flourish at 3★.
  - Under reduce motion it shows the last frame at once, with one sound (the
    highest star) and one haptic. This departs from D48's half-stagger for
    this cue only: it is the design's own reduce-motion line.
  - `GameplayState.starsCapped` is set when the same rule, unassisted, would
    have given more. The card then shows "Wins with a hint or an extra slot
    earn up to 2 stars."
  - `LevelWinOutcome.showStarTip` now means: never shown, below 3 stars, and
    not capped. `recordLevelWin` no longer writes `starTipShown`. The card
    calls `SaveService.markStarTipShown()` (one idempotent update) once it
    shows the tip, so a card with no room (16:9, or the note) leaves the tip
    for the next.

  No schema field changes.
- **D192. The race per section 09 (lane R; Q131–Q135 answered; Q-P4-7
  settled by lead note 10).**
  - The strip sits in the HUD row (C4b's `GameplayHud.raceStrip`: x 76 to
    W − 16, top 62, 48 tall, in place of the level and coin pills; a taller
    strip scales down). `LevelPill.race` and `hudRaceChip` are gone, and the
    soft-stuck banner is back at 152.
  - 9.6 is a card, once per rival.
  - Leave race asks once (9.7b).
  - Settings is reachable from a race's Pause, with the race's hold kept (the
    integrator wires `onSettings`).
  - Rival select selects on tap, has one Start, a "New" chip and the beaten
    rival's check.
  - The results duck the music to `raceResult` (0.3) in
    `RaceResultLayer` and play `jingle_versus_win` or `jingle_versus_lose`.
  - Visible rival names carry no "Computer" in their text. The Computer tag
    beside every name carries spec-prop §1.1 rule 5, and the screen-reader
    strings still say "computer" (`arb_keys_m7_test`, R's widget tests).
- **D193. Home, Chapters, the Museum and Records per J and I.4–I.6 (lane M;
  Q92, Q113, Q115 and Q123 answered).** Chapters opens from Home's chapter
  card only. The Museum's Chapters link is gone (C4b removed it with
  `museumChaptersLink`). Frame 10.4's header crops the theme art
  (`ThemeThumbnailLoader`, lead note 4). The Museum's next line is
  "Chapter 4 · 14 levels to go", and a locked shelf's label is two lines at
  11 px.
- **D194. The first-launch fade through `GameplayEntrance` (C4b froze, lane O
  passes it).** `GameplayPage.entrance` (`push` by default, `fromSplash` from
  the splash) and the gameplay `CustomRoute`: `GameplayTransitions` fades in
  over 400 ms from the splash, and runs the platform transition on the first
  75 % otherwise, so a push still ends at 300 ms. It pops over 300 ms. The
  transition reads the entrance from the route's own `GameplayRouteArgs`.
- **D195. "Not enough coins" from the booster popup until M6 (lane O calls
  lane M's dialog).** There is no connectivity service, and "online" in frames
  3.2 and 3.8 means an ad can be offered, which is M6's `AdsService`. Until
  then an unaffordable coin button in `BoosterBuyPopup` stays enabled and
  opens `NotEnoughCoinsDialog`, with a `TODO(M6)` for the offline look.
  `connectivity_plus` is rejected (rule 9; connectivity isn't ad readiness).
- **D196. copy.md m7-3 in the ARB (C4b).** Keys keep their names and take
  copy.md's values, with curly quotes and `·` kept. Every description
  cites its copy.md id, or says "Not in copy.md m7-3" and why. None says
  "Placeholder" any more (`arb_keys_m7_test`).
  - Numbers the app owns became placeholders: `museumIntro(levels)`,
    `oomUndoSpent(count)`, `extraSlotLimitToast(count)`,
    `tutorialStepChip(step, total)`, `splashStorageBody(megabytes)`,
    `recordsFamiliesValue` and `recordsStarsValue`.
  - Rule constants stay in the text: "3 stars", "Seven days" and "After
    Level 2".
  - 53 keys are new and 10 retired (m7-design P4.8), and the retired ones
    are pinned gone.
  - Changed shapes: `raceRivalLocked(rival)` takes a name,
    `raceLossBody(rival)`, `reminderOfferDenied(time)`,
    `badgeEarnedToastTitle(badge)`, `museumNextLine(chapter, count)` and
    `dailyShareText(date, glyphs, moves, day)`.
  - A skin select keys `forest-bear` as `forest_bear`, since ICU select keys
    can't hold `-`. `CatalogL10n.skinNameOf` and `skinDescriptionOf` map it.
  - Every call site was updated, including the tutorial's "STEP n OF 3" on
    all three Level 1 steps (lead note 6).
  - `SheetRowTag` caps its width at 150 and scales its text down, since
    "Free, as often as you like" overflowed a 360 dp sheet at 1.3× text.
  - Frame-only lines keep their keys with a `TODO(design)`:
    `raceStripReady`, `racePauseHeader` and `gameplayGenerating`.
- **D197. copy.md's rival lines ship, with scoped exemptions (C4b; Q-P4-2
  settled by lead note 10).** Four of copy.md's lines use words the E1 lists
  deny, but about the computer and never the player:
  - "Slow" and "Quick" in `raceRivalSkill`;
  - "Quick" and "before" in `raceRivalBlurb` (the architecture missed rival
    2's "before it makes it");
  - "ends" and "lost" in `raceLeaveBody` ("nothing lost" reassures);
  - "before" in `raceWinBody`.

  `respect_copy_test` exempts each for its key and word only, with its
  reason. A test fails if a word leaves its key, and the same word in any
  other key still offends. The design owns copy, and none of these lines
  changes a rule.
- **D198. The catalog copy is final (Q73 answered; Q-P4-9 settled by lead
  note 10).** copy.md G.1–G.4 and H are the final English: the figurine
  names and flavours, the skin descriptions (Forest Bear's included) and
  the chapter 7–10 names.
- **D199. Ten theme palettes; `band` is the fallback colour (C4b).**
  `ChapterTheme` gains ch07–ch10, and each theme carries its tokens v3
  `theme.chapters.N`: `palette` (band, accentTop, accent, accentEdge,
  onAccent, soft, ink) and `thumb`. `fallbackColor` becomes `palette.band`,
  so ch01–ch06 also leave NestyBoard's BG map: tokens win over the
  prototype. `forChapter` cycles ten themes, the catalog's chapters 7–10 take
  their own theme, and ch07–ch10 sell at Q156's default. Theme ids are what
  the save stores, so this is additive, with no schema step.
- **D200. Forest Bear on sale at 2,500 (C4b; Q72 answered for Forest Bear).**
  copy.md H prices it, inside spec §7.3's 800–3,000
  (`BundledCatalogRepository.forestBearPrice`). The Shop's unsold path is
  still tested, on a catalog of its own.
- **D201. The lead notes' settled look (C4b records lead notes 3–9).**
  - Text links keep the tokens' look with a 48 dp hit box. The menus spec's
    44 is superseded (CLAUDE.md, the overflow harness).
  - The chapter ribbon stays the one-line `ui_chapter_ribbon`, tinted with
    the chapter's palette, with a `TODO(design)` asking whether frame 4.7's
    two-line plate replaces it.
  - The chest card sits at top 214 with `ui_chest`, and the SVG is the
    fallback.
  - Race results show two buttons as drawn, and system back returns to rival
    select.
  - "STEP n OF 3" is on all three Level 1 steps.
  - The font ships 20 glyphs, not 18: the splash errors' `sd_card_alert` and
    `inventory_2` as `IconUses.storageError` and `contentError`, with a
    `TODO(design)` asking for them in tokens.json `icons`.
- **D202. Phase 4's integration (the integrator, 2026-09-30).** Every
  lane's needs from others is in, and no frozen signature changed:
  - the view hands core's legal targets to the board with each effect
    (`_board.dropTargets = state.dropTargets`), so E.14's drag hover shows
    in the app (`gameplay_view_test`);
  - `RaceResultLayer` draws the plank's dolls in the level's own skin and
    the player's Color symbols, as the win card does (rule 3's placeholder
    until the skin lands; `gameplay_view_race_test`);
  - Settings is reachable from a race's Pause (Q132's answer, D192). The
    Pause stays under the pushed Settings, so its pause hold, set when
    Pause opens and lifted only by Resume, keeps the rival paused
    throughout (`gameplay_view_race_test`, `app_flow_test` (i));
  - three ARB keys phase 4's screens stopped reading are retired and
    pinned gone: `homeChaptersButton` (the chapter card has its own label),
    `museumCollection` (6.1's header chip) and `recordsThreeStarLevels`
    (10.6 draws no such cell; copy.md G.11 still lists it, asked in the
    Claude Design follow-up);
  - E1's `reminder_opt_in_test` follows D190 (a denied Yes stays on and
    blocked and is never asked twice), `m7_phase4_test` follows 9.7b's
    confirm, `di_test` resolves `UiArtLibrary` and `SystemSettingsService`
    in both envs, and `app_flow_test` gains (j) the chapter card → Chapters
    → level card → replay, (k) the blocked reminder's Open phone settings,
    and the daily win card's Share in (g);
  - the playthrough follows copy.md m7-3 and the new screens, and
    `nesty-test` drives the five new device files, each from a fresh
    install, with `--only` names `board`, `race` (scenarios `loss` and
    `oom`), `meta`, `daily_states` (`chest`, `paused`, `settings`) and
    `overlays`; docs/TEST_COVERAGE.md has their rows;
  - the design gaps are collected, paste-ready, in
    `claude-design-request-m7.md` "Follow-up after m7-3".
- **D203. E13 with the first-launch fade (lead note 11).** The fade adds
  up to 400 ms before level 1 is alone on screen. E13 still counts from
  `main()` to level 1's first playable frame, which the board reaches under
  the fade (it takes input once it is laid out); the "alone" time now
  includes the fade's end. `nesty-test` records both and holds neither to
  a threshold (Q114: the owner's device check notes the seconds), so the
  fade fails nothing. The playthrough checks the route's entrance is
  `GameplayEntrance.fromSplash`.
- **D204. Lane B's board choices (look only; no rule changes).**
  - E.15's dashed cubic arch from `layout.hintArc` (6 on, 6 off, 3 dp,
    `#F2893B`) replaces frame 3.1's dotted quadratic arc: tokens win, and
    frame 12.13 draws the same arch (Q-B1).
  - An iced tower's ice sits where the design's `iceTower` scene draws it
    (its bottom 16.5 under the plank's top). The ice composition hides its
    own doll on a tower stand, which is 5 dp taller, and the slot draws the
    doll under it (Q-B2).
  - E.13's padlock ping scales only the unlock symbol: the golden lock is
    part of the case art (Q-B3). `padlock_ping`'s null, the flash ring, is
    not driven.
  - Tower silhouettes keep D21's true sizes with the design's step. The
    stack's input is the tower's tallest nest at the start, so the spacing
    never moves as it empties; a stack squeezed to no step hides behind its
    top doll.
  - On rows of 5 and 6 the tall case is capped at the pitch − 2 dp, and
    `case_size` follows the cap (the architecture's fallback, found by
    `bundle_layout_fit_test`).
  - The drag hover reads only the bloc's `dropTargets`: no rule call in a
    component (rule 2).
- **D205. Lane R's race choices (look and flow; no rule changes).**
  - 9.7b's Keep racing resumes the race (the whole Pause closes), as the
    view's back gesture on Pause already does.
  - 9.6 comes before 9.4's chosen action (any button or system back), once
    per rival; its New race races the rival it unlocked, through
    `RaceCubit.chooseNextRival`, so the frozen `onNewRace` stays
    parameterless. Its Not now does what the player tapped.
  - 9.4 and 9.5 draw `VersusRibbon`: `ui_win_ribbon` has no tint hook.
  - The strip's 360 dp (glyph-only tag) and 340 dp (no state line) rules go
    by screen width, as the tokens name screen widths.
  - `RivalStrip` resolves the `AudioService` itself for `rival_complete`,
    since `GameplayServices` carries no audio.
  - At 1.3× text the strip, the rival cards and the result blocks scale
    down rather than scroll or cut; the reward chip's and the tag's text
    scale down rather than ellipsize. A pick on rival select lasts for the
    visit; 9.5 shows an empty plank when the player completed no family.
- **D206. Lane M's menus choices (look; no rule changes).**
  - Home between the 16:9 body (2.1b) and 844 dp (2.1) blends every number
    linearly, with no jump; the old hero squeeze stays below 2.1b.
  - Home's relit ring is derived, not stored: `HomeCubit` shows it when a
    live refresh sees the streak go from paused to lit, and clears it at
    the next refresh. No save field.
  - Home's star totals come from `ChapterStarTally`
    (`features/chapters/cubit/`), so `features/home` never names the star
    rule and stays in `stars_gate_nothing_test`'s scan.
  - A folded Chapters row hides its figurine below 380 dp or at 1.3× text,
    so the name and kicker wrap instead of being cut. A tap on any reached
    chapter's header toggles it, one open at a time, the current one open
    by default. The level card's Play replays the level.
  - `HomeTile.height` stays 132 and each screen passes `tileHeight`;
    `ChaptersCubit`'s `RemoteConfigService` is optional (the spec defaults);
    `TextLink` lives in `core/ui/widgets/home/` with a 48 dp box.
- **D207. Lane D's daily and Settings choices (look and flow; no rule
  changes).**
  - The reminder offer is a full-screen dialog at the Daily view, outside
    the SafeArea, shown while the daily is solved and no chest is pending;
    `offered` is written when it first builds, so a pending chest never
    uses it up.
  - The segmented Reduce motion track is 48 tall (frame 10.2e's 44), so
    every segment is a 48 dp target.
  - In the blocked state the toggle is drawn off and a tap opens the
    phone's settings (10.2f); see Q158.
  - The offer proposes the solve's hour (Q81); frame 10.2's "7:00 PM" is an
    example.
  - The relit twinkles belong to the daily win card, not the Daily screen,
    and the freeze notice stays 5.2's toast, with no sub line on the card.
- **D208. Lane O's overlay choices (look; no rule changes).**
  - The win card is laid out by the design's y values
    (`CelebrationLayout`: campaign, replay, plain). A screen under 760 dp
    tall gets `winStarsShort`, with neither the helper note nor the tip;
    the star count and the cap still apply.
  - The light haptic is `HapticPattern.pick` and the flourish's success is
    `complete`, the patterns the game has. The chest plays one medium
    haptic at 483 ms, as designed, and no success haptic.
  - The chapter ribbon is tinted by a colour matrix (`RibbonTint`), since
    `ui_chapter_ribbon` has no named fill.
  - The family counter hugs its text by scaling the file's 70 dp pill 0.9
    to 1.2.
  - The splash's error card is placed by its own delegate (top 470, lifted
    on short screens); 12.6's failed card keeps the board dimmed behind
    it.
  - The relaxed toast shows once per launch and the +1 Slot limit toast
    once per level, as the design proposed. Go to Shop from the booster
    popup leaves the level as Pause → Home does (it saves in progress).
  - Four frame-only strings became ARB keys, each description saying so:
    `oomUndoFreeChip`, `boosterLimitSemantics`, `restartSuggestedHint`,
    `hintGainedTag`. Lane R added `raceRivalBeaten` and `raceStartFor`, and
    lane M 18 screen-reader and label keys, all "Not in copy.md m7-3".

- **D209. Phase 4's device run passed on both platforms (2026-09-30).**
  Every `nesty-test` device check passes from fresh installs on the final
  code, on the iPhone 16 Pro simulator (iOS 18.3) and the API 35 emulator:
  - the playthrough (525 s on iOS with E13 at 3,958 ms; 598 s and 93
    screenshots on Android), resume A/B (the same board), the daily's
    fingerprint against core's;
  - the five phase-4 files: board layouts, the race loss and Out of Moves,
    the meta screens, the daily states (the day-7 chest, a paused then relit
    streak, Settings) and the overlays;
  - `--android --only reminder`: one pending reminder when on, none when off.

  The run needed nine iOS passes and two on Android. Two of the iOS passes
  were cut short when the simulator was shut down from outside the stage,
  and one by the owner's pause. The last iOS pass ran every step on the
  final code.

  Fixes:
  - Seven bugs in the new device tests. The screenshot data was replaced
    instead of merged. A finder missed the race board under Settings. Out
    of Moves in a race needed a race that has a dead end (race 6, found by
    a breadth-first search). There were timing, scroll and intro-card races
    in meta, daily_states and overlays. Settings' Language row was below
    the fold on a 731 dp screen.
  - Six app bugs, each with a regression test that fails without the fix:
    - the open chapter card's accent bar drew nothing;
    - chapter 10's kicker wrapped after the en dash;
    - Records' families cell put `records.families` over the Museum's 10
      (Q159);
    - the reminder offer, the level card and "A few more coins" had the
      no-Material yellow double underline;
    - the day-7 chest's scrim left the safe-area bands undimmed.

  Afterwards the analyzer is clean and the game suite passes (3,999 tests).
  Android's E13 of 18.3 s was the machine's load (load average 17), not
  the app. The generated notification icon renders as the doll silhouette.
  Eleven differences from the frames, none a rule, go to the fidelity audit
  (BACKLOG M7). The screenshots and the side-by-side comparisons are in the
  scratchpad (`screens-p4/`, `cmp-p4/`), and the report is
  `scratchpad/m7/reports/device-p4.md`.

- **D210. The splash draws the fallback doll from its first frame (2026-10-01).**
  The splash and the wordmark draw E.19's placeholder doll (red, like frame
  1.1) at once and cross-fade to the art when the skin lands (240 ms
  `easeOut`, a cut under reduce motion), instead of hiding the dolls until
  the skin loads. The first frame is then never empty, and the doll's
  colour is a Claude Design question (follow-up 10.6). This supersedes Q58.
- **D211. The App Flow scenes' CSS is the frames' values (2026-10-01).**
  Each frame is a `dc-import` of a component scene (`NestyHub`, `NestyMeta`,
  `NestyShop`, `NestyMenus`, `NestyBoard`), at 1 CSS px = 1 dp. The fidelity
  pass reads a value there where `tokens.json` has none and doesn't estimate
  it from a screenshot. `tokens.json` still wins where it has the value.
- **D212. Every menu page paints the CREAM gradient (2026-10-01).**
  `CreamPage` paints `canvasCream` to `canvasCreamLow` (180 degrees), as the
  scenes do; the Scaffold stays opaque, and the page's bottom safe-area band
  is painted too (the lists scroll under it, then end 24 dp above it).
- **D213. Header titles (2026-10-01).** Rival select, Chapters, Records and
  Settings start-align the title, 12 dp after the back or close button;
  Daily and the Shop centre it; the Museum's sits on the left with no
  button (`ScreenHeader.titleAlignment`). That is what each scene's CSS does.
- **D214. The tutorial's scrim covers the HUD and the booster bar
  (2026-10-01).** Frames 1.3, 1.4 and 10.8b dim them. Pause stays reachable
  through an `IgnorePointer` hole, so a player can still leave a tutorial.
- **D215. The chest card (2026-10-01).** The art gets the frame's 130 dp slot;
  `ui_chest`'s 200x200 canvas overflows upward and
  nothing is clipped. The card's top stays at `layout.chestCard.card.top`
  214. The chest's drawn size is Claude Design's question (follow-up 10.5).
- **D216. The short win card keeps the helper note hidden (2026-10-01).**
  `winStarsShort.notePill` says "not shown" on a short phone, so the game
  keeps it hidden and the audit's finding F6 (show it) is rejected. Where a
  capped win says why on a short phone is still a design gap (follow-up 4.12).
- **D217. The chest flights' ring and trail (2026-10-01).** The coin pill and
  the Hint badge get a ring in `relitGlow`, 3 dp wide and 6 dp clear, while
  the flights land; each flying sprite leaves three 6 dp dots at 85 % that
  fade in 200 ms. Both are off under reduce motion. The values are frame
  10.3d's estimate and stay `TODO(design)` (follow-up 1.7).
- **D218. Rival select's locked card and its fade (2026-10-01).** A locked
  card is the SUNK look with the scene's inset shadow, so it shows on the
  gradient page. The list ends in a 16 dp mask (a `ShaderMask`) only while it
  can scroll, with a 12 dp gap above the pinned hint. The audit's 24 dp
  painted fade is rejected: it shows a seam on the gradient.
- **D219. The type pass follows the CSS (2026-10-01).** Where `tokens.json`
  has no size, the menus and rival cards take the scenes' sizes, which are
  20 to 35 % smaller than phase 4's estimates from screenshots. This is a
  decision, not a question: the design is the source of truth for look, no
  owner decision chose the larger sizes, and the overflow suite at 1.3x text
  stays green. A type token per surface is follow-up 10.1 and 11.9.
- **D220. The coin count-up and the haptics (2026-10-01).** The count-up
  lasts `stars.startMs` minus the coins' start (1,300 - 700 = 600 ms, halved
  under reduce motion), where it was a guess. The
  haptic patterns already equal `tokens.haptics` (success 80 ms, soft error
  60 ms); their feel on a phone is the owner's. Both `TODO(M7)` markers are
  gone.
- **D221. The undo flies back (2026-10-01; Q160's default).** Undo reverses
  `motion.move`. No frame or token draws an undo, so it is a stand-in
  (`TODO(design): Q160`).
- **D222. Faults on a device go through a test-only seam (2026-10-01).**
  `bootstrap(beforeRunApp:)` runs after the DI, the save flusher and the
  reminder start and before `runApp`; `integration_test/support/` re-registers
  a decorated service through GetIt's `allowReassignment`. There is no fault
  flag in `lib/`, so no release build can be put into a fault by a define.
  The seam has no host test (no fitting style); `faults_test` exercises it.
- **D223. `nesty-test`'s device options (2026-10-01).** `--android-size
  WxH@dpi` (an `EXIT` trap restores only what the run set),
  `NESTY_TEST_IOS_DEVICE` and `NESTY_TEST_ANDROID_DEVICE`, and the `faults`
  and `semantics` steps. Fidelity shots are taken on the iPhone 16e (390x844)
  and on Android at 1170x2532@480, which is 390x844 dp.
- **D224. The TalkBack method (2026-10-01).** The semantics tour holds at each
  screen, the script moves TalkBack's focus by key, and logcat or the
  "Display speech output" overlay is the evidence. A fix gets a host
  semantics test that fails without it (`matchesSemantics` or
  `tester.getSemantics`) and the R11-R38 tests stay green.
- **D225. BACKLOG moves (2026-10-01).** Q29's markers move to M8, E9's `l1`
  and the skin-landing check have device steps, the owner-only items move to
  "Owner inputs needed", and the design-only items stay with the follow-up.
  Phase 5C does the rest of the moves, with a reason on each.
- **D226. `AppColors.sunkShadow` (2026-10-01).** It is `Color(0x265A2D0F)`
  (rgba(90, 45, 15, .15)). The plan's `#260F2D5A` had its RGB bytes reversed.
- **D227. The undo's order and its queue (2026-10-01).** The snapshot applies at
  frame 0 and then `doll_move` flies the doll from the reverted move's `to`
  to its `from`, hiding the source's top sprite until it lands, so the board
  is on core's state from the first frame (rule 10). It plays one `whoosh`
  for the file's 260 ms, 130 ms under reduce motion. A second undo during a
  flight cancels it and plays its own; a restart and a new level never fly.
- **D228. The Hint badge's ring and the relit card's twinkles (2026-10-01).**
  The badge's ring rides the existing 900 ms hint glow; one `RewardRing`
  (radius 999) serves the stadium pill and the round badge. The relit streak
  card's two twinkles are 22 and 14 dp at (+44, -6) and (+52, +4) from the
  disc: frame 10.7b gives the positions only, so the sizes are the build's
  choice (follow-up 11.3).
- **D229. Rival select's locked line (2026-10-01).** It uses `lockedName`
  (`#8A6A4E`), not the CSS `#8A5B3A`, which has no `AppColors` name (follow-up
  11.8). Settings' non-tiled rows are unchanged.
- **D230. Chapters' opening scroll (2026-10-01).** The page jumps once after its
  first layout so up to three folded rows stay above the current card, fewer
  when the viewport can't hold them: it needs 311 dp under them (92 header + 14
  + 60 family row + 14 + 2 x 62 + 7), so the family row stays visible too. The
  row keys sit outside the fade-in's transform, so its first-frame rise
  doesn't skew the jump.
- **D231. Smaller menu choices (2026-10-01).**
  - `StarsChip` derives its type from its height (28 tall: an 18 star and
    Fredoka 14; 30 tall: 20 and 15).
  - `FigurineModal` is a root-navigator dialog whose barrier is the scrim, and
    a tap on the barrier closes it.
  - Records' cells get the scene's white inset and a 4 dp edge.
  - The Shop grids' prices are plain, with no chip, as the CSS has them; the
    detail page keeps its chip. "Not enough coins" shows the number alone,
    and a screen reader still hears "coins".
  - The Museum's next card is `minHeight` 150 and grows at 1.3x text.
  - The Museum's Play is `compact` (38) in a 48 dp box, Chapters' "levels to
    go" stays under the bar, and the figurine spotlight is 200 tall: the
    scenes draw 36, inline and 300 (follow-up 11.4-11.6).
- **D232. Storage and content faults fail the level repository, not the save
  (2026-10-01).** Bootstrap has already handed the save to the flusher and the
  daily service before the seam runs, and the splash's card depends only on
  the `AppExceptionKind`. The generator faults answer null, the interface's
  failure value ("never throws").
- **D233. Frame 9.3c's restart is shot on rival 2's race 39 (2026-10-01).** At
  stage 20 it is the only race of rivals 1 to 3 and races 1 to 40 whose rival
  restarts before it finishes (at its 7th step). It runs at
  `NESTY_RACE_PACE_MS=1000`, and the test re-checks the rival with core's
  `RivalBot` on the device's own board before Start, so a generator change
  fails with a reason instead of a long wait.
- **D234. The semantics tour's rival rule (2026-10-01).** A label that names a
  rival as its subject must contain "Computer", or the next node must, where a
  separate tag is read right after the name.

- **D235. Claude Design's m7-4 is copied into `design/` (2026-10-01).** At
  the owner's "Copy and wire it", m7-4 went into `design/` byte for byte with
  the delivery, as a one-off like D171's m7-3 copy. `design/` stays
  owner-managed. It was wired by four lanes (tooling, copy, game, menus) and
  integrated by 5d-i (D241-D245).
- **D236. D172 stands: the +1 Slot always joins the bottom shelf
  (2026-10-01).** m7-4's `layout.extraSlot.placement` (a second slot on the
  next shelf up, a row of 6 only when every row holds 5) is not adopted. The
  owner chose "Keep D172" on 2026-10-01, so D22 and spec section 3.6 stay as
  built.

- **D237. Local habits, then the backend (2026-10-02).** The owner asked for
  the app to stay fully local and working smoothly, and for Firebase, the
  admin, purchases and the other backend work to sit at the very end. The
  order is: close M7 (the m7-4 device run, its fixes, translations, the
  review and the milestone gate), then the proposals in
  [plans/local-habits-brainstorm.md](plans/local-habits-brainstorm.md) once
  the owner picks which to build (Q162), then M4, M5, M6 and M8. The same
  note's "Wider concepts" records the later research pass: today's visitor
  and a spoiler-free picture share are optional and are not in the Q162
  default; the rest is already in the game, already deferred, or out under
  the respect rules. M8 stays
  last because its acceptance is a release build with production Firebase.
  Nothing in the proposal is a rule, and GAME_SPEC.md is unchanged. D235
  and D236 stay the m7-4 copy and the kept +1 Slot, already named in
  CLAUDE.md.

- **D238. Working within Claude's usage limits (2026-10-04).** On
  2026-10-04 the owner asked for a CLAUDE.md rule:
  - use Claude's tokens efficiently, with the right model for each task;
  - always save the work before a session limit runs out;
  - run parallel agents and split large tasks into manageable chunks;
  - none of this may lower the quality of the app or the code.

  The cause was phase 5's first fidelity audit. One Opus agent judged 124
  screenshot pairs in a single context: 1,468 turns, 842 images, about 557M
  cached input tokens. It hit the session and weekly limits three times and
  saved nothing, because its findings lived only in its context.

  The redo used four Sonnet judges of about 30 pairs each, each appending its
  rows to a file after every batch. They used about 230k tokens each.

  CLAUDE.md "Workflow" now carries the rule: the model per task, chunks with
  parallel agents on disjoint files, saving as you go, and small contexts.

- **D239. Be proactive (2026-10-04).** The owner asked for Claude Code to
  be more proactive and to do what can be done without being told.
  CLAUDE.md "Workflow" now says:
  - start whatever can run now, in parallel where files don't conflict;
  - prepare the next stage while the current one runs;
  - fix what turns up on the way, each fix with its test;
  - ship the default and record a question rather than block.

  The limits stay: an ambiguous game rule, outward-facing or hard-to-reverse
  actions (commits, pushes, deletes outside the repo and the scratchpad), and
  what the rules leave to the owner (GAME_SPEC.md, design/, CLAUDE.md's
  rules). The first case was the same day: the translation drafts started in
  a separate folder (build/m7-p5/l10n-drafts) while the 5f device run used
  the tree.

- **D240. Claude Code's documented efficiency practices (2026-10-04).** The
  owner asked for a web search of what else makes Claude Code efficient,
  and for those practices to be added to the files. The sources are the
  official docs on costs, prompt caching, memory, sub-agents, model
  configuration and best practices, at code.claude.com/docs/en/.

  Added:
  - CLAUDE.md "Working within Claude's usage limits":
    - big output stays out of context (tests with `-r failures-only`;
      verbose searches and logs in a subagent), but no subagent for a
      small edit;
    - effort is set per task;
    - the prompt cache is kept warm: no mid-task model, fast-mode or MCP
      switch, compacting only at a task break, `/clear` between unrelated
      tasks, and rewind-or-clear after two failed corrections.
  - A new "Compact instructions" section in CLAUDE.md, which `/compact`
    follows: what a summary must keep.
  - `effort: low` on the `test-runner` and `dart-formatter` agents. Every
    agent already named its model and narrowed its tools, and `test-runner`
    already used `-r failures-only`.

  Not added:
  - settings keys and environment variables the research could not verify,
    or that depend on a newer CLI than the `claude` on PATH (1.0.88);
  - a hook that rewrites test commands, because the agents' gates read the
    real exit codes.

  CLAUDE.md is over the docs' 200-line guidance. Its "Current state" is
  condensed to point at PROGRESS at the next docs pass.

  The same day's evidence also refined the model bullet. Sonnet translators
  are fine, but reviewing translations and player-facing copy goes to Opus.
  - The Sonnet reviewers R1–R3 made 2–6 fixes per language pair.
  - An Opus spot-check of 272 high-risk keys then fixed 102 more in the six
    Latin-script drafts: a rival given a gender, missing plurals, glossary
    drift, and Turkish "tamam" used for "complete".
  - The Opus reviewer of hi and ja made 30 fixes.

- **D241. m7-4's tooling stage (2026-10-02).** Tokens v4 are generated, with
  `oneShelf` and `font.scripts` documented only; the rule values stay pinned
  (`versus.*` except the ribbon colours, `chest.*`, `extraSlot.placement`).
  `sound.events.reminderSet` "none" is an empty `SoundCue`. Two new Lottie
  contracts, `ui_rival_react` (segmented) and `ui_museum_idle` (loop), with
  the fields `tintFills` and `sizedRects`, the validation `namedShapes` and
  placeholder PNGs named after a slot. `design/board/chNN/` syncs to
  `assets/board/chNN/` (the pip-baked stand and tower are skipped).
  `toast.app.top` (+4) is the one wired; `motion.toast.appTop` (-1) is
  emitted and unused. Rival select keeps the built 16 dp mask and 12 dp gap
  over `rivalSelect.shortScreen`'s 24 dp fade (lead note 10).
- **D242. m7-4's copy stage (2026-10-02).** `DailyService.unlockAfterLevel`
  is the one source of "After Level 2". `a11y_freezes` drops "left" (the
  respect deny-list, Q168). A won level with a best and no stars reads its
  best (`chaptersLevelSemanticsWonBestOnly`). The booster enum is
  `BoosterButtonKind`. The English ARB's sha256 `47724d15...` replaced 5A's
  `f8027ce5...`.
- **D243. m7-4's game lane (2026-10-02).** 5.3's tower step is in drawn units
  (x0.9661) and the deepest silhouette sits on `hudClearY` (10.42 against
  tokens' worked example 10.8, Q169). 5.4's clamp (safe top + 53 = 112)
  applies only over the counter. 5.1 and 5.2: the overlays scale with the
  stand (`qo`), and on four shelves with k. 6.3 needs no code (no digits in
  the loops). 6.5 and 10.9c: `SheetRowChip` moves under the sub below a 120 dp
  text column and never scales. 8.1: the Pause hole (10, 56, 60x60, r 22) and
  the tip in the HUD row. Chapters 7-10's wood comes through
  `SkinService.prepareForLevel(themeId:)`, the theme being
  `selectedTheme ?? play.themeId`. 9.6's primary reads "Race {rival}". The
  splash dolls stay red (DELIVERY Choices 10.6).
- **D244. m7-4's menus lane (2026-10-02).** The settings keys `lastRival`
  (4.5) and `relitGlowSeen` (4.10) go through `DatabaseService`: no save
  schema step, no new box. `ScreenHeader` aligns to the start (10.2).
  `AppColors` are token aliases plus `TODO(design)` frame-only colours (the
  lit streak card's peach, the spotlight panel, `cabinetDrop`, `rowDash`,
  `segmentedTrackShade`). The 7-day "A full week!" line stays.
- **D245. 5d-i's cross-lane choices (2026-10-02).**
  - Home's relit glow starts when Home is on screen (`TickerMode`): a muted
    ticker's clock still runs, so the 2.8 s glow was spent behind the Daily
    screen and `relitGlowSeen` written unseen (4.10).
  - 10.9c's device shot is English at 1.3x through the test binding (German
    is 5B's).
  - The 693 dp frames (9.3e, 9.3g, 11.2d-f) pair with the 731 dp run.
  - Four-shelf boards are host-only: no level uses four shelves.
  - `pairs.txt` covers seven new frames, not DELIVERY's four.
- **D246. 5d-dev's in-run fixes (2026-10-02).**
  - Shop purchase burst (an app bug the iPhone run found; the lead's fix):
    `PurchaseTwinkleBurst.showOver`, when called during a build (a card's
    `didUpdateWidget` swap), measures and inserts its overlay in a post-frame
    callback, else the Overlay was marked dirty mid-build and the grid threw.
    The test "purchase celebration (F.5)" in `shop_phase4_test.dart` failed
    before the fix.
  - `board_layouts_test`'s hint step branches on `hintNeedsCounter`: Android's
    shorter top inset never needs the hint's yield (a test fix).
  - 5d-tri: a non-race generated request that fails on open (Bonus, Daily)
    shows `NextLevelFailedCard` (gameplay title and body, Back to Home), not
    the splash's `RetryView` (an app bug; the 12.6 card now covers it, as
    9.3f covers races). The Museum modal's spotlight image is wrapped in
    `ExcludeSemantics`, so the figurine's name is read once (an app bug).
    D234 is read case-insensitively: copy.md writes "computer" in lower case
    in its a11y strings. Four test bugs (the versus ribbon's title is painted
    by `LottieTextOverlay`; the reminder offer's barrier hid Back, so
    `_seedPaused` seeds `offered: true`; the win card's note key also wraps
    the tip; a settle pause after the intro card).
- **D247. The streak card's two faces (2026-10-04, 5f-fa; settles the
  audit's reconciliation 1).** The Daily page's lit card is the orange
  `gradient.streak` face (App Flow 5.1 and 5.5: 64 dp disc, white 36 count),
  the paused card (5.2b) is the cream `surface` face, and the peach
  `streakCard*` face is only the relit look (10.7, 10.7b). The paused card
  carries a 22 dp "Paused" chip and the freeze chip inline, and the chip
  drops under the count above 1.15x text.
- **D248. Menu card sizes follow the frames' sums (2026-10-04, 5f-fa).**
  - A shop card's height is the frame's sum with its name line following the
    text scale, plus 1 dp so the footer's 48 dp hit area is not clipped
    (skins 173, themes 152).
  - The "Match each chapter" toggle lays out at 30 dp and its 48 dp hit area
    overhangs.
  - The Museum cabinet's niche is 72 dp with 9 dp padding (402 in all); the
    next chip reads `museumNextChip` ("5 to go").
  - A folded chapter's name is one line down to 0.85, two lines above 1.15x
    text.
  - Rival select's subtitle gap is 13 dp, Records' body starts 14 dp under
    the header, and Play's label is 28 above 9 characters, else 36.
- **D249. Toasts stay 10 s for a screen reader (2026-10-04, 5f-fa; TalkBack
  T1).** While `MediaQuery.accessibleNavigation` is on, a toast stays 10 s
  (4x the 2.5 s of `motion.toast.autoDismissMs`) and still leaves with its
  card, so a TalkBack or VoiceOver user can reach the live region (WCAG
  2.2.1). Sighted play is unchanged. Test "T1" in `toast_geometry_test.dart`.
- **D250. Rival select's reading follows copy.md A11y (2026-10-04, 5f-fa).**
  A card reads `raceRivalCardSemantics`, a locked card
  `raceRivalLockedSemantics` ("Locked computer rival. Beat Button to
  unlock."), and a pick adds `raceRivalSelectedSemantics`. Nothing joins its
  own label with ". " any more. `dailyFreezesSemantics` ends the streak
  card's one reading. The T2 finding (the badge toast over the win ribbon on
  a short screen) needed no change: at 390x844 the toast clears the ribbon
  (Q171).
- **D251. The wordmark's doll and the shared modal head (2026-10-04, 5f-fb).**
  - The wordmark's doll over the "e" was invisible because a childless
    `CustomPaint` collapsed to 0x0 in `AnimatedSwitcher`'s loose Stack; it
    now has a 30x45 box (frames 1.1, 10.8, 12.10).
  - `BalancedText` (CSS `text-wrap: balance`) sets modal heads through
    `ErrorCard.headStyle`, and `bindLastWord` binds an `ErrorCard` body's last
    two words with U+00A0 (`text-wrap: pretty`). Finders on those bodies must
    use `bindLastWord`.
- **D252. Out of moves: Undo is always the mint row (2026-10-04, 5f-fb;
  settles reconciliation 2).** The Undo tile is `SheetRowTone.success` in
  every state, and +1 Slot's outline marks the way out only while Undo is
  free (frames 3.5, 12.8, 10.9b). There is no owner question: it is a look.
- **D253. Versus pause rows follow frame 9.7 (2026-10-04, 5f-fb).** Fredoka
  600 17, 50 dp rows, a solid 1.5 dp #F0DFC4 divider (`divider`). The
  campaign pause keeps NestyOverlay's look. The portrait's shadow order is
  reversed (CSS lists the top shadow first), so the white inner ring shows.
- **D254. The reminder's time picker (2026-10-04, 5f-fb; reconciliation 6).**
  On iOS it is the Cupertino wheel in a #F2F2F7 bottom sheet titled
  `reminderPickerTitle` with Cancel and Done (frame 10.2b); elsewhere the
  Material dial. `showReminderTimePicker` serves the offer and Settings.
- **D255. The chest draws 121 dp, and the tutorial's tip tail (2026-10-04,
  5f-fb).** The chest shot's ~101 dp was the app's: a loaded `LottieFxView`
  is a `CustomPaint` of its own 200x200 canvas and the Stack gave it loose
  constraints, so it drew at 1.0 and off-centre. `SizedBox.expand` on both
  chest paths fixes it (`layout.chestCard.artFit`), with no Claude Design
  question. The other 18 `LottieFxView` uses sit under tight constraints
  (5f-fd audited them). The tutorial tip's tail is a 22x9 triangle that takes
  no layout height (frame 1.3).
- **D256. Plain-board moments live in `board_layouts_test` (2026-10-04,
  5f-fc).** `boardMoments` shoots `b_03_selection`, `b_04_nesting` and
  `b_05_family_complete`, so the tutorial shots in the playthrough keep their
  names. `invalidMove` waits on the `doll_invalid` clip for a bare slot
  (260 ms in, engine paused), because `Slot.shakeX` only runs for a locked,
  ice or tower target (5f-board-shake: a test bug).
- **D257. Retired keys and Home's Bonus chip (2026-10-04, 5f-fd).**
  `museumLockedShelfLabel`, `settingReminderOn` and `settingReminderOff` are
  retired (`arb_keys_m7_test`'s `retiredKeys`): frames 6.1, 10.2e and 10.2h
  never draw them. Home's Bonus Endless chip reads `chaptersStarsTotalAll`
  through `StarsChip(all: true)` (frame 12.2, copy.md G.11). Only the 11 short
  forms stay unread in `lib/`; they are 5B's.
- **D258. The Q154 marker (2026-10-04, 5f-fd).** The board's marker
  (`gameplay_board.dart:147`) is already `TODO(v1.1)`; no `TODO(M7)` about
  screen-reader play remains, so nothing needed re-tagging. BACKLOG v1.1 now
  carries Q154 as an item. The two `TODO(M7)` left in `language_sheet.dart`
  are 5B's.

- **D259. Engagement research, then the backlog (2026-10-04).** The owner
  asked for three things:
  - an analysis of the features built, in progress and planned;
  - an in-depth web search for features that bring players of every age back
    and make their progress feel impressive;
  - the result in the backlog.

  Three read-only lanes ran: the repo's features; what top puzzle and casual
  games do; and psychology, age groups, ethics and law. The lead checked the
  code facts and the primary pages.

  The result is [plans/engagement-research.md](plans/engagement-research.md),
  and its items are in BACKLOG "Engagement research and the kid path". It
  holds:
  - proposals ER1–ER11 in three waves. Wave 1 is Free Play by difficulty,
    milestones, a monthly recap, challenge codes and a healthy-play kit;
  - what not to copy, and why;
  - the kid path (D260).

  Nothing in ER1–ER11 is a rule. Nothing starts until M7 is closed, and Q173
  asks which to build.

  The order follows D237: M7, the local habits, these local proposals, then
  M4, M5, M6 and M8. ER11b waits for M4's and M8's accounts.

  Two findings:
  - A second freeze was dropped: Duolingo's data assumes a streak can break,
    and E2's never does.
  - The shipped "Next puzzle in …" line (frame 5.5) is information, not the
    countdown offer that respect rule 3 bans.
- **D260. Under-13s become a target: a mixed audience (2026-10-04).** During
  the research's planning, the owner was asked whether "kids to adults" kept
  spec §1's 13+ (D92) or made under-13s a real audience. The owner chose the
  latter.

  Nesty is now a mixed audience: adults 18–55 stay the core, and children are
  a real audience. Until the owner pastes engagement-research §6.4's text,
  this supersedes:
  - spec §1's "not designed for children";
  - §17's "don't market to children";
  - D92's "not made for or marketed to under-13s".

  The respect rules (spec-prop §1.1) and the six-question checklist apply to
  every age unchanged.

  Every player under 13, and every player of unknown age, gets the kid path
  (engagement-research §6):
  - a neutral age question: month and year, no default, never blocking. It is
    asked after the first win and kept only on the device, with store age
    signals where available (M6);
  - a parent area behind a parental gate, for the reminder, sharing, links
    out and purchases;
  - analytics by age (M4): nothing before the age answer, no ad ID, and
    analytics off on the kid path until the owner's legal check;
  - ads by age (M6): child-directed, rated G, from Families self-certified
    sources, never personalized, and no rewarded placements;
  - purchases behind the gate (M6);
  - a family-tone listing (M8): the under-13 bands on Play, and no "for kids"
    wording on the App Store.

  The details are Q174's defaults. The local part lands after the local
  habits and before M4.

  The rules were checked on 2026-10-04 against Google Play's Families policy,
  the FTC's COPPA FAQ, Apple's App Review Guidelines (1.3, 2.3.8, 5.1.4,
  2.5.18) and AdMob's child-directed treatment. The owner confirms the legal
  details (§17); that check is a BACKLOG owner input.
- **D261. Nine locales; the first launch follows the phone (2026-10-02,
  5b-locale).**
  - The locales are `app_es` (neutral Latin American), `app_pt` (Brazilian)
    with `app_pt_BR` (`@@locale` only), `app_id`, `app_hi`, `app_de`,
    `app_fr`, `app_tr` and `app_ja`. `l10n.yaml` sets
    `preferred-supported-locales: [en]`.
  - `LocaleSetting.system` ("system") is a new value of the existing `locale`
    settings key and its default. There is no schema step. It deviates from
    spec §13.3's example `"en"`: an install that never picked a language
    follows the phone, and a stored code, "en" included, stays pinned.
  - `AppLocaleResolver` is the one resolution, for the app and for the
    reminder: a pin with a catalog wins; otherwise the first phone language
    with a catalog, else English. Every `pt_*` goes to pt_BR, other regional
    variants to their language, and the legacy `in` is read as `id`.
  - The supported list comes from the ARBs present
    (`AppLocalizations.supportedLocales`), so a language turns on when its
    ARB lands. `LanguageState` keeps the stored setting and the rendered
    language apart, and the app follows the phone's locale changes live.
  - iOS `CFBundleLocalizations` lists the nine (pt as pt-BR). Android 13+'s
    per-app picker gets `res/xml/locales_config.xml` and
    `android:localeConfig` (5b-int).
  - The sheet has no "Phone's language" row, as frame 8.2 has none (Q176).
- **D262. Script fonts: one family per Latin role (2026-10-02, 5b-fonts).**
  - Baloo 2 (Devanagari) and M PLUS Rounded 1c (kana and kanji) are the faces
    `font.scripts` names, from google/fonts at the existing pin, subset, with
    their OFL texts registered. M PLUS's OFL text is composed from pinned
    inputs because google/fonts ships none for that folder.
  - Each script gets one family per role (`Baloo2Display`, `Baloo2Body`,
    `MPLUSRounded1cDisplay`, `MPLUSRounded1cBody`), because Flutter matches a
    style's `fontWeight` against each file's OS/2 weight class and ignores
    pubspec's `weight:`, while the tokens map weights per role (deva
    `body700 -> 600` but `display700 -> 700`; jpan `display700 -> 800` but
    `body700 -> 700`). Each file's weight class is the Latin weight it
    answers. This replaces l10n.md's single family per script, for about
    +0.66 MB.
  - The fallback lists are generated from the tokens:
    `displayFallback = [Nunito, Baloo2Display, MPLUSRounded1cDisplay]` and
    `bodyFallback = [Fredoka, Baloo2Body, MPLUSRounded1cBody]`. They are set
    on all 53 generated styles, the theme, the Lottie label and the four
    hand-built styles (a guard test).
  - The subset lists (`tools/fonts/subset/{hi,ja}.txt`) are generated by
    `gen_font_subsets` (`--check` in CI) and committed: Hindi's whole block,
    and Japanese's blocks plus the characters the Latin faces lack, from the
    ARBs, intl's ja and hi dates, the SDK's Material strings and the
    autonyms. A new kanji needs `gen_font_subsets`, `build_fonts.sh` and
    `--verify`; until then the system font draws it.
  - Coverage and the weight mapping are checked in pure Dart
    (`tools/lib/src/fonts/ttf_cmap.dart`), and in the app by ink.
  - A design gap: Fredoka at the pin lacks the Turkish ğ Ğ İ ş Ş (and ₹), so
    Turkish display text draws them from Nunito mid-word. It is in BACKLOG M7
    and the Claude Design follow-up §13, not a rule.
- **D263. Fitting and the language sheet (2026-10-02 to 2026-10-05, 5b-copy,
  5b-om, 5b-og, 5b-int).**
  - `FitText` is the one fitting widget (textFit's order: wrap, scale to the
    surface's `minScale`, the short form, then scale further). The 11 short
    forms are wired and every locale translates them. Ribbons use
    `RibbonLabel`.
  - `ShrinkToFitText` gained `overflowLines` and `fixedWidth`, and Japanese
    breaks between characters instead of shrinking the whole string.
  - Large text shrinks the Museum figurine to 48 dp so family names keep a
    column; the Shop's cards get +2 dp for tall scripts (a flat value, not
    tuned per locale).
  - The Computer tag drops to its glyph when the row would scale under 0.75
    (by available width, not only by screen width).
  - The HUD level pill is laid out in the free width between pause and the
    coin pill. It stays exactly centred when it fits the old symmetric room
    and otherwise sits against the narrower control (a few dp off-centre at
    360 dp with a five-digit balance and a long tier; no frame shows it,
    Q181).
  - The language sheet follows frames 8.2 and 8.2b: native name beside the
    English name, rows enabled by `AppLocaleResolver.app.supports`, a tap
    applies at once and the sheet stays open and redraws, Done closes it.
  - The readability floor (0.75) is a gate in the overflow suite (5b-int B2).
  - `locale_script.dart` and `LocaleScriptScope` apply the script's size
    factor and line heights (the tokens' per-script values) where text is
    tracked.
- **D264. No runtime case transforms; joins and clocks follow the locale
  (2026-10-02, 5b-copy; 5b-copycheck).**
  - The screen-reader joins are ARB keys (`a11yJoinList`, `a11yJoinSentences`,
    through `context.localizations.joinList` and `joinSentences`). A closing
    stop is added only on request and read from the language's own key. A part
    that already ends a sentence (. 。 । ! ? ！ ？) keeps its mark.
  - No `toUpperCase` or `toLowerCase` of user text (Turkish İ/ı); a source-scan
    test enforces it.
  - `context.formatClock` follows the phone's 24-hour switch and the locale.
- **D265. Translation conventions (2026-10-04, 5b-T1 to T4, R1 to R4, spot,
  full-a, full-b, int, copycheck).**
  - Registers per l10n.md §2.3: tú (es), você (pt), tu (fr), du (de), and the
    friendly forms of tr, id, hi and ja (ja's screen-reader badge hints use
    the mission form 〜しよう). Q178 keeps these.
  - "Computer" names the rival on every rival surface (Computadora, Computador,
    Computer, Komputer, Bilgisayar, कंप्यूटर, コンピューター), and rival lines
    are gender-neutral in es, pt, fr and hi.
  - Glossary changes from review: pt "Aparência" for a skin (not "visual");
    id keeps the loanword "streak"; tr tierSuperShort is "ÇOK ZOR"; the Daily's
    level pill and "Back to Daily" use the head noun (Desafío, Desafio, Défi),
    because "Diario", "Diário" and "Du jour" alone read as journal, diary and
    an adjective; hi says सुपर, नया रिकॉर्ड and (for slot or stand) जगह; ja
    uses マス and keeps "NEW" and "DAY"; fr On/Off is "Oui/Non"; fr and de
    use "gel" and "Schutz" for a streak freeze; de counts undos as
    "Rücknahme(n)".
  - Rival names are translated meanings (Q177).
  - Plurals: in fr, pt and hi `one` covers 0, so a `one` branch carries
    `{count}`; pt also gets an explicit `=0` branch on the 51 keys with a
    `one` branch ("0 moedas"); es `one` branches keep the number. Ranges keep
    "–".
  - The respect lists per locale live in `test/l10n/locales/<code>.dart` with
    matching per script (stems, German compounds, Turkish İ/ı folding,
    Indonesian clitics, Devanagari with the nukta stripped); the reviewers
    added loss words (tr söndür, yandın; id padam; hi, ja several).
  - From the freeze on, every English change ships with its eight
    translations in the same change.
- **D266. The tests' locale axis (2026-10-02 to 2026-10-05, 5b-tests,
  5b-int).**
  - `test/l10n/` checks parity, plural shape, the respect rules and
    "Computer" per locale, and font coverage by ink. `NESTY_L10N_ARB_DIR`
    points the checkers at a fixture directory, and `requireAllLaunchLocales`
    is on.
  - The overflow suite takes `NESTY_TEST_LOCALE`: the full matrix for en, de,
    hi and ja, 360x640 and 375x667 for the rest (`NESTY_OVERFLOW_MATRIX=full`
    gives all five). The loop includes `pt` besides `pt_BR`.
  - The device step is `nesty-test --only locales`: German through the real
    picker, Hindi and Japanese seeded (one per script family).
  - What a simulator can't drive is the phone-language default; its host
    tests are in TEST_COVERAGE's Translations row.
- **D267. Phase-5 follow-ups that landed with 5B (2026-10-04 to 2026-10-05).**
  - The figurine modal hangs from the top at safe top + 69 dp (frame 6.2:
    128 - 59), centring only when the screen is too short (5f-fix2). The skin
    detail's description binds its last word. Frame 2.6's ghosts and ticks are
    a static frame's notation that `doll_invalid` doesn't draw, so the step
    only asserts the clip is live. The splash error shots wait for the
    showcase art.
  - E13 is timed by a 4 ms in-app poller (the app's own time, independent of
    the screenshot loop; 5f-e13). The record also carries `levelsCheckMs` (the
    repository's CPU-only control, from its log line), `quietLevelsCheckMs`
    and `noisy`. The `00b_splash_loaded` shot moved to the faults scenario
    `splash_loaded` (the splash held after the art), which is why faults runs
    eight times.
  - 5f-startup found no app regression. E13 followed the CPU control
    (r = 0.90 over 14 launches): once corrected, 5f is no slower than 5a. The
    new fonts cost nothing measurable at startup (the A/B is inside the noise,
    about 100 ms with a standard error of 125 ms). The 5f runs were on a busy
    host (Spotlight indexing and the owner's simulator).
  - The admin stays English, and RTL is out of scope (none of the nine is
    RTL).

- **D268. A daily gift: the owner asks for a daily and weekly login reward
  (owner, 2026-10-05).**
  - Nothing in the game paid for opening the app. The Daily pays for solving
    its puzzle.
  - local-habits "Out" and engagement-research "Rejected" had left out
    "escalating login calendars". Those were proposals, not owner decisions,
    and this request overrides them for the form below.
  - One research pass: [plans/login-gift-research.md](plans/login-gift-research.md).
    The genre norm is a 7-day escalating calendar that restarts at Day 1 after
    a missed day (Homescapes). That restart breaks respect rule 6 (D92), and
    it is the case PEGI's 2026 criteria rate 12.
  - The cumulative form keeps Nesty at PEGI 7:
    - the track counts claims, not dates;
    - every reward is shown in advance;
    - there is no countdown.

    It is the plan's one approach.
  - The plan is [plans/plan-login-gift.md](plans/plan-login-gift.md), with
    the spec-prop text for a §7.5b to paste.
  - **Approved by the owner on 2026-10-05, with Q182's defaults:**
    - it starts after M7 closes, ahead of the local habits;
    - a Home button with a dot, and no popup;
    - the track 20 · 30 · 1 hint · 40 · 50 · 1 hint · 100 coins + 1 extra
      slot;
    - the same gift on the kid path.
  - Until the owner pastes it into GAME_SPEC.md (BACKLOG "Owner inputs"), the
    plan's §7.5b text, the §7.3 row and the `login_gift_track` key are the
    rule, the way Q85 holds for M7's spec proposals.
  - The work list is BACKLOG "Daily gift". The Claude Design request is
    [plans/claude-design-login-gift-prompt.md](plans/claude-design-login-gift-prompt.md)
    (App Flow section 13).
  - local-habits "Out" and engagement-research "Rejected" now note that the
    rejection covers the resetting form only.

- **D269. Local first, backend last, and data-driven for the admin (2026-10-05).**
  The owner asked to push every Firebase, purchase and backend task to the
  last step. The game must first work 100% locally. Later, the components'
  data moves to the backend, so the admin panel controls it dynamically.

  This confirms D237's order: M7, the daily gift (D268), the local habits
  (Q162), the local part of the engagement research and the kid path (D259,
  D260), then M4 (Firebase content), M5 (admin), M6 (ads and purchases) and
  M8 (release).

  Nothing that needs a server, an account, Firebase, ads, analytics delivery
  or a store purchase starts before M4. On 2026-10-05, ER11b (Game Center and
  Play Games: accounts and the network) moved from the engagement section to
  M8.

  Local work keeps its admin seam:
  - Anything the admin will control later is read today through a repository
    or a `RemoteConfigService` key with a bundled, hard-coded default
    (CLAUDE.md hard rule 6). This covers levels, chapters and themes, skins
    and their prices, the daily-gift track, rival and race parameters,
    rewards, and copy that may change.
  - A feature never hard-codes such a value in a widget or cubit.
  - So M4 and M5 swap the source for Firestore, Storage and Remote Config
    without touching the features.
  - Analytics calls go through `AnalyticsService`, which stays a fake until
    M4.

- **D270. Themes, characters and a story mode, as proposals (2026-10-05).**
  The owner asked for themes, animations and characters "like Marvel, Power
  Rangers, Barbie" that bring players back, and for a story mode, with
  research. The analysis is
  [plans/themes-characters-story.md](plans/themes-characters-story.md).

  - **No licensed characters.** Marvel, Power Rangers and Barbie are other
    companies' trademarks and copyrights, and a licence is unrealistic before
    M8 (TC-L, Later). The proposals are original characters in those genres:
    - a mascot (TC1);
    - a five-colour hero squad whose colours are the doll families (TC2);
    - fashion dolls with ER6 (TC3);
    - a story mode, "The Long Way Home", which absorbs ER9 (TC4);
    - folk-tale and world-doll chapters with a sensitivity review (TC5, TC6);
    - an idle and tap animation layer (TC7);
    - a friendlier Computer (TC8);
    - themed booster looks (TC9);
    - yearly costume days with ER8 (TC10).
  - **Limits.** All of it is cosmetic or narrative, local (D269), and within
    the respect rules (D92) and the kid path (D260). Nothing is random,
    limited-time, or sold by a character.
  - **Not rules.** Q184 picks what to build. A rule change waits for spec-prop
    text. Names and emblems get a legal check before they ship.
  - **Where it sits.** BACKLOG's new section is after the local habits,
    beside the engagement research's wave 2.
  - **Second pass (same day).** The owner sent the ask again. The doc was
    checked against the code and deepened:
    - **Corrections:**
      - The catalog is Dart constants, not JSON. TC-DATA adds accessors.
      - Each `FxId` has one Lottie. TC-FX adds variants.
      - The Large symbol disc (out to r 96) covers the apron, so the squad's
        emblem frames the symbol.
      - Chapters are fixed at ten. New lands wait for M4 or a Shop-only
        theme.
      - The figurine pairing belongs to design, so the story makes it its
        plot.
      - The respect lists rule out "lost" and "lonely", so the story is
        hide-and-seek.
    - **Character or skin.** Coins are sold for money. So a character (a
      persona) is earned and never sold, and a skin may be sold for coins.
    - **Story triggers, verified in code.** No save step:
      - The prologue plays after Level 2's first win. `tutorialDone` can't
        trigger it, because it flips during that level.
      - Homecomings key on `completedChapterId`.
      - Midpoint pages are Storybook-only, because the milestone chest owns
        level 10.
    - **Added:**
      - a trend radar with each locale's kid favourites;
      - the story mode in detail (§4);
      - an animation catalogue;
      - a region-aware seasonal calendar;
      - TC11 Pop Stage, TC12 Moonlight Dolls, TC13 Little Ones (levels 3,
        7, 13 and 17) and TC14 Nest House.

- **D271. The race strip keeps the word "Computer" at 360 dp and up
  (2026-10-05).** 5C's ethics lens found the strip dropping the tag to its
  glyph for a long name or a large text scale (es, pt, fr, id and ja at
  360 dp), past D192's rule (glyph only under 360 dp). In a race the strip is
  the only on-screen rival label (spec-prop §1.1 rule 5; mode-vs-computer
  rule 11).
  - **The strip makes room instead (`_StripRoom`):**
    - first the name scales, down to the 0.75 readability floor;
    - then the dots give way to the count alone (the count says the same);
    - then the tag moves to the second line, in the state line's place.
      The portrait's motion and the announcer still carry the state.
  - **Above 8 families** the count always stands alone. Frame 9.3 draws at
    most 8 dots, and the 6 dp dot row there was our own proposal.
  - **Home's vs Computer tile and the race Pause header** keep the glyph
    fallback (`ComputerTag.glyphOnlyForRow`). Their own label ("vs Computer",
    "vs Computer · {rival}") carries the word in every locale. The fix lane's
    first version kept the tag's word there too, by scaling or wrapping, and
    failed the overflow suite's floor in es, pt and ja.
  - **Tests.** `computer_word_test` covers 9 locales × 360 and 390 dp × 1.0×
    and 1.3×. The strip is checked for all three rivals with 8 families,
    exact word, readable and uncut. Home and Pause pass when their label
    contains the word.
  - **Design.** Claude Design is asked for the strip's count-only and
    two-line forms (BACKLOG M7 5C, `TODO(design)` in `rival_strip.dart`).

- **D272. The daily gift starts next, with M7's sign-offs open (owner,
  2026-10-05, Q185).** M7 is code complete and its gate passed; its
  acceptance waits on the owner's design sign-off (Q161), the VoiceOver pass
  and Claude Design's follow-up. As D90 did for M2 and M3, those don't block
  the next work: the daily gift (D268, BACKLOG "Daily gift") starts now,
  fully local (D269), and its art comes with Claude Design's Wednesday
  round (`plans/claude-design-login-gift-prompt.md`).
- **D273. The race-loss card keeps its designed hop (owner, 2026-10-05,
  Q183).** 9.5 plays `ui_rival_react`'s `win` segment, with its confetti, as
  m7-4 C.6 designed it. The ethics lens's P1 is closed by the owner's
  choice. The loss copy stays warm ("So close! Rematch?", a rematch costs
  nothing). TC8 (a polite bow) stays a proposal under Q184.

- **D274. All four local habits, in order (owner, 2026-10-05, Q162).**
  After the daily gift (D272), the local habits in
  [plans/local-habits-brainstorm.md](plans/local-habits-brainstorm.md) are
  built in this order:
  1. welcome back;
  2. a month of played days;
  3. the last 7 dailies playable;
  4. the home-screen widget, with its native iOS and Android work, last.
- **D275. Themes, characters and story: wave 1 first (owner, 2026-10-05,
  Q184).** After the local habits, TC7 (the living dolls' animation layer),
  TC8 (the Computer's personality) and TC1 (the Nest Keeper mascot) come
  first, then the story mode (TC4a and the Storybook). The mascot's and
  squad's names wait for a legal check. The other sub-questions keep their
  defaults (plans/themes-characters-story.md).

- **D276. The daily gift's rules and save (2026-10-05, stage 1;
  plan-login-gift §7.5b, D268).**
  - `LoginGiftRules` (`core/services/login_gift/`) is pure, beside
    `MilestoneChest`: the track, `dayOf(claims) = claims % 7 + 1`, one claim
    per local date, no claim on a date earlier than `latestSeen`, the wrap
    after Day 7, and locked until Level 2 is won
    (`StreakDailyService.unlockAtHighestLevel`).
  - "The latest date ever seen" is raised by a claim and by the gift's status
    read (`SaveService.noteLoginGiftDate`, only once the gift is unlocked), so
    a date seen without a claim also blocks an earlier one (Q188).
  - Remote Config `login_gift_track` is the first string key: a JSON array of
    7 objects with only `coins`, `hints` and `slots` (whole numbers of at
    least 0, at least one above 0 per day). Anything else falls back to the
    whole default track (rule 6). The literal lives in
    `remote_config_keys.dart`; `LoginGiftRules.defaultTrack` is its parsed
    form, and a test holds them together.
  - Save schema 3 adds `loginGift {claims, lastClaim, latestSeen}`
    (`migrations-engineer`). Step 2 → 3 only stamps the schema, so every
    player starts at Day 1, and a `loginGift` that a schema-2 app kept as an
    unknown key after a downgrade survives. On read, `latestSeen` is never
    earlier than `lastClaim`, and a corrupt `claims` reads 0 (that date still
    can't claim twice). The schema-2 test fixture was written by HEAD's codec
    from a scripted mid-game player.
  - `SaveService.claimLoginGift(today)` decides the grant inside its one
    update, so the pay and the claim count can't disagree, and adds the
    boosters even with the dev flavor's unlimited boosters (they are a stored
    count).
- **D277. The daily gift's state and UI (stage 2), on stand-ins until Claude
  Design's section 13.**
  - `LoginGiftCubit` (`features/login_gift/cubit/`): phases `locked`, `ready`,
    `claimed` and `waiting` (a clock wound back). `refresh()` reads and emits
    in one synchronous step, so a stale "ready" can't land after a claim;
    `claim()` is synchronous and never throws; the track is re-read on every
    refresh; it re-reads on save changes and on app resume.
  - Home's coin pill shows `min(balance, coinsCap)` while claimed coins fly,
    so it ticks up as they land and never dips. The cap is released on
    landing, on the sheet's close and on dispose, and in the button's early
    returns.
  - The button sits beside the gear, 6 dp apart, so the wordmark stays
    centred; both keep a 48 dp target at 360 dp and 1.3× text. Its dot is
    gold, with no number, never red, and it is hidden until the unlock. The
    stand-in glyph is the chest's `redeem` (Q186).
  - The sheet: Days 1–6 in a 3 × 2 grid and Day 7 wider with the chest art,
    then Claim or a calm line ("Tomorrow: {gift}", or "Next gift: {gift}"
    while waiting). On Days 1–6 the coins fly to the pill (up to six sprites)
    and a hint or slot day pops its tile. Day 7 pays at once, closes the sheet
    and opens `GiftChestModal` on `ChestRewardSequence`, which gains `slots`
    and `RewardChipKind.slot`; the milestone and Daily chests are unchanged.
    The chest's ribbon falls back to `giftTitle` where `giftChestTitle` won't
    fit (de, es, fr, pt at 360 dp).
  - Every stand-in value is in `widgets/gift_look.dart` under `TODO(design)`,
    so the section 13 swap is one place.
  - Analytics: `login_gift_claim {day, claims}` through the fake
    `AnalyticsService` (M4 sends it; the kid path keeps it off for under-13s,
    BACKLOG).
- **D278. The daily gift's strings.**
  - 20 keys in the nine catalogs, English stand-ins until copy.md "## Daily
    gift". Claim uses each language's chest "Collect" word (de "Einsammeln").
    `giftRewardPair` is `{first} + {second}`, except ja `{first}と{second}`.
  - The Opus review (D240) fixed 14 strings: es 1, pt 1, hi 1, de 4, fr 1, tr
    1 and ja 5. Japanese now titles it 毎日のプレゼント, so it never echoes デイリーパズル.
    No new hi or ja glyph, so no font rebuild.
- **D279. The daily gift's checks (D169).**
  - Host: the rules, the claim contract, the migration and the codec, the
    cubit (with the resume path), the widgets, the chest's slot chip, Home's
    header, the overflow suite in nine locales, and
    `test/ethics/login_gift_respect_test.dart`. That test scans the code,
    allows only `LoginGiftRules` to write `claims` (and only `+ 1`), walks 600
    odd clock jumps, checks the copy in nine locales and finds one call site
    for the sheet, reached only from a tap.
  - Device: `integration_test/login_gift_test.dart` (`ready`, `claimed`,
    `day7`, `clock_back`, shots `g_*`) as `nesty-test --only gift`, in the
    default run too, and the playthrough's `13b_home_gift_ready`. It passed on
    the iPhone 16e and the Android emulator, and all 14 iOS shots passed the
    contract and the respect rules.
  - After the review's fixes (D280) it passed again on both: iOS `gift` and
    the playthrough, and Android `gift`, the playthrough and E13 (4.2 s). One
    iOS `clock_back` run failed before its body ran, because `flutter drive`
    never attached while the host gates loaded the Mac; alone it passed in 35
    s. Before the Android rerun, the free space fell below the 20 GB floor
    (19.86 GB), so `apps/game/build/app` (Gradle's git-ignored output) was
    deleted.
- **D280. The daily gift's review (stage 4).**
  - No P0, and the security scan found nothing. Fixed: Day 7's cap released if
    the chest can't open, the app-resume test, a 6 dp gap between the gift
    button and the gear, the tiles' "Day N" baseline (the device shots), and a
    48 dp target test for the header.
  - Left: the tiles show Western digits, as every chip does, and a foreground
    app crossing midnight keeps the old dot until a save change, a resume or
    the sheet's open (nothing is paid wrongly).
- **D281. Claude Design's m7-5 is copied into `design/` (2026-10-07).** At
  the owner's "please do it yourself and put to design/", m7-5 went into
  `design/` as a one-off, as D171's m7-3 and D235's m7-4 did. `design/` stays
  owner-managed. 18 files changed, 9 entries were added, nothing was deleted
  (the copy was `rsync -rc` without `--delete`; `diff -rq` empty afterwards).
  It is Part 1 (the daily gift, App Flow section 13) and Part 2 (the answers
  to the m7-4 runs). Four lanes wired it (tooling, copy, gift, game plus
  menus) and a font lane and the lead integrated them (D282–D294). The
  repo-root `export 4/` copy was removed at the owner's request after it was
  verified identical to `design/`.
- **D282. m7-5's tooling stage.** Tokens v5 are generated: 1,989 leaves, 1,641
  emitted and 348 documented. The pieces:
  - The new type-token classes (`type.*`: Home, Chapters, Museum, Records and
    Shop type tokens) and the `gift.*` classes (button, sheet, tile, tally,
    claim, reduced motion, the 16:9 `short` set, type).
  - Documented leaves carry a check instead of a value: notes, prose tops
    (`layout.generating.card.top`, `layout.noCoins.top`: centred as built),
    placement rules, art references (a test checks each file ships and is
    synced) and copy ids (ARB keys). A reworded note fails the codegen.
  - `font.scripts.latnTr` (D291) is a whole-string face: never in a fallback
    chain, and the codegen fails if a bundled Fredoka weight is unmapped.
  - The two ribbons carry `sizedRects` (`band_rect`, `edge_rect`, `hi_rect`);
    LOTTIE.md "m7-5" is the contract.
  - `sync_design_assets` gains `ui/gift/` (`gift_glyph.svg`), `chip_slot.svg`,
    `slot_flight.svg` and `gift_claim.wav` (audio 31, UI art 38).
  - The icon font gains `more_horiz` (69 glyphs): the race strip's thinking
    state (D290).
  - `SfxMix` gains `gift_claim` at gain 1. All generators pass `--check`.
- **D283. The copy stage.** `copy.md` m7-5 went into the nine catalogs: eight
  new keys (`giftSubtitle`, `giftTitleShort`, `giftChestTitleShort`,
  `giftSlotsShort`, `chestContentsSlotShort`, `giftA11yChestContents`,
  `giftA11yClaimed`, `giftA11yAdded`) and four reworded in English
  (`giftButtonReadySemantics`, `giftTileSemantics`, `giftChestTitle`,
  `giftChestBody`). The Opus review (D240) fixed 9 strings: es 1, id 2, de 1,
  tr 1, ja 4. No new hi or ja glyph, so no font rebuild for the copy. The
  respect test's clock-word ban caught de "jetzt" in `giftA11yAdded`, now
  "Du hast {count}."
- **D284. The streak freeze chip stays as shipped.** `dailyFreezes` keeps "1
  freeze" and "{n} freezes", with "No freeze" at zero. DELIVERY 26 says "the
  game is right"; copy.md's "{count} streak freeze(s)" echoes our question's
  wording, and adopting it fails 12 overflow cases because the chip squeezes
  the streak count on the card's row. The translated "streak freeze" wording
  is the `dailyFreezesSemantics` value already in each catalog. Asked of
  Claude Design (BACKLOG).
- **D285. The gift's final look (Part 1).**
  - The button's glyph is `ui/gift/gift_glyph.svg` through `UiArt.giftGlyph`
    at 28 dp, so Q186 is answered and `IconUses.dailyGift` is gone. `UiArt`
    also gains `chipSlot` and `slotFlight`.
  - The header's gift face sits at right 68 and the gear's at right 16, 6 dp
    apart; the faces' top blends 64 to 26 dp on `HomeLayout.t`. The 12 dp
    ready dot has a 2.5 dp cream ring painted outside, and stays still.
  - The sheet is its own route (`GiftSheetRoute`, a `ModalBottomSheetRoute`)
    whose barrier paints the gift scrim, so a coin claim can open the 122 x 54
    hole round the Home coin pill (pill width + 12, radius 27) and light the
    pill ring above the scrim. It opens over 280 ms.
  - Its numbers blend between the 844 dp frame and the 16:9 `gift.short` set
    on the screen height, as Home blends 2.1 and 2.1b. The 16:9 sheet is 465,
    not 461, because the Claim stays the 58 dp large button (frame 54; BACKLOG).
  - The tally (`GiftTally`, `features/login_gift/widgets/gift_tally.dart`) is
    an overlay above the scrim and the chest dim, placed from the coin pill's
    live rect, left = pill left, top = pill top + 54. It slides from behind the
    pill, holds 1.2 s after the last landing and removes itself. It appears
    only from Claim and Day 7's Collect (the respect test checks it). Its "+N"
    tag sits on the disc's top end corner so it never covers "CHAPTER n"
    (13.5c).
  - Coins fly as `coinSpritesFor` sprites (one per 10 coins, 2 to 6) on a
    quadratic path with the control (175, 300) scaled to the screen. A hint or
    slot day flies one 40 dp sprite on the control (300, 240) (the claimHint
    scene; the tokens name only the coins'), 650 ms with a 3-dot trail, and
    lands on the tally's disc with a light haptic.
  - A tuned track's slot day (Days 1 to 6) shows `slot_flight.svg` as tile
    art; the tokens list coin and hint art only.
  - Day 7: `jingle_reward` plays on Collect (as Daily's day-7 chest 5.6 does),
    not after Open. The chest waits for the pill ring's 240 ms fade before it
    closes. Under Reduce motion the claim's hole and ring show for 400 ms, and
    Day 7 shows no ring (no flights).
  - New `SoundEffect.giftClaim` (`gift_claim`, at 0 on every Claim) and
    `HapticPattern.giftClaim` (light).
- **D286. Tile amounts never scale; the rings paint outside only.**
  - A tile amount too wide for its tile steps the art above it, then takes the
    locale's compact form (`NumberFormat.compact`: "100K", "10万", "100 mil",
    "1 लाख"; de keeps digits below a million), then shrinks the art to 16 dp
    or more. The screen-reader label keeps the exact amount. Only a tuned
    track reaches it (the default's Days 1 to 6 are 50 or less).
  - `RewardRing` and every gift ring paint their CSS box-shadow outside the
    shape (`RingGlowPainter`). The old `BoxDecoration` shadow also filled the
    shape, so the HUD pill's ring tinted the pill and the Hint badge's ring hid
    the badge under an opaque disc (10.3d draws a ring round a visible badge).
    Both chests' flights keep the trail and the pill ring.
- **D287. Part 2's game items (b-game).**
  - A ribbon is never scaled now: the canvas draws 1:1, and a phone narrower
    than band + 70 narrows the band through the named rects with the tails
    moved by half the difference (win: 290; chapter: 336, so 320 on 390 as 4.7
    draws). This supersedes LOTTIE v3's owner-accepted 6 dp tail overhang
    (2026-09-26): the ribbon and its 106 % pop stay on screen at every width.
    Directed by tokens `winRibbon.size` ("never wider than screen − 70"), not a
    lane's choice.
    `FxRibbon` in `features/fx/fx_ribbon.dart` is the one place; three
    hand-copied fallback painters became `RibbonRestPainter`.
  - The win label box is `winRibbon.size.textBox` (266 x 40), not
    `textFit.winRibbon.box` (312 x 40, left stale in tokens.json);
    `TextFitTokens.winRibbonBox` is unused. At 266 every win, daily and race
    title fits in all nine locales at 0.80 or more.
  - The chapter ribbon's label shadow is the chapter's `ribbonFold` at 35 %.
  - The tutorial's tap hand is its 128 x 144 canvas at 0.6 about the
    fingertip (48, 32): 40 dp. The generating card is centred in the safe area
    (Choice 10); the game had it at a fixed top. The splash gets its 240 dp top
    fade. The rival-select locked line is `textSecondary`.
  - The wobble before a move: `doll_move` starts at the angle `doll_pick`
    last drew and eases it to 0 over its first 80 ms; the pick clip now stops
    just after the flight starts, in the same frame. Core's events are
    unchanged. Undo takes no wobble.
  - Verified right, no change: the Restart glow (4), the chest rays and the
    glass dome (6, 9), the undo (13), the board pieces at their limits (23),
    the capped 16:9 win (22), the race win's toast and the Computer tag (24).
    The undo's `TODO(design): Q160` is gone.
- **D288. The race strip's forms (9.3, 9.3h, 9.3i).** The order is measured at
  the current text scale: full, then count only, then tag on a second line. The
  name no longer shrinks to 0.75 to keep a form ("pick the first form that
  fits"); only the last form may scale its lines. More than 8 families is
  always count only, and the dots are never under 8 dp (the m7-4 `dotsMany`
  6 dp is superseded). 9.3i shows a state glyph (`more_horiz` pulsing,
  `replay`, `check_circle`) after the tag, none before Start or once the player
  finished first (it would read as the computer's state). The strip is 58 dp
  only in 9.3i above 1.1x text, and the HUD moves the family counter down with
  it.
- **D289. Part 2's menu items (b-menus).**
  - The frame-only colours and shadows are tokens now (`cabinet`,
    `segmentTrack`, `segmentSelected`, `rowDash`, `museumNextName`). The
    figurine panel's two radial gradients stay in `AppColors` with a
    `TODO(design)`: `spotlightPanel` equals the cone's fill, not the panel's.
  - The type tokens are wired, with two frame-over-token choices: the museum
    header count stays 16 (`type.museum.count` says 20, the frame's CSS and the
    game draw 16) and the Shop balance follows NestyShop (13, #9A6A44).
  - Item 12 fix: the all-home Museum card draws `museum_full` at 92 dp
    (frame 6.1c), not a gold disc. Item 18: the figurine spotlight is 300 dp,
    200 on screens under 760 dp. Item 21: the Chapters list folds 3 rows
    above the current one (`scrollFoldedAbove`). Items 15 (twinkles 22/14),
    17, 19, 20, 25 and 27 verified, no change.
- **D290. The icon font gains `more_horiz` (2026-10-07).** The race strip's
  thinking glyph needed it; `tools/fonts/nesty_symbols.txt` names it, the icon
  font was rebuilt (69 glyphs, `build_fonts.sh --verify` passes) and
  `NestyIcons` regenerated. The tools' icon-gap test now expects no gap.
- **D291. Turkish display text draws in Baloo 2 (item 28).**
  - Fredoka lacks ğ Ğ İ ş Ş (and the rupee sign), which fell back to Nunito
    mid-word (D262). In `tr` every Fredoka role now draws whole strings in
    `Baloo2LatnTr`: Baloo 2 v1.700 from the Hindi face's pinned file, Latin and
    Latin Extended-A, weights 500, 600 and 700, 174 KB. Nunito stays for body.
    Never per glyph, and never in a fallback chain.
  - The rupee sign is added to the Devanagari subset, so it draws in Baloo 2 in
    every locale (the token's claim did not hold: `hi.txt` lacked it).
- **D292. How Turkish reaches the ~160 Fredoka use sites (the lead's
  integration of b-font's gap).**
  - The generated type tokens were `static const TextStyle` and could not see
    the locale. The codegen now emits every Fredoka style as a getter through
    `DisplayFace.of` (`core/ui/tokens/ui_token_types.dart`), and
    `AppTextStyles`' 13 Fredoka styles are getters too; const use sites lost
    `const` (analyze found each).
  - `LocaleScriptScope` sets the face for the whole app and
    `LocaleScript.display` swaps both ways (Fredoka to Baloo 2 in `tr` and
    back), so a locale change cannot leave the old face.
  - `lottie_label` and `slot_decor` build their styles per size, so they call
    `DisplayFace.apply` (uncached); `retry_view`'s head style and `sheet_row`'s
    label are static, so they read through `DisplayFace.of` (cached by
    identity, no allocation per frame).
  - `AppTheme.forLocale(locale)` gives one cached `ThemeData` per script.
  - The test harness wraps `LocaleScriptScope` and `AppTheme.forLocale`, and
    `test/flutter_test_config.dart` resets the face between tests.
  - The overflow suite's readability floor is measured against the script's
    size factor (`screen_harness`): Japanese draws at 0.94 by design, which is
    not a shrink, so its runs no longer flag text that sits exactly where the
    design puts it.
- **D293. The lead's other fixes in the integration.**
  - 9.3i's counter shift is clamped to 8 dp, so the counter pill's bottom stays
    at or above `hudClearY` (150). B-game had flagged a 2 dp overshoot (142 to
    152) at 1.3x text with a long rival name. It is tested.
  - Home's coin pill takes the locale's compact count
    (`CoinPill.homeNeedsCompact`, `NestyNumberText.compact`) only when the full
    count would be drawn below 0.8 of its size in the header's half: a huge
    balance on a 360 dp phone, worst in Turkish's wider Baloo 2 digits. The
    screen-reader label keeps the exact count. It is tested
    (`test/core/ui/coin_pill_compact_test.dart`).
  - The l10n test support's `LocaleRules` caches its compiled patterns (an
    `Expando` per rules object). Hindi's respect check took 3 min 48 s per test
    under load, compiling a Unicode-property RegExp per entry per key; it looked
    like a hang and stopped a full run. The ethics file now runs in 45 s.
  - The ja strip test expects count only at 1.0x and tag on a second line at
    1.3x (the measured forms).
- **D294. Checks for the gift's new parts (D169).**
  - Host: gift button, tile, sheet (844 and 16:9), tally, scrim and ring
    tests; the respect test's tally and dot checks (+2); the ribbons' width
    tests; the wobble hand-off tests; the Turkish font tests; the overflow
    suite in nine locales.
  - Device: `nesty-test --only gift` gains scenario `hint` (shots
    `g_41_hint_flight`, `g_42_hint_landed`) and `day7` gains
    `g_25_day7_collect`. TEST_COVERAGE's gift row is updated.
  - Incident, lesson for every lane: `dart run build_runner build
    --build-filter=<file>` deleted every other generated output in
    `apps/game` (27 files). A full `build_runner build` restored them; no
    file was lost. Never pass `--build-filter` here.
- **D295. Watch every long run (owner, 2026-10-07).** The owner asked: "please
  add a watcher agents always to detect and fix it also add a rule for it".
  - What happened: a background shell's default two-minute timeout had killed
    the game suite's wrapper, its `flutter test` ran on as an orphan, and a
    wait loop sat an hour on a summary file that was never written.
  - `tools/scripts/watch-run` watches a run's log and process. It prints one
    line per event (START, PROGRESS, FAIL, DONE, DIED, STALLED, OVERTIME) and
    ends on the first terminal state. It runs under the Monitor tool.
  - `.claude/agents/run-watcher.md` is the fixer an alert spawns: it diagnoses
    (the log, orphans, load, disk, the slow spot), fixes the cause with its
    test, and reruns the piece under a fresh watch.
  - CLAUDE.md Workflow "Watch every long run" is the rule: long runs go
    detached with an exit-code summary, watched from the start, and every alert
    is acted on at once. README has the commands.
  - First used for the l10n rerun (244 passed) and the m7-5 device run.

- **D296. The device run's and the shots' fixes (stages D and E, 2026-10-08).**
  - `meta_screens_test`: Chapters folds up to three rows (item 21), so on an 844 dp phone chapter 1's row shows above chapter 4's card. The step expects that only on a tall phone and scrolls to the row either way.
  - The gift tally sits in the root overlay, above every page's Material, so its count and "+N" tag drew `WidgetsApp`'s debug underline (iOS shot g_42). Its overlay entry now gives the body `DefaultTextStyle`, as the toast queue does. `gift_sheet_test` checks the tally's text has no decoration; it fails without the fix.
  - The all-home Museum card (6.1c) takes NestyHub's 12 dp gap beside the 92 dp badge. Its headline prefers one line (it may shrink to 0.9) and wraps only for a longer translation. `museum_page_test` pins one line at 390 dp.
  - `tools/scripts/nesty-test` pruned no old runs: `$(("…" + 1))` quoted a number in shell arithmetic. Fixed.
  - `watch-run` gains `--new-only`, for re-arming a watch on a run that is already going. An emulator restart now waits for the old one to exit and bounds its boot: a new one on the same AVD refuses to start while the old one holds it, and the first retry hung there until the watcher reported the stall.

- **D297. The local habits start now, with M7's and the gift's sign-offs open
  (owner, 2026-10-08).** The owner asked to build the four local habits in
  D274's order, fully offline (D269):
  1. welcome back;
  2. the month;
  3. the past dailies;
  4. the widget.

  As D272 did for the gift, this doesn't wait for M7's design sign-off (Q161),
  the VoiceOver pass, the gift's §7.5b paste, Q187 or Q188. The plan is
  [plans/plan-local-habits.md](plans/plan-local-habits.md), and the work list
  is BACKLOG "Local habits".
  - §7.5c (the past dailies) counts as spec once the owner approves it
    (Q189), and stage 3's code waits for that.
  - Stages 1 and 2 may run meanwhile.
  - The widget starts only after 1–3 pass on both devices.
  - The design comes later as `nesty-design-m7-6`. Until then the surfaces
    are `TODO(design)` stand-ins.
- **D298. Where the habits keep their data (2026-10-08, plan stage 0).**
  - **Welcome back's dates are settings, not save fields:** `lastOpenDate`
    and `welcomeBackDate` in `settings_schema.dart`. They describe this phone,
    not the player's progress, so there is no schema step.
    - `lastOpenDate` is a high-water mark, written after the previous value
      is read, so a clock wound back shows no card.
    - `LoginGiftProgress.latestSeen` isn't reused: it is written only once
      the gift unlocks, and on every Home load.
  - **The month reads `daily.done` and `daily.frozen`.** 31 dates cover the
    current month. If Q190 keeps its default, stage 3 raises `maxDates` to 62.
  - **The past dailies take their own path:**
    - save schema 4's `dailyArchive {played, inProgress}`;
    - `PlayRequest.pastDaily`;
    - `DailyArchiveRules`.

    So a past day never reaches `StreakDailyService._solveOn`, `daily.done`,
    `records.dailies`, `dailyReward` or today's in-progress slot.
  - **The month's week starts on the phone's region:** the rendered locale
    drops the region (`en_GB` renders as `en`), so the first preferred locale
    with the rendered language gives `intl`'s first day.
  - **The two numbers the admin tunes:** `welcome_back_days` (2, clamped
    2–60) and `daily_archive_days` (7, clamped 0–28) are Remote Config keys
    (rule 6).
- **D299. The widget uses the app's own platform channel, not `home_widget`
  (2026-10-08, plan stage 0, rule 9).**
  - **Why not the package:** `home_widget` 0.10.0 (pub.dev, checked
    2026-10-08) is maintained and fits Flutter 3.41.2. But its flavor support
    landed in Sep–Oct 2026 and is still changing (PRs #446, #469, #471,
    #472), and it adds `path_provider` and its own launch channel.
  - **Why the channel is enough:** the widget is static. The native side
    needs only a shared key-value store and a reload, so a
    `com.futrix.nesty/home_widget` channel beside `ChannelSystemSettings
    Service` adds no dependency.
  - **No streak rule in Swift or Kotlin:** the app writes an eight-day
    projection of the streak (`DailyService.projection`), and native code
    only looks the date up.
  - **Flavors:** one URL scheme and one App Group per flavor (`nesty`,
    `nesty-dev`, `nesty-stg`; `group.com.futrix.nesty[.dev|.stg]`), so the
    three installs never collide.
  - **Midnight:** iOS timeline entries at each local midnight, and an inexact
    Android alarm rescheduled on the time and zone broadcasts.
- **D300. Retention research, round 3, as proposals (2026-10-08).** The
  owner asked for web research on features that bring players back. The
  analysis is [plans/retention-research.md](plans/retention-research.md).
  - **Only what is new.** Each idea found was checked against ER1–ER12,
    TC1–TC14, the local habits and E1–E14, and against the code. Seven are
    new:
    - RR1, a solve coach: the solver's shorter line, replayed after a win
      on request;
    - RR2, a helping hand: one free hint on the third try of a level;
    - RR3, a living Home on the phone's clock;
    - RR4, Nest Maker: player-made puzzles shared as ER4 codes;
    - RR5, a satisfying replay clip;
    - RR6, the stores' re-engagement surfaces (M8);
    - RR7, a next-up peek on the win card.
  - **Left out.** Ideas already planned (Game Center, renovation, story
    maps) or already rejected are listed in the doc's §3 with where each
    stands. The rejected ones are win streaks, daily missions, albums,
    season passes, leagues and bot teams.
  - **Limits.** All seven are local except RR6. All are within the respect
    rules (D92) and the kid path (D260), and none is random, timed or sold.
  - **Not rules.** Q193 picks what to build. Anything that touches a rule
    needs spec-prop text first (RR1, RR2, RR4, RR5). Q192 asks whether
    RR2's free hint fits the never list.
  - **Where it sits.** BACKLOG has a new section, "Retention research,
    round 3", after the themes, characters and story section and before
    M4. Q193's default spreads the items over the existing waves.
- **D301. Claude Design's m7-6 is copied into `design/` (owner, 2026-10-08).**
  The owner asked to copy the repo-root `export 5/` into its folders and
  delete it, as D281 did for m7-5.
  - **The copy:** `rsync -rc` without `--delete`, `.DS_Store` excluded. 29
    files were added (`ui/widget/`, `prototypes/NestyHabits.dc.html`,
    `prototypes/NestyWidget.dc.html` and the SVG copies) and 12 changed
    (`tokens.json`, `copy.md`, `README.md`, `DELIVERY.md`, `AUDIO.md`,
    `LOTTIE.md`, `lottie/ui_chest.json` and five prototypes). Nothing was
    deleted. `diff -rq` was empty afterwards, and `export 5/` was then
    removed. `~/Downloads/export 5` is the owner's own copy and is left as
    it is.
  - **What it holds:** Part 1, the local habits (App Flow section 14 and
    12.14, the `habits` tokens, the widget art and the `## Local habits`
    copy), and Part 2, the answers to m7-5's open questions.
  - **The import comes later.** The owner's brief keeps the import a
    separate task, the m7-5 way. Until it runs, the `--check` of
    `gen_design_tokens` and `sync_design_assets` shows drift.
  - **Look only, not rules.** It draws Q190's and Q191's defaults: a ‹ chip
    on the 1st–7th that reaches the window's days in the month before, and a
    frozen day's own mark. It also disables the coin and ad boosters on a
    past day. That last point is a rule, so it went into §7.5c for the
    owner's approval (Q189) instead of being taken from the design.
- **D302. Stages 1 and 2 built: welcome back and the month (2026-10-08).**
  Two Sonnet lanes built them on stand-ins, and the lead integrated them.
  The details are in BACKLOG "Local habits" and
  `build/local-habits/reports/`.
  - **Welcome back's Play** pushes the Daily, then today's board, so the
    win's "Back to Daily" lands on the Daily.
  - **The open tracker** (`WelcomeBackTracker`, started in bootstrap) reads
    `lastOpenDate` before it writes, and keeps it in memory, because Home
    asks in its first frame.
  - **The card's headline** wraps to a second line before it shrinks. The
    overflow suite's readability floor caught id's, pt's and tr's lines in
    the slot beside Records. So id is "Halo lagi!", pt "Olá de novo!", and
    tr's button "Bulmacayı oyna".
  - **The week's first day:** `WeekStart` reads the date data
    `GlobalMaterialLocalizations` already loads (`en_GB`, `pt_PT` …), not
    intl's 346 KB `date_symbol_data_local` table.
  - **Copy checks:** `respect_copy_test` now checks the `welcomeBack` and
    `dailyMonth` keys.
  - **Checks:**
    - host: analyze, the game suite, tools, fonts (no new glyph), the TODO
      index, and the habits' overflow suites in nine locales;
    - device: `daily_states` with `welcome` and `month` on the iPhone 16e,
      with the shots judged. Android comes with the post-stage-3 run.
- **D303. Auto-compact at 400k tokens (owner, 2026-10-08).** The owner asked
  for compaction to happen on its own before a session gets huge. The
  project's `.claude/settings.json` sets `autoCompactWindow: 400000`, so
  Claude Code compacts when the context reaches 400k tokens instead of near
  the model's full window. CLAUDE.md's Workflow says so. "Compact
  instructions" decide what survives, and the checkpoints keep the rest.
  - **To change it:** `/autocompact <n>k` for one model, or edit the
    setting. The environment variable `CLAUDE_CODE_AUTO_COMPACT_WINDOW`
    overrides both.
- **D304. m7-6's tooling: tokens v6, the widget art and the chest's matte
  (2026-10-08).** The owner asked for the import (D301 copied it). Stage A1
  made the four generators accept it; `--check` of `gen_design_tokens`,
  `sync_design_assets`, `gen_fx_spec` and `gen_nesty_icons` is clean again.
  Details: `build/m7-6/reports/a1-tooling.md`.
  - **Tokens v6:** 2278 leaves, 1849 emitted and 429 documented; 325 members
    were added and none removed or renamed. The new classes are the
    `Habits*Tokens` (welcome card, month, day cells, past day, widget) and
    `RibbonTitleTokens`. A key with a dot (`flame_lit.svg`) now spans path
    segments in `TokenReader`.
  - **Elliptical radial gradients** (the figurine panels) are emitted as a
    radius-0.5 `RadialGradient` with `EllipseGradientTransform`, a hand-written
    const `GradientTransform` in `ui_token_types.dart`, so the stops land
    where the design's do on any box.
  - **`design/ui/widget/` is native art:** the sync validates it against
    `habits.widget.art` (flat SVGs at the dp aspect, the one-colour doll,
    1x/2x/3x PNGs, the two previews, nothing else) and copies nothing into
    `apps/game/assets`. Stage 4 turns it into the iOS catalog and the Android
    drawables, as `ui/notification` became the notification icon.
  - **The Lottie contract allows one gradient fill:** `matteFills` lists the
    `<part>_fill`s a file may have as a `gf`, each valid only on an alpha
    matte (`td: 1` over a layer with `tt` 1 or 2). `ui_chest`'s `rays_matte`
    carries `falloff_fill`. Every other `_fill` must still be a plain fill.
  - **Prose sound events:** a single file with a note (`button (the welcome
    card, ...)`, `win @0, no coins (...)`) reads as that file. The habits
    play `button` and `win` and add no sound; a tools test checks it.
  - **The habits' rules stay code:** `habits.respect`, the welcome card's
    `when` (`welcomeBackDays`), the month's 7-day window and a past day's
    rules are documentation, not emitted values.
- **D305. m7-6's copy is in the nine catalogs (2026-10-08).** Stage A2 mapped
  `copy.md` "Local habits", its short forms and Part 2's freeze chip onto 51
  keys (`welcomeBack...`, `dailyMonth...`, `pastDaily...`, `dailyLocked...`,
  `widget...`, `dailyFreezesShort`). No new glyph, so no font build.
  - **Stand-in keys kept their names:** `welcomeBackPlay` is now "Play" and
    its old phrase moved to `welcomeBackPlaySemantics`. `dailyMonthDaySemantics`
    drops the unused `playable` cases; a playable day wraps its label in
    `dailyMonthDayOpenSemantics`.
  - **"Just for fun" avoids each catalog's denied "only"** (es solo, pt só,
    de nur, id hanya, hi सिर्फ/केवल, tr sadece): "por pura diversión",
    "einfach zum Spaß", "tamamen eğlence için".
  - **The Opus review** (D240) kept 47 of ja's 51 values and changed four:
    お楽しみ read as a calque, so `dailyMonthHint`, `pastDailyNote`,
    `pastDailyWinLine` and `pastDailyWinSemantics` say 気軽に, a character
    already in the subset. The other eight locales were kept. The retired
    `apply.py` held the old ja values and is not to be rerun.
  - **The respect check widened:** `checkedPrefixes` in
    `test/l10n/support/arb_checks.dart` and the ethics test now cover
    `pastDaily`, `dailyLocked` and `widget`, so the denied lists run over all
    51 keys.
- **D306. The local habits' final look replaces the stand-ins (2026-10-08).**
  Stage B-habits, from tokens v6 and the App Flow frames 14.1, 14.2 and 12.14.
  Report: `build/m7-6/reports/b-habits.md`.
  - **The welcome card** is one button (`TactileSurface`): the whole card
    plays today's daily, its Play pill is a look, and the close is a 28 dp
    disc in a 48 dp target. The close fades the card over 180 ms, then the
    cubit hides it, so the dolls grow back after. The card takes its short
    line when the full one needs a third line, and Play goes under the text at
    1.3x.
  - **Home's dolls under the card:** the scale clears the tallest doll 8 dp
    below the card (0.78 on 844), and below 0.6 the dolls fade out and the
    plank stays. The card height is measured, so larger text shrinks the
    dolls further. The card sits 74 dp under the chapter card on every size;
    the slot variant is gone.
  - **The month card** reads `HabitsMonthTokens` and `HabitsDayCellTokens`:
    the lit, played-later, freeze, today and open looks, a legend of only the
    marks the month holds, and the short values under 768 dp. The hint line,
    the previous-month chip and any tap wait for stage 3 and Q189
    (`TODO(later)` in `month_card.dart`).
  - **12.14, `DailyLockedCard`,** replaces the lock icon and line on the Daily
    page before Level 2 is won: its title, body and a Play Level button. The
    frame's sizes have no tokens, so they come from the scene and a
    `TODO(design)` stays (BACKLOG, Design gaps).
  - **Not built, and noted:** the month's 728 dp top and the 16 dp header
    fade once scrolled (the Daily stacks its cards 16 dp apart), and frames
    14.2c-g and 14.1d were judged by tokens, not viewed. The close target
    overlaps the Play pill's top 6 dp, as the design does.
- **D307. Part 2's items, as built (2026-10-08).** Stages B-menus, B-game and
  B-font; reports `b-menus.md`, `b-game.md`, `b-font.md`. Item numbers are
  the design's.
  - **1, the freeze chip:** it shows `dailyFreezesShort` (the number) beside
    the snowflake when "{count} freezes" passes 64 dp at the current text
    scale.
  - **2, the Computer tag** scales with the text setting up to 1.3x (height
    20k, glyph 14k, text 11k, radius 10k; the ring stays 1.5 dp). Callers
    still drop to the glyph first where a row can't grow.
  - **3, Pause in a race** stays 48 dp and sits `formsPauseTop` (5 dp) down
    when the strip is 58.
  - **4, Claim on 16:9** is the 58 dp button and the sheet 465 dp; the code
    already followed `GiftShortTokens`, so nothing changed.
  - **5, the Day 7 ribbon:** the chest modal uses the default `RibbonTitle`,
    which now reads `RibbonTitleTokens`.
  - **7 and 8, the Museum:** the count is `MuseumTypeTokens.count` (16,
    tabular), the figurine spotlight reads `AppGradientTokens.figurinePanel*`
    (`AppColors.spotlight*` are removed) and the brass name plate reads
    `MuseumTokens.cabinetNamePlate*`.
  - **10, the chest's rays:** no code change; a test renders the real
    `ui_chest` and checks that the matte fades the rays outwards.
  - **13, Records:** "Best moves" opens Chapters and its `TODO(design)` is
    removed.
  - **14, the tutorial:** Level 1 already has one family, so no rule changed;
    `TutorialLift` fades the scrim, hole, tip and hand over 200 ms when the
    cue ends.
  - **15, the text link** is Fredoka 700 16/20 (`AppTextStyleTokens.textLink`)
    with the same 48 dp box; `RetryView` follows.
  - **16, the family counter** follows the text setting up to 1.3x: the label
    hugs its text between 30 and 58 dp, the pill is label + 34 (at most 92),
    and a longer label shrinks and never wraps. Fidelity gap: the bundled
    Fredoka measures "12 / 12" at 37 dp where the design says 44, so our pill
    is 71 against 78.
  - **17 and 20, the splash:** error dim is `scrimLight`; the plank's dolls
    are not built until the skin is ready, then fade in over 200 ms (the
    fallback draws only if the load ends with no art), and the fallback body
    radius is 0.16 of its height.
  - **18, 19 and 21, the board:** `ShelfPresets.one` is a designed preset
    (plank 540, 150 dp, up to 4 slots), the row of 6 already followed the
    row-of-5 formulas, and an invalid drift onto an empty target stops at
    0.5 of the mover's height.
  - **The month's ‹ chip glyph:** `chevron_left` is in the icon subset
    (70 glyphs, `NestyIcons.chevronLeft`, `IconUses.monthPrevious` and
    `monthNext`). The close glyph stays at the bundled 600 cut, where
    tokens say `dismissGlyphWeight` 700: a fidelity note, as the gift's check
    was before item 6.
- **D308. The integration and the host gate (2026-10-08).** Stage C (the lead)
  integrated the lanes, and `nesty-test --only gates` ran. Two failures were
  real and are fixed with tests; the rest were stale tests.
  - **The Museum's all-home line (6.1c)** got `ShrinkToFitText.overflowMinFontScale`:
    on one line it may shrink to 0.9, and on two lines to the 0.75 readability
    floor. Spanish at 1.3x text ("Todas las familias están en casa.") was cut
    beside the 92 dp badge. This predates m7-6 (the m7-5 card), and the gift
    gate never ran the es suite. Test: `shrink_to_fit_wrap_test.dart`.
  - **`ComputerTag`** now passes its scale k as `TextScaler.linear(k)` on an
    11 dp style, instead of folding k into the font size with `noScaling`. The
    readability floor now judges the word against its 11 dp: Hindi at 1.3x on
    Home's vs Computer tile read as 70% of 14.3 dp, and it draws the same
    size. Test: `race_atoms_test.dart`.
  - **Test fixes:** `streak_card_test` loads the bundled fonts, because the
    freeze chip's 64 dp fit was measured in the test font (every glyph 1 em);
    `asset_manifest_test` counts 70 glyphs (`chevron_left`); the welcome
    card, daily states and splash tests follow the new copy and timing
    (`playthrough_test` splash comment, `daily_states_test` finders).
  - **Gate result:** `nesty-test --only gates` passed in every step, with the
    es and hi overflow suites rerun in full.
  - **Not done yet:** the device run (stage D, both platforms) and fidelity
    judging (stage E) are in progress. Their results go in a later decision.
- **D309. m7-6's device run and fidelity (2026-10-08).** Every on-device
  check passes on the iPhone 16e and the Android emulator, and the shots
  match the m7-6 frames. The reports are `build/m7-6/reports/e-fidelity-ios.md`
  and `e-fidelity-android.md`.
  - **Device:** Android passed every check in one run. iOS failed one step,
    the new `locked` (12.14). Home's Daily tile is inert until the Daily
    opens, and before stage 4 nothing in the app opens the Daily that early
    (the widget's link will, DELIVERY item 12). The step now checks the
    tile's "After Level 2" and opens the Daily as that link will. iOS then
    passed every `daily_states` scenario.
  - **Fixed from the judging:**
    - the paused streak card's freeze chip sits at the card's right edge,
      as 5.2b draws it, not right after "Paused";
    - the Daily's 7-day strip draws its 2 dp rings (`inset 0 0 0 2px`).
      They were inset shadows with no spread, so nothing painted since M7.
      Test: `day_strip_test.dart`;
    - the month's seed marks its freeze notice seen, so the existing
      "Streak saved" toast no longer covers the month shots.
  - **By design:**
    - the month's past cells are flat: raised means playable, and that
      waits for stage 3;
    - on the emulator's short screen (411 × 731 dp, like 2.1b) the welcome
      card fades the dolls out and the plank stays (14.1d);
    - the iOS month starts on Sunday, from the phone's region.
  - **Left as notes:** the figurine modal's "0/20" against the frame's
    "15 / 20" (a BACKLOG fidelity note, older than m7-6), a one-word last
    line in the locked figurine modal, and the gift chest's chips about
    10 px wider. The respect rules pass on every habit shot.
  - **BACKLOG:** the ten m7-5 follow-ups that m7-6 answered are ticked.
  - **Final host gate:** `nesty-test --only gates` after these fixes passed
    every step except the TODO index, which had gone stale because doc
    edits shift its line numbers. It was regenerated, and `tools` (474 tests)
    and every generator's `--check` passed.
- **D310. §7.5c, the past dailies, approved (owner, 2026-10-08).** The
  owner approved Q189: the rule text in plan-local-habits §7.5c and its
  defaults table. Q190 and Q191 keep their defaults, which m7-6 already
  draws: a ‹ chip on the 1st–7th reaches the window's days in the month
  before, and a frozen day has its own frost mark. §7.5c now counts as spec
  for the archive until the owner pastes it into GAME_SPEC (the owner's
  brief, D297). Stage 3's code starts.
  - **Commits:** the owner allows commits when they are needed
    (conventional, no attribution, never a force-push). Pushing still waits
    for the owner.
- **D311. Stage 3, the last 7 dailies, built (2026-10-08).** Four lanes
  (save, core, logic, ui) and the lead built §7.5c on m7-6's final look
  (14.3a–e). Prompts, checkpoints and reports are in
  `build/local-habits/{prompts,checkpoints,reports}/stage3-*`.
  - **Save schema 4:** `dailyArchive {played, inProgress}` sits beside
    `daily`, never inside it.
    - The step 3 → 4 stamps an empty archive, and keeps one a downgraded app
      left. The codec reads it leniently: a malformed archive reads as empty.
    - `DailyProgress.maxDates` goes from 31 to 62, for Q190's month back.
    - A real schema-3 fixture (`fixtures/schema3_document.json`) is migrated
      in the tests.
  - **`PlayRequest.pastDaily` (`PlayKind.pastDaily`):** its board is saved in
    `dailyArchive.inProgress`, one at a time; a second past day replaces the
    first. Today's board is never touched.
  - **The window:** `DailyArchiveRules` (`core/services/daily_archive/`) and
    `daily_archive_days` (7, clamped 0–28, 0 turns it off; a malformed value
    reads as 7). There are now 34 Remote Config keys.
  - **The resolver takes the `AppClock`,** so the gate lives in one place. It
    refuses today, a future date, a date before the window and a locked
    Daily. It accepts the saved past board's own date, for a board still
    open past midnight. It builds that date's daily with `rewardCoins: 0`.
    - No new core API: the board comes from `dailyParams(date)` and
      `generateWithRetries`.
    - `test/parity/daily_past_dates_test.dart` pins it. It sits in `parity/`
      so the node, chrome and dart2wasm runs take it by directory.
  - **The win:** it counts in stats, families, dolls and badges as a replay
    does. It pays 0 coins, writes no `daily` field, and leaves
    `records.dailies`, `longestRun`, `lastSolve`, the chest and `adCounters`
    alone. It adds the date to `played` once.
  - **The prune** runs on the Daily page's load
    (`DailyService.pruneArchive()`), never from gameplay.
  - **Boosters on a past day:** `canUndo`, `canHint` and `canAddSlot` mean
    "owned" (dev's unlimited boosters count as owned). The bloc refuses a buy,
    a stale confirm included, and Out of moves lists the owned boosters plus
    Restart.
  - **Analytics:** `past_daily_complete {days_ago, again}`, with the M4
    kid-path `TODO`.
    - Lead ruling: `level_start` and `level_win` still fire for a past day
      (the level is the date), as they do for the daily. They are generic
      gameplay events, and the M4 kid path gates all analytics.
    - Ads: a past day never touches `adCounters`. BACKLOG M6 gains "the
      interstitial counter skips a past daily".
  - **The picker and the card (lead rulings on lane ui's drafts):**
    - every window day opens, played or not. A solved day offers Play again,
      and "Solved on the day" wins over "Played later";
    - tapping the open day again closes its card. The card stays open on the
      way back from a game (14.3e);
    - a past day's win plays the `win` cue (the design's `habitsPastWin`),
      never `coins`;
    - today's cell scrolls up to today's card while the window's days are
      open (14.3a), built by the lead.
  - **Day targets:** 48 dp tall and one column wide, so 43–44 dp on a 360 dp
    phone. The grid can't be wider than its card (14.3a), and 44 still meets
    iOS's 44 pt. The ‹ chip keeps 48 × 48. While the picker is active, rows
    and the header grow to 48 dp, so the card is about 18 dp taller than
    14.2.
  - **No new strings:** m7-6's copy (D305, with its Opus review) already held
    every `pastDaily…` key. The overflow cases are in
    `daily_month_overflow_test` and `win_overlay_overflow_test`.
  - **Device step:** `daily_states_test.dart` gets the `archive` scenario on
    2026-11-03, whose window (Oct 27–Nov 2) crosses into October, so the ‹
    chip shows. Its shots are `d_40_month_window` to `d_45_today_resumes`.
    `nesty-test` runs it in the `daily_states` loop.
  - **The stage's review** (`build/local-habits/reports/stage3-review.md`)
    found two P1s and five P2s, all handled with a test each:
    - the board's Out of moves sheet never got the past-day flag, so a
      spent Undo still showed its price (inert). It does now, and
      `gameplay_view_test` covers the sheet and a Hint with none owned;
    - Play on a past day's card after midnight rolls the screen over and
      starts nothing, instead of a board the resolver refuses;
    - `PastDayReveal` keeps one `CurvedAnimation` and disposes it;
    - the played list's trim keeps the newest dates, not the latest
      played;
    - the month's hint says "7 days" while `daily_archive_days` is tunable.
      Nothing serves another value before M4's Remote Config, so it is a
      `TODO(M4)` and a BACKLOG M4 item.

- **D312. Stage 4, the home-screen widget, built (2026-10-08).** Three
  lanes (dart, ios, android) built plan-local-habits §4 in their own
  worktrees on m7-6's widget frames (14.4), from the lead's frozen contract
  and the ui-designer's spec with the lead's rulings
  (`build/local-habits/{prompts,reports}/stage4-*`). A fourth lane wrote the
  device check. No package (D299): one test-only Gradle dependency, JUnit.
  - **The contract:** the channel `com.futrix.nesty/home_widget` (`publish`
    takes the JSON and answers a bool; `readBack` and `storeInfo` exist only
    in debug builds, for the device check). The store is iOS's App Group
    `UserDefaults` (`group.com.futrix.nesty`, `.dev`, `.stg`; key
    `nesty_widget_snapshot`) and Android's SharedPreferences `nesty_widget`
    (key `snapshot`). A failed or missing channel is silent (rule 3).
  - **Snapshot v1:** `{v, scheme, lang, unlocked, locked{title, small,
    medium, a11y}, days[8]}`, one entry per date from the app's local today.
    Each day carries `state` (`ready`, `solved`, `paused`, `zero`), `streak`,
    and every string already localized: `number`, `label`, `labelShort`
    (paused only), `title`, `sub`, `line`, `lineShort`, `a11y`. `dolls` (hex)
    are today's and tomorrow's only, from the Daily's own board through
    `LevelResolver`, and none while the Daily is locked. A newer `v` or a
    malformed snapshot draws the first-run state. The goldens
    (`test/fixtures/widget_snapshot_v1*.json`) are read by the Dart, Swift
    and Kotlin tests alike.
  - **No streak rule outside the app:** `DailyService.projection(from,
    days)` runs the one `_reconcile` cumulatively (freezes spent on one date
    are gone on the next), equal to `refresh()` walked day by day over 40
    seeded saves. The natives only look a date up. `HomeWidgetBridge`
    publishes on start, resume, `DailyService.changes` and a language
    change, skips an unchanged write and retries a failed one.
  - **Past the last entry** (a phone left unopened for more than a week):
    the last entry keeps its state, so a resting streak stays resting. Only
    a solved last entry turns ready, since the new day isn't solved. The
    title is the generic one, with no sub and no dolls. Lead ruling on the
    lanes' two readings; Android was changed to iOS's.
  - **The link:** `<scheme>://daily` (`nesty`, `nesty-dev`, `nesty-stg`).
    `WidgetLink` takes a cold link through the splash: the Daily over Home
    when unlocked, Home when locked, Level 1 on a first launch. A warm link
    pushes the Daily over the current stack, and with the Daily locked it
    changes nothing. `widget_open` is logged with the M4 kid-path `TODO`.
  - **iOS:** `tools/ios/add_widget_target.rb` (xcodeproj gem, idempotent,
    `--check`) creates and keeps the `NestyWidget` target in the nine
    configurations, with `$(app id).widget` ids. The fonts and goldens are
    referenced, never copied, and the extension has no pods.
    `NestyWidgetStore.swift` is compiled into Runner, the extension and
    RunnerTests, so the group key exists once. Runner's Debug
    configurations gain `SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG` for
    the debug-only methods. FlutterSceneDelegate already delivers cold and
    warm links. The day key is always Gregorian in the phone's zone. The
    gallery alone shows the first-run state. **The widget kind
    `NestyDailyWidget` is never renamed:** placed widgets are found by it.
    The App Groups need the owner's Apple Developer steps before a signed
    build (BACKLOG "Owner inputs needed"); simulators need none.
  - **Android:** `NestyWidgetProvider` redraws per exact size (one
    RemoteViews per `OPTION_APPWIDGET_SIZES` entry on API 31+, the
    portrait and landscape pair before). The height tiers come from the
    measured need at the phone's font scale, not fixed thresholds, so a
    large font drops the dolls instead of overlapping; at 1.0 they land on
    the spec's 154 and 122 dp. The medium look starts at 250 dp. A strict
    JSON reader of our own (`WidgetJson.kt`) runs the same on the JVM and
    the phone. An inexact midnight alarm (no exact-alarm permission) is
    re-armed by itself, `TIMEZONE_CHANGED`, `TIME_SET`, `BOOT_COMPLETED`,
    `LOCALE_CHANGED` and `MY_PACKAGE_REPLACED`. The tap is an explicit,
    immutable intent to `MainActivity`.
  - **Generated native files:** `gen_widget_strings` (new `nesty_tools`
    script, `--check` in CI) writes the gallery name, description and
    first-run title from the ARBs to iOS `<lang>.lproj` and Android
    `values-<lang>` (`values-id`, `values-pt-rBR`; iOS `pt-BR.lproj`).
    `sync_design_assets` now also writes the widget's art (iOS asset
    catalog, Android vector drawables, the 2 × 2 preview) with the C2PA
    chunk stripped.
  - **Faces:** Fredoka and Nunito for en, es, pt, pt_BR, id, de and fr;
    the system face for tr, hi and ja (lead ruling, gap 10; Android draws
    the system sans everywhere).
  - **Strings:** none new. m7-6's copy (D305, with its Opus review) held
    all 19 `widget…` keys.
  - **Design gaps:** the first-run look, the short tiers, the locked and
    4 × 2 tiers, the tinted and StandBy looks, the line's balance and the
    "+N" dolls take the spec's defaults with `TODO(design)` (12 in Swift, 3
    in Kotlin), listed in BACKLOG.
  - **Tests:** the Dart side (projection, snapshot and goldens, bridge,
    link, the codegen and art in `tools/test`, the ethics scan of
    `home_widget` and `widget_link`), Kotlin JVM (`WidgetTimelineTest`,
    `WidgetJsonTest`, `WidgetFitTest`), RunnerTests (`NestyWidgetCoreTests`,
    18) and `integration_test/home_widget_test.dart` with
    `nesty-test --only widget`. A simulator can't place a widget, so the
    look on a home screen is the owner's real-phone check (BACKLOG).
  - **The stage's review** (`build/local-habits/reports/stage4-review-{dart,native}.md`):
    no P1, five P2s on the two sides, all fixed with tests:
    - a second tap with the Daily, or today's daily board, already on top
      pushed a second Daily. It now opens nothing more. Any other screen
      keeps its place under the Daily, as the plan says: a board sits under
      the Pause the app opened when it was hidden, which holds a race's
      clock;
    - the bridge only followed `DailyService.changes`, which fires when a
      screen refreshes the daily. It now also follows `SaveService.changes`,
      keyed on the daily's progress (without today's board) and the
      unlock, so a solve or Level 2's win republishes and a board's moves
      compose nothing;
    - a link on our scheme other than the widget's reset the app to the
      splash. Cold, it now starts the app as usual; warm, it moves nothing;
      it is never logged;
    - Android's widget work catches `Throwable`, always answers Dart, and
      the clock receiver redraws under `goAsync` on the widget's single
      worker thread, never the main thread;
    - the cold-link device checks can't see a Flutter route, so the lead
      judges `w_cold_link` for the Daily.
- **D313. Stage 3's device run, a date fix, and a paused session
  (2026-10-08).**
  - The full run after stage 3 passed on the iPhone 16e except three steps:
    the meta finale (`flutter drive` never attached, the Mac under load), and
    daily_states' month and archive, whose expectations predated the window
    (window days now say ", open to play"; November 3's page shows two open
    days with October's five behind ‹). The tests are fixed.
  - On the Android emulator every step through the daily gift passed except
    daily_states' chest (a starved emulator) and archive (a test bug: today's
    Play sat under the header; it is now scrolled clear first). Overlays was
    stopped while hung and wrongly logged PASS. The emulator then stopped
    answering adb under host load 34–47 from another project's builds, so
    faults, semantics and locales never ran.
  - Judging d_43 found a real bug: the past day's date printed
    "Sunday1November". intl reads a string as a skeleton only in its own
    spelling, so the tokens' `EEEEdMMMM` was read as a pattern.
    `core/ui/date_skeleton.dart` puts a skeleton's fields in intl's order
    and the locale gives the order and punctuation ("Sunday, November 1",
    "Sonntag, 1. November"), as CLDR intends; copy.md's "Saturday 10
    October" is a sample, not a format.
  - `nesty-test` no longer counts a stopped `flutter drive` as a pass: a
    device step needs the driver's "All tests passed.", and a driver
    extension that never answers stops the step after the attach-hang limit.
    The device scripts wait for the Mac's load to fall under 20 and cold-boot
    the emulator before Android.
  - Stage 4 is merged into `feat/m7-offline-game`. The reruns of stage 3's
    failed and missing steps fold into the full run after stage 4, which runs
    them on the same code.
  - 14.3d at 731 dp puts the button over the bar: a design gap in BACKLOG.
  - The owner has no Apple Developer account yet, so the widget's App Groups
    ([plans/widget-apple-setup.md](plans/widget-apple-setup.md)) wait.
    Simulators need none of it; a real-iPhone build and an upload do.
  - The owner paused the session at this checkpoint. The resume steps are in
    `build/local-habits/checkpoints/stage3-lead.md` "Resume".
- **D314. The full device run after stage 4, part one (2026-10-09).**
  - The host gate on the merged tree passed once a stale TODO index and four
    analyzer infos were fixed.
  - The iPhone 16e passed every step except three areas, all fixed:
    - `faults_test` race_failed, generating and bonus_failed: bootstrap
      started the widget's bridge, which holds the `LevelResolver` and so the
      generator, before the `beforeRunApp` seam, so the faulty generator was
      never used. The bridge now starts after the seam
      (`test/bootstrap_order_test.dart`). The app itself was not affected.
    - the widget's drives: `xcodebuild test` ran RunnerTests (which passed)
      on a clone, and a clone needs its source shut down, so the 16e was off.
      `nesty-test` runs them without parallel testing and boots the device
      again by UDID.
    - d_43 against frame 14.3d: the Moves pill used the regular win's Nunito
      15 chip; tokens.json `habits.pastDay.win` sets Fredoka 700 28. The date
      cell's day is now Fredoka 700 22, and the card takes the frame's note,
      colours and spacing. Both judges missed it; a judge now has to open
      each frame and compare type with the token and the frame's CSS.
  - `watch-run` now flags `nesty-test`'s own "FAIL <step>" lines: a device
    run's failed step had stayed silent until the run's exit.
  - Android passed the playthrough (E13: 3.9 s to level 1), then the emulator
    wedged at resume phase B with the Mac out of memory (swap 16.3 of 17.4 GB
    from another project's tests). `bin/device4-android.sh` waits for the
    load under 20 and memory at least 40% free before it cold-boots the
    emulator.
  - The owner paused the session again. Left: the iOS reruns (daily_states,
    faults, widget), the rest of Android, the judging, then the close.
- **D315. The device run after stage 4, part two, and the local habits'
  close (2026-10-09 to 2026-10-10).**
  - iPhone 16e reruns (20261009-195236, 20261010-081708):
    - passed: daily_states, faults 8/8, RunnerTests, the widget's four
      drives and the embedded `.appex`;
    - daily_states `paused` failed once only because the simulator's
      SimMetalHost crashed with the Mac's swap full; the same code passed
      on 20261009-195236;
    - the cold link records SKIP: from iOS 17 the simulator asks "Open in
      …?" before `simctl openurl` opens an app (a widget's tap doesn't ask),
      and no tool here can tap it. The cold start is covered by the Android
      cold link and `widget_link_test`.
  - Android emulator (20261010-084542): 106 steps passed. The one failure
    was the widget's cold link, which opened Level 1's tutorial. Cause:
    `flutter drive` uninstalls the app when its test ends unless it keeps
    the app running, so the dev app went onto a clean phone (a first launch).
    `nesty-test`'s fix:
    - `ready` keeps the app (`--keep-app-running`);
    - the dev app is built on the seeds' date (`NESTY_FAKE_DATE`);
    - an `am start -W` timeout counts when its Activity line is the app's
      (the resumed activity is still required);
    - the run's output folder is made absolute.
    The rerun (20261010-095915-widget-android) passed 7 of 7: a cold start
    in 6.6 s onto the Daily over Home.
  - Judged:
    - stage 3's d_40–d_45 against 14.3a–e, with the frames open;
    - iOS's d_43 reshot after D314's sizes;
    - every w_ shot on both platforms: iOS 10 PASS and the cold link's SKIP;
      Android 11 PASS, compared with iOS shot by shot by the lead, because
      the judge skipped the references.
    Reports: `build/local-habits/reports/stage3-fidelity.md` and
    `stage4-fidelity.md`. Stages 3 and 4 pass on both platforms.
  - The close `/review` (`build/local-habits/reports/close-review.md`;
    code-reviewer, security-scanner, the ethics lens) found no P0 and no
    P1. P2 fixed:
    - `WelcomeBackTracker` builds its lifecycle listener in a try, starts
      once and is disposed by get_it (`welcome_back_tracker_no_binding_test`);
    - a test pins where `intlSkeleton` puts letters it doesn't order;
    - 14.3d's sizes, which only the design's prose and CSS give, are marked
      `TODO(design)` with their BACKLOG gap;
    - `drive`'s temporary log moved under the run's logs.
    Left as they are:
    - Android Auto Backup (`allowBackup`'s default): with no account, it is
      how an offline player's progress reaches a new phone, and the save
      holds no personal data. M8's privacy and kid-path review decides
      (BACKLOG M8).
    - The archive's `played` has no read cap (it is pruned on refresh), the
      widget's `publish` takes any size (only our Dart calls it), and a web
      page can fire `nesty://daily` and log `widget_open`: noise for M4's
      analytics item.
  - The 20 GB disk floor: the three merged agent worktrees were removed
    (9.4 GB; their branches are kept), with the test cache and `build/ios`.
    `device4-android.sh` waits for memory at least 25% free (40% never came
    while another project's tests ran).
  - On the owner's request in another session (2026-10-10), Home's
    welcome-back card was commented out briefly. The same day that session
    restored it, on the owner's word to do what is best for the game.
    Nothing of it was committed, and the card, its tests and the `welcome`
    device scenario are unchanged.
  - `nesty-test --only gates` passed on the closed tree (46 steps, run
    `build/local-habits/logs/gates-20261010-101129.log`).
  - The local habits are code complete. Left with the owner:
    - the widget on a real phone: placing it, the drawn sizes, light, dark
      and tinted, a real midnight, the tap;
    - the App Groups, which need an Apple Developer account (D313);
    - the design gaps in BACKLOG "Local habits".

## Package reasons (CLAUDE.md rule 9)

Versions are the resolved versions in the root `pubspec.lock`, checked
against every member's `pubspec.yaml` on 2026-09-26. "§13.2" says whether
spec §13.2 lists the package (it was amended for D1/D2). The root
`pubspec.yaml` only declares the workspace and has no dependencies. In the
apps every constraint is a caret on the locked version, except `auto_route`
and `lottie` (exact pins) and `intl` (`any`). In core and tools, `lints: ^6.0.0` and
`test: ^1.25.6` are lower floors than the locked versions.

The design foundation round (2026-09-26) added `flutter_svg`, `xml`,
`flutter_soloud` and the `tools` member (`nesty_tools`). Their new transitive
lock entries are `http` 1.6.0, `path_parsing` 1.1.0, `petitparser` 7.0.2,
`vector_graphics` 1.2.3, `vector_graphics_codec` 1.1.13 and
`vector_graphics_compiler` 1.3.0. The fonts are not packages: they are built
by `tools/fonts/build_fonts.sh` from pinned upstream commits with fontTools
4.60.1 in a throwaway venv (never a project dependency).

The M2 Lottie contracts (2026-09-26, D41) added `lottie` to the game. Its
new transitive lock entries are `archive` 4.3.0 and `posix` 6.5.2; no locked
version changed. `flame_lottie` was evaluated and not added.

The M2 integration (2026-09-26, D57) added `integration_test` and
`flutter_driver` (SDK) as game dev dependencies. Their new lock entries are
`process` 5.0.6, `sync_http` 0.3.1 and `webdriver` 3.2.0, plus the SDK's
`flutter_driver`, `fuchsia_remote_debug_protocol` and `integration_test`; no
locked version changed.

The post-M2 round (2026-09-27, D59–D61) added no package and changed no
locked version (`flutter pub get --enforce-lockfile` passes). The music and
jingles use `flutter_soloud`'s OGG Vorbis decoder, and the iOS audio session
is set in `AppDelegate.swift` with AVFoundation, so no `audio_session`
package was needed (Q61).

The M3 contracts stage (2026-09-27, D80) added `package_info_plus` and
`url_launcher` to the game. Their new lock entries are `package_info_plus`
10.2.1, `package_info_plus_platform_interface` 4.1.0, `url_launcher` 6.3.2
and its platform packages (android 6.3.30, ios 6.4.2, linux 3.2.3, macos
3.2.6, platform_interface 2.3.2, web 2.4.3, windows 3.1.6), `win32` 6.4.0,
`ffi_leak_tracker` 0.1.2 and the SDK's `flutter_web_plugins`; no locked
version changed and the path dependencies are untouched. Both are the
newest releases that resolve on Flutter 3.41.2 (package_info_plus 10.2.1
needs Flutter 3.38.1, url_launcher 6.3.2 Flutter 3.27); `url_launcher_android`
stays at 6.3.30 because 6.3.31+ need Flutter 3.44 / Dart 3.12. Removing
`hive_ce_generator` also dropped `yaml_writer` 2.1.0. iOS picks up the two
new pods at the next `pod install`.

The M7 phase-3 contracts stage (2026-09-29, D154) added `share_plus`,
`flutter_local_notifications`, `timezone` and `flutter_timezone` to the
game. Their new lock entries are `share_plus` 13.3.0,
`share_plus_platform_interface` 7.2.0, `cross_file` 0.3.5+5, `uuid` 4.6.0,
`flutter_local_notifications` 22.3.1 and its platform packages (linux
8.0.1, platform_interface 12.2.0, web 1.0.0, windows 3.1.1), `dbus`
0.7.15, `timezone` 0.11.1, `flutter_timezone` 5.1.0 and `equatable` 2.1.0;
no locked version changed. share_plus 13 is the line that accepts the
locked `win32` 6.4.0 (11.x and 12.x need ^5.5.3) and needs AGP 8.12.1, so
`android/settings.gradle.kts` moved from 8.11.1; flutter_local_notifications
needs core-library desugaring (`desugar_jdk_libs` 2.1.4 in
`android/app/build.gradle.kts`) and compileSdk 36, which is Flutter
3.41.2's. None is in spec §13.2, and none needs a network. iOS picked
up three pods at the smoke build's `pod install`.

The 5B stage (2026-10-02, D262) added two fonts and one dev dependency; none
changes `pubspec.lock`:
- **Baloo 2** (SIL OFL 1.1, google/fonts `ofl/baloo2` at the existing pin):
  Devanagari for Hindi. It is the rounded face tokens v4 `font.scripts.deva`
  names, and it is bundled because the game is offline-first. Subset to the
  Devanagari block, about 275 KB a file; five files (two display, three body).
- **M PLUS Rounded 1c** (SIL OFL 1.1, google/fonts `ofl/mplusrounded1c`):
  kana and kanji for Japanese, the face `font.scripts.jpan` names. Subset to
  kana, punctuation, full-width forms and the copy's kanji; four files.
  Together the nine script files are 2,233,548 B (budget 2.5 MB).
- **`intl` in `tools`** (dev tool only, not shipped, 0.20.2, already in the
  workspace graph): `gen_font_subsets` needs its ja and hi date strings
  (`DateFormat.EEEE`, `MMMd`) to know which kanji the Japanese subset must
  keep.

### Runtime dependencies

| Package | Locked | Used in | Why | §13.2 |
|---|---|---|---|---|
| `flutter` (SDK) | — | render, game, admin | UI framework. In `nesty_render`: `Color`, `Canvas`, `Rect`, `@immutable` for the palette and renderer interface. `nesty_render` declares `flutter: ">=3.41.0"`, kept at or below the CI pin (D15) | — |
| `flutter_localizations` (SDK) | — | game, admin | ARB localization delegates (spec §16) | yes |
| `intl` | 0.20.2 | game, admin | Required by the `gen-l10n` output. Constraint `any` because `flutter_localizations` pins the version | yes |
| `flame` | 1.38.2 | game | `NestyGame` (`FlameGame`), `BoardComponent`, `GameWidget` on the gameplay page | yes |
| `flutter_bloc` | 9.1.1 | game, admin | Cubit-first state management (D1): `BaseAsyncCubit`/`BaseAsyncBloc`, `BlocProvider`/`BlocBuilder`/`BlocListener` | yes |
| `bloc` | 9.2.1 | game, admin | Core Cubit/Bloc types, imported directly by the app-lifetime `LanguageCubit` and `SessionCubit` | yes |
| `get_it` | 9.3.0 | game, admin | Service locator (`final get = GetIt.instance`) | yes |
| `injectable` | 3.0.0 | game, admin | DI annotations: `real`/`fake` environments, `@preResolve` (Hive), `@disposeMethod` | yes |
| `auto_route` | 11.1.0 (pinned exactly) | game, admin | Routing (D1): `AppRouter`, `@RoutePage` pages, `AutoRouteWrapper`. Admin: guards, `AutoTabsRouter` shell, nested Levels stack. **Why the exact pin:** 11.2.0 calls `Viewport(scrollCacheExtent:)`, which Flutter 3.41.2 doesn't have (B1). Revisit when the SDK is upgraded (Q23) | yes |
| `freezed_annotation` | 3.1.0 | game, admin | `@freezed` on `AsyncValue` and the states (`LanguageState`, `SplashState`, `HomeState`, `SessionState`, `AdminUser`) | yes |
| `json_annotation` | 4.12.0 | game, admin | **Not used yet.** Declared for app-side JSON DTOs from M3–M5 (Firestore document wrappers §5.2/§14.1, cache files). Level JSON itself is never parsed here: it goes through `nesty_core`'s `LevelCodec` (rule 2). Remove it if M5 ends without a use | yes |
| `hive_ce` | 2.20.0 | game | Local database (D2): the `settings` box in `HiveDatabaseService`, and pure-Dart `Hive.init` in round-trip tests | yes |
| `hive_ce_flutter` | 2.3.4 | game | `Hive.initFlutter` in the app documents directory. Brings `path_provider` (§13.2) in transitively | yes |
| `nesty_core` (path) | 0.1.0 | render, game, admin, tools | The single rule implementation (rule 2). `nesty_render` keys its palette, renderer API and generated `DollColorTokens` on `DollColor`. `tools` uses it to cross-check the tokens' doll colors (and for the M1–M2 level CLIs). The game imports it since M2 (the bloc's `GameSession`, the board, the bundled repository, the solver isolate); the admin declares it but doesn't import it yet | — |
| `nesty_render` (path) | 0.1.0 | game, admin, tools | Shared doll rendering and layout math. The game imports it from `lib/` since M2 (layout, part rasters, the rest renderer, sprites, backgrounds); the admin doesn't yet. `tools` imports only the Flutter-free `package:nesty_render/svg_tools.dart` (the asset sync's validator; `svg_tools_purity_test.dart` keeps it free of `dart:ui`) | — |
| `flutter_svg` | 2.3.0 | render | Spec §12.2: turns the layered skin, board and theme SVGs into `ui.Image` rasters once per size (Phase 3 skin rasterizer, board sprites, theme background; rule 8). For now only `bundled_svg_render_test.dart` uses it: flutter_svg compiles all 39 shipped SVGs with no warnings. Added in the design foundation round (2026-09-26) | yes |
| `xml` | 7.0.1 | render, tools | Flutter-free SVG parsing in `package:nesty_render/svg_tools.dart`: the spec §12.2 validator and metadata strip now, the skin layer splitter in Phase 3, and the admin upload check in M5. 7.0.1 is the newest that `vector_graphics_compiler` (via flutter_svg) accepts (`<=7.0.1`). `tools` declares it too (the plan listed it) but uses it only through `svg_tools.dart` so far | yes |
| `flutter_soloud` | 4.1.7 | game | Spec §11.3: low-latency SFX with per-play playback speed, needed for the per-size clack pitch (D19) and the combo chimes. Imported by `SoLoudBackend` (`core/services/audio/soloud_backend.dart`), the one seam both `SfxEngine` (the SFX and jingles, since M2 phase 4) and `SoLoudMusicService` (since the post-M2 round) go through; `SoLoudEngineHost` starts and stops the engine. Since D61 it also decodes the OGG Vorbis music (streamed with `loadMem(..., LoadMode.disk)`) and jingles with its bundled Ogg/Vorbis libraries, so **`NO_XIPH_LIBS` must never be set** in the Android or iOS build. **Why 4.x, not 5.x:** 5.x needs `native_toolchain_c` ^0.19.4, which needs `meta` ^1.19, but Flutter 3.41.2 pins `meta` 1.17.0. 4.1.7 is a classic FFI plugin (CMake on Android; podspec plus CMake on iOS), and the dev APK and iOS builds both link it. Upgrade with the SDK (Q23, BACKLOG "Later") | yes |
| `lottie` | 3.6.1 (pinned exactly) | game | **Owner decision (D40): every animation in the design ships as Lottie** (29 files). A pure-Dart Lottie player: board clips through our `LottieFxComponent` over `LottieDrawable`, the HUD, overlays and screens through `LottieFxView` (m2-lottie-design §2). **Why 3.6.1:** the newest release that resolves on Flutter 3.41.2 / Dart 3.11 (3.4.0–3.5.1 need Flutter 3.44; 3.6.0 is retracted). **Why the exact pin:** the export workarounds depend on its internals (image layers drawn at bitmap size, the travel-hold callback skip, the swapped progress fields for point values), and the equivalence tests pin them (D43). It brings `archive` 4.3.0 and `posix` 6.5.2 transitively. No `flame_lottie` (D41) | — |
| `path` | 1.9.1 | tools | Repo-relative path handling in the `nesty_tools` CLIs. Already in the lock transitively | — |
| `package_info_plus` | 10.2.1 | game | The Settings footer's "v1.0.0 (build 42)" (frame 8.1, spec §10.2 #13), behind `AppInfoService` so tests and the fake env never call the platform. Added by the M3 contracts stage (D80); the newest release on Flutter 3.41.2 | — |
| `url_launcher` | 6.3.2 | game | Settings' Privacy Policy link and Support email (frame 8.1, spec §9.3, §10.2 #13, §17), behind `LinkLauncher`. `launchUrl` only, never `canLaunchUrl`, so no Android `<queries>` or iOS `LSApplicationQueriesSchemes` entries are needed. Added by the M3 contracts stage (D80); `url_launcher_android` resolves to 6.3.30 (6.3.31+ need Flutter 3.44) | — |
| `share_plus` | 13.3.0 | game | E3, the daily share card (spec-prop §10.2 #11, D92): the OS share sheet for the Daily screen's spoiler-free text, behind `ShareService` (`SharePlusShareService`; plain text, no file or link until M8). 13.x is the line that accepts the locked `win32` 6.4.0; it needs AGP ≥ 8.12.1. Added by the M7 phase-3 contracts stage (D154) | — |
| `flutter_local_notifications` | 22.3.1 | game | E4, the opt-in daily reminder (spec-prop §7.9, §1.1 rule 7, D92): one local, offline, inexact repeating notification a day, behind `NotificationService` (`LocalNotificationService`); the permission is asked only after the player's Yes. Min API 24 (spec §0), compileSdk 36, core-library desugaring. Added by the M7 phase-3 contracts stage (D154) | — |
| `timezone` | 0.11.1 | game | The reminder's `zonedSchedule` takes a `TZDateTime` in the device's zone; flutter_local_notifications 22 needs ≥ 0.11.0; the `latest_10y` data. Pure Dart. Added by the M7 phase-3 contracts stage (D154) | — |
| `flutter_timezone` | 5.1.0 | game | The device's IANA zone for `tz.local`, so the reminder keeps its local time across DST (a fixed offset would drift by an hour). Added by the M7 phase-3 contracts stage (D154) | — |

### Dev dependencies

| Package | Locked | Used in | Why | §13.2 |
|---|---|---|---|---|
| `test` | 1.29.0 | core, tools | Unit tests and the architecture guard; the `nesty_tools` codegen, sync and TODO-index tests | — |
| `lints` | 6.1.0 | core, tools | Base lint set for the pure-Dart members' strict `analysis_options.yaml` | — |
| `flutter_test` (SDK) | — | render, game, admin | Widget and unit tests | — |
| `flutter_lints` | 6.0.0 | render, game, admin | Base lint set for the Flutter members | — |
| `build_runner` | 2.15.1 | game, admin | Runs the freezed, injectable, auto_route and hive_ce generators | yes |
| `freezed` | 3.2.5 | game, admin | Generates `*.freezed.dart` | yes |
| `json_serializable` | 6.14.1 | game, admin | **Not used yet**, the pair of `json_annotation` above | yes |
| `injectable_generator` | 3.0.2 | game, admin | Generates `di.config.dart` | yes |
| `auto_route_generator` | 10.5.0 | game, admin | Generates `app_router.gr.dart`. Its output is byte-identical under auto_route 11.1.0 and compiles against it (B1) | yes |
| ~~`hive_ce_generator`~~ | — | — | **Removed 2026-09-27 (D80).** It generated nothing: settings are primitives and the save is one JSON document (D63, D67), so no type needs a Hive adapter. Add it back with the first `@GenerateAdapters` type | yes |
| `bloc_test` | 10.0.0 | game, admin | `blocTest` for the base cubit/bloc, `LanguageCubit`, `SplashCubit`, `HomeCubit`, `LoginCubit`, `SessionCubit` | yes |
| `mocktail` | 1.0.5 | game, admin | Mocks for failure paths the fakes don't cover (a failing `SaveService`, `DatabaseService` or `AuthService.signOut`) | yes |
| `integration_test` (SDK) | — | game | The on-device playthrough `integration_test/playthrough_test.dart` (D57): the integration binding and `takeScreenshot`. Its iOS pod is linked in every configuration, and only registered in debug (BACKLOG "Tech debt") | — |
| `flutter_driver` (SDK) | — | game | The host side of `flutter drive`: `test_driver/integration_test.dart` runs `integrationDriver` and saves the screenshots (D57). It brings `process`, `sync_http`, `webdriver` and the SDK's `fuchsia_remote_debug_protocol` into the lock | — |

The m7-5 import (2026-10-07, D291) added no package and changed no locked
version. It bundles one font family, `Baloo2LatnTr` (Baloo 2 v1.700, three
static instances at wght 500, 600 and 700, 58 KB each, subset to
`tools/fonts/subset/tr.txt`), cut by `tools/fonts/build_fonts.sh` from the same
pinned `Baloo2[wght].ttf` and under the same OFL (`Baloo2-OFL.txt` already
ships) as the Hindi face. Fredoka lacks five Turkish letters (spec §13.2
lists no font; preferred: yes, as the existing Baloo 2 faces).

The local habits' stage 4 (2026-10-08, D312) adds no Dart package (D299:
`home_widget` was researched and not taken). It adds one test-only Gradle
dependency: `junit:junit:4.13.2` (`testImplementation` in
`apps/game/android/app/build.gradle.kts`) for the widget's Kotlin JVM tests
(`WidgetTimelineTest`, `WidgetJsonTest`, `WidgetFitTest`). It is never
shipped. No Robolectric. The iOS widget extension has no pods.

## Open questions

Owner decisions come first. Each one names the spec section or milestone it
blocks. Resolved questions stay here, checked, so their numbers are never
reused.

- [x] **Q1. B1: pin `auto_route: 11.1.0` or upgrade Flutter?** Resolved
  2026-09-26: pinned exactly in both apps (B1, D12). An SDK upgrade is Q23.
- [x] **Q2. Approve the CLAUDE.md update.** Resolved 2026-09-26: CLAUDE.md
  was updated. The owner approved it when choosing the aquabuildr stack,
  whose option text said CLAUDE.md rule 10 and spec §13 would be updated.
  The update covers:
  - rule 10 (Cubit-first `flutter_bloc`, `get_it` + `injectable`);
  - the flavored Commands, with no FVM;
  - a Conventions section;
  - the extended layout;
  - a Git section;
  - the rule that `design/` is owner-only.

  Later that day the docs pass corrected one fact in it, the Flutter version
  in Commands ("3.43+" → 3.41.2, D15).
- [x] **Q3. Where does the M3 save document live (spec §13.3)?** In a Hive
  box, or in the spec's atomic JSON file (temp file + rename, schema version,
  migrations)? Today Hive holds only device settings. §13.3 is deliberately
  unchanged until this is decided.
  **Resolved 2026-09-27 (owner): a Hive box via `DatabaseService`, with a
  schema version and migrations** (D63).
- [x] **Q4. What is the settings `symbols` value for large symbols?** §13.3
  shows only `"subtle"`. The large mode is "assist mode" in §10.2, §12.3 and
  §16, and "Large" in DESIGN_BRIEF Prompt 9. The skeleton persists
  `"assist"`. Resolved 2026-09-26: `large`, the handoff's decision the owner
  accepted (D19). A stored `assist` is read as `large`. The rename is built in
  M2 (BACKLOG).
- [x] **Q5. Is `reward_medium` missing from spec §9.4?** §7.3 pays easy and
  medium 10 each, but §9.4 has only `reward_easy`, `reward_hard` and
  `reward_superhard`. Should medium read `reward_easy` (M3), or should a
  `reward_medium` key be added?
  **Resolved 2026-09-27 (owner): add `reward_medium`, default 10** (D64).
- [ ] **Q6. Deep links in the admin after the first sign-in (M5).** Should
  the admin return to the originally requested link (for example a shared
  `/levels/L0024`)? Today it lands on the Dashboard.
- [ ] **Q7. Hash URLs (`/#/levels`) or path URLs (`/levels`) for the admin
  (M5)?** Path URLs need `flutter_web_plugins` (an SDK package, with a reason
  recorded here) and a Firebase Hosting SPA rewrite.
- [ ] **Q8. Extract the duplicated base layer (D6) into a shared package,
  such as `packages/nesty_app_core`?** The error kinds differ per app, so
  the package would need a strategy for them.
- [x] **Q9. Web-safe solver hashing (M1, spec §6.2).** In the browser a
  Dart `int` is a JS number: exact to 2^53, with 32-bit bitwise operators.
  The 64-bit canonical hash therefore needs a web-safe design, such as two
  32-bit halves or `fixnum`. `fixnum` is already in the lock transitively; a
  direct dependency would need a reason recorded here. Resolved 2026-09-26:
  `Hash64` is two MurmurHash3_x86_32 halves in web-safe u32 arithmetic, no
  `fixnum` (D28); parity holds on the VM, node, Chrome and dart2wasm, and CI
  runs the web half (D39).
- [ ] **Q10. Confirm the bundle id `com.futrix.nesty` (and `.dev`, `.stg`)
  before any store upload.** It can't change after publishing.
- [ ] **Q11. Is `DEVELOPMENT_TEAM` `Z674BG8G6U` the right Apple team?** It
  came from `flutter create` on this machine.
- [ ] **Q12. How many Firebase projects: one per flavor or fewer?**
  `firebase/.firebaserc.example` assumes three (dev, stg, prod), and
  `flutterfire configure` then produces `firebase_options_<flavor>.dart` plus
  per-flavor `google-services.json` / `GoogleService-Info.plist`. The owner
  runs it (M4).
- [x] **Q13. CI Flutter version vs local.** Resolved 2026-09-26. CI pins
  `FLUTTER_VERSION: "3.41.2"`, the published stable the local SDK is built
  on. nesty_render's floor was relaxed to `>=3.41.0`, and every job runs
  `pub get --enforce-lockfile` (D15). Whether to upgrade is Q23.
- [x] **Q14. Fonts.** DESIGN_BRIEF names Fredoka (display) and Nunito (body).
  They must be bundled as assets, not fetched at runtime with `google_fonts`
  (offline first launch, rule 3). Will the owner supply the font files with
  `design/`, or may they be added from the OFL releases? Resolved 2026-09-26:
  they are bundled as assets and sourced by tooling. The handoff ships no font
  files (D18), so the tooling adds the static Fredoka 500/600/700 and Nunito
  500–800 TTFs from google/fonts at a pinned commit, with OFL.txt, and the
  licenses are registered at startup (BACKLOG "Design foundation").
- [x] **Q15. The `design/` exports are missing.** Resolved 2026-09-26: the
  design handoff was delivered and is in `design/` (D18, commit 3a8dfca). Its
  screens are HTML prototypes in `design/prototypes/`, not PNGs. The admin
  designs are still missing (BACKLOG "Owner inputs needed"). The original
  question said these were needed:
  - `design/tokens.json`, which replaces the placeholder `AppColors`, the
    gold gradient and the doll ink/light shades;
  - the screens (game and admin);
  - `design/symbols/`;
  - the Classic skin SVG.

  Everything visual is `TODO(design)` until then.
- [ ] **Q16. iPad orientation.** iPad allows Portrait and PortraitUpsideDown,
  iPhone and Android allow portrait only. Should iPad be upright-only?
  Separately, `UIRequiresFullScreen` is deprecated in iPadOS 26 and should be
  rechecked in M7/M8.
- [ ] **Q17. Should dev and stg builds get distinct app icons and a
  `versionNameSuffix` (M8)?** Icons need design assets.
- [x] **Q18. Can hidden tower nests show their size but not their color
  (spec §3.2)?** `DollRenderer` has a `silhouette` flag that ignores color.
  The paint-splash reveal (§11.1) is assumed to be composed by the caller.
  Confirm in M2. Resolved 2026-09-26: yes. Buried nests are wood silhouettes
  at their true size with the color hidden, following spec §3.2 rather than
  the design (D21). In the plan, the reveal wipe is a `DollRenderer` paint
  option driven by the board timeline.
- [x] **Q19. Where does a solvable fixture record its expected optimal move
  count (M1)?** The suggestion is to keep fixture files as pure §5.1 level
  JSON and put the expectations in the test. Resolved 2026-09-26: the
  fixtures stay pure §5.1 JSON, and the expectations are consts in
  `packages/nesty_core/test/solver/fixture_expectations.dart`
  (`test/fixtures/README.md`).
- [ ] **Q20. Tighten the spec §14.3 rules sketch for M5?** Both rules files
  keep the sketch's semantics. A one-off emulator check on 2026-09-26
  confirmed these gaps (details in `firebase/README.md`):
  - (a) The `firestore.rules` catch-all also matches `admins/{uid}`.
    Firestore ORs overlapping matches, so an existing admin can create or
    edit `admins/*` despite `allow write: if false`.
  - (b) The catch-all read has no `status` check, so draft `chapters`,
    `skins` and `themes` are publicly readable and listable, unlike draft
    levels.
  - (c) `dailyOverrides` for future dates are readable ahead of their date.
  - (d) Storage uploads have no size or content-type limits.

  Separately, the Storage admin check reads Firestore. The first
  `firebase deploy --only storage` must grant that access, or admin uploads
  fail.
- [ ] **Q21. Admin `web/manifest.json` still has the template's
  `portrait-primary` orientation and `#0175C2` colors.** For a desktop tool
  the orientation should probably go, and the colors should come from tokens
  once `design/` exists.
- [x] **Q22. No VS Code admin config passes
  `--dart-define=NESTY_FAKE_SERVICES=true`.** Resolved 2026-09-26: "Admin
  [DEV] (Chrome, fake services)" was added. The dev/stg/prod admin configs
  stay on real services, so they stop at Login until M5.
- [ ] **Q23. Stay on Flutter 3.41.2, or upgrade local and CI?**
  - **Upgrading** to a newer stable (3.44.x or 3.47.x) means bumping
    `FLUTTER_VERSION` in `ci.yaml` and committing the re-resolved lock in
    the same change. On 3.44.9, 5 test packages change (D15). It would also
    let auto_route move past the 11.1.0 pin (B1).
  - **The stray local commit:** should `~/development/flutter` drop its
    local "wip" commit (`5408e0f`, on top of the 3.41.2 tag, touching only
    the SDK's `pubspec.lock`)? Then it reports its real version, and the
    three `.metadata` files and future `flutter create` output stop
    recording a revision that doesn't exist upstream.
- [ ] **Q24. Relax the `rm -rf` deny globs in `.claude/settings.json`?**
  - `Bash(rm -rf /*)`, `Bash(rm -rf ~*)` and `Bash(rm -rf $HOME*)` deny
    every `rm -rf` of an absolute or home path, not only the root or home
    directory. That includes cleaning `apps/game/build` by its absolute
    path.
  - The proposal is to move them to `ask`, keeping exact denies for
    `rm -rf ~`, `~/`, `$HOME` and `$HOME/`.
  - This changes permission settings, so only the owner can decide it.
- [ ] **Q25. Should CLAUDE.md rule 10 name the D14 exception?** For
  example: "Async feature cubits extend `BaseAsyncCubit<T>` … (app-lifetime
  store mirrors excepted, see `.claude/rules/bloc-cubit.md`)". CLAUDE.md is
  the owner's file.
- [ ] **Q26. Use the same error-key names in both apps?** The game's
  generic failure key is `genericLoadFailed`, and the admin's is
  `errorGeneric`. Renaming it is an ARB edit plus gen-l10n. This is
  optional and a matter of style.
- [ ] **Q27. Commit the Gradle wrapper?** The root `.gitignore` no longer
  ignores `gradlew`, `gradlew.bat` and `gradle-wrapper.jar`, but the Flutter
  template's `apps/game/android/.gitignore` still does. Flutter recreates
  them on build, and a clean checkout builds fine.
  `gradle-wrapper.properties` is tracked either way.
- [ ] **Q28. Should the app title players see be localized?**
  `MaterialApp.title` comes from `FlavorValues.appTitle`, a hard-coded
  string in each `main_<flavor>.dart`: `'Nesty: Doll Sort'` in the game's
  prod entry point and `'Nesty Admin'` in the admin's (D8).
  - It shows in Android Recents and in the browser tab. In prod, Recents
    says "Nesty: Doll Sort" while the splash (ARB `appName`) and the
    launcher say "Nesty".
  - The option is `onGenerateTitle` with an ARB key, keeping only the
    `[DEV] `/`[STG] ` prefix in `FlavorValues`.
  - Or it can stay as a deliberately unlocalized brand name.
  - This was the review's one uncertain finding.
- [ ] **Q29. How should coins and counters get tabular figures (M2)?** The
  design says "Use tabular figures for coins and counters" (tokens.json
  `fontSize.number.tabular`), and numbers use Fredoka. But Fredoka's digits
  are proportional (advances 379–566 units) and it has no `tnum` feature, so
  `FontFeature.tabularFigures()` has no effect. Nunito's digits are already
  fixed-width. The options:
  - a fixed-width digit layout widget (simplest, no font change);
  - Nunito for numbers (changes the look);
  - a patched "Fredoka Tabular" built by `build_fonts.sh` (the OFL allows it
    under a new name).

- [x] **Q30. How should the towerless levels L3–L15 be graded (D26)?**
  Applied default (a): an open-slot-only board keeps its §6.6 tier (badge and
  coins) with a `tierOverride` reason. The alternatives: (b) declare them
  easy and relax the §6.6 pattern check for towerless boards (L6 and L10
  then pay easy coins and lose their badges); (c) introduce towers before
  L16, against §3.7.
  Resolved 2026-09-26: owner-confirmed default (a). Open-slot-only boards
  keep their §6.6 tier (badge and coins) with a `tierOverride` (D26, D52).
- [x] **Q31. What does the game do with an expert-only generated level
  (spec §6.4, D33)?** Bonus 40 (superhard, smart 0/300) and bonus 99 (medium,
  smart 142/300) of bonus levels 1–100 are expert only, and no admin reviews
  device-generated levels. Options: (a) the generator treats expert only as
  a tier miss and keeps looking (a `Generator.version` bump and new goldens);
  (b) the app shows the flag, which `GeneratorSuccess.simulation.expertOnly`
  already carries; (c) the §6.4 flag applies only to admin-authored levels.
  Decide before M3's Bonus Endless and daily.
  Resolved 2026-09-26: the owner confirmed the recorded default. The
  generator keeps returning an expert-only level with
  `simulation.expertOnly` set (D33). What the app shows for one is settled
  when Bonus Endless is built (M3, BACKLOG).
- [x] **Q32. Relax the exhaustive-search targets (design §5)?** An
  exhaustive 435,588-node proof takes 2.28 s on the VM (target 2 s) at
  191–289k nodes/s (target 300k); budget-limited searches, hints (35–38 ms)
  and soft-stuck checks (20–22 ms) are well inside. The admin steps the
  search, so the page never blocks. Proposed: "admin 500k ≤ 3 s VM worst
  case". The next levers are hashing only the changed key words and a
  count-only kernel routine.
  Resolved 2026-09-26: owner-confirmed. The relaxed target "admin 500k ≤ 3 s
  VM worst case" stands; the speed levers stay in BACKLOG "Later".
- [x] **Q33. Cap the admin generator's params, or scale the admin budget by
  board size (design §5 heap ≤ 64 MB)?** The widest board
  `Generator.checkParams` accepts (4×5, 17 depth-4 towers, 72 cells) holds
  72.3 MiB of typed lists at 500k nodes (80.3 MB peak), about 152 B/node.
  Typical boards stay at 86–125 B/node, 37–44 MB. No curve row comes near.
  Resolved 2026-09-26: owner-confirmed as built. No cap and no budget
  scaling for now; no curve row comes near the limit. The M5 admin generator
  re-checks it (BACKLOG M5).
- [x] **Q34. Confirm the default difficulty curve (design A16, D33) before
  M3.** Every row has one set per color and 1 empty slot unless noted; S =
  shelves × slots, T = towers × depth:

  | Levels | Easy | Medium | Hard | Superhard |
  |---|---|---|---|---|
  | 1 (all tiers) | 1 color, size 3, 2×3, empty 3 | same | same | same |
  | 2 (all tiers) | 2 colors, size 3, 2×3, empty 2 | same | same | same |
  | 3–9 | 3 colors, size 3, 2×4, empty 2 | 3 colors, size 3, 3×3, empty 2 | 4 colors, size 3, 3×3 | 4 colors, size 3, 3×4, empty 2 |
  | 10–15 | 3 colors, size 4, 3×3, empty 2 | 4 colors, size 4, 3×3 | 4 colors, size 4, 3×4, empty 2 | 5 colors, size 4, 3×4 |
  | 16–30 | 5 colors, 3×3, T 4×3 | 6 colors, 3×3, T 5×4 | 7 colors, 3×3, T 6×4 | 8 colors, 3×3, T 7×4 |
  | 31–50 | 6 colors, 3×3, T 4×3, 1 lock | 5 colors, 2×4, T 4×4, 1 lock | 6 colors, 3×3, T 5×4, 1 lock | 6 colors, 2×4, T 5×4, 1 lock |
  | 51–70 | 6 colors, T 4×3, 1 ice | 6 colors, T 5×3, 1 lock, 1 ice | 7 colors, T 5×4, 1 lock, 1 ice | 7 colors, T 6×4, 1 ice |
  | 71–120 | 6 colors, size 5, T 4×3, 1 lock, 1 ice | 6 colors, size 5, T 4×4, 1 lock | 6 colors, size 5, T 5×4, 1 ice | 6 colors, size 5, T 7×4 |
  | 121+ | as 71–120 | as 71–120 | as 71–120 | 6 colors, size 6, T 7×4 |

  Also: `bonusParams` takes the global play order (not the "Bonus Level N"
  count); the daily is medium on weekdays and hard on weekends on the 31–50
  boards; levels 1–15 can only reach easy (D26), so the generator returns the
  closest tier there. Any change alters generated levels and needs a
  `Generator.version` bump.
  Resolved 2026-09-26: owner-confirmed. The default curve table (A16) is the
  curve. BACKLOG M3 drops its `TODO(M3)`; any later change still needs a
  `Generator.version` bump.
- [x] **Q35. Confirm the recorded M1 defaults (design A-list and the build
  steps' readings).** Each is implemented, tested and changeable:
  - A3 fallback step 3: the first non-pointless placement, then the first
    placement; a hint on a won state returns no move (`none`, `solved`).
  - A17 smart bot: the lookahead drops moves to boards with no non-pointless
    move; "doesn't fill the last empty slot" counts empty, open-like,
    interactable slots (iced ones don't); "most merges after" counts ordered
    moves; when every candidate is dead the best-ranked is still played.
  - The default simulation seed hashes the board only (D32).
  - Rejection precedence (D27); `targetOccupied` unreachable.
  - `restart()` keeps `undosUsed` and the extra slots.
  - `solver.unproven` without a solver is an error; `generatorVersion` ≥ 1;
    rule 6 applied per lock, literally.
  - The engine lays out up to 28 authored slots (the validator's limit is 22).
  - Generator readings: the lock wait-cycle rule, no ice on a lock, the best
    deal kept after 20, invalid daily dates rejected.
  - Freeze the PRNG (D28), simulator (D32) and generator (D33) definitions
    under `Generator.version` 1 before M3 ships dailies.
  Resolved 2026-09-26: owner-confirmed. Every listed default stands. The
  PRNG, simulator and generator definitions are frozen under
  `Generator.version` 1 before M3 ships dailies (BACKLOG M3).
- [x] **Q36. Bundle policy (D34).** Should an expert-only bundled level fail
  CI rather than warn? Are the tutorials (L1–L2) plus open-slot boards the
  right set for `tierOverride`, or should intro levels (L16, L31, L51) be
  allowed? Keep the M2 layout limits (2–3 shelves, ≤ 4 slots) for every
  bundled level, or only for 1–30? May bundle entries start at `version` 0?
  Should unknown top-level bundle keys be ignored for forward compatibility?
  Resolved 2026-09-26: owner-confirmed as built. An expert-only bundled
  level warns. `tierOverride` covers the tutorials and open-slot boards. The
  M2 layout limits apply to every bundled level, bundle entries start at
  `version` 1, and unknown top-level keys stay errors. Revisit when bundling
  moves to a Firestore export (BACKLOG M5).
- [x] **Q37. Authored levels (D35).** Is L16's 4,3 board with two depth-4
  towers right for the tower intro (the design's 4,3,3 TOWER16 board is L18,
  easy)? The easy tower levels all simulate 100 % casual; should easy aim
  for 70–95 %? Check L6 (HARD) and L10 (SUPER HARD) in the M2 playtest.
  Resolved 2026-09-26: owner-confirmed. The authored levels stand as built
  (D35). L6 and L10 are still checked in the M2 playtest (BACKLOG M2).
- [x] **Q38. Render defaults (D36–D38).** The doll clamp gap 8/3 dp; a buried
  nest two or more sizes smaller than the top stays hidden behind it at 18 dp
  per depth; pips on an occupied extra slot; the 4-shelf preset scaling every
  piece by 104/150 (and a top-row tower's maxSize-6 doll standing 2 dp into
  the HUD there); the shine sweep crossing the doll over the full 300 ms
  (the prototype's CSS crosses in the middle ~40 %); the placeholder's look;
  both symbol sizes per atlas page; chapters 7+ cycling ch01–ch06; the
  theme's swap-on-ready; lazy glass frames 1–2; sprite fit as
  `preserveAspectRatio` meet.
  Resolved 2026-09-26: owner-confirmed. Every listed render default stands
  (D36–D38).
- [x] **Q39. A tap on an unpickable slot with nothing selected (M2).** An
  empty, locked or iced slot tapped with no nest lifted is ignored today
  (`TODO(design)` in `tap_policy.dart`; frame 2.6 doesn't cover it). Should it
  shake the slot like an invalid move?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): a tap on an unpickable slot never shakes: an empty stand dips, a sealed case pings its padlock, an iced slot bumps its ice counter (frame 12.13); D185.**
- [ ] **Q40. Dragging another nest while one is tap-lifted (M2, D55).** The
  drag start switches the selection (the drag reads as an explicit pick),
  while a tap there is an invalid move (D22). Keep that, or make the drag
  start invalid too?
- [ ] **Q41. The soft-stuck re-check (M2, D55).** It runs after an undo and
  after +1 Slot as well as after moves, so the banner stays right when an undo
  lands on another stuck board. The contract said "after each applied move".
  OK?
- [ ] **Q42. `booster_use` sources (M2, §14.4).** The spec allows `free`,
  `coins` and `ad`; M2 logs every inventory use as `free`. Should an inventory
  use have its own source?
- [ ] **Q43. Skipped bundled levels (M2, §5.3, D54).** An invalid bundled
  level makes `entryAt(itsOrder)` return the next playable one, and
  `levelCount` is the last available order. Is that the intended reading of
  "skipped with a log entry"?
- [ ] **Q44. Undos in the dev flavor (M2).** Boosters never run out there
  (`unlimitedBoosters`), and the bloc makes undos unlimited too (`canUndo`
  ignores the free-undo count), so the out-of-moves sheet shows no "Free · N
  left" chip. Is unlimited undo intended in dev?
- [ ] **Q45. Sound effects when the app goes to the background (M2, D54).**
  Voices pause and resume on return. Cut short one-shots instead?
- [ ] **Q46. Starting coins (M3, §7.3).** A fresh install starts with 0 coins;
  the spec gives no starting balance.
- [ ] **Q47. Figurine names and empty fallbacks (M3).** The design names only
  the Classic, Sailor and Baker Families. Should 4–10 be "The <Name> Family"?
  `figurineName`, `tierName` and `chapterName` return '' for an unknown id,
  and the win card then hides "Next up".
- [ ] **Q48. When a button's sound and haptic fire (M2).** On activation (a
  tap, or the screen reader's action), so a drag off the button stays
  silent; not on touch-down. OK?
- [ ] **Q49. Continue on the win overlay (M2, frame 2.11, D56).** It loads the
  next level inside the same page (`NextLevelPressed`), keeping the Flame game
  alive with no route transition, where the earlier M2 design replaced the
  route. Is that the intended flow?
- [ ] **Q50. The chapter ribbon's look (M2, frame 4.7).** The game follows the
  Lottie file's one-line ribbon ("CHAPTER 2 · Rainy Café Corner",
  m2-lottie-design §12), not NestyBoard's two-line blue card. Confirm the
  Lottie look wins.
- [ ] **Q51. M3 entries shown disabled (M2).** Home's settings gear and
  Pause's Settings tile are greyed out until M3, while the design draws them
  enabled. Keep them disabled, or enabled with no action?
- [ ] **Q52. An invalid move onto a tower (M2).** The whole tower (top doll,
  silhouettes) shakes by hand in sync, following §7 and
  `FxImageRequest.hideTarget`, rather than §9.3's "the top doll shakes in the
  file"; the "+N" tag stays still. OK?
- [ ] **Q53. Win timing and the combo clock (M2).** Won opens at 2117 + 250 ms
  as §7 says, while the last trail sparkles still fade under the scrim. The
  combo runs on board time (it stops while paused) and resets on start and
  restart, not on undo. OK?
- [ ] **Q54. Pools and segment types (M2, D53).** Pools follow
  m2-lottie-design §14 (2 per doll file, glass and ice one per slot), not
  LOTTIE.md's "dolls one per slot". And the timeline's `FxSegment` duplicates
  the runtime's `FxRange`/`FxPlan`: keep both or merge them?
- [ ] **Q55. Ice on an iced tower (M5, L51+).** `fx_ice` is anchored on the
  doll at the tower's surface (design §8), which puts the ice 5·fs above the
  static `iceRect` anchored on the stand. Should the ice follow the stand
  instead?
- [x] **Q56. Anchors of `ui_toggle` and `ui_splash_loader` (M2).** LOTTIE.md
  says only "toggle box" and "bar box"; the game takes their top-left, with
  the canvas as the widget's box. Or their centre?
  **Resolved 2026-09-27 (the designer, LOTTIE.md v3 "Inside the canvas"):**
  `ui_toggle`, `ui_spinner` and `ui_splash_loader` fill their canvas
  exactly, "because the canvas is the component box". That is what the game
  does; nothing changed.
- [x] **Q57. The HUD coins at Won (M2, frames 2.8, 1.5).** The bloc pays the
  reward at Won, so the HUD's coin pill shows the new balance while the win
  overlay counts "+10" up at 700 ms; the frames show the HUD still at the old
  balance. Hold the HUD until the count-up ends?
  **Resolved 2026-09-27 (owner: match the design):** the HUD shows the balance
  before the reward from Won (the flying set and the overlay, whose settled
  frame 2.8 still shows the old balance) until the next level starts
  (`GameplayView`, `gameplay_view_test` "keeps the old balance").
- [x] **Q58. The splash before the skin loads (M2, frame 1.1).** For about a
  second the three shelf dolls and the wordmark's doll draw with the
  procedural placeholder, then swap to the skin. Hide them until the art
  lands, or keep the placeholder?
  **Resolved 2026-09-27 (owner: match the design):** they stay hidden until the
  showcase's art lands, then fade in over `motion.ui.modalIn` (240 ms, none with
  reduced motion). With no showcase the placeholder draws them at once
  (rule 3); a showcase that fails leaves them hidden on the splash, and Home
  draws its placeholder dolls (`SplashView`, `Wordmark.dollShown`,
  `splash_page_test`).
- [x] **Q59. The subtle belly symbol: bare ink, or on a cream disc (M7,
  review FIDELITY-3)?** Every App Flow board frame (2.1–2.6, 1.3, 1.6) draws
  its dolls from `design/prototypes/skins/classic/preview/doll-*.svg`, which
  put the symbol on an r 55 `#FFF8EC` disc with a 5-unit ring in the colour's
  light shade. tokens.json (`skin.symbolSize` 110, no subtle disc), design
  README §3 ("filled with ink at 94 %"), `generator/nesty-doll.js` and
  `skins/classic/renders/*.svg` draw the bare symbol, and the game follows
  them. The precedence puts App Flow above the README, but tokens.json above
  both, and the tokens define only the large mode's disc. Which is canonical
  for `subtle`? If it is the disc, the subtle body raster (skin and
  placeholder) gains it, and the goldens change.
  **Resolved 2026-09-27 (owner): bare ink.** The subtle symbol stays as
  tokens.json, README §3, the generator and the renders draw it; the App Flow
  preview art's disc is not adopted. No code change.
- [ ] **Q60. +1 Slot pressed again during the re-pitch (M2, D58).** The
  second press is queued: a second slot re-pitches in after the first, and a
  second booster is spent in stg/prod. Or ignore presses during the 300 ms
  re-pitch, as the board's global lock does for taps?
- [x] **Q61. The iOS audio session (audio plan Q39).** Mix with the
  player's own music (`.ambient`), or stop it (the default)?
  **Resolved 2026-09-26 (owner): `.ambient`,** set in `AppDelegate.swift`
  (no package). It follows the silent switch, as Android already mixes.
  Keeping Nesty's music off while another app plays is an optional M7 item.
- [x] **Q62. Chapter complete's two jingles (audio plan Q40).** At 4.6 the
  figurine joins the Museum (AUDIO.md: `jingle_reward`) and the overlay
  opens (`jingle_chapter`). **Resolved 2026-09-26 (owner): only
  `jingle_chapter`;** `jingle_reward` is for skins, bought themes, the daily
  chest and purchases (`JingleCues`, M3 and M6 callers).
- [x] **Q63. Android screen recording (audio plan Q41).** SoLoud's
  low-latency output can't be captured by Android screen recorders.
  **Resolved 2026-09-26 (owner): low latency off in dev and stg, on in
  prod** (`Flavor.audioLowLatency`), so videos recorded on dev or stg builds
  have sound.
- [x] **Q64. Where the hint arc starts (M7, D60).** Frame 3.1 starts it 66
  below the source doll's top, two thirds down its 99 dp doll. The game
  keeps the 66 (capped at two thirds for smaller dolls), which on Level 9's
  tall brown3 lands on its upper body. Should it start at the head instead?
  **Resolved 2026-09-27 (owner): keep the design's value**, 66 below the
  top (capped at two thirds), as frame 3.1 draws it.
- [x] **Q65. The extra slot's pulse under a doll (M7).** `ui_extra_slot`
  loops until the level resets, also while a doll stands on the slot.
  Frame 3.6 shows only an empty extra slot. Stop the pulse while it is
  occupied?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): the loop stops (a 150 ms fade to its rest frame) while a doll stands on the pad, and restarts at frame 0 once it is empty (`motion.extraSlot`); D184.**
- [ ] **Q66. A music volume slider (M3).** `MusicService.setVolume` applies
  at once and cancels a running fade (a crossfade too). Fine for a slider;
  should it fade instead? Nothing calls it in M2.
- [ ] **Q67. When does the daily unlock (M3, m3 §8.3, D76)?** Default: once
  Level 2 (the tutorial) is won, with intro cards covering any mechanic a
  daily board shows before the player's campaign reaches it (the dailies
  use the 31–50 boards: towers and a lock). The locked Daily tile has no
  design (`TODO(design)`).
- [ ] **Q68. Should the chapter reward be a Remote Config key (M3, m3 §7.1,
  D72)?** Default: `reward_chapter`, default 150, like Q5. Spec §9.4 doesn't
  list it.
- [ ] **Q69. Where does a relaunch after a kill land (M3, m3 §3.4, D71)?**
  Default: the splash, then Home, with PLAY reopening the saved board
  exactly. The alternative opens straight into the board.
- [ ] **Q70. The streak's readings (M3, m3 §8.2, D76).** Defaults: at most
  1 freeze held, granted once per ISO week (Monday start, including a missed
  Monday); a frozen day keeps the streak but doesn't add to it; the chest
  opens on every 7th streak day (7, 14, …); only today's date counts, so a
  daily finished after midnight pays its coins but doesn't extend the
  streak.
- [ ] **Q71. Bonus levels (M3, m3 §7.4, D74).** Default: outside the
  chapters (no chapter progress, no figurine, the last chapter's theme),
  numbered from 1, and never skipping levels published later. OK?
- [ ] **Q72. Prices the frames don't show (M3, m3 §9.1, D75).** Defaults:
  the Space skin 1,200 (frame 7.3 shows it owned), the ch02 and ch03 themes
  800 and 1,000 when bought before their chapter; `forest-bear` is not
  sold. All tunable from Firestore in M4.
  **Forest Bear answered 2026-09-30 by Claude Design's m7-3 (phase 4): sold at 2,500 (copy.md H), D200.** The other defaults (Space 1,200, ch02 800, ch03 1,000) stay open.
- [ ] **Q73. Catalog content the design doesn't supply (M3, m3 §9.1,
  D75).** Figurine names 4–10 default to "The Astronaut/Gardener/Snow/
  Circus/Musician/Royal/Explorer Family" (Q47); 9 figurine flavor texts,
  5 skin descriptions (only Ocean's exists) and the names of chapters 7–10
  are hidden until supplied; the privacy policy URL and the support email
  hide their Settings rows until supplied.
  **The catalog copy answered 2026-09-30 by Claude Design's m7-3 (phase 4): copy.md G.1–G.4 and H, every figurine name and flavour text, the six skin descriptions and Forest Bear's, and the chapter 7–10 names, final (Q-P4-9); D198.** The privacy policy URL and the support email stay open.
- [ ] **Q74. The Settings footer's Player ID (M3, frame 8.1, D79).** The
  spec has no player id. Default: a local random id made on first launch
  and kept in the save (`7F3A-21C9`). Keep it, or drop it from the footer?
- [ ] **Q75. The Shop's Coins and No Ads tabs before M6 (M3, m3 §10.7,
  D75).** Default: all four tabs show, and those two show a store-closed card
  until the store lands in M6. Or hide them until then?
- [ ] **Q76. The milestone chest (M7, D92 E5).** Default: 100 coins and 1
  hint (`chest_coins`, `chest_hints`), at level 10 of every chapter and every
  10th bonus level, never on a replay.
- [ ] **Q77. Race rewards (M7, D93).** Default: 20, 30 and 40 coins by rival
  (`race_reward_1/2/3`), no daily cap.
- [ ] **Q78. When vs Computer unlocks (M7, D93).** Default: after Level 20
  (`race_unlock_level`).
- [ ] **Q79. Rival paces (M7, D93).** Default: 3.0, 2.4 and 1.6 s per move
  (`race_pace_ms_1/2/3`), each varying by up to ±20 %
  (`race_pace_jitter_pct`), tuned by playtest.
- [ ] **Q80. Rival boards (M7, D93).** Default: easy, medium and medium, at
  the stage of the player's highest level.
- [ ] **Q81. The reminder's default time (M7, D92 E4).** Default: the hour
  the player solved their first daily, editable in Settings.
- [ ] **Q82. Replays (M7, D92 E7).** Default: a replay pays nothing, never
  moves `currentLevel`, the chest or the Museum, and best moves are kept per
  level id and version.
- [ ] **Q83. The badges (M7, D92 E8).** Default: about 12 cosmetic badges
  with fixed triggers, which Claude Code proposes in the brainstorm doc and
  Claude Design names and draws.
- [ ] **Q84. Relaxed mode's undo rows (M7, D92 E6).** Default: with relaxed
  mode on, the undo price and ad rows are hidden (undo is free).
- [ ] **Q85. Where the new rules live (M7, D92, D93).** Default: the owner
  pastes `plans/spec-proposals-m7.md` into GAME_SPEC.md; until then its
  approved text is the rule. Or keep them recorded here only?
- [ ] **Q86. Ads for players of unknown age (M6, D92).** Default: decide at
  M6 between non-personalized ads by default and reading Apple's Declared
  Age Range API.
  2026-10-04 (D260): under-13s are now a target, so Google Play's Families
  policy decides most of this. A player of unknown age gets the kid path's
  ads (child-directed, G, certified, no ad ID) until the age question or a
  store signal says otherwise. Q174 holds the rest.
- [ ] **Q87. 4-shelf boards and 5-slot rows (M7, D92).** The confirmed
  curve (Q34) never uses them. Default: keep the curve's layouts for launch.
  Or add them to chapters 8–10 for variety? That needs Claude Design B.1–B.2,
  a curve change and a `Generator.version` bump.
- [ ] **Q88. Best moves on daily, bonus and race boards (M7, m7 §11,
  D102).** Default: none; they can't be replayed, so their win card shows
  "Moves N" only. Keep a best for them too?
- [ ] **Q89. When the milestone chest pays (M7, m7 §9, D103).** Default: in
  the win's own save update, so a kill before the modal loses nothing; the
  modal's buttons only show it. Or pay on the modal's button instead?
- [ ] **Q90. Replays in progress (M7, m7 §6, D100).** Default: a replay is
  never saved, so a kill ends it (it pays nothing, so nothing is lost). Or
  save and resume replays like the campaign?
- [ ] **Q91. What the records count (M7, m7 §12, D105).** Default: every
  mode (campaign, replay, bonus, daily, won races), won boards only; "dolls
  nested" is the dolls that end inside another in each won board,
  `totalSets × (maxSize − 1)`. Or count the moves as they are made?
- [x] **Q92. Where Chapters and Records open from (M7, m7 §15.8, D109).**
  Default: a row of two buttons under Home's header, and a Chapters button
  on the Museum screen, until Claude Design draws them (request §I.4).
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): Chapters opens from Home's chapter card, Records from the Records button beside it; the Museum has no Chapters link (frames 2.1, 6.1); D193.**
- [ ] **Q93. Bonus milestone chests (M7, m7 §9, D97, D103).** Default: every
  10th bonus level, tracked in their own list (`chests.bonusOpened`). OK?
- [ ] **Q94. The badge triggers (M7, m7 §12, D106, with Q83).** Default: the
  twelve of m7 §12; `tall_order` counts `maxSize` 5 or more, `grand_nest`
  6; `museum_full` is the ten launch figurines. Claude Design names and
  draws them.
- [ ] **Q95. The freeze chip's "0 left" (M7, frame 5.2, D110).** Default:
  rewritten "No freeze" (scarcity wording, E1). Keep the frame's copy?
- [ ] **Q96. The paused streak's look (M7, m7 §15.7, D98).** Default: the
  whole Daily tile badge and streak card turn neutral (never red), the flame
  muted. Or only the flame?
- [ ] **Q97. Where "Streak relit!" shows (M7, m7 §8, D98).** Default: on the
  daily win card's streak line, not as a toast on the Daily screen.
- [ ] **Q98. The vs Computer tile before the race ships (M7, m7 §15.8,
  D109).** Default: locked, "After Level 20" until that level is won, then
  "Coming soon" until M7 phase 2 lands. Or hide the tile until then?
- [ ] **Q99. The layout signature (M7, D114, E12).** Default: the slots per
  shelf, the sorted tower depths, the glass cases, the iced slots, the colour
  count and `maxSize`; colours, positions and set cuts are ignored (a
  reskin). Should another feature separate two levels?
- [ ] **Q100. Expert-only levels past L200 (M7, D114).** The approved text
  says "an error for L31–200". Default: an error from L31 on, so a level
  published later (M4) is held to it too.
- [ ] **Q101. `maxSize` 6 as a `bundle check` gate (M7, D114).** Default: an
  error on any slot but a super hard one (spec §3.7), so size 6 appears only
  on L130, L140 … L200.
- [ ] **Q102. The intro levels leave their curve rows (M7, D113).** Default:
  L31, L51 and L71 have no towers and 3–4 colours, so each mechanic arrives
  alone (and L71 with "few colours"). OK?
- [ ] **Q103. Chapter 5's "fewer empty slots" (M7, D113).** Default: no empty
  slot at the start, on all 20 of its levels.
- [ ] **Q104. The 20,000-node start solve (M7, D113).** Default: every new
  level solves from its start within the device's soft-stuck budget (spec
  §6.3), a selection rule pinned by a repo test, not a `bundle check` gate
  (making it one is a "Later" item).
- [ ] **Q105. Twist knobs beyond ±1 (M7, D113).** Default: towers 4 deep in
  chapters 5, 8 and 10; no empty slot in chapter 5, chapter 6's hard levels
  and chapter 10; 2 empty slots on some of chapter 6's easy levels; glass
  and ice counts 0–2 where a twist names them.
- [ ] **Q106. `levelsVersion` (M7, D113).** Default: stays 0 until M4's
  remote manifest reads it.
- [ ] **Q107. L200, the grand finale (M7, D115).** Default: kept as the only
  level the casual bot never wins (0/300; smart 300/300, 35 moves; L160 is
  now 7/300 and L170 27/300). Or re-tune it, which needs two or more swaps
  or giving up its 35 moves?
- [ ] **Q108. Four easy pairs that read alike (M7, D115).** L81/L82 and
  L91/L92 (chapter 5), L141/L142 and L151/L152 (chapter 8) differ only in
  their shelf count. Default: kept. Or allow another knob in those slots
  (a glass or ice count, towers ±2)?
- [ ] **Q109. The near-duplicate measure (M7, D115).** Default: a repo test,
  calibrated on one review's four pairs; E12's signature (Q99) stays the
  gate. Or make it a `bundle check` gate?
- [ ] **Q110. +1 Slot's one sound (M7, D116).** Default: the booster's own
  tap feedback plays it and the timeline's cue is gone. Or every board sound
  from the timeline (then the two buttons that lead there go silent)?
- [x] **Q111. The extra slot's loop at rest (M7, D116).** Default: it starts
  at frame 24, where its scale matches the static pad but its opacity is
  about 88 %: a smaller pop than before. Wait for Claude Design's E.21, or
  crossfade it in now?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): the loop rests on frame 0 (`ui_extra_slot`'s `rest` marker, `motion.extraSlot.restFrame`); D184.**
- [ ] **Q112. The shell's overflow sweep (M7, D121).** Default: the bottom
  nav and `HomeView` are swept apart. Also sweep the fully navigated shell
  (Home under the real router) at the five sizes?
- [x] **Q113. The Chapters header band (M7, D118).** Your direction asked for
  a band about 96 dp tall with the chapter's theme art cropped behind a soft
  scrim. Default: the stand-in keeps a theme-colour emblem with the family,
  and Claude Design's 10.4 decides. Or build the cropped band now?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): yes: the header crops the chapter's theme art (frame 10.4); D193.**
- [ ] **Q114. What E13 times (M7, D123).** Default: from Dart's `main()` to
  Level 1's first playable frame on a fresh install; the native launch
  before `main()` isn't in it, so your device check adds the seconds from
  the tap on the icon.
- [x] **Q115. The Museum's next-family line (M7, D118, design request J.2).**
  Default: "7 levels to go" under the family's name. Your example read
  "Chapter 4 · 7 levels to go": add the chapter?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): "Chapter 4 · 14 levels to go" (copy.md G.10 `museum_next_line`); D193.**
- [ ] **Q116. Which assists cap a win at 2★ (M7, D125).** Default: a hint
  used since the last Restart, or an extra slot on the board at the win (an
  extra slot survives undo and Restart, D22).
- [ ] **Q117. Best stars across level versions (M7, D125).** Default: kept
  per level id, so a new version (M4 content) keeps them. Best moves stay
  per version (D102).
- [ ] **Q118. Where the 3★ target shows (M7, D125).** Default: "3 stars at
  15 moves or fewer" appears only on a replay's win card below 3★, never on
  a level's first win.
- [ ] **Q119. A one-time tip about stars (M7, D125).** Default: the first
  win below 3★ says once "Fewer moves earn more stars. Replay any level from
  Chapters."
- [ ] **Q120. Stars for levels won before stars existed (M7, D125).**
  Default: the stars their best moves earn, as if no hint was used, or 1★
  where there is no best.
- [ ] **Q121. E13's headline: "playable" or "alone on screen" (M7, D127, device stage).** Default: both reported; `nesty-test` prints both; "playable" stays D123's definition.
- [x] **Q122. Where the badge toast sits over the win card, and whether it closes with the card (M7, device stage).** Default: unchanged (top 58, 3 s), reported above. The toast covers "Level Complete!" and stays over Home's Chapters/Records row after the first win, over chapter 10 complete and over All Levels Done.
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): above the result card's ribbon at y 60, one at a time, and it leaves with the card (`motion.toast`); D187.**
- [x] **Q123. The Museum's shelf label: scaled to fit (shipped), two lines with a taller shelf, or a shorter form (M7, D130, device stage, design request J.2).** Default: scaled to fit, until J.2.
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): two lines at 11 px, "Chapter N" over "Levels a–b" (frame 6.1; copy.md G.10); D193.**
- [ ] **Q124. A Rematch after a win pays again (M7, D136, D138).** Default:
  yes, every win pays `race_reward_n` (spec-prop §7.7 "A win pays"; no cap,
  Q77). Or pay only a race's first win?
- [ ] **Q125. The race board's stage (M7, D134).** Spec-prop §7.7 says "at
  the stage of the player's highest level". Default: the highest campaign
  level won (`highestLevel − 1`), since the next level's stage may bring a
  mechanic not met yet. Or the next level's stage?
- [ ] **Q126. Race seeds and the raceNo cap (M7, D134, D138).** The seed
  formula can't meet any reachable daily or bonus seed, though bonus levels
  from 2,100,001 and dailies of the years 310–339 would. Default: keep the
  formula and cap raceNo at 99,999, where New race replays the last board.
- [ ] **Q127. A rival's restart takes one pace interval (M7, D133, D136).**
  Default: yes, the strip says "Starting over" for that interval, and the
  next interval makes the new run's first move. Or restart and move in the
  same interval?
- [ ] **Q128. Leaving a race, and its analytics (M7, D137).** Default: Quit
  race goes back to rival select with nothing written, the left race's
  raceNo is used up (the next race is a new board), and a race logs none of
  spec §14.4's level events until M4 defines race events.
- [ ] **Q129. A race board's theme (M7, D135).** Default: the player's
  current chapter's, like the daily, until Claude Design's frame 9.3 lands.
- [ ] **Q130. `race_unlock_level` below 16 (M7, D134).** Below the tower
  stage every board simulates easy, so rivals 2 and 3 would get easy
  boards. Default: no clamp; the default 20 keeps every race at stage 16 or
  later. Or clamp the race stage to 16 or later?
- [x] **Q131. "Rival unlocked" (frame 9.6) (M7, D139).** Default: a toast
  over the win card, after any badge toast. Or a fuller card, like Chapter
  complete's?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): a card, shown once per rival as 9.4 closes (frame 9.6); D192.**
- [x] **Q132. Settings in a race's Pause (M7, D139).** Default: no Settings
  tile, only Restart and Quit race. Or keep Settings reachable mid-race
  (the race stays paused while it is open)?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): Settings is reachable from a race's Pause (frame 9.7); D192.**
- [x] **Q133. Quit race in one tap (M7, D139).** Default: one tap with no
  confirmation, like every Pause tile; a race loses nothing by quitting.
  Or ask first?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): Leave race asks once (frame 9.7b); D192.**
- [x] **Q134. The rival strip (M7, D139).** Default: a counter pill ("3/6")
  with the rival's state, no second board, until frame 9.3 lands. Or a
  small live board of the rival's copy (a second, read-only board)?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): the family counter plus one dot per family, no second board (frame 9.3); D192.**
- [x] **Q135. The rival strip on a narrow screen (M7, D141, race-ui).**
  m7 P2.9 says its state line "drops first below the smallest width" and
  names no width. Default: below 340 dp the strip shows the portrait, the
  name with its Computer tag and the counter, without "Thinking…", until
  frame 9.3 says what gives way (design request C.9). The width is the
  strip's inner width (the screen − 64 dp), so the line drops on every
  screen under 404 dp: the iPhone 16 Pro (402 dp) and the design's 390
  reference hide "Thinking…", and the 411 dp emulator shows it (device
  stage, D143).
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): the tag goes glyph-only below 360 dp and the state line hides below 340 dp (screen width); D192.**
- [x] **Q136. Toasts over a result card (M7, D143, device stage).** Toasts
  on 2.8 and 9.4 stack 350 ms apart at one spot, so a second hides the first
  (the `first_race` badge toast under 9.6's "New rival unlocked!"; 2.8 with
  two badges). Default: they stack, as today. Or queue them, each after the
  previous one closes? Design request I.6 and C.9 ask where they go.
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): queued: one at a time, 2.5 s each, 300 ms apart (`motion.toast`); D187.**
- [ ] **Q137. The reminder on a day already solved (M7, D153).** Plan
  decision 15 says "a daily repeating" notification. Default: it still
  fires on a day already solved. Skipping those days needs one-shot
  notifications over a rolling window, re-planned at each launch (a
  repeating iOS trigger can't skip a day), and they would stop if the app
  isn't opened for the window. Or skip solved days?
- [ ] **Q138. "Offered once" (M7, D153).** Default: the offer counts as
  made at its first appearance on the Daily screen, answered or not;
  Settings keeps the switch. Or show it again until answered?
- [ ] **Q139. The reminder row before the daily unlocks (M7, D153).**
  Default: Settings hides "Daily reminder" until Level 2 is won (the
  daily's own unlock). Or show it from the start?
- [x] **Q140. A button to the phone's notification settings (M7, D153).**
  Default: none in phase 3; the denied and blocked lines say where to
  turn notifications on. A button needs a small platform channel or the
  `app_settings` package (a rule-9 reason). Add one?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): yes: "Open phone settings" on the denied step and Settings' blocked row (frames 10.2d, 10.2f); D189.**
- [ ] **Q141. A tap on the reminder (M7, D153).** Default: it opens the
  app normally (splash, then Home, one tap from Daily). Or deep-link to
  the Daily screen (later)?
- [ ] **Q142. The reminder while the app is open (M7, D153).** Default:
  iOS shows nothing in the foreground; Android posts it at default
  importance (no heads-up banner). Or show it in the foreground too?
- [x] **Q143. How many notification lines (M7, D153, design request
  G.7).** G.7 asks Claude Design for 2–3 lines. Default: one line, the
  same every day; rotating needs one schedule per weekday. Rotate them?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): three lines (copy.md G.7 `notification_1..3`), rotating at each re-plan (Q-P4-5); D190.**
- [x] **Q144. The share text (M7, D151, design request G.6).** Default:
  the date, one 🪆 per family (at most 12), the families, the moves and
  the streak count, even while the streak is paused; no board, colours or
  moves. G.6 replaces the wording. Anything to add or drop?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): G.6's text: one belly-symbol emoji per family, "Solved in N moves · Day D 🔥", or the no-streak line; on the daily win card (frame 10.1); D188.**
- [x] **Q145. The replay's 3-star target line (M7, D148, Q118).**
  Default: it shows only when the moves were over the 3-star threshold,
  so an assisted win at or under it shows none, and no line explains the
  hint or +1 Slot cap until design request K.4 says how. Or say why a
  2-star win was capped?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): "Wins with a hint or an extra slot earn up to 2 stars." (copy.md G.11 `stars_helper_note`); D191.**
- [x] **Q146. Reduce motion on the win card's stars (M7, D149, design
  request K.3).** Default: every star shows at once, with no pop or
  twinkle; the three pitched clacks and haptics still play at half the
  stagger (60 ms apart), as D48 does for every cue. Or play them silently?
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): the last frame at once, one sound (the highest star) and one light haptic (`motion.stars`); D191.**
- [ ] **Q147. The star totals (M7, D150).** Default: a chapter's total is
  3 × its bundled levels with a par (60), and Records' is 3 × the
  bundle's levels with a par (600). OK?
- [ ] **Q148. A tutorial whose scripted moves leave every optimal line
  (M7, D146).** The stars-core lane checks that L1's and L2's scripted
  moves lie on an optimal line. Default if one doesn't: accept that its
  first play can't reach 3★ (a replay can), and report it. Or change the
  script? (Checked 2026-09-29 by stars-core: L1's script is its whole
  2-move solve, par 2; L2's scripted swallow `r0c0>r1c0` leaves a 2-move
  finish, 3 in all, par 3. Both first plays can reach 3 stars, and
  `repo_levels_test` pins it, so the default is moot. The bots' star
  shares per chapter are in `tools/levels/README.md` "Par and the star
  shares", for tuning the two slack keys.)
- [ ] **Q149. A denied reminder Yes (M7, D160).** When the OS says no,
  `DailyReminder.enable` still stores the chosen time and `offered`, and
  only `on` stays false. Default: yes, so a denial never loses the
  player's time. Or leave the settings untouched?
- [ ] **Q150. A platform double for the share test (M7, D156).** A true
  `SharePlatform` double needs `share_plus_platform_interface` and
  `plugin_platform_interface` as dev dependencies (rule 9). Default: no;
  a plain-Dart test of the status mapping and a "never throws" test with no
  platform registered cover it, as `url_link_launcher_test` does. Add
  them?
- [x] **Q151. The Share button's glyph until I.10 (M7, D156).** Default:
  `NestyIcons.download`, unused elsewhere in the app, so it collides with
  no other meaning. Or another glyph from the subset? On a device the tray-and-arrow
  glyph is the solved card's only icon-only button, and it reads as
  "download" or "save" (device stage, D162). I.10 should name the share
  glyph.
  **Answered 2026-09-30 by Claude Design's m7-3 (phase 4): `share`, and `ios_share` on iOS (tokens `icons.share`, `shareIOS`); D188.**
- [ ] **Q152. The reminder offer's time after a night solve (M7, D153, Q81,
  Q138).** The offer proposes the solve's hour, so a daily solved at 01:59
  offers "Every day at 1:00 AM" (seen on both devices). Default: keep the
  solve's hour, because nothing is scheduled until Yes and "Change time" is
  on the card. Or propose a daytime hour, for example the Settings default
  19:00, when the solve's hour falls at night (say 22:00–07:59)?
- [ ] **Q153. A paused streak and a clock rolled back (M7, D163, review
  R2).** While the daily streak is paused (`lastDate` is null), the save
  has no latest date. If the player rolls the clock back to an earlier ISO
  week, that week grants a freeze, and solving that past daily relights
  the run (m7-design §8's `solve` compares only against `lastDate`).
  Default: leave it as it is. It needs a deliberate rollback while paused,
  gives at most one freeze per round trip, and nothing is paid for. Or
  keep a high-water date in `DailyProgress` (or keep `lastDate` on a
  pause), so this also counts as "the clock went back"? That changes §8's
  model and the save (a schema step).
- [ ] **Q154. Screen-reader play on the board (M7, D165, review R12).**
  The Flame board has no screen-reader nodes. A VoiceOver or TalkBack
  player can use every menu, overlay and dialog, but can't pick a slot,
  so they can't play any level, the daily or a race. Screen-reader play is
  not in spec §16 or spec-prop §16. Building it means:
  - one node per slot, from the page's `BoardGeometry`, labelled from
    core's state;
  - a tap that goes through the board's own input rules;
  - the tutorial card as a live region;
  - about 20 new strings from Claude Design (11 color names, sizes,
    towers, glass and ice states) in the 9 launch languages;
  - then a VoiceOver and TalkBack device pass.

  Should blind players be able to play levels in v1? Default: build it in
  v1.1, and say in the store listing that playing the board needs sight
  until then.
- [ ] **Q155. The reminder's time zone data (M7, D166, review R9).**
  P3.10 loads `timezone`'s `latest_10y`, which lacks 132 backward-link
  zone ids (Europe/Amsterdam, Asia/Calcutta, GMT and others). Should it
  load `latest_all` instead? That adds about 380 KB of data and about 3 ms
  of decode. Default: keep `latest_10y`. Since R9, the platform receives
  the device's own id and applies its real DST rules. For those ids, the
  Dart side only lacks R34's gap-day check: a 02:xx reminder scheduled
  within a day before a spring-forward change. The zone key's offset
  repairs that at the first refresh after the change.

- [ ] **Q156. Theme prices for chapters 7–10 (M7 phase 4, D199).** No
  source prices the ch07–ch10 themes. Spec §7.3 gives 500–2,000 and ch06 is
  2,000. Default: 2,000 each (`BundledCatalogRepository.laterThemePrice`),
  tunable from Firestore in M4.
- [ ] **Q157. The splash's "about 60 MB" (M7 phase 4, D196).** copy.md E's
  `splash_storage_body` says "Nesty needs about 60 MB to set up the
  shelves." The save itself needs far less, and the prod APK is 79.8 MB.
  Default: ship copy.md's line, with 60 in `SplashCopy.storageMegabytes`
  (the ARB's `{megabytes}`) for you to confirm or change.
- [x] **Q158. A blocked reminder has no off switch in the app (M7 phase 4,
  D190, D207).** After a Yes the OS denied, the reminder stays on and
  blocked (D190). Settings then draws the toggle off, and a tap on it (or
  on "Open phone settings") opens the phone's settings (frame 10.2f), so
  nothing in the app turns the reminder off while it is blocked. Nothing
  is delivered while blocked, but if notifications are allowed later the
  reminder starts as the player asked. Default: no extra control. The
  alternative is a "Turn off" link on the blocked row, which needs a new
  string (asked in the Claude Design follow-up).
  **Answered 2026-10-01 ("Build it"): the blocked row has a Turn off link (10.2f, `settings_reminder_turn_off`) and 10.2h's Off row; D235, D244.**
- [x] **Q159. Records' families cell (M7 phase 4, D209).** copy.md G.10
  and frame 10.6 read "{count} of 10 Families home", which is the Museum's
  count. The cell's value is `records.families`, every family a won board
  completed (spec-prop §7.9), so after two wins it read "2 of 10" with the
  Museum still empty. Default shipped: the rule's plain count, labelled
  "Families completed" (`TODO(design)` for its copy and glyph). Or show the
  Museum's own count ("N of 10 Families home")?
  **Answered by Claude Design's m7-4 (DELIVERY 8.5): Records shows "Families completed" (`records_families`) with the family counter's doll mark.**
- [x] **Q160. The undo's motion (M7 phase 5, D221, D227).** No frame or token
  draws an undo; it cut to the old board. Default shipped: the moved doll
  flies back along its own path, `doll_move` reversed (260 ms, one `whoosh`,
  130 ms under reduce motion), with `TODO(design): Q160`. Or keep the cut
  until Claude Design draws one (follow-up 11.1)? Answered 2026-10-07 by
  Claude Design (m7-5 DELIVERY, Choice 13): keep the shipped undo; the
  `TODO(design)` is gone (D287).
- [ ] **Q161. Closing M7 with owner-only items (M7 phase 5).** The
  acceptance line "matches the design screens" needs the owner's sign-off,
  and several checks need a phone (VoiceOver, a real reminder, the haptic
  feel, the final mix, the ten flagged levels). Default: M7 is "code
  complete, acceptance waits on the owner", as M2 and M3 are (D90); the
  owner-only items stay open under M7, and M4 doesn't start until you say so.
  Or may M4 start with them open, as D90 allowed for M2 and M3?
- [x] **Q162. Which local habits to build (after M7, D237).** Answered 2026-10-05: all four, in this order (D274). The four
  proposals are welcome back, a month of played days, the last 7 dailies
  playable, and a home-screen widget
  ([plans/local-habits-brainstorm.md](plans/local-habits-brainstorm.md)).
  Default: the first three in that order, and the widget only after them.
  None starts until M7 is closed. Playing an old daily must not move the
  streak or pay the daily coins again, and spec §7.5 stays as written until
  you approve that one. Or build none of them?

- [ ] **Q168. The freeze chip's "0 left" (M7 phase 5, D242, D247).**
  Frame 5.2 and DELIVERY 7 read "0 left"; "left" is on the respect deny-list
  (D110, Q95). Default shipped: "No freeze", and "{count} streak freeze(s)"
  without "left". Or take the design's "0 left"?
- [ ] **Q169. The board's clearance over the HUD (M7 phase 5, D243).** The
  deepest silhouette sits on `hudClearY` at 10.42 dp; tokens' worked example
  says 10.8. Keep 10.42?
- [ ] **Q170. Ice on four shelves (M7 phase 5, D243).** On four shelves the
  ice reaches about 13 dp into the plank above (the design's own numbers),
  so that preset skips the check. No level uses four shelves today. Accept?
- [ ] **Q171. The badge toast over the win ribbon on short screens (M7 phase
  5, D250; TalkBack T2).** At 390x844 the toast clears the ribbon. On a
  731 dp screen the short-screen blend lifts the ribbon so it sits under the
  toast, and there is no room above or below for a 54 dp card; tokens place
  the toast at `toast.inPlace.tops.winCard` on purpose. Default: no change.
  Or delay the badge toast until the ribbon has gone, under about 800 dp?
- [ ] **Q172. "Selected" on a picked rival card (M7 phase 5, D250).** copy.md
  says a pick adds "Selected", and the card is also a checked radio, so
  TalkBack may say both. Default: as copy.md says. Or drop "Selected" and let
  the radio state speak?
- [ ] **Q173. Which engagement proposals to build (after the local habits,
  D259).** ER1–ER11 are in
  [plans/engagement-research.md](plans/engagement-research.md) §3.
  - Default, wave 1 first: ER1 Free Play by difficulty, ER2 milestones you
    can feel, ER3 your month in dolls, ER4 challenge codes, ER5 the
    healthy-play kit.
  - Then the wave 2 items you pick: ER6 Doll Workshop, ER7 larger text, ER8
    seasons that come back, ER9 stories.
  - Later: ER10 family profiles and ER11 platform surfaces.

  None starts until M7 is closed and Q162's habits are done. Or a different
  set or order?
- [ ] **Q174. The kid path's details (D260).** Defaults
  (engagement-research §6.3):
  - Play Console bands 9–12 plus 13+; 6–8 only after a readability pass.
  - The age question after the first win, with store age signals where
    available.
  - Kid-path ads child-directed, rated G and from certified sources, with
    §9.1's pacing and no rewarded placements.
  - Purchases behind the parental gate.
  - The reminder and sharing turned on by a grown-up in the parent area.
  - Analytics off for under-13 and unknown age until the legal check; crash
    reports kept.
  - Not in Apple's Kids Category.

  Or no ads at all on the kid path, or younger bands?
- [ ] **Q175. Spanish and Portuguese phones (M7 phase 5B, D261).** Spanish
  is neutral Latin American. Every `pt_*` phone gets Brazilian Portuguese.
  Default: as built. Or Spain's Spanish, or a European Portuguese catalog?
  (This was l10n.md's Q160; the Q numbers there are stale.)
- [ ] **Q176. First launch and the language sheet (D261).** A fresh install
  follows the phone, and a sheet tap pins a language. The sheet has no "Phone's
  language" row, as frame 8.2 has none. Default: as built. Adding the row
  needs a string and a design; `changeLanguage("system")` already exists.
- [ ] **Q177. Rival names (D265).** Translated meanings (Guijarro, Botón,
  Cometa; Kiesel, Knopf, Komet; コイシ, ボタン, コメット), or Pebble, Button
  and Comet everywhere? Default: translated.
- [ ] **Q178. The registers (D265).** French "tu" (not "vous"), German "du",
  Spanish "tú", Portuguese "você". Default: as built.
- [ ] **Q179. Hindi's register (D265).** Everyday Hindi with the English game
  words players use (स्ट्रीक, कंप्यूटर), or formal Hindi (स्तर, संकेत)? Default:
  everyday.
- [ ] **Q180. A native reader before the store release (M8).** Default: none.
  The cross-review by back-translation (two Opus passes, D240) is the check,
  and nothing waits on a person. Portuguese "Ajustes" for Settings follows the
  glossary (Android's pt-BR says "Configurações"), and ja badge hints use
  〜しよう; a native reader would settle both.
- [ ] **Q181. The HUD pill off-centre (D263).** At 360 dp with a five-digit
  balance and a long tier, the level pill sits a few dp off-centre instead of
  scaling below the 0.75 floor. No frame shows that combination. Default:
  as built. Or cap the text scale in the pills?

  The 5B questions were provisionally numbered Q162–Q167 in the plan and the
  lanes' reports (Q160–Q165 in l10n.md §9.2); D237 took Q162, so they are
  renumbered here, Q175–Q180 in the plan's order, with Q181 from 5b-copy.

- [x] **Q182. The daily gift (D268, plan-login-gift).** Answered 2026-10-05: the owner approved the plan with every default below.
  - (a) When? Default: right after M7 closes, ahead of the local habits.
    Or now, inside M7 before 5C, which reopens the translations and the
    device run.
  - (b) How does it show? Default: a Home button with a dot and no popup
    (spec-prop §1: nothing nudges). Or the genre's sheet on the first Home of
    each day, dismissible.
  - (c) The track? Default: 20 coins · 30 · 1 hint · 40 · 50 · 1 hint ·
    100 + 1 extra slot, about 530 coins of value a week against the Daily's
    650. Or coins only.
  - (d) The kid path (D260)? Default: the same gift for everyone, since it
    takes nothing away and never nudges.

### Notes for later milestones (not questions)

Since 2026-09-26 each note below is also an item in [BACKLOG.md](BACKLOG.md),
the tracker. They stay here as history. New notes go into BACKLOG.md instead.

- **M6:** before `google_mobile_ads` is added, the AdMob App IDs must be in
  place, or the app crashes at launch: `GADApplicationIdentifier` in
  `ios/Runner/Info.plist` and `com.google.android.gms.ads.APPLICATION_ID` in
  `AndroidManifest.xml` (test IDs in debug, rule 5).
- **M4:** Firebase init goes where the `TODO(M4)` comment is in each app's
  `bootstrap.dart`, and must fail silently offline.
- **M3:** `SystemHapticsService` maps spec §11.2 to single impacts. The
  multi-pulse "success pattern" is still to be tuned on devices.
- **Firebase CLI:** not installed on this machine.
  - What was checked: on 2026-09-26, firebase-tools 13.35.1 in a scratch
    directory ran `emulators:exec --only firestore,storage` against a copy
    of `firebase/`. It confirmed that the rules compile and behave as the
    §14.3 sketch says (34 checks, Q20).
  - What wasn't: `firebase emulators:start` from `firebase/`, the Auth
    emulator and the UI.
  - To install: `npm install -g firebase-tools`, which also needs a JDK.
  - Emulator-backed rules tests are to be added in M5.
- **iOS:** the first `flutter build ios` ran `pod install`. `Podfile.lock`
  and the CocoaPods changes to the Xcode project and workspace are meant to be
  committed.
- **M8:** any Xcode Archive or fastlane lane must run
  `flutter build ipa --flavor <f> -t lib/main_<f>.dart` first, or the D8 guard
  fails the build. Profile and release iOS builds haven't been tried yet.
- **Before the first push:** the owner runs `git init` and adds the remote.
  CI has only been simulated locally, so watch its first run on
  `ubuntu-latest`. (By 2026-09-26 the repo existed with a GitHub `origin`.
  Watching CI's first run is a BACKLOG "Tech debt" item.)

- [x] **Q183. The race-loss card's Computer celebration (M7 phase 5, the ethics lens).** Answered 2026-10-05: keep as designed (D273).
  The 9.5 loss card plays `ui_rival_react`'s `win` segment, a hop with
  confetti, over the player's loss (race_result_overlay.dart; LOTTIE.md). The
  design specifies it, so it breaks no rule, but the ethics lens rates it
  close to the line (P1). Default shipped: the design as delivered.
  Alternative: TC8's polite bow (themes-characters-story).
- [x] **Q184. Which themes, characters and story proposals to build (D270).** Answered 2026-10-05 in part: wave 1 first (D275); the names and the other sub-questions keep their defaults.
  Pick from TC1–TC14 and their order. TC-FX and TC-DATA come with the
  items that need them. Also:
  - the mascot's name, and the squad's names and chapter, after a legal
    check;
  - the route for new lands in TC5 and TC6 (default: with M4's weekly
    levels);
  - whether the story keeps the tokens' figurine pairing (default: yes, as
    its plot);
  - whether passed beats replay in the flow (default: no, the Storybook
    only).

  Default order: wave 1 (TC7 animation layer, TC8 Computer personality, TC1
  mascot), then TC4a story panels and the Storybook (absorbing ER9), then
  TC13 Little Ones.

- [x] **Q185. May the daily gift start before M7's owner sign-offs?** Answered 2026-10-05: start it next (D272). M7 is
  code complete and its gate passed (2026-10-05); its acceptance waits on
  the design sign-off (Q161), the VoiceOver pass and Claude Design's
  follow-up. D90 let M7 start while M2's and M3's device checks were open.
  Default: the daily gift (D268) starts when the owner says so, without
  waiting for those sign-offs.

- [x] **Q186. The daily gift button's glyph (D277).** Answered 2026-10-07: Claude
  Design's section 13 names it, `design/ui/gift/gift_glyph.svg`, drawn through
  `UiArt.giftGlyph` (D285). No icon-font glyph was needed; `IconUses.dailyGift`
  is gone.
- [ ] **Q187. `.claude/rules/hive.md` says the save document carries `"schema":
  1`.** It has been stale since schema 2, and the save is now schema 3 (D276).
  It is a rules file, so it waits for you. Default: leave it; the suggested
  text is "the current `SaveDocument.currentSchema`".
- [ ] **Q188. A date seen far ahead (D276).** A phone whose clock was once far in
  the future, and opened the app then without claiming, shows "Next gift: …"
  with no Claim until that date comes round. That is §7.5b's "the latest date
  ever seen"; nothing is lost and the copy is calm. Or count only claimed
  dates. Default: as built, until M4's server time.
- [x] **Q189. §7.5c, the past dailies (D297).** Answered 2026-10-08: approved as written, with every default below (D310). Approve the rule text in
  [plans/plan-local-habits.md](plans/plan-local-habits.md) and its defaults:
  - a past day pays nothing;
  - it isn't counted in Records' dailies or the longest streak;
  - it is counted in wins, moves, families and dolls, as a replay is;
  - the month marks it "played later";
  - replays are allowed and pay nothing;
  - there is no Share on a past day;
  - one past-day board is in progress at a time;
  - the window doesn't depend on the install date;
  - on a past day's board only owned boosters work, with no coin or ad
    buy (added after m7-6 drew it, D301).

  Stage 3's code waits for the answer.
- [x] **Q190. The window across a month boundary (D298).** Answered 2026-10-08: the default (D310). On the 1st–7th,
  some of the last 7 dates are in the previous month.
  - **Default:** the month card pages back exactly one month and forward
    again, and `maxDates` goes from 31 to 62, so that month shows in full.
  - **Or:** the grid's first row reaches back to the window's first date.
  - **Or:** only the current month's part of the window is offered.
- [x] **Q191. A frozen day in the month (D298).** Answered 2026-10-08: the default (D310).
  - **Default:** a quiet frost mark (`acUnit`), neither lit nor blank.
  - **Or:** blank like any day not played.
- [ ] **Q192. Is RR2's free hint within the never list? (D300)** The never
  list bans offers shown because a player failed. RR2 gives one free hint
  on the third try of a level: no ad, no coins, at most once per level.
  - **Default:** yes, it fits, because nothing is sold and nothing is shown
    for money.
  - **Or:** no, and RR2 is dropped. Its tools-side "mechanic wall" check
    stays.
- [ ] **Q193. Which retention proposals to build, and where (D300).**
  - **Default:**
    - RR3 (a living Home) and RR7 (the next-up peek) join the local
      habits, after the widget;
    - RR1 (the solve coach) and RR2 (the helping hand) join the engagement
      research's wave 1;
    - RR4 (Nest Maker, after ER4) and RR5 (the replay clip) join wave 2;
    - RR6 (the stores' surfaces) goes with M8.
  - **Or:** any subset, in any order.

## Next step

[BACKLOG.md](BACKLOG.md) is the tracker for everything still to do. This
section only says where to look.

**Now (2026-10-10):** M7 is code complete and the `/milestone M7` gate passed
([Phase 5, 5C](#phase-5-5c-the-review-and-its-fixes-2026-10-05)). Its
acceptance waits on the owner: the design sign-off (Q161), the VoiceOver
pass and Claude Design's follow-up; BACKLOG "M7" lists them. The daily gift
(D268) is built on Claude Design's section 13 (m7-5, D281–D296) and passed on
both devices. Its acceptance waits on the owner's sign-off and the paste of
§7.5b. The local habits (D274's order, D297) are code complete
(2026-10-10): welcome back, the month of played days, the last 7 dailies
and the home-screen widget. Each passes its host tests and device steps on
both platforms, and the close review's fixes are in (D302–D315). Left with
the owner: the widget on a real phone and its App Groups (no Apple Developer
account yet, D313), and the design gaps in BACKLOG "Local habits". The plan
is [plans/plan-local-habits.md](plans/plan-local-habits.md). Next (D237),
once M7 is closed: the engagement proposals (Q173), the kid path's local
part (D260) and the themes, characters and story picks (D275); the retention
proposals wait on Q192–Q193. M4–M6 and M8 come
last (D237, D269). The items below are the earlier rounds' notes.

1. **This round (D23):** the design foundation and M1 are done, and M2 is
   code complete (D53–D58): the app plays on an iOS simulator and an Android
   emulator with every real service, and the review fix pass is in. Left for
   M2's acceptance (BACKLOG "M2"):
   - the owner's 60 fps check on a real mid-range Android device in a
     profile build, following [M2 acceptance](#m2-acceptance-spec-18)
     (`/perf-profile`);
   - the manual L1–30 pass on the dev flavor;
   - the owner's answers to Q39–Q60 (none blocks the acceptance).

   The unlock-symbol raster swap moved to M5, the tabular figures (Q29) to
   M7 and the load-failure copy to the design gaps. The on-device
   playthrough runs with `NESTY_SCREENSHOT_DIR=<dir> flutter drive --flavor
   dev --driver test_driver/integration_test.dart --target
   integration_test/playthrough_test.dart -d <device>` from `apps/game`.
2. **The post-M2 round** ([Post-M2 round](#post-m2-round-claude-design-v3-and-audio-2026-09-27))
   imported Claude Design v3 (D59, D60) and the music and jingles (D61), so
   the Lottie re-export and the music are no longer waited on. Left for the
   owner (BACKLOG "Post-M2 round" and "Owner inputs needed"): the device check of the Level 9 hint,
   +1 Slot, a tower reveal and the ribbons; the audio acceptance on a
   mid-range Android and an iPhone (gapless loops over 3 cycles, audible
   ducks, no clipping, streaming under 3 MB resident); the `jingle_reward`
   listening check; Q64–Q66.
3. **Next: M7, the offline game (D90, D92, D93).** It covers:
   - levels 31–200 on the chapter plan;
   - chapter themes 7–10 and the catalog copy;
   - the vs Computer race;
   - the eight engagement features under the respect rules;
   - star ratings, 1 to 3 per level (D125,
     [plans/star-rating.md](plans/star-rating.md));
   - the art polish.

   All of it comes before any backend. D237 keeps M4–M6 and M8 at the very
   end, after M7 and after the local-habit proposals. After those come the
   engagement proposals the owner picks (D259, Q173) and the kid path's
   local part (D260), which must land before M4. Where things are:
   - the work list is BACKLOG "M7";
   - the reasoning is `docs/plans/offline-game-brainstorm.md`;
   - the rules are `docs/plans/spec-proposals-m7.md`, for the owner to paste
     into the spec (Q85);
   - the art and copy request is `docs/plans/claude-design-request-m7.md`;
   - the prompt that starts the work in a fresh Claude Code session is
     `docs/plans/m7-claude-code-prompt.md`.

   Q76–Q87 have defaults, and none blocks the start.

   **Phases 1–3 are done** (2026-09-29, [M7](#m7--the-offline-game--phase-1-integrated-2026-09-28)):
   levels 31–200, E1, E2, E5–E9 and E12–E14; then vs Computer; then star
   ratings, the share card and the reminder. Each passed on the iPhone 16
   Pro simulator and the API 35 emulator (D126–D131, D143, D162). **Phase 4
   is integrated** (2026-09-30, [Phase 4](#phase-4-claude-designs-m7-3-delivery-integrated-2026-09-30),
   D171–D208): Claude Design's `nesty-design-m7-3` replaces every stand-in,
   and its device run passed on both platforms (D209). The design gaps are
   in `claude-design-request-m7.md`
   "Follow-up after m7-3". Then phase 5 (the close), whose review pass is
   done in two rounds ([M7 review pass](#m7-review-pass-2026-09-29),
   D163–D167), with the accessibility audit. The device run after the
   review passed on both platforms (D168). **Phase 5A is built**
   (2026-10-01, [Phase 5A](#phase-5a-the-fidelity-fixes-the-animated-undo-and-the-device-seams-built-2026-10-01),
   D210–D234): the fidelity fixes from the scenes' CSS, the animated undo and
   the device seams. Left in phase 5: its device run (blocked on disk: it
   needs 20 GB free), then the fidelity audit and the TalkBack pass with their
   fixes, the translations (5B) and the `/milestone M7` gate (5C). Q88–Q161
   have defaults; none blocks the next phase. Left with the owner: a real reminder on a phone,
   tuning the two star slack keys from `nesty_levels report --stars`, Q154
   (screen-reader play on the board), and the pass-and-play proposal,
   [plans/pass-and-play-proposal.md](plans/pass-and-play-proposal.md): build
   it or not, and which rules. **After M7 (D237):** the local habits in
   [plans/local-habits-brainstorm.md](plans/local-habits-brainstorm.md),
   whichever of the four Q162 picks. Then M4 (Firebase), M5 (admin), M6
   (ads and purchases) and M8 (release on production Firebase), in that
   order.
4. **M3** is code complete ([M3](#m3--app-shell-and-meta--code-complete-acceptance-pending)):
   both criteria pass on the iPhone 16 Pro simulator and the API 35
   emulator. Left for its acceptance (the two items at the top of BACKLOG
   "M3"): the owner swipes the app away mid-level on a physical phone and
   relaunches it, and opens the Daily on two physical phones on the same
   date.
5. **Owner inputs:** BACKLOG's "Owner inputs needed" lists what only the owner
   can supply or decide, with the milestone each one blocks. Due next: Q73's
   content (figurine names 4–10, flavor texts, skin descriptions, the
   privacy URL and support email), which M3 ships hidden or as placeholders,
   and the M3 defaults Q67–Q75.
6. Owner decisions that block nothing but are cheapest to take early: Q23
   (SDK upgrade), Q24 (deny globs), Q25 (rule 10 wording) and Q27 (Gradle
   wrapper).
