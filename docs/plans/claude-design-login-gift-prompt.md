# Claude Design prompt: the daily gift

Paste everything below the line into the Nesty Claude Design project. It asks
for a new section of App Flow frames (13), a few tokens and the copy for the
daily gift. Nothing else in the export should change. Recorded as PROGRESS
D268 and in BACKLOG "Daily gift". The rule is
[plan-login-gift.md](plan-login-gift.md) §7.5b.

**Superseded for sending (2026-10-05):** its text is Part 1 of
[claude-design-request-m7-5.md](claude-design-request-m7-5.md), the one
message for Wednesday 2026-10-07. Send that instead; this file stays as the
reference. The build starts now with stand-ins (D272).

---

Nesty: Doll Sort. Please design a new feature, the **daily gift**, as a new
section 13 of the App Flow, with its tokens and copy. Please don't change any
existing frame, token or file except to add what is listed here.

**What it is.** Once a day, opening the app lets the player claim one gift
from a 7-day track. All seven gifts are shown in advance:

| Day | Gift |
|---|---|
| 1 | 20 coins |
| 2 | 30 coins |
| 3 | 1 hint |
| 4 | 40 coins |
| 5 | 50 coins |
| 6 | 1 hint |
| 7 | 100 coins + 1 extra slot |

The track counts claims, not dates. A player who skips three days simply
claims the next day on the track; nothing is ever lost. After Day 7 the track
starts again at Day 1. It unlocks with the Daily (after level 2), and is
hidden before that. There is no ad and no purchase anywhere in it.

**It is not the Daily puzzle.** Home already has the Daily Puzzle tile with
its flame streak, its 7-day strip (5.1) and its day-7 chest (5.6). The gift
must read as a different, smaller thing at a glance. Please avoid the flame,
the streak count and the word "streak", and pick a look that won't be
mistaken for the 7-day strip.

**The player respect rules apply** (they shape every frame):
- every gift's contents visible before it is claimed;
- no timer, countdown, "ends in" or "today only";
- no red marks, no broken chain and no "missed" label for skipped days;
- nothing pops up on its own. The player opens the gift when they choose;
- copy is warm and never guilt- or fear-based. No "don't miss", "lose",
  "come back or…", and no urgency.

**Frames we need** (390 × 844, plus the short 16:9 phone where the layout
changes, as 2.1b does):
- **13.1 Home, gift ready.** Frame 2.1 with a gift button that has a gentle
  "ready" mark (a dot, not a number or a red badge). Today's top row is the
  coin pill (+), the wordmark and the gear. Please choose where the button
  sits, here or elsewhere on Home, and show 2.1b too.
- **13.2 Home, gift claimed.** The same button at rest (no mark).
- **13.3 The gift sheet, ready.** A bottom sheet in the house style (34 top
  radius, grabber, sheet title) with the seven days:
  - claimed days marked done;
  - today's day highlighted, with a Claim button;
  - later days showing their gift plainly, not greyed into "locked";
  - Day 7 drawn bigger, with the chest art (`ui/chest/chest_closed.svg`) and
    its two rewards shown on it.
- **13.4 The sheet, claimed today.** Today's day is done. A calm line says
  what tomorrow's gift is (for example "Tomorrow: 1 hint"), with no clock.
- **13.5 The claim.** Coins fly to the coin pill (the existing
  `ui/sprites/coin_flight.svg`, as the chest's flights do), and a hint flies
  with `hint_flight.svg`. Show the moment and the end state.
- **13.6 Day 7.** Claiming Day 7 opens the existing chest sequence (5.6 / 5.6b,
  `ui_chest`) with "100 coins + 1 extra slot" shown before it opens. Say if
  the chest needs a gift-specific title or tint.
- **13.7 A new track.** The sheet the day after Day 7: Day 1 again, with the
  past week's days cleared, and no "reset" or "start over" wording.
- **Reduce motion:** what 13.5 and 13.6 do with motion reduced (the in-app
  three-way setting).

**Art.** A gift glyph for the button: a Material Symbols Rounded glyph (FILL 1,
weight 600, like the rest of `icons`) or a small SVG in `ui/`. Name it in
DELIVERY.md. Reuse `chest_closed` / `chest_open`, `coin_flight` and
`hint_flight`. An extra-slot sprite, if Day 7's slot should fly as well.

**Sound and haptics.** Reuse `coins.ogg` and the chest's `chest_wiggle` /
`chest_open`, unless you think the gift needs its own short sound. If so,
add it to AUDIO.md's contract.

**Tokens.** An additive `gift` block (button, sheet day tile in its four
states: done, today, later and Day 7). Short-phone values go under
`homeShort` if Home changes there.

**Copy** (a new `## Daily gift` section in copy.md, English; the game
translates it into its nine languages):
- the button's screen-reader label, ready and claimed;
- the sheet title ("Daily gift" or better);
- the day label ("Day {n}");
- Claim;
- the claimed-today line and the tomorrow line ("Tomorrow: {gift}");
- the Day 7 chest's title, if it differs from 5.6;
- each tile's screen-reader label (day, gift, done / today / later);
- short forms under `## Short forms` for a German text about 30 % longer.

Please list everything new in DELIVERY.md, as in m7-4.
