# Claude Code prompt: build the kid path and the characters' wave 1

Paste everything below the line into a fresh Claude Code session in the
repo. Run `/clear` first if the session already has another task in it. It
starts the next phase, which the owner picked on 2026-10-10 (D316): the kid
path's local part (D260) and the themes' wave 1 (D275: TC7, TC8, TC1),
built together. As D297 did for the local habits, it starts while M7's, the
daily gift's and the local habits' sign-offs stay open.

The design comes from [claude-design-request-m7-7.md](claude-design-request-m7-7.md)
(App Flow sections 15 and 16). Send it to Claude Design at the same time;
the build starts on `TODO(design)` stand-ins, as the local habits did.

---

Build the next phase I picked on 2026-10-10 (PROGRESS D316):
- **the kid path's local part** (D260, Q174's defaults): the age question,
  the parental gate and the parent area, and the kid-path states of the
  screens that offer the reminder, sharing, links out and purchases;
- **the characters' wave 1** (D275): TC7 the living dolls, TC8 the
  Computer's friendly reactions and TC1 the Nest Keeper mascot.

The race-loss card keeps its designed hop (D273, confirmed again on
2026-10-10), so TC8 adds no bow. Build it all fully offline (D269). Log the
start as D317, take new decisions from D318 and new questions from Q194
(check PROGRESS first: another session may have taken numbers since).

**Read first, by section, not whole:**
- `docs/plans/engagement-research.md` §6 (6.1 to 6.5): the kid path, what
  the rules require, Q174's defaults, the spec text waiting for my paste,
  and the design request.
- `docs/plans/themes-characters-story.md` §0 (no licensed characters), §2
  (how every proposal must fit), TC1, TC7, TC8, §5 (the animation
  catalogue) and §9 (TC-DATA).
- BACKLOG "Engagement research and the kid path" (the kid path's items) and
  "Themes, characters and story" (wave 1). That is the work list; tick each
  item with its evidence.
- PROGRESS D92 (the respect rules), D237, D260, D269, D270, D273, D275 and
  D316; spec §1, §10.2, §11.3, §12, §16 and §17; spec-prop §1.1.
- CLAUDE.md "Working within Claude's usage limits" and "Watch every long
  run".

**What the code already has (checked 2026-10-10; verify before relying on it):**
- No age, birth date, parental gate or kid-path code or string exists. The
  only mention is a `TODO(M4)` comment about kid-path analytics at
  `core/router/widget_link.dart:85`.
- A fresh install goes Splash → Level 1 (`core/router/app_router.dart:30`).
  The win card (`features/gameplay/overlays/win_overlay.dart`, about :762)
  offers Continue or Back to Chapters; `gameplay_bloc.dart` decides what
  comes next. Find the exact point after Level 1's win where the age
  question fits without slowing Level 1.
- Settings (`features/settings/pages/settings_page.dart`), in order: Sound,
  Music, Haptics; the reminder toggle and its time row, Relaxed mode,
  Reduce motion; Color symbols; Language, Restore Purchases and Privacy
  choices (both disabled until M6), Privacy Policy and Support (each shown
  only when its value in `core/services/links/app_links.dart` is set).
- Sharing: `ShareService` (`core/services/share/`), offered only by the
  daily win's Share button (`win_overlay.dart`, about :751). The reminder
  offer is `features/daily/widgets/reminder_offer_dialog.dart` with
  `ReminderOfferCubit`, mounted on the Daily page; the reminder itself is
  `core/services/reminder/daily_reminder.dart`. Links out go through
  `LinkLauncher`, from Settings only.
- The Shop (`features/shop/`) has four tabs: Coins, Skins, Themes, No Ads.
  Coins and No Ads show `shop_closed_card.dart` until M6, and nothing in
  the Shop uses `PurchaseService` yet. There is no starter pack in code.
- Storage: a settings key is a `SettingsKeys` constant
  (`core/services/database/settings_schema.dart`) with a `SettingsDefaults`
  entry and needs no schema step. A save field (`SaveDocument`, schema 4)
  is a schema step with a migration (`migrations-engineer`).
- The board's dolls: `BoardComponent` forwards taps as a `SlotTapped` intent
  (`features/gameplay/game/components/board_component.dart`, about :812);
  nothing on the board idles today. Reduce motion is read in
  `board_component.dart` and `nesty_game.dart`. A doll's face is its own
  cached raster in the lid group (`packages/nesty_render/lib/src/skin/skin_layer.dart`,
  `doll_part_rasters.dart`), so a blink needs a new part or a transform of
  that raster, never a re-raster per frame (rule 8).
- Home's plank dolls play `doll_idle` (`features/home/showcase/showcase_dolls.dart`).
- The race: `ui_rival_react` is one Lottie with segments idle (0–180),
  family (180, 40 f), win (220, 80 f) and lose (300, 80 f), played through
  `FxId.uiRivalReact` (`core/ui/widgets/race/rival_react.dart`,
  `features/race/widgets/rival_strip.dart`, `race_result_overlay.dart`).
  `RaceState` holds only `totalSets` and `rivalSets`: no event says the
  player completed a family. The gameplay timeline's `Completed` event and
  its FX are the nearest source.
- The tutorial (`features/gameplay/overlays/tutorial_overlay.dart`,
  `bloc/tutorial_script.dart`) is a plain tooltip; no character speaks
  anywhere. The out-of-moves sheet (`overlays/out_of_moves_sheet.dart`) has
  three rows with coin and free-undo chips.
- `CatalogRepository` (`core/repository/catalog_repository.dart`, bundled
  Dart constants, real and fake) has no `characters` accessor yet.
- Sounds are the `SoundEffect` enum (`core/services/audio/audio_service.dart`)
  mapped in `sfx_mix.dart`; a new one comes from `design/audio` and
  AUDIO.md through `sync_design_assets`. A Lottie comes from `design/lottie`
  and LOTTIE.md through `gen_fx_spec` into `FxId`.
- Nothing measures play time today; `WelcomeBackTracker` notes opens only.
- Remote Config keys follow `RemoteConfigKey<T>._('name', default)` in
  `remote_config_keys.dart`, added to `all`.

**Stages.** Each stage keeps a checkpoint file in `build/kid-path-wave-1/`
(git-ignored) and appends its findings to its report as it goes.

0. **Plan (Opus, no code).** Write `docs/plans/plan-kid-path-wave-1.md`:
   - **The kid path's rules as spec-prop text, "§17a The kid path"**, in the
     plan, as §7.5c sat in `plan-local-habits.md`. Engagement-research §6.4
     is the text for spec §1 and §17 that I paste; §17a adds the details:
     - when the age question is asked: after Level 1's win, never during a
       level and never at launch; and for a player who won Level 1 before
       this update (default: once, after their next win);
     - what is stored: month and year only, on the device. Pick a settings
       key or a save field, with the reason;
     - the age band (under 13, 13 and over, unknown) worked out from the
       answer and today's date, so a child who turns 13 moves to the adult
       path by itself; unanswered means the kid path;
     - no default value and no wrong answer; whether a quiet way past the
       question exists (default: none, and any answer continues);
     - the gate: what it asks (default: a number written in words, typed
       as digits, in all nine languages), a new number after a wrong try,
       no lockout and no timer, and whether a pass covers one action or the
       whole visit to the parent area;
     - the parent area: where it is entered, what it holds (the reminder
       and its time, sharing, Privacy Policy, Support, the age, and
       Purchases from M6), and how Settings looks on the adult path;
     - what the kid path changes today: the reminder offer is never shown;
       sharing is off until a grown-up turns it on, and the Share button is
       hidden while it is off; links out ask the gate; the Shop's Coins and
       No Ads tabs get the gate hook for M6;
     - a player whose answer puts them on the kid path after a reminder
       was already set (default: keep it, and show it in the parent area);
     - analytics: nothing before the age answer and nothing on the kid path,
       enforced now in front of `AnalyticsService` (the fake until M4), so
       M4 inherits it.
   - **The characters' behaviour** (cosmetic, no game rule; rule 10):
     - TC7: which dolls idle, how often, the stagger, the blink on stand-ins
       given the face raster, the tap squish and the "home" bounce, the
       Museum figurines' tap wave, reduce motion (idles off), and the
       battery rule (idles stop after 30 s without input and in the
       background), within rule 8's budget;
     - TC8: the wave at the race's start, and the cheer when the player
       completes a family (default: the player's first family of the race,
       at most once per race, never on a loss). The Computer is always
       labelled "Computer";
     - TC1: every place the Nest Keeper appears (Home, the tutorial's
       voice, the win card, the moment after out of moves, the gentle
       break) and every place she never appears (the Shop, ads, purchases,
       the out-of-moves sheet's offers, the booster popup, any loss offer).
       The break: how play time is measured, the threshold as a Remote
       Config key, and that sleeping is only a look: it never blocks play,
       shows no timer and says nothing guilty. Her name stays off screen
       until the legal check (D275); code uses the id `nestKeeper`.
   - **What I control later through Remote Config or the catalog (D269):**
     the break's threshold, and the characters' lines and looks through a
     `characters` accessor on `CatalogRepository` (TC-DATA), with bundled
     defaults in real and fake.
   - **Per item:** the strings, the host tests, the device step (D169) and
     the TEST_COVERAGE row.
   - **The BACKLOG work list:** expand the kid path's and wave 1's items
     into checkable items, as "Local habits" was.

   Then **stop and ask me to approve §17a and its defaults**, and the
   characters' rules. Stages 2 and 3 may run while I answer; stage 1's code
   waits for my answer.
1. **The kid path** (after I approve §17a).
   - The age question, the gate sheet and the parent area (an
     `@RoutePage` page), on stand-ins (`TODO(design)`).
   - Pure rules beside the others in `core/services/` (the age band, the
     gate's check); any I/O behind an interface with real and fake (rule 4).
   - The gated surfaces: the daily win's Share, the reminder offer and
     Settings' reminder rows, Privacy Policy and Support, and the Shop's
     M6 hook.
   - The analytics gate in front of `AnalyticsService`, with tests.
   - Tests: the band at 12 years 11 months, 13 years 0 months and an
     unanswered age; the pickers in nine locales; the gate's wrong and right
     tries; every gated surface on both paths; the overflow suite in nine
     locales; `test/ethics/kid_path_respect_test.dart` (no default, no
     lockout or timer, nothing that scolds, and no "too young", "kids mode"
     or "for kids" in any locale).
   - Device step: a new `integration_test/kid_path_test.dart` that
     `nesty-test` drives: a fresh install, Level 1's win, the age question;
     on the kid path, Share hidden on the daily win and the parent area
     behind the gate (a wrong try, then a right one); on the adult path,
     Settings as before.
2. **TC7, the living dolls** (`flame-engineer`).
   - Flame tweens on the existing components: transforms only, no game
     truth (rule 10), pre-built curves and no per-frame allocation (rule 8).
   - A pure scheduler for the idles, host-tested (timings, stagger, the
     30 s stop, reduce motion, backgrounding).
   - The tap squish and the "home" bounce follow the board's existing tap
     and `MoveEvent` order; they never delay input or a move.
   - The Museum figurines' tap wave.
   - Device step: a playthrough step that checks the idle runs and stops
     (through a test seam), with a screenshot. The 60 fps check on a 2 GB
     Android is mine: add it to BACKLOG "Owner inputs needed" with the
     `/perf-profile` steps.
3. **TC8, the Computer's reactions.**
   - A race event when the player completes a family, from the gameplay
     timeline's `Completed` to `RaceCubit`.
   - The wave at the start and the cheer, on stand-ins (reuse
     `ui_rival_react`'s segments, `TODO(design)`) until m7-7's segments
     arrive. The loss card keeps its `win` hop (D273).
   - Tests: the cubit's event, at most once per race, none on a loss; the
     race device step extended with the wave and the cheer.
4. **TC1, the Nest Keeper** (after stage 1, so her win-card moment and the
   age question share one order).
   - The `characters` accessor (TC-DATA) in real and fake, with bundled
     defaults.
   - A `NestKeeper` widget on a Lottie slot with a stand-in still until
     m7-7's segmented Lottie arrives; the play-time measure and the break.
   - Her lines in nine catalogs; the tutorial's copy pass, in her voice.
   - Tests: widget tests for each placement; a test that she never appears
     on the Shop, the out-of-moves sheet, the booster popup or any offer;
     `test/ethics/characters_respect_test.dart` (no guilt, no "don't go",
     no "I missed you", nothing scary, in every locale).
   - Device step: playthrough shots of Home, the tutorial and a win with
     her.

**Every stage also ships:**
- the strings in all nine catalogs, with the Opus translation review (D240);
- `gen_font_subsets` and `build_fonts.sh` if a `hi` or `ja` glyph is new;
- its device step and TEST_COVERAGE row (D169);
- CLAUDE.md's Code map for each new feature, service or accessor.

**Device runs.** Write each run as a background script. Run them once after
stages 1 to 3 and again after stage 4, with the full `nesty-test` on the
iPhone 16e and the Android emulator, and judge every new shot against the
stand-in intent.

**Close:**
- `/review` with the security scanner and the ethics lens, then fix what it
  finds;
- PROGRESS, with the decisions, the Status row and "Next step";
- BACKLOG ticked;
- CLAUDE.md's Code map, Commands and Current state;
- `dart run nesty_tools:todo_index`;
- the full `nesty-test --only gates`.

When `nesty-design-m7-7` arrives, I'll ask for its import as a separate task
(the m7-6 way: tooling, copy, swap the stand-ins, device run, fidelity).

**My standing rules (verbatim):**
- Never edit GAME_SPEC.md or anything in design/.
- Keep CLAUDE.md's facts current in the same change, and never change its
  rules.
- Rules come only from the spec, spec-proposals-m7.md and PROGRESS
  decisions, never from tokens.json. For the kid path, the plan's §17a
  counts as spec once I approve it.
- If something is still ambiguous, stop and ask.
- Never reuse a Hive box name, typeId or field index. A new save field is a
  schema step with a migration.
- A new package or font needs its reason in PROGRESS.
- Every new or changed feature ships with host tests, a nesty-test device
  step and its TEST_COVERAGE row (D169).
- Leave my iPhone 15 Pro Max simulator alone (5D28401E-76FA-40BA-B458-5DCD9C8A9D55):
  - never boot, shut down, erase, install on or screenshot it;
  - never run `simctl shutdown all`;
  - always pass a UDID.

  Use the iPhone 16e (87BDED37-4095-49C4-811A-3E2B7D5FB38B) and the Android
  emulator (AVD `flutter_emulator`). Warm the emulator up for 90 s after it
  boots.
- Check for at least 20 GB free before each device run. If space is short,
  tell me instead of deleting anything outside the repo and the scratchpad.
- Every long run gets a watcher (D295):
  - it runs detached with `nohup`, its log under `build/`;
  - `tools/scripts/watch-run` watches it under the Monitor tool;
  - on an alert, the `run-watcher` agent fixes the cause at once.
- Commit at sensible points (D310): conventional commits, no attribution,
  never force-push. Don't push until I say. Never commit secrets or real
  AdMob IDs.
- There is no Apple Developer account yet (D313): simulators only.
- The respect rules (D92, spec-prop §1.1), for every item:
  - nothing pops up on its own except the one age question, and no new
    notification;
  - no countdown, no timer and no lockout, on the gate too;
  - a child is never blocked, scolded or told they are too young, and no
    screen says "kids mode" or "for kids";
  - nothing personal leaves the phone; the age stays on the device;
  - a character never sells, never appears in the Shop, an ad, a purchase
    or a loss offer, never guilts or mocks, and is never scary;
  - the Computer is always labelled "Computer".

Start with stage 0, and tell me when each stage is done.
