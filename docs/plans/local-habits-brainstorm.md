# Local habits: a proposal (after M7, D237)

Date: 2026-10-02. Status: **a proposal for the owner. Nothing is decided and
no code exists.** It answers the owner's ask to keep the app fully local and
to add reasons to open it on ordinary days. The order is D237: close M7,
then whichever of these the owner picks (Q162), then M4, M5, M6 and M8.
[GAME_SPEC.md](../GAME_SPEC.md) is not edited. The respect rules and the
ideas already adopted or rejected are in
[offline-game-brainstorm.md](offline-game-brainstorm.md) (D92); this file
does not repeat them.

## What the app already does

The daily habit is built and offline: one puzzle a day from
`DifficultyCurve.dailyParams` (`seed = yyyymmdd`, spec §7.5), the gentle
streak that pauses instead of resetting (E2), one weekly freeze, the day-7
chest, the opt-in reminder (E4), stars, the Museum and vs Computer. A player
who has solved today has no second local reason to open the app, and nothing
on the home screen shows the puzzle before the app is open.

## What similar games add, and what Nesty should not copy

- A 7-day replay of the same seeded daily, so a solved day is not a dead end
  ([GridJoy's archive](https://gridjoy.app/changelog)).
- A home-screen glance of today's puzzle and the streak
  ([Sudoku Zen's widget](https://apkpure.net/sudoku-zen-daily-offline/com.themightymidgets.sudoku)).
- A short offline daily with a personal calendar of played days
  ([Trio](https://mwm.ai/apps/trio-daily-logic-puzzles/6791609588)).

Left out on purpose: a second daily obligation (a weekly puzzle, a daily
duel, missions), a paid archive, a streak repair, and any red mark or
countdown for a missed day. Those fail brainstorm §5 or are already in
BACKLOG "Later".

## The four proposals

Build them in this order, and only the ones the owner picks. Each one works
with no network.

### 1. Welcome back

If the last day the app was opened is two or more days before today, Home
shows one card: the streak is resting, today's puzzle is ready, and one tap
plays it. The line never says the streak was lost. There is no second card
on the days in between, and no new notification.

- **Reuses:** `AppClock` for today, the Daily route, and the paused-streak
  copy's tone (E2). There is no stored "last opened" date today, so this
  needs one date in the save or in settings, written when the app opens.
- **Core:** no new rule.
- **Ethics:** checklist questions 3, 5 and 6. The card is value-framed, it
  does not punish the gap, and it is not a push. It can be dismissed.

### 2. A month of played days

The Daily's 7-day strip (`day_strip.dart`, frame 5.1) grows into the current
month. A day that was solved is lit. A day that was not is blank. No red
mark, no broken chain, no "missed" label.

- **Reuses:** `DailyProgress` dates already stored for the streak. The strip
  is a widget; the month is the same data drawn further back.
- **Core:** no new rule. The streak rules do not change.
- **Ethics:** question 5. Blank is not a failure.

### 3. The last 7 dailies, playable

Any of the previous seven dates can be generated on the device and played.
The generator already takes the date as the seed
(`DifficultyCurve.dailySeed` / `dailyParams`), so two phones on the same
date still get the same board, with no server and no `dailyOverrides`.

Playing an old day does not move the streak, does not grant or spend a
freeze, and does not pay the daily coins again. It cannot repair a paused
streak and it cannot be farmed. That is the line brainstorm §7 draws against
a streak save.

- **Reuses:** `dailyParams`, the Daily board, the existing win card with
  "Moves N" only (Q88: the daily has no stars and no best-moves line).
- **Core:** no change to `tryMove`. A small app rule for "this solve is an
  archive day", recorded as spec-prop text before any code, because spec
  §7.5 says one puzzle per day.
- **Save:** which archive dates are solved, separate from `daily.done`, so
  today's streak is untouched.
- **Ethics:** questions 1, 2, 3 and 5. No timer, no payment, no effect on
  the streak.

### 4. Home-screen widget, optional and later

Today's puzzle is ready, and the streak count, on the home screen. A tap
opens the Daily. It works offline. It comes after 1–3, because it is a
glance at a habit, not a new mode.

- **Reuses:** the same streak and "solved today" the Daily already shows.
- **Cost:** WidgetKit and AppWidget in the three flavors, plus a package
  with its rule-9 reason in PROGRESS. That cost is why brainstorm §6 left
  it for later. Moved from BACKLOG "Later" by D237; it is still optional.

## Left where they already are

| Idea | Why it stays put |
|---|---|
| Weekly puzzle, daily duel, missions | A second obligation beside the daily (brainstorm §6) |
| Pass-and-play | Already proposed in [pass-and-play-proposal.md](pass-and-play-proposal.md). Two people on one phone, not a daily return |
| Ghost race, favourite family, doll expressions | Mastery or personality, not a reason to open the app tomorrow |
| A paid archive | M6. Gating past days would gate the habit |
| Stars or a best-moves line on the daily | Q88 shipped "Moves N" only |

## Wider concepts

A second pass, still proposals, judged against brainstorm §5. The four above
stay the default. Two extras below are optional and are not part of that
order.

Players come back for a short ritual that is the same for everyone, a record
they are proud of, and a way to tell someone without spoiling the puzzle.

- Wordle and Connections keep a streak, stats, and a share grid. Their
  archives are explicit: playing an old puzzle does not move the streak
  ([Wordle help](https://help.nytimes.com/hc/en-us/articles/24611727334932-Wordle),
  [Connections help](https://help.nytimes.com/360011158491-New-York-Times-Games/28525912587924-Connections)).
  That matches proposal 3.
- The same record, and
  [The Boar](https://theboar.org/2025/04/what-makes-the-new-york-times-games-so-addictive/),
  also shows the harm: a broken streak feels like a loss, and one hard Wordle
  wiped millions of streaks. Nesty already chose the other side (E2: a missed
  day pauses). Do not copy the break.
- [Dayzle](https://dayzlegame.com/) and
  [Puzzle Cottage](https://store.steampowered.com/app/4922130/Puzzle_Cottage/)
  keep one daily, a freeze, a calendar of past days, and offline practice when
  the daily is finished. Nothing counts down.
- [A Little to the Left's daily tidy](https://pupjunkies.com/a-little-to-the-left-calendar-why-the-daily-tidy-is-actually-genius-111)
  adds an archive, long badges, and seasonal looks. Its streak still breaks.
  Take the archive and the seasonal look, not the break.
- Ethical write-ups reject escalating login rewards, expiring collections,
  energy, and mystery chests
  ([Sam Liberty's ETHIC framework](https://sa-liberty.medium.com/the-ethic-framework-designing-ethical-gamification-that-actually-works-50fa57c75610),
  [Game Developer on punishing a break](https://www.gamedeveloper.com/business/ethics-in-the-videogame-industry-a-mythbusting-and-scientific-approach)).
  A welcome with no payout is the safe form of "reward the return."

### Already in the game

One shared daily, the gentle streak, the weekly freeze, the day-7 chest, and
the opt-in reminder. The spoiler-free share text (E3). Stars, replay, best
moves, and Records, including dailies solved, the longest run, and lifetime
badges such as 7 dailies. The Museum, milestone chests with the contents
shown first, vs Computer, Bonus Endless, and relaxed mode.

### Optional extras

- **Today's visitor.** The date picks one of the bundled skins, the same doll
  for every phone that day, drawn on the daily card and named in the share
  line ("The sailor stopped by"). It is a greeting, not a collectible: missing
  the day does not lose a doll. No new rule in `nesty_core`. The art already
  exists.
- **A picture share, still spoiler-free.** Wordle's hook is the grid of
  squares, not the sentence. E3 already shares text. A small local image of
  how many families were nested, with no board, is the same idea in Nesty's
  art. No server.

### Already parked

- A calendar of past days and a 7-day replay: proposals 2 and 3. The NYT rule
  (an archive does not touch the streak) is already how proposal 3 is written.
- A home-screen glance: proposal 4.
  [Sudoku Zen](https://apkpure.net/sudoku-zen-daily-offline/com.themightymidgets.sudoku)
  agrees.
- Welcome back with no coins: proposal 1. A coin for returning would be a
  login bonus, which is the pattern the ethics pieces warn about.
- Sofa play with a running score: the pass-and-play proposal. Puzzle Cottage
  keeps a head-to-head on one machine. That is a line to add there if it is
  built, not a fifth daily habit.
- A seasonal look on the daily card (leaves, snow) with no expiring reward:
  later, because it needs art. An expiring seasonal collection is a treadmill
  and stays out.
- A longer once-a-month board: the weekly puzzle already deferred in
  brainstorm §6. One more obligation.

### Out

- Five puzzles that all count toward one streak (Dayzle). The campaign and
  Bonus Endless are already the "one more."
- A streak that breaks, a streak repair, or a red missed day.
- Lives, energy, timers, mystery chests, escalating login calendars that
  restart after a missed day (D268 adopts a cumulative daily gift instead:
  [plan-login-gift.md](plan-login-gift.md)), and
  "today only" skins.
- World leaderboards. They need a server, and a ranking pushes speed, which
  brainstorm §7 already rejected.

## Open question

Q162. Which of the four to build, if any, and in which order? The default
recorded here is 1, then 2, then 3, and 4 only after those. Today's visitor
and the picture share are optional and are not part of that default. None of
them starts until M7 is closed and the owner answers.
