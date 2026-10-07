# Claude Design request: nesty-design-m7-6

One message for the Nesty Claude Design project, for its next round. It has
two parts:
- **Part 1:** the four local habits (D274) as a new App Flow section 14. The
  build starts on `TODO(design)` stand-ins
  ([local-habits-claude-code-prompt.md](local-habits-claude-code-prompt.md)).
- **Part 2:** every design question m7-5 left open: the m7-5 follow-ups in
  BACKLOG "M7" and the `TODO(design)` markers no delivery has answered
  (checked 2026-10-08).

When the delivery comes, import it through the checks in BACKLOG M7
"Importing a Claude Design delivery", the m7-5 way (D281–D296).

Paste everything below the line.

---

Nesty: Doll Sort. Thank you for m7-5: the daily gift is in the game exactly
as section 13 draws it, in all nine languages, and Turkish titles now use
your Baloo 2 build. This round has two parts:
- **Part 1** is a new section 14, the local habits: four small reasons to
  open the app on an ordinary day, all fully offline.
- **Part 2** is the design questions m7-5 left open.

Please deliver both as **`nesty-design-m7-6`**, cumulative and in m7-5's
format: the whole handoff root, with `tokens.json`, `README.md`,
`LOTTIE.md`, `AUDIO.md`, `copy.md` and the App Flow file whole. In
DELIVERY.md, list only what changed, and put each "keep" under "Choices".
None of this changes a game rule: prices, rewards, limits and unlocks stay
as the game has them. A partial delivery is fine. 14.1 to 14.3 unblock the
most; the widget (14.4) is built last.

## Part 1: the local habits (new section 14)

Please don't change any existing frame, token or file except to add what is
listed here. Frames are 390 × 844, plus the short 16:9 phone (390 × 693)
wherever the layout changes, as 2.1b and 13.1b do. Each one needs a reduce
motion note.

**The player respect rules apply to all four** (they shape every frame):
- nothing pops up on its own, and there is no new notification;
- no timer, countdown, "expires", "last chance" or "today only";
- no red marks, no X, no broken chain and no "missed" or "lost" for a day
  not played; blank is not a failure;
- an old day never repairs or moves the streak;
- no ad, no purchase and no coin offer anywhere in these paths;
- the copy is warm and never guilt- or fear-based.

### 14.1 Welcome back (Home)

When the player opens the app after two or more days away (and the Daily is
unlocked and today's puzzle isn't solved), Home shows **one** card. It says,
warmly, that the streak is resting and today's puzzle is ready, and one tap
plays today's daily. It never says the streak was lost. It can be dismissed,
and it is gone once today is solved or the next day comes.

- **Where it sits.** Home has no free slot today. Its stack is the top row
  (coin pill, wordmark, gift button, gear), the chapter card with Records,
  the plank with the dolls, Play, and the tiles row. Please place the card on
  2.1 and on 2.1b, and say what moves. It is an inline card, not a modal or a
  sheet.
- **Three variants:**
  - **14.1a, a freeze kept the flame:** like 5.2, "A freeze kept your flame
    lit."
  - **14.1b, paused:** like 5.2b, the number kept and the flame unlit.
  - **14.1c, no streak yet.**
- **With the gift.** Show 14.1 together with the gift button's ready dot
  (13.1): both appear after a gap.
- **Its parts:** the dismiss control (a 48 dp target) and its screen-reader
  label; the card's entrance, and the card with motion reduced.

### 14.2 A month of played days (Daily)

The Daily (5.1) adds the current month as a calendar:
- a day the daily was solved on its own date is **lit**;
- a day solved later from 14.3 has a quieter **"played later"** mark;
- a day not played is **blank** (no red, no X, no "missed");
- today is marked, and future days are plain.

- **Keep the 7-day strip.** It is the streak's cycle toward the day-7 chest,
  not calendar days, so it stays. Please decide where the month lives:
  under the puzzle card, as a card that opens from the strip, or another way.
  Show it on 5.1 and on the 16:9 phone.
- **Edge cases to show:** the 1st of a month (one day lit at most), the 31st,
  a month with a frozen day (a freeze covered it: lit or its own mark?), and
  a player who just unlocked the Daily.
- **Text.** The week starts on the locale's first day, and the month and
  weekday names are localized (Japanese and Hindi included). Please give the
  cell sizes so a 7 × 6 grid fits a 360 dp wide phone.

### 14.3 The last 7 dailies, playable (Daily)

Any of the previous seven dates can be played on the device. Every phone
gets the same board for a date. Playing an old day pays nothing, never moves
the streak, never grants or spends a freeze, never counts toward the day-7
chest and can't repair a paused streak. It is for fun. Replays are allowed,
and pay nothing.

Frames we need:
- **14.3a The picker.** In the month (14.2), the last 7 days are tappable.
  Show how a playable past day reads against a lit day and a blank day older
  than the window (which isn't tappable and has no lock and no "expired"
  word).
- **14.3b A past day's puzzle card.** Like 5.1's puzzle card with the date
  title (for example "Wed 7 Oct"), "5 colors · Hard", the preview and Play,
  but no coin chip. One calm line may say it doesn't change the streak.
- **14.3c The board.** 5.3's date pill for a past date.
- **14.3d The win.** 5.4 for a past day: "Moves N", no coins, no streak card
  change, and a way back to the Daily.
- **14.3e A past day already solved.** Its card and its cell, with Play
  again.

### 14.4 The home-screen widget (iOS and Android)

A glance at today's puzzle and the streak, outside the app. Tapping it opens
the Daily. It works offline, has no ad, and never counts down to the next
puzzle.

- **Sizes:**
  - iOS systemSmall and systemMedium;
  - Android 2 × 2 and 4 × 2 cells (with their resize limits).
- **States:**
  - **14.4a ready:** today's puzzle is ready, with the streak number and an
    unlit flame;
  - **14.4b solved:** today is solved and the flame is lit;
  - **14.4c paused:** the number kept, the flame unlit, and no "missed";
  - **14.4d no streak yet**;
  - **14.4e before the Daily unlocks** (after Level 2): what it shows then.
- **Looks:**
  - iOS light and dark, the iOS 18 tinted mode, and the iOS 17 container
    background;
  - Android light and dark, its corner radius, and the picker's preview
    image.
- **Art the platform can draw:**
  - Widgets can't play Lottie or render our Flutter UI. Please export the
    widget's art as simple SVG (no filters, so Android can take it as a
    vector drawable), plus PNG at 1×, 2× and 3×.
  - Name the files under `ui/widget/`.
- **Text:**
  - Say whether Fredoka must be bundled into the widget, or whether the
    system rounded face is fine where a custom font can't be used (Android
    RemoteViews).
  - The widget gallery's name and description are in the copy.

### Tokens, sound and copy for section 14

- **Tokens:** an additive `habits` block:
  - the welcome-back card;
  - the month's cell states (lit, played later, playable past day, blank,
    future, today), its grid and its 16:9 values;
  - the past-day puzzle card;
  - the widget's sizes, paddings and colours (light, dark, tinted).
- **Sound and haptics:** reuse the existing set (`tap`, `chest_*`,
  `jingle_*`), unless a habit needs its own short sound. If it does, add it
  to AUDIO.md's contract.
- **Copy:** a new `## Local habits` section in copy.md, in English (the game
  translates it into its nine languages). It needs:
  - **the welcome-back card:** the three variants' lines, the button and
    the dismiss label;
  - **the month:** its title (for example "October"), each day's
    screen-reader label ("7 October, solved", "played later", "not played",
    today), and the playable past day's label;
  - **a past day:** the puzzle card's lines, the win card's lines, and Play
    again;
  - **the widget:** the gallery name and description, each state's lines,
    and the screen-reader label;
  - **short forms** under `## Short forms` for a German text about 30 %
    longer.

  None of it may say streak lost, missed, broken, expires, last chance,
  hurry or today only.

## Part 2: questions m7-5 left open

Each item says what the game ships today. Change the handoff, or answer
"keep" and the game keeps what it ships.

### From the m7-5 build and device run

1. **The freeze chip's wording.** copy.md says "{count} streak freeze(s)",
   which overflows the streak card's row in 12 cases (German and Hindi the
   worst). The game ships "1 freeze" / "{n} freezes". Please give a wording
   that fits 360 dp in German, or keep.
2. **Every Computer tag.** 9.3i draws the `NestyStrip` tag scaling with the
   text (20k tall, glyph 14k). The game's `ComputerTag` stays 20 dp, because
   every rival surface shares it. Should every Computer tag scale?
3. **Pause in the 58 dp race strip.** 9.3i draws Pause as tall as the
   strip. The game keeps Pause at 48 dp (`HudTokens.pauseButtonSize`), and
   no token says it grows. Please add a token, or keep.
4. **Claim on the 16:9 gift sheet.** 13.3b's Claim is 54 tall, and the
   game's large button is 58 (so the sheet is 465, not 461). Please give a 54
   button size, or a 58 Claim.
5. **The Day 7 ribbon.** 13.6b's ribbon is 46 tall at Fredoka 21 with
   padding 24. The shared ribbon title draws 18/700 with padding 9/22, the
   same as 10.3b. Can one ribbon spec serve both?
6. **The done tile's check.** It is drawn at weight 700, and the bundled
   icon font is a static 600 cut. Is 600 fine, or should we cut a 700 weight?
7. **Tokens that disagree with the frames:**
   - `textFit.winRibbon.box` says 312 × 40, while `winRibbon.size.textBox`
     says 266 × 40;
   - `type.museum.count` says 20, while the frames draw 16;
   - the figurine panel's two radial gradients (earned and locked, six
     colours) have no token.

   Please fix the tokens. Today the game follows the frames.
8. **The Museum's won nameplates.** The game draws a glossy, saturated gold
   with a diagonal shine; 6.1c draws a pale, flat gold. Which is meant?
9. **The gift tally on a short phone.** On a 731 dp phone the tally ends
   about 2 dp from the chapter card's "CHAPTER n" label, so a two-digit count
   covers its start for the tally's 1.2 s visit (under the scrim). May the
   tally cover the card, as 13.5b and 13.6d draw it, or should it step
   aside?
10. **The opened chest's rays.** `ui_chest`'s rays (m7-5 item 6) read as hard
    wedges on a phone, where 10.3c and 13.6c draw a soft glow. Please give a
    softer ray matte in the Lottie.

### Frames and tokens no delivery has covered yet

11. **Home between 700 and 844 dp tall.** The game blends 2.1b into 2.1 by
    height. Please confirm the blend, or draw a frame at about 760 dp.
12. **The Daily before Level 2.** The Daily screen when it is still locked
    has no frame (12.3 shows only the locked Home tile).
13. **Records' "Best moves by level".** It has no destination of its own; the
    game opens Chapters. Keep, or draw it?
14. **The tutorial's second family.** Level 1's tutorial has a step with no
    frame. Please draw it, or confirm the step's tip copy and hole.
15. **A 16 px text link.** The overlays' text link has no Fredoka 16 style;
    the game uses `buttonSmall` at 16. Please add a type token, or keep.
16. **The family counter's label width.** The family counter's label has a
    52 dp maximum width, which is our guess (LOTTIE.md §12). Please confirm it
    or give the width.
17. **The splash's error dim and two error icons.** The splash's error dim
    (`#3C1E0A` at 35 %) has no colour token. The `storageError` and
    `contentError` glyphs aren't in tokens `icons`. Please add them, or keep.
18. **The 1-shelf board.** The board uses `boardPresets.oneShelf` (540 /
    150, "tiny boards only") with no frame. Please confirm it, or draw a
    1-shelf scene.
19. **Rows of 5 and 6 with tall pieces.** Choice 23 kept these pieces at
    their limits: the tall case is capped at the pitch − 2 dp, and a row of 6
    extends the row of 5's formulas (pitch 62, stand 0.662). Please confirm
    that covers the row of 6, so we can retire the notes.
20. **The fallback doll.** Please say whether `layout.fallbackDoll`'s sizes
    are diameters or radii. Should the splash's first frames show the
    fallback doll before the skin loads (about a second), or nothing?
21. **An invalid move's drift onto an empty glass case or ice slot.** The
    game drifts it at the mover's own height. Please confirm, or give the
    height.

Please list everything new in DELIVERY.md, as in m7-5.
