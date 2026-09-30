# vs Computer: the race (M7, D93)

**Status:** approved in principle by the owner on 2026-09-28 (D93). The
numbers are defaults behind Remote Config keys; Q77–Q80 in
[PROGRESS.md](../PROGRESS.md) are the owner's to change. The spec text is in
[spec-proposals-m7.md](spec-proposals-m7.md) §7.7. Until the owner pastes it
into GAME_SPEC.md, the approved text there is the rule. Research and
reasoning: [offline-game-brainstorm.md](offline-game-brainstorm.md) §1 and §3.

## The mode in one line

You and a computer rival solve identical copies of the same puzzle at the same
time. Whoever completes every family first wins.

## Rules

1. **Entry.** A vs Computer tile on Home, locked until Level 20 is won
   (`race_unlock_level`, default 20, Q78). Before that, the tile shows its
   lock and "After Level 20".
2. **Rivals.** Three rivals, unlocked in turn: the first win against one
   unlocks the next. Each is a character from Claude Design (a name, a
   portrait, a one-line personality; copy.md). They are always labelled
   **Computer** (rule 11).
   | Rival | Plays like | Pace (s per move, default) | Board tier (default) | Win pays (default) |
   |---|---|---|---|---|
   | 1 | spec §6.4 casual bot | 3.0 (`race_pace_ms_1`) | easy | 20 (`race_reward_1`) |
   | 2 | spec §6.4 smart bot | 2.4 (`race_pace_ms_2`) | medium | 30 (`race_reward_2`) |
   | 3 | spec §6.4 smart bot | 1.6 (`race_pace_ms_3`) | medium | 40 (`race_reward_3`) |

   Only the two bots of spec §6.4 exist. No new bot policy is added (D93).
   Difficulty comes from the policy, the pace and the board.
3. **The board.** One board per race, made by the generator with the
   difficulty curve's params for the rival's tier. The stage is the one the
   player's highest level has reached, so a race only uses mechanics the
   player has met (§3.7).
   - The seed is `3_000_000 + rival × 100_000 + raceNo`. It can't collide with
     the daily (yyyymmdd) or bonus seeds (1_000_000 + N).
   - `raceNo` counts that rival's races from 1.
   - Both sides start from identical copies.
4. **Start.** The race board shows both sides at rest. The race starts when
   the player taps Start, with no countdown.
5. **The player's moves** follow §2 and §4 as in any level:
   - Undo and Restart are free and unlimited. Hint and +1 Slot are off, so no
     race can be won with coins or ads (spec §1 respect rules).
   - The soft-stuck banner still shows. Out of moves offers Undo and Restart
     only.
6. **The rival's moves.** The rival plays its bot's policy (§6.4), one move
   per pace interval.
   - Each interval varies by up to ±20 % (`race_pace_jitter_pct`), drawn from
     the race's own seeded PRNG.
   - Between moves the rival strip shows a "thinking" state. Its moves animate
     on the strip.
7. **The rival's restart.** When the rival's run can't be won, it restarts
   from the start with its next run seed, and the strip says "Starting over".
   A run can't be won when the board has no useful move, or when it reaches
   §6.4's 250-move cap.
8. **Winning.** The first side to complete every family wins. If the player's
   last completion and the rival's land on the same frame, the player wins:
   player input is handled first.
9. **Pausing** stops the rival's clock: the Pause button, the app going to the
   background, or any sheet or overlay. Resuming continues the race exactly
   where it was.
10. **Results.**
    - **A win** pays the rival's reward (rule 2). It shows "You win!" (9.4),
      and the first win against rival 1 or 2 also shows "rival unlocked"
      (9.6).
    - **A loss** shows "The computer finished first" (9.5), costs nothing and
      takes nothing.
    - **After either,** Rematch replays the same board against the same rival.
      Its runs are deterministic, so it plays the same moves again, and the
      player can learn to beat it. New race moves to the next `raceNo`.
      No streak, and no loss count shown anywhere.
11. **Labelling (non-negotiable, spec §1 respect rules).**
    - Every rival shows the word **Computer** and a computer glyph wherever it
      appears: the select screen, the race strip, the results and Records.
    - Never a human avatar, an "online" status, a typing indicator or chat.
12. **Saving.** A race is never resumed: killing the app or quitting from
    Pause ends it with no reward and no penalty. The save keeps, per rival:
    - unlocked;
    - wins;
    - `raceNo`.

    That's a schema step with a migration (`SaveMigrations`).
13. **Records** (E8) show races won per rival. A badge marks the first win
    against each rival.

## What core does and what the app does

- **nesty_core (rule 2, rule 7):**
  - a public, seeded, step-by-step rival API: `RivalBot` (working name)
    reusing `BotPlayer` from `packages/nesty_core/lib/src/simulator/bots.dart`,
    which is internal today;
  - the run-end and restart rule;
  - the race board params (a `DifficultyCurve` entry for a stage and a tier);
  - the race seed formula.
  - The rival's moves are a pure function of the board, the policy and the
    run seed. Core never reads the clock.
  - Changing the bots or the curve still needs a `Generator.version` bump
    (§6.5). The race API adds no policy, so none is needed.
- **The app:**
  - a `RaceBloc` or cubit that owns the clock (pace, jitter from the race
    PRNG, pause) and the result;
  - the rival strip, and the Home tile, select, race, pause and result
    screens;
  - the save fields and the Remote Config keys with their defaults (rule 6);
  - the audio: `jingle_versus_win`, `jingle_versus_lose` and `rival_complete`
    when Claude Design delivers them.
  - A bot move costs microseconds. Where it runs (the UI isolate between
    frames, or the solver's isolate) is decided in the build plan. Either way
    it allocates nothing per move (rule 8).

## Tests

- **Core:**
  - the same seed gives the same rival moves;
  - the rival never plays an illegal move;
  - the restart rule fires on a dead board and at the cap;
  - the race board params only use the mechanics of the stage;
  - the seed formula doesn't collide.
- **Bloc** (a fake clock):
  - the pace and jitter;
  - pause stops the rival;
  - win and loss;
  - the reward is paid once;
  - unlocks happen in order;
  - Rematch replays the same moves;
  - a kill leaves no reward.
- **Widget:** "Computer" is on every rival surface. Hint and +1 Slot are
  absent in a race. The tile is locked before Level 20.
- **Integration:** a playthrough segment that wins against rival 1, with the
  player playing the solver's solution and the rival's pace slowed through a
  debug define.

## What Claude Design draws

This is section C of [claude-design-request-m7.md](claude-design-request-m7.md):
- 9.1 the Home tile, locked and unlocked;
- 9.2 rival select, with three rivals in their locked and unlocked states;
- 9.3 the race board with the rival strip: families counter or mini board,
  "thinking", "Starting over", at 390×844 and on a short 16:9 screen;
- 9.4 you win, 9.5 the computer wins, 9.6 rival unlocked;
- the Pause dialog in a race;
- optional rival reaction Lottie;
- the two jingles and the SFX;
- the copy: rival names, personalities and the result lines.

## Alternatives the owner didn't pick (kept for later)

- **A ghost race:** race a labelled replay of your own best run or the
  solver's. It's cheaper, and a possible extra later.
- **Alternating turns on one board:** a family scores for whoever completes
  it. This is rejected against the computer (turn pressure), but it's the
  basis of the hot-seat proposal for two people on one device (D90).
- **A third, stronger bot policy:** declined for now (D93). It would need spec
  text, core work and a `Generator.version` bump.
