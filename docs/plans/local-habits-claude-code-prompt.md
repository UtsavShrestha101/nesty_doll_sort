# Claude Code prompt: build the local habits

Paste everything below the line into a fresh Claude Code session in the
repo. Run `/clear` first if the session already has another task in it. It
starts the next phase: the four local habits (D274's order). D272's reasoning
lets it start while M7's and the daily gift's sign-offs stay open.

The design comes from [claude-design-request-m7-6.md](claude-design-request-m7-6.md)
(App Flow section 14). Send it to Claude Design at the same time; the build
starts on `TODO(design)` stand-ins, as the daily gift did.

---

Build the four local habits I picked (PROGRESS D274, Q162), in this order:
1. welcome back;
2. a month of played days;
3. the last 7 dailies, playable;
4. the home-screen widget, last.

Build them fully offline (D269). As D272 did for the daily gift, start now,
while M7's sign-offs (Q161, the VoiceOver pass) and the gift's (§7.5b,
Q187, Q188) stay open. Log that as D297. Take new decisions from D298 and new
questions from Q189.

**Read first, by section, not whole:**
- `docs/plans/local-habits-brainstorm.md`, "The four proposals". It is the
  proposal; the rules come from the plan you write in stage 0 once I approve
  it.
- BACKLOG "Local habits". That is the work list; tick each item with its
  evidence.
- PROGRESS D92 (the respect rules), D237, D269, D272 and D274; spec §7.5 and
  spec-prop §7.5 (the daily and its gentle streak).
- CLAUDE.md "Working within Claude's usage limits" and "Watch every long
  run".

**What the code already has (checked 2026-10-08; verify before relying on it):**
- The Daily page (`features/daily/pages/daily_page.dart`) stacks
  `StreakCard`, `DayStrip`, `ChestRow` and `PuzzleCard`. `DayStrip` draws
  the streak's 7-day cycle from `DailyStatus.cycleDone` and `solvedToday`,
  not calendar dates.
- `DailyProgress` (`core/services/save/save_document.dart`) already keeps
  `done` (solved dates, at most `maxDates = 31`) and `frozen`. That is enough
  for the current month.
- `StreakDailyService._solveOn` only appends to `done` when the date isn't
  today (a board started before midnight). An archive solve must not use that
  path: it would light the month and push current-month dates out of `done`.
- `PlayRequest.daily(yyyymmdd)` and `progressAfterSolve(date)` accept any
  date, but an old date today would:
  - pay `dailyReward` (`default_level_resolver.dart` `_daily`, and
    `recordLevelWin`'s coin path in both save services);
  - append to `daily.done`, and bump `records.dailies` and `lastSolve`;
  - share the one `daily.inProgress` slot, so it would overwrite today's
    board in progress.

  All four need a separate archive path.
- No "last opened" date is stored. `LoginGiftProgress.latestSeen` is close,
  but it is only written once the gift unlocks, and `LoginGiftCubit`
  overwrites it on every Home load, so don't build on it. A settings key
  (`settings_schema.dart`) needs no schema step; a save field does.
- Home (`home_page.dart`, `HomeLayout`'s 2.1/2.1b blend) has no free slot
  for a card. The Home stack is: the header with the gift button, the chapter
  card with Records, the plank, Play, and the tiles row. D92 rules out a popup
  on its own.
- The save is schema 3, freezed JSON in one Hive string, and no Hive typeIds
  are assigned. There is a schema-2 fixture, but no schema-3 fixture yet.
- Widget prerequisites:
  - no widget package in any pubspec;
  - iOS targets 14.0 (WidgetKit yes, interactive widgets no), with Runner and
    RunnerTests targets only, no entitlements and no App Group;
  - the build configurations are {Debug, Profile, Release} × {dev, stg,
    prod};
  - the bundle ids are `com.futrix.nesty`, `.dev` and `.stg`;
  - Android has `minSdk 24`, three product flavors and no AppWidgetProvider.
- `nesty-test`'s `daily_states` check loops the scenarios `chest paused
  saved settings` of `integration_test/daily_states_test.dart`, under
  `NESTY_FAKE_DATE` and `NESTY_DAILY_SCENARIO`.

**Stages.** Each stage keeps a checkpoint file in `build/local-habits/`
(git-ignored) and appends its findings to its report as it goes.

0. **Plan (Opus, no code).** Write `docs/plans/plan-local-habits.md`:
   - **Per habit:** the data and where it lives, the rules, the UI on
     stand-ins, the strings, the host tests, the device step (D169) and the
     TEST_COVERAGE row.
   - **The archive rule as spec-prop text, "§7.5c Past dailies"**, in the
     plan, as §7.5b sits in `plan-login-gift.md`. It covers:
     - the window, today − 7 to today − 1;
     - the same board on every phone, from `dailyParams(date)`;
     - an archive solve never moves the streak, never grants or spends a
       freeze, never counts toward the day-7 chest, and can't repair a
       paused streak;
     - what an archive solve pays. Default: nothing, so it can't be farmed.
     - whether it counts in Records' dailies. Default: no.
     - whether the month lights it. Default: yes, with a quieter "played
       later" mark.
     - replays. Default: allowed, paying nothing.
   - **What I control later through Remote Config (D269):** the welcome-back
     gap (2 days) and the archive window (7 days), as int keys with bundled
     defaults.
   - **The widget's plan.** Use `web-researcher` for the current
     `home_widget` (or a reason for platform channels instead), and cover:
     - WidgetKit: an extension target in all nine build configurations and
       an App Group per flavor;
     - Android: an AppWidgetProvider per flavor;
     - rolling over at local midnight without the app (an iOS timeline entry,
       an Android update);
     - what the app writes, and when;
     - how it is tested, given that `flutter drive` can't place a widget.
   - **The BACKLOG work list:** expand "Local habits" into checkable items,
     as "Daily gift" was.

   Then **stop and ask me to approve §7.5c and its defaults.** Stages 1
   and 2 may run while I answer; stage 3's code waits for my answer.
1. **Welcome back.**
   - The open date is written on each app open and resume, after the
     previous value is read.
   - The card shows when the gap is at least the Remote Config gap, the Daily
     is unlocked and today isn't solved. It sits inline on Home (stand-in
     placement, `TODO(design)`), with variants for: a freeze kept the flame,
     paused with the number kept, and no streak yet.
   - One tap plays today's daily. It can be dismissed (48 dp), and it goes
     once today is solved or the date changes.
   - No notification, no auto-shown modal, no "lost", "missed" or "broken".
   - Tests: cubit and widget tests, the clock wound back (no card), the
     overflow suite in nine locales.
2. **A month of played days.**
   - The Daily page shows the current month from `daily.done`: a solved day
     is lit, an unsolved day blank, with today marked.
   - No red mark, no X, no broken chain and no "missed".
   - The week starts on the locale's first day (`intl`), and the month and
     weekday names come from `intl` in the nine locales.
   - The streak rules don't change; `DayStrip` stays the streak's cycle unless
     the design says otherwise.
   - Tests: widget tests for the 1st and the 31st of a month, a month with
     freezes, and the readability floor in `ja` and `hi`.
3. **The last 7 dailies, playable** (after I approve §7.5c).
   - `migrations-engineer` does save schema 3 → 4: the archive's solved dates
     separate from `daily.done`, and the archive's own board in progress (or
     none), never today's slot. It adds a schema-3 fixture and the migration
     and contract tests.
   - A `PlayRequest` case for an archive day that pays what §7.5c says and
     records nothing on the streak.
   - The picker sits in the month: the last 7 days are tappable.
   - The puzzle card for a past date has no coin chip. The board's date pill
     shows the past date, and the win card shows "Moves N" with no coins and
     no streak change.
   - No "expires", "last chance" or countdown on the window.
   - Tests: core's generator determinism for past dates, the bloc and save
     paths (no coins, no streak, no freeze, no chest, no `records.dailies`),
     and today's in-progress board surviving an archive game.
4. **The widget** (only after 1–3 pass on both devices).
   - The package's reason goes in PROGRESS (rule 9).
   - It shows today's puzzle as ready or solved, the streak number and the
     flame, and the paused look with the number kept. Tapping it opens the
     Daily (an auto_route deep link). It works offline and with no ad.
   - Native work:
     - iOS: the extension in dev, stg and prod (build each flavor with
       `--no-codesign`), the shared App Group store, and a timeline entry at
       local midnight;
     - Android: the provider, its layout and preview, the flavors' authority
       and name, and the midnight update.
   - Tests:
     - host tests for the data the app writes (a `HomeWidgetService` behind
       an interface with a fake, rule 4);
     - native tests where cheap (a Swift timeline test, an Android
       instrumented or Robolectric layout test);
     - a device step that asserts the shared store and the deep link.

     The TEST_COVERAGE row says why a simulator can't place the widget.
   - The App Group in the Apple Developer account, and a real-phone check,
     go to me in BACKLOG "Owner inputs needed", with exact steps.

**Every habit stage also ships:**
- the strings in all nine catalogs, with the Opus translation review (D240);
- `gen_font_subsets` and `build_fonts.sh` if a `hi` or `ja` glyph is new;
- `test/ethics/local_habits_respect_test.dart`, on the `login_gift_respect_test`
  pattern, which scans the habits' code and copy in every locale;
- its device step (D169):
  - welcome back, the month and the archive as new `daily_states` scenarios
    (or their own `integration_test/*_test.dart` driven by `nesty-test`);
  - a playthrough shot where Home or the Daily changes;
  - the TEST_COVERAGE rows;
- analytics events, if any, through `AnalyticsService` (the fake until M4),
  and none for the kid path's under-13s.

**Device runs.** Write each run as a background script. Run them once after
stage 3 (habits 1–3) and again after stage 4, with the full `nesty-test` on
the iPhone 16e and the Android emulator, and judge every new shot against the
stand-in intent.

**Close:**
- `/review` with the security scanner and the ethics lens, then fix what it
  finds;
- PROGRESS, with the decisions, the Status row and "Next step";
- BACKLOG ticked;
- CLAUDE.md's Code map, Commands and Current state;
- `dart run nesty_tools:todo_index`;
- the full `nesty-test --only gates`.

When `nesty-design-m7-6` arrives, I'll ask for its import as a separate task
(the m7-5 way: tooling, copy, swap the stand-ins, device run, fidelity).

**My standing rules (verbatim):**
- Never edit GAME_SPEC.md or anything in design/.
- Keep CLAUDE.md's facts current in the same change, and never change its
  rules.
- Rules come only from the spec, spec-proposals-m7.md and PROGRESS
  decisions, never from tokens.json. For the archive, the plan's §7.5c counts
  as spec once I approve it.
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
- Don't commit until I say. Conventional commits, no attribution, never
  force-push. Never commit secrets or real AdMob IDs.
- The respect rules (D92, spec-prop §1.1), for every habit:
  - nothing pops up on its own, and no new notification;
  - no countdown, no timer, no "expires", "last chance" or "missed";
  - no red mark and no broken chain; blank is not a failure;
  - a gap never lowers anything, and an old day never repairs or moves the
    streak;
  - no ad or purchase in any habit's path, and nothing paid unlocks a past
    day.

Start with stage 0, and tell me when each stage is done.
