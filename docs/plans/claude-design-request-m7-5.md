# Claude Design request: nesty-design-m7-5 (send Wednesday 2026-10-07)

One message for the Nesty Claude Design project. It holds two things:
- the daily gift's new section 13 (D268, D272; the rule is
  [plan-login-gift.md](plan-login-gift.md) §7.5b);
- every M7 design question still open after m7-4. These are the open
  `design` items in BACKLOG "M7", gathered from "Follow-up after m7-3"
  §1, §4, §5 and §11–§14 in
  [claude-design-request-m7.md](claude-design-request-m7.md) and from
  BACKLOG.

It replaces sending [claude-design-login-gift-prompt.md](claude-design-login-gift-prompt.md)
and the follow-up separately. When the delivery comes, import it through the
checks in BACKLOG M7 "Importing a Claude Design delivery".

Paste everything below the line.

---

Nesty: Doll Sort. Thank you for m7-4: the game draws all of it, in nine
languages now (en, es, pt-BR, id, hi, de, fr, tr, ja). This round has two
parts:
- **Part 1** is a new feature, the daily gift, as App Flow section 13;
- **Part 2** is the design questions the m7-4 device runs left open.

Please deliver both as **`nesty-design-m7-5`**, cumulative and in m7-4's
format: the whole handoff root, with `tokens.json`, `README.md`,
`LOTTIE.md`, `AUDIO.md`, `copy.md` and the App Flow file whole. In
DELIVERY.md, list only what changed, and put each "keep" under "Choices".
None of this changes a game rule: prices, rewards, limits and unlocks stay
as the game has them. A partial delivery is fine. Part 1 and items 1, 5 and
16 unblock the most.

## Part 1: the daily gift (new section 13)

Please don't change any existing frame, token or file except to add what is
listed here.

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
  with `hint_flight.svg`. Show the moment and the end state. Home has no
  hint or slot button to fly to, so please say where a hint or an extra
  slot goes (today the game pops its tile in place).
- **13.6 Day 7.** Claiming Day 7 opens the existing chest sequence (5.6 / 5.6b,
  `ui_chest`) with "100 coins + 1 extra slot" shown before it opens. Say if
  the chest needs a gift-specific title or tint. The ribbon title must fit
  on a 360 dp phone in German, Spanish, French and Portuguese: today's
  stand-in, "A week of gifts", doesn't, and the game falls back to "Daily
  gift" there. Please give it a short form.
- **13.7 A new track.** The sheet the day after Day 7: Day 1 again, with the
  past week's days cleared, and no "reset" or "start over" wording.
- **13.8 Waiting.** A phone whose clock was set back: the gift can't be
  claimed until the date seen last comes round. The button has no dot, and
  the sheet has no Claim button, just a calm line naming the next gift ("Next
  gift: 50 coins"), with no date or clock and no hint that anything is
  wrong.
- **Reduce motion:** what 13.5 and 13.6 do with motion reduced (the in-app
  three-way setting).

**What the game draws today** (built on stand-ins from the tokens; keep or
change any of it). On Home, the button sits beside the gear, 6 dp apart, with
a 13 dp gold dot, and both keep a 48 dp target on a 360 dp phone at 1.3×
text. The sheet shows Days 1–6 in a 3 × 2 grid of 96 dp tiles, and Day 7 as
a wider 100 dp tile with the chest art, then the Claim button or the calm
line. Up to six coins fly to the pill over 700 ms. Screenshots of the
stand-ins are attached.

**Art.** A gift glyph for the button: a Material Symbols Rounded glyph (FILL 1,
weight 600, like the rest of `icons`) or a small SVG in `ui/`. Name it in
DELIVERY.md. Please don't reuse the chest's `redeem`: the gift must read as
its own thing. Reuse `chest_closed` / `chest_open`, `coin_flight` and
`hint_flight`. The chest's contents row now has a third chip, "+1 slot",
beside the coin and hint chips: please draw its disc in their style. An
extra-slot sprite too, if Day 7's slot should fly.

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
- the waiting line ("Next gift: {gift}", 13.8);
- the gift phrases that fill {gift}, with their plurals: "{n} coins", "{n}
  hint(s)", "{n} extra slot(s)", and how two join on Day 7 ("100 coins + 1
  extra slot");
- the Day 7 chest's title, if it differs from 5.6;
- each tile's screen-reader label (day, gift, done / today / later), and the
  three state words it uses (today's stand-ins: "Claimed", "Today's gift",
  "Coming up");
- the chest's "+1 slot" chip and its screen-reader text ("100 coins, 1 extra
  slot");
- short forms under `## Short forms` for a German text about 30 % longer.

## Part 2: questions the m7-4 runs left open

Each item says what the game ships today. Change the handoff, or answer
"keep" and the game keeps what it ships.

### Tokens

1. **Frame-only colours.** Each is drawn in a frame but has no token. Give
   each a name in `color`, or say which existing token it is:
   - the toast kinds:
     - success `#EAF7EC` / `#A6DDB3` / `#46A758`;
     - info `#E8F3FF` / `#9CC4EA` / `#3E8EDE`;
     - badge `#FFF7E0` / `#E6C36A` / `#F5C518`;
     (face, ring, accent in each);
   - the lit streak card's peach `#FFF2E6 → #FFE7D0`, edge `#E6B79A` (10.7);
   - the settings divider `#F0E0C4` (10.2e);
   - the open chapter's won cell `#FFF6E6`;
   - the locked cell's lock `#C4AE92`;
   - the Museum's next niche name `#FFEFD6`;
   - the rival-select locked line `#8A5B3A` (the game draws `#8A6A4E`);
   - the spotlight panel, the cabinet's drop shadow, the dashed row line and
     the segmented track's shade;
   - the brown `#6E4526` the icons use.
2. **A type token per surface.** The sizes the game takes from the scenes'
   CSS have no token:
   - Chapters: rows 10, 15 and 11, and cells 16;
   - the Museum: 11, 20 and 12;
   - Records: 20, 11.5, 16 and 18;
   - the Shop: 16, 14, 15 and 13;
   - Home: 11 and 17.

   Add a `type` entry per surface, or confirm the CSS is the spec.
3. **The chest flights** (10.3c, 10.3d). The coin pill's gold ring as a
   coin lands, and the 6 dp trail dots: give their values. The game ships
   the flights without them.
4. **The Restart glow** (12.7, "Suggested"). The frame draws a crisp orange
   ring of about 3 dp. The game uses the Undo's soft gold glow (3.4). Give
   the token (colour, width, blur), or keep the soft glow.

### Lottie and art

5. **The versus and Daily win ribbons' width** (9.4, 9.5, 5.4).
   - `ui_win_ribbon` draws a 336 × 56 dp band, with tails to 380 dp on a
     390 phone.
   - The App Flow CSS draws a 290 × 56 body, with tails to 334 dp.

   Confirm which is right. If the CSS is, send the file with a 290 band, or
   with `band_rect` and `tail` named rects so the game can set the width (as
   `ui_chapter_ribbon` has them).
6. **The open chest's rays** (10.3c). They read paler and narrower than the
   frame's (about #FFD98A at 55 %). Raise their alpha and width in
   `ui_chest.json`, or keep.
7. **The chapter ribbon** (4.7). The game tints the one-line
   `ui_chapter_ribbon` with the chapter's palette (a colour matrix). Does
   frame 4.7's two-line plate replace the Lottie? If the Lottie stays, name
   its band and edge fills so the game can recolour them exactly.
8. **The tutorial hand** (1.3, 1.4, 1.6, 10.8b). `ui_tap_hand` is about
   67 dp; the frames' hand is about 40. Send a smaller hand, or keep.
9. **The case-break shatter** (2.7). On iOS it reads as a rectangular frost
   slab, not a dome. Confirm the slab, or redraw it as a dome.
10. **The generating card** (12.5, 12.6, 12.10).
    - The frame draws an orange arc on a cream track, in a wider,
      off-centre card at y 360.
    - The game ships `ui_spinner` (purple, 44 dp) in a 236 dp card centred
      in the safe area.

    Recolour the spinner or keep it. Give `layout.generating.top`, or keep
    the safe-area rule.
11. **The splash's top** (1.1, 10.8, 12.10, 12.11). The frames draw a flat
    cream-to-peach top. The game draws chapter 1's theme art, so its blurred
    arch and halo show in the top 200 dp. Is the arch meant, or should a top
    fade cover it? Give the fade's value if so.
12. **The all-home Museum card** (6.1c). The scene draws
    `ui/badges/museum_full.svg` at 92 dp. Confirm the badge art is the
    card's centrepiece, at that size.

### Motion

13. **The undo** (no frame draws one). The game flies the moved doll back
    along its own path: `doll_move` reversed, 260 ms, one `whoosh`, and
    130 ms under reduce motion. Draw an undo (a short path, a different ease,
    a sound), or keep.
14. **The wobble before a move.** A picked doll wobbles. When it is dropped,
    the wobble snaps into `doll_move`'s first frame. Give a settle time
    before a move, or keep the snap.
15. **The relit streak card's twinkles** (10.7b). The frame places two stars
    near the flame disc with no size. The game draws Lottie twinkles at 22
    and 14 dp. Give the sizes, or keep.

### Layout and frames

16. **The race strip's two new forms** (9.3). The strip must always show
    the word "Computer" beside the rival's name at 360 dp and wider; under
    360 dp the glyph alone stays (your README's rule). In Spanish,
    Portuguese, French, Indonesian and Japanese, and at 1.3× text, the name
    and the tag don't fit one line beside 8 dots. So the game has two forms
    of its own. Please draw both with 9.3:
    - **The count without dots.** The family count ("3/8") stands alone in
      the right column when a long name and the tag need the room. It also
      does so in every race above 8 families, because 9.3 draws at most 8
      dots.
    - **The tag on the second line.** When even that is short (a long name
      at 360 dp, or 1.3× text), the name takes the first line and the
      Computer tag the second. It replaces the state line ("Thinking",
      "Starting over", "Finished"). The portrait's motion and the screen
      reader still carry the state.

    Say whether the state line should come back elsewhere in that form,
    for example as a small glyph beside the tag, or whether the dots should
    shrink instead.
17. **The "Not enough coins" dialog's top** (7.4c). The Museum's detail now
    hangs from the frame's top (128 dp, 6.2 and 6.3). The coins dialog is
    still centred, where the frame draws it at about 220 dp. Add its top to
    `layout`, or keep it centred.
18. **The figurine modal's spotlight** (6.2, 6.3). NestyShop draws it 300
    tall; the game draws 200, so the modal is shorter on a 731 dp phone.
    Give the height, or keep 200.
19. **The Museum's Play button** (6.1). The scene draws it 36 tall. The
    game's smallest tactile size is 38, inside a 48 dp touch box. Add a 36
    size, or keep 38.
20. **Chapters' "levels to go"** (10.4). The scene puts it inline, right of
    the progress bar. The game puts it under the bar so it can grow at 1.3×
    text. Keep, or say how it sits with large text.
21. **Where Chapters scrolls on open** (8.4). The game keeps up to three
    folded rows above the open card, fewer on a short phone. Add
    `layout.chapters.scroll.foldedAbove: 3`, or change the rule.
22. **A capped win on a short phone** (11.2d). The win card's helper note
    says why the stars are capped, but on the 16:9 phone it has no room.
    Where should the reason sit there?
23. **Board pieces at the limits.**
    - A tall glass case, its ice, and a row of 6 (a second +1 Slot on a
      4-slot bottom shelf) aren't drawn. The game caps the tall case at the
      pitch − 2 dp, and a 96-wide ice can overlap a neighbour by up to
      2.4 dp. Draw them, or keep.
    - `fourShelves` has no glass or ice sizes; the pieces scale with the
      dolls.
24. **What the game adds** (9.4, 9.6, 9.7b, 10.6b).
    - The badge toast shows its earned line under the title (copy.md G.8),
      and the race win shows "You beat the computer in a race."
    - 9.7b's rival portrait carries the Computer tag, because every rival
      surface says Computer.

    Keep, or redraw those frames with them.
25. **The chest card at 10 of 10** (12.4). It drops its "N levels to the
    chest" line once the chest is due. Confirm.
26. **The freeze chip at zero** (5.2, 5.2b, 10.7). "0 left" counts down a
    loss, so the game ships "No freeze" at zero and "{count} streak
    freeze(s)" otherwise, in the same chip width. Confirm, or give another
    zero-state line without "left".

### Copy and fonts

27. **"Owned".** A screen reader hears it after an owned skin card's name
    (`shopOwned`), and copy.md doesn't name it. Confirm "Owned", or give
    the line.
28. **Fredoka for Turkish.** The Fredoka build at the pin lacks ğ Ğ İ ş Ş
    (and ₹), so Turkish titles draw those letters in Nunito mid-word. Send a
    Fredoka build with Latin Extended-A (OFL allows it, under a new name if
    modified), or pick another rounded display face that covers it, and say
    which. A source and a version are enough: the game rebuilds its fonts
    from a pin.

Thank you!
