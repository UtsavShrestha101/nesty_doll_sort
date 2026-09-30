# nesty-design-m7-3

The whole m7 round in one folder: A, B and G (part 1), I, J, K and C (part 2), and D, E and F (part 3), plus H. The folder is the handoff root: every file from earlier deliveries, plus everything m7 adds or changes. Open `prototypes/Nesty App Flow.dc.html` over http for all 132 frames.

## Files added or changed

| path | new or changed | request item | note |
|---|---|---|---|
| `DELIVERY.md` | changed | – | this file: all of m7 in one cumulative folder |
| `tokens.json` | changed | A.3, A.4, B, C.10, I.10, I.11, K.6, E, F | v3, additive: `theme`, the board layout keys (m7-1); `icons`, `versus`, `chest`, `shop`, `chestModal`, `settings`, `textLink`, new colors, `layout.*` for every new screen, `motion.stars`, `chest`, `rivalMove`, `rivalDot`, `toast`, `purchase`, `tapFeedback`, `dragHover`, `extraSlot`, 8 `sound.events`, `sound.musicDuck.raceResult` |
| `README.md` | changed | all | Latest changes (m7-1, m7-2, m7-3), Bundle, Components, Screens 2.1, 5.6, 6.1, 7.3b–7.4c and sections 09–12, icons, routes, motion, sound, 3.1b |
| `copy.md` | new | G.1–G.11, H, E | one section per G item plus H and E |
| `audio/star_1.wav`, `audio/star_2.wav`, `audio/star_3.wav` | new | K.3 | rising E6, G6, C7 |
| `audio/chest_wiggle.wav`, `audio/chest_open.wav` | new | I.3 | three rising creaks; lid, chink and sparkle |
| `audio/rival_complete.wav` | new | C.7 | the computer completes a family |
| `audio/jingle_versus_win.ogg`, `audio/jingle_versus_lose.ogg` | new | C.7 | −17 dBFS RMS, −1.4 / −1.6 dBTP |
| `audio/AUDIO.md` | changed | C.7, I.3, K.3 | files, levels, jingles, music rules and the SFX m7-2 table |
| `generator/nesty-sfx.js`, `generator/nesty-music.js` | changed | C.7, I.3, K.3 | synthesize the new sounds |
| `lottie/ui_stars.json` | new | K.3 | 240×110; `star_1`, `star_2`, `star_3`, `flourish` |
| `lottie/ui_chest.json` | new | I.3 | 200×200; `arrive`, `idle`, `wiggle`, `open`, `open_idle` |
| `lottie/ui_intro_towers.json`, `lottie/ui_intro_glass.json`, `lottie/ui_intro_ice.json` | new | D | 302×230 loops for 4.1–4.3, no text layers |
| `lottie/ui_extra_slot.json` | changed | E.21 | frame 0 (marker `rest`) matches the static pad |
| `lottie/images/star_filled.png`, `lottie/images/star_empty.png`, `lottie/images/star_glow.png`, `lottie/images/chest_closed.png`, `lottie/images/chest_open.png` | new | I.3, K.3 | placeholders at their declared sizes |
| `lottie/LOTTIE.md` | changed | B.4, D, I.3, K.3, E.21 | changes m7-1…m7-3, Files, When, Image slots; 35 files |
| `ui/stars/star_filled.svg`, `ui/stars/star_empty.svg`, `ui/stars/star_glow.svg` | new | K.1 |  |
| `ui/chest/chest_closed.svg`, `ui/chest/chest_open.svg`, `ui/sprites/coin_flight.svg`, `ui/sprites/hint_flight.svg` | new | I.3 |  |
| `ui/rivals/rival_1.svg`, `ui/rivals/rival_2.svg`, `ui/rivals/rival_3.svg`, `ui/rivals/rival_locked.svg` | new | C.2 | usable at 96 and 48 |
| `ui/badges/<id>.svg`, `ui/badges/<id>_locked.svg` | new | I.6 | the 12 G.8 ids, 96×96 viewBox |
| `ui/notification/ic_notification.svg` | new | I.2 | 24×24, white on transparent |
| `prototypes/NestyHub.dc.html` | new | C, I, J, K, E | the m7 screens (Home, rivals, Chapters, Museum, Records, Settings, sheets, system UI) |
| `prototypes/NestyMeta.dc.html` | new | C, I, J, K, E | the m7 overlays (win cards, race results, chest, dialogs, toasts, sheets) |
| `prototypes/Nesty App Flow.dc.html` | changed | all | 132 frames: 2.1 / 2.1b, 5.6 / 5.6b, 6.1–6.1c, 7.3b, 7.4b, 7.4c redrawn or added; sections 09, 10, 11 and 12 |
| `prototypes/NestyBoard.dc.html` | changed | B, C | m7-1 scenes; race scenes and the `short`, `rival`, `lvl`, `tier` props |
| `prototypes/NestyShop.dc.html` | changed | H | the Forest Bear card and `skinDetailBear` |
| `prototypes/Nesty Soundtrack.dc.html` | changed | C.7, I.3, K.3 | plays the 8 new files |
| `prototypes/Lottie FX.dc.html` | changed | B.4, D, I.3, K.3 | plays all 35 files |
| `prototypes/nesty-sfx.js`, `prototypes/nesty-music.js` | changed | C.7, I.3, K.3 | copies of the generators |
| `prototypes/ui/` | new | C, I, K | copy of `ui/` that the pages load |
| `themes/ch07_puppet_theater.svg` | new | A.1 | Puppet Theater, 1290×2796, paths and gradients only |
| `themes/ch08_autumn_bandstand.svg` | new | A.1 | Autumn Bandstand |
| `themes/ch09_castle_library.svg` | new | A.1 | Castle Library |
| `themes/ch10_sunrise_lookout.svg` | new | A.1 | Sunrise Lookout |
| `board/glass-case-tall-0.svg` | new | B.4 | tall case for a size-5 or size-6 doll, intact |
| `board/glass-case-tall-1.svg` | new | B.4 | cracked |
| `board/glass-case-tall-2.svg` | new | B.4 | shattered |
| `lottie/fx_glass_unlock_tall.json` | new | B.4 | the unlock for the tall case; `case_size` and `doll_size` = h / 150 |
| `lottie/images/glass_case_tall_0.png` | new | B.4 | placeholder, 279×456 |
| `lottie/images/glass_case_tall_1.png` | new | B.4 | placeholder, 279×456 |
| `lottie/images/glass_case_tall_2.png` | new | B.4 | placeholder, 279×456 |
| `prototypes/Nesty Board Presets.dc.html` | new | B | every new scene with its measurements |
| `prototypes/Nesty Chapter Themes.dc.html` | new | A | the ten themes with their palettes, ribbons and Shop crops |
| `prototypes/backgrounds/ch7-puppet-theater.svg` | new | A.1 | copy the prototype pages load |
| `prototypes/backgrounds/ch8-autumn-bandstand.svg` | new | A.1 | copy the prototype pages load |
| `prototypes/backgrounds/ch9-castle-library.svg` | new | A.1 | copy the prototype pages load |
| `prototypes/backgrounds/ch10-sunrise-lookout.svg` | new | A.1 | copy the prototype pages load |
| `prototypes/skins/classic/board/glass-case-tall-0.svg` | new | B.4 | copy the prototype pages load |
| `prototypes/skins/classic/board/glass-case-tall-1.svg` | new | B.4 | copy the prototype pages load |
| `prototypes/skins/classic/board/glass-case-tall-2.svg` | new | B.4 | copy the prototype pages load |

## Still to come
Nothing. Not delivered, both optional: C.6 (a rival reaction Lottie: the strip's dot fill and move nudge carry it) and A.5 (per-theme shelf art: the shared wood reads well on every theme).

## Removed or renamed
Nothing. Frames 2.1, 5.6 and 6.1 are redrawn in place, as J and I.3 ask.

## Note on SVGs
Every SVG saved from this project carries a `<metadata>` content-credentials block after the root tag (ch01–ch06 had it too). It draws nothing. If the import rejects `<metadata>`, strip that one element; everything else uses paths, groups, gradients, opacity and clipPath only.

## Choices this round made

**C · vs Computer**
- Own colour: indigo `gradient.versus` (#7B8BEF → #4E5FD9, edge #3242A8), apart from the bonus teal.
- Rival strip: 48 dp in the HUD row (top 62), replacing the level and coin pills. The soft-stuck banner stays at 152, under the family counter, so they never meet. The board fit keeps every doll below y 150, so no doll passes under the strip on 390×844 or 16:9, and the strip takes no board taps.
- Start sits in the booster bar over slots 2–3; no countdown.
- A race board that fails to generate shows 9.3f: Try again (same rival, new board) or Back to races.
- Pause (9.7): Settings stays reachable; Leave race asks once (9.7b).
- 9.6 is a card, shown once per rival as 9.4 closes; the rival keeps a "New" mark in 9.2 until raced (9.2b).
- Records rows show the rival portraits (40 dp) instead of icons.
- After a player win the strip reads "You finished first".
- Toasts on 9.4 sit above the ribbon at y 60, one at a time for 2.5 s, and leave with the card.
- On narrow screens the Computer tag drops to its glyph below 360 dp, then the state line below 340.
- Each rival move nudges the portrait (1.06, 160 ms); no sound or haptic. Reduce motion: "Thinking…" without dots or nudge.
- 9.4 keeps 2.8's confetti, coin burst and count-up and plays `jingle_versus_win` instead of `win`; 9.5 has no confetti and plays `jingle_versus_lose`; both duck the music to 0.3.

**I · Engagement**
- Share sits on the daily win card (5.4 → 10.1); 5.5 is unchanged.
- The time picker is the phone's own. If the prompt is declined, the offer card turns into "Notifications are off for Nesty" with Open phone settings, and the Settings row reads "Off in your phone's settings" with the same button (this replaces the stand-in's text-only line). Android accent #F2893B.
- Chest: the coin chip shows the promised amount the whole time; the dust puff is `fx_dust_puff` and the flash is `ui_chest`'s own; reduce motion is a 200 ms crossfade with no wiggle or flights. 5.6 is redrawn closed first (5.6, 5.6b).
- Chapters opens from Home's chapter card, scrolled to the current chapter. Kept from the stand-in: tier edges on won and current levels only, "Level N of 200" with its bar, and a short staggered fade-in (none with reduce motion). The chest level uses the chest art and the finale the `flag` glyph.
- Replays pay no coins and say why on a solid card. A first win shows "Moves N"; "Best" appears once there is an earlier win.
- First launch fades from the splash straight into Level 1 (400 ms).
- Relaxed mode's Undo badge is `all_inclusive`.

**J · the owner's review**
- Home: the chapter card (with its star total) and a Records button sit above the hero; the tiles are Daily Puzzle, vs Computer and Remove Ads.
- Museum: the next family is the focus, with "Chapter 4 · 14 levels to go" (the owner's form); locked shelves read "Chapter N" / "Levels a–b" on two lines at 11 px; collected families bob gently under warm light instead of a new Lottie. 6.2 and 6.3 are unchanged.
- The booster popup (3.2) opens Not enough coins too when online; offline, 3.8 is unchanged.

**K · Stars**
- The stars sit between the ribbon and the families; the moves chip joins the coin row.
- The reveal starts when the coin count-up ends (1,300 ms), as in the build, so it never plays over the win sound or the coin burst.
- Q146: with reduce motion the stars appear at once with one sound (the highest star earned) and one light haptic.
- A helper cap shows the neutral note "Wins with a hint or an extra slot earn up to 2 stars." If the tip would show on the same card, the note wins and the tip waits.
- The tallest replay card (target and tip) ends at 732, above the booster bar at 734.

**E · States**
- E.1: the 16:9 Home rule is approved (tiles 12 dp above the nav, hero scaled 0.82).
- E.3: a streak is never lost; a missed day without a freeze pauses it (10.7).
- E.4: Home has no Museum tile since J.1.
- E.13: taps on an empty, locked or iced slot never shake: a 2 dp dip, a padlock ping or a counter bump.
- E.20 (3.1b): the family counter fades while the hint arrow needs its space.
- E.21: `ui_extra_slot` rests on frame 0.

**H** · Forest Bear costs 2,500 coins.

## Choices m7-1 made
- **A.1 themes.** Chapter 7 awards the Circus Family, so its room is a daytime puppet theater (velvet curtains, a painted backdrop, footlights) instead of a big top next to ch05's Night Carnival. Chapter 8 is a park bandstand in autumn, chapter 9 a castle library with an arched window and pennants, and chapter 10 a sunrise lookout with hot-air balloons over the hills. Same recipe as ch01–ch06: flat top band, washed-out middle, floor band under the bottom shelf.
- **A.2 names.** Puppet Theater, Autumn Bandstand, Castle Library, Sunrise Lookout (the longest ribbons, "CHAPTER 8 · Autumn Bandstand" and "CHAPTER 10 · Sunrise Lookout", are shorter than ch06's).
- **A.3 palettes.** Snowy Cabin keeps the 4.7 ribbon blue. The other nine share one lightness and vary hue (OKLCH), so white Fredoka on every accent is at least 3.4:1 and ink on soft at least 7:1.
- **A.4 thumbnails.** Crop rectangles in `tokens.json` (1080×506 at x 105, y per theme), not PNGs.
- **A.5 shelf art.** Not needed: the shared wood reads well on all four rooms.
- **B.3 doll heights.** The clamp h·2/3 ≤ minPitch − 8/3 is replaced by `layout.boardFit`, which tests the plank above and the HUD as well as the width. Size 5 on three shelves stays 133.5 dp. Size-6 levels use a tall three-shelf preset (planks 300 / 494 / 688), where size 6 is 142.1 dp; on the usual planks they would shrink to 90.6 %. The picked doll keeps its 14 dp lift and may pass in front of the plank above.
- **B.4 glass case.** A new tall case for sizes 5–6, scaled to its doll, with the doll standing on the stand. It gets its own Lottie, `fx_glass_unlock_tall`, rather than stretching the old one.
- **B.5 tower on the top shelf.** The silhouette step shrinks (never below 9 dp) so the deepest one ends 8 dp under the family counter; with less room, fewer silhouettes are drawn and the +N tag keeps the real count.
- **B.6 extra slot.** The pad goes to the lowest shelf with fewer than 4 slots. Only when every shelf holds 4 does the bottom shelf become a row of 5.
- **B.7 iced tower.** The +N tag stays hidden until the ice is gone, then pops in with the shatter.
- **B.1, B.2.** Delivered as optional presets (`fourShelves`, `rowOfFive`); the game needs neither unless the owner wants the variety.
- **G.5 rivals.** Pebble (relaxed, slow), Button (careful, slow), Comet (careful, quick), referred to as "it" so they read as computers.
- **G.6 share text.** Each family is its belly-symbol emoji, one per DollColor, so all 11 are distinct and none depends on color (Tangerine's flower is 🌼). No board and no answers.
- **G.10 placeholders.** "Coins needed" becomes "A few more coins" and the Museum intro is rewritten to say what the shelf is; the other lines are kept as templates.
- **G.11 help note.** Hints and +1 Slot are stated plainly as a 2-star ceiling ("Wins with a hint or an extra slot earn up to 2 stars.").
- **H price.** 2,500 coins, between Forest Friends (2,000) and Winter (3,000).
