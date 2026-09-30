# Star rating: 1 to 3 stars per level (M7, D125)

**Status:** requested by the owner on 2026-09-28, with the rules chosen from
four options the same day (D125). This reverses D92's "stars and par are not
in M7". The rule text is spec-proposals-m7.md §7.10, which counts as spec
until the owner pastes it into GAME_SPEC.md (Q85). The numbers are defaults
behind Remote Config keys (rule 6). The smaller defaults below are Q116–Q120
in [PROGRESS.md](../PROGRESS.md). Art, motion, sound and copy are section K of
[claude-design-request-m7.md](claude-design-request-m7.md). Stand-ins ship
until they land. Work items: BACKLOG "M7" → "Star rating".

**Built and integrated (2026-09-29, M7 phase 3, m7-design P3.1–P3.15,
D144–D161):** the rule in core with par in the bundle (par 2–35 on the 200
levels), the schema-2 save fields and the backfill, the bloc's stars and
the assisted cap, the stand-in `StarRow` on the win card, Chapters and
Records, E1's tests and `report --stars`. Left: the device run of the
playthrough's star steps, the owner's slack tuning from `report --stars`,
and Claude Design's section K through the swap points below.

## The feature in one line

Every win of levels 1–200 (or a replay of one) earns 1, 2 or 3 stars. Fewer
moves earn more stars, 3 is the most, and a level keeps its best.

## The owner's choices (2026-09-28)

| Question | Choice |
|---|---|
| How a win earns stars | Moves against par, with slack: 3★ within par + 20 %, 2★ within par + 60 %, 1★ for any win |
| Hints and +1 Slot | A win that used either gets at most 2★. Undo and Restart never affect stars |
| Where stars appear | Levels 1–200 and their replays: the win card, Chapters and Records. The daily, Bonus Endless and race boards show moves only (like best moves, Q88) |
| Anything beyond the grade | Nothing. Stars never pay, unlock or gate anything, and nothing about them shows during play |

## Rules (spec-prop §7.10)

1. **Par** is the fewest moves that solve the level from its start. It is
   the solver's optimal solution: A* with a consistent heuristic (spec §6.3)
   finds the true minimum. `nesty_levels bundle build` computes it with the
   admin budget and writes it into each bundle entry, and `bundle check`
   recomputes it and fails on a mismatch. The level JSON doesn't change, so
   no level version moves (L1–L30 stay byte-identical).
2. **Moves** are the winning attempt's moves as the game already counts
   them (`GameState.moveCount`): undo takes a move back, and Restart starts
   again from 0 (spec §2.4). The win card's "Moves 18" is the same number.
3. **Thresholds.** `t3 = par + ⌈par × star3_slack_pct / 100⌉` and
   `t2 = par + ⌈par × star2_slack_pct / 100⌉`, with defaults 20 and 60. A win
   with moves ≤ t3 earns 3★, one with moves ≤ t2 earns 2★, and any other win
   earns 1★.

   | Par | 3★ at or under | 2★ at or under |
   |---|---|---|
   | 8 | 10 | 13 |
   | 12 | 15 | 20 |
   | 20 | 24 | 32 |
   | 30 | 36 | 48 |
4. **Assists cap at 2★.** A win gets at most 2★ if it used a hint during the
   winning attempt, or if an extra slot was on the board when it won (default
   Q116). 3★ is always the player's own solve, so coins and ads can't buy
   it. Undo, Restart and relaxed mode never lower stars.
5. **Best stars.** A level keeps the most stars it has ever earned. A replay
   can raise them, and nothing lowers them: not a worse replay, a new level
   version (default Q117) or a Remote Config change.
6. **Cosmetic.** Stars pay nothing and unlock nothing. They never gate a
   level, a chapter, a rival or a reward, and they never show during play.
   There is no live meter: the brainstorm rejected a move counter during
   play (brainstorm §7).
7. **Where they show.** The win card of a campaign level or a replay shows
   that win's stars. Chapters shows each won level's best stars and each
   chapter's total. Records shows the total and the levels at 3★. Daily,
   Bonus Endless and race boards show moves only.

## Keeping a 1★ win a win

The brainstorm set stars aside because "stars make a win feel like a 1-star
failure" (brainstorm §6). These rules answer that:
- **Every win earns at least 1★.** The win card celebrates any win the same
  way: ribbon, coins and confetti. The stars sit inside the celebration and
  never replace it.
- **The slack is generous.** 3★ allows 20 % over the perfect solve.
  Before release, the levels tool reports what share of the smart and casual
  bots' wins would get each star count per chapter, so the owner can tune
  the two keys.
- **No dimmed "missing" stars in grey or red.** Empty stars are soft
  outlines in the card's own colours (design request K).
- **Copy stays positive.** No copy ever says "only", "missed", "failed" or
  "try again". The 3★ target ("3 stars at 15 moves or fewer") shows only
  on a replay's win card, never on a level's first win (default Q118).
- **One tip, once.** The first time a win earns fewer than 3★, the card
  explains how stars work: "Fewer moves earn more stars. Replay any level
  from Chapters." (default Q119).
- **Stars never go down.**

## What changes where

**`nesty_core` (rule 2: the rule lives here):**
- `lib/src/rules/star_rating.dart`: `StarRating.maxStars`,
  `StarRating.threshold(par, slackPct)` and `StarRating.starsFor({moves, par,
  assisted, star3SlackPct, star2SlackPct})`, exported from the barrel.
- `codec/level_bundle.dart`: `LevelBundleEntry.par` (int, read leniently;
  absent means no stars for that entry).
- Tests: `test/rules/star_rating_test.dart` (the threshold table, the cap,
  bounds, par 1), the codec round trip, the web parity.

**`tools` (the levels CLI):**
- `bundle build` writes `par` from `Solver` (admin budget).
- `bundle check` recomputes it and fails on a mismatch.
- A `report` line gives the bots' star shares per chapter.
- `tools/levels/README.md`.
- Then `apps/game/assets/levels/bundle.json` is rebuilt: only the entries
  change, never a level's data or version.

**`apps/game`:**
- **Remote Config:** `star3_slack_pct` (20) and `star2_slack_pct` (60) in
  `remote_config_keys.dart`.
- **Levels:** `PlayEntry.par` from the bundled entry. It is null for the
  daily, bonus and race.
- **Save:**
  - a new `levelStars` map (`{"L0024": 3}`), per level id, keeping the
    highest;
  - `LevelWinRecord.stars`, and `LevelWinOutcome.stars` / `previousStars`;
  - `RecordsSummary.stars` and `threeStarLevels`.

  Schema 2 hasn't shipped to players, so `levelStars` joins schema 2's one
  migration (plan-m7 "Rejected": players migrate once), and the codec reads
  it leniently. A load-time backfill fills it for wins that happened before
  it existed (default Q120):
  - a level with a best (`levelBests`) gets the stars its best earns, as if
    no hint was used;
  - any other won level gets 1★.

  Like the load-time badges (m7 §12), the backfill is derived, silent and
  idempotent.
- **Gameplay bloc:**
  - the attempt's `assisted` flag: a hint used since the last restart, or
    an extra slot on the board;
  - at the win, `StarRating.starsFor(...)` with the Remote Config slack;
  - `GameplayState.stars`, `previousStars` and `starTarget` (t3, for the
    replay card);
  - `recordLevelWin` gets the stars.

  Replay counts (it can raise best stars); daily, bonus and race compute
  none.
- **UI (stand-ins until K lands):**
  - `core/ui/widgets/stars/star_row.dart`: `StarRow(count, size)` and
    `StarRow.reveal(count)`, the single place the art and motion swap in;
  - the win card, above the moves line: stars pop in one by one with a
    pitched sound and a light haptic each, plus the 3★ flourish (reuse
    `fx_twinkle`); under reduce motion they appear at once;
  - Chapters: three small stars under each won cell, and the chapter's
    total on its card and on its folded row;
  - Records: rows "Stars" (N of 600) and "Levels with 3 stars";
  - the replay card's target line, and the one-time tip.

  Every new string goes through ARB (below).
- **E1:**
  - `respect_copy_test.dart` checks the star keys against the deny-list
    ("only", "missed", "failed" and the rest);
  - a test that no unlock, reward or gate reads `levelStars`;
  - `reward_randomness_test.dart` scans the new paths.

## ARB keys (stand-in copy; copy.md G.11 replaces the English)

| Key | Stand-in English | Where |
|---|---|---|
| `starsSemantics(count)` | "{count} of 3 stars" (ICU plural) | every `StarRow` |
| `winStarsTarget(moves)` | "3 stars at {moves} moves or fewer" | the replay card, below 3★ |
| `winStarsNewBest` | "New best!" | a replay that raises the stars |
| `starsFirstTip` | "Fewer moves earn more stars. Replay any level from Chapters." | the first win below 3★, once |
| `chaptersStarsTotal(earned, total)` | "{earned}/{total}" | the chapter card and folded row |
| `chaptersStarsSemantics(earned, total)` | "{earned} of {total} stars" | semantics |
| `recordsStars` | "Stars" | Records row |
| `recordsThreeStarLevels` | "Levels with 3 stars" | Records row |

## When Claude Design delivers section K

Each piece has one place to swap in:

| Delivery | Tool | Swap point |
|---|---|---|
| Star art: filled, empty, and optionally the 3★ glow (SVG) | `sync_design_assets` (add the folder to its mapping) | `StarRow` switches from the `NestyIcons.star` stand-in to the SVGs |
| Star colours, sizes and motion in `tokens.json` | `gen_design_tokens` | `AppColorTokens.star*` and the motion tokens, used by `StarRow` and the win card |
| Lottie `ui_stars` (markers `star_1`, `star_2`, `star_3`, `flourish`) | LOTTIE.md table plus `gen_fx_spec` | `FxId.uiStars` on the win card; the stand-in tween stays as the fallback |
| SFX `star_1`–`star_3` (WAV) | AUDIO.md plus the SFX sync | `SfxId.star1..3` replace the pitched stand-in |
| copy.md G.11 | the ARB file | the eight keys above keep their names; only the values and descriptions change |
| Frames 11.1–11.5 | the fidelity pass (`ui-designer`) | the win card, Chapters and Records layouts |

## Tests

- **Core:**
  - the threshold table (par 1, 8, 12, 20, 30 and 60 at the default slack,
    and at 0 % and 100 %);
  - moves exactly at t3 and t2, and one above;
  - the cap;
  - input validation;
  - the codec's `par` round trip and its lenient read;
  - node parity.
- **Tools:**
  - `bundle build` writes the solver's optimal length;
  - `bundle check` fails when an entry's `par` is edited;
  - every one of the 200 levels has a par;
  - L1–L30's level data is unchanged.
- **Save:**
  - best stars keep the highest across wins, replays and a new version;
  - the backfill: from best moves, 1★ without a best, idempotent, silent;
  - the Hive round trip;
  - the lenient read.
- **Bloc:**
  - 3★, 2★ and 1★ wins;
  - a hint then a win caps at 2★, but a hint then Restart then a win doesn't;
  - +1 Slot caps, including after Restart;
  - relaxed undo never caps;
  - replay raises the stars;
  - daily, bonus and race have none.
- **Widgets:**
  - the win card at 1, 2 and 3★;
  - a replay's new best;
  - the target line only on replay;
  - the one-time tip shows once;
  - reduce motion shows the stars at once;
  - semantics;
  - Chapters' stars and totals;
  - Records rows;
  - overflow at the 5 sizes × 1.0 and 1.3.
- **Integration:**
  - the playthrough's L1 win shows its stars (the tutorial path is optimal,
    so 3★);
  - a replay that wins with more moves keeps the best;
  - screenshots of the win card and Chapters.

## Ethics checklist (brainstorm §5)

1. **Every level winnable without an ad, a purchase or a booster?** Yes.
   Stars gate nothing. 3★ is reachable without boosters, because par is the
   solver's own booster-free solution, and a booster can never help reach 3★.
2. **Rewards shown in advance, deterministic, no paid randomness?** Stars
   aren't a reward: they pay nothing. They are a deterministic function of
   moves and par.
3. **No timer, countdown, scarcity or fail-triggered offer?** None. Time
   plays no part, and a low-star win never shows an offer.
4. **Every computer rival labelled?** Not applicable: races have no stars.
5. **Nothing punishes absence or shames a loss?** A 1★ win celebrates like
   any win, stars never drop, and the copy is checked by the E1 deny-list.
6. **Prompts off by default and switchable?** There are no prompts. The
   one-time tip is information, shown once (Q119).

## When it's built

In M7 phase 3, as its own track beside the share card and the reminder:
- **Contracts:** the core rule and the codec's `par`, the Remote Config
  keys, `levelStars`, the state fields, the ARB keys, and `StarRow`'s
  signature.
- **Lanes:**
  - `stars-core` (nesty-core-engineer: core);
  - `stars-levels` (tools and the bundle rebuild);
  - `stars-services` (save, records, backfill);
  - `stars-bloc` (the gameplay bloc);
  - `stars-ui` (the win card, Chapters, Records, overflow).
- **The integrator:** the gates, the playthrough's star checks and the docs.

Phase 2 (vs Computer) is already planned, and its core is built, so stars
don't join it. The share card and the reminder touch other files, except
the daily win card, which the phase-3 contracts give one owner.

## Questions (each ships its default)

- **Q116.** Which assists cap a win at 2★: a hint used since the last
  Restart, or an extra slot on the board at the win (extra slots survive
  undo and restart, D22)? Default: yes, both.
- **Q117.** Best stars are kept per level id, so a new level version (M4
  content) keeps them. Best moves stay per version (D102). Default: yes.
- **Q118.** The 3★ target ("3 stars at 15 moves or fewer") shows only on a
  replay's win card below 3★, never on a first win? Default: yes.
- **Q119.** A one-time tip on the first win below 3★ explains stars and
  points to Chapters? Default: yes, once.
- **Q120.** Levels won before stars existed: the stars their best moves earn
  (as if no hint was used), or 1★ where there is no best? Default: yes.
