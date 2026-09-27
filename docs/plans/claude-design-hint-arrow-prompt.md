# Claude Design prompt: the hint arrow under the HUD's centre

Paste everything below the line into the Nesty Claude Design project. It
asks for one frame variant of 3.1 and, if needed, a token. Nothing else in
the export should change. Recorded as PROGRESS D62 and in BACKLOG "Design
gaps" (M7).

---

Nesty: Doll Sort. Please design one missing case of the **Hint** screen
(App Flow frame 3.1). Please don't change any other frame or file.

**Frame 3.1 as it is today.** The `ui_hint_arrow` (40 × 50, bobbing 10 up)
sits over the source doll, centred at (column centre, doll top − 33). The
HUD sits above the board on the 390 × 844 screen with a 59 safe top:
- the pause button, level pill and coin pill end at y 110;
- the family counter pill (70 × 26, centred at x 195) ends at y 142.

On frame 3.1's board the top-row dolls leave the arrow room below the HUD.

**The missing case.** Some levels have taller top-row dolls than any frame
shows. These are boards whose largest doll is size 3, on three shelves: the
game sizes all dolls from the board's largest size, so a size-3 doll there
is as tall as a size-4 one on frame 2.2's board. On those levels the
arrow's top reaches y 100 on 390 × 844.

- **Solved in the game.** Over the side columns, the arrow now steps up to
  a quarter of a column sideways, off the counter pill. It also moves up to
  16 down, under the button row, so its tip reaches at most 8 into the
  doll's top. On frame 3.1's own board nothing moves.
- **Not solved.** A three-stand top row has its middle stand at x 195,
  right under the counter pill. The arrow can't step off the pill there
  without leaving its doll. It can't drop the 25–50 it would need either
  without covering the doll's face. It stays tucked under the pill by
  10–33. This affects levels 3, 5, 8 and 21–23.

**What we need.** A variant of frame 3.1 (call it 3.1b), with the hint
source on the middle stand of a three-stand top row and a tall doll there
(its top near y 165 on 390 × 844, as on level 3). Show where the arrow goes, or what
the HUD does, so they don't collide. Options we could build:
- the counter pill steps aside or fades while a hint shows;
- the arrow points in from the side of the doll's head;
- a smaller arrow, or a shorter bob, for this case;
- anything better you prefer.

**Keep:**
- the arrow's look and its `ui_hint_arrow` file (if the fix needs a
  different motion, a new marker or a new file is fine; say which);
- the HUD's layout on every other screen;
- the 390 × 844 reference.

**Please send back:**
- frame 3.1b;
- a line in README's Hint section that says when it applies;
- any new token, such as an offset or a fade time, in tokens.json;
- if you changed or added a Lottie, its LOTTIE.md v3 entry.
