# Plan: M7 — Art and polish, plus the offline game

Status: written 2026-09-28. The owner's prompt (`plans/m7-claude-code-prompt.md`)
asked for plan-then-workflow "like M3", so this plan runs without a further
stop. Later decisions go in PROGRESS as D94+, questions as Q88+.

## Context

Spec §18 M7 ✅: **matches the design screens; no layout overflows on 5 screen
sizes.** D90–D93 widen it (spec-prop §18): levels 1–200 bundled, valid,
solvable and on schedule; vs Computer, the gentle streak, the share card, the
reminder, the milestone chest, relaxed mode, replay with best moves, Records
and badges and the first-launch L1 working fully offline, with tests at every
layer; every feature passes the ethics checklist (brainstorm §5).

Rules: spec §2–§8, and until the owner pastes it (Q85) the approved text of
`plans/spec-proposals-m7.md` (§1.1, §7.1, §7.3, §7.5, §7.7–§7.9, §8, §9.4,
§10.1–10.2, §13.3, §16). 100 % offline: no Firebase, ads, purchases or other
backend. Q76–Q87 ship their defaults. Nothing from the Claude Design request
has landed (`design/` is unchanged), so new screens are built from the tokens
with `TODO(design)` and a BACKLOG item, chapters 7–10 reuse ch01–ch04, and
copy is placeholder.

Scope: BACKLOG "M7" (Offline content, Game modes, Engagement E1–E14, the fix
items, fidelity, overflow, animation, translations, accessibility) and its 10
`TODO(M7)` markers, all of which already have items.

## Approach

Five phases, each one Workflow run: a **contracts** stage freezes the shared
surface (the save schema, settings keys, Remote Config keys, routes, ARB keys,
interfaces, and the phase's section of `plans/m7-design.md`, which is
authoritative for the lanes), **lanes** build in parallel on exclusive paths,
and an **integrator** does every cross-lane edit, codegen and the gates. One
review with a fix pass comes at the end (phase 5). Every lane writes a report
with the six ethics answers to the run's checkpoint folder, and a lane that
dies is retried on Opus from its checkpoint.

1. **No-wait work.** Contracts, then lanes: `levels`, `meta-services`,
   `gameplay-bloc`, `menus`, `gameplay-ui`, `board-fx`, `overflow`; then an
   H/S level review and the integrator (E9 playthrough rewrite, the L31, L51,
   L71 and L130 segments, E13's timing, the device runs).
2. **vs Computer.** The owner is reminded here to send the Claude Design
   request, after its missing items are added to it. Contracts, then
   `race-core`, `race-bloc`, `race-ui`; the integrator adds the playthrough
   segment that beats rival 1.
3. **Star ratings, share card and reminder.**
   - Contracts: the packages pinned, plus the star rule, par in the bundle
     and `levelStars`.
   - Lanes: the star track (`stars-core`, `stars-levels`, `stars-services`,
     `stars-bloc`, `stars-ui`), then `notifications`, `share` and
     `engagement-ui`.
   - The integrator builds both platforms.

   The owner added the stars on 2026-09-28: D125,
   [star-rating.md](star-rating.md).
4. **Claude Design deliveries**, if any have landed: sync, wire, re-check.
   Otherwise nothing runs and the items stay open.
5. **Close.** Fidelity audit (`ui-designer`), accessibility audit,
   translations (8 languages), animation polish, the pass-and-play proposal;
   their fix lanes; a three-lens review (rules and correctness, security,
   ethics) and its fix pass; the `/milestone M7` gates, `nesty-test` on iOS
   and Android, and the docs.

Rejected, one line each:
- **One workflow for all of M7:** too long to steer; each phase's result
  shapes the next contracts.
- **Worktrees per lane:** nothing may be committed, and patches across 7 lanes
  merge worse than exclusive paths plus one integrator (M3's model).
- **A separate race page and bloc:** it would duplicate the tap policy, the
  board and the overlays; the race is the gameplay page with a race request
  and a `RaceCubit` beside the bloc (phase-2 contracts confirm).
- **Saving every M7 field in its own schema step:** one step, schema 1 → 2,
  carries all of them, race included, so players migrate once.

## Decisions the contracts stages record (defaults, each flagged as a question)

1. **Save schema 2** (one `SaveMigrations` step with a test on a real schema-1
   document): `levelBests {"<id>@<version>": moves}`, `records {families,
   dolls, dailies, longestRun, badges}`, `daily.lit` and `daily.run` (the
   current unbroken run), `chests.opened [levelNumber]`, `race.rivals[3]
   {unlocked, wins, raceNo}`. The step sets `lit = streak > 0`, `run =
   longestRun = streak`, `dailies = done.length`, the rest empty.
2. **Settings** stay in the `settings` box as new keys, never renamed or
   reused (they are not save fields, so no schema step): relaxed mode, reduce
   motion (`system|on|off`), and in phase 3 the reminder's on, hour, minute
   and offered.
3. **Remote Config** gains every spec-prop §9.4 key with its default.
4. **Gentle streak (E2):** `streak` counts solved days and never drops. A
   miss a freeze covers keeps `lit`; a miss without one sets `lit = false`,
   `run = 0`; the next solve relights it (`streak + 1`, `run = 1`). The chest
   stays on every 7th streak day. Streak, chest and freeze copy is rewritten
   without loss framing ("Streak saved!" included).
5. **Replay (E7):** a new `PlayRequest.replay(order)` for won bundled levels:
   no coins, no chest, no Museum, never moves `currentLevel`, never saved in
   progress (a replay loses nothing on a kill). The tutorial and intro cards
   don't repeat. Continue returns to Chapters.
6. **Best moves (E7):** bundled levels only, first play or replay, keyed
   `<id>@<version>`; the win card reads "Moves 18 · Best 16". Daily, bonus
   and race boards can't be replayed, so their card shows the moves only.
7. **Milestone chest (E5):** campaign L10, L30 … L190 and bonus N % 10 == 0;
   paid in the win's single save update (a kill loses nothing); a modal in
   5.6's system shows the contents, then opens. The win card shows whichever
   of the chest and the figurine is nearer.
8. **Relaxed mode (E6):** undo free and unlimited in every mode, the HUD badge
   "∞", no price, popup or ad row; read live, so a toggle mid-level applies.
9. **Reduce motion (E14):** the app root overrides
   `MediaQuery.disableAnimations` (system = the OS value), so every current
   reader (`context.reduceMotion`, `LottieFxView`, the board's `MotionSpec`)
   follows. Sounds and haptics are unchanged.
10. **Records and badges (E8):** families, dolls nested (the dolls that go
    inside another per nest move), dailies, the longest run, races per rival,
    best moves and levels won (derived). Every mode counts, replays and races
    included. The 12 draft badges (brainstorm §3 E8) with deterministic
    triggers; ones derivable from the save are granted on load, silently.
11. **First launch (E9):** while no level has been won, the splash opens L1;
    the first win's Continue goes to Home. A kill during L1 comes back to L1.
12. **Entry points** (no frame yet, `TODO(design)`): Chapters and Records from
    Home, Chapters also from the Museum; vs Computer as a Home tile.
13. **Overflow sizes:** 360×640 (small Android), 390×844 (standard),
    430×932 (tall), 375×667 (small iPhone), 768×1024 (iPad portrait), at
    1.0× and 1.3×.
14. **vs Computer (phase 2):** core gains a public `RivalBot` over `BotPlayer`
    (run seed `Prng.derive(raceSeed, policy, run)`, restart on "no useful
    move" or the 250 cap), `DifficultyCurve.raceSeed(rival, raceNo)` and
    `raceParams(highestLevel, tier, …)`. The app owns the clock through an
    injected ticker; the rival steps on the UI isolate (core's `BotPlayer`
    allocates nothing per move). Selecting a rival or New race starts
    `raceNo + 1`; Rematch keeps it.
15. **Reminder (phase 3):** a daily repeating local notification at the
    chosen time, inexact on Android (no exact-alarm permission); before any
    daily is solved the default time is 19:00.

## Files (the contracts stages assign exact ownership)

| Member | What changes |
|---|---|
| `packages/nesty_core` | phase 2: `simulator/rival_bot.dart` (public), `curve.dart` race params and seed, the barrel, `public_api_test`, tests (VM, node, chrome) |
| `tools` | E12 gates in `bundle_policy.dart` + tests; `tools/levels/manifest.json` and `authored/L0031…L0200.json`; README |
| `apps/game` core | `services/save/**` (schema 2, migration), `services/daily/streak_daily_service.dart`, `services/database/**` (settings keys), `remote_config_keys.dart`, `models/play_request.dart` (replay, race), new `services/{records,notifications,share}/**`, router, DI, bootstrap (motion override) |
| `apps/game` features | new `chapters/`, `records/`, `race/`; `gameplay/{bloc,pages,overlays,widgets,game}`, `home/`, `settings/`, `daily/`, `museum/`, `splash/`; `core/ui` additions |
| `apps/game` other | `app_en.arb` (+ 8 locales in phase 5), `pubspec.yaml` (phase 3), Android manifest and Gradle, iOS AppDelegate, `assets/levels/bundle.json` (built), tests, `integration_test/` |
| docs | this plan, `plans/m7-design.md`, PROGRESS, BACKLOG, TODO index, `plans/claude-design-request-m7.md` (gaps), `plans/pass-and-play-proposal.md`, `.claude/skills/review/SKILL.md` (the ethics lens, E1) |

## Reused code

`BaseAsyncCubit`/`AsyncValue`; `InMemorySaveService.update` and
`recordLevelWin` (one update per win); `SaveMigrations`; `SettingsKeys`,
`DatabaseService` streams (`symbolsModeChanges`); `StreakDailyService`;
`LevelResolver`; `DifficultyCurve`, `Generator.generateWithRetries`,
`BotPlayer`, `Prng`; `IsolateLevelGeneratorService`; the UI kit (`ModalCard`,
`NestySheet`, `HomeTile`, `NestyToast`, `NestyProgressBar`, `SettingsRow`);
the day-7 chest modal (5.6); `screen_harness.dart`; `nesty_levels` generate,
report, bundle build and check; `playthrough_test.dart` and `nesty-test`.

## Codegen

`flutter gen-l10n`, then `dart run build_runner build`, in `apps/game`. Each
contracts stage runs both. Lanes run them only through one lock script in the
checkpoint folder (an atomic `mkdir` lock), so two never run at once; the
integrator runs the final pass. `nesty_core` and `tools` need none.

## Packages (phase 3; rule-9 reasons in PROGRESS when added)

`share_plus` (E3, the OS share sheet), `flutter_local_notifications` (E4,
local offline scheduling), `timezone` and `flutter_timezone` (its local-time
daily schedule). None is in spec §13.2 and none needs a network. Versions: the
newest that resolve on Flutter 3.41.2 / Dart 3.11 without moving a locked
version (researched before the phase-3 contracts).

## Verification

- **Baseline gate** (`/milestone`): pub get with the lock unchanged except the
  phase-3 packages, codegen drift, format, `flutter analyze --fatal-infos
  --fatal-warnings`, core/render/game/admin/tools tests, core web parity,
  the token/icon/asset/TODO-index checks, `bundle check` and `fixtures
  check`, the APK dev/prod, iOS dev and admin web builds.
- **Levels:** `bundle check` over 200 levels with the E12 gates; the H/S
  review report.
- **Features:** unit and bloc tests (fake clock for the streak, reminder and
  race), widget tests on fake services, the migration test, the E1 tests
  (no race hint or +1 Slot; streak, chest and reminder copy free of loss
  framing; the reminder off on a fresh install; no reward outside the seeded
  PRNG).
- **Overflow:** every screen at the 5 sizes × 1.0/1.3.
- **Device:** `flutter drive` on the iPhone 16 Pro simulator and the API 35
  emulator: the E9 playthrough with E13's time, the mechanic segments, the
  race segment, resume and daily; `nesty-test` on both at the close.
- **Owner:** the fidelity sign-off, the haptics and mix by ear, the M2/M3
  device checks, E13's seconds on a phone, a reminder on a phone.

## Risks

- **Shared files** (the gameplay view, ARB, the router, DI): exclusive paths,
  keys and routes added up front, a codegen lock, and the integrator.
- **Level quality:** bots grade and agents review H/S levels, but only the
  owner's play proves feel; the report lists what to play first.
- **Native notification setup** (desugaring, receivers, the iOS delegate):
  both platforms are built and run in phase 3, not only in the close.

## Open questions for the owner (the defaults above ship unless answered)

Decisions 1–15 are recorded as D94+ with a Q each where they choose between
readings: best moves on daily and bonus boards (6), the chest paid at the win
(7), replays not saved in progress (5), records counting every mode (10),
the reminder firing daily even after that day's solve (15), and the entry
points (12). Still blocked on the owner, as before: Q29 (tabular figures),
Q16 (iPad orientation), Q65, Q66, `forest-bear`, the haptics and mix by ear.
