# Plan: the daily gift (a login reward), 2026-10-05

Status: **approved by the owner on 2026-10-05 with Q182's defaults (D268).**
It starts after M7 closes. The work list is BACKLOG "Daily gift", and the design
request is [claude-design-login-gift-prompt.md](claude-design-login-gift-prompt.md).
Research: [login-gift-research.md](login-gift-research.md).

## Context

- **The request (2026-10-05):** a daily and weekly login reward, "the same
  as other games".
- **What exists:** nothing that pays for opening the app. The Daily pays for
  solving its puzzle: 50 coins, plus 300 on every 7th streak day (spec §7.3,
  §7.5, E2).
- **What earlier docs said:** local-habits "Out" and engagement-research
  "Rejected" left out "escalating login calendars". Those were proposals,
  not owner decisions.
- **What the owner's rules allow (D92, spec-prop §1.1):**
  - Rule 6 rules out the genre's restart to Day 1.
  - Rule 2 rules out wheels and card reveals.
  - Rule 3 rules out countdowns and expiry.
  - So this copies the genre's look (7 days, a bigger Day 7) and pairs it
    with a count that never drops, as HoYoLAB does.
- **Rating:** PEGI 7, not PEGI 12 (research §Regulation).
- **Placement:** not in the spec, and not an M7 feature. By default it comes
  first after M7 closes, ahead of the local habits (D237, Q162). Q182a.

## The rule (spec-prop text for the owner to paste, §7.5b)

```markdown
### 7.5b Daily gift
Once a day, opening the app lets the player claim a gift from a 7-day track
shown in full in advance. The track counts claims, not dates: a missed day
never moves it back, and the next claim is simply the next day on the track.
After day 7 the track starts again at day 1. At most one claim per local
calendar date; a date earlier than the latest date ever seen claims nothing.
Unlocks with the Daily (after level 2). No ad, purchase or timer is involved.
Track (Remote Config `login_gift_track`): 20 coins · 30 coins · 1 hint ·
40 coins · 50 coins · 1 hint · 100 coins + 1 extra slot.
```

- **A week of gifts:** 260 coins, 2 hints and 1 extra slot, worth about 530
  coins. A week of Dailies pays 650. Q182c.
- **Also needed:** a §7.3 row ("Daily gift | the 7-day track") and a §9.4 key.

## Approach

- **The rules:** `LoginGiftRules` holds the rule above as pure Dart, beside
  `MilestoneChest` (`services/chest/`), which is the precedent for app meta
  rules with no interface.
- **The save:** schema 3 adds `loginGift {claims, lastClaim, latestSeen}`.
  - `SaveService.claimLoginGift` checks, writes the claim and credits coins
    and boosters in one update, like `writeDaily`.
- **The state:** `LoginGiftCubit` (a `BaseAsyncCubit`) exposes the track,
  the next day and `canClaim` for today (`AppClock`).
- **Home:** a gift button in the top row, with a dot when a gift is ready.
  It opens a sheet that shows all seven days and a Claim button. There is no
  auto-popup (spec-prop §1: nothing nudges). Q182b.
- **The claim:** coins fly with `RewardFlight`. Day 7 opens with
  `ChestRewardSequence` and the existing chest art, contents shown first.

**Rejected:**
- A restart to Day 1 on a missed day: rule 6, and it is the PEGI 12 case.
- Folding the gift into the Daily: it changes §7.3's numbers, and it is a
  second reward for the same solve.
- A 30-day layer: one cadence first.
- An ad "double it": M6, and not on the kid path.

## Files

| Member | Path | | What |
|---|---|---|---|
| game | `lib/core/services/login_gift/login_gift_rules.dart` | create | Track, next day, `canClaim(today, progress)`, clock guard, the track's parse with its fallback |
| game | `lib/core/services/save/save_document.dart` | modify | `LoginGiftProgress` (freezed), the `loginGift` field, `currentSchema` 3 |
| game | `lib/core/services/save/save_migrations.dart` | modify | Step 2→3 (no data to derive; it records the step) |
| game | `lib/core/services/save/{save_service,hive_save_service,fake_save_service}.dart` | modify | `claimLoginGift(LocalDate today)` → the grant, or null |
| game | `lib/core/services/remote_config/remote_config_keys.dart` (+ the service, fake, defaults) | modify | `RemoteConfigKey<String>` support and `login_gift_track` (rule 6) |
| game | `lib/features/login_gift/{cubit,widgets}/` | create | `LoginGiftCubit` + state, `GiftButton`, `GiftSheet`, `GiftDayTile` |
| game | `lib/features/home/pages/home_page.dart`, `widgets/home_layout.dart` | modify | Places the button (`TODO(design)` until the frames come) |
| game | `lib/l10n/app_*.arb` (×9) | modify | About 8 keys: title, the day label, Claim, the claimed and tomorrow lines, the a11y labels |
| game | `assets/` via `sync_design_assets` | regen | Only if Claude Design sends gift art |
| game | `integration_test/login_gift_test.dart` | create | Scenarios `ready`, `claimed`, `day7`, `clock_back` (`NESTY_FAKE_DATE` + a seeded save) |
| tools | `scripts/nesty-test` | modify | `--only gift` |
| docs | TEST_COVERAGE row, BACKLOG, PROGRESS D/Q, CLAUDE.md Code map, the research lists, a Claude Design prompt | modify / create | — |

`nesty_core` and `nesty_render` are untouched (no board rule).

## Reused code

- `StreakDailyService` / `AppClock` for the local date.
- `SaveService.writeDaily`'s one-update pattern, and `BoosterInventory`.
- `ChestRewardSequence`, `RewardFlight` and `RewardRing` (`features/fx/chest/`).
- `SheetRow`, `StarsChip`'s chip style and `FitText`.
- `stars_gate_nothing_test` as the template for an ethics scan.
- `daily_states_test`'s scenario switch.

## Codegen

In `apps/game`: `flutter gen-l10n`, then `dart run build_runner build`
(freezed, injectable, `di.config.dart`). Then `dart run
nesty_tools:todo_index`. `gen_font_subsets` + `build_fonts.sh` only if the hi
or ja strings add new glyphs.

## Packages

None.

## Verification

- **Host:**
  - `login_gift_rules_test`: cumulative; a gap of 1, 3 or 30 days keeps the
    index; one claim a day; clock back; clock forward then back (the high
    water); the wrap after 7; locked before level 2; a malformed Remote
    Config value falls back.
  - The migration 2→3 test.
  - The cubit's `bloc_test`.
  - The sheet's widget test: all 7 rewards visible before claiming, no
    countdown text.
  - `ethics/login_gift_respect_test`: no ad, purchase or `Random` import; no
    path that lowers `claims`.
- **The gate:** `flutter analyze`, `cd apps/game && flutter test -r
  failures-only`, the overflow suite in nine locales, `cd tools && dart test`.
- **Device:** `tools/scripts/nesty-test --only gift` on the iOS simulator and
  the Android emulator, plus the playthrough's Home shot. The new strings get
  an Opus translation review (D240).

## Risks

- **Two seven-day loops** (the streak chest and the gift) could read as one.
  The copy and art must tell them apart: "Daily gift" vs "Daily puzzle".
- **Clock changes:** winding the clock forward borrows at most one gift per
  date seen, and the high-water mark takes it back in time, not in coins.
  Accepted until M4's server time.
- **Design:** none of the 2.1 / 2.1b frames has a gift button, so this needs
  a Claude Design delivery or a `TODO(design)` stand-in.

## Open questions (Q182, answered 2026-10-05: every default)

- **a. When?** Default: right after M7 closes, before the local habits. Or
  now, inside M7 before 5C (it reopens the 5B translations and the device
  run).
- **b. How does it show?** Default: a button with a dot, no popup. Or the
  genre's sheet on the first Home of each day, dismissible, at most once a
  day.
- **c. The track:** the numbers above. Or coins only.
- **d. The kid path:** default: the same gift for everyone. It takes nothing
  away and never nudges.
