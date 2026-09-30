# Claude Design request: Nesty's offline game (M7)

Paste everything below the line into Claude Design, in the Nesty project
that produced the v1 handoff, the v3 Lottie export and the audio delivery.

---

## Nesty: Doll Sort, the next design round

You designed Nesty's handoff: `tokens.json`, the App Flow frames
(`prototypes/Nesty App Flow.dc.html`, frame ids 1.1–8.7), NestyBoard,
NestyMenus, NestyOverlay and NestyShop, the 7 layered skins, the chapter
themes ch01–ch06, the 10 museum figurines, the 29 Lottie files (LOTTIE.md
v3) and the audio (AUDIO.md). The game now plays all of that. The next
round finishes the game offline: 200 levels in 10 chapters, the art for
chapters 7–10, the board layouts the later levels need, a new "vs
Computer" race, a set of engagement features the owner approved, and
the states no frame shows yet. The approved features are a daily share
card, a daily reminder, a milestone chest, replay with best moves,
Records and badges, relaxed mode, a gentler streak and star ratings (1 to
3 stars per level, section K).

Nesty is rated 13+ with an all-ages feel. Everything here is warm and
never pushy. No countdowns, no "don't lose your streak", nothing random
for sale, and a computer rival always reads as a computer.

Keep every convention of the existing handoff: `tokens.json` stays the
single source of values (and wins over a frame), new screens get frame
ids in the App Flow file, Lottie files follow LOTTIE.md v3 (canvas, anchor,
markers, allowed features, no text layers except the documented ones),
audio follows AUDIO.md (SFX as 44.1 kHz mono WAV, jingles and loops as
OGG), and the README's "Screens" and "Latest changes" list what changed.
Don't change existing frames unless a section below asks for it.

If screenshots are attached, they show the app's current stand-ins for the
screens below (Home, Chapters, the Museum, the win card, the chest, Records
and the "Not enough coins" dialog). They are context only: redesign freely.

### A. Chapter themes 7–10

1. Four board backgrounds in the ch01–ch06 format: portrait SVG,
   1290×2796, the important content inside the centred 1080×1920 safe area
   (spec §12.4), named `themes/ch07_<name>.svg` … `themes/ch10_<name>.svg`.
   The existing six are Sunny Toy Shop, Rainy Café Corner, Seaside Market,
   Snowy Cabin, Night Carnival and Spring Garden Shed. Chapters 7–10 award
   the Circus, Musician, Royal and Explorer figurine families; the themes
   may echo them, but avoid a second carnival next to ch05.
2. A name for each (the chapter ribbon reads "CHAPTER 7 · <Name>").
3. A `palette` of UI accents per theme (spec §12.4), all ten, in
   `tokens.json`.
4. Theme card thumbnails for the Shop (frame 7.7 shows a 74 px thumbnail;
   the app draws a flat colour today). Preferred: a crop rectangle per
   theme in `tokens.json` (x, y, w, h in the 1290×2796 art) that the app
   cuts from the background. Otherwise one PNG per theme at 3×.
5. Optional: per-theme shelf and stand art (spec §12.4) if the themes need
   more than the shared wood.

### B. Board layouts for levels 31–200

Levels 31–200 bring glass cases (from L31), ice (from L51), dolls up to
size 5 (from L71) and size-6 "super hard" levels (L130, L140 … L200).
NestyBoard has presets for 2 and 3 shelves with up to 4 slots per row,
and the level curve never needs more. Items 3–7 are needed; 1 and 2
are optional, for variety in chapters 8–10 if the owner wants it.
Add, as NestyBoard presets with the same measurements (plank y, stand
width, pitch, doll heights per size):

1. Optional: a 4-shelf board.
2. Optional: rows of 5 slots.
3. Size 5 and size 6 dolls on a 3-shelf board: the tallest doll per slot
   pitch. The game clamps doll height board-wide today
   (`h·2/3 ≤ minPitch − 8/3`); confirm or replace that rule.
4. A glass case holding a size-5 and a size-6 doll (the case is shorter and
   narrower than those dolls today).
5. A tower on the top shelf with 3 buried nests, keeping the deepest
   silhouette clear of the HUD.
6. The extra slot (+1 Slot booster) when the bottom shelf is already full.
7. An iced tower: where its "+N" tag goes. Today it draws over the ice.
   Put it above the ice, or hide it until the ice is gone.

### C. vs Computer race (a new App Flow section 09)

The owner approved these rules:
- **The race:** the player and a computer rival solve identical copies of
  one puzzle at the same time, and whoever completes every family first wins.
- **Rivals:** three, unlocked in turn after Level 20 (beat one to unlock the
  next). Rival 1 is relaxed and slow, rival 2 is careful and slow, rival 3 is
  careful and quick.
- **Boosters:** in a race the player has free, unlimited Undo and Restart
  but no Hint and no +1 Slot, so nothing can be bought.
- **The rival's runs:** it makes one move every couple of seconds. When its
  board goes wrong it starts over on its own.
- **Results:** a win pays coins (20, 30 and 40 by rival, for now); a loss
  costs nothing. Rematch replays the same board; New race starts a fresh
  one.
- **Pause:** pausing pauses the rival too.

The player's own board stays the focus; the rival takes a compact strip.
Rivals are characters (doll-family personalities) but always read as
computers. A small "Computer" tag and a computer glyph sit on every rival
surface. No human faces, no "online" dots, no typing bubbles or chat.

1. 9.1 the mode's Home tile (frame 2.1's system), locked ("After Level 20")
   and unlocked.
2. 9.2 rival select: three rivals, each with a name, a portrait at 96 and
   48 px, a one-line personality, a skill label and the reward. Show the
   locked and unlocked states. Deliver the portraits as SVG in the skins'
   allowed features, or as 3× PNG, with a locked silhouette.
3. 9.3 the race board: the player's board and HUD (Undo and Restart only),
   plus the rival strip. The strip has the portrait, a families counter or a
   mini progress view, and the "thinking", "Starting over" and "finished"
   states. Draw the Start state before the race begins (a Start button, no
   countdown), at 390×844 and on a short 16:9 screen. Say how the strip
   reads with reduce motion on (no "thinking" motion).
4. 9.4 you win (coins, Rematch, New race), 9.5 the computer finished first
   (warm: "So close! Rematch?", nothing lost), 9.6 rival unlocked.
5. The Pause dialog during a race (3.9's system): resume, restart and quit
   (quitting ends the race with no reward and no penalty).
6. Lottie, optional: a rival reaction loop (idle, a family completed, win,
   lose) per LOTTIE.md.
7. Audio: `jingle_versus_win` and `jingle_versus_lose` (OGG, AUDIO.md's
   jingle rules) and a short `rival_complete` SFX (WAV) for the rival
   finishing a family.
8. The computer glyph for the "Computer" tag: a Material Symbols Rounded
   name (the app's icon font, I.10), or an SVG if no glyph fits. Also the
   tag itself, as a chip that never reads as a difficulty badge.
9. What the app's stand-ins had to guess, each to confirm or replace:
   - vs Computer's own colour (today the teal of the bonus gradient);
   - the rival strip's height, and where it sits relative to the
     soft-stuck banner (3.4);
   - the Start button in the booster bar's slot, or floating over the
     board;
   - a race board that fails to generate, and its retry;
   - Pause in a race: whether Settings stays reachable, and whether Quit
     (the one action Resume can't undo) asks to confirm;
   - 9.6 as a toast over 9.4, or a fuller card, and a "New" mark on a
     freshly unlocked rival in 9.2;
   - a portrait icon per rival on the Records rows once they have names;
   - where the strip sits against the board's top shelf: the stand-in sits
     in the top shelf's band, so a tall doll's head passes under it even on
     the iPhone 16 Pro, and more on a short 16:9 screen (taps pass through
     it to the board);
   - what the strip says once the player has won (the stand-in's state
     line goes blank);
   - where 9.4's toasts go ("New rival unlocked!", a badge), clear of the
     ribbon, and whether a second toast waits for the first;
   - which part of the strip gives way first on a narrow screen (the
     stand-in drops the state line below 340 dp);
   - the strip's short "moved" beat on each rival move (the stand-in nudges
     the portrait; no sound or haptic), apart from `rival_complete` (C.7);
   - 9.4's celebration and 9.5's music: the stand-in plays 2.8's confetti,
     coin burst, count-up and `win` sound, and ducks the music as 2.8 does
     for both results, until C.7's jingles land (AUDIO.md has no race row).
10. Every new value in `tokens.json`.

### D. Intro card loops (frames 4.1–4.3)

The intro cards for towers, glass cases and ice show a static
illustration today. Spec §7.6 asks for a short looping animation: three
Lottie loops, `ui_intro_towers`, `ui_intro_glass` and `ui_intro_ice`,
whose canvas is the card's 302×230 illustration box, looping, with no
text layers. Add them to LOTTIE.md's tables.

### E. States no frame shows yet

Each as a frame (or a note on an existing frame):

1. Home (2.1): a Super Hard level (the SUPER HARD badge), Bonus Endless
   ("Bonus Level N" on PLAY), a streak of 0 on the Daily tile, the Daily
   tile before Level 2 is won (locked), and a short 16:9 phone (a body
   about 630 dp tall above the nav: the game keeps the tiles 12 dp above
   the nav and scales the hero; approve or replace).
2. The win card (2.8) in Bonus Endless: the bonus level's number and its
   chest countdown. Today it reads "Chapter N · 1 / 1", taken from the last
   chapter's theme.
3. Streak lost (the Daily screen, 5.1's system).
4. The Museum with all ten figurines collected ("Every family is home."),
   and the Museum tile on Home once every chapter is done.
5. A board being generated (a bonus level or the daily): today a spinner
   over the previous board with "Setting up the shelves…".
6. A Continue whose next level can't be generated (today the retry view
   plus a "Back to Home" link).
7. Soft stuck with nothing to undo (3.4's banner suggests Restart instead).
8. The Out-of-Moves sheet (3.5) with the free undos spent (the Undo row
   priced).
9. +1 Slot at its limit (2 used this level).
10. L1 tutorial's third step (the last Cherry doll into the family; 1.3 and
    1.4 cover steps 1 and 2).
11. A disabled booster, the danger button, the success banner.
12. A load failure on the splash (storage vs content).
13. Feedback for a tap on an empty, locked or iced slot with nothing
    selected (ignored today: should it shake?).
14. Highlighting the column a dragged doll hovers over.
15. The hint's dashed arc for moves other than 3.1's (e.g. to another row).
16. Whether the extra slot's pulse keeps playing under a doll placed on it.
17. Where `fx_twinkle` sits on the win overlay.
18. The family counter's label width (52 dp is a guess).
19. A designed look for the procedural fallback doll (drawn when a skin
    can't load, and on the splash's first frames).
20. The hint arrow over the middle stand of a three-stand top row (a
    variant of 3.1, call it 3.1b). The middle stand sits at x 195, right
    under the family counter pill (70×26, ending at y 142 on 390×844).
    With a tall doll there (its top near y 165, as on level 3), the
    `ui_hint_arrow` (40×50, bobbing 10 up, centred at doll top − 33)
    tucks under the pill by 10–33. It can't step aside without leaving
    its doll, or drop lower without covering the face. Show where the
    arrow goes, or what the HUD does, so they don't collide. For example,
    the pill steps aside or fades while a hint shows, the arrow points in
    from the side of the head, or a smaller arrow or shorter bob. Keep
    the arrow's look and the HUD everywhere else. Add a line to README's
    Hint section saying when 3.1b applies, and any new offset or fade
    time to `tokens.json`.
21. The +1 Slot pad's loop (`ui_extra_slot`, 3.6) opens at 96 % scale and
    75 % opacity, but the static pad it replaces draws at 100 %, so the
    hand-off pops. The game starts the loop at frame 24, where the scale is
    100 % but the opacity is still about 88 %. Make the loop's first frame
    (or a `rest` marker) match the static pad, or say which frame is its
    rest pose.

### F. Tokens to add

Values the app uses that `tokens.json` doesn't have yet:

1. Shop: each skin card's background, Buy's coin-chip face, and the skin
   detail panel's (7.4) highlight, edge and caption colour per skin (only
   Ocean's is drawn).
2. The day-7 chest modal's (5.6) glow and shadow.
3. Settings' Color symbols cards (8.1): the selected face and the ring.
4. A text-link style ("Back to Home" on 4.9).
5. The toast's auto-dismiss time, and the Shop purchase celebration's
   timing.
6. The per-theme palettes from A.3.

### G. Copy

In a new `copy.md`, each line in the tone of the existing copy:

1. Figurine family names for 4–10 (astronaut, gardener, snow, circus,
   musician, royal, explorer) as "The <Name> Family"; 1–3 are Classic,
   Sailor and Baker.
2. A one-line flavor text for every figurine (only the Sailor Family has
   one).
3. A one-line description for the Classic, Space, Sweets, Forest Friends
   and Winter skins (Ocean's is "Sailor collars, tiny anchors and wave
   trims.").
4. The four chapter names from A.2.
5. The vs Computer rivals' names and one-line personalities from C.2,
   the race's result lines (win, loss, rival unlocked, "Starting over"),
   and what a screen reader hears as the rival plays (for example "The
   computer completed a family: 3 of 5").
6. The daily share text (I.1): a spoiler-free template of a few lines
   with the date, the families as doll glyphs or emoji, the moves and
   the streak day. No board, no answers. Today's stand-in repeats one
   doll emoji (🪆) per family, at most 12, and names no colours. If yours shows each family's color, the
   11 colors need 11 distinct glyphs or emoji (there is no separate
   circle emoji for teal, blue and navy).
7. The reminder copy (I.2): the one-time offer ("Want a note when
   tomorrow's puzzle is ready?") and 2–3 notification lines, all value
   framed. Never "don't lose your streak".
8. Badge names and one-liners for these 12 badges (I.6). They are
   cosmetic only and pay nothing. Each is earned once, over the player's
   lifetime, never for consecutive days. Keep the ids; the names are
   yours:
   1. `first_family`: complete a family;
   2. `glass_breaker`: open a glass case;
   3. `ice_melter`: shatter ice;
   4. `tall_order`: win a level with size-5 dolls;
   5. `grand_nest`: win a level with size-6 dolls;
   6. `level_100`: win level 100;
   7. `level_200`: win level 200;
   8. `dailies_7`: solve 7 daily puzzles;
   9. `dailies_30`: solve 30 daily puzzles;
   10. `first_race`: win a race against the computer;
   11. `all_rivals`: beat every computer rival;
   12. `museum_full`: collect every figurine.
9. The milestone chest (I.3), relaxed mode (I.2) and the gentle streak
   states (I.7): "paused" and "relit", warm and never guilt-based.
10. The lines the stand-ins already ship as placeholders: the Museum's
    intro ("Win all 20 levels of a chapter to bring its doll family
    home."), the next family's "7 levels to go" and a locked shelf's
    "Chapter 4 · Levels 61–80" (J.2); the Chapters header's "Level 57 of
    200" (I.4); and the "Not enough coins" dialog: "Coins needed", "You
    need 250 more coins", "Coins come from winning levels, the daily
    puzzle and chests.", "Go to Shop" and "Not now" (J.3).
11. The star rating (K):
    - what a screen reader says ("2 of 3 stars");
    - the replay's target line ("3 stars at 15 moves or fewer") and "New best!";
    - the one-time tip ("Fewer moves earn more stars. Replay any level from Chapters.");
    - a chapter's total ("38/60");
    - Records' "Stars" and "Levels with 3 stars".

    Never "only", "missed", "failed" or "try again".

### H. The Forest Bear skin

`skins/forest-bear` ships but no frame sells it. If it should be sold:
its Shop card (7.3), its detail (7.4), a description and a suggested
price (800–3000 coins, spec §7.3).

### I. Engagement (a new App Flow section 10)

The owner approved these features. Each needs frames in the existing
system (the tokens, NestyMenus, NestyOverlay):

1. 10.1 **Daily share card.** A Share button on the Daily's done card
   (5.4/5.5), and a preview of the shared text as it appears in a
   message. The share is text only, through the phone's share sheet, so
   no image card is needed.
2. 10.2 **Reminder and Settings rows.**
   - A one-time offer card on the Daily's done card after the first solve:
     "Yes, remind me" with a time, and "No thanks".
   - Picking the time, from the offer and from Settings: the phone's own
     time picker, or a designed one.
   - When the player says yes but then declines the phone's notification
     prompt: what the offer card says next, and the Settings row's "off in
     your phone's settings" state with a way to open those settings.
   - The Android notification icon: a white silhouette on transparent at
     24 dp, as SVG (Android draws a coloured icon as a white square), and
     the notification's accent colour. iOS uses the app icon.
   - Today's stand-ins (phase 3), each to confirm or replace: the offer is
     a Settings-section surface under the solved card with a time chip,
     "Change time", "Yes, remind me" and "No thanks"; the time picker is
     the phone's own (Flutter's, themed only by the app theme); there is no
     button to the phone's settings (Q140), so the denied and blocked lines
     say where to turn notifications on; the Android icon is a monochrome
     doll silhouette traced from the doll art
     (`res/drawable/ic_notification.xml`) with the app's primary colour as
     the accent.
   - New rows in Settings (8.1): the daily reminder with its time,
     relaxed mode ("Unlimited free undo") and reduce motion (on, off,
     system). Draw reduce motion's three-way control (today a sheet with
     three choices).
3. 10.3 **Milestone chest.**
   - The win card (2.8) showing "3 levels to the chest" when the chest is
     nearer than the next figurine.
   - The chest modal (5.6's system) with its contents shown before
     opening.
   - A chest arrives at level 10 of every chapter and every 10th bonus
     level (default: 100 coins and a hint).
   - **Opening it should be a reward moment** (the owner's request after
     playing the build). Today the chest is a drawn icon that swaps to
     an open one. Design the moment for both the milestone chest and the
     day-7 streak chest (5.6), which share one system:
     - arrival: the chest drops in and settles;
     - idle: it breathes, a glint runs on its lock, and the contents
       stay visible;
     - anticipation: a little wiggle before it opens;
     - the burst: the lid, light, coins and sparkles;
     - the contents chips popping in one by one;
     - Collect: the coins fly to the HUD's coin pill and the hint flies
       to the Hint button, whose badge bumps.
   - **Deliver:**
     - chest art, closed and open, as SVG in the skins' allowed features
       or as 3× PNG, replacing the app's drawn chest;
     - a Lottie `ui_chest` per LOTTIE.md: a canvas the modal's chest box
       fits, with markers `arrive`, `idle` (loop), `wiggle`, `open` and
       `open_idle` (loop) and no text layers;
     - a coin-flight sprite (if the coins shouldn't be `fx_coin_burst`'s)
       and a hint-bulb sprite for the hint's flight to the Hint button;
     - the landing's dust puff and the burst's flash, if they shouldn't
       be `fx_dust_puff` and a plain white glow;
     - SFX (WAV, AUDIO.md): `chest_open` for the lid (today `whoosh`), and
       the wiggle's three rising creaks (today the doll clack at rising
       pitches);
     - the timings in `tokens.json` `motion`. The app's stand-in: the
       chest about 130 dp wide in the card; arrival 600 ms; idle breathing
       1.00–1.03 over about 3 s; wiggle 480 ms; burst 750 ms;
     - how it reads with reduce motion on (a quick crossfade, no
       wiggle or flights).
   - The coin chip during the burst: today it counts up from 0 on Open.
     Should it keep the promised amount the whole time?
   - Redraw 5.6 with its closed step first: the day-7 chest now opens
     closed, like the milestone chest, and 5.6 shows only the open one.
   - The contents are always shown before the chest opens. Nothing is
     random, and no copy says "lucky" or "mystery" (spec §1.1 rule 2).
4. 10.4 **Chapters.** A chapter list with each chapter's 20 levels, the
   won ones marked, best moves on each, locked ones dimmed. Tap a won
   level to replay it. Say where it opens from (Home, the chapter ribbon
   or the Museum).
   - **The owner's direction:** cool, clean, elegant, and a screen players
     want to come back to. Today's stand-in is a plain grid of numbered
     tiles, and it reads like a spreadsheet. Give each chapter its
     character: its theme (a crop of its background, or its palette), its
     name, and the doll family it awards, collected or waiting.
   - Show its progress, and make the current level stand out as the
     obvious next tap. Won levels, with their best moves, and locked
     levels should read at a glance. A finished chapter can fold down to
     a compact row.
   - Mark each chapter's chest level (level 10) and its finale (level 20).
     Today they are the chest icon and a sparkle.
   - Today's stand-in also has: a thin HARD or SUPER HARD edge on a won or
     current level (the tier chip's colours; never on a locked one), a
     "Level 57 of 200" line with a progress bar under the header, a short
     staggered fade-in of the cards (none under reduce motion), and the
     screen opening scrolled to the current chapter. Keep, change or drop
     each.
   - Won levels now show their best stars, and each chapter its total (K.5).
     Otherwise keep to the respect rules: nothing is locked behind stars,
     there are no nags, and "Best 16" stays a quiet personal record.
   - Draw it at 390×844 with the player in chapter 4, and show how
     200 levels stay easy to scan.
5. 10.5 **Replay win card.** 2.8 in replay: its stars (K.4), "Moves 18 ·
   Best 16", no coins (and why), with Continue returning to the chapter
   list. Also:
   - the ordinary 2.8 with its new moves line ("Moves 18 · Best 16"; the
     daily, bonus and race cards show "Moves 18" only);
   - the replay card's reason line ("A replay for fun: coins come from new
     levels.") on a surface that stays readable over the board and the
     confetti. Today it's hard to read.
6. 10.6 **Records.**
   - A Records screen: levels won, families, dolls nested, dailies solved,
     the longest unbroken streak, races won per rival, and the stars earned
     (K.5).
   - About 12 badges, earned and unearned states, as icons at 48 and
     96 px (SVG).
   - A "badge earned" toast, and where it sits over the win card. Today it
     covers the "Level Complete!" ribbon, stays up for 3 s, and lingers over
     Home after the card closes. It should stay clear of the ribbon and
     leave with the card.
7. 10.7 **Gentle streak.** The Daily tile (2.1) and the streak card (5.1)
   with the flame lit, out ("paused") and relit. A missed day never
   lowers the number, and a freeze keeps the flame lit. Also the relit
   lines on the Daily's win card (5.4: "Streak relit! Your 12-day streak
   is glowing again.").
8. 10.8 **First launch.** A new player goes from the splash straight into
   Level 1's tutorial. Optionally, the transition from 1.1 into 1.3.
9. 10.9 **Relaxed mode on the board.** The Undo button's badge when undo
   is unlimited (today a "∞" stand-in), and the Out-of-Moves sheet (3.5)
   with its Undo row always free.
10. **Icons.** The app's icon font is a subset of Material Symbols Rounded
    (FILL 1, weight 600). Name a glyph for:
    - Chapters and Records (the Home entry points);
    - Share, the reminder and its time row, relaxed mode and reduce
      motion (today Share stands in with `download`, and the offer and
      both reminder rows with `calendarToday`);
    - the Records rows (the best-moves link; each rival's row);
    - the chapter finale mark on Chapters (today a sparkle: the subset
      has no flag or trophy). Now that stars exist (K), it must not read
      as a rating star;
    - the computer tag (C.8).

    Draw an SVG only where no glyph fits.
11. Every new value in `tokens.json`, and new copy in `copy.md` (G.6–G.10).

### J. The owner's review of the build (changes to existing frames)

The owner played the current build and asked for these:

1. **Home (2.1) without the Museum tile.** The bottom nav's Museum tab is
   the way in, so the tiles are Daily, Remove Ads (hidden once bought) and
   the vs Computer tile (9.1). Home also needs a place for Chapters and
   Records (today a row of two buttons under the top bar). Redraw 2.1 with
   them, at 390×844 and on a short 16:9 screen.
2. **The Museum (6.1–6.3), redesigned.** The owner found the current screen
   hard to understand and flat. Redesign it so that:
   - a new player sees at a glance what it is: a shelf of doll families,
     one per chapter;
   - it's clear how a family is earned: win all 20 levels of its chapter;
   - the next family to earn is the focus, with its progress and a way to
     go and play;
   - it feels like a cozy collection worth visiting: light, depth, a
     little life on the collected families, and their names and one-line
     stories (G.1, G.2).

   Show it with 0, 3 and all 10 families collected. Say whether 6.2 (the
   detail) and 6.3 (a locked family) change. Name each locked shelf by its
   chapter and its levels (for example "Chapter 4 · Levels 61–80"). Today
   that label shrinks to about 9 px to fit a phone. Choose its size, wrap it
   onto two lines, or give a shorter form. Add
   any Lottie idle loop per LOTTIE.md. Today's stand-in puts the next
   family's silhouette, name, "7 levels to go" and a Play button above the
   shelf; the owner's own example read "Chapter 4 · 7 levels to go": say
   which.
3. **Not enough coins.** A tap on a price the player can't cover (a skin,
   a theme or a booster) should open a small dialog before anything else,
   instead of jumping straight to the Shop. It shows:
   - the price and how many more coins are needed;
   - where coins come from: wins, the daily puzzle, chests;
   - "Go to Shop" (its Coins tab) and "Not now".

   Keep the copy warm and plain: no urgency, and no "only today". Draw it
   over 7.3 (a skin card) and 7.4 (the skin detail). Say whether the
   booster popup (3.2) should use it too: today its coin button is simply
   disabled when the price can't be covered (3.8).

### K. Star rating (a new App Flow section 11)

The owner added star ratings after playing the build, and chose the rules:
- **Stars:** every win of levels 1–200, first play or replay, earns 1, 2 or
  3 stars. 3 is the most.
- **How they're earned:** from the win's moves against par, the fewest moves
  that solve the level. 3★ within par + 20 %, 2★ within par + 60 %, and 1★
  for any win. For par 12: 3★ at 15 moves or fewer, 2★ at 20.
- **Help:** a win that used a hint or +1 Slot earns at most 2★, so stars
  can't be bought. Undo and restart never count against stars.
- **Best stars:** a level keeps its best stars, and a replay can raise them.
- **Cosmetic:** stars never pay, unlock or gate anything, and nothing about
  them shows during play (no meter). The daily, Bonus Endless and race boards
  show moves only.

The research worry is that "stars make a win feel like a 1-star failure". A
1★ win must still read as a win:
- the stars sit inside the celebration and never replace it;
- empty stars are soft outlines in the card's own colours, never grey or
  red;
- no copy says "only", "missed" or "try again".

1. 11.1 **The star.** Filled and empty, as SVG in the skins' allowed features.
   The app's sizes are about 44 dp on the win card, 20 dp on the Chapters
   cards and Records, and 11 dp under a Chapters level cell. It must not look
   like the Grape dolls' star symbol (`symbols/star.svg`, purple): for
   example gold, rounder, with a highlight. Add a 3★ state, such as a glow
   or a ring.
2. 11.2 **The win card (2.8) with 1, 2 and 3 stars.** Where the stars sit
   relative to the ribbon, the moves line ("Moves 18 · Best 16"), the coins,
   and the chest or figurine progress. Draw all three at 390×844 and on a
   short 16:9 screen.
3. 11.3 **The reveal.** The stars pop in one by one after the card lands,
   each with a sound and a light haptic, and 3★ ends with a small flourish.
   Deliver:
   - a Lottie `ui_stars` per LOTTIE.md, with markers `star_1`, `star_2`,
     `star_3` and `flourish`, and no text layers;
   - SFX `star_1`, `star_2` and `star_3` (WAV, AUDIO.md), rising;
   - the timings in `tokens.json` `motion`;
   - how it reads with reduce motion on (the stars appear at once).

   Today's stand-in is a scale pop per star, 120 ms apart, with the doll
   clack at rising pitches and a light haptic each. It starts when the
   coin count-up ends (1,300 ms after the card opens), so it never plays
   over the win jingle's loud part or the coin burst, and 3★ ends with a
   hand-painted sparkle glow and a success haptic, no sound (a stand-in
   for `fx_twinkle`). With reduce motion the stars show at once, and the
   three clacks and haptics still play, 60 ms apart, as every cue does at
   half its stagger (D48): say if they should be silent (Q146).
4. 11.4 **A replay's card (10.5).** Its stars, "New best!" when they rise,
   and, below 3★, the target line ("3 stars at 15 moves or fewer"). A
   level's first win never shows the target. Also:
   - the one-time tip, shown the first time a win earns fewer than 3★
     ("Fewer moves earn more stars. Replay any level from Chapters.");
   - if a hint or +1 Slot kept a win at 2★, whether the card says so, and
     how, without blame.
   - where the star row sits between the coin pill (or the replay's
     reason pill) and the card: on a phone it lies over the board's middle
     shelf under the scrim;
   - the tallest replay card, with the target line and the tip, pushes
     "Back to Chapters" onto the dimmed booster bar on a 19.5:9 phone.
5. 11.5 **Chapters (10.4) and Records (10.6) with stars.**
   - Each won level's best stars under its cell.
   - Each chapter's total (for example 38/60), on its card and on a folded
     chapter's row. Today's stand-in is one 20 dp star beside the numbers,
     shown on every card, even at 0/60.
   - A chapter with every level at 3★.
   - Records' total (of 600) and "Levels with 3 stars".
   - Optionally, the total on Home's Chapters entry (J.1).
6. Every new value in `tokens.json` (the star colours, sizes and motion),
   and the copy in `copy.md` (G.11).

### Delivery: the download folder

The owner hands each delivery to the game exactly as it downloads, so the
folder has to follow this format.

**1. Name.** `nesty-design-m7-1`, then `-2` and `-3`, in the order at the
end. Each part is cumulative: it holds everything from the earlier parts, so
the latest folder is always complete. A partial delivery is fine.

**2. Layout.** The handoff's own root, with every file, changed or not:

```
nesty-design-m7-N/
  DELIVERY.md       new: what this part contains (item 5)
  README.md         whole: "Latest changes" and "Screens" updated
  tokens.json       whole: the single source of values
  copy.md           new: all the copy (item 6)
  audio/            with AUDIO.md, whole
  board/
  generator/
  lottie/           with LOTTIE.md, whole, and images/ as before
  museum/
  prototypes/       Nesty App Flow.dc.html whole, with sections 09, 10 and 11
  skins/
  store/
  symbols/
  themes/
  ui/               new: UI art that isn't board, skin, theme or museum art
    badges/  chest/  icons/  notification/  rivals/  sprites/  stars/
```

**3. File names.** New files are lowercase snake_case; `board/` keeps its
kebab-case.

| Item | Files |
|---|---|
| A.1 | `themes/ch07_<slug>.svg` … `themes/ch10_<slug>.svg`, where the slug is the chapter's name (for example `ch07_circus_big_top.svg`) |
| A.3, A.4, F and every new value | `tokens.json` |
| A.5 (optional) | `board/ch07/` … `board/ch10/`, each holding the `board/` file names it replaces |
| B | new board pieces in `board/`; the presets in `prototypes/NestyBoard.dc.html` and in `tokens.json`'s `layout` |
| C.2 | `ui/rivals/rival_1.svg`, `rival_2.svg`, `rival_3.svg`, `rival_locked.svg` |
| C.6 (optional) | `lottie/ui_rival_react.json` |
| C.7 | `audio/jingle_versus_win.ogg`, `audio/jingle_versus_lose.ogg`, `audio/rival_complete.wav` |
| D | `lottie/ui_intro_towers.json`, `lottie/ui_intro_glass.json`, `lottie/ui_intro_ice.json` |
| G, and H's description and price | `copy.md` |
| I.2 | `ui/notification/ic_notification.svg`: a 24×24 viewBox, white on transparent |
| I.3 | `ui/chest/chest_closed.svg`, `ui/chest/chest_open.svg`, `ui/sprites/coin_flight.svg`, `ui/sprites/hint_flight.svg`, `lottie/ui_chest.json`, `audio/chest_open.wav`, `audio/chest_wiggle.wav` |
| I.6 | `ui/badges/<id>.svg` and `ui/badges/<id>_locked.svg` for each of G.8's 12 badge ids, on a 96×96 viewBox |
| I.10, C.8 | the glyph names, in `tokens.json` (an `icons` map from each use to its glyph) and in README; `ui/icons/<name>.svg` only where no glyph fits |
| K.1 | `ui/stars/star_filled.svg`, `ui/stars/star_empty.svg`, `ui/stars/star_glow.svg` |
| K.3 | `lottie/ui_stars.json`, `audio/star_1.wav`, `audio/star_2.wav`, `audio/star_3.wav` |
| Every frame | `prototypes/Nesty App Flow.dc.html` |

Where a PNG replaces an SVG, keep the name and end it in `@3x.png` (for
example `ui/chest/chest_closed@3x.png`).

**4. What the game's import checks.**
- **SVGs** use the skins' subset (spec §12.2): paths, groups, gradients,
  opacity and clipPath only, every id unique. No filter, mask, text (outline
  it instead), image, `<style>`, `style="…"` or nested `<svg>`.
- **Sounds:** every new sound is named by a `tokens.json` `sound` event (or
  a music track) and has its AUDIO.md row. The import rejects an audio file
  no token names. SFX are 44.1 kHz mono WAV, and jingles and loops are OGG,
  as AUDIO.md says.
- **Lottie:** every new file has its LOTTIE.md row (canvas, anchor, frame
  count, markers) and uses only v3's allowed features.
- **Whole files:** `tokens.json`, `README.md`, `LOTTIE.md`, `AUDIO.md` and the
  App Flow file are always delivered whole, never as fragments.
- **Nothing moves:** existing files keep their names and places, and nothing
  is removed unless DELIVERY.md says so.

**5. DELIVERY.md** lists:
- every file this part adds or changes, one row each: `path | new or
  changed | request item (for example K.3) | note`;
- the request items still to come;
- anything removed or renamed (ideally nothing);
- each choice the request left open, and what this part chose (for example,
  9.6 as a toast or as a card).

**6. copy.md.** One section per G item (`## G.1` … `## G.11`), and one line
per string: `- <id>: <text>`.
- Use the ids the request gives (the badge ids, the rival numbers, the
  chapter numbers), and otherwise a short slug.
- Keep placeholders exactly as the request writes them (`{count}`,
  `{moves}`).
- Write a plural as two lines, `one:` and `other:`.

**7. Order.** The order that unblocks the game fastest:
- first A, B (items 3–7) and G;
- then I, J, K and C;
- then D, E and F.

## Follow-up after m7-3

Written 2026-09-30 by the M7 phase 4 integrator, from the gaps the
contracts stages and the five lanes found while building
`nesty-design-m7-3` into the game (PROGRESS D173–D208; architecture lead
note 13). The request above is fully delivered; this is a separate,
smaller prompt. Paste everything below the line into Claude Design, in the
same Nesty project.

---

### Nesty: follow-up to nesty-design-m7-3

Thank you for m7-3. The game now draws all of it: the ten themes and
palettes, the board presets and the tall pieces, vs Computer (section 09),
the engagement screens (10), the stars (11), the states (12), the 35 Lottie
files, the 8 new sounds, the UI art, the icons and the copy. Building it
turned up the gaps below. Each item says what the game ships today ("The
game ships"). For each one, either change the handoff, or answer "keep",
and the game keeps what it ships. None of them changes a game rule: prices,
rewards, limits and unlocks stay as the game has them.

Deliver the answers as `nesty-design-m7-4`, cumulative and in m7-3's format
(the "Delivery" section of the round's request: the whole handoff root,
`tokens.json`, `README.md`, `LOTTIE.md`, `AUDIO.md` and the App Flow file
whole). In DELIVERY.md, list only what changed, and put each "keep" under
"Choices". A partial delivery is fine; items 1, 2 and 3 unblock the most.

#### 1. Tokens (`tokens.json`)

1. **Icons.** Add the splash errors' glyphs to `icons`: `sd_card_alert`
   (12.10, storage) and `inventory_2` (12.11, content). The game ships
   both from the font, outside the map.
2. **Frame-only colours.** Each is drawn in a frame but has no token. Add
   each to `color` (or say which existing token it is):
   - the toast kinds: success `#EAF7EC` / `#A6DDB3` / `#46A758`, info
     `#E8F3FF` / `#9CC4EA` / `#3E8EDE`, badge `#FFF7E0` / `#E6C36A` /
     `#F5C518` (face, ring, accent);
   - the peach streak card: face `#FFF2E6 → #FFE7D0`, edge `#E6B79A`
     (10.7);
   - the settings divider `#F0E0C4` (10.2e);
   - the locked Chapters row's name `#8A6A4E` (10.4; the game ships
     `color.textMuted`);
   - the splash error card's dim over the art (12.10, 12.11);
   - the disabled booster's sunk face and its "+1" tag, and the +1 Slot
     limit badge (12.9, 12.12);
   - the Records stat tiles' and Settings' icon-tile tints (10.6, 10.2e);
   - everything still hard-coded in the game's `AppColors`: `iconBrown`,
     `textBrown`, `chevron`, `closeFill`, `closeShade`, `disabledFace`,
     `disabledText`, `disabledCoin`, `coinChipTop`, `coinChipBottom`,
     `coinChipEdge`, `adClaimedFace`, `adClaimedRing`, `superHardChipText`,
     `dailyText`, `dailyChipFace`, `sheetGrabber`, `divider`,
     `iconTileGreen`, the day strip's `day*` faces, rings and dots, the
     chest's `chest*` body, lid, ring, lock and glow, `freezeChipText`,
     `symbolsCardSelectedFace`, `symbolsCardRing`, the Museum's `walnut*`,
     `shelfFace*` and `spotlight*`, `warningHighlight`, `dangerHighlight`,
     `successBannerFace`, `successToastTitle`, `successToastMessage`,
     `infoFace`, `infoEdge`, `infoTitle`, `infoText`, `cream`,
     `playDiscShade`, `playCaption`, `woodBarHighlight`, `woodBarShadow`,
     `loaderTop`. Give each a name in `color`, or say it can go.
3. **`color.starEmpty`** is an art reference inside the colour map. Move
   it out, or give the empty star's outline colour.
4. **Text links.** `textLink.minTapHeight` is 44; the game's rule is a 48 dp
   hit box, so it keeps the look and a 48 dp box. Add `textLink.pressed`
   (the game ships `#6E4526`, `color.computerTagText`), and the orange
   variant that 10.2's "Change time" uses.
5. **Toasts.** `motion.toast` names the tops 60, 152 and 124. Add the
   app-wide toast's place (frames 5.2 and 8.3 put it 58 below the safe
   top; the game ships that) and the toast geometry (padding, radius,
   icon size).
6. **The first-launch fade** (10.8): the game ships 400 ms `easeOut`, a cut
   under reduce motion. Add it to `motion`.
7. **Chest flights** (10.3c, 10.3d): the gold ring the coin pill shows as a
   coin lands, and the 6 dp trail dots, as values. The game ships the
   flights without them. Also the open card's rays: the game turns them once
   in 24 s.
8. **`layout.fallbackDoll`:** "circle, 0.36 h", "disc, 0.19 h" and "disc
   0.2 h": diameters or radii? The game reads them as diameters (12.12).

#### 2. Copy (`copy.md`)

1. **Lines a frame shows with no id.** Give each an id, or confirm the
   frame's text:
   - "Ready when you are" (9.3, the strip before Start);
   - "vs Computer · {rival}" (9.7, the race Pause's header);
   - "Setting up the shelves…" (12.5);
   - "Owned" (an owned skin card, read after its name);
   - "Free" (10.9b, the relaxed Undo row's chip);
   - "Suggested" (12.7, under the glowing Restart);
   - "+{count}" (10.3d, the green tag on a booster that gained one);
   - "Full House · all 10 families" (6.1c);
   - "2 days to go" (the Daily's chest row);
   - `chapter_stars_total_all: {count}/600` (Home's Bonus chip);
   - `reminder_not_now` on the denied card, or say it reuses
     `coins_needed_later`.
2. **Numbers the game owns.** These lines hard-code a number the game reads
   from its rules or Remote Config. The game ships each with a placeholder
   and the rule's number, so a tuning change can't contradict the copy.
   Please write them with the placeholder:
   - `museum_intro` "20" levels → `{levels}`;
   - `oom_undo_spent` "2" free undos → `{count}`;
   - `records_*_value` "10" and "600" → `{count}` / `{total}`;
   - `slot_limit` "Two" extra slots → `{count}`.
3. **Rival lines and the respect rules.** Four lines use words the game's
   copy rules reject elsewhere: "Slow" (`rival_1_skill`, `rival_2_skill`),
   "Quick" (`rival_3_skill`, `rival_3_personality`), "before"
   (`rival_2_personality`, `race_win_body`), and "ends" and "lost"
   (`race_quit_body`). They describe the computer, never the player, so the
   game ships them with exemptions for those lines only. If you prefer, send
   alternatives without those words.
4. **`records_three_star_levels`** ("Levels with 3 stars", G.11) has no
   cell in frame 10.6. The game dropped the line; confirm, or draw the cell.
5. **Frames that still say "OF 2".** Frames 1.3, 1.4 and 10.8b read "STEP 1
   OF 2" and "STEP 2 OF 2"; copy.md E says "STEP {step} OF 3" on all three
   Level 1 steps, which the game ships. Update the frames.
6. **The share text's date** (G.6) is given only by example ("Sep 30"). The
   game ships the locale's month and day (`MMMd`). Confirm.
7. **The reminder's default time.** Frame 10.2 shows "7:00 PM"; the game
   proposes the hour the player solved the daily (the owner's rule, Q81).
   Confirm 7:00 PM is an example.

#### 3. Screen-reader strings

copy.md has none for these; the game ships its own. Send the final wording:
- a locked badge's how-to (10.6: shown only to a screen reader, or also
  visible?);
- Chapters' level cells: won with best moves and stars, the current level,
  locked, the chest level and the finale level; a folded chapter's row and a
  locked one;
- the chest's contents before Open (5.6, 10.3);
- the daily win card's Share button ("Share today's result");
- the Android notification channel's name and description;
- Home's chapter card, Bonus card and vs Computer tile; the Museum's
  niches (collected, next, locked) and its count; the Records stat cells and
  race rows;
- rival select's "Beaten" and "Start race against {rival}";
- the Reduce motion control's group name, the reminder offer's time chip,
  and "+Slot, 2 of 2 used" (12.9).

#### 4. Frames and looks to confirm

Each has a default the game ships; answer "keep" or change it.
1. **9.6 "New rival unlocked!"** Built as a card that comes before 9.4's
   chosen action (any button, or system back), once per rival; its New
   race races the rival it unlocked. Does it interpose or replace 9.4? Does
   `jingle_reward` play? (The game plays nothing.)
2. **9.7b "Keep racing"** resumes the race (the whole Pause closes). Or
   back to the Pause card?
3. **9.4 and 9.5 in versus colours.** `ui_win_ribbon` has no fills the game
   can tint, so it draws a versus ribbon of its own. Send a versus variant
   of the file, or name its fills.
4. **The rival strip.** "The state line hides below 340" and "the tag is
   glyph only below 360": screen width (built; the strip is 298 wide on a
   390 screen) or the strip's own width? And the dots at 9 or more families
   (built: 6 dp with a 2 dp gap).
5. **Rival select.** After the player picks a rival and comes back, which
   card is selected? (Built: the pick lasts for the visit, then the newest
   "New" rival again.)
6. **9.5's plank when the player completed no family:** an empty plank
   (built) or no plank? And 9.3f: confirm the versus tone and the 52 dp
   `refresh` on the versus disc.
7. **Home between 700 and 844 dp tall.** 2.1 is 844 and 2.1b is the 16:9
   body; built as a straight blend of every number between them. Confirm,
   or give the breakpoint.
8. **Chapters.** A finished chapter's row opens as an accordion, and a tap
   on the open chapter's header folds it (built; undrawn). Below 380 dp or
   at 1.3× text a folded row hides its figurine so the name and the
   kicker's two or three lines fit. The chest and flag marks at 1.3× text.
   Draw these, or keep.
9. **"Best moves by level"** (10.6) has no destination frame; the link
   opens Chapters today.
10. **Home's relit ring** (10.7b's glow on the streak badge): built only
    while Home stays open across the Daily win. Should it show when the win
    was in an earlier session?
11. **The Shop.** Space's detail chip on the dark edge needs more contrast.
    Frame 7.2 draws a purchase's "card in" only for coin packs: what does a
    skin or theme purchase show besides the jingle?
12. **The win card on a short screen.** `winStarsShort` hides the tip; the
    game also hides the helper note ("Wins with a hint or an extra slot
    earn up to 2 stars.") on the 16:9 card and switches to it below 760 dp
    of screen height. Confirm both.
13. **12.6 "The shelves need a moment".** The frame shows only the theme
    art behind the card; the game keeps the board dimmed behind it.
    Acceptable?
14. **The family counter's hug** (`layout.hud.familyCounter`): the
    `ui_family_counter` pill is a fixed 70 dp, so the game scales it 0.9 to
    1.2 to hug "4 / 4" (64) and "12 / 12" (78). Send a file whose pill
    takes any width, or keep.
15. **4.7, the chapter ribbon.** The game tints the one-line
    `ui_chapter_ribbon` with the chapter's palette. Does frame 4.7's
    two-line plate replace the Lottie? If the Lottie stays, name its band
    and edge fills so the game can recolour them exactly.
16. **The Settings reminder row.** No frame shows it Off, and in the
    blocked state (10.2f) the toggle is drawn off and opens the phone's
    settings, so nothing in the app turns a blocked reminder off. Draw the
    Off row, and say whether the blocked row needs a "Turn off" link. The
    segmented Reduce motion control is 44 tall in 10.2e; the game makes it
    48 so each segment is a 48 dp target.
17. **Frames no one drew:** the Daily screen before the solve with a paused
    card; the freeze-used line on the Daily card (the game shows only 5.2's
    toast); the relit twinkles' place on the daily win card (10.7b);
    whether "Reminder set" has a sound or haptic (none shipped); 12.5's
    reduce-motion spinner (the game shows frame 0; a slow pulse?).
18. **The toasts' timing:** the relaxed toast once per launch, and the +1
    Slot limit toast once per level (your proposals, shipped). Confirm.

#### 5. Board

1. **Rows of 5 and 6 with tall pieces.** A tall glass case, its ice, and a
   row of 6 (a second +1 Slot on a 4-slot bottom shelf, built by
   `rowOfFive`'s formulas) aren't drawn anywhere. The game caps the tall
   case at the pitch − 2 dp, and a 96-wide ice can overlap a neighbour by up
   to 2.4 dp. Draw them, or keep.
2. **`fourShelves`** has no glass or ice sizes; the pieces scale with the
   dolls. The 1-shelf preset is still undrawn.
3. **The tower stack.** `layout.towerStack` grows each silhouette
   (`h + step × depth`); the game keeps true sizes, each base raised by the
   step (D21). On the tall preset the top doll of a 3-deep tower sits 3 dp
   under the family counter, not `hudClearY`'s 8. Confirm.
4. **The hint arc.** Frame 3.1 draws a dotted quadratic arc through the
   doll; `layout.hintArc` (and frame 12.13) is a dashed cubic arch. The game
   ships the tokens' arch, with no arrowhead. And `layout.hintMiddle`: when
   the arrow over the middle top stand also reaches the Pause row, what
   happens? (Nothing today.)
5. **The padlock ping** (E.13): the golden lock is part of the case art, so
   the game scales only the unlock symbol. Confirm, or split the lock out.
6. **The normal glass case** reaches 0.7 dp into the plank above (top 351.3
   under a plank ending at 352). Intended?

#### 6. Lottie and art

1. **LOTTIE.md "Doll size"** says the game overrides every `<role>_size`,
   but the three `ui_intro_*` loops animate `mover_size`, `family_size` and
   `family_2_size` themselves. Say in LOTTIE.md that those are authored and
   never overridden, or move the shrink onto a parent null.
2. **`ui_intro_glass`'s padlock symbol** is 26.67 % (9.6 dp), not the
   board's 12 dp. Document it, or match the board.
3. **The intro loops' tags** ("+2", "+1", the ice count): the files have no
   text layers. Confirm the digits are drawn in the art.
4. **The open chest's box.** `ui/chest/chest_open.svg` is 180×150, but
   frame 5.6's open chest sits in a 200×170 box. Which is right? And the
   chest card's top: `layout.chestCard.card.top` is 214, frame 10.3b draws
   168 (the game ships 214).
5. **The relaxed Undo tag** "Free, as often as you like" (10.9b) overflows a
   360 dp sheet at 1.3× text; the game scales it down. Draw 10.9b's layout
   for a long tag.

#### 7. Housekeeping

1. README's "m7 adds" glyph list is missing a comma ("all_inclusive
   (unlimited Undo) redeem (chests)") and names 18 glyphs, where m7-2's
   DELIVERY counted 17.
2. The toast colours, the text link's pressed state and the icons above
   also appear in README's "Components": keep the two in step.
