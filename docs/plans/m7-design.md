# M7 design — the offline game (authoritative)

Status: phase 1 written 2026-09-28 by the M7 phase-1 contracts stage from the
approved [plan-m7.md](plan-m7.md) (its decisions 1–13 are the defaults
recorded here). Every M7 lane follows this document; where it and the plan
differ, this document wins. BACKLOG cites it as "m7 §n". Decisions are
PROGRESS D95–D110; the owner questions are Q88–Q98. A default the owner may
still overturn says "(default, Qn)". Phases 2, 3, 4 and 5 add their
sections below when their contracts stages run (phase 2: P2.1–P2.15; phase
3: P3.1–P3.15; phase 4: P4.1–P4.10).

Sources, in the CLAUDE.md order: the spec, and until the owner pastes it
(Q85) the approved text of [spec-proposals-m7.md](spec-proposals-m7.md)
("spec-prop"), then `design/` (nothing of the M7 Claude Design request has
landed, so every new screen is a stand-in built from the tokens, §15), then
the owner's decisions D18–D23, D63–D65 and D90–D93. The reasons are in
[offline-game-brainstorm.md](offline-game-brainstorm.md) §3–§5 ("brainstorm")
and the race in [mode-vs-computer.md](mode-vs-computer.md) ("vs-computer").

M7's acceptance (spec-prop §18): **matches the design screens; no layout
overflows on 5 screen sizes; levels 1–200 bundled, valid, solvable and on
schedule; vs Computer, Records, the reminder, relaxed mode, replay and the
gentle streak work fully offline**; every feature passes the ethics
checklist (brainstorm §5, the last section here).

## 1. What the contracts stage froze

These files exist, compile (`flutter analyze --fatal-infos --fatal-warnings`
clean), are documented and have minimal tests. A lane adds behaviour where
§18 says so and never changes a frozen signature; a needed change goes in its
report for the integrator. "Implemented" means the body is complete and
tested, and the owning lane only extends its tests.

| Area | Files (frozen) | State |
|---|---|---|
| Models | `core/models/play_request.dart`: `PlayKind.replay`, `PlayRequest.replay(order)` = `ReplayPlay`, `isBundled`, `isReplay`, `isGenerated` (bonus or daily); `core/models/reduce_motion_mode.dart` (`ReduceMotionMode.system/on/off`, `resolve`, `fromStorage`) | implemented |
| Save schema 2 | `core/services/save/save_document.dart` (`levelBests`, `records` = `SaveRecords`, `chests` = `ChestProgress`, `race` = `RaceProgress`/`RivalProgress`, `DailyProgress.lit`/`run`/`paused`/`relitOn`, `LevelWinRecord.bestKey`/`chest`/`families`/`dolls`/`boardBadges`, `LevelWinOutcome`, `ChestGrant`/`ChestSource`), `save_document_codec.dart`, `save_migrations.dart` (step 1 → 2), `save_service.dart` (`LevelWinOutcome recordLevelWin(...)`, `int? bestMovesFor(key)`), `in_memory_save_service.dart` (the M7 win path §7, the replay guard, the load-time badges), `hive_save_service.dart` (load-time badges) | implemented |
| Meta rules | `core/services/records/{badge,badge_rules,record_rules,records_summary}.dart` (`BadgeId`, `BadgeRules`, `RecordRules`, `LevelBests`, `RecordsSummary`); `core/services/chest/milestone_chest.dart` (`MilestoneChest`) | implemented |
| Daily | `core/services/daily/daily_status.dart`: `lit`, `run`, `paused`; `StreakDailyService` publishes them | fields only: the gentle-streak algorithm (§8) is the meta-services lane's |
| Settings | `SettingsKeys.relaxed`/`reduceMotion`, `SettingsDefaults.relaxed`/`reduceMotion` (`settings_schema.dart`); `DatabaseService.{relaxedMode, setRelaxedMode, relaxedModeChanges, reduceMotion, setReduceMotion, reduceMotionChanges}` in Hive and the fake; the shared contract test | implemented |
| Remote Config | the ten spec-prop §9.4 keys (§5) | implemented |
| Resolver | `LevelResolver` docs; the replay case of `DefaultLevelResolver` and `FakeLevelResolver`; `ContentReadyGuard` checks every bundled request (campaign and replay) | implemented |
| Routes | `ChaptersRoute` (`features/chapters/pages/chapters_page.dart`), `RecordsRoute` (`features/records/pages/records_page.dart`), pushed on the root router, guarded by `ContentReadyGuard`, music_home | stub pages (a plain list) |
| Cubits | `ChaptersCubit(save, levels, catalog)` + `ChaptersState`/`ChapterSection`/`ChapterLevel`/`ChapterLevelStatus`; `RecordsCubit(save, levels)` + `RecordsState` | implemented (load, follows the save) |
| Gameplay bloc | constructor `(levels, solver, remoteConfig, save, analytics, resolver, daily, clock, settings)` (the 9th, `DatabaseService`); event `RelaxedModeChanged`; `GameplayState.{relaxed, dailyRelit, winMoves, bestMoves, previousBest, chestLevelsLeft, chest, newBadges, firstWin}` and `isReplay` | `relaxed` read at start and followed live; the rest are the gameplay-bloc lane's |
| Home | `HomeCubit(save, levels, resolver, daily, catalog, remoteConfig)` (the 6th); `HomeState.{dailyLit, raceUnlockLevel, raceUnlocked}` | implemented |
| Settings UI state | `SettingsState.{relaxedMode, reduceMotion}`, `SettingsCubit.{setRelaxedMode, setReduceMotion}` | implemented |
| Splash | `SplashState.opensFirstLevel` (E9) | field only (gameplay-bloc lane) |
| Skin | `SkinService.selectedSkinChanges` (Asset, Fake, the test `ControlledSkinService`) | implemented |
| UI kit | `core/ui/widgets/feedback/badge_toast.dart` (`BadgeToast.show(context, badge)`, `iconOf`), exported by `nesty_ui.dart` | implemented |
| Copy | 54 ARB keys (§16) and three rewrites (§8), gen-l10n run | final English is Claude Design's (G.6–G.9) |
| E1 tests | `test/ethics/respect_copy_test.dart`, `test/ethics/reward_randomness_test.dart` (§17) | implemented |

DI: `ChaptersCubit` and `RecordsCubit` are `@injectable` factories. No new
service is registered: the meta rules are pure Dart over `SaveService`, like
M3's streak (there is no `RecordsService`; the Records screen reads
`RecordsSummary.of(save.document, levelCount:)`).

## 2. Stages, lanes and codegen

Phase 1 ("no-wait work", plan §Approach):

1. **Contracts** (done): this document, the frozen files, PROGRESS D95–D110
   and Q88–Q98, the BACKLOG decision items.
2. **Parallel lanes** (§18): `levels` (already running), `meta-services`,
   `gameplay-bloc`, `menus`, `gameplay-ui`, `board-fx`, `overflow`.
3. **H/S level review** (agents play every H and S level through its solution
   and one casual run; the levels lane's report lists what to play first).
4. **Integrator**: every cross-lane edit, DI and codegen's final pass, the E9
   playthrough rewrite, E13's timing, the L31, L51, L71 and L130 playthrough
   segments, the TODO index, the device runs, the ethics checklist rows.

**Codegen:** only through the lock, from anywhere:

```sh
LANE=<lane> bash /private/tmp/claude-501/-Users-utsav-Downloads-nesty/5ca50ca4-7f3a-4fdd-b24a-b8b04a3923b6/scratchpad/m7/bin/codegen.sh l10n|build|all
```

It takes an atomic `mkdir` lock (a lock older than 20 minutes is taken
over), runs `flutter gen-l10n` and/or `dart run build_runner build` in
`apps/game`, and prints build_runner's tail. Never run either tool directly.
`nesty_core` and `tools` need none. The contracts stage ran `all` once at the
end of its edits; `lib/l10n/app_en.arb` is complete for phase 1, so a lane
that needs another key lists it in its report and the integrator adds it.

## 3. Save schema 2 (spec-prop §13.3; plan decision 1)

### 3.1 The document

Schema 2 is schema 1 (m3 §3.1) plus these keys, written after `playerId` in
this order, then the unknown keys sorted:

```json
{
  "schema": 2,
  "...": "every schema-1 key as m3 §3.1 has it",
  "daily": {"streak": 11, "lit": true, "run": 2, "lastDate": "2026-10-06",
            "freezes": 0, "freezeWeek": 202641, "done": ["2026-10-06"],
            "frozen": ["2026-10-05"], "noticeDate": null,
            "chestPending": false, "inProgress": null},
  "levelBests": {"L0024@2": 16, "L0003@1": 9},
  "records": {"families": 212, "dolls": 780, "dailies": 12, "longestRun": 9,
              "badges": ["first_family", "glass_breaker"]},
  "chests": {"opened": [10, 30], "bonusOpened": [10]},
  "race": {"rivals": [{"unlocked": true, "wins": 3, "raceNo": 5},
                      {"unlocked": true, "wins": 0, "raceNo": 1},
                      {"unlocked": false, "wins": 0, "raceNo": 0}]}
}
```

- `daily.lit` and `daily.run` sit after `streak` (§8 defines them).
- `levelBests`: `"<levelId>@<version>"` → the fewest moves (≥ 1),
  `LevelBests.key` (§11).
- `records`: lifetime counts and the badge ids, in the order earned (§12).
- `chests.opened`: campaign orders whose milestone chest was opened;
  `chests.bonusOpened`: bonus numbers. The second list is an addition to
  spec-prop §13.3's example: a chapter published later (M4, L210) must never
  collide with a bonus number (D97).
- `race.rivals`: exactly three, in order (vs-computer rule 12). A fresh
  save has rival 1 `unlocked: true` (the mode itself unlocks at
  `race_unlock_level`, §5), rivals 2 and 3 locked, `raceNo` 0 (none yet).
  Phase 2 writes it.
- Settings stay in the `settings` box (m3 §3.1's deviation; §4).

### 3.2 Codec rules (`SaveDocumentCodec`, implemented)

As m3 §3.3 (lenient, never throws, unknown top-level keys kept and written
back, unknown nested keys dropped), plus:

- `daily`: `run` is an int ≥ 0; `lit` is the stored bool, or `run > 0`
  when missing; a pair that disagrees reads as paused (`lit` false, `run`
  0). So after any read, `lit == (run > 0)`.
- `levelBests`: entries with a non-empty key and an integral move count ≥ 1;
  others are skipped.
- `records`: each count an int ≥ 0, else 0; `badges` distinct non-empty
  strings, first occurrence kept, **unknown ids kept** (a newer app's badge
  survives a downgrade; `SaveRecords.earned` shows only known ones).
- `chests`: distinct ints ≥ 1, ascending, per list.
- `race.rivals`: always three; a missing or unreadable rival is its fresh
  default; extra ones are dropped; rival 1 is always unlocked, and so is any
  rival with a win.
- `inProgress` of kind `replay` is dropped (a replay is never saved, §6).

### 3.3 The migration, schema 1 → 2 (`SaveMigrations.steps[1]`)

The one M7 step (plan: "players migrate once"). Schema-1 `daily.streak` was
the unbroken run (the M3 rule reset it on an uncovered miss), so:

| Schema-2 field | Derived as |
|---|---|
| `daily.streak` | unchanged |
| `daily.lit` | `streak > 0` |
| `daily.run` | `streak` |
| `records.longestRun` | `streak` |
| `records.dailies` | the distinct readable dates in `daily.done` (at most 31 are kept, so a long-time player starts from that) |
| `records.families`, `records.dolls` | 0 |
| `records.badges` | empty; the badges the document implies are granted on load (§12), silently |
| `levelBests`, `chests`, `race` | empty (defaults) |

A schema-1 `lit` that the missed days since contradict is fixed by the next
`refresh` (§8: an uncovered miss pauses it). The step never throws: an
unreadable `daily` counts as no streak. `HiveSaveService.load` backs the raw
schema-1 text up under `doc_backup_v1` before the first write (never
overwriting an earlier backup, m3 §3.2) and writes schema 2 back.
`save_migrations_test.dart` and `hive_save_service_test.dart` migrate a real
schema-1 document (`test/core/services/save/fixtures/schema1_document.json`,
m3's key order), including the backup.

### 3.4 Who writes what

| Field | Code path | Lane |
|---|---|---|
| `levelBests` | `recordLevelWin` (the bloc passes `bestKey`) | contracts implemented; gameplay-bloc passes it; meta-services owns the tests |
| `records.families`, `records.dolls` | `recordLevelWin` (the bloc passes `RecordRules` counts) | same |
| `records.dailies`, `records.longestRun` | `recordLevelWin`'s daily branch (from `win.daily`) | same |
| `records.badges` | `recordLevelWin` and `load` (`BadgeRules`) | same |
| `daily.lit`, `daily.run` | `StreakDailyService` reconcile and solve (§8) | meta-services |
| `chests` | `recordLevelWin` (the bloc passes `MilestoneChest.forWin`) | contracts implemented; gameplay-bloc passes it |
| `race.rivals` | the phase-2 race result API | phase 2 |

## 4. Settings keys (plan decision 2)

In the `settings` box (`SettingsKeys`), a storage contract: never rename or
reuse a key. They are not save-document fields, so no schema step; a missing
key reads as its default, a wrong-typed one too.

| Key | Type | Default | Read by |
|---|---|---|---|
| `relaxed` | bool | `false` | `GameplayBloc` (start and `relaxedModeChanges`), Settings |
| `reduceMotion` | `system` \| `on` \| `off` (`ReduceMotionMode.storageValue`) | `system` | the app root (`reduceMotionChanges`), Settings |

Phase 3 adds the reminder's keys (on, hour, minute, offered; spec-prop
§13.3 nests them as `reminder`, the box stores flat keys). They must not
reuse either name above.

## 5. Remote Config keys (spec-prop §9.4; plan decision 3)

Declared once in `RemoteConfigKeys` with their defaults (rule 6), pinned in
`remote_config_keys_test.dart` (29 keys):

| Key | Default | Used by |
|---|---|---|
| `chest_coins` | 100 | the milestone chest (§9; Q76) |
| `chest_hints` | 1 | the milestone chest (§9; Q76) |
| `race_unlock_level` | 20 | the Home tile now (§15.8), the race in phase 2 (Q78) |
| `race_pace_ms_1` / `_2` / `_3` | 3000 / 2400 / 1600 | phase 2 (Q79) |
| `race_pace_jitter_pct` | 20 | phase 2 (Q79) |
| `race_reward_1` / `_2` / `_3` | 20 / 30 / 40 | phase 2 (Q77) |

Every reader clamps a negative tuned value to 0 (`MilestoneChest.forWin`
does for the chest).

## 6. `PlayRequest.replay(order)` and the resolver (plan decision 5)

- **The request:** `PlayRequest.replay(order)` (`ReplayPlay`), kind
  `PlayKind.replay`, `number` = order, `isBundled`, not generated. It is its
  own kind so no code that means "the campaign" matches a replay by
  accident: an exhaustive switch must decide.
- **Won:** a campaign order is won when `order < SaveService.highestLevel`
  (`currentLevel` moves past an order when it is won, never back;
  `highestLevel` also covers the dev picker moving `currentLevel` back). Only
  a won level replays.
- **Resolving** (`DefaultLevelResolver`, implemented): the bundle entry at
  exactly that order (a skipped invalid level never replays as its
  successor), with the campaign's board, tier, version, chapter and theme,
  `rewardCoins: 0` and `completesChapter: false`; null for a level not won
  or not in the bundle. `next(replay)` is null, `prefetch` does nothing,
  `homeRequest` never returns one. `ContentReadyGuard` refuses any bundled
  request (campaign or replay) the bundle lacks.
- **Never saved in progress:** `saveInProgress` ignores a replay's board
  (it must never replace the main line's), `inProgressOf(replay)` is null,
  `clearInProgress(replay)` does nothing and the codec drops a stored one.
  A kill during a replay loses only that replay (default, Q90). The bloc
  also skips its `_persistProgress` for replays (gameplay-bloc).
- **What a replay shows:** the same board and HUD (no "Replay" tag on the
  level pill since D170: the owner had it removed, because it only repeated
  the win card and looked like a button); **no tutorial cue and no intro card** (the bloc passes
  none for a replay, whatever `tutorialDone` and `seenIntros` say); boosters
  as usual (relaxed mode applies); the win card of §11; Continue goes back to
  Chapters (`router.pop()`, which the page's `PopScope` doesn't veto, D85).
- **Analytics:** a replay logs spec §14.4's level events like its campaign
  level (`level` = the order, D77's convention) and no new event (D100).

## 7. The win path in one save update (m3 §3.5 extended)

**The bloc** (`GameplayBloc._win`, gameplay-bloc lane), in this order:

1. `firstWin = save.document.stats.wins == 0` (read before recording, E9).
2. `chest = MilestoneChest.forWin(request, remoteConfig)` (null for a
   replay, a daily and a race).
3. `daily = daily.progressAfterSolve(date)` for a daily (as M3).
4. `outcome = save.recordLevelWin(LevelWinRecord(request, rewardCoins,
   moves: moveCount, completedChapterId, chapterReward, date, daily,
   bestKey: LevelBests.keyOf(play), chest, families:
   RecordRules.familiesIn(level), dolls: RecordRules.dollsNestedIn(level),
   boardBadges: BadgeRules.forWonLevel(level)))`.
5. The state: `winReward` (the level's coins; 0 on a replay), `winMoves`,
   `bestMoves`/`previousBest` from the outcome, `chestLevelsLeft =
   MilestoneChest.levelsToNext(request)` (§9), `chest = outcome.chestPaid`,
   `newBadges = outcome.newBadges`, `firstWin` (a campaign win only),
   `dailyRelit = daily?.relitOn(date) ?? false`, and M3's
   `completedChapterId`, `chapterReward`, `dailyStreak`, `nextRequest`.

**The save** (`InMemorySaveService.recordLevelWin`, implemented), one
`update`, so a kill never keeps half of it:

1. Coins += `rewardCoins` (**0 for a replay, whatever the record says**);
   `stats.wins` += 1 and `stats.moves` += moves (every mode, replays
   included).
2. By kind: campaign moves `currentLevel`/`highestLevel` past the order,
   clears its board and collects a completed chapter's figurine and reward
   once (M3); bonus moves `bonus.next`; daily takes `win.daily`, clears its
   board, adds 1 to `records.dailies` when the solve added a date `done`
   lacked, and raises `records.longestRun` to `daily.run`; **a replay moves
   nothing, collects no figurine and pays no chapter reward**.
3. The milestone chest: when `win.chest` is this very request's (campaign
   order or bonus number) and `chests` lacks it: coins += `coins`, hints +=
   `hints`, the number joins `opened`/`bonusOpened`. Never on a replay.
4. Best moves: with a `bestKey`, a bundled request and moves ≥ 1:
   `levelBests[key] = min(old, moves)`.
5. Records: `families` += `win.families`, `dolls` += `win.dolls`.
6. Badges: `BadgeRules.newlyEarned(win.boardBadges ∪
   BadgeRules.derivable(document after 1–5), records)` are appended.
7. Returns `LevelWinOutcome(bestMoves, previousBest, chestPaid, newBadges)`.

A board saved won by an older build still records its win once on restore
(D88), through the same path.

## 8. E2, the gentle streak (spec-prop §7.5; plan decision 4)

`streak` counts the days the daily was solved on its own date and never
drops. `run` is the unbroken run (the M3 streak's meaning: a frozen day keeps
it without adding). `lit` is the flame: `lit == (run > 0)`. The weekly
freeze stays (at most 1, granted once per ISO week, m3 §8.2), the chest
stays on every 7th streak day, and only today's date counts.

```text
grant(d, day):   unchanged (m3 §8.2)
reconcile(d, T):
  if d.lastDate != null and d.lastDate > T: return d   // the clock went back: no grant (review R2)
  if d.lastDate != null and d.lastDate < T:
    for day in d.lastDate + 1 .. T − 1:            // each missed day, in order
      grant(d, day)
      if d.freezes > 0: d.freezes −= 1; d.frozen += day; d.lastDate = day
                                                   // lit and run stay
      else:             d.lit = false; d.run = 0; d.lastDate = null; stop
                                                   // "paused": streak unchanged
  grant(d, T)
solve(d, T):       // progressAfterSolve(T)
  d = reconcile(d, T)
  if T in d.done: return d                         // solved already
  if d.lastDate != null and d.lastDate > T:        // the clock went back
    d.done += T; return d
  d.run = (d.lastDate == T − 1) ? d.run + 1 : 1    // lastDate is null when paused
  d.streak += 1; d.lit = true
  d.lastDate = T; d.done += T
  if d.streak % 7 == 0: d.chestPending = true
// in the win's save update: records.longestRun = max(longestRun, run),
// records.dailies += 1 for a date done lacked (§7)
```

- **Relit** (a moment, not a state): `DailyProgress.relitOn(T)` = `run == 1
  && streak > 1 && lastDate == T`: the solve restarted the run on a streak
  that already had days. The bloc sets `GameplayState.dailyRelit`; the daily
  win card's streak line says "Streak relit!" / "Your 13-day streak is
  glowing again." (§15.7). No toast on Daily, no stored flag (D98).
- **Paused:** `DailyStatus.paused` = `!lit && streak > 0`: the tile's badge
  and the streak card take their resting look (§15.7), and the card reads
  `dailyStreakPaused`.
- **The strip** (m3 §8.4) keeps `cycleDone` over the counted streak, so the
  chest's progress is never lost either.
- `_reconcile` in `streak_daily_service.dart` stops zeroing the count; the
  M3 worked-table test becomes the table below (meta-services).

Worked table (fresh install, daily unlocked; the meta-services lane's test
runs it verbatim):

| Date | Day (ISO wk) | Action | streak | lit | run | lastDate | freezes | frozen (latest) | chest |
|---|---|---|---|---|---|---|---|---|---|
| 09-21 | Mon (39) | solve (grant W39) | 1 | ✓ | 1 | 09-21 | 1 | — | |
| 09-22 | Tue | solve | 2 | ✓ | 2 | 09-22 | 1 | — | |
| 09-23 | Wed | solve | 3 | ✓ | 3 | 09-23 | 1 | — | |
| 09-24 | Thu | solve | 4 | ✓ | 4 | 09-24 | 1 | — | |
| 09-26 | Sat | open: Fri missed, a freeze covers it (notice) | 4 | ✓ | 4 | 09-25 | 0 | 09-25 | |
| 09-26 | Sat | solve | 5 | ✓ | 5 | 09-26 | 0 | 09-25 | |
| 09-27 | Sun | solve | 6 | ✓ | 6 | 09-27 | 0 | 09-25 | |
| 09-28 | Mon (40) | solve (grant W40) | 7 | ✓ | 7 | 09-28 | 1 | 09-25 | pending |
| 09-28 | Mon | Collect (+300) | 7 | ✓ | 7 | 09-28 | 1 | 09-25 | — |
| 09-29 | Tue | solve (longestRun 8) | 8 | ✓ | 8 | 09-29 | 1 | 09-25 | |
| 10-02 | Fri | open: Wed covered, Thu not → paused | 8 | — | 0 | null | 0 | 09-30 | |
| 10-02 | Fri | solve: relit | 9 | ✓ | 1 | 10-02 | 0 | 09-30 | |
| 10-04 | Sun | solve: Sat missed, no freeze → paused, then relit | 10 | ✓ | 1 | 10-04 | 0 | 09-30 | |
| 10-06 | Tue (41) | open: Mon missed, its own W41 grant covers it | 10 | ✓ | 1 | 10-05 | 0 | 10-05 | |
| 10-06 | Tue | solve | 11 | ✓ | 2 | 10-06 | 0 | 10-05 | |
| 10-12 | Mon (42) | open: Wed–Sun missed, W41's freeze already used → paused; then today's W42 grant (it covers the next miss, not this one) | 11 | — | 0 | null | 1 | 10-05 | |
| 10-12 | Mon | solve: relit | 12 | ✓ | 1 | 10-12 | 1 | 10-05 | |

`records.longestRun` ends at 8. The next chest opens on streak 14, whatever
the pauses in between.

**Copy** (§16, E1): "Play today to keep your streak" → "Play today to add to
your streak"; "Streak saved!" → "Freeze used" (plan decision 4); frame 5.2's
freeze chip "0 left" → "No freeze" (scarcity wording, Q95); new: the paused
subline, "Streak relit!", its body, the paused badge's semantics. Every
other streak, freeze and chest string was checked and is value-framed
(`respect_copy_test`).

## 9. E5, the milestone chest (spec-prop §7.3; plan decision 7)

- **Where:** level 10 of every chapter, campaign orders with `(order − 1) %
  20 + 1 == 10` (L10, L30 … L190, and on past the launch chapters), and every
  Bonus Endless level with `N % 10 == 0`. Never on a replay, a daily or a
  race (`MilestoneChest.forWin`).
- **Contents:** `chest_coins` coins and `chest_hints` hints (100 and 1,
  Q76), fixed and shown before it opens (spec-prop §1.1 rule 2).
- **Paid in the win's update** (§7 step 3; default, Q89), so a kill between
  the win and the modal loses nothing; opened once per level number (the dev
  picker can bring a level back; its chest never pays twice).
- **The modal** (gameplay-ui, §15.4) opens after Continue when
  `GameplayState.chest != null`, before Chapter complete (they never
  coincide on the campaign: the chest is position 10, the figurine 20) and
  before the next level. Its buttons only dismiss: nothing is granted there.
- **The win card's nearer goal:** after winning position `p` of a chapter
  the chest is `10 − p` levels away for `p < 10`, otherwise the figurine
  (position 20) is nearer. `GameplayState.chestLevelsLeft` holds `10 − p`
  (the card shows `winChestCountdown` and the bar at `(10 − left) / 10`
  instead of the figurine line) or null (the figurine bar as M3). Bonus
  Endless always counts down (`10 − N % 10`, 10 right after a chest). Null
  for a replay and a daily.
- **The HUD's coin hold** (Q57, D73): the HUD keeps the pre-win balance until
  the next level starts, so it subtracts the chest's coins as it subtracts
  the win reward (gameplay-ui).

## 10. E6, relaxed mode (spec-prop §8; plan decision 8; Q84)

- A Settings toggle (`relaxed`, off by default). Read **live**: the bloc
  reads it at every start and follows `relaxedModeChanges`
  (`RelaxedModeChanged`), so a toggle from Pause → Settings applies to the
  level in play.
- With it on, **undo is free and unlimited in every mode**: `UndoPressed`
  never opens the purchase popup and never spends coins; `canUndo` is only
  "there is a move to undo". The free-undo count keeps counting
  (`session.undosUsed`, analytics unchanged) but nothing shows it.
- The HUD's Undo badge shows "∞" (`BoosterBadge.infinite()`, gameplay-ui);
  the Out-of-Moves Undo row shows "Always free" with no count, price or ad
  row. Hint and +1 Slot are unchanged, and coins are still earned.
- The dev flavor's `unlimitedBoosters` stays a separate, dev-only flag.

## 11. E7, replay, best moves and the Chapters screen (spec-prop §7.1; plan decisions 5, 6, 12)

- **Best moves:** bundled levels only (campaign and replay), first play or
  replay, keyed `LevelBests.key(level.id, version)` (`L0024@2`): a new level
  version starts a new best. Daily, bonus and race boards keep none, and
  their win card shows the moves only (`winMovesOnly`; default, Q88). Moves
  are never shown during play (brainstorm §7).
- **The win card:** "Moves 18 · Best 16" (`winMovesBest`, the best after
  this win) on a campaign level or a replay; the first win of a level shows
  "Moves 18 · Best 18".
- **The replay win card:** no coin pill, count-up, burst or `coins` sound;
  `winReplayReason` where the pill sits; the chapter card without its "Next
  up" line; the button reads `winBackToChapters` and pops to Chapters.
- **Chapters** (`ChaptersCubit`, implemented): every catalog chapter's 20
  levels (uniform blocks in order-space, as Home and the Museum count them),
  all ten rendered up front. A cell is **locked** when the bundle doesn't
  have that exact order, **current** when it is `currentLevel` (a tap plays
  `PlayRequest.campaign`), **won** when behind `highestLevel` (a tap plays
  `PlayRequest.replay`, "Best N" when `bestMovesFor` has one: a level won
  before M7 shows the check mark without it), otherwise locked (no tap).
  `ChapterLevel.request` says what a tap plays. The screen follows
  `SaveService.changes`.
- **Entry points** (no frame, `TODO(design)`; default, Q92): a Chapters
  button on Home's new entry row and on the Museum screen (§15.8, §15.9).

## 12. E8, records and badges (spec-prop §7.8; plan decision 10; Q83)

**Records** (`RecordsSummary.of`, the Records screen):

| Record | Definition |
|---|---|
| Levels won | campaign levels behind `highestLevel` that the bundle has, plus the Bonus Endless levels behind `bonus.next` (derived; replays and dailies don't add) |
| Families completed | `records.families`: every won board adds its `totalSets` |
| Dolls nested | `records.dolls`: every won board adds the dolls that end inside another, `totalSets × (maxSize − 1)` (the approved "dolls that go inside another", counted per won board so undo, restart and the route never change it; default, Q91) |
| Dailies solved | `records.dailies`: one per date solved |
| Longest streak | `records.longestRun`: the longest unbroken run (§8) |
| Races won per rival | `race.rivals[i].wins` (0 until phase 2) |
| Best moves | per level, on Chapters (the Records row links there) |

Every mode counts: campaign, replay, bonus, daily and (phase 2) a won race.
Only won boards add (default, Q91).

**Badges** (`BadgeId`, `BadgeRules`; cosmetic, pay nothing, never taken
away, never over consecutive days):

| Id | Earned when | Detected |
|---|---|---|
| `first_family` | `records.families ≥ 1` or `stats.wins ≥ 1` (every win completes a family; a schema-1 save has wins but no records) | derivable |
| `glass_breaker` | a won board had a glass case (a win breaks every case, spec §3.3, §5.3 rule 6) | the won level |
| `ice_melter` | a won board had a slot with `0 < ice ≤ totalSets` (every completion lowers every counter, spec §3.4, so it shattered) | the won level |
| `tall_order` | a won board with `maxSize ≥ 5` | the won level |
| `grand_nest` | a won board with `maxSize 6` | the won level |
| `level_100` | `highestLevel ≥ 101` | derivable |
| `level_200` | `highestLevel ≥ 201` | derivable |
| `dailies_7` | `records.dailies ≥ 7` | derivable |
| `dailies_30` | `records.dailies ≥ 30` | derivable |
| `first_race` | a race won against any rival | derivable (phase 2) |
| `all_rivals` | every rival beaten at least once | derivable (phase 2) |
| `museum_full` | the Museum holds the ten launch figurines (ch01–ch10; later chapters never take it away) | derivable |

- **When:** in the win's save update (the won level's badges plus the
  derivable ones of the document after the win) and on `SaveService.load`
  (the derivable ones, **silently**: a migrated save, or a badge added by an
  update). Nothing else grants one.
- **The badge-earned event:** `LevelWinOutcome.newBadges` →
  `GameplayState.newBadges` → the win overlay shows one `BadgeToast` each
  (tone success, "Badge earned!", the badge's name), a few hundred ms after
  it opens and one after the other (gameplay-ui). Phase 2's race result does
  the same. Load-time grants show nothing.
- Names (`badgeName`), hints (`badgeHint`) and glyphs (`BadgeToast.iconOf`)
  are placeholders until Claude Design names and draws them (request §I.6).

## 13. E9, first launch opens Level 1 (spec-prop §10.1; plan decision 11)

- **The splash:** `SplashState.opensFirstLevel` = no level has been won
  (`save.highestLevel <= 1`, after the save loads). Then the splash page
  `replaceAll([GameplayRoute(request: PlayRequest.campaign(1))])`: L1's
  tutorial, with no Home underneath and nothing in between (E13 measures
  it). Otherwise Home, as M3.
- **A kill during L1** comes back to L1: `highestLevel` is still 1, so the
  splash opens it again and the bloc restores the saved board (m3 §3.4).
- **The first win's Continue** goes to Home (`GameplayState.firstWin`, a
  campaign win with `stats.wins == 0` before it): `replaceAll([
  MainShellRoute(children: [HomeRoute()])])`, never L2. Pause → Home works as
  in M3.
- M6's consent step will sit between the splash and L1 (spec-prop §10.1).
- **Tests that change** (a fresh fake save now lands in L1): the
  gameplay-bloc lane updates `test/core/router/app_router_test.dart` ("the
  app opens on the splash, which opens Home") and the flows of
  `test/app_flow_test.dart` that start at Home (seed the DI save past L1, or
  play L1 first); the integrator rewrites the playthrough and resume
  scenarios of `integration_test/` that tap Home's PLAY first, and adds
  E13's timing.

## 14. E14, reduce motion (spec-prop §16; plan decision 9)

- The app root (`lib/app/app.dart`, `MaterialApp.router`'s `builder`, inside
  the existing text-scale clamp) wraps the tree in a `MediaQuery` whose
  `disableAnimations` is `mode.resolve(systemDisablesAnimations:
  <the platform's value>)`, following `DatabaseService.reduceMotionChanges`
  (initially `reduceMotion`). System = the OS value, On = true, Off = false.
  The OS value is either flag: Android's Remove animations
  (`disableAnimations`, carried by `MediaQuery`) or iOS's Reduce Motion
  (`AccessibilityFeatures.reduceMotion` only, read from the view).
  `ReduceMotionOverride` rebuilds on `didChangeAccessibilityFeatures`
  (review R7, D167).
- So every current reader follows without change: `context.reduceMotion`,
  `LottieFxView`, the UI kit's tokens (`reducedMotionDurationScale`) and the
  board (`GameplayView` sets `GameplayBoard.reduceMotion` from
  `context.reduceMotion`; `NestyGame.reduceMotion` swaps its `MotionSpec`).
  A change mid-level (Pause → Settings) must reach the board: board-fx
  checks it and the page's dependency update covers it.
- Sounds and haptics are unchanged.
- Tests keep driving the flag through `pumpScreen(reduceMotion:)`.

## 15. The UI stand-ins (ui-designer's spec, adjusted to what is frozen)

Built from `design/tokens.json`, `design/README.md` and the UI kit, since
none of request §E/§I has landed; every one carries `TODO(design)` and its
BACKLOG item. **Shared rule:** every row or cell is `Expanded` plus the
component's own `FittedBox(fit: scaleDown)`, so 360–430 dp widths and 1.3×
text scale text down instead of overflowing; nothing is narrower than a 48 dp
target; screens are vertical `ListView`s; on 768 × 1024 content sits in a
~600 dp column and grids gain columns (a placeholder while Q16 is open).

### 15.1 Chapters (menus)

`ScreenHeader(title: chaptersTitle, onBack: pop, coins)`; one surface card
per `ChapterSection` (radius 24, the Museum card's) with the header row
(`winChapter(number)` + `ChapterProgress.nameOf`, and `winChapterProgress(won,
total)`) and a 4-column grid of 20 cells (6 at ≥ 600 dp, spacing 12). A cell
(radius 14, ~56–60 tall, the number in `AppTextStyleTokens.number`):
- **won:** `AppColors.dayDoneFace`/`dayDoneRing` (the day strip's done cell),
  a small `checkCircle` corner badge in `success`, and `chaptersBestMoves`
  below when `bestMoves != null`; tap → `GameplayRoute(request:
  ChapterLevel.request!)` on the root router;
- **current:** the day strip's "today" cell (`dayTodayTop` → `primary`,
  edge `primaryEdge`, white); tap → the campaign;
- **locked:** 55 % opacity with `NestyIcons.lock` instead of the number, no
  tap, no ripple.
Semantics: `chaptersLevelSemantics*`. States: loading, `RetryView`, data.

### 15.2 Records (menus)

`ScreenHeader(title: recordsTitle)`; a card of read-only `SettingsRow`s:
`recordsLevelsWon` (`checkCircle`), `recordsFamilies` (`favorite`),
`recordsDolls` (`addBox`), `recordsDailies` (`calendarToday`),
`recordsLongestStreak` (`localFireDepartment`, value `dailyStreakDays`),
`recordsBestMovesLink` (chevron → `ChaptersRoute`), and three race rows
`recordsRaceRow(n)` ("Rival 1 · Computer": **every rival surface says
Computer**, spec-prop §1.1 rule 5, with the computer stand-in glyph
`smartDisplay`, not `bolt`) reading 0 until phase 2. A second card,
`recordsBadgesHeader`: a 4-column grid (6 at ≥ 600 dp) of the twelve badges,
`BadgeToast.iconOf` at 48 px, unearned ones at 55 % opacity, `badgeName`
below (2 lines, no ellipsis at 1.3×), semantics `badgeSemanticsEarned` /
`badgeSemanticsLocked` (with `badgeHint`). Placeholder names:
`first_race` "First Race Won", `all_rivals` "Every Rival Beaten" (the rest
as the ui-designer proposed).

### 15.3 The win card (gameplay-ui)

`WinSummary` gains what the state carries (`winMoves`, `bestMoves`,
`chestLevelsLeft`, `isReplay`, `newBadges`). A caption row in
`AppTextStyleTokens.row` 13–14 px, `textSecondary`, first inside the
chapter/streak card, 6–8 below it: `winMovesBest` or `winMovesOnly`.
- chest nearer: the figurine row becomes a 28 px `ChestIcon` +
  `winChestCountdown`, the bar re-scaled to the 10-level cycle;
- replay: §11 (no coin pill; `winReplayReason`; `winBackToChapters`);
- daily: the streak card; `dailyRelit` swaps its lines for
  `dailyStreakRelitTitle`/`Body`;
- first win (E9): Continue goes to Home;
- a replay's level pill has no tag (the `hudReplayChip` tag was removed, D170).

### 15.4 The milestone chest modal (gameplay-ui)

`MilestoneChestModal` in the overlay chain: Win → Continue → [interstitial,
M6] → **[milestone chest]** → [Chapter complete] → next level. `ModalCard` +
`RibbonTitle.streak` (`chestMilestoneTitle`) + `ChestIcon`; two steps in an
`AnimatedSwitcher` (200 ms, `curveEaseOut`): closed with the contents shown
(`chestInside`, a coin chip `winCoins(coins)` and a hint chip
`chestContentsHint`, `chestMilestoneBody(level)` or
`chestMilestoneBodyBonus(number)`, semantics `chestContentsSemantics`) and
`chestOpen`; then `ChestIcon.open()` with twinkles, the success haptic and
`JingleCues.reward()`, and `dailyChestCollect` to dismiss. Nothing is
granted by its buttons (§9).

### 15.5 Settings rows (menus)

A new `SettingsSection` between Sound/Music/Haptics and Color symbols:
- **Relaxed mode:** `SettingsToggleRow` with an optional `subtitle`
  (backward-compatible) — `sentimentSatisfied`, `settingRelaxedMode`,
  `settingRelaxedModeSubtitle` (`caption`, `textMuted`, wraps) →
  `SettingsCubit.setRelaxedMode`;
- **Reduce motion:** `SettingsRow(icon: bolt, label: settingReduceMotion,
  value: reduceMotionSystem/On/Off)` opening a `NestySheet(title:
  settingReduceMotionSheetTitle)` of three `SheetRow`s with a check on the
  active one (`LanguageSheet.show`'s shape) → `SettingsCubit.setReduceMotion`.

### 15.6 Relaxed mode on the board (gameplay-ui)

`BoosterBarModel.of(state)`: `undoBadge = unlimitedBoosters ? null :
state.relaxed ? const BoosterBadge.infinite() : badgeFor(...)`; the new
sealed case draws "∞" in the 22 px circle, tinted `success`/`successEdge`;
Hint and +1 Slot untouched; semantics `boosterUndoUnlimitedSemantics`.
`OutOfMovesSheet(relaxed:)`: the Undo row's trailing is
`SheetRowTag(oomUndoFreeUnlimited)`.

### 15.7 The gentle streak on Daily and Home (menus)

- Lit (unchanged): `AppGradientTokens.streak`.
- **Paused** (`DailyStatus.paused`, `HomeState.dailyLit == false` with
  `dailyStreak > 0`): the badge and the whole streak card take the neutral
  `AppGradientTokens.surface`, the flame `textMuted`, never red (default,
  Q96); the card's subline `dailyStreakPaused(streak)`; the badge's
  semantics `streakBadgeSemanticsPaused`.
- **Relit:** on the daily win card (§15.3), not a toast on Daily (D98).
- Copy per §8.

### 15.8 Home entry points (menus)

- A row of two `TactileButton`s (`secondary`, `small` = 48 dp, each
  `Expanded`, 12 apart, 16 side margins) right after the header, in the slot
  the dev level picker's button uses (`padding.top + 5 + 46 + 14`): Chapters
  (`checkCircle`, `homeChaptersButton`) and Records (`star`,
  `homeRecordsButton`). The dev picker's button moves beside or below it.
- A fourth `HomeTile` in the tiles row, "vs Computer" (`homeVsComputerTile`,
  `smartDisplay`), on `HomeTile`'s locked path: `homeVsComputerLocked(
  raceUnlockLevel)` while `!raceUnlocked`, `homeVsComputerSoon` once
  unlocked until phase 2 ships the race (default, Q98).

### 15.9 The Museum's link to Chapters (menus)

A full-width `TactileButton(secondary, small, expand, icon: checkCircle,
label: museumChaptersLink)` between the header and the collection card,
pushing `ChaptersRoute` on the root router.

### 15.10 Gaps these stand-ins reveal (for the Claude Design request)

The ui-designer's list stands (the ordinary 2.8 card's moves line, icons for
Chapters and Records, the computer glyph as a token, Home's affordances for
Chapters and Records, the chest's two-step open, the "∞" badge, the
always-free Undo row, a 3-state Settings control, the paused look, the rival
names or a "coming soon" state) plus the replay chip on the level pill and
the relit lines on the daily win card. The integrator adds them to
`docs/plans/claude-design-request-m7.md`.

## 16. The ARB keys added (all in `app_en.arb`, each with a description)

Every phase-1 description ends "Placeholder until Claude Design's copy.md
lands"; the two board keys are final. `arb_keys_m7_test.dart` pins them.

| Key | English | Where |
|---|---|---|
| `dailyStreakKeep` (rewritten) | Play today to add to your streak | streak card, lit, unsolved |
| `dailySavedTitle` (rewritten) | Freeze used | the freeze notice (5.2) |
| `dailyFreezes` (rewritten `=0`) | No freeze · 1 freeze · N freezes | the freeze chip |
| `dailyStreakPaused` | Your {count}-day streak is paused. Play today to relight it. | streak card, paused |
| `dailyStreakRelitTitle` | Streak relit! | daily win card |
| `dailyStreakRelitBody` | Your {count}-day streak is glowing again. | daily win card |
| `streakBadgeSemanticsPaused` | {count}-day streak, paused | Home tile badge |
| `chaptersTitle` | Chapters | Chapters header |
| `chaptersBestMoves` | Best {moves} | won cell caption |
| `chaptersLevelSemanticsWon` | Level {level}, won, best {moves} moves | semantics |
| `chaptersLevelSemanticsWonNoBest` | Level {level}, won | semantics |
| `chaptersLevelSemanticsCurrent` | Level {level}, play next | semantics |
| `chaptersLevelSemanticsLocked` | Level {level}, locked | semantics |
| `homeChaptersButton` | Chapters | Home entry row |
| `museumChaptersLink` | Chapters | Museum link |
| `recordsTitle` | Records | Records header |
| `homeRecordsButton` | Records | Home entry row |
| `recordsLevelsWon` | Levels won | Records row |
| `recordsFamilies` | Families completed | Records row |
| `recordsDolls` | Dolls nested | Records row |
| `recordsDailies` | Dailies solved | Records row |
| `recordsLongestStreak` | Longest streak | Records row |
| `recordsBestMovesLink` | Best moves | Records row → Chapters |
| `recordsRaceRow` | Rival {number} · Computer | Records race rows |
| `recordsBadgesHeader` | Badges | Records badge card |
| `badgeName` | First Family … Full House (select on `BadgeId.id`) | grid, toast |
| `badgeHint` | Complete a family … Bring every Museum family home | semantics |
| `badgeSemanticsEarned` | {name}, earned | semantics |
| `badgeSemanticsLocked` | {name}, not earned yet. {hint} | semantics |
| `badgeEarnedToastTitle` | Badge earned! | the toast |
| `winMovesBest` | Moves {moves} · Best {best} | win card |
| `winMovesOnly` | Moves {moves} | win card (daily, bonus, race) |
| `winChestCountdown` | {count} levels to the chest | win card |
| `winReplayReason` | A replay for fun: coins come from new levels. | replay win card |
| `winBackToChapters` | Back to Chapters | replay win card |
| ~~`hudReplayChip`~~ | removed (D170) | — |
| `chestMilestoneTitle` | Milestone chest! | chest modal |
| `chestMilestoneBody` | You reached Level {level}! | chest modal |
| `chestMilestoneBodyBonus` | You reached Bonus Level {number}! | chest modal |
| `chestInside` | Inside this chest | chest modal |
| `chestContentsHint` | +{count} hints | chest modal chip |
| `chestContentsSemantics` | {coins} coins and {hints} hints | semantics |
| `chestOpen` | Open | chest modal |
| `settingRelaxedMode` | Relaxed mode | Settings |
| `settingRelaxedModeSubtitle` | Unlimited free undo | Settings |
| `settingReduceMotion` | Reduce motion | Settings |
| `settingReduceMotionSheetTitle` | Reduce motion | the sheet |
| `reduceMotionSystem` / `On` / `Off` | System / On / Off | the row and sheet |
| `oomUndoFreeUnlimited` | Always free | Out-of-Moves Undo row |
| `boosterUndoUnlimitedSemantics` | {booster}, always free | semantics |
| `homeVsComputerTile` | vs Computer | Home tile |
| `homeVsComputerLocked` | After Level {level} | Home tile, locked |
| `homeVsComputerSoon` | Coming soon | Home tile, until phase 2 |
| `boardTowerHidden` | +{count} | the board's tower tag (final) |
| `boardIceCount` | {count} | the ice badge (final) |

## 17. E1, the respect tests (spec-prop §1.1; brainstorm §5)

| Test | What it pins | Written by |
|---|---|---|
| `test/ethics/respect_copy_test.dart` | every ARB value of the streak, freeze and chest families (`dailyStreak*`, `dailyFreezes`, `dailySaved*`, `dailyChest*`, `dailyWin*`, `streakBadge*`, `chest*`, `winChest*`, `recordsLongestStreak`) against a deny-list of loss, guilt, urgency and scarcity wording, and that the list catches the old copy | contracts (done); phase 3 adds the reminder's key prefix |
| `test/ethics/reward_randomness_test.dart` | no reward path (`core/services/{save,daily,records,chest}`, `features/gameplay/bloc`, `features/{chapters,records}`) reads `Random(`, `Random.secure`, `math.Random` or `DateTime.now(`; the Player ID's `Random.secure` is the one allowed use | contracts (done); phase 2 adds the race's paths |
| "Computer" on every rival surface | `arb_keys_m7_test` (the ARB) now; the menus lane's Records widget test (the row shows it) | contracts, menus |
| No race path offers hint or +1 Slot; the reminder is off on a fresh install | phase 2, phase 3 | their contracts |

The `/review` skill's ethics lens is step 5 of `.claude/skills/review/SKILL.md`
(added by the phase-1 integration: spec-prop §1.1 and the six questions, a
failing answer is a P0); the phase-5 close's three-lens review runs it. The
phase-1 integration also widened `reward_randomness_test` to the chest
opening (`features/fx/chest/` and both chest modals), which shows and counts
up the amounts paid.

## 18. Lane ownership and test plans

A lane touches only its paths; everything else goes in its report for the
integrator. Generated files (`*.freezed.dart`, `*.g.dart`, `*.gr.dart`,
`di.config.dart`, `app_localizations*.dart`) come only from the lock script.
`lib/l10n/app_en.arb` is frozen for phase 1. Every lane writes its report
(with the six ethics answers of the last section) and keeps a checkpoint in
the run's checkpoint folder.

| Lane | Owns | Builds | Tests (in its paths) |
|---|---|---|---|
| **levels** (running) | `tools/lib/src/levels/**`, `tools/test/levels/**`, `tools/levels/**`, `apps/game/assets/levels/bundle.json`; also the level count of `test/core/repository/bundled_level_repository_test.dart` (it pins 30; the 200-level bundle needs 200) | L31–L200, E12 gates | tools levels tests, `bundle check`, `fixtures check`, that one repository test |
| **meta-services** (services-engineer) | `lib/core/services/{save,daily,records,chest}/**` and `lib/core/repository/{level_resolver,default_level_resolver,fake_level_resolver}.dart` (behaviour, never a frozen signature); `test/core/services/{save,daily,records,chest}/**`, `test/core/repository/{default_level_resolver,fake_level_resolver}_test.dart`, `test/ethics/reward_randomness_test.dart` upkeep | E2's algorithm (§8) in `StreakDailyService`; everything else in its paths is implemented: it owns the full tests and any fix | the §8 worked table verbatim (reconcile, solve, relit, pause, clock back, chest every 7th counted day, longestRun through `recordLevelWin`); `recordLevelWin`'s M7 branches (replay no-pay incl. a record that claims coins, chest once per level number for campaign and bonus, a chest of another level ignored, bests min and a new version, records, badges order and no repeats, the outcome); load-time badges (in memory and Hive, migrated and current documents, no toast path); Hive round trip of every schema-2 field; codec leniency cases; `BadgeRules`/`RecordRules`/`MilestoneChest` full tables; resolver replay edge cases (a skipped level, the dev picker) |
| **gameplay-bloc** (bloc-architect) | `lib/features/gameplay/bloc/**`, `lib/features/splash/**`, `test/features/gameplay/bloc/**`, `test/features/splash/**`, `test/app_flow_test.dart`, `test/core/router/app_router_test.dart` | replay (no tutorial or intro, no `_persistProgress`, no chest or figurine, `nextRequest` null); relaxed undo (§10); the win card's data and the chest grant, the record hooks, `newBadges`, `dailyRelit`, `firstWin` (§7); E9 in the splash cubit and its page (§13) | `blocTest`s for each §7 field per kind (campaign, chest level, bonus 10, daily relit, replay), relaxed on/off/mid-level toggle (no offer, no spend, `canUndo`), replay never saving in progress and never showing a cue or card, first win; the splash's `opensFirstLevel` (fresh, L1 in progress, L1 won); E9's router and app-flow updates |
| **menus** (flutter-frontend-dev) | `lib/features/{chapters,records,home,settings,daily,museum}/**`, `lib/app/**`, `lib/core/ui/**` except `widgets/booster/**` and `*.gen.dart`, their tests (`test/features/{chapters,records,home,settings,daily,museum}/**`, `test/app/**`, `test/core/ui/**` except `booster_button_test.dart`) | Chapters (§15.1), Records (§15.2), the badge grid, Settings rows (§15.5), the reduce-motion override at the app root (§14), the Daily states (§15.7), Home entries (§15.8), the Museum link (§15.9); fixes "Home's shelf after a skin equip" (`ShowcaseDolls` follows `SkinService.selectedSkinChanges`) and "the Daily puzzle card's preview background" | widget tests per screen and state on fake services (won/current/locked cells and taps, a best and none, records rows incl. "Computer", badges earned/unearned, Settings rows and the sheet writing `DatabaseService`, the override: system/on/off reaching `context.reduceMotion`, paused/lit/relit copy, the vs Computer tile's two states, the shelf re-preparing after an equip) |
| **gameplay-ui** (flutter-frontend-dev) | `lib/features/gameplay/{pages,overlays,widgets}/**` except `pages/gameplay_board.dart`, `lib/core/ui/widgets/booster/**`, `test/features/gameplay/{pages,overlays,widgets}/**`, `test/core/ui/booster_button_test.dart` | the win card (§15.3), the chest modal and its place in the chain (§15.4), relaxed HUD and out-of-moves rows (§15.6), the first-win Continue, the replay's Back to Chapters and chip, the badge toasts, the coin hold minus the chest; fixes "Play Bonus Level N failure" and "a restored out-of-moves board with an undismissed intro card" (both `TODO(M7)` in `gameplay_view.dart`) | page tests on the recording board: each win-card variant, the modal's two steps and that it grants nothing, the chain order, "∞" and "Always free", Continue per case, the toasts, both fixes |
| **board-fx** (flame-engineer) | `lib/features/gameplay/game/**`, `lib/features/fx/**`, `lib/features/gameplay/pages/gameplay_board.dart`, `test/features/gameplay/game/**`, `test/features/fx/**` | "+1 Slot plays `button` twice" (keep one), "the `ui_extra_slot` pop at rest", the "+N" tag and the ice digits through `boardTowerHidden`/`boardIceCount` handed to `SlotDecor` where the board is built, reduce motion reaching the board mid-level (§14) | one cue per +1 Slot, the loop's first frame, the tag and badge text from the ARB (a test locale's digits), `MotionSpec` swapping on a change |
| **overflow** (test-writer) | `test/overflow/**`; in `test/features/support/screen_harness.dart` only a new `overflowScreenSizes` constant (360 × 640, 390 × 844, 430 × 932, 375 × 667, 768 × 1024) and `safeAreaOf` for the two new sizes (`screenSizes` stays as is) | the suite | every screen (splash, Home, Daily, Museum, Shop, Settings, Chapters, Records, gameplay HUD with win, chest, out-of-moves, pause and chapter-complete overlays) at the five sizes × 1.0 and 1.3 with `expectNoLayoutErrors`; a failure in another lane's widget goes in the report |
| **integrator** | every cross-lane edit, DI, codegen's final pass, `integration_test/**`, docs, the TODO index | the E9 playthrough rewrite and E13's timing; the L31, L51, L71 and L130 segments; the Claude Design request's new gaps (§15.10); the ethics checklist rows | the full gate (§20) |

## 19. Decisions and questions

PROGRESS D95–D110 record this design (D94, the same day, is the owner's
CLAUDE.md rule); Q88–Q98 ask the owner (each also a BACKLOG "Owner inputs
needed → Decisions" item). Defaults ship unless the owner answers otherwise.
Plan-m7 decisions 14 (the race's core) and 15 (the reminder) are recorded by
the phase-2 and phase-3 contracts.

| D | Decision | Section |
|---|---|---|
| D95 | This document and its frozen phase-1 contracts; lanes and the codegen lock | §1, §2, §18 |
| D96 | Save schema 2 and its one migration | §3 |
| D97 | Bonus chests in their own list, `chests.bonusOpened` | §3.1, §9 |
| D98 | The gentle streak's state machine; "relit" is a moment on the daily win card, not a stored state | §8 |
| D99 | Settings keys `relaxed` and `reduceMotion` | §4 |
| D100 | Replay is its own request kind, never saved; replays log the campaign's level events | §6 |
| D101 | The win path, one update, and what it reports | §7 |
| D102 | Best moves per bundled level id and version | §11 |
| D103 | The milestone chest: where, what, paid at the win, the nearer goal | §9 |
| D104 | Relaxed mode read live by the bloc | §10 |
| D105 | Records per won board, every mode; "dolls nested" | §12 |
| D106 | The twelve badges' triggers, granted at wins and on load | §12 |
| D107 | First launch opens L1 | §13 |
| D108 | Reduce motion at the app root | §14 |
| D109 | Entry points and the reserved vs Computer tile | §15.8, §15.9 |
| D110 | The E1 copy rewrites and the two respect tests | §8, §16, §17 |

| Q | Question | Default |
|---|---|---|
| Q88 | Best moves on daily, bonus and race boards? | none; their card shows the moves only |
| Q89 | The milestone chest paid at the win, or on the modal's button? | at the win (a kill loses nothing) |
| Q90 | Replays saved in progress? | never; a kill ends the replay |
| Q91 | Records count every mode, won boards only; "dolls nested" = the dolls that end inside another per won board | yes |
| Q92 | Where Chapters and Records open from | Home's entry row; Chapters also from the Museum |
| Q93 | Bonus chests every 10th bonus level, tracked apart | yes |
| Q94 | The badge triggers (§12) | as listed; `tall_order` counts maxSize ≥ 5 |
| Q95 | Frame 5.2's freeze chip "0 left" rewritten "No freeze" | yes |
| Q96 | The paused look recolors the whole card and badge | yes (neutral, never red) |
| Q97 | "Streak relit" on the daily win card, not a Daily toast | yes |
| Q98 | The vs Computer tile before the race ships | locked, "After Level N", then "Coming soon" |

## 20. Verification

Contracts stage (2026-09-28):
- `flutter analyze --fatal-infos --fatal-warnings` at the root: no issues.
- `cd apps/game && flutter test --timeout 90s`: 1,600 pass. The one failure
  is `bundled_level_repository_test.dart`'s "30 levels" pin against the
  levels lane's 200-level `bundle.json` (not a contracts change; the levels
  lane or the integrator updates the count).
- `LANE=contracts codegen.sh all`: exit 0.

Phase-1 close (integrator): the `/milestone` baseline gate (codegen drift,
format, analyze, every suite, the token/icon/asset/TODO-index checks,
`bundle check` and `fixtures check`, builds), the E9 playthrough with E13's
time and the mechanic segments on the iPhone 16 Pro simulator and the API 35
emulator, and the ethics checklist rows below.

Phase-1 integration (2026-09-28, D113–D124): every lane's hand-off made;
codegen through the lock, exit 0; `flutter analyze --fatal-infos
--fatal-warnings` clean; 840 hand-written Dart files formatted; nesty_core
1,506, nesty_render 530, apps/game 2,489, admin 47 and tools 330 tests
pass; `bundle check` (200 levels) and `fixtures check` OK; the four
generators' `--check` and the TODO index unchanged (PROGRESS "M7 — phase 1").
Not run by the integrator: the builds and the device checks. The rewritten
`integration_test/` (E9, E13's `NESTY_E13`, the chests and the L31, L51, L71,
L130 and L200 segments) runs in the device stage.

## Phase 2: vs Computer

Written 2026-09-28 by the M7 phase-2 contracts stage. Sources, in order:
spec-prop §7.7 (the race; the spec until Q85) and §1.1 rule 5 ("A computer
opponent is always labelled a computer"), [mode-vs-computer.md](mode-vs-computer.md)
("vs-computer"), plan-m7 decision 14, the phase-2 architecture proposal
(adopted, with the departures in P2.14) and the ui-designer's stand-in spec
(P2.10). Where the ui-spec says `RaceRoute` or "a new page", the plan wins
(plan-m7 "Rejected: a separate race page and bloc"): the race is the
gameplay page with a race request. Decisions are PROGRESS D132–D139; the
owner questions are Q124–Q134. Phase 1 had already frozen the save fields
(`race.rivals`, §3), the Remote Config keys (§5), the `first_race` and
`all_rivals` badges (§12), the Records race rows (§15.2) and the Home tile
(§15.8). The star rating (D125) is phase 3's: nothing here computes, shows
or saves a star, and the race's result card shows none.

### P2.1 What this stage froze

These files exist, compile (`flutter analyze --fatal-infos
--fatal-warnings` clean), are documented and have minimal tests
(`test/contracts/m7_phase2_test.dart`). A lane adds behaviour where P2.13
says so and never changes a frozen signature; a needed change goes in its
report for the integrator. "Implemented" means the body is complete and
tested, and the owning lane extends its tests.

| Area | Files (frozen) | State |
|---|---|---|
| Core | `packages/nesty_core`: `simulator/rival_bot.dart` (`RivalBot`, `RivalStep`), `simulator/bots.dart` (`BotPlayer.stepRun`, `runWon`/`runLost`; `SimBot` exported alone), `generator/curve.dart` (`raceRivals`, `maxRaceNo`, `raceSeed`, `racePolicy`, `raceTier`, `raceParams`), the barrel, `public_api_test`/`barrel_test`, the race goldens and parity | implemented by the race-core lane ahead of this stage (its report), reviewed and frozen as is: 1,606 VM tests pass |
| Request | `core/models/play_request.dart`: `PlayKind.race` (id `race`, never stored), `PlayRequest.race(rival:, raceNo:)` = `RacePlay`, `number` = raceNo, `isGenerated` now bonus, daily or race, `isRace`; `tryCreate(race, _)` is null | implemented |
| Every switch | `save_document.dart` (`inProgressOf(race)` null), `save_document_codec.dart` (drops an `inProgress` of kind race), `in_memory_save_service.dart` (`recordLevelWin` records nothing for a race; `saveInProgress`/`clearInProgress` ignore one), both resolvers, the bloc's `_entryOf` (order = raceNo), `HomeCubit`'s tier switch | implemented |
| Resolver | `level_resolver.dart` (docs), `DefaultLevelResolver._race` (P2.4), `FakeLevelResolver` (race from `generated`, `next` null) | implemented |
| Save API | `save_service.dart`: `int? beginRace(int rival)`, `RaceWinOutcome recordRaceWin(RaceWinRecord win)`; `save_document.dart`: `RaceWinRecord`, `RaceWinOutcome`; `InMemorySaveService` (so `FakeSaveService` and `HiveSaveService`, which extend it); the badge step shared by both win paths (`_withWinBadges`) | implemented; no schema step (schema 2 has every field) |
| Race rules | `core/services/race/race_rules.dart` (`RaceRules`: `paceStream`, `maxFrameDelta`, `maxPaceMs`, `modeUnlocked`, `stageLevel`, `paceMs`, `jitterPct`, `rewardCoins`, `pacePrng`, `nextIntervalMs`, `parsePaceOverride`) | implemented |
| Frame clock | `core/services/ticker/`: `FrameTicker` (interface: `start`, `stop`, `isTicking`, `dispose`), `SchedulerFrameTicker` (a raw `Ticker`, `@Injectable(as: FrameTicker, env: [real, fake])`, a factory), `FakeFrameTicker` (tests: `tick`, `advance`) | implemented |
| Race cubit | `features/race/cubit/race_cubit.dart` + `race_state.dart`: `RaceState`, `RacePhase`, `RivalActivity`, `RaceResult`, `RaceHold`; `RaceCubit(@factoryParam RacePlay, SaveService, RemoteConfigService, FrameTicker)` with `playerBoardLoaded`, `start`, `playerBoardChanged`, `setHold`, `rematch`, `newRace`, `close` | `playerBoardLoaded` (the rival's setup → ready), `rematch`, `newRace` and `close` implemented; `start`, `playerBoardChanged` and `setHold` are documented stubs (`TODO(M7)`, race-bloc) |
| Bloc | `gameplay_state.dart`: `raceLive`, `isRace`, `acceptsInput` gated in a race; `gameplay_event.dart`: `RaceGateChanged({required bool open})`; its handler | the gate implemented; the rest of race mode (P2.6) is race-bloc's |
| Rival select | `features/race/cubit/rival_select_cubit.dart` + state (`RivalSelectState`, `RivalCard`), `pages/rival_select_page.dart` (`RivalSelectPage`, `RivalSelectView`) | cubit implemented; the page is a stub list (`TODO(design)`) |
| Routes and page | `app_router.dart`: `RivalSelectRoute` (root, `ContentReadyGuard`); `gameplay_page.dart`: a `BlocProvider<RaceCubit>` for a race request, passed as `GameplayView.race` (null otherwise) | implemented; the view doesn't use `race` yet (`TODO(M7)`, race-ui) |
| Copy | `app_en.arb`: 31 keys (P2.11), gen-l10n run | final English is Claude Design's (request C, G.5) |
| E1 | `reward_randomness_test` scans `core/services/{race,ticker}` and `features/race`; `respect_copy_test` checks `race*` and `hudRace*`; `arb_keys_m7_test` pins the keys, "Computer" on every rival surface and no human-status words | implemented |
| Docs | CLAUDE.md's Code map (`simulator/` and `generator/` entries, `features/race`, the `FrameTicker` row, `services/race/`), this section, PROGRESS D132–D139 and Q124–Q134, the BACKLOG items | done |

DI: `RaceCubit` and `RivalSelectCubit` are `@injectable` factories (the
race cubit takes its request as `param1`); `FrameTicker` is a factory bound
in both environments (`di_test` resolves all three).

### P2.2 Lanes and codegen

1. **Contracts** (done): P2.1.
2. **Lanes, in parallel** (P2.13): `race-services`, `race-bloc`, `race-ui`.
   `race-core` is done (it ran ahead); it keeps `packages/nesty_core/**`
   for any fix a lane reports (P2.3 lists none needed).
3. **Integrator**: every cross-lane edit, DI and codegen's final pass, the
   rival-1 playthrough segment, the E1 race session test, README's
   define, the TODO index, the ethics row, the device runs.

Codegen only through the lock, as in phase 1 (§2): `LANE=<lane> bash
…/scratchpad/m7/bin/codegen.sh l10n|build|all`. `lib/l10n/app_en.arb` is
complete for phase 2: a lane that needs another key lists it in its report,
and the integrator adds it.

### P2.3 The core rival API (race-core, frozen)

Reviewed against spec-prop §7.7 and the architecture's §1; no core change
is needed. The public names:

```dart
enum RivalStep { moved, finished, restarted }
final class RivalBot {
  factory RivalBot(Level level, {required SimBot policy, required int raceSeed,
      int moveCap = SimulatorParams.defaultMoveCap});      // 250
  static const int runStream = 0x52564C30;                 // 'RVL0'; + SimBot.index
  static int runSeed(int raceSeed, SimBot policy, int run);
  final Level level; final SimBot policy; final int raceSeed; final int moveCap;
  int get run; int get moveCount; int get setsCompleted; int get totalSets; bool get isFinished;
  String get lastFrom; String get lastTo;                  // StateError before the first move
  RivalStep step();                                        // StateError once finished
  GameState snapshot();                                    // allocates
}
// DifficultyCurve (exported already)
static const int raceRivals = 3, maxRaceNo = 99999;
static int raceSeed(int rival, int raceNo);                // 3_000_000 + rival × 100_000 + raceNo
static SimBot racePolicy(int rival);                       // 1 casual; 2, 3 smart
static Tier raceTier(int rival);                           // 1 easy; 2, 3 medium (Q80)
static GeneratorParams raceParams({required int rival, required int raceNo,
    required int highestWonLevel});                        // id 'race-<rival>-<raceNo>'
```

- **A step** is one pass of the simulator's run loop (`BotPlayer.stepRun`,
  which `BotPlayer.play` now repeats), so the rival plays exactly spec
  §6.4's bots (vs-computer rule 2: no new policy). `moved` and `finished`
  played `lastFrom → lastTo`; `finished` completed the last family.
- **The restart rule** (spec-prop §7.7, vs-computer rule 7): at the start
  of a step, 250 moves made or no useful move (none, or only pointless
  ones) → `restarted`: no move, the board back at the start, `run + 1`, the
  next run's `Prng`. The win check comes first. A restart is a step of its
  own (Q127).
- **The run seeds** are `Prng.derive(raceSeed, 'RVL0' + policy.index, run)`,
  a departure from decision 14's `Prng.derive(raceSeed, policy, run)`,
  whose run 0 would be the generator's attempt 0 of the same seed (D133).
- **Determinism** (rule 7): integer kernel and `Prng` only; the rival's
  moves are a pure function of (level, policy, race seed). The race seed
  seeds both the board and the runs, so a Rematch (same raceNo) replays the
  same board and moves. `rival_parity_test` pins 18 digests plus restart
  cases on node, chrome and dart2wasm; `race_golden_test` pins three race
  boards (`race-1-1@20`, `race-2-1@70`, `race-3-1@120`).
- **Rule 8:** a move step allocates nothing (race-core's sweep: worst smart
  step 4.8 µs AOT); a restart allocates one `Prng`; `snapshot` allocates.
- **Public:** `RivalBot`, `RivalStep`, and `SimBot` (`show SimBot`);
  `BotPlayer`, `SmartScore` and the engine stay internal (`barrel_test`).
  `Generator.version` stays 1: every existing golden is unchanged.
- **The board's stage** is the caller's: `raceParams` takes the highest
  level won and range-checks it; the app passes `RaceRules.stageLevel`
  (Q125). With `race_unlock_level` tuned below 16, rivals 2 and 3 would get
  easy boards (every board below the tower stage simulates easy); the
  default 20 keeps every race at stage 16 or later (Q130).

### P2.4 The race request and the resolver's race case

```dart
enum PlayKind { campaign, bonus, daily, replay, race('race') }   // race never stored
const factory PlayRequest.race({required int rival, required int raceNo}) = RacePlay;
bool get isRace;   // number => raceNo; isGenerated => bonus | daily | race; tryCreate(race, _) => null
```

- **Never saved** (spec-prop §7.7 "A race in progress is never resumed"):
  `saveInProgress` ignores a race, `inProgressOf(race)` is null,
  `clearInProgress(race)` does nothing, the codec drops a stored one, and
  `recordLevelWin` records nothing for a race (it returns an empty
  outcome): a race's win goes only through `recordRaceWin` (P2.7).
- **`DefaultLevelResolver._race`** (implemented): null, with nothing
  generated, while the mode is locked (`RaceRules.modeUnlocked`: the save's
  `highestLevel > race_unlock_level`, as `HomeState.raceUnlocked`), for a
  rival outside 1–3 or one locked in the save, or a raceNo outside
  1–`maxRaceNo`. Otherwise `raceParams(rival, raceNo, highestWonLevel:
  RaceRules.stageLevel(highestLevel))` generated in the isolate
  (`LevelGeneratorService`, `generateWithRetries`) through
  `_ensureGenerated`, whose cache and in-flight de-dup give a Rematch the
  very same `Level` at once.
- **The entry:** the simulated tier, `levelVersion: Generator.version`,
  `rewardCoins: RaceRules.rewardCoins(rival)`, the current chapter's theme
  (the daily's; Q129), no chapter. `next(race)` is null; `homeRequest` is
  never a race; `prefetch` works (generated).
- **A failure** (every retry failed → null → the bloc's
  `AppException(content)`): the page shows the `NextLevelFailedCard` shape
  with `retry` and `raceBackToRivals` (race-ui). The raceNo was stored at
  selection, so the next race is a new board. Race-core's sweep found 0
  failures in 1,500 boards.
- **`FakeLevelResolver`:** a race comes from `generated` (a test fills it);
  `next` is null.

### P2.5 The RaceCubit

The gameplay page with a race request provides it beside the bloc. The
bloc owns the player's board; the cubit owns the rival, the clock, the
holds and the result. Frozen: every signature in P2.1. The race-bloc lane
builds `start`, `playerBoardChanged`, `setHold` and the tick to this
section.

```text
waiting --playerBoardLoaded--> ready --start--> running --(player won | rival finished)--> finished
finished --rematch()--> waiting (same request)      finished --newRace()--> waiting (next raceNo)
```

- **Setup** (`playerBoardLoaded(PlayEntry play)`, implemented): the page
  calls it on the bloc's `BoardResetEffect` of reason `start`. An entry of
  another request is ignored. It builds `RivalBot(play.level, policy:
  racePolicy(rival), raceSeed: raceSeed(rival, raceNo))` and its mirror
  `GameSession(play.level)`, both on the player's own `Level` object (so
  "identical copies" is literal), the pace stream `RaceRules.pacePrng(
  raceSeed)` (`Prng(Prng.derive(raceSeed, 'PACE'))`), reads `paceMs` and
  `jitterPct`, keeps `play.rewardCoins`, and emits `ready` with
  `totalSets` and `rivalBoard`. A level core can't race is an
  `AsyncValueError` of kind `content`.
- **Start** (vs-computer rule 4): `ready → running` at once, no countdown;
  `activity: thinking`; running time 0; the first due time is one interval
  (`RaceRules.nextIntervalMs`); the ticker starts unless a hold is on. The
  page then sends `RaceGateChanged(open: true)`.
- **The clock:** the injected `FrameTicker`, ticking only while running
  with no hold. Per tick: `delta = elapsed − last` (0 on the first tick
  after a start), clamped to `RaceRules.maxFrameDelta` (250 ms), added to
  the running time; when the running time reaches the due time, **one**
  rival step, then `due += nextIntervalMs(pace, paceMs, jitterPct)`. At
  most one step per frame. A tick that isn't due does integer arithmetic
  only: no emit, no allocation.
- **A step:** `moved` → `rival.move(bot.lastFrom, bot.lastTo)` (assert
  `MoveApplied`), `rivalMoves + 1`, `rivalSets` from the session,
  `activity: thinking`; `finished` → the same move, then `phase: finished`,
  `result: rivalWon`, `activity: finished`, the ticker stopped; `restarted`
  → `rival.restart()`, `rivalSets` 0, `rivalRestarts + 1`, `activity:
  startingOver` for that interval (Q127). One emit per step,
  `rivalBoard: rival.state`.
- **The pace** (spec-prop §7.7, Q79): `race_pace_ms_<rival>` clamped to
  0..`maxPaceMs`, or a dev debug build's `--dart-define=NESTY_RACE_PACE_MS`
  (`parsePaceOverride`, like `NESTY_FAKE_DATE`); interval = `paceMs + d`,
  `d` uniform in `−span..span`, `span = paceMs × jitterPct ~/ 100`, one draw
  per interval, integers only.
- **The player's win:** the page forwards every board the bloc emits
  (`playerBoardChanged`). A won board (`GameState.isWon`) while running and
  without a result: the ticker stops, `phase: finished`, `result:
  playerWon`, and `save.recordRaceWin(RaceWinRecord(rival, raceNo,
  rewardCoins, moves: board.moveCount, families: RecordRules.familiesIn,
  dolls: RecordRules.dollsNestedIn, boardBadges: BadgeRules.forWonLevel))`
  runs **exactly once**; its outcome is in the state. Any later board is
  ignored.
- **The tie** (spec-prop §7.7 "on the same frame the player wins"): the
  rival moves only inside a frame tick, and a player's move is applied in
  its input task's microtasks (the bloc's in-play handlers are
  synchronous; the bloc's class doc says so), and the page's listener
  forwards the won board in a microtask too, before the next frame. So a
  player win delivered before frame N beats a rival finish due in frame N:
  the tick finds the result decided. A rival finish in frame N's tick
  comes first when the player's move lands after it; the page then closes
  the gate, and the bloc (FIFO) refuses any later move.
- **Holds** (spec-prop §7.7 "Pause"): `RaceHold.pause` (the Pause dialog,
  and Settings over it), `overlay` (the out-of-moves sheet, the booster
  popup, any overlay over the board), `app` (`AppLifecycleState` other than
  `resumed`). They stack; any hold stops the ticker, and the last one off
  restarts it from elapsed 0, so background time never counts, no due time
  moves, and the race resumes exactly where it was. `held` mirrors "any
  hold". A hold set before Start still counts at Start.
- **Rematch and New race** (implemented): only from `finished`; they stop
  the clock, drop the rival and go back to `waiting`. `rematch()` returns
  the same request (writes nothing); `newRace()` calls
  `save.beginRace(rival)` and returns the next request (null, nothing
  changed, if the save refuses). The page then sends `GameplayStarted` with
  it on the same page (not `router.replace`, which auto_route answers by
  keeping the page, its bloc and cubit), and the next `playerBoardLoaded`
  rebuilds the rival from run 0: the same seed gives the same moves at the
  same intervals.
- **Leaving** (Quit race, back, a kill): `close()` disposes the ticker and
  writes nothing (spec-prop §7.7 "leaving it ends it with no reward"; a
  loss writes nothing either).

### P2.6 The gameplay bloc's race mode

`GameplayState.raceLive` (default false), `isRace`, and `acceptsInput`
adds `(!isRace || raceLive)`. `RaceGateChanged(open:)` sets `raceLive` in a
race and is ignored outside one (implemented). The constructor is
unchanged. The race-bloc lane builds the rest, in a race only:

- **Boosters** (spec-prop §7.7 "Undo and restart are free and unlimited.
  Hint and extra slot are off"): Undo takes the relaxed branch (free, no
  offer, no spend; `booster_use` and `stats.boostersUsed` still count it,
  as in relaxed mode); Restart is free as always; Hint, +1 Slot (the debug
  free slot included) and a purchase confirm for either do nothing: no
  offer, no spend. `canHint` and `canAddSlot` are false.
- **Nothing extra:** no tutorial cue, no intro card, no restore, no
  `_persistProgress`. Out of moves opens the sheet (race-ui shows Undo and
  Restart only); the soft-stuck check and banner stay.
- **`_win`:** cancels solver work, sets `status: won` and `winMoves`,
  nothing else: no `recordLevelWin`, no coins, chest, figurine,
  `currentLevel`, best moves (Q88), `firstWin` or `nextRequest`, no
  prefetch. The cubit records the win (P2.5).
- **Analytics:** none of spec §14.4's level events (`level_start`,
  `level_restart`, `level_win`, `level_out_of_moves`, `level_soft_stuck`):
  a race isn't a level (Q128). `booster_use` stays.
- **The tie guard:** every in-play handler stays synchronous up to
  `session.move` (the class doc); race-ui's real-bloc page test pins it.

### P2.7 The save's race-result API

```dart
int? beginRace(int rival);                        // raceNo + 1 (at most maxRaceNo), one update; null: off 1..3 or locked
RaceWinOutcome recordRaceWin(RaceWinRecord win);  // one update; RangeError: rival off 1..3, raceNo off 1..maxRaceNo, reward < 0
@freezed abstract class RaceWinRecord { required int rival; required int raceNo; required int rewardCoins;
  @Default(0) int moves; @Default(0) int families; @Default(0) int dolls; @Default(<BadgeId>[]) List<BadgeId> boardBadges; }
@freezed abstract class RaceWinOutcome { @Default(0) int coins; int? unlockedRival; @Default(0) int wins;
  @Default(<BadgeId>[]) List<BadgeId> newBadges; }
```

- **`beginRace`** runs when a race is chosen (rival select's Race, New
  race), never at the result: the request then carries the raceNo, so
  resolving and Rematch are pure, and a quit or a kill can't hand the same
  board back as a new race. At the cap the raceNo stays (New race replays
  the last board; Q126). Rematch doesn't call it.
- **`recordRaceWin`, one update:** coins += reward; the rival's `wins` + 1;
  the next rival unlocks if locked (1 → 2 → 3; `unlockedRival` only when
  new, never from rival 3); `stats.wins` + 1 and `stats.moves` + moves;
  `records.families` and `records.dolls` (races count, Q91); the badges:
  `BadgeRules.newlyEarned(boardBadges ∪ derivable(after))`, appended, the
  same helper as `recordLevelWin` (`first_race` and `all_rivals` are
  derivable from `race.rivals`, so `BadgeRules` doesn't change). A Rematch
  win pays again (Q124).
- **Unlock order** stays strictly 1 → 2 → 3: the codec keeps rival 1 and
  any rival with a win unlocked (phase 1), `beginRace` refuses a locked
  rival, and so does the resolver.
- **No save field is added:** schema 2's `race.rivals` (unlocked, wins,
  raceNo) is everything the race needs (vs-computer rule 12's "schema step"
  is phase 1's step 1 → 2). No Hive change.

### P2.8 Routes and DI

- **`RivalSelectRoute`** (`features/race/pages/rival_select_page.dart`),
  pushed on the root router behind `ContentReadyGuard` (music_home, as
  every non-gameplay page). An `AutoRouteWrapper` over `RivalSelectCubit(
  save, remoteConfig)`: `RivalSelectState({coins, List<RivalCard>
  rivals})`, `RivalCard(number, unlocked, wins, rewardCoins)`, following
  `SaveService.changes` (a race's unlock shows on the way back);
  `begin(rival) → RacePlay?` (null while the mode or the rival is locked)
  stores the raceNo, and the page pushes `GameplayRoute(request: race)`.
- **The race** is `GameplayRoute(request: PlayRequest.race(rival:,
  raceNo:))`: `GameplayPage.wrappedRoute` adds `BlocProvider<RaceCubit>(
  create: (_) => get<RaceCubit>(param1: request))` and passes it as
  `GameplayView.race`. One page, one board, the same overlays.
- **Home's tile** (race-ui): once `raceUnlocked`, a tap pushes
  `RivalSelectRoute` on the root router, and the footer goes (P2.10).
- **`FrameTicker`** (`core/services/ticker/`): real `SchedulerFrameTicker`
  in both envs, one per race; `FakeFrameTicker` in tests. `RaceRules`
  (`core/services/race/`) is pure rules with no interface.

### P2.9 The rival strip's data

- `BlocSelector<RaceCubit, AsyncValue<RaceState>, RivalStripData>` with
  the record `(rival, activity, rivalSets, totalSets, rivalMoves, held)`
  (race-ui defines it in its widget): "Rival N · Computer", the families
  (`raceStripFamilies`), and the state line from `activity` (`idle` →
  `raceStripReady`, `thinking` → `raceStripThinking`, `startingOver` →
  `raceStripStartingOver`, `finished` → `raceStripFinished`). A
  `rivalMoves` bump plays the strip's short "moved" beat (none with reduce
  motion). The cubit emits once per rival step, never per frame.
- **The board never rebuilds for a rival move:** the Flame board is built
  once and fed only by the bloc's effects; the cubit never touches the
  bloc's state; the strip sits in its own `RepaintBoundary`; the view's
  `BlocListener<RaceCubit>` listens only to `phase` and `result` (the gate,
  the result card), so a rival move never calls the view's `setState`.
- **Screen readers:** one merged node, `raceStripSemantics(name, done,
  total)`; a separate live region announces only a family completed
  (`raceAnnounceFamily`), a restart (`raceAnnounceStartingOver`) and the
  finish (`raceAnnounceFinished`), at most one per 2,000 ms (the latest
  wins).

### P2.10 The stand-in UI (the ui-spec, adjusted to what is frozen)

Built from `design/tokens.json`, the App Flow frames it reuses (2.1, 2.8,
the HUD and booster bar, 3.5, 3.9, 5.6) and the UI kit, since Claude
Design's section C (frames 9.1–9.6) hasn't landed. §15's shared rule holds
(every row or cell `Expanded` + its own `FittedBox(scaleDown)`, vertical
`ListView`s, the ~600 dp column on 768 × 1024). Every item carries
`TODO(design)`. The gaps are already in the design request's section C
(the lead added the ui-spec's list): none is added here.

- **Two atoms** (race-ui, `lib/core/ui/widgets/race/`, exported from
  `nesty_ui.dart`): `ComputerTag` (the `smartDisplay` glyph, 16 px, and
  `raceComputerTag`, `TierChip`'s pill shape in the neutral `surfaceSunk`/
  `textSecondary` tones, never a tier's colour) on every rival surface; and
  `RivalPortrait` (a round `HomeTileIcon`-style tile in the Home tile's
  teal, `gradient.bonus`/`bonusEdge`, with the `smartDisplay` glyph, 96 dp
  on select and 48 dp on the strip; rivals told apart only by a small
  walnut number badge, never by invented character art).
- **9.1 Home tile:** unchanged `HomeTile`; locked (`homeVsComputerLocked`)
  before the unlock; once unlocked a tap opens rival select and the footer
  goes (like the Daily tile's). `homeVsComputerSoon` retires (the
  integrator removes the key once no code reads it; Q98 follows).
- **9.2 Rival select:** `ScreenHeader(raceSelectTitle, coins)` over a
  `ListView` of three cards in `WideScreenColumn`: `RivalPortrait` 96,
  `raceRivalName` (`cardTitle`) + `ComputerTag`, `raceRivalBlurb`
  (`bodySmall`, `textSecondary`), `raceRivalSkill` (`caption`), the reward
  chip (`CoinIcon` + `raceRivalReward`, shown before the race: spec-prop
  §1.1 rule 2), `raceRivalWins`, and `TactileButton(compact, primary)`
  `raceSelectRace`. Locked: 55 % portrait, `NestyIcons.lock` on the badge,
  `raceRivalLocked(previous)` in place of the blurb, no button, inert.
  Semantics `raceRivalSemantics(name)`.
- **9.3 The race board** (the gameplay page): the same theme background,
  Flame board and HUD (pause button, coin pill: the live balance, no coin
  hold). `LevelPill` shows `hudRaceChip` with `smartDisplay` instead of the
  level and tier. The **rival strip** (P2.9): a full-width card ~64 dp tall
  (a guess) under the family counter, in the band the soft-stuck banner
  starts at; the banner moves down by the strip's height when both show;
  `RivalPortrait` 48 + name + `ComputerTag` on the left, a walnut counter
  pill (`FamilyCounterPillPainter` at 0.8×) and the state line on the
  right (the state line drops first below the smallest width). No second
  board (Q134). **Below the board** the `WoodBar` shows: in `ready`, one
  centred `TactileButton(raceStart, playArrow)` in the boosters' place, no
  scrim, no countdown; while running, exactly Undo and Restart
  (`BoosterButton` 80 × 58), Undo's badge `BoosterBadge.infinite()` whatever
  the Relaxed mode setting. Generating: `gameplayGenerating` + the spinner,
  as for a bonus level. Thinking is a static label (no loop); the counter
  bumps once (200 ms, `motion.complete.counterBump`) when a rival family
  lands; "Starting over" for its interval; finished shows a static
  `checkCircle`, no confetti.
- **9.4 You win:** `WinOverlay`'s scaling wrapper, `OverlayEntrance(fade)`,
  `Scrim`, `fx_confetti`, `RibbonTitle(raceWinTitle)`, the reward chip as
  2.8's (`winCoins` count-up, `fx_coin_burst`, the `win` and `coinsCountUp`
  sounds, until `jingle_versus_win` lands), `winMovesOnly(winMoves)` (no
  best, no stars: Q88, D125), `raceRivalName` + `ComputerTag`, then
  `raceRematch` (primary), `raceNewRace` (secondary) and the
  `raceBackToRivals` link. The badge toasts (`outcome.newBadges`) as the
  win card does.
- **9.5 The computer finished first:** a `ModalCard` + `RibbonTitle`
  (`PauseDialog`'s shell), `OverlayEntrance(modal)`, a regular `Scrim`
  (never `Scrim.strong`, no danger tone or red), `RivalPortrait` +
  `ComputerTag`, `raceLossTitle` and `raceLossBody`, the same three
  actions. No reward, no move count, no comparison. It opens at once over
  the frozen board.
- **9.6 Rival unlocked:** after the first win against rival 1 or 2
  (`outcome.unlockedRival`), a `BadgeToast`-style `NestyToast` (success
  tone, `smartDisplay`), `raceRivalUnlockedTitle` + `raceRivalUnlockedBody(
  name)`, ~900 ms after 9.4 opens, after any badge toast (Q131). Never
  again on a rematch.
- **Pause in a race** (3.9's system): `racePauseSubtitle(name)` for the
  subtitle; two tiles, Restart (the player's own board only; the rival
  keeps its progress) and `raceQuit` (`NestyIcons.close`, one tap, no
  confirmation: Q133; pops to rival select, nothing written); no Settings
  tile (Q132). Resume releases the `pause` hold.
- **Out of moves in a race:** `OutOfMovesSheet(relaxed: true, onExtraSlot:
  null)`: Undo "Always free" and Restart only.
- **Holds from the view:** Pause and Settings → `pause`; the out-of-moves
  sheet, the booster popup and any overlay → `overlay`;
  `AppLifecycleListener` (any state but `resumed`) → `app` (`hidden` still
  opens Pause).
- **Records:** the three `recordsRaceRow` rows now read `race.rivals[i].
  wins` (already built).
- **Reduce motion:** thinking has no motion; the counter bump follows the
  family counter's `durationScale`; 9.4 follows 2.8's rules; no shake,
  confetti or wobble elsewhere.

Departures from the ui-spec: the race is `GameplayRoute` with a race
request, not `RaceRoute(rival:)` (the plan); the route is
`RivalSelectRoute` (the ui-spec's `RaceSelectRoute`); the keys are P2.11's
names; the loss reads vs-computer rule 10's "The computer finished first"
with C.4's "So close! Rematch?" below it; rival 3's blurb and skill avoid
"quick" (the respect deny-list's urgency word): "Careful, and fast with it."
and "Speedy", and rival 1's "Easygoing" (not "Relaxed", the Settings mode's
name); 9.4 adds the moves line (Q88's default for race boards).

Integration (PROGRESS D140, D141): 9.4 opens on the board's own win report
(after the winning batch, as 2.8 does), 9.5 at once over a frozen board;
every way out of a race pops the page; a board that can't be made shows the
failure card with Back to rivals on the first load and on Rematch or New
race; the HUD reads the save's live balance; the strip lets taps through to
the board; the counter bumps on a rival family and a portrait nudge is the
"moved" beat; the state line drops below 340 dp (Q135). Four new gaps went
into the design request's C.9.

### P2.11 The ARB keys added (all in `app_en.arb`)

Every description ends "Placeholder until Claude Design's copy.md lands."
`arb_keys_m7_test` pins them.

| Key | English | Where |
|---|---|---|
| `raceSelectTitle` | vs Computer | rival select header |
| `raceComputerTag` | Computer | `ComputerTag` on every rival surface |
| `raceRivalName(number)` | Rival {number} | a rival's name until copy.md names them |
| `raceRivalBlurb(number)` | Takes it easy, one move at a time. · Thinks each move through. · Careful, and fast with it. | select card |
| `raceRivalSkill(number)` | Easygoing · Careful · Speedy | select card |
| `raceRivalReward(coins)` | Win {coins} coins (1: Win 1 coin) | select card's reward chip |
| `raceRivalWins(count)` | Ready to race · 1 win · {count} wins | select card |
| `raceRivalLocked(number)` | Win against Rival {number} to unlock | a locked card |
| `raceRivalSemantics(name)` | {name}, Computer | portrait and card semantics |
| `raceSelectRace` | Race | a card's button |
| `raceStart` | Start race | the Start button |
| `raceStripReady` | Ready | strip, before Start |
| `raceStripThinking` | Thinking… | strip, between moves |
| `raceStripStartingOver` | Starting over | strip, a restart |
| `raceStripFinished` | Finished | strip, the rival done |
| `raceStripFamilies(done, total)` | {done}/{total} | strip's counter |
| `raceStripSemantics(name, done, total)` | {name}, Computer: {done} of {total} families | strip semantics |
| `raceAnnounceFamily(done, total)` | The computer completed a family: {done} of {total} | live region |
| `raceAnnounceStartingOver` | The computer is starting over. | live region |
| `raceAnnounceFinished` | The computer finished all families. | live region |
| `hudRaceChip` | vs Computer | the level pill in a race |
| `raceWinTitle` | You win! | 9.4 |
| `raceLossTitle` | The computer finished first | 9.5 |
| `raceLossBody` | So close! Rematch? | 9.5 |
| `raceRivalUnlockedTitle` | New rival unlocked! | 9.6 |
| `raceRivalUnlockedBody(name)` | {name} · Computer is ready when you are. | 9.6 |
| `raceRematch` | Rematch | 9.4, 9.5 |
| `raceNewRace` | New race | 9.4, 9.5 |
| `raceBackToRivals` | Back to rivals | 9.4, 9.5, the failure card |
| `racePauseSubtitle(name)` | {name} · Computer | Pause in a race |
| `raceQuit` | Quit race | Pause in a race |

Reused, no new key: `winCoins`, `winMovesOnly`, `coinsSemantics`, `retry`,
`gameplayGenerating`, `restart`, `undo`, `oomUndoFreeUnlimited`,
`boosterUndoUnlimitedSemantics`, `pauseTitle`, `recordsRaceRow`,
`homeVsComputerTile`, `homeVsComputerLocked`.

### P2.12 E1, the race tests

| Test | What it pins | Written by |
|---|---|---|
| `test/ethics/respect_copy_test.dart` | `race*` and `hudRace*` values against the deny-list (a loss is warm; nothing hurries) | contracts (done) |
| `test/ethics/reward_randomness_test.dart` | no `Random`/`DateTime.now` in `core/services/race`, `core/services/ticker`, `features/race` (the rival and the pace draw only from core's seeded streams) | contracts (done) |
| `test/core/ui/arb_keys_m7_test.dart` | the 31 keys; "Computer" in every rival-surface string; no "online", "typing", "chat" | contracts (done) |
| Race mode offers no Hint or +1 Slot | a race's Hint, +1 Slot and purchase confirms: no `BoosterOffer`, no spend; undo past `free_undos_per_level` free | race-bloc (bloc tests) |
| "Computer" on every rival surface | select, strip, results and Pause show the tag and the word | race-ui (widget tests) |
| `test/ethics/race_respect_test.dart` | one race through the real bloc and cubit on fakes: pressing Hint and +1 Slot never emits a `BoosterOffer`, coins only rise by the reward; a loss and a quit write nothing; nothing in `RaceState` counts down | integrator |

### P2.13 Lane ownership and test plans

A lane touches only its paths; everything else goes in its report for the
integrator. Generated files come only from the lock script. Every lane
writes its report (with the six ethics answers) and keeps a checkpoint.

| Lane | Owns (exclusive) | Builds | Tests (in its paths) |
|---|---|---|---|
| **race-core** (nesty-core-engineer) | `packages/nesty_core/**` | done (P2.3); only a fix a lane reports | its suites stay green: VM, node, chrome, dart2wasm parity, every golden unchanged |
| **race-services** (services-engineer) | `lib/core/services/{save,race}/**`, `lib/core/repository/{level_resolver,default_level_resolver,fake_level_resolver}.dart`, `test/core/services/{save,race}/**`, `test/core/repository/{default_level_resolver,fake_level_resolver}_test.dart` | owns the implemented save API, codec case, `RaceRules` and `_race`: their full tests and any fix (never a frozen signature) | `beginRace`: +1 in one update and one `changes` event, null for a locked rival or one off 1..3, the cap, a reload (Hive round trip) keeps the raceNo and pays nothing ("a kill leaves no reward"). `recordRaceWin`: each step (coins, wins, unlock 1→2→3 and none from 3, `unlockedRival` only when new, stats, records, `first_race` once, `all_rivals` on the last first win, board badges), one `changes` event, the RangeErrors, a Hive round trip. `recordLevelWin` ignores a race; `saveInProgress`/`clearInProgress` too; the codec drops a race `inProgress`. `RaceRules`: every clamp, `nextIntervalMs` range and determinism over many draws, one draw per call, the define only in a dev debug build, `stageLevel` at 1, 21, 31, 51, 71. The resolver: the stage level, mode locked, rival locked, raceNo 0 and past the cap, the cache giving the same `Level`, a generator failure giving null, the theme, never restored, `next` null; `FakeLevelResolver`'s race |
| **race-bloc** (bloc-architect) | `lib/features/gameplay/bloc/**`, `lib/features/race/cubit/**`, `lib/core/services/ticker/**`, `test/features/gameplay/bloc/**`, `test/features/race/cubit/**`, `test/core/services/ticker/**` | the `RaceCubit` bodies (P2.5: start, the tick, pace, holds, the result, the tie) on `FakeFrameTicker`; the bloc's race mode (P2.6) | vs-computer "Bloc" tests, on `FakeFrameTicker`, `FakeSaveService`, `FakeRemoteConfigService`: the first rival move one interval after Start, then intervals within ±pct, the same (time, move) list from two cubits and from a Rematch; every rival move `MoveApplied` on the mirror; `startingOver` and `rivalSets` back to 0 on a dead board and at the cap; pause, overlay and app holds each stop it, overlapping holds, no due time moving while held, a 10 s frame gap counting 250 ms; a win: `recordRaceWin` once, a second won board ignored; a loss: no `changes` event; board-then-tick → player, tick-then-board → rival; `outcome.unlockedRival` surfaced; `close()` mid-race writes nothing; Rematch/New race from each phase. The bloc: no offer and no spend for Hint and +1 Slot (and the purchase confirm), `canHint`/`canAddSlot` false, undo free past `free_undos`, a win writes nothing to the save, nothing persisted, no cue or intro card, no level events, input refused before the gate opens and after it closes, a mid-drag drop putting the doll down |
| **race-ui** (flutter-frontend-dev) | `lib/features/race/{pages,widgets}/**`, `lib/core/ui/widgets/race/**` (+ its export lines in `nesty_ui.dart`), `lib/features/gameplay/{pages,overlays,widgets}/**` except `pages/gameplay_board.dart`, `lib/features/home/**`, `lib/core/ui/widgets/booster/**`, their tests, `test/overflow/race_overflow_test.dart` | the tile opening rival select; rival select (9.2); the view's race wiring (`playerBoardLoaded` on the start effect, `playerBoardChanged`, Start, the gate from the phase, the holds, in-page Rematch and New race, Quit race → pop); the strip (P2.9); 9.4–9.6 with the toasts; Pause, the out-of-moves sheet and the bar in a race; `LevelPill`'s race chip; the failure card; `TODO(design)` on each | widget and page tests on the recording board with the real bloc and cubit on fakes: "Computer" on select, strip, results and Pause; no Hint or +1 Slot in the bar or the sheet; the tile locked before L20 and then opening select; each strip state; the tie in one pumped frame (the real bloc); `handleAppLifecycleStateChanged` holds; Rematch replaying on the same page; the result cards per outcome; overflow at the five sizes × 1.0 and 1.3 |
| **integrator** | cross-lane edits, DI and codegen's final pass, `integration_test/**`, `test/ethics/**`, the ARB, CLAUDE.md, README, docs, the TODO index | the rival-1 segment: the dev picker past L20, Home's tile, rival 1, Start, then the solver's moves on the board it regenerates from `raceParams(1, 1, 20)` (`race-1-1@20` in core's `race_vectors.dart`: the rival finishes in 19 steps) with `--dart-define=NESTY_RACE_PACE_MS=600000`; expects "You win!", +20 coins, Rival 2 unlocked and "Computer" on screen. The E1 race session test; README's define; the E10 ethics row; retiring `homeVsComputerSoon`; closing the BACKLOG items | the `/milestone` baseline gate, core web parity, the segment on the iPhone 16 Pro simulator and the API 35 emulator |

vs-computer "Tests", mapped: same seed → same moves and never an illegal
move (race-core, done; race-bloc's mirror assert and two-cubit list);
restarts on a dead board and at the cap (race-core, done; race-bloc's
`startingOver`); params use only the stage's mechanics, seeds don't collide
(race-core, done); pace and jitter (race-services' `nextIntervalMs`,
race-bloc's timing); pause stops the rival (race-bloc, race-ui's lifecycle);
win and loss, the reward once (race-bloc, race-services' one update); the
tie (race-bloc, race-ui); unlocks in order (race-services, race-bloc);
Rematch replays the same moves (race-bloc, race-ui); a kill leaves no reward
(race-services' reload, race-bloc's `close`); "Computer" everywhere
(contracts' ARB pins, race-ui, the integrator's E1 test); no Hint or +1 Slot
(race-bloc, race-ui, the integrator); the tile locked before L20 (race-ui);
beat rival 1 (the integrator's segment).

### P2.14 Decisions and questions

| D | Decision | Section |
|---|---|---|
| D132 | This phase-2 design and its frozen contracts; lanes and the codegen lock | P2.1, P2.2, P2.13 |
| D133 | Plan-m7 decision 14, as built: the core rival API (`RivalBot`, `RivalStep`, `SimBot` public, `stepRun`, the labelled run streams, a restart as a step, no version bump), the rival stepping on the UI isolate from an injected ticker, raceNo + 1 per chosen race and none per Rematch | P2.3, P2.5 |
| D134 | Race boards: the seed and its bounds, the policy and tier table in core, the stage of the highest level won | P2.3, P2.4 |
| D135 | `PlayRequest.race`: its own kind, generated, never saved; the resolver's race case; a failure goes back to rival select | P2.4 |
| D136 | `RaceCubit` beside the bloc on the gameplay page: the mirrored rival, the frame clock, the `'PACE'` jitter, the holds, the tie by frame order, in-page Rematch and New race; `RaceRules` | P2.5 |
| D137 | The bloc's race mode: the gate, undo free, Hint and +1 Slot off, no level record, no level events | P2.6 |
| D138 | The save's race API: `beginRace` at selection, `recordRaceWin` in one update, no schema step | P2.7 |
| D139 | Rival select, the stand-ins, the 31 keys and the E1 race tests; the Home tile opens rival select | P2.8, P2.10–P2.12 |

Departures from the architecture proposal, each recorded: its D113–D118
and Q99–Q104 are D133–D138 and Q124–Q129 here; `_race` is implemented now
rather than returning null until race-services (it is short, and a real
race board lets race-ui and the integrator run early); `_race` also
refuses a race while the mode is locked; `beginRace`/`recordRaceWin` throw
a `RangeError` on a negative reward or a raceNo off range, as
`recordLevelWin` does, rather than clamping; `FrameTicker` gains
`isTicking`; `RivalSelectState` gains `coins`; the ARB set merges the
proposal's and the ui-spec's (P2.10 lists the copy changes);
`homeVsComputerOpen` is not added (the unlocked tile has no footer).

| Q | Question | Default |
|---|---|---|
| Q124 | A Rematch after a win pays again? | yes: "a win pays", no cap (Q77) |
| Q125 | The board's stage is the highest campaign level won (`highestLevel − 1`)? | yes |
| Q126 | Keep the seed formula (bonus ≥ 2,100,001 and years 310–339 formally overlap, both unreachable) and cap raceNo at 99,999, New race then replaying the last board? | yes |
| Q127 | A restart takes the rival one pace interval, shown as "Starting over"? | yes |
| Q128 | Quit race goes back to rival select and the left race's raceNo is used up; races log no spec §14.4 level events until M4 defines race events? | yes to both |
| Q129 | A race board uses the current chapter's theme until frame 9.3 lands? | yes |
| Q130 | If `race_unlock_level` is tuned below 16, rivals 2 and 3 get easy boards: clamp the race stage to 16 or later, or accept? | no clamp; the default 20 keeps every race at stage 16 or later |
| Q131 | "Rival unlocked" (9.6) as a toast over the win card, or a fuller card? | a toast |
| Q132 | Pause in a race without the Settings tile? | yes: Restart and Quit race only |
| Q133 | Quit race in one tap, with no confirmation? | yes, like every Pause tile |
| Q134 | The rival strip as a counter pill, no second board, until frame 9.3? | yes |

### P2.15 Verification

Contracts stage (2026-09-28):
- `cd packages/nesty_core && dart test`: 1,606 pass (the race core as the
  race-core lane applied it; its web parity runs are in its report).
- `LANE=contracts2 codegen.sh all`: exit 0 (73 outputs).
- `flutter analyze --fatal-infos --fatal-warnings` at the root: no issues.
- `cd apps/game && flutter test --timeout 120s -r failures-only`: 2,523
  pass, 0 fail (`test/contracts/m7_phase2_test.dart` 23, and the extended
  `arb_keys_m7_test`, E1 and `di_test`).
- `cd tools && dart test test/claude_md_test.dart`: 6 pass.

Phase-2 integration (2026-09-28, integrator; PROGRESS D140–D142):
- `LANE=integrator2 codegen.sh l10n` (after retiring `homeVsComputerSoon`),
  then `all`: exit 0.
- `flutter analyze --fatal-infos --fatal-warnings` at the root: no issues.
- `dart format --output=none --set-exit-if-changed`, CI's exclusions,
  tracked and untracked files: 879 files, 0 changed.
- `cd packages/nesty_core && dart test`: 1,606 pass; `dart test -p node
  test/parity test/generator/golden_test.dart`: 78 pass.
- `cd packages/nesty_render && flutter test`: 530 pass.
- `cd apps/game && flutter test --timeout 120s`: 2,776 pass, 0 fail.
- `cd apps/admin && flutter test`: 47 pass.
- `cd tools && dart test`: 330 pass.
- `nesty_levels bundle check` / `fixtures check`: 200 levels OK / 11
  fixtures OK; `gen_design_tokens`, `gen_nesty_icons`,
  `sync_design_assets`, `gen_fx_spec` with `--check`: unchanged;
  `todo_index`, then `--check`: 120 tagged markers, unchanged.
- The ethics checklist's E10 row: filled, no failing answer.

Left for the device stage: the playthrough (with its rival-1 segment,
`NESTY_RACE_PACE_MS=600000`) on the iPhone 16 Pro simulator and the API 35
emulator, then the phase-2 close.

Phase-2 device run (2026-09-28, device stage; PROGRESS D143). All from fresh
installs:
- iPhone 16 Pro simulator (iOS 18.3): all 9 `nesty-test` steps pass. The
  playthrough takes 430 s and takes 85 screenshots, the race's 25–25f
  included.
- API 35 emulator: all 9 steps pass. The playthrough takes 420 s.
- Resume: phase A matched phase B in all four runs.
- Daily: the fingerprint is the same on iOS, Android and in core
  (daily-20260926).
- Two stand-in fixes, each with a regression test: the strip's counter pill
  draws at 0.8×, and 9.4's rows sit on a ModalCard.
- After the fixes: `flutter analyze --fatal-infos --fatal-warnings` is
  clean, `apps/game` passes 2,778, and `todo_index --check` is unchanged.

## Phase 3: star ratings, the daily share card and the opt-in reminder

Written 2026-09-29 by the M7 phase-3 contracts stage. Sources, in order:
spec-prop §7.10 (stars), §7.9 (the reminder), §10.2 (#4, #11, #13, #18,
#19), §13.3 (the save) and §1.1 (the respect rules), which are the spec
until Q85; [star-rating.md](star-rating.md) (D125, the defaults of
Q116–Q120); plan-m7 decision 15 (the reminder); the phase-3 architecture
proposal and the ui-designer's stand-in spec (adopted, with the lead's
notes and the departures in P3.14); design request K, I.1, I.2, G.6, G.7,
G.11. Decisions are PROGRESS D144–D155; the owner questions are
Q137–Q148. Phase 2's shapes (`RaceWinRecord`/`RaceWinOutcome`,
`beginRace`, `recordRaceWin`, `_withWinBadges`, `raceLive`,
`RaceGateChanged`, `PlayKind.race`) are unchanged: a race records nothing
through `recordLevelWin` (its early return stays first), its `_win` branch
returns before any star code, and `PlayRequest.isBundled` excludes it, so
races have no stars.

**Reconciled with phase 2** (the architecture's §8 checklist, against the
integrated tree): the save's race API, the bloc's race branch, the
resolvers, the race result widgets and the splash constructor are as phase
2 left them; the ARB's phase-3 keys come after the race keys and retire
nothing; `RemoteConfigKeys.all` was 29 and is now 31; the ethics tests
keep phase 2's paths and prefixes and add phase 3's; the numbering starts
at D144 and Q137. Two shapes differ from what the architecture assumed and
are adapted (P3.14): `RecordsSummary.of` needs the par count, and two
Daily tests pumped `DailyPage` rather than `DailyView`.

### P3.1 What this stage froze

These files exist, compile (`flutter analyze --fatal-infos
--fatal-warnings` clean), are documented and have minimal tests
(`test/contracts/m7_phase3_test.dart`, core's `star_rating_test` and
`level_bundle_par_test`). A lane adds behaviour where P3.13 says so and
never changes a frozen signature; a needed change goes in its report for
the integrator. "Implemented" means the body is complete and tested, and
the owning lane extends its tests.

| Area | Files (frozen) | State |
|---|---|---|
| Core rule | `packages/nesty_core/lib/src/rules/star_rating.dart` (`StarRating`: `maxStars`, `minStars`, `assistedMaxStars`, `maxSlackPct`, `threshold`, `starsFor`, `starsForWin`), the barrel's export | implemented |
| Bundle codec | `codec/level_bundle.dart`: `LevelBundleEntry.par` (`int?`, in `==`, `hashCode`, `toString`), written after `rewardCoins` only when present, read leniently (a warning, the entry kept) | implemented |
| Remote Config | `remote_config_keys.dart`: `star3SlackPct` (`star3_slack_pct`, 20), `star2SlackPct` (`star2_slack_pct`, 60), in `all` (31 keys) | implemented |
| Save, schema 2 | `save_document.dart`: `levelStars`, `starTipShown`, `DailyProgress.lastSolve`, `DailySolve`, `InProgressLevel.hinted`, `LevelWinRecord.starsKey`/`stars`/`minuteOfDay`, `LevelWinOutcome.stars`/`previousStars`/`showStarTip`; `save_document_codec.dart`; `save_migrations.dart` (docs only); `save_service.dart` (`backfillLevelStars`, `recordLevelWin`'s star step); `in_memory_save_service.dart` | implemented |
| Stars glue | `core/services/records/star_rules.dart` (`StarSlack`, `StarRules`); `records_summary.dart` (`stars`, `starsPossible`, `threeStarLevels`; `.of(…, starLevels:)`); `records_cubit.dart` (passes it); `core/models/play_entry.dart` (`par`) | implemented |
| Bloc state | `gameplay_state.dart`: `stars`, `previousStars`, `starTarget`, `starTip`, `starsNewBest` | fields only: the bloc's behaviour is stars-app's (P3.6) |
| Chapters data | `chapters_state.dart`/`chapters_cubit.dart`: `ChapterLevel.stars`, `ChapterSection.stars`, `ChapterSection.starsPossible` | implemented |
| UI kit | `core/ui/widgets/stars/star_row.dart` (`StarRow`, `StarRow.reveal`, the sizes), exported by `nesty_ui.dart` | a static stand-in: the reveal's motion and cues are stars-ui's (`TODO(M7)`) |
| Daily's solve | `daily_status.dart` (`solve`), `streak_daily_service.dart` (publishes today's) | implemented |
| Share | `core/services/share/share_service.dart` (`ShareService`, `ShareOutcome`) | interface only: `SharePlusShareService`, `FakeShareService` and the wiring are the share lane's |
| Reminder settings | `core/models/reminder_settings.dart` (`ReminderSettings`); `settings_schema.dart` (the four keys, `SettingsKeys.reminder`, `SettingsDefaults.reminder`); `DatabaseService.{reminder, setReminder, reminderChanges}` in Hive and the fake; the shared contract test; `hive_save_service_test`'s gated double | implemented |
| Notifications | `core/services/notifications/`: `notification_service.dart` (`NotificationService`, `NotificationPermission`, `reminderId`), `reminder_plan.dart` (`ReminderPlan`), `fake_notification_service.dart` (implemented), `local_notification_service.dart` (a safe stub: never prompts, schedules nothing, reads unknown; `TODO(M7)`) | fake implemented; the real one is the reminder lane's |
| Reminder | `core/services/reminder/daily_reminder.dart` (`DailyReminder`), `reminder_status.dart` (`ReminderStatus`, `ReminderEnableResult`); `bootstrap.dart` starts it | `refresh` reads the settings, the permission and the lock; `planFor` implemented; `start`, `enable`, `disable`, `setTime` are safe stubs (`TODO(M7)`) |
| The offer | `features/daily/cubit/reminder_offer_cubit.dart` + `reminder_offer_state.dart` (`ReminderOfferStep`, `ReminderOfferState`), `widgets/reminder_offer_card.dart` (`ReminderOfferCard`, `.provided()`); `DailyView({reminderOffer})`, which `DailyPage` fills | frozen hidden: `load` emits `hidden`, the card renders nothing (`TODO(M7)`); the slot shows only while solved (implemented) |
| Copy | `app_en.arb`: 26 keys (P3.11), gen-l10n run | final English is Claude Design's (G.6, G.7, G.11, I.1, I.2) |
| E1 | `respect_copy_test` (8 prefixes, a star-shaming list, the reminder never names a streak), `reward_randomness_test` (`core/ui/widgets/stars`), `arb_keys_m7_test` (the 26, their G./I. suffix, the share text's placeholders) | implemented |
| Platform | `apps/game/pubspec.yaml` (four packages), the root `pubspec.lock`, `android/settings.gradle.kts` (AGP 8.12.1), `android/app/build.gradle.kts` (core-library desugaring 2.1.4), `ios/Podfile.lock` | done; the manifest, the icon and `AppDelegate.swift` are the reminder lane's (P3.10) |
| Docs | this section, PROGRESS D144–D155 and Q137–Q148 and the package reasons, BACKLOG, CLAUDE.md's facts, the TODO index | done |

DI: `NotificationService` is `LocalNotificationService` (real) and
`FakeNotificationService` (fake), both lazy singletons; `DailyReminder` is
a lazy singleton in both environments (it composes interfaces, like
`SaveLifecycleFlusher`); `ReminderOfferCubit` is an `@injectable` factory.
`ShareService` has no binding until the share lane adds its two.

### P3.2 Lanes and codegen

1. **Contracts** (done): P3.1, the packages and the Android build change
   with a dev APK and an iOS dev build as the smoke check (both built, so
   share_plus stays; the native-channel fallback isn't needed, D154).
2. **Five lanes in parallel** on exclusive paths (P3.13): `stars-core`,
   `stars-app`, `stars-ui`, `reminder`, `share`.
3. **Integrator**: every cross-lane edit, DI and codegen's final pass, the
   E1 tests of P3.12, `di_test`, `app_flow_test`, the playthrough's star,
   share and offer steps, the optional Android reminder check, the docs.

Codegen only through the lock, as in phase 1 (§2): `LANE=<lane> bash
…/scratchpad/m7/bin/codegen.sh l10n|build|all`. `lib/l10n/app_en.arb` is
complete for phase 3: a lane that needs another key lists it in its report,
and the integrator adds it.

### P3.3 The star rule, par and the slack keys

**The rule** (spec-prop §7.10; rule 2: it lives in core):

```dart
abstract final class StarRating {
  static const int maxStars = 3, minStars = 1, assistedMaxStars = 2;
  static const int maxSlackPct = 1000;              // a technical bound, not a rule
  static int threshold(int par, int slackPct);       // par + (par × slackPct + 99) ~/ 100
  static int starsFor({required int moves, required int par, required bool assisted,
      required int star3SlackPct, required int star2SlackPct});
  static int starsForWin(GameState state, {required int par, required bool hintUsed,
      required int star3SlackPct, required int star2SlackPct});
}
```

- `threshold` is `par + ⌈par × slack ÷ 100⌉` in integers (par 12: 15 at
  20 %, 20 at 60 %); a `RangeError` for par < 1 or a slack outside
  0..1000. `starsFor`: 3 at moves ≤ t3, else 2 at moves ≤ t2, else 1;
  then at most 2 when assisted. Literal: a star2 slack below star3 only
  makes 2★ unreachable. A `RangeError` for negative moves.
- `starsForWin` reads `moveCount` and `extraSlotCount > 0` from the board
  (so no caller can forget the extra-slot cap, Q116) and takes the hint
  flag, which only the app knows; an `ArgumentError` on a board not won.
- Pure integers, so the VM, dart2js and wasm agree (the stars-core lane
  adds the parity digest). `public_api_test` pins the four constants.

**Par in the bundle** (star-rating.md "Rules" 1):

- `LevelBundleEntry.par` (`int?`): the fewest moves that solve the level
  from its start, the solver's optimum at the admin budget; null means no
  stars for that entry (content without a proven par, M4). The encoder
  writes it after `rewardCoins` only when present, so a par-less bundle
  encodes byte for byte as before (today's `bundle.json` and
  `bundle check` are unchanged by this stage). The decoder reads it
  leniently: absent → null; an integral number ≥ 1 by value (`2.0` is 2)
  → the par; anything else → one `schema.wrongType` or
  `schema.valueOutOfRange` **warning** at `/levels/<i>/par`, par null,
  the entry kept (a bad par never makes a level unplayable). No new
  `IssueCodes` entry.
- The levels tools (stars-core): `bundle build` runs `analyzeLevel(level,
  simulate: false)` (rule 8 at `SolverBudgets.admin`) and writes
  `pars[id] = solverMoves` (A* with the consistent heuristic, so
  optimal); an unsolved level is `build.parUnproven` and nothing is
  written. `bundle check` takes the pars from the rule-8 solve its loop
  already runs and reports a committed par that is missing or differs as
  `bundle.parMismatch` ("committed 14, the solver's 13"). `report --stars
  [--star3-slack 20] [--star2-slack 60] [--runs 300]` prints, per chapter
  and bot, the share of won runs at 3★/2★/1★ (a report, never a gate),
  from `RivalBot` runs (public core API, no simulator change, no
  `Generator.version` bump). Then `bundle.json` is rebuilt: only `par`
  keys appear; no level's `data` or `version` moves (L1–L30 stay
  byte-identical).

**The slack keys** (spec-prop §9.4, rule 6): `star3_slack_pct` 20 and
`star2_slack_pct` 60, both in `RemoteConfigKeys.all`; readers clamp them
through `StarRules.slackOf` (P3.5).

### P3.4 The save: schema-2 additions and the backfill

Schema 2 hasn't shipped (it exists only in the uncommitted M7 tree, and
no build was released), so the new fields join schema 2 with lenient
reads, and there is no schema 3 (plan-m7: players migrate once). A
phase-1 schema-2 document on the owner's simulator reads them as their
defaults, and the backfill fills `levelStars`.

| Type | Member | JSON |
|---|---|---|
| `SaveDocument` | `Map<String, int> levelStars` (level id → best stars 1–3; per id, so a new version keeps them, Q117) | `"levelStars": {"L0024": 3}`, right after `levelBests` |
| `SaveDocument` | `bool starTipShown` (Q119) | `"starTipShown": false`, after `levelStars` |
| `DailyProgress` | `DailySolve? lastSolve` | `"lastSolve": {"date": "2026-09-28", "moves": 18, "families": 5, "minute": 1150}` or null, after `chestPending` |
| `DailySolve` (new) | `LocalDate date`, `int moves`, `int families`, `int? minuteOfDay` | as above |
| `InProgressLevel` | `bool hinted` (Q116 across a kill) | `"hinted": false`, after `session` |
| `LevelWinRecord` | `String? starsKey`, `int? stars` (this win's, 1–3), `int? minuteOfDay` (0–1439) | not stored |
| `LevelWinOutcome` | `int? stars` (best after), `int? previousStars` (best before), `bool showStarTip` | not stored |

- **Codec:** `levelStars` keeps non-empty ids with an integral value 1–3;
  `starTipShown` a bool, else false; `lastSolve` null unless its date
  parses (moves and families ints ≥ 0, else 0; the minute 0–1439, else
  null); `hinted` a bool, else false.
- **Migration:** step 1 → 2 writes nothing new: the decoder's defaults
  are the values (empty, false, null, false). §3.3's table gains:
  `levelStars` empty (filled by the backfill), `starTipShown` false,
  `daily.lastSolve` null, `inProgress.hinted` false.
- **`recordLevelWin`**, in its one update, after best moves (§7 step 4):
  with a non-empty `starsKey`, `stars` 1–3 and a bundled request,
  `levelStars[key] = max(old, stars)`; the outcome carries the new best
  and the old; the first win ever below 3★ sets `starTipShown` and
  reports `showStarTip`. A daily that added a date `done` lacked keeps
  `daily.lastSolve = DailySolve(its date, moves, families, minute)`; any
  other daily win keeps the save's own `lastSolve` (only this path writes
  it, whatever the record's `daily` holds). The race's early return stays
  first; coins, chests, progress, records and badges never read stars
  (the contract test compares a win with and without stars).
- **`int backfillLevelStars(LevelRepository levels)`** (Q120), silent and
  idempotent, one update: every won campaign order (order <
  `highestLevel`) the bundle has at exactly that order, with a par and no
  `levelStars` entry for its id, gets `StarRules.backfill(par:, best: the
  best of its current version, slack:)` (1★ without a best). It never
  lowers or replaces an entry, never sets the tip, never throws (a failure
  is logged under `nesty.save` and gives 0). The splash calls it once the
  save and the bundle are loaded (stars-app, P3.6). Cost: at most 200
  lookups and one Hive write on the first launch after the update.

### P3.5 The stars glue

```dart
typedef StarSlack = ({int star3, int star2});
abstract final class StarRules {                       // core/services/records/star_rules.dart
  static StarSlack slackOf(RemoteConfigService config); // each clamped to 0..StarRating.maxSlackPct
  static String? keyOf(PlayEntry play);                  // the level id for a bundled board, else null
  static int? targetFor(PlayEntry play, StarSlack s);    // StarRating.threshold(par, s.star3); null without a par
  static int backfill({required int par, required int? best, required StarSlack slack}); // null best → 1
  static int levelsWithPar(LevelRepository levels);      // bundled levels with a par, each at its own order
}
```

- **`PlayEntry.par`** is `request.isBundled ? bundleEntry?.par : null`:
  null for the daily, Bonus Endless and a race, so they compute no stars.
  No resolver change.
- **`RecordsSummary`** gains `stars` (the sum of `levelStars`),
  `starsPossible` (`StarRating.maxStars × starLevels`: 600 at launch) and
  `threeStarLevels`. `RecordsSummary.of(doc, levelCount:, starLevels:)`
  takes the par count (`StarRules.levelsWithPar`), which `RecordsCubit`
  passes, so a level without a par never counts toward the total.
- **Chapters:** `ChapterLevel.stars` (a won cell's `levelStars[id]`, else
  null), `ChapterSection.stars` (the sum over its cells) and
  `ChapterSection.starsPossible` (3 × the chapter's orders the bundle has
  with a par: 60 for a full chapter).

### P3.6 The bloc's assisted flag and the win's stars

State (frozen): `int? stars` (this win's; null for daily, bonus, race or
an entry without a par), `int? previousStars` (the outcome's), `int?
starTarget` (t3, only on a replay below 3★ whose moves were over it,
Q118), `bool starTip` (the outcome's `showStarTip`, Q119), and `bool get
starsNewBest => isReplay && stars != null && previousStars != null &&
stars > previousStars`.

The stars-app lane builds the bloc to this:
- **`bool _hintSinceRestart`** (Q116): set in `_hintArrived` when a
  charged hint move shows (a proven dead end gives no move, costs nothing
  and doesn't count), which also calls `_persistProgress`, so a kill right
  after keeps it; cleared by `_restart` and by `_begin` for a fresh
  session; a restored session takes `saved.hinted`; `_persistProgress`
  writes `hinted`. A race has no hints, so it stays false there.
- **`_win`**, after phase 2's race branch (which returns before
  `recordLevelWin`): `slack = StarRules.slackOf(remoteConfig)`; `stars =
  play.par == null ? null : StarRating.starsForWin(session.state, par:,
  hintUsed: _hintSinceRestart, …slack)`; the record gets `starsKey:
  stars == null ? null : StarRules.keyOf(play)`, `stars`, and `minuteOfDay:
  now.hour * 60 + now.minute` from `AppClock` on every win (the save keeps
  it only for a daily). State: `stars`, `previousStars`, `starTarget:
  isReplay && stars < 3 && moves > t3 ? t3 : null`, `starTip`. Undo,
  Restart's move reset and relaxed mode reach the rule only through
  `moveCount`, so they never lower stars. `level_win`'s parameters stay.
- **The splash:** after `Future.wait([_save.load(), _levels.load()])`,
  `_save.backfillLevelStars(_levels)` before the ready state; nothing on a
  failed load. No constructor change.

### P3.7 StarRow and the stand-in star UI

Built from `design/tokens.json` and the UI kit, since design request K
(frames 11.1–11.5, the star art, `ui_stars`, `star_1..3`) hasn't landed.
§15's shared rule holds. Every item carries `TODO(design)`.

```dart
class StarRow extends StatefulWidget {   // core/ui/widgets/stars/star_row.dart, exported by nesty_ui.dart
  const StarRow({required this.count, this.size = sizeCard, super.key});   // at rest
  const StarRow.reveal({required this.count, this.size = sizeWin, this.delay = Duration.zero,
      this.onStar, super.key});                                             // the win card
  static const double sizeWin = 44, sizeCard = 20, sizeCell = 11;           // K.1's sizes
  static const double gapRatio = 0.18;
  final int count; final double size; final Duration delay; final bool reveal;
  final void Function(int star)? onStar;                                    // star i (1-based) lands
}
```

- **The one swap point** for K.1 (art), K.3 (motion, sound) and K.6
  (tokens): no caller changes when they land. One semantics node,
  `starsSemantics(count)`.
- **The stand-in look** (lead note: the architecture's painted star over
  the ui-spec's `NestyIcons.star`, whose subset has no outline for an
  empty star): a painted rounded five-point star; filled is
  `AppColorTokens.coin` with a `coinDark` edge; empty keeps the ui-spec's
  `surfaceTrack` face and adds a soft `surfaceEdge` outline, the card's
  own warm colours, never grey or red. Two shared painters and a path
  cache per size, so nothing allocates per frame.
- **The win card** (`win_overlay.dart`, `win_chapter_card.dart`, the
  view's mapping; stars-ui owns the whole overlay, the daily variant
  included): `WinSummary` gains `int? stars`, `bool starsNewBest`, `int?
  starTarget`, `bool starTip`. The `StarRow.reveal` sits directly above
  the chapter card, centred in the overlay's column (the moves line is the
  card's first row, so the stars read above it; the overlay's column is
  anchored at the ribbon, so the row pushes only the card and Continue
  down, and stars-ui's overflow test checks that the ribbon keeps its
  place and scale at 390×844). "New best!" (a
  `SheetRowTag`-style pill), the target line and the one-time tip go in
  the card under the moves caption. No stars on the daily, bonus or race
  cards, and none during play.
- **The reveal's times** (lead note: taken from the existing
  `WinOverlaySchedule`): `win` plays at the open (2 s; its loud part is
  the first 600 ms, −45 dB by 1.3 s) and `coins` at `winCoinsMs` 700 (its
  loud part to 1,100 ms; the count-up ends at 700 + `winCountUpMs` 600 =
  1,300). So `starsStartMs` = `FxTiming.winCoinsMs +
  WinOverlaySchedule.winCountUpMs` = **1,300 ms at 1×**, stars 120 ms
  apart (1,300, 1,420, 1,540): after both sounds' loud parts and the
  count-up, never over the coin burst. The ui-spec's 300 ms sat in `win`'s
  loudest part, the architecture's 1,000 ms in the coin burst.
- **The cues** (`WinOverlaySchedule.starCues(stars)`): `SoundEffect.clack`
  at `dollSize` 3, 2, 1 (+1, +3, +5 semitones: rising; the ui-spec's
  `SoundEffect.nest` doesn't exist) with `HapticPattern.button` per star;
  the 3★ flourish is one `fx_twinkle` burst around the row with
  `HapticPattern.complete` and no sound (the ui-spec's; the architecture
  names no haptic). `TODO(design)` K.3: `star_1..3` and `ui_stars` swap in
  here.
- **Reduce motion** (lead note 7 of the ui-spec over the architecture's
  "one cue", because D48 is the owner's rule: cue offsets and staggers run
  at half duration): every star shows at once, with no pop and no twinkle;
  the three cues still fire, from 650 ms, 60 ms apart (`motion.ms`), and
  the flourish's haptic too. Q146 asks K.3.
- **Chapters** (stars-ui): 11 dp stars under each won cell (none on
  current or locked cells; a won cell without stars shows none), and
  `chaptersStarsTotal` (`StarRow` 20 + text) on the card and the folded
  row, always shown, even at 0. The cell's semantics appends
  `starsSemantics`. The cell may grow to about 78 dp if 1.3× at 360 dp
  needs it (the ui-spec's note), else `FittedBox(scaleDown)`.
- **Records** (stars-ui): "Stars" (`recordsStars`, value
  `chaptersStarsTotal(stars, starsPossible)`) and "Levels with 3 stars"
  (`recordsThreeStarLevels`, value `threeStarLevels`) as `RecordStatRow`s
  after the longest streak, with `NestyIcons.star`; the best-moves link
  gives up the star glyph for `NestyIcons.extension` (both are in the
  subset).

### P3.8 The daily's solve

`DailyStatus.solve` (`DailySolve?`) is today's solve:
`StreakDailyService._publish` sets `daily.lastSolve?.date == today ?
daily.lastSolve : null`. A day an older build solved has no solve, so it
shows no Share. The share lane owns `core/services/daily/**` from here.

### P3.9 The share card (E3)

```dart
enum ShareOutcome { shared, dismissed, unavailable }
abstract interface class ShareService {          // core/services/share/share_service.dart (frozen)
  Future<ShareOutcome> shareText(String text, {Rect? origin});   // never throws
}
// share lane: share_plus_share_service.dart, @LazySingleton(as: ShareService, env: [AppEnv.real]):
//   SharePlus.instance.share(ShareParams(text:, sharePositionOrigin: origin)), the status mapped,
//   errors logged under 'nesty.share' → unavailable.
// share lane: fake_share_service.dart, @LazySingleton(as: ShareService, env: [AppEnv.fake]):
//   final List<String> shared; ShareOutcome next = ShareOutcome.shared.
```

- **Where:** the Daily screen's solved card (frame 5.5,
  `PuzzleCard._SolvedFooter`), not the daily win card (5.4): spec-prop
  §10.2 #11 is the Daily screen, BACKLOG E3 says "the Daily's done card".
  A compact `IconTactileButton` beside "Play Level N" (the ui-spec's
  layout), with `dailyShareSemantics`. The glyph: no share glyph is in the
  subset (I.10), so a stand-in the lane picks from the subset, with
  `TODO(design)`.
- **The text** (spoiler-free; lead note: one 🪆 per family, so no colour
  map; the ui-spec's lead note 3 is superseded): `features/daily/share/
  daily_share_text.dart`: `typedef DailyShareData = ({LocalDate date, int
  families, int moves, int streak})`; `DailyShareData? shareDataOf(
  DailyStatus s)` (null unless `solvedToday` and `solve != null`);
  `DailyShareText.of(l10n, localeName:, data:)` formats the date with
  `DateFormat.yMMMd(localeName)`, repeats `dailyShareFamilyGlyph`
  min(families, `maxGlyphs` 12) times as `{dolls}` and fills
  `dailyShareText`. Never the board, the colours, slot ids or a move
  list. The streak is the count the streak card shows, paused or not
  (Q144). The store link lands in M8.
- **Wiring** (share lane): `DailyCubit(daily, resolver, save,
  remoteConfig, ShareService share)` adds `Future<ShareOutcome>
  share(String text, {Rect? origin})`; `PuzzleCard` gains `void
  Function(Rect? origin)? onShare` (the button shows only when non-null);
  `DailyView` builds the text from l10n and `shareDataOf(state.status)`.
  The outcome shows nothing. No analytics event (spec §14.4 has none).
  Sharing pays nothing.

### P3.10 The reminder (E4)

**Settings keys** (`settings_schema.dart`; flat, never renamed or reused,
not save fields, so no schema step; §4's table gains them):

| Key | Type, range | Default | Meaning |
|---|---|---|---|
| `reminderOn` | bool | false | the player opted in (spec-prop §7.9 "off until the player accepts") |
| `reminderHour` | int 0–23 | 19 | the time (plan decision 15; the first solve's hour once the offer appears, Q81) |
| `reminderMinute` | int 0–59 | 0 | |
| `reminderOffered` | bool | false | the one-time offer has appeared; Yes sets `reminderOn`, No thanks changes nothing else |

`ReminderSettings` (`core/models/reminder_settings.dart`, freezed: `on`,
`hour`, `minute`, `offered`; `defaultHour` 19, `defaultMinute` 0,
`isValidTime`). `DatabaseService.reminder` (a wrong type or an hour or
minute out of range reads as its default, per field),
`setReminder(ReminderSettings)` (Hive: one `putAll` of the four keys) and
`reminderChanges` (after any of the four changes; only a value that
differs from the last one is emitted, so one `setReminder` emits once and
an unchanged write is quiet), in Hive and the fake, with the shared
contract test.

**`NotificationService`** (frozen; the fake implemented; the real one is
the reminder lane's):

```dart
enum NotificationPermission { granted, denied, unknown }
@freezed abstract class ReminderPlan { int hour, minute; String title, body, channelName, channelDescription; }
abstract interface class NotificationService {   // core/services/notifications/notification_service.dart
  Future<void> initialize();                           // idempotent; never prompts, never throws
  Future<NotificationPermission> permission();         // no prompt
  Future<NotificationPermission> requestPermission();  // the OS prompt when undecided; only after the player's Yes
  Future<bool> scheduleDaily(ReminderPlan plan);       // the one repeating reminder, replaced; false on failure
  Future<void> cancelDaily();
  Future<bool> hasPendingDaily();
}
const int reminderId = 1;                              // a platform contract: never reuse it
```

- **`FakeNotificationService`** (fake env): `permissionAnswer` (granted),
  `scheduleSucceeds`, and the records `initializeCount`, `requestCount`,
  `scheduled`, `scheduleCalls`, `cancelCalls`.
- **`LocalNotificationService`** (real env; its constructor touches no
  plugin, so `di_test`'s real env resolves it): frozen as a safe stub
  (never prompts, schedules nothing, reads unknown), so the real app
  behaves as if the reminder were off until the lane fills it. The lane
  builds: `initialize` (memoized) loads `package:timezone/data/
  latest_10y.dart`, sets `tz.local` from
  `FlutterTimezone.getLocalTimezone().identifier` (an unknown id falls
  back to a fixed location at the device's current offset, re-synced on
  resume, and named after the device's own id, or `GMT±HH:MM` without one,
  so the platform can resolve it: review R9, D166), and calls `plugin.initialize` with
  `AndroidInitializationSettings('ic_notification')` and
  `DarwinInitializationSettings(requestAlertPermission: false,
  requestBadgePermission: false, requestSoundPermission: false)`.
  Permission: Android `areNotificationsEnabled()` /
  `requestNotificationsPermission()`; iOS `checkPermissions()?.isEnabled` /
  `requestPermissions(alert: true, badge: false, sound: true)`; null reads
  unknown. `scheduleDaily` re-reads the zone, takes the next future
  `hour:minute` in `tz.local` (skipping a day on which that wall-clock time
  doesn't exist, a spring-forward gap: review R34), skips a call identical
  to this process's last (plan, zone; the zone keyed on its name and
  current offset, review R9), then `zonedSchedule(id: reminderId, scheduledDate:,
  notificationDetails:, androidScheduleMode:
  AndroidScheduleMode.inexactAllowWhileIdle, title:, body:,
  matchDateTimeComponents: DateTimeComponents.time)` (22.3.1's named
  signature, checked in the pub cache). It is the one place outside
  `AppClock` that reads the device clock (`tz.TZDateTime.now`), because
  the OS schedule runs in real time; a `NESTY_FAKE_DATE` plan simply rolls
  forward. Errors are logged under `nesty.notifications`.
- **The details** (pure builders in `reminder_notification_details.dart`,
  unit-tested without the plugin): Android channel `daily_reminder`,
  `Importance.defaultImportance`, `Priority.defaultPriority` (no
  heads-up), `channelShowBadge: false`, `icon: 'ic_notification'`,
  `color: AppColorTokens.primary` (`TODO(design)` I.2); iOS
  `DarwinNotificationDetails(presentAlert: false, presentBanner: false,
  presentList: false, presentSound: false, presentBadge: false, sound:
  '')`: nothing shows while the app is open; in the background the OS
  shows the alert and the sound (`sound: ''` is the OS default; without it
  FLN attaches none: review R10, D166). A tap opens the app normally (no payload, Q141).

**`DailyReminder`** (`core/services/reminder/`, a lazy singleton in both
envs, no interface: it composes `NotificationService`, `DatabaseService`
and `DailyService`):

```dart
enum ReminderEnableResult { enabled, denied }
@freezed abstract class ReminderStatus { ReminderSettings settings; NotificationPermission permission;
  bool available;                                  // the daily is unlocked (DailyService.isUnlocked)
  bool get blocked => settings.on && permission == NotificationPermission.denied; }
class DailyReminder {
  DailyReminder(NotificationService notifications, DatabaseService settings, DailyService daily);
  ReminderStatus get status; Stream<ReminderStatus> get changes;
  void start();                      // bootstrap, after SaveLifecycleFlusher: listens, then one unawaited refresh
  Future<ReminderStatus> refresh();  // re-reads the permission and the lock; schedules when on, cancels when off
  Future<ReminderEnableResult> enable({required int hour, required int minute});
  Future<void> disable();
  Future<void> setTime({required int hour, required int minute});
  @visibleForTesting ReminderPlan planFor(ReminderSettings settings);  // implemented
  @disposeMethod Future<void> dispose();
}
```

- **Scheduling:** one notification a day at the chosen local time, one
  repeating inexact trigger, so no `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM`
  (Doze may batch it by minutes). It fires every day while on, a day
  already solved included (plan decision 15; Q137). `refresh` runs
  serially (one in flight, one more queued) on `start`, on
  `AppLifecycleState.resumed` (an `AppLifecycleListener`, guarded like
  `SaveLifecycleFlusher`'s), on `reminderChanges`, on `languageStream` (the
  copy follows the language: a supported locale from `languageCode`, else
  English) and after `enable`/`disable`/`setTime`. On → `scheduleDaily(
  planFor(settings))`; off → `cancelDaily()` (which also clears a stray
  schedule after a crash). The settings are the truth: availability only
  gates the UI, so a refresh before the save loads never cancels an on
  reminder.
- **Boot, app update, time zone:** Android's
  `ScheduledNotificationBootReceiver` re-registers on `BOOT_COMPLETED`,
  `MY_PACKAGE_REPLACED` and `QUICKBOOT_POWERON`; iOS keeps pending
  requests. A time zone change is picked up at the next launch or resume;
  until then the reminder keeps the old zone's time (a known limit).
- **`enable`:** `initialize` → `requestPermission()`. Granted →
  `setReminder(on: true, hour, minute, offered: true)` → refresh →
  `enabled` (a scheduling failure is logged and retried at the next
  refresh, silently). Denied or unknown → nothing scheduled, `on` stays
  false, the time is kept → `denied`. **`disable`** → `on: false` →
  cancel. **`setTime`** → stores it → reschedules when on.
- **The permission, denied** (the architecture's version, lead note): the
  offer shows its denied step; Settings' toggle stays off and a
  `NestyToast` (info) says `settingReminderBlocked`; a later On asks again
  (Android may prompt again; iOS answers from its stored choice). Revoked
  later while on: the row stays on with `settingReminderBlocked` as its
  subtitle (`status.blocked`), and the schedule stays, so turning
  notifications back on in the OS resumes it. No button opens the OS
  settings in phase 3 (Q140; ui-spec lead note 4 agrees): `LinkLauncher`
  can't open an app's notification settings on both platforms without a
  new package or channel.

**The one-time offer** (`features/daily/cubit/reminder_offer_cubit.dart`
+ `reminder_offer_state.dart`, `features/daily/widgets/
reminder_offer_card.dart`; frozen hidden):

```dart
enum ReminderOfferStep { hidden, ask, asking, enabled, denied }
@freezed abstract class ReminderOfferState { ReminderOfferStep step; int hour; int minute; }
@injectable class ReminderOfferCubit extends BaseAsyncCubit<ReminderOfferState> {
  ReminderOfferCubit(DailyReminder reminder, DatabaseService settings, DailyService daily, AppClock clock);
  Future<void> load(); void setTime({required int hour, required int minute});
  Future<void> accept(); Future<void> decline(); void dismiss(); }
class ReminderOfferCard extends StatelessWidget { const ReminderOfferCard({super.key});
  static Widget provided(); }       // a BlocProvider over get<ReminderOfferCubit>()..load()
```

- **Trigger:** `load` shows `ask` when the daily is unlocked,
  `DailyStatus.solvedToday`, and neither `reminder.offered` nor
  `reminder.on`. For a new player that is the Daily screen they come back
  to after their first solve; a player who solved dailies on an older
  build sees it on their next solved day. At that first appearance it
  writes `offered: true, hour: the solve's hour, minute: 0` in one
  `setReminder` ("offered once", Q138; Q81's default becomes the Settings
  default too). The solve's hour is `status.solve.minuteOfDay ~/ 60`,
  else `clock.now().hour`.
- **Steps:** ask (the time chip `reminderOfferTime`, `reminderOfferChangeTime`
  opens `showTimePicker`, `reminderOfferYes`, `reminderOfferNo`) → Yes:
  `asking` (buttons disabled) → `reminder.enable` → `enabled`
  (`reminderOfferDone`) or `denied` (`reminderOfferDenied`), each with the
  kit's close button → hidden. No thanks → hidden. Leaving and coming back
  the same day shows nothing. A 200 ms `AnimatedSwitcher`, instant under
  reduce motion. The card is a `NestySurface` in `SettingsSection`'s look
  (the ui-spec §7), `TODO(design)` I.2, and carries its own 16 dp top gap.
- **Placement** (done): `DailyView({this.reminderOffer})` shows it under
  the puzzle card only while `solvedToday`; `DailyPage.build` passes
  `ReminderOfferCard.provided()`. `daily_page_test` and
  `daily_overflow_test` pump `DailyView()` (no offer), so they never need
  the offer's DI-built cubit.

**Settings rows** (the reminder lane; `TODO(design)` I.2): shown only
while `status.available` (Q139); `SettingsToggleRow(icon:
NestyIcons.calendarToday, label: settingReminder, subtitle: blocked ?
settingReminderBlocked : null)`; when on, a `SettingsRow(label:
settingReminderTime, value: MaterialLocalizations.formatTimeOfDay(…))`
opening `showTimePicker`. `SettingsCubit(database, appInfo, save,
DailyReminder reminder)`; `SettingsState.reminder` (`ReminderStatus`);
`setReminderOn(bool) → Future<bool>` (false on denied, for the toast),
`setReminderTime(hour, minute)`; `load` awaits `reminder.refresh()`; it
follows `reminder.changes`.

**Platform changes:**

| File | Change | Who |
|---|---|---|
| `android/settings.gradle.kts` | AGP 8.11.1 → 8.12.1 (share_plus 13's floor; Gradle 8.14 meets its 8.13 minimum) | contracts (done) |
| `android/app/build.gradle.kts` | `isCoreLibraryDesugaringEnabled = true`; `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`; `compileSdk` stays `flutter.compileSdkVersion` (36, FLN 22.3.1's own) | contracts (done) |
| `android/app/src/main/AndroidManifest.xml` | `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`; `ScheduledNotificationReceiver` (not exported) and `ScheduledNotificationBootReceiver` with `BOOT_COMPLETED`, `MY_PACKAGE_REPLACED`, `QUICKBOOT_POWERON`, `com.htc.intent.action.QUICKBOOT_POWERON`; no exact-alarm permission (a merged one is removed with `tools:node="remove"`) | reminder |
| `android/app/src/main/res/drawable/ic_notification.xml` (new) | a white-on-transparent 24 dp vector traced from existing doll art (not a square; ui-spec lead note 5), `TODO(design)` until I.2's `ic_notification.svg` is synced | reminder |
| `android/app/src/main/res/raw/keep.xml` (new) | `tools:keep="@drawable/ic_notification"` (Dart names it by string, so resource shrinking would drop it) | reminder |
| `ios/Runner/AppDelegate.swift` | `import UserNotifications`; `UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate` before `return super…` | reminder |
| `ios/Podfile.lock` | three new pods (`flutter_local_notifications`, `flutter_timezone`, `share_plus`) at the smoke build's `pod install`; no Info.plist key; deployment target 14.0 | contracts (done) |

### P3.11 The ARB keys added (all in `app_en.arb`)

Every description cites the spec line and ends "Placeholder until Claude
Design's copy.md lands (G.n)" (or I.n) naming the item that replaces it;
the key names stay. `arb_keys_m7_test` pins them.

| Key | English | Where |
|---|---|---|
| `starsSemantics(count)` | 1 of 3 stars · {count} of 3 stars | every `StarRow` (G.11) |
| `winStarsTarget(moves)` | 3 stars at 1 move · 3 stars at {moves} moves or fewer | a replay's card below 3★ (G.11) |
| `winStarsNewBest` | New best! | a replay that raised the stars (G.11) |
| `starsFirstTip` | Fewer moves earn more stars. Replay any level from Chapters. | the first win below 3★, once (G.11) |
| `chaptersStarsTotal(earned, total)` | {earned}/{total} | the chapter card, the folded row, Records' value (G.11) |
| `chaptersStarsSemantics(earned, total)` | 1 of {total} stars · {earned} of {total} stars | semantics (G.11) |
| `recordsStars` | Stars | Records row (G.11) |
| `recordsThreeStarLevels` | Levels with 3 stars | Records row (G.11) |
| `dailyShare` | Share | the solved card's button (I.1) |
| `dailyShareSemantics` | Share today's result | its semantics (I.1) |
| `dailyShareText(date, dolls, families, moves, streak)` | Nesty Daily · {date}⏎{dolls}⏎{N family/families} in {N move/moves} · {N-day streak} | the shared text (G.6) |
| `dailyShareFamilyGlyph` | 🪆 | one per family in `{dolls}` (G.6) |
| `reminderOfferTitle` | Want a note when tomorrow's puzzle is ready? | the offer (G.7) |
| `reminderOfferTime(time)` | Every day at {time} | the offer's time chip (G.7) |
| `reminderOfferChangeTime` | Change time | the offer (G.7) |
| `reminderOfferYes` | Yes, remind me | the offer (G.7) |
| `reminderOfferNo` | No thanks | the offer (G.7) |
| `reminderOfferDone(time)` | All set. One note a day at {time}. | the offer, enabled (G.7) |
| `reminderOfferDenied` | Notifications are off for Nesty in your phone's settings. Turn them on there, then switch on Daily reminder in Settings. | the offer, denied (G.7) |
| `reminderNotificationTitle` | Today's puzzle is ready | the notification, spec-prop §7.9's words (G.7) |
| `reminderNotificationBody` | A new daily puzzle is on the shelf. | the notification (G.7) |
| `reminderChannelName` | Daily reminder | Android's app settings (G.7) |
| `reminderChannelDescription` | One note a day when the daily puzzle is ready | Android's app settings (G.7) |
| `settingReminder` | Daily reminder | Settings toggle (G.7) |
| `settingReminderTime` | Reminder time | Settings row (G.7) |
| `settingReminderBlocked` | Notifications are off for Nesty in your phone's settings | Settings subtitle and toast (G.7) |

The ui-spec's names (`dailyShareButton`, `settingDailyReminder*`,
`notificationTitle`/`Body`, `reminderOfferBody`, `reminderOfferTimeLabel`,
`reminderOpenSettings`) became the architecture's; the offer has no body
line (the title and the time chip say it) and no "Open Settings" (Q140).
Reused, no new key: `closeSemantics`, `retry`, `levelDaily`.

### P3.12 E1, the phase-3 tests

| Test | What it pins | Written by |
|---|---|---|
| `test/ethics/respect_copy_test.dart` | the prefixes `reminder`, `settingReminder`, `dailyShare`, `stars`, `winStars`, `chaptersStars`, `recordsStars`, `recordsThreeStar` against the deny-list; six of the families pinned; a star-shaming list ("fail", "try again", "poor", "not enough" …) over the star keys; no `reminder*`/`settingReminder*` value names the streak | contracts (done) |
| `test/ethics/reward_randomness_test.dart` | `lib/core/ui/widgets/stars` joins the scanned paths | contracts (done) |
| `test/core/ui/arb_keys_m7_test.dart` | the 26 keys, the G./I. suffix, the share text's five placeholders | contracts (done) |
| `test/ethics/stars_gate_nothing_test.dart` (new) | no reward, unlock or gate path names `levelStars`, `StarRating`, `StarRules` or `starsFor`, and every path it scans exists: `lib/core/services/{chest,daily,race}`, `lib/core/repository`, `lib/core/router`, `lib/features/{home,race,shop,museum}`, `badge_rules.dart`, `win_reward.dart` | integrator |
| `test/ethics/reminder_opt_in_test.dart` (new) | on a fresh install the reminder is off and nothing is scheduled or requested; the permission is asked only after Yes; only ever one pending id; no badge; the notification text is the same whatever the streak (a paused one included) | integrator |

### P3.13 Lane ownership and test plans

A lane touches only its paths; everything else goes in its report for the
integrator. Generated files come only from the lock script. Every lane
writes its report (with the six ethics answers) and keeps a checkpoint in
`scratchpad/m7/checkpoints/`.

| Lane (agent) | Owns (exclusive) | Builds | Tests (in its paths) |
|---|---|---|---|
| **stars-core** (nesty-core-engineer) | `packages/nesty_core/**`; `tools/**`; `apps/game/assets/levels/bundle.json`; `apps/game/test/core/repository/bundled_level_repository_test.dart` | P3.3's tools: `bundle build` and `check` with par, `report --stars`, the READMEs; the bundle rebuild; the full core tests and parity | `star_rating_test`: par 1, 8, 12, 20, 30, 60 at 20/60, 0 % and 100 %; moves at t3, t3 + 1, t2, t2 + 1; the cap; `starsForWin`; the RangeErrors; a star2 below star3. The codec: the round trip, absent (byte-identical), `0`/`-1`/`"x"`/`2.5` a warning with the entry kept, `2.0` reads 2, the key order. `test/parity/star_rating_parity_test.dart` (a digest over par 1–60 × slack {0, 20, 60, 100, 1000} × moves 0–120 × assisted) and codec vectors with `par`, on node, chrome and dart2wasm. Par equals the BFS oracle's shortest line on the solvable fixtures. Tools: build writes the solver's length; `build.parUnproven` writes nothing; check fails with `bundle.parMismatch` on an edited or missing par; `repo_levels_test`: all 200 have a par ≥ 1, a digest of L1–L30's `data` taken before the rebuild, each tutorial's scripted prefix on an optimal line (L1, L2; Q148); a `report --stars` output test; `bundle check` green. App: `entryAt(1).par == 2` |
| **stars-app** (bloc-architect with services-engineer) | `lib/core/services/{save,records,remote_config}/**`; `lib/core/repository/{fixture_levels,fake_level_repository}.dart`; `lib/features/gameplay/bloc/**`; `lib/features/splash/**`; their tests | P3.6's bloc and the splash's backfill call; the fixture pars (the solver's) | best stars keep the highest across wins, replays and a new version; daily, bonus and race write no `levelStars`; out-of-range stars ignored; `stars`/`previousStars`; `showStarTip` once, never on 3★; the backfill (from the best, 1★ without, par-less and skipped orders skipped, idempotent, never lowers, silent); `lastSolve` on a daily's first solve only; the four fields in the Hive round trip and codec leniency; the schema-1 fixture migrates with them empty, then backfills; `StarRules` clamps; `RecordsSummary` totals. Bloc (`blocTest`): 3★, 2★, 1★ at the boundaries; a hint caps; a hint, Restart, then a win doesn't; +1 Slot caps, after Restart too; a hint, kill and restore still caps; relaxed undo never caps; a replay raises (`starsNewBest`); `starTarget` only on a replay below 3★ over t3; daily, bonus and race give `stars == null` and no tip; stars change no coins, chest or `nextRequest`. Splash: backfill before ready, none on a failed load; `splash_cubit_test`'s mocktail save stubs `backfillLevelStars` |
| **stars-ui** (flutter-frontend-dev) | `lib/core/ui/widgets/stars/**`; `lib/features/gameplay/{pages,overlays,widgets}/**` except `pages/gameplay_board.dart` and the race-only files; `lib/features/gameplay/game/timeline/win_overlay_schedule.dart`; `lib/features/{chapters,records}/**`; their tests; `test/overflow/{win_overlay,gameplay_view,chapters_records}_overflow_test.dart` | P3.7 in full: the reveal, the cues, the win card, Chapters, Records | `StarRow` counts 0–3, the sizes, semantics, the reveal's `onStar` timing, reduce motion (at once, cues at half the stagger), the flourish only at 3★; the win card at 1, 2 and 3★ (campaign and replay), "New best!", the target only on a replay, the tip once; a 1★ card keeps the ribbon, the coins and the confetti; no stars on daily or bonus, none in the HUD; the schedule's star cues; Chapters' cell stars and totals (card and folded), none on current or locked cells; Records rows and the link's new icon; overflow at the five sizes × 1.0 and 1.3 |
| **reminder** (flutter-frontend-dev, platform-minded) | `lib/core/services/{notifications,reminder,database}/**`; `lib/core/models/reminder_settings.dart`; `lib/features/settings/**`; `lib/core/ui/widgets/settings/**`; `lib/features/daily/cubit/reminder_offer_*.dart`; `lib/features/daily/widgets/reminder_offer_card.dart`; `android/app/src/main/{AndroidManifest.xml,res/**}`; `ios/Runner/AppDelegate.swift`; their tests; `test/overflow/{settings,reminder_offer}_overflow_test.dart` | P3.10: the real service and its details, `DailyReminder`, the offer, the Settings rows, the platform rows marked "reminder" | the pure builders (init never prompts; the channel, no badge, inexact, the time components, the icon; the next occurrence across DST dates in `America/New_York`; the zone fallback); the real service never throws (a throwing plugin double); `DailyReminder`: a fresh install neither schedules nor asks; off cancels; on schedules one plan with the current copy; a language change reschedules; enable granted and denied; disable; setTime; resume re-reads; concurrent triggers coalesce; `available` false before L2 is won. `SettingsCubit` and page: the row hidden until available, the toggle, a denied toast, the time row, blocked. `ReminderOfferCubit` and card: every step, `offered` written once, the hour from `solve.minuteOfDay` or the clock, never twice. The reminder's copy never names the streak. Overflow at the five sizes × 1.0 and 1.3 |
| **share** (flutter-frontend-dev) | `lib/core/services/{share,daily}/**`; `lib/features/daily/**` except the offer's three files; their tests; `test/overflow/daily_overflow_test.dart` | P3.8–P3.9: the two `ShareService` implementations, the text, the button, the cubit call | `SharePlusShareService` maps each status and swallows errors (a `SharePlatform` override); the exact English text of a sample; the glyph row capped at 12; no colour names, slot ids or move lists; plurals and the date per locale; `shareDataOf`; `DailyCubit.share` (coins unchanged); the Share button only on a solved card with a solve; `StreakDailyService` publishes `solve` for today only; daily overflow with Share and an offer-sized placeholder |
| **integrator** | every cross-lane edit; the final codegen pass; `integration_test/**`; `test/ethics/**`; `test/app_flow_test.dart`; `test/core/dependency_injection/di_test.dart`; later ARB additions; `tools/scripts/nesty-test`; CLAUDE.md, README, docs, the TODO index | P3.12's two new tests; the checks below | the gates below |

**Shared files:**

| File | Owner |
|---|---|
| `lib/l10n/app_en.arb` (+ generated) | contracts (26 keys, done); later keys through the integrator |
| `apps/game/pubspec.yaml`, root `pubspec.lock`, `ios/Podfile.lock`, `android/settings.gradle.kts`, `android/app/build.gradle.kts` | contracts only |
| `save_document.dart` (+ `.freezed.dart`), `save_document_codec.dart`, `save_migrations.dart` | contracts implemented; then stars-app; share and reminder read only |
| `gameplay_state.dart` | contracts froze the fields; then stars-app |
| `lib/core/ui/nesty_ui.dart` | contracts (the `StarRow` export); then the integrator |
| `lib/bootstrap.dart` | contracts (`get<DailyReminder>().start()`) |
| `daily_page.dart` (the `reminderOffer` slot) | contracts placed it; then share |
| `di.config.dart` and every generated file | only `LANE=<lane> codegen.sh` |
| `respect_copy_test.dart`, `reward_randomness_test.dart`, `arb_keys_m7_test.dart`, `remote_config_keys_test.dart` | contracts; then the integrator |

**Integration checks** (integrator): the `/milestone` baseline gate
(codegen `all` exit 0; format; `flutter analyze --fatal-infos
--fatal-warnings`; every suite, `claude_md_test` included; core web parity
with the star vectors; `bundle check` with 200 pars and `fixtures check`;
the four generators' `--check`; the TODO index; APK dev and prod
(`--release` too: FLN's consumer rules and `keep.xml`); iOS dev; admin
web) and the merged manifest has no `SCHEDULE_EXACT_ALARM`/
`USE_EXACT_ALARM`. `di_test`: `NotificationService` (Local/Fake),
`ShareService` (SharePlus/Fake), `DailyReminder` and `ReminderOfferCubit`
resolve in both envs. `app_flow_test` (fake env): after a daily solve the
offer shows; No thanks hides it; Settings shows the reminder row off.
**The playthrough:** L1's win shows `starsSemantics(3)` (the tutorial path
is par, 2 moves); Chapters shows L1 at 3★; the L1 replay won in 4 moves
(two legal placements into empty slots, checked with `Rules.tryMove`)
shows 2★, "3 stars at 3 moves or fewer" and no "New best!", and Chapters
keeps 3★; Records shows "Stars"; after the daily the solved card shows
Share (screenshot, never tapped: the OS sheet can't be dismissed from
`flutter drive`) and the offer (screenshot), then "No thanks" with
`reminder.offered && !reminder.on` and no permission request; Settings
shows "Daily reminder" off (screenshot); screenshots of the win card and
Chapters. The resume and daily-fingerprint checks are unchanged
(`hinted` rides in `inProgress`). No device check taps an OS dialog.
**Optional Android check:** `integration_test/reminder_test.dart`, run by
`nesty-test --android --only reminder` after `adb shell pm grant
com.futrix.nesty.dev android.permission.POST_NOTIFICATIONS`: the reminder
on in Settings (no dialog) → `hasPendingDaily()`; off → none. iOS skips it;
the owner checks a real reminder on a phone.

### P3.14 Decisions and questions

| D | Decision | Section |
|---|---|---|
| D144 | This phase-3 design and its frozen contracts; five lanes and the integrator; the codegen lock; phase 2's shapes unchanged | P3.1, P3.2, P3.13 |
| D145 | The star rule's API in core (`threshold`, `starsFor`, `starsForWin`, `assistedMaxStars`, the technical `maxSlackPct` 1000) and the two slack keys, clamped by `StarRules.slackOf` | P3.3, P3.5 |
| D146 | Par in the bundle: written only when present, read leniently (a warning, the entry kept); `bundle build` writes the solver's optimum, `bundle check` recomputes it; no level's data or version moves | P3.3 |
| D147 | Stars in schema 2, no schema 3: `levelStars` (per id, highest), `starTipShown`, `daily.lastSolve` (only the win path writes it), `inProgress.hinted`; the silent, idempotent load-time backfill; stars change no coins, chest, progress or badge | P3.4 |
| D148 | The assisted flag (a charged hint since the last Restart, kept across a kill; an extra slot read by core) and the win's stars, target and tip in the bloc's state | P3.6 |
| D149 | `StarRow` as the one swap point (the architecture's API, a painted star, the ui-spec's colours with a soft outline); the stars above the chapter card; the reveal at 1,300 ms, 120 ms apart, a rising clack and a light haptic each, the 3★ twinkle; reduce motion at once with the cues at half the stagger (D48); stars-ui owns the whole win overlay | P3.7 |
| D150 | The star totals count only bundled levels with a par (60 a chapter, 600 in Records); Records' best-moves link takes `NestyIcons.extension` | P3.5, P3.7 |
| D151 | The share card on the Daily screen's solved card (5.5): plain text through `ShareService`/share_plus, one 🪆 per family (at most 12), families, moves and the streak count, from `daily.lastSolve`; silent; no analytics | P3.8, P3.9 |
| D152 | The reminder's settings keys (`reminderOn`, `reminderHour`, `reminderMinute`, `reminderOffered`; off, 19:00, false) and `DatabaseService.reminder`/`setReminder`/`reminderChanges` | P3.10 |
| D153 | `NotificationService` (the real one a safe stub until its lane) and `DailyReminder`: one repeating inexact reminder (id 1), re-synced at launch, resume, a settings or language change; no badge; nothing shown while the app is open on iOS; the permission only after Yes; the offer marked offered at first appearance, at the solve's hour; hidden until its lane; the denied and blocked states | P3.10 |
| D154 | The four packages with their rule-9 reasons; AGP 8.12.1 and desugaring 2.1.4; the smoke builds passed, so share_plus stays (no native fallback) | P3.1, P3.10 |
| D155 | Phase 3's E1: the eight prefixes, the star-shaming list, the reminder never naming the streak, the stars widget in the randomness scan; the 26 ARB keys naming their copy.md item; the integrator's two new tests | P3.11, P3.12 |

**Departures from the architecture proposal**, each recorded:
- `RecordsSummary.of` takes a required `starLevels` (the par count), and
  `StarRules.levelsWithPar` counts it, because the lead note says the
  totals count only levels with a par (the proposal had `3 ×
  levelCount`).
- `LocalNotificationService` is a frozen safe stub, not left to the lane:
  `bootstrap` starts `DailyReminder` in the real env, which needs a real
  `NotificationService` binding from the first build.
- `DailyReminder.refresh` already reads the permission and the lock (no
  scheduling), and `planFor` is implemented, so the stub is truthful.
- `ReminderOfferCubit` takes its four dependencies as plain parameters in
  the stub (the lane keeps them as fields; the signature stays).
- `daily.lastSolve` is written only by the win path: a daily win that
  adds no date keeps the save's own (a record's `daily` from
  `progressAfterSolve` may not carry it).
- Hive's `reminderChanges` is quiet on an unchanged write (the fake is
  too), so the two agree; the proposal said `.distinct()`.
- `ReminderSettings.isValidTime`, `SettingsKeys.reminder` (the four keys)
  and the fake's `scheduleSucceeds`/`initializeCount` are additions.
- `daily_page_test` and `daily_overflow_test` (the share lane's) pump
  `DailyView()` instead of `DailyPage()`: once the offer card reads its
  cubit, the page would need DI in those tests.
- The reveal starts at 1,300 ms (P3.7's reasons), and reduce motion keeps
  three cues (D48), not one.
- `respect_copy_test` adds a star-shaming list and a reminder-no-streak
  test beyond the prefixes.

**Departures from the ui-spec** (lead notes applied): `StarRow`'s API is
the architecture's; the painted star replaces `NestyIcons.star`;
`starTipShown` replaces the `seenIntros` sentinel; the share text is one
🪆 per family (no colour map, so the teal/blue/navy collision is moot);
the offer is marked offered at first appearance; denied from Settings
leaves the toggle off with a toast; no "Open Settings"; the key names are
P3.11's; the notification icon is a traced doll silhouette, not a square.

| Q | Question | Default |
|---|---|---|
| Q137 | The reminder on a day already solved? | it still fires (plan decision 15, "a daily repeating" notification); skipping needs one-shot notifications re-planned at each launch, which stop if the app isn't opened |
| Q138 | "Offered once": does an unanswered offer count? | yes, its first appearance; Settings keeps the switch |
| Q139 | The Settings reminder row before the daily unlocks (Level 2)? | hidden until then |
| Q140 | A button that opens the phone's notification settings? | none in phase 3; the copy says where (it needs a small platform channel or `app_settings`, rule 9) |
| Q141 | A tap on the reminder? | it opens the app normally (splash → Home); a deep link to Daily later |
| Q142 | The reminder while the app is open? | not shown on iOS; Android's default importance (no heads-up) |
| Q143 | G.7's "2–3 notification lines"? | one line; rotating needs one schedule per weekday |
| Q144 | The share text's content? | the date, one 🪆 per family (at most 12), the families, the moves and the streak count, even while paused; G.6 replaces the wording |
| Q145 | The replay target line (Q118's detail)? | only when the moves were over t3; an assisted win at or under t3 shows none, and no line explains the cap until K.4 |
| Q146 | Reduce motion on the win card's stars? | all at once, no pop or twinkle; the three cues and haptics still fire at half the stagger (D48); K.3 may say silent |
| Q147 | The star totals? | Chapters: 3 × the chapter's bundled levels with a par (60); Records: 3 × the bundle's levels with a par (600) |
| Q148 | If a tutorial's scripted moves leave every optimal line (stars-core checks L2)? | accept that its first play can't reach 3★ (a replay can), and report it |

### P3.15 Verification

Contracts stage (2026-09-29):
- `flutter pub get`: the lock gained only new entries (the four packages
  and `cross_file` 0.3.5+5, `dbus` 0.7.15, `equatable` 2.1.0,
  `flutter_local_notifications_{linux 8.0.1, platform_interface 12.2.0,
  web 1.0.0, windows 3.1.1}`, `share_plus_platform_interface` 7.2.0,
  `uuid` 4.6.0); no locked version moved.
- `flutter build apk --debug --flavor dev -t lib/main_dev.dart` after the
  AGP bump: built (186 s). `flutter build ios --no-codesign --flavor dev
  -t lib/main_dev.dart`: built (`pod install` added the three pods).
- `LANE=contracts3 codegen.sh all`: exit 0 (99 outputs).
- `flutter analyze --fatal-infos --fatal-warnings` at the root: no issues.
- `cd packages/nesty_core && dart test`: 1,619 pass; `dart test -p node
  test/parity test/generator/golden_test.dart` plus the two new files:
  90 pass.
- `cd apps/game && flutter test --timeout 120s`: 2,805 pass, 0 fail
  (`test/contracts/m7_phase3_test.dart` 20, the extended E1, ARB,
  Remote Config, database contract and codec tests).
- `cd tools && dart test`: 330 pass once the TODO index was regenerated
  (135 tagged markers); `nesty_levels bundle check`: 200 levels OK.

The lanes (2026-09-29), each in its own paths:
- **stars-core:** core `dart test` 1,662 pass; node parity and goldens 84,
  Chrome and dart2wasm parity 60 each (the star digests from
  `test/rules/reference/starref.py`); tools `test/levels` 120; `bundle
  check` 200 levels OK with their pars (2–35), `fixtures check` OK; `report
  --stars` over all levels at 20/60: the casual bot's wins 24.0 / 47.9 /
  27.9 % at 3★/2★/1★, the smart bot's 98.6 / 1.3 / 0.0 %.
- **stars-app:** the bloc's 171 tests (12 new for stars), the save's 92,
  the splash's 9, `m7_phase3_test` 21, `app_flow_test` 12.
- **stars-ui:** `star_row_test` 9, the win card's 29 and 27, Chapters and
  Records 51, the win overlay and Chapters/Records overflow sweeps 80 and
  30, and the Chapters scroll-to-current regression test.
- **reminder:** the detail builders 14 (DST in `America/New_York`), the
  real service 14 (a throwing plugin double), `DailyReminder` 17, the
  offer's cubit 14 and card 6, Settings' cubit 10 and page 19, and the
  Settings and offer overflow sweeps 60 and 30.
- **share:** both share services 5, the share text 7, the Daily page 17,
  the Daily overflow sweep 130.

The integrator (2026-09-29), after every lane and its own edits:

| Command | Outcome |
|---|---|
| `LANE=integrator3 codegen.sh all` | exit 0 |
| `flutter analyze --fatal-infos --fatal-warnings` (root) | No issues found |
| `dart format --output=none --set-exit-if-changed`, CI's exclusions, tracked and untracked files | 917 files, 0 changed |
| `cd packages/nesty_core && dart test` | 1,662 pass |
| `cd packages/nesty_core && dart test -p node test/parity test/generator/golden_test.dart` (the star vectors included) | 84 pass |
| `cd packages/nesty_render && flutter test` | 530 pass |
| `cd apps/game && flutter test --timeout 120s` | 3,059 pass |
| `cd apps/admin && flutter test` | 47 pass |
| `cd tools && dart test` (with `claude_md_test`) | 344 pass |
| `nesty_levels bundle check` / `fixtures check` | 200 levels OK with par / 11 fixtures OK, 0 errors, 0 warnings |
| `gen_design_tokens`, `gen_nesty_icons`, `sync_design_assets`, `gen_fx_spec` with `--check` | all exit 0, unchanged |
| `dart run nesty_tools:todo_index`, then `--check` | 125 tagged markers, unchanged on the check |
| `flutter build apk --debug --flavor dev -t lib/main_dev.dart` | built |
| `flutter build apk --release --flavor prod -t lib/main_prod.dart` | built (79.8 MB); `drawable/ic_notification` survives resource shrinking |
| `flutter build ios --no-codesign --flavor dev -t lib/main_dev.dart` | built (31.3 MB) |
| `cd apps/admin && flutter build web -t lib/main_prod.dart` | built |
| The merged manifests (`devDebug`, `prodRelease`) | no `SCHEDULE_EXACT_ALARM` or `USE_EXACT_ALARM`; `POST_NOTIFICATIONS` and `RECEIVE_BOOT_COMPLETED` present |

Not run here: the device checks. The next stage runs the playthrough's new
steps, the unchanged resume and daily checks, and `nesty-test --android
--only reminder`.

Phase-3 device run (2026-09-29, device stage; PROGRESS D162). All from fresh
installs:
- iPhone 16 Pro simulator (iOS 18.3): the playthrough (90 screenshots),
  resume A = B and daily = core all pass.
- API 35 emulator: the same, all pass.
- `nesty-test --android --only reminder`: passes. On gives one pending
  reminder, off gives none.
- The iOS simulator's log shows no notification authorization request
  across 8 launches.
- Two UI fixes, each with a regression test: `NestyToast`'s text style, and
  the replay reason line's surface.
- After the fixes: `flutter analyze --fatal-infos --fatal-warnings` is
  clean and `apps/game` passes 3,061.

## Phase 4: Claude Design's m7-3 delivery

Written 2026-09-30 by phase 4's second contracts stage (C4b) from the phase 4
architecture and its lead notes (scratchpad `m7/p4/architecture.md`,
`ui-spec-game.md`, `ui-spec-menus.md`; the architecture wins on APIs, data,
behaviour, lanes and tests, the two UI specs on the look). The delivery is
`nesty-design-m7-3`, in `design/` since D171; the +1 Slot stays on the
bottom shelf (D172). Decisions are PROGRESS D173–D178 (C4a, the tooling) and
D179–D201 (C4b); the owner questions are Q156 and Q157. Earlier sections are
unchanged: where this section and one of them differ, this one wins for
phase 4's items.

The problem in one sentence: replace every M7 stand-in with m7-3 without
changing a rule, on exclusive paths, with every changed feature covered by
host tests, a device step and a `docs/TEST_COVERAGE.md` row (D169).

### P4.1 What C4a and C4b froze

Each item compiles (`flutter analyze --fatal-infos --fatal-warnings`
clean), is documented and has a minimal test (C4b's in
`test/contracts/m7_phase4_test.dart`). A lane adds behaviour and never
changes a frozen signature; a needed change goes in its report for the
integrator.

| Area | Frozen | Where | Stage |
|---|---|---|---|
| Tokens v3 | 1,218 leaves (1,021 emitted, 197 documented); board sections (`GlassCaseTallTokens`, `BoardFitTokens`, `BoardPresetTokens`, `TowerStackTokens`, `IcedTowerTokens`, `HintArcTokens`, `ChapterThemeTokens`), the per-screen UI classes, `ToastTokens`, `IconTokens`, the new `MotionTokens` and `SoundTokens` | `render_tokens.gen.dart`, `ui_tokens.gen.dart` | C4a (D173) |
| Lottie | 6 contract rows (`fx_glass_unlock_tall`, `ui_stars`, `ui_chest`, the three `ui_intro_*`), `ui_extra_slot`'s `rest` marker, `LottieRole` +4, `FxSpec.scaleNulls`, `sizesAuthored` | `fx_spec.gen.dart`, `features/fx/fx_id.dart` | C4a (D174, D175) |
| Assets | `design/ui/**` (35 SVGs), themes ch07–ch10, the tall case, 8 sounds, the generated `res/drawable/ic_notification.xml` | `apps/game/assets/**`, pubspec | C4a (D176) |
| Font | 68 glyphs (the 18 new plus `sd_card_alert`, `inventory_2`) | `NestySymbolsRounded`, `nesty_icons.gen.dart` | C4a (D177) |
| FX plumbing | `BoardSprite.glassCaseTall0..2` (93×152) and `glassCaseTall(frame)`; `FxImageSlot` tall pieces and `art` (`UiArt`) on the 5 UI slots; `FxDrawableParams.caseScale`; the intro loops ambient under reduce motion; `SlotShape.lockedSize`; `LevelSkinImages` leaves the UI slots null | nesty_render `board/board_sprites.dart`, `board/board_shape.dart`; `features/fx/fx_image_source.dart`, `fx_drawable_params.dart`, `fx_player.dart` | C4b |
| Audio | `SoundEffect.star1..3`, `chestWiggle`, `chestOpen`, `rivalComplete`; `Jingle.versusWin`, `versusLose`; `DuckReason.raceResult` (0.3); `SfxMix`'s map and gains | `core/services/audio/`, `music/music_service.dart` | C4b |
| UI art | `UiArt` (35 files, viewBox each, `badge(id, earned:)`, `rival(n)`), `UiArtLibrary` (`AssetUiArtLibrary` real, `FakeUiArtLibrary` fake, `UiArtScope`), `UiArtImage`, `UiArtImageSource` | `core/ui/art/` | C4b (D186) |
| Icons | `IconUses` (23 uses + `storageError`, `contentError`), `shareFor(platform)` | `core/ui/icons/icon_uses.dart` | C4b |
| Toasts | `ToastTone`, `ToastSpec`, `ToastQueue`, `ToastHost` (`maybeOf`, tops 60/152/124, the app root's 117), `ToastCard`; `NestyToast.show` queues on the nearest host; `BadgeToast.show` queues a badge toast with its art | `core/ui/widgets/feedback/toast_queue.dart`, `nesty_toast.dart`, `badge_toast.dart`, `app/app.dart` | C4b (D187) |
| Buttons | `TactileButtonVariant.versus`; `.danger` on `dangerTop → danger` | `core/ui/widgets/buttons/tactile_button_style.dart` | C4b |
| Chest | `ChestIcon` draws `UiArt.chestClosed`/`chestOpen` at the art's 180:150; `lockCenter` from the art | `features/daily/widgets/chest_icon.dart` | C4b |
| Themes and catalog | `ChapterTheme` ch07–ch10 with `token`, `palette`, `thumb`; `fallbackColor` = `palette.band`; `forChapter` cycles ten; `themeIds` ×10; ch07–ch10 at 2,000 (Q156); Forest Bear sold at 2,500 | nesty_render `theme/chapter_theme.dart`; `core/repository/bundled_catalog_repository.dart` | C4b (D199, D200) |
| Bloc | `NudgeSlot`, `SlotNudgeKind { emptyStand, lockedCase, iced }`, `TapPolicy.nudgeKindOf`; `SlotNudgeEffect` (the timeline plays nothing yet); `GameplayState.dropTargets` (core's `Rules.legalTargets` on the pick, empty once nothing is lifted) and `starsCapped` | `features/gameplay/bloc/` | C4b (D185, D191) |
| Save | `LevelWinRecord.starsCapped`; `showStarTip` = never shown, below 3, not capped; `recordLevelWin` no longer writes `starTipShown`; `SaveService.markStarTipShown()` (one idempotent update) | `core/services/save/` | C4b (D191) |
| Route | `GameplayEntrance { push, fromSplash }`, `GameplayPage.entrance`, `GameplayTransitions` (400 ms; push on `Interval(0, 0.75)`; pop 300 ms), the gameplay `CustomRoute` | `features/gameplay/pages/gameplay_entrance.dart`, `core/router/app_router.dart` | C4b (D194) |
| Services | `GameplayServices.share` (`ShareService`) and `.uiArt` (`UiArtLibrary`); `SystemSettingsService` (`ChannelSystemSettingsService` real on `com.futrix.nesty/system_settings`, `FakeSystemSettingsService` fake) | `features/gameplay/pages/gameplay_services.dart`; `core/services/system_settings/` | C4b (D189) |
| View hooks | `GameplayHud({…, Widget? raceStrip, bool familyCounterHidden})` (the strip in the top row, x 76 to W − 16, top 62, 48 tall, in place of the level and coin pills; a taller strip scales down); `GameplayBoard.familyCounterYield`; `RaceResultLayer(race, overlay, state, services, continuing, onRematch, onNewRace, onBackToRaces)` with the `raceResult` duck; `PauseDialog({…, RacePauseInfo? race, VoidCallback? onLeaveRace})`; `NextLevelFailedCard({title, body, retryLabel, secondaryLabel, onRetry, onSecondary, versus})`; `DailyShareData` = `({date, families, moves, streakDay, streakLit})` and `DailyShareText.of`; `seedSave(document, settings:)`; `SplashCopy.storageMegabytes` | `features/gameplay/widgets/gameplay_hud.dart`, `pages/gameplay_board.dart`, `overlays/race_result_overlay.dart`, `pause_dialog.dart`, `next_level_failed_card.dart`; `features/daily/share/daily_share_text.dart`; `integration_test/support/seeded_save.dart`; `features/splash/splash_copy.dart` | C4b |
| Copy | copy.md m7-3 in `app_en.arb` (P4.8) | `lib/l10n/app_en.arb` | C4b (D196–D198) |

Removed with the copy: `LevelPill.race` (the strip replaces the race's level
pill), the Museum's Chapters link (Q92's answer), the Daily solved card's
Share wiring (D188), `shareDataOf`. `test/core/ui/level_pill_race_test.dart`
went with `LevelPill.race`; `gameplay_hud_race_test.dart` now pins the
strip's place.

### P4.2 Lanes, exclusive paths and codegen

C4a (the tooling) and C4b (this stage) ran first and alone. Five lanes then
run in parallel (lead note 1: there is no T lane). Every lane uses the
frozen signatures of P4.1, never another lane's bodies. An edit outside a
lane's paths goes in its report for the integrator.

| Lane | Owns (exclusive) |
|---|---|
| **B board** | `packages/nesty_render/**` except `render_tokens.gen.dart` and `theme/chapter_theme.dart`; `features/gameplay/game/**` except `timeline/win_overlay_schedule.dart`; `features/fx/**` except `chest/**` and the frozen `fx_id.dart`, `fx_image_source.dart`, `fx_spec.dart` shapes; `features/gameplay/pages/gameplay_board.dart` (bodies); `core/services/skin/**` |
| **R race** | `features/race/**`; `core/ui/widgets/race/**`; `features/gameplay/overlays/{race_result_overlay,pause_dialog}.dart` (bodies); `features/gameplay/widgets/race_action_bar.dart`; `test/features/gameplay/pages/gameplay_view_race_test.dart`; `test/overflow/race_overflow_test.dart`; their tests |
| **M meta** | `features/{home,chapters,museum,records,shop}/**`; `core/ui/widgets/home/**`; `core/ui/widgets/buttons/play_button.dart`; `core/ui/widgets/modal/not_enough_coins_dialog.dart`; `core/ui/art/theme_thumbnail_loader.dart` (new); their tests and overflow suites |
| **D daily and settings** | `features/{daily,settings}/**`; `core/services/{daily,notifications,reminder,system_settings}/**` (bodies; the frozen shapes stay); `core/ui/widgets/settings/**`; `android/app/src/main/kotlin/**`; `ios/Runner/AppDelegate.swift`; `test/overflow/{daily,settings,reminder_offer}_overflow_test.dart`; `integration_test/reminder_test.dart`; their tests |
| **O overlays** | `features/gameplay/pages/**` except `gameplay_board.dart`; `features/gameplay/overlays/**` except R's two; `features/gameplay/widgets/**` except R's; `features/gameplay/game/timeline/win_overlay_schedule.dart`; `features/splash/**`; `features/fx/chest/**`; `core/ui/widgets/{stars,booster,hud}/**`; `core/ui/widgets/feedback/badge_toast.dart`; `core/ui/widgets/retry_view.dart`; `core/ui/lottie/**`; `core/extensions/app_exception_extension.dart`; their tests (not `gameplay_view_race_test`) and overflow suites |
| **I integrator** | cross-lane edits; `integration_test/playthrough_test.dart` and `support/**`; `tools/scripts/nesty-test`; `test/ethics/**`; `test/app_flow_test.dart`; `test/core/dependency_injection/di_test.dart`; later ARB additions; docs (PROGRESS, BACKLOG, TEST_COVERAGE, m7-design, CLAUDE.md, README, `claude-design-request-m7.md`'s "Follow-up after m7-3"); the TODO index |

- Codegen in `apps/game` only through the lock script
  (`LANE=<lane> bash scratchpad/m7/bin/codegen.sh l10n|build|all`); never
  `flutter gen-l10n` or build_runner directly.
- Only C4a, C4b and the integrator run the nesty_tools generators; a lane
  that needs a token, glyph or asset change asks the integrator.
- Lanes never run a device (one simulator, a shared `apps/game/build`):
  they write their `integration_test/*_test.dart` files, which the
  integrator wires into `tools/scripts/nesty-test` and TEST_COVERAGE (lead
  note 12).
- Every changed screen goes through `test/overflow/` (5 sizes × 1.0 and 1.3
  text, 48 dp targets, labels, cut text), owned by the screen's lane.
- Cross-lane reads: M and O use R's `ComputerTag` and `RivalPortrait`; M uses
  O's `StarRow` and `StarsTotal`; O uses D's `DailyShareText.of` and M's
  `NotEnoughCoinsDialog.show`; O uses B's `familyCounterYield` (false until
  B lands).

### P4.3 Lane B: the board

Items (architecture §2): B.1–B.7, D172 as built, E.13–E.16, E.19, E.20
(geometry and the yield signal), E.21.
- **The fit rule** replaces `_dollHeights`' h·2/3 clamp:
  `ShelfPresets.forShape(shape)` picks `twoShelves`, `threeShelves`,
  `threeShelvesTall` (3 shelves, maxSize 6) or `fourShelves` (1 shelf keeps
  its stand-in); `k = min(1, min(V, HUD, H) / heightOf(maxSize))`; stands at
  `min(90, pitch − 2.4)`, pips unscaled; `dollMinGap` and `pieceShrink` go.
- **The +1 Slot** (D172): the bottom shelf; 4 → 5 is `rowOfFive` (pitch
  74.4, stands 0.8), 5 → 6 the same formulas (`TODO(design)`); the re-pitch
  280 ms `easeInOut`, then the pad pops.
- **The tall case**: `SlotShape.lockedSize` filled in `board_shape_of.dart`;
  `usesTallCase` when the sealed doll is taller than 117.5 × pieceScale;
  `fx_glass_unlock_tall` with `case_size` driven by
  `FxDrawableParams.caseScale`; per-slot pools.
- **Tall ice, the tower stack, the iced tower** (§2.4): the tag hidden while
  iced, popping in at `fx_ice`'s `shatter` (frame 48).
- **`ui_extra_slot`** rests on frame 0 (the `rest` marker), stops under a
  doll (150 ms) and restarts when empty (Q65, Q111; D178).
- **Feedback** (§2.6): `SlotNudgeEffect` plays the dip, the padlock ping or
  the ice bump (preallocated `HandTween`s); the drag hover glows
  `fx_select_glow` at 60 % on a `dropTargets` stand; hint arcs are cubics
  (`HintArcTokens`); `SlotGeometry.hintNeedsCounter` sets
  `familyCounterYield`; the fallback doll per `layout.fallbackDoll`.
- **Tests**: `board_fit_test` (every preset's `limits` and `dollHeights`
  within 0.1 dp), `bundle_layout_fit_test` (all 200 levels × 6 viewports ×
  0/1/2 extra slots, architecture §2.8), the geometry, timeline, component,
  compensation, `case_size` delegate and workaround tests.
- **Device**: new `integration_test/board_layouts_test.dart` (architecture
  §7.3).

### P4.4 Lane R: vs Computer

Items: C.2–C.9 (C.1's Home tile is M's), the 9.3f card through
`NextLevelFailedCard(versus: true)`.
- Rival select (9.2): tap to select, one Start (`raceStart`), the beaten
  rival's check, "New" (`raceRivalNew`: unlocked, `raceNo == 0`, rival > 1),
  the newest preselected, `UiArt.rival(n)` portraits, `raceSelectSubtitle`,
  `raceStartHint`.
- The strip in the HUD row (9.3–9.3e, `RivalStripTokens`): 8 dp dots, the
  states "Ready when you are" / "Thinking…" / "Starting over" / "Finished" /
  "You finished first", the tag glyph-only under 360 dp and the state line
  hidden under 340 dp; Start over slots 2–3; the banner back at 152 (done
  by C4b's hook).
- Results (9.4, 9.5) in `RaceResultLayer`: two buttons as drawn, system back
  to rival select (lead note 9); 9.4 plays `Jingle.versusWin` (coins @700),
  9.5 `Jingle.versusLose`, both under the `raceResult` duck; 9.6 a card once
  per rival as 9.4 closes; badge toasts through a scoped `ToastHost` at 60.
- Pause (9.7, 9.7b): the header `racePauseHeader` with portrait and tag,
  `racePauseSubtitle`, Leave race asking once (`raceLeaveTitle`,
  `raceLeaveBody`, `raceLeaveKeep`); Settings reachable (Q132): the
  integrator flips `onSettings` in the view with the race hold kept.
- `SoundEffect.rivalComplete` when the rival completes a family (no haptic).
- The Computer tag (C.8): 20 tall, radius 10, 1.5 dp `#D8B07A` ring, glyph 14
  + Nunito 800 11, beside every rival name.
- **Tests**: select (selection, New, beaten check, locked), the strip (every
  state, dots, widths 320–430, reduce motion, taps pass through), results
  and 9.6, pause and the leave confirm, the cues; a `ComputerTag` beside
  every rival name (Q-P4-7's decision moves that check out of the ARB).
- **Device**: new `integration_test/race_loss_test.dart` (fast pace; the
  race gaps).

### P4.5 Lane M: the meta screens

Items: A.4, C.1, E.1, E.4, F.1, F.5 (purchase), H (cards), I.4 with 10.4b,
I.6 (screen), I.7 (Home badge), J.1, J.2, J.3 (dialog), K.5.
- `ThemeThumbnailLoader` in `core/ui/art/` (lead note 4): the art's
  `thumb` crop at 158×74 (Shop), 84×42 (Chapters' folded rows), the
  358-wide header clipped to 92; an LRU of 12, loads one at a time,
  `palette.band` until ready; the menus spec's grayscale 0.7 / brightness
  1.06 locked look.
- Home per 2.1/2.1b and 12.1–12.3 (the chapter card opens Chapters, the
  Records button beside it; SUPER HARD and BONUS badges; locked tiles; 16:9);
  Chapters 10.4 and the level card 10.4b; Museum 6.1–6.1c (the Chapters link
  is gone, C4b); Records 10.6 (the stats grid, the races card with portraits
  and tags, "Best moves by level", the 3-column badge grid from
  `UiArt.badge`); the Shop's `ShopTokens` (delete `shop_colors.dart`),
  Forest Bear's card and detail; "Not enough coins" per J.3.
- **Tests**: every screen state per frame, the theme crops (the loader's
  fake), the level card replays, the Forest Bear buy flow, the dialog copy.
- **Device**: new `integration_test/meta_screens_test.dart` (a seeded save
  through `seedSave`).

### P4.6 Lane D: the daily and Settings

Items: E.3 (Daily), F.2 (day-7), F.3, I.1 (text), I.2, I.3 (5.6/5.6b), I.7
(Daily), architecture §3.8, §3.9, R4; the solved card's Share button goes
(C4b removed the wiring; D drops `PuzzleCard.onShare`).
- The reminder (§3.9): the offer's body line, time chip, set and denied
  steps; a denied Yes keeps `reminderOn: true` and blocked (D190); Settings'
  Daily reminder toggle, Time row, blocked row with "Open phone settings"
  (`SystemSettingsService`), Relaxed mode with its subtitle, Reduce motion's
  inline Off · On · System (`SettingsSegmentedRow`, replacing
  `reduce_motion_sheet.dart`); the notification title "Nesty", its three
  lines rotating by `epochDay(nextFire) % 3` at each re-plan (one trigger,
  id 1); `AppColorTokens.notificationAccent`.
- The native side of `com.futrix.nesty/system_settings`
  (`openNotificationSettings`): `MainActivity.kt` (API 26+
  `ACTION_APP_NOTIFICATION_SETTINGS`, 24–25 app details) and
  `AppDelegate.swift` (iOS 16+ `openNotificationSettingsURLString`, else
  `openSettingsURLString`).
- The streak's lit / paused / relit looks (`color.streakPaused*`,
  `relitGlow`); the day-7 chest modal (5.6/5.6b) opens closed like the
  milestone chest (`ChestModalTokens`); `SettingsTokens` for the symbols
  cards.
- **Tests**: the share text (C4b's `daily_share_text_test`), the reminder
  steps (denied keeps on), the rotation, the blocked row, the segmented
  control, the channel service (a fake binary messenger).
- **Device**: new `integration_test/daily_states_test.dart` (a seeded
  6-day streak with `NESTY_FAKE_DATE`, then a paused → relit seed, the
  Settings states); `reminder_test.dart` updated.

### P4.7 Lane O: the overlays

Items: D, E.2, E.5–E.12, E.17, E.18, E.20 (the HUD's 150 ms fade of
`familyCounterHidden`), I.1 (the button), I.3 (the sequence, milestone),
I.5, I.6 (toast), I.8, I.9, K.1–K.4, the J.3 popup path.
- The win card per 11.2–11.2d (`WinStarsTokens`, `winStarsShort`):
  `ui_stars` in its 240×110 canvas at (75, 176) through `UiArtImageSource`,
  segments `star_1…star_n` from 1,300 ms with `SoundEffect.starN` and a light
  haptic each, the flourish at 3★; reduce motion: the last frame at once, one
  sound (the highest) and one haptic (D191); the moves chip with `route` and
  "New best!" on it; the helper note when `starsCapped` (it wins over the
  tip; neither on 16:9); the tip when `starTip` and there is room, then
  `SaveService.markStarTipShown()`; badge toasts through a scoped
  `ToastHost(top: ToastHost.badgeTop)`.
- The daily win card's Share above Back to Daily (10.1), with
  `IconUses.shareFor`, an origin rect, `DailyShareText.of` and
  `GameplayServices.share`.
- The chest moment (§3.5) on `ui_chest` (arrive, idle, wiggle, open,
  open_idle), the chips at their promised amounts from the start, the
  flights, reduce motion's crossfade; the card at top 214 (lead note 8),
  the SVG fallback.
- The splash passes `GameplayEntrance.fromSplash` (the 400 ms fade; E13 per
  lead note 11); the storage and content error views (`splashStorage*`,
  `splashContent*`, `IconUses.storageError`/`contentError`,
  `SplashCopy.storageMegabytes`).
- 12.5 generating (`gameplayGenerating`, `ui_spinner` 44), 12.6 failed
  (`NextLevelFailedCard`'s look, `gameplayFailed*`), 12.7 stuck with Restart
  glowing, 12.8 undos spent (`oomUndoSpent`), 12.9 the +1 Slot limit (the
  disabled face, "2/2", `extraSlotLimitToast` once), 10.9 relaxed
  (`all_inclusive`, `relaxedModeOn`), the tutorial's "STEP n OF 3" (C4b
  switched the chips), the intro loops (`LottieFxView`, frame 0 still under
  reduce motion), the chapter ribbon tinted with the palette (lead note 7),
  the win twinkles, the counter's hug width, the text link's 48 dp box (lead
  note 3), the booster popup's "Not enough coins" path.
- **Tests**: the win card at 1/2/3★ (campaign, replay, bonus, daily with
  Share), the reveal and reduce motion, the note and the tip's deferral, the
  chest phases and flights, generating, failed, OOM spent, the slot-limit
  toast, the disabled booster, the splash errors, the tutorial chips, the
  intro loops, the fade.
- **Device**: new `integration_test/overlays_test.dart` (architecture §7.3);
  L1's step 3 and the fade in the playthrough (I).

### P4.8 Copy: copy.md m7-3 in the ARB

- Every copy.md string is in `app_en.arb` by the architecture's §4 table:
  keys keep their names, values are copy.md's (curly quotes and `·` kept),
  each description cites its id ("copy.md G.5 `rival_1_name`…"), and a key
  copy.md doesn't cover says "Not in copy.md m7-3" and why. No description
  says "Placeholder until Claude Design".
- App-owned numbers became placeholders: `museumIntro(levels)`,
  `oomUndoSpent(count)` (`free_undos_per_level`), `extraSlotLimitToast(count)`
  (`LayoutLimits.maxExtraSlots`), `tutorialStepChip(step, total)`,
  `splashStorageBody(megabytes)` (Q157), `recordsFamiliesValue(count, total)`,
  `recordsStarsValue(count, total)`. Rule constants stay in the text: "3"
  stars (`StarRating.maxStars`), "Seven days" (the day-7 cadence), "After
  Level 2" (Q67).
- Shapes that changed: `raceRivalLocked(rival)` (a name, not a number),
  `raceLossBody(rival)`, `reminderOfferDenied(time)`,
  `badgeEarnedToastTitle(badge)`, `museumNextLine(chapter, count)`,
  `dailyShareText(date, glyphs, moves, day)`, `winStarsTarget` without the
  unreachable singular. Skin selects key `forest-bear` as `forest_bear`
  (`CatalogL10n.skinNameOf`, `skinDescriptionOf`).
- 53 new keys (the architecture's NEW rows); 10 retired (`museumChaptersLink`,
  `recordsRaceRow`, `raceSelectRace`, `raceRivalWins`,
  `settingReduceMotionSheetTitle`, `chestInside`, `dailyShareFamilyGlyph`,
  `tutorialStep1Chip`, `tutorialStep2Chip`, `hudRaceChip`), pinned gone by
  `arb_keys_m7_test`. Frame-only lines kept as keys with a `TODO(design)`:
  `raceStripReady` ("Ready when you are", C7), `racePauseHeader`
  ("vs Computer · {rival}"), `gameplayGenerating` ("Setting up the
  shelves…", C8), `shopOwned`.
- Every call site compiles: the chest modals' bodies, the reminder's denied
  line, the tutorial chips, the Museum's intro and link, rival select's
  locked line and button, Records' race rows ("Pebble, Computer" until M's
  rows), the reduce-motion sheet's title, the badge toast, the race loss
  card and the share text.
- E1: `respect_copy_test` adds the new race keys and five scoped exemptions,
  each with its reason (D197): `raceRivalSkill` "slow" and "quick",
  `raceRivalBlurb` "quick" and "before", `raceLeaveBody` "ends" and "lost",
  `raceWinBody` "before"; a test fails if a word leaves its key, and the
  same word in another key still offends. `arb_keys_m7_test` pins every M7
  key, the citations, the retired keys, the share placeholders, every
  select's ids, and "computer" in the screen-reader strings (visible names
  carry the tag instead; R's widget tests pin it).

### P4.9 Decisions and questions

Decisions (PROGRESS): D173–D178 (C4a: tokens, Lottie, `sizesAuthored`, UI
art sync and the notification icon, the font, the extra-slot note for B),
then:
- D179 phase 4's design: C4a, C4b, five lanes, the integrator, the lock;
- D180 the fit rule and presets; D181 D172 as built (rows of 5 and 6);
- D182 the tall case and tall ice; D183 the tower stack and the iced
  tower's tag;
- D184 `ui_extra_slot` rests on frame 0 and stops under a doll (Q65, Q111);
- D185 E.13's nudge, E.14's hover from core's legal targets, the hint arcs,
  3.1b's counter yield (Q39);
- D186 the UI art layer drawn from `nesty_render`'s rasterizer (no
  flutter_svg in the game);
- D187 the toast queue (Q122, Q136);
- D188 Share on the daily win card with G.6's text (Q144, Q151,
  Q-P4-1);
- D189 "Open phone settings" by a platform channel (Q140);
- D190 a denied Yes stays on and blocked; the three lines rotate (Q143,
  Q-P4-4, Q-P4-5);
- D191 the stars: `ui_stars`, one reduce-motion cue, the helper note, the
  tip marked when shown (Q145, Q146, Q-P4-6);
- D192 the race per section 09 (Q131–Q135, Q-P4-7);
- D193 Home, Chapters, Museum and Records per J and I.4–I.6 (Q92, Q113,
  Q115, Q123);
- D194 the first-launch fade through `GameplayEntrance`;
- D195 "Not enough coins" from the booster popup until M6;
- D196 copy.md into the ARB; D197 the scoped copy exemptions (Q-P4-2);
  D198 the catalog copy is final (Q73, Q-P4-9);
- D199 the ten theme palettes, `band` as the fallback, `forChapter` cycles
  ten; D200 Forest Bear at 2,500 (Q72);
- D201 the lead notes' settled look (48 dp text links, the chapter ribbon,
  the chest card, race results, "STEP n OF 3", 20 glyphs).
- D202 the integration (the integrator): the view's `dropTargets` hand-off,
  `RaceResultLayer`'s skin, Settings in a race's Pause with the hold kept,
  three retired ARB keys, E1, `di_test`, `app_flow_test` and the playthrough
  on m7-3, the five device files in `nesty-test`, the Claude Design
  follow-up;
- D203 E13 with the first-launch fade (lead note 11): E13 counts to the
  first playable frame, reached under the fade; "alone" includes it; no
  threshold (Q114);
- D204–D208 the lanes' look and flow choices: B the board (the tokens'
  hint arch, the iced tower's ice, the ping, the tower stack, the capped
  tall case), R the race (Keep racing resumes, 9.6 before 9.4's action,
  `VersusRibbon`, screen-width rules), M the menus (Home's blend, the
  derived relit ring, `ChapterStarTally`, the folded row), D the daily and
  Settings (the offer dialog, the 48 dp segmented track, the blocked
  toggle, Q81 kept), O the overlays (the design-y win card and its 760 dp
  short card, the haptics, `RibbonTint`, the scaled counter, the toasts'
  cadence, four frame-text keys).

Owner questions: **Q156** the ch07–ch10 theme prices (default 2,000 each);
**Q157** the splash's "about 60 MB" (default: copy.md's line with 60 in
`SplashCopy.storageMegabytes`); **Q158** (the integrator, from lane D) a
reminder the OS blocked has no off switch in the app (default: no extra
control). The design answered Q39, Q65, Q72 (Forest
Bear), Q73 (the catalog copy), Q92, Q111, Q113, Q115, Q122, Q123,
Q131–Q136, Q140, Q143–Q146 and Q151 (PROGRESS marks each with its
decision). Unchanged: Q129,
Q152, Q29, Q87.

### P4.10 Verification

C4b's gate (2026-09-30; its report, `scratchpad/m7/reports/c4b.md`):
the five generators' `--check`; `flutter analyze --fatal-infos
--fatal-warnings`; nesty_core, nesty_render, game, admin and tools suites.
What still fails is each lane's to close and is listed in the report
(B: the three `board_pieces_l9_test` +1 Slot cases, D178; the owner's
untracked `export 2/` folder in `claude_md_test`). The lanes' gates, the
integrator's full `/milestone` baseline, and the device stage (every new
`integration_test` file on the iPhone 16 Pro simulator and the API 35
emulator, `--android --only reminder`) follow; phase 5 starts after them.

The integrator (2026-09-30; its report, `scratchpad/m7/reports/integrator4.md`,
and the status table, `integrator-p4.md`): every lane's needs from others
and the integrator's own items are in (D202, D203). Its gate passed:
`codegen.sh all` through the lock; `dart format` over CI's list (987
files, 0 changed); `flutter analyze --fatal-infos --fatal-warnings`;
nesty_core 1,662 and its node parity 84; nesty_render 600; the game 3,992;
the admin 47; tools 391; `bundle check` (200 levels) and `fixtures check`
(11); the five generators' `--check`, the TODO index at 93 markers; the APK
dev debug and prod release (81.4 MB; `aapt2 dump resources` keeps
`drawable/ic_notification`, the generated vector), iOS dev (`Runner.app`
32.6 MB) and the admin's web. `nesty-test` drives the playthrough and the
five new files, each from a fresh install (`--only
board,race,meta,daily_states,overlays`). Left: the device stage, then
phase 5.

## Phase 5: close (stub)

Fidelity audit, accessibility audit, translations (8 languages), animation
polish, the pass-and-play proposal, the three-lens review (rules and
correctness, security, ethics) and its fix pass, the `/milestone M7` gate,
`nesty-test` on iOS and Android, the docs.

## Ethics checklist (brainstorm §5; filled per feature by the integrators)

The six questions: (1) every level winnable without an ad, purchase or
booster; (2) every reward shown in advance and deterministic, no paid
randomness; (3) no timer, countdown, scarcity or fail-triggered offer; (4)
every computer rival labelled a computer on every screen; (5) nothing
punishes absence or shames a loss; (6) every non-essential prompt or
notification off by default, value-framed and switchable in Settings.

Phase 1 (2026-09-28, from the lanes' reports and the integration): no
failing answer. Phase 2 (2026-09-28, vs Computer, from the lanes' reports
and the integration): no failing answer. Phase 3 (2026-09-29, star
ratings, the share card and the reminder, from the five lanes' reports,
the contracts' and the integration): no failing answer. Phase 4
(2026-09-30, Claude Design's m7-3, from C4a's, C4b's and the five lanes'
reports and the integration): no failing answer, and one flagged for the
owner: question 6 for the reminder in its blocked state, which has no off
switch in the app (Q158; nothing is delivered while blocked).

| Feature | 1 | 2 | 3 | 4 | 5 | 6 | Checked by |
|---|---|---|---|---|---|---|---|
| Levels 31–200 and E12's gates | Yes: rule 8 proves every level from its start; each new one also solves within 20,000 nodes, and the smart bot wins ≥ 75 % | Yes: a level pays its tier's fixed coins; boards are fixed files from recorded seeds | None: no timer, no offer, no copy | n/a | No: no copy; only L200 never wins by chance (Q107) | n/a | levels, levels-fix |
| E2 gentle streak | Yes: the streak gates no level | Yes: the day-7 chest's coins are fixed and shown before it opens | None: `respect_copy_test` ("Freeze used", "No freeze") | n/a | No: a miss pauses the flame and never lowers the count or the chest cadence; the paused look is neutral, never red | n/a: the freeze notice is information, shown once | meta-services, menus, contracts |
| E5 milestone chest | Yes: a bonus on a win already made | Yes: its contents show closed, before Open; fixed Remote Config amounts paid at the win; the opening counts up exactly those (`reward_randomness_test` scans it) | None: the countdown counts levels to a reward, never a deadline; it never follows a loss | n/a | No: never taken back | n/a: the presentation of a reward already paid; reduce motion respected | gameplay-bloc, gameplay-ui, owner-chest, integrator |
| E6 relaxed mode | Yes: it only removes undo's cost | n/a | None: it drops the undo price and ad rows | n/a | No | Yes: off by default, a Settings toggle, read live | gameplay-bloc, gameplay-ui, menus |
| E7 replay and best moves | Yes: only won levels replay | Yes: a replay pays nothing and says why; best moves are deterministic | None: moves never show during play; no stars or grades | n/a | No: a replay can't lower progress; "Best N" is a quiet personal record | n/a | gameplay-bloc, gameplay-ui, menus |
| E8 records and badges | Yes: cosmetic | Yes: fixed triggers, pay nothing, never taken away | None: no badge for consecutive days | Yes: every Records rival row reads "Rival N · Computer" (`arb_keys_m7_test`, the Records widget test) | No: no "missed a badge" copy | n/a: the badge toast acknowledges a win in the session; no notification | meta-services, menus, gameplay-ui |
| E9 first launch and E13 timing | Yes: L1 is the tutorial, won by two moves, nothing to buy or spend | Yes: L1 pays its fixed +10, shown on the win card; nothing random | None: E13 is measured by the test and never shown to a player | n/a | No: the first win's Continue goes Home with no loss or absence copy | n/a: no prompt added (M6's consent step will sit before L1) | gameplay-bloc, gameplay-ui, integrator, device stage |
| E14 reduce motion | Yes | n/a | None | n/a | No | Yes: follows the system by default, a Settings row; sounds and haptics keep their strength | menus, board-fx |
| The chapter ribbon fix (daily and bonus boards) | Yes | n/a | None | n/a | No | None | gameplay-ui, device stage |
| The Museum label fix (Chapter N · Levels X–Y) | Yes | n/a | None | n/a | No | None | menus, device stage |
| The owner's review (Home, Chapters v2, the Museum, the Shop's equip, "Not enough coins", the chest opening) | Yes: nothing gates a level | Yes: the Museum says what earns a family; Chapters marks the chest and finale levels; the dialog states only a price and a shortfall | None: the dialog opens only on the player's own tap, never after a fail, and "Not now" costs nothing | n/a | No: the Museum fix removes an unfair "soon" on a fully won chapter | n/a: the dialog is player-started and skippable | menus, owner-home, owner-fixes, owner-chest |
| E10 vs Computer (phase 2) | Yes: a race gates no level; every race board is generator-made and solved from its start (rule 8); in a race Hint and +1 Slot are off and Undo and Restart are free, so nothing can be bought (`race_mode_test`, `race_respect_test`) | Yes: the reward (`race_reward_n`, 20 / 30 / 40) shows on the select card before the race and is paid once, in one update (`recordRaceWin`); the board, the rival's moves and the pace's jitter come only from core's seeded streams (`reward_randomness_test`) | None: Start has no countdown; the pace is the rival's move interval and is never shown; `RaceState` has no time field (`race_respect_test`); no offer can open in a race; every race string passes the urgency list | Yes: the tile, every select card (and its screen-reader label), the strip, its label and announcements, the level pill, 9.4, 9.5, the unlock toast and Pause (`arb_keys_m7_test`, race-ui's widget tests, `gameplay_view_race_test`, `app_flow_test` (i), the playthrough segment) | No: a loss writes and costs nothing, its copy is warm ("The computer finished first" / "So close! Rematch?"), there is no loss count, and every race string passes the taunt and loss lists (`respect_copy_test`); nothing depends on days | n/a: no prompt or notification; "New rival unlocked!" acknowledges a win in the session | race-core, contracts, race-services, race-bloc, race-ui, integrator |
| E3 share card (phase 3) | Yes: nothing gates on sharing; the button shows only on a solved card whose solve is known (`daily_page_test`) | n/a: no reward; `DailyCubit.share` is a pure delegate that touches no save field, coin or analytics event (`daily_page_test`'s Share group) | None: no "share to unlock", no timer; `dailyShare*` passes the deny-list (`respect_copy_test`) | n/a | No: the text is spoiler-free and value-framed (the date, one 🪆 per family up to 12, the families, the moves and the streak count as the card shows it, paused or not; never the board, colours, slots or a move list, `daily_share_text_test`); a failed or dismissed share shows nothing | Player-started only: nothing auto-shares and no prompt appears; the device runs never tap it | share, contracts, integrator |
| E4 reminder (phase 3) | Yes: the reminder gates nothing | n/a: no reward | None: the offer follows a solve, with no countdown; `reminder*` and `settingReminder*` pass the deny-list ("now", "before", "miss", "left") | n/a | No: the same warm text every day whatever the streak, a paused one included, and it never names it (`reminder_opt_in_test`, `planFor` never reads the streak); no badge; the denied and blocked lines carry no blame | Yes: off on a fresh install with nothing scheduled or asked (`reminder_opt_in_test`, `daily_reminder_test`); offered once, at its first appearance (Q138); the OS asked only after the player's Yes (the one `requestPermission` call is `DailyReminder.enable`, reached only from the offer's Yes and Settings' toggle); one id, one a day, inexact, no badge; a Settings switch and time; the playthrough answers "No thanks" and checks nothing was scheduled | reminder, contracts, integrator |
| Star rating (phase 3, D125) | Yes: stars gate nothing (`stars_gate_nothing_test` scans the chest, daily and race services, the repository, the router, Home, vs Computer, the Shop, the Museum, `badge_rules.dart` and `win_reward.dart`, and a 1★ and a 3★ run of twenty levels leave the same save apart from the stars); par is the solver's booster-free optimum, equal to a breadth-first oracle on every solvable fixture (`par_oracle_test`); both tutorials' scripted lines reach 3★ (`repo_levels_test`) | Yes: stars pay nothing (the contract, bloc and E1 tests: coins, chest, progress and badges unchanged); a pure integer function of moves and par, the same on the VM, node, Chrome and dart2wasm (digests from an independent Python reference); `reward_randomness_test` scans the star widget | None: no time in the rule; no offer follows a low-star win; the star keys pass the deny-list and a star-shaming list | n/a: races have no stars (`PlayEntry.par` is null for a race; the bloc test) | No: every win earns at least 1★ and celebrates the same (ribbon, coins, confetti, card; `win_overlay_test`); stars never go down (the save keeps the highest, across replays and a new version; the backfill never lowers); an empty star is a warm outline, never grey or red; the replay's target line is information | n/a: no prompt; the one-time tip is a line in the card, shown once (`starTipShown`) | stars-core, stars-app, stars-ui, contracts, integrator |
| m7-3's tooling and contracts (phase 4, C4a, C4b) | Yes: no rule changed; tokens' rule values (`versus.*`, `chest.*`, the +1 Slot limit, the reduce-motion default) are documented, never read, and `rule_tokens_test` pins each to its real source | Yes: nothing random added; the chest's contents-first rule is the design's too | None: the toast's 2.5 s is display time, with no offer | Yes: the `computer` glyph ships; every screen-reader string says "computer" (`arb_keys_m7_test`); visible names carry the tag (D192) | No: the copy passes the deny-lists, with four rival lines exempt for their key and word only, about the computer (D197) | n/a: no prompt added | c4a, c4b |
| Board layouts 31–200, the nudge, the hover, hint arcs (phase 4) | Yes: every bundled level fits every supported screen with 0, 1 or 2 +1 Slots (`bundle_layout_fit_test`); no rule changed | n/a: the board shows no reward; the tag, ice count and pips are core's numbers | None: the 80–280 ms motions are feedback; no offer on a dead tap | n/a: the race board draws through the same board; its labels are lane R's | No: a tap on an unpickable slot gets a soft nudge, never the invalid shake or `bonk` | n/a: reduce motion halves the nudges | board, integrator |
| vs Computer on section 09 (phase 4) | Yes: optional, gates no level; race Undo free and unlimited, no booster or purchase | Yes: "Win 20 / 30 / 40 coins" on each open card before Start, paid once from `RaceRules.rewardCoins`; 9.6 says only what unlocked | None: no countdown before Start, Pause holds the rival too (Settings included, D202), nothing but Rematch and New race after a loss | Yes: the Computer tag beside every rival name on select, the strip, 9.4, 9.5, 9.6, Pause and 9.7b (widget tests pin one per name); screen readers hear "{name}, Computer" and "the computer" | No: 9.5 is "So close! Rematch?" on the plain scrim, no red, no move count; Leave race says "nothing lost" and writes nothing | n/a: no prompt; 9.6 once per rival after the player's own win, Not now as prominent | race, integrator |
| Home, Chapters, the Museum and Records (phase 4) | Yes: they only open screens; every level opens in order and replays are free | Yes: the level card shows the target and the best before Play; the Museum's next family and levels to go; star totals are fixed sums (`ChapterStarTally`) | None: the relit ring is a one-time glow | Yes: the vs Computer tile and every Records race row carry the tag, and their labels say "computer player" | No: a paused streak rests, never red, its number never drops; a 1★ level shows warm outline stars; a rival with no wins is an en dash; a locked badge reads "Not earned yet" | n/a | meta, integrator |
| The Shop: Forest Bear, theme crops, "Not enough coins" (phase 4) | Yes: skins and themes are cosmetic | Yes: every price fixed and shown before the tap (Forest Bear 2,500, D200; ch07–ch10 at Q156's default); the dialog states the exact price and shortfall | None: no sale or countdown; the dialog opens only on the player's own tap on a price, never after a fail (D195) | n/a | No: warm copy ("A few more coins") | n/a: the celebration's haptic follows the Haptics setting | meta, overlays |
| The daily, the gentle streak and the day-7 chest (phase 4) | Yes: the streak gates nothing | Yes: the day-7 chest shows "+300 coins" before Open, a fixed amount | None: no timer or scarcity | n/a | No: a missed day pauses ("resting"), never lost or red | n/a | daily |
| The reminder dialog and Settings (phase 4, D189, D190) | Yes: gates nothing | n/a: no reward | None: the offer follows a solve, never a fail, with no countdown; "Open phone settings" only on the player's tap | n/a | No: the three rotating lines never name the streak or an absence | Yes, flagged in one state: off until a Yes, asked once, value-framed, the OS asked only after the Yes; Settings turns it off, except while the OS blocks it, when the toggle opens the phone's settings instead (Q158) | daily, integrator |
| The win card, stars and the daily win card's Share (phase 4, D188, D191) | Yes: stars, the helper note and the tip gate nothing (`stars_gate_nothing_test`) | Yes: the coin chip counts to its known reward; stars pay nothing | None: no offer after a low-star win | n/a | No: a 1★ win shows the same card, coins and Continue as a 3★ one; the helper note explains the cap without blame | Player-started only: Share is the player's tap, plain text, never auto-shared; the tip shows once | overlays, integrator |
| The chest moment on `ui_chest` (phase 4) | Yes: a bonus on a win already made | Yes: the contents show from the first frame at their promised amounts, no count-up | None | n/a | No | n/a: reduce motion's crossfade | overlays, daily |
| The splash's fade and error cards, 12.5–12.9, relaxed mode, the tutorial and the intro loops (phase 4) | Yes: the +1 Slot limit toast only explains; relaxed mode only removes friction | n/a | None: the failed card and the splash errors offer only Try again and Back; the Out of Moves prices are the player-tapped rows | n/a | No: "The shelves need a moment", "Your 2 free undos are used" | Yes: the relaxed toast once per launch, only when the player turned it on in Settings | overlays |

**Review pass (2026-09-29, phase 5).** Five read-only lenses reviewed the
whole M7 diff: logic, ui (with the accessibility audit), platform,
security and ethics. The ethics lens re-checked every row above against
the code, not only against its tests, and found no answer contradicted.
Five findings, none P0: R1 (P1), the race win and loss cards never said
"Computer" to a screen reader (question 4), fixed with the rival select's
`Semantics` pattern and two tests; R2, a clock rolled back behind
`lastDate` granted a freeze for the older ISO week, fixed in `reconcile`
(the line in §8, D163; the paused case is Q153); R3 and R5, two doc
fixes; R4, the reminder's Android accent, deferred to I.2. The findings
table and the audit's per-screen table are in PROGRESS "M7 review pass
(2026-09-29)". No answer above changes; E10's question 4 now also holds
for a screen reader on 9.4 and 9.5.

**Review pass, round 2 (2026-09-29).** Four deeper lenses tried to break
the code: the save, the race and the bloc's lifecycle, the reminder and
platform, and the accessibility audit of the pre-M7 screens. They found 33
issues (R6–R38): 32 were fixed, and R12, screen-reader play on the board,
is left to the owner (Q154). Two fixes bear on the answers above:
- E2's question 5. A daily finished after midnight no longer counts toward
  the streak (R6). It used to burn a held freeze or restart the run and say
  "Streak relit!" when the Daily's countdown ticked mid-puzzle. Now it pays
  and records the date only, as §8 and Q70 say.
- E4's question 6. Over the Hive fallback the reminder never cancels the
  player's real schedule, and the one-time offer never shows again (R30).

The other reminder fixes (the zone fallback, the iOS sound, the
spring-forward gap; D166) and E14's iOS Reduce Motion (D167) make P3.10
and §14 hold on real devices. No answer above changes. The findings table
and the per-screen audit are in PROGRESS "M7 review pass", round 2.

**Device run after the review (2026-09-29, phase 5; PROGRESS D168).** Every
device check passes from fresh installs on the iPhone 16 Pro simulator and
the API 35 emulator, before and after its one fix: the playthrough, resume
A = B and daily = core. `nesty-test --android --only reminder` passes, and
passes again with the emulator in Europe/Amsterdam, so R9's fallback holds
on Android.

Each screenshot was paired with its phase-3 twin. They show only round 2's
few-dp changes, and one side effect of R23, now fixed. Where the block
above the win card's button scales down (a 16:9 phone), the button stood
wider than the card. It now takes the scaled card's width and keeps its
own height (`_BlockOverButton`, `win_overlay_test`).

No answer above changes: the fix is layout only. Still to do: the VoiceOver
and TalkBack pass, and the race-loss segment on a device.
