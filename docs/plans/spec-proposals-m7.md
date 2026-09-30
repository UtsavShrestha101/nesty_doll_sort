# Spec text proposed for GAME_SPEC.md (M7, D92–D93, D125)

The owner approved these rules in principle on 2026-09-28 (D92, D93 in
[PROGRESS.md](../PROGRESS.md)), and the star rating (§7.10) the same day
(D125). Claude never edits GAME_SPEC.md (CLAUDE.md), so
each block below says where it goes and is written to be pasted as is. Until
the owner pastes it, the text here, as approved in D92 and D93, is the rule for
these features (Q85). Numbers are defaults behind Remote Config keys (§9.4
block below), and the owner can change them (Q76–Q87).

Why each rule exists: [offline-game-brainstorm.md](offline-game-brainstorm.md).
vs Computer in full: [mode-vs-computer.md](mode-vs-computer.md). The star
rating in full: [star-rating.md](star-rating.md).

---

## §1 Target players: add after the "Tone" bullet

```markdown
- Engagement features are designed as if children may play, whatever the store rating: non-essential notifications are off until the player opts in, copy is warm and never guilt- or fear-based, and nothing nudges a player to keep playing.

### 1.1 Player respect rules
These hold for every feature, including monetization (§9):
1. Every level can be won from its start with no booster, ad or purchase (§5.3 rule 8 proves it). Boosters only save time.
2. No paid or unpaid randomness in rewards: no loot boxes, gacha or mystery chests. Every reward shows its contents before it opens.
3. No lives or energy, no timers in normal levels (§1), no countdown or limited-time offers and no scarcity framing.
4. No offer is ever shown because the player failed, got stuck or is about to lose a streak. A streak can't be bought back.
5. A computer opponent is always labelled a computer, everywhere it appears. Never a human avatar, an "online" status or chat.
6. A missed day never takes away anything earned (§7.5).
7. Notifications are local, opt-in, value-framed and at most one a day (§7.9).
```

## §7.1 Levels and chapters: add at the end

```markdown
- **Replay:** the chapter list shows every chapter's 20 levels. A won level can be played again at any time. A replay pays no coins, doesn't move `currentLevel`, doesn't count towards the milestone chest or the museum and has no interstitial.
- **Best moves:** every win (first play or replay) records the fewest moves for that level id and version. The win card shows "Moves 18 · Best 16". The move count is never shown during play.
```

## §7.3 Coins: add rows to the "Source" table

```markdown
| Milestone chest (level 10 of each chapter, and every 10th bonus level) | `chest_coins` (100) plus `chest_hints` (1) hint |
| vs Computer win (§7.7) | `race_reward_1/2/3` (20 / 30 / 40) by rival |
```

And add under the tables:

```markdown
The milestone chest is fixed and shown before it opens: the win card shows how many levels remain to it. It opens once per level number and never on a replay.
```

## §7.5 Daily puzzle: replace the last two sentences

Replace "The streak calendar shows 7 days. Missing a day resets the streak, but one 'streak freeze' is earned each week." with:

```markdown
The streak calendar shows 7 days. The streak counts the days the daily was solved, and a missed day never lowers it. A missed day covered by a streak freeze keeps the flame lit. A missed day with no freeze puts the flame out ("paused") until the next solve relights it and adds one. One freeze is earned each week (hold at most one). The chest opens on every 7th streak day. The longest unbroken run is kept in Records (§7.8). After the daily, the player can share a spoiler-free result (§10.2).
```

## §7.7 vs Computer (new section)

```markdown
### 7.7 vs Computer
A race: the player and a computer rival solve identical copies of one puzzle at the same time, and whoever completes every family first wins.
- **Unlock:** after winning level `race_unlock_level` (20). Three rivals unlock in turn: the first win against one unlocks the next.
- **Rivals:** rival 1 plays like the casual bot (§6.4) at `race_pace_ms_1` (3000 ms) per move on an easy board; rival 2 like the smart bot at `race_pace_ms_2` (2400) on a medium board; rival 3 like the smart bot at `race_pace_ms_3` (1600) on a medium board. Each interval varies by up to `race_pace_jitter_pct` (20 %) from the race's seeded PRNG. No other bot policy is used.
- **Board:** made by the generator from the curve's params for the rival's tier, at the stage of the player's highest level, with seed `3_000_000 + rival × 100_000 + raceNo`. Both sides start from the same board.
- **Player:** the normal rules (§2, §4). Undo and restart are free and unlimited. Hint and extra slot are off.
- **Rival:** makes one move per interval. When its run can't be won (no useful move, or the 250-move cap of §6.4), it restarts from the start with its next run seed.
- **Result:** the first side to complete every family wins; on the same frame the player wins. A win pays the rival's `race_reward_n`. A loss costs nothing. Rematch replays the same board and the same rival moves; New race uses the next `raceNo`.
- **Pause:** pausing, a sheet or the app going to the background stops the rival too.
- **Save:** per rival, unlocked, wins and `raceNo`. A race in progress is never resumed: leaving it ends it with no reward.
- The rival is always labelled a computer (§1.1).
```

## §7.8 Records and badges (new section)

```markdown
### 7.8 Records and badges
The Records screen shows: levels won, families completed, dolls nested, dailies solved, the longest unbroken streak, races won per rival, best moves per level, and the stars earned (§7.10). Badges are cosmetic, pay no coins and have fixed triggers counted over the player's lifetime, never over consecutive days (for example: first family, first glass case opened, 7 dailies solved, first race won, every rival beaten, level 100 won, every figurine). The list of about 12 badges is kept in `docs/plans/offline-game-brainstorm.md` until it's final.
```

## §7.9 Daily reminder (new section)

```markdown
### 7.9 Daily reminder
One optional local notification a day ("Today's puzzle is ready"). It is offered once, after the player's first solved daily, and is off until the player accepts. The player picks the time (default: the hour they solved that first daily). It never mentions losing a streak, never shows a badge count and is turned off or re-timed in Settings. No network is involved.
```

## §7.10 Star rating (new section, D125)

```markdown
### 7.10 Star rating
Every win of a campaign level (§7.1), first play or replay, earns 1, 2 or 3 stars. 3 is the most.
- **Par** is the fewest moves that solve the level from its start, the solver's optimal solution (§6.3). It is computed when the level bundle is built, and checked with it.
- **Moves** are the winning attempt's moves as the game counts them: undo takes a move back, and restart starts again from 0 (§2.4).
- **3 stars:** moves ≤ par + ⌈par × `star3_slack_pct` ÷ 100⌉ (20). **2 stars:** moves ≤ par + ⌈par × `star2_slack_pct` ÷ 100⌉ (60). Any other win earns **1 star**. For par 12: 3 stars at 15 moves or fewer, 2 stars at 20 or fewer.
- A win that used a hint, or has an extra slot on the board, earns at most 2 stars, so stars can't be bought. Undo, restart and relaxed mode never lower stars.
- Each level keeps its best stars. A replay can raise them, and nothing lowers them.
- Stars are cosmetic. They never pay, unlock or gate anything, and nothing about them shows during play. Daily, Bonus Endless and race boards show moves only.
```

## §8 Boosters: add under the table

```markdown
**Relaxed mode** (Settings, off by default): undo is free and unlimited, with no price and no ad row. Everything else, including coin rewards, is unchanged.
```

And in §19 remove "a 'relaxed mode' with unlimited undo".

## §9.4 Remote Config keys: add

```
chest_coins / chest_hints                   100 / 1
race_unlock_level                           20
race_pace_ms_1 / _2 / _3                    3000 / 2400 / 1600
race_pace_jitter_pct                        20
race_reward_1 / _2 / _3                     20 / 30 / 40
star3_slack_pct / star2_slack_pct           20 / 60
```

## §10.1 Flow: replace the first line and extend Home

```
Splash/loading → (first launch: consent) → Level 1 (first launch only; Home after the first win) or Home
Home → Daily · Museum · Shop · Settings · vs Computer · Chapters · Records
```

## §10.2 Screen list: add

```markdown
4. **Win** (addition): the win's stars on a campaign level or a replay (§7.10), "Moves 18 · Best 16", and the milestone chest's progress when it is the nearer goal.
11. **Daily** (addition): after solving, a Share button (a spoiler-free text through the OS share sheet), and the one-time reminder offer (§7.9).
13. **Settings** (addition): relaxed mode (§8), daily reminder and its time (§7.9), reduce motion (§16).
17. **vs Computer:** the Home tile, rival select, the race board with the rival strip, and the win, loss and rival-unlocked results (§7.7).
18. **Chapters:** each chapter's 20 levels with won marks, best moves and best stars, and each chapter's star total; tap a won level to replay (§7.1, §7.10).
19. **Records:** records, the stars earned and badges (§7.8).
20. **Milestone chest:** its contents and an open button, in the day-7 chest's style.
```

## §13.3 Save data: add to the document

```json
"levelBests": {"L0024@2": 16},
"levelStars": {"L0024": 3},
"records": {"families": 212, "dolls": 780, "dailies": 12, "longestRun": 9, "badges": ["first_family", "chapter_1"]},
"daily": {"streak": 4, "lit": true, "lastDate": "2026-09-24", "freezes": 1, "done": ["2026-09-24"]},
"chests": {"opened": [10, 30]},
"race": {"rivals": [{"unlocked": true, "wins": 3, "raceNo": 5}, {"unlocked": true, "wins": 0, "raceNo": 1}, {"unlocked": false, "wins": 0, "raceNo": 0}]},
"settings": {"...": "...", "relaxed": false, "reminder": {"on": false, "hour": 19, "minute": 0, "offered": true}, "reduceMotion": "system"}
```

(The game keeps `settings` in its own Hive box, a recorded deviation, m3-design §3.1.)

## §16 Accessibility: extend the reduced-motion sentence

```markdown
Support reduced motion (shorter animations, no screen shake): follow the system setting, with a Settings override (on, off, system). Sounds and haptics keep their strength.
```

## §18 M7: extend the acceptance line (owner's choice)

```markdown
✅ Matches the design screens. There are no layout overflows on 5 test screen sizes. Levels 1–200 are bundled, valid, solvable and on the §3.7 and §6.6 schedule. vs Computer (§7.7), Records (§7.8), the reminder (§7.9), star ratings (§7.10), relaxed mode, replay and the gentle streak work fully offline.
```
