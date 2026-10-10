# Claude Design request: nesty-design-m7-7

One message for the Nesty Claude Design project, for its next round. It has
three parts:
- **Part 1:** the kid path (D260, Q174's defaults) as a new App Flow
  section 15. It grows engagement-research §6.5's request.
- **Part 2:** the characters' wave 1 (D275: TC7, TC8, TC1) as a new
  section 16. It is themes-characters-story §10 cut to wave 1: no squad, no
  story and no Little Ones yet. The race-loss card keeps its hop (D273), so
  it asks for no bow.
- **Part 3:** the design questions m7-6 left open (BACKLOG "Local habits",
  checked 2026-10-10).

The build starts on `TODO(design)` stand-ins
([kid-path-wave-1-claude-code-prompt.md](kid-path-wave-1-claude-code-prompt.md)).
When the delivery comes, import it through the checks in BACKLOG M7
"Importing a Claude Design delivery", the m7-6 way (D304–D309).

Paste everything below the line.

---

Nesty: Doll Sort. Thank you for m7-6: welcome back, the month of played
days, the last 7 dailies and the home-screen widget are in the game as
section 14 draws them, in all nine languages, on iOS and Android. This round
has three parts:
- **Part 1** is a new section 15, the kid path. Nesty now welcomes children
  as well as adults.
- **Part 2** is a new section 16, our first characters: the Nest Keeper
  mascot, dolls that come alive on the board, and a friendlier Computer.
- **Part 3** is the design questions m7-6 left open.

Please deliver all three as **`nesty-design-m7-7`**, cumulative and in
m7-6's format: the whole handoff root, with `tokens.json`, `README.md`,
`LOTTIE.md`, `AUDIO.md`, `copy.md` and the App Flow file whole. In
DELIVERY.md, list only what changed, and put each "keep" under "Choices".
None of this changes a game rule: levels, prices, rewards, limits and
unlocks stay as the game has them. A partial delivery is fine. 15.1 to 15.3
and 16.1's motion spec unblock the most; the mascot's Lottie (16.2) can
come last.

Please don't change any existing frame, token or file except to add what is
listed here. Frames are 390 × 844, plus the short 16:9 phone (390 × 693)
wherever the layout changes, as 2.1b and 14.1 do. Each one needs a reduce
motion note.

## Part 1: the kid path (new section 15)

Players under 13, and anyone who hasn't told us their age, play the same
game on a "kid path": the same levels, coins and boards. The game asks the
player's age once, and a grown-up controls a few things behind a simple
check. The player never sees the words "kid path".

**Rules that shape every frame:**
- The age question never blocks anyone. Nothing is pre-selected, there is no
  wrong answer, and nothing ever says "too young".
- A child is never scolded, shamed or locked out. Where something needs a
  grown-up, it says so kindly.
- The grown-up check is quick for an adult and hard to pass by chance. It
  has no timer, no countdown and no lockout, and a wrong try never scolds.
- No "kids", "kids mode" or "for kids" wording anywhere.
- The age stays on the phone, and the copy says so.
- The existing respect rules still apply: nothing pops up on its own (the
  age question is the one exception, asked once), no countdowns, nothing
  random for sale.

### 15.1 The age question

- **When.** Once, right after Level 1's win (so Level 1 stays instant), on
  the way to Level 2. A player who won Level 1 before this update sees it
  once, after their next win.
- **The screen.** One calm screen with a month picker and a year picker,
  with nothing pre-selected, a line saying it stays on this phone, and one
  Continue button.
- **Readable by a 9-year-old**, and fits at 1.3× text and on the 16:9 phone.
- **States:** empty (Continue disabled), one picked, both picked.
- **A way past.** The game asks for an answer, and any answer continues. If
  you think a quiet "Skip" belongs here, draw it too and say why under
  "Choices"; the owner decides.
- **The pickers in nine languages**, including Japanese and Hindi month
  names and a year list that reaches back about 100 years.

### 15.2 The grown-up check (parental gate)

- A small sheet a grown-up passes in a few seconds and a child can't pass
  by chance. Our default: "Type forty-seven", a number written in words and
  typed as digits. The words come from the game's catalogs in nine
  languages, so the design gives the pattern and the English.
- **States:** asking; wrong (a gentle retry with a new number); passed (the
  sheet closes and the action goes on).
- Show it over Settings and over the daily win card.

### 15.3 The parent area

- **Where.** A "For grown-ups" row in Settings (8.1, 10.2e) opens it,
  behind the check. Show that row, and Settings on the adult path, where
  the rows stay as today.
- **Rows:** the daily reminder and its time (moved here from Settings on
  the kid path), Sharing on or off, Privacy Policy, Support, the player's
  age (change it), Purchases (drawn now, shown from the ads-and-purchases
  round), and a short "About this area" text.
- **States:** sharing off (the default) and on; the reminder off and on.

### 15.4 Kid-path states of existing frames

- **10.1 The daily win:** with sharing off, there is no Share button. Show
  how the card balances without it. With sharing on, Share asks the check
  first.
- **10.2 The reminder offer:** on the kid path it is never shown; please
  confirm nothing takes its place.
- **8.1 Settings' links:** Privacy Policy and Support ask the check first.
- **7.1 and 7.8 The Shop's Coins and No Ads tabs:** they ask the check
  first. Both are closed until the ads-and-purchases round, so one frame of
  the check over the Shop is enough.

### Tokens and copy for section 15

- **Tokens:** an additive `kidPath` block: the age question's pickers and
  layout (with the 16:9 values), the check's sheet, the parent area's rows.
- **Sound and haptics:** reuse the existing set (`button`, `tap`). A wrong
  try on the check has no buzz or error sound.
- **Copy:** a new `## Kid path` section in copy.md, in English (the game
  translates it into nine languages): the age question's title, line,
  picker labels and Continue; the check's prompt pattern ("Type {number}"),
  its wrong-try line and its screen-reader labels; the parent area's title,
  every row and the "About this area" text; the "ask a grown-up" lines on
  Share and the links. Short forms under `## Short forms` for German, about
  30 % longer. None of it says too young, kids, child mode or for kids.

## Part 2: characters, wave 1 (new section 16)

Our first characters. Keep the cozy folk-toy-shop look (spec §12.1, the
tokens). **Original designs only**, including anything generated: nothing
may resemble Marvel, Power Rangers, Barbie, KPop Demon Hunters, Sanrio or
any existing character, in its logo, suit, silhouette, colour blocking or
catchphrase. Motion never flashes more than three times a second.

**Rules for every character:**
- never sells anything, and never appears in the Shop, an ad, a purchase
  or any offer, including the out-of-moves sheet's rows and the booster
  popup;
- never mocks, guilts or scares ("you failed", "don't go", "I missed you"
  are out);
- the Computer is always labelled "Computer" and never pretends to be a
  person.

### 16.0 A character bible

For the Nest Keeper and for the Computer:
- a proposed name, for a legal check (the Nest Keeper's working name is
  "Grandma Nesta"; the game keeps her name off screen until the check);
- a personality in three words;
- how it moves;
- its wordless babble voice;
- do and don't.

### 16.1 Living dolls on the board (a motion spec, no new Lottie)

The board's dolls come alive a little, without ever slowing play.
- **Idle:** a blink, a small sway and, after a long idle, one yawn. Give the
  timings, the amplitudes, how often, the stagger between dolls, and which
  dolls idle (for example only the top doll of each slot). Nothing idles
  during a move.
- **The blink.** Each skin is the 512 × 768 layered format (shadow,
  bottom_mask, bottom_detail, top_mask, face, top_detail, shine), and the
  face is its own layer that rides on the lid. Please say how a blink is
  drawn: a closed-eyes face layer for each of the 7 skins, an eyelid layer
  the game tints, or a short squash of the face layer. Deliver the art if a
  layer is needed.
- **Taps:** the touched doll squishes (with a soft giggle), and the doll
  that receives a nest bounces "home". Neither may delay the move.
- **Home's plank dolls** (`doll_idle`): keep as they are, or join the new
  idles?
- **The Museum:** a figurine waves when tapped.
- **Reduce motion:** idles off; say what a tap keeps.
- **Rest:** idles stop after 30 s without a touch and when the app is in
  the background.
- **Sound:** the giggle (three short, soft variants), named in spec §11.3's
  style, with its AUDIO.md entry.

### 16.2 The Nest Keeper (mascot)

A large painted matryoshka grandmother who "keeps the nest". Opening her
is a nod to the app icon.
- **Where she appears** (please draw each, on 844 and 16:9):
  - **Home (2.1, 2.1b):** where she sits without crowding the stack (the
    top row, the chapter card, the welcome-back card when it shows, the
    plank, Play, the tiles);
  - **the tutorial (1.3 to 1.6):** she voices the tip card. Draw the tip
    with her;
  - **the win card (2.8, with the stars of 11.2):** a cheer;
  - **after out of moves:** a comfort ("Let's try that one again") when the
    player picks Restart, on the board, never on the sheet (3.5) itself;
  - **a gentle break:** after a long play she dozes on Home. It is only a
    look: it never blocks play and shows no timer.
- **One Lottie, `ui_keeper`, with named segments:** idle (breathing), wave,
  cheer, comfort, doze (in, loop, wake) and a tap reaction, like
  `ui_rival_react`, at the sizes and positions the frames give. Add a
  reduce-motion still for each segment.
- **Her voice:** four to six short wordless babble clips, with no real
  words in any language, with their AUDIO.md entries. Say when she babbles
  and when she stays quiet (never over a jingle).
- **Her lines:** one short, warm line for each moment, never guilt-based.

### 16.3 The Computer's reactions

Two new segments in `ui_rival_react`, beside idle, family, win and lose:
- **`wave`:** at the race's start (9.3);
- **`cheer`:** "Nice one!" when the player completes their first family of
  the race, at most once per race.

Draw both on the rival strip (9.3, 9.3i). The loss card (9.5) keeps the
`win` hop as you designed it (owner's choice), so no bow is needed.

### Tokens, sound and copy for section 16

- **Tokens:** an additive `characters` block: the idle and tap timings, the
  Keeper's sizes and positions per frame, and the cheer's bubble.
- **LOTTIE.md:** `ui_keeper` with its segments, and the two new
  `ui_rival_react` segments, with rows in "When each one plays".
- **AUDIO.md:** the giggle and the babble clips.
- **Copy:** a new `## Characters` section in copy.md: the Keeper's lines for
  each moment, the tutorial's tips in her voice (replacing 1.3 to 1.6's
  tips), the Computer's "Nice one!", and every screen-reader label. Short
  forms under `## Short forms`.

## Part 3: questions m7-6 left open

Each item says what the game ships today. Change the handoff, or answer
"keep" and the game keeps what it ships.

1. **12.14's sizes.** `DailyLockedCard` (card radius 32, the 76 dp piece,
   title 26, body 16, the 58 dp button) has no tokens; the game reads them
   from the NestyHabits `dailyLocked` scene. Please add a `layout` entry.
2. **The family counter's Fredoka metrics.** Our bundled Fredoka measures
   "12 / 12" at 37 dp at 1× where the design's pill draws 44, so the pill is
   71 dp against 78 (48 against 57 at 1.3×). Is the design's font a
   different cut, or is the gap fine?
3. **The figurine modal's count.** The game reads "0/20" (the shared
   "{done}/{total}"); NestyOverlay draws "15 / 20". Is the spaced form
   meant?
4. **The welcome card's close glyph.** Tokens say weight 700; the bundled
   icon font is a static 600 cut. Is 600 fine, or should we cut a 700
   weight?
5. **The month card's place.** It sits 16 dp under the puzzle card, not 12,
   and the card's header doesn't fade the content under it once scrolled
   (14.2: top 728, a 16 dp fade). Please confirm the gap and the fade.
6. **14.3d on a short screen.** At 731 dp (the 16:9 Android emulator) the
   past day's Back to Daily sits on the top of the board's dimmed bar,
   because the card keeps the frame's button top (630 from the safe top).
   Please draw 14.3d at 16:9.
7. **14.3d's sizes as tokens.** The Moves pill's Fredoka 700 28 `#5B3A21`
   and the date cell's day at Fredoka 700 22 are only in
   `habits.pastDay.win`'s prose and the frame's CSS. Please type them.
8. **The widget's first run.** With nothing stored yet, both platforms
   borrow the locked look. Please draw that state, or confirm.
9. **The widget's size tiers.** The game uses its own tiers for iOS's
   shorter widgets, for Android's locked and 4 × 2 looks, and keeps the
   medium flame at 46 dp in the compact tier. Please confirm, or give the
   tiers.
10. **The widget's text fits.** The game puts the line on one line, then
    the short form; wraps the label to two lines in the 104 column; puts
    1000+ on the number's 0.8 floor alone; caps the type at xxLarge; and
    uses SwiftUI's greedy wrap where 14.4 balances the line. Please confirm
    each, or give the rule.
11. **The widget's dolls.** It shows the first N with no "+N", and past its
    last stored day it shows the generic title with no line or dolls.
    Please confirm, or draw them.
12. **The widget's tinted look and StandBy.** 14.4f draws mock values (the
    system applies its own tint), and StandBy uses the dark tokens. Please
    confirm, or draw them.
13. **The widget's face in Turkish, Hindi and Japanese.** No widget face is
    drawn for them, so they use the system face; Android draws the system
    sans everywhere, with "sans-serif-medium" bold where the frames draw
    Roboto 700. Please confirm, or name the faces.

Please list everything new in DELIVERY.md, as in m7-6.
