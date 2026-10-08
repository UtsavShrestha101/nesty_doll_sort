# nesty-design-m7-6

Cumulative handoff root: every m7-5 file plus the changes below. Nothing here changes a game rule: prices, rewards, limits, unlocks, the streak and the gift track stay as the game has them.

## Part 1 · The local habits (App Flow section 14)

**New files**
- `prototypes/NestyHabits.dc.html`: 14.1a–14.3e and 12.14 (scenes `wFreeze` … `dailyLocked`).
- `prototypes/NestyWidget.dc.html`: 14.4, 14.4a–e, 14.4f–h (scenes `ios` … `androidLooks`, plus `previews` for the picker images).
- `ui/widget/`: `flame_lit.svg`, `flame_unlit.svg`, `flame_unlit_dark.svg` (44 dp), `doll.svg` (18 × 24, one colour, a template image), `daily_mark.svg` (52 dp), each also as `.png`, `-2x.png` and `-3x.png`; `preview_2x2.png` and `preview_4x2.png` (3×, Android’s previewImage). Flat fills, no filters or gradients, so Android takes the SVGs as vector drawables. Copies of the SVGs under `prototypes/ui/widget/`.

**Changed files**
- `prototypes/Nesty App Flow.dc.html`: section 14 (25 frames), 12.14, the flow map and the frame count.
- `prototypes/NestyHub.dc.html`: two additive props, `dolls` (a scale, or `off`) and `daily` (`paused`, `zero`) for the Daily tile’s badge. Unset, every existing frame draws as before.
- `prototypes/NestyBoard.dc.html`: one additive prop, `past`: no coin pill, and a booster with ▶ or a price takes the disabled face. Unset, nothing changes.
- `tokens.json`: `habits` (the respect rules; `welcomeBack`; `month` with every cell state, the grid, the legend and the 16:9 values; `pastDay`; `widget` with sizes, paddings, layouts and the light, dark and tinted colours), `sound.events.habitsTap` and `habitsPastWin`, `haptics.habitsTap` and `habitsPastWin`, `textFit.habitsWelcome`, `habitsMonth` and `widget`.
- `copy.md`: `## Local habits` (the welcome card, the month and each day’s screen-reader label, a past day, the locked Daily, the widget with its gallery name and description) and its `## Short forms`.
- `audio/AUDIO.md`: `## Local habits`. No new sound.
- `lottie/LOTTIE.md`: one row in “When each one plays”. No new Lottie.

**Decisions**
- **Welcome back, where:** an inline card under the chapter card (top 198 on 844, 158 on 693). Only the dolls move: they scale to 0.78 on 2.1; on 2.1b there is no room, so they fade out and the empty plank stays. One rule covers every height and text size: the dolls scale to clear the card by 8 dp, and fade out below 0.6.
- **Welcome back, the card:** the whole card is the Play button; the close is the house close glyph in a 48 dp target, read as “Hide this card”. The respect rules’ “no X” is about day marks, and no day cell draws one. The card arrives with Home’s first frame, never later, so it can’t read as a pop-up. With the gift: the ready dot simply shows too.
- **The month, where:** the last card of the Daily’s scroll, under today’s puzzle card. The 7-day strip stays the streak’s cycle and never sits next to calendar days; nothing new opens; on open the month’s title peeks under Play. A past day’s card opens right under the month, so the player keeps their place and today’s card stays on top.
- **A frozen day:** its own blue mark, never lit. Lit means the puzzle was solved on that date.
- **Playable or not:** the last 7 days are raised, like every pressable surface in the game; older days are flat. A blank day has no colour, no lock and no word, and looks the same as a future day.
- **The 1st of a month:** a ‹ chip reaches the window’s days in the month before, shown only on the 1st to the 7th. There is no browsing past it.
- **Past-day paths:** no coin pill, no ▶ or price badge (a booster at 0 is disabled), Out of moves lists only owned boosters and Restart, and no interstitial after the win.
- **Widget type:** iOS bundles Fredoka 600/700 and Nunito 800 in the widget extension. Android RemoteViews can’t load the app’s fonts, so it uses the system sans; the text stays text for TalkBack and font scaling, and the art carries the look.
- **Sound:** nothing new. `button` on the card, its close, a month day and Play again; `win` without `coins` on the past-day win.

## Part 2 · The questions m7-5 left open

**Changed**
1. **Freeze chip:** “{count} freeze” / “{count} freezes”, the game’s wording. Under 64 dp it falls back to `streak_freeze_chip_short`, the number alone beside the snowflake; `a11y_freezes` keeps “streak freeze” (`textFit.freezeChip`).
2. **Computer tag:** yes, every tag scales with the text setting, up to 1.3×: 20k tall, glyph 14k, text 11k, radius 10k. Where a surface can’t grow, the tag drops to its glyph first (`versus.computerTag`).
4. **Claim on 16:9:** the 58 dp Claim, so the 13.3b sheet is 465 tall (top 228). Frame and `gift.short` updated.
5. **Day 7 ribbon:** one spec, the shared ribbon title of 10.3b (Fredoka 700 18, padding 9/22, radius 16, top −18). 13.6b redrawn (`gift.chest.ribbon`).
7. **Tokens:** `textFit.winRibbon.box` is 266 × 40; `type.museum.count` is 16; new `gradient.figurinePanelEarned` and `gradient.figurinePanelLocked` (6.2, 6.3).
8. **Name plates:** 6.1c is meant: flat pale brass (`namePlateTop` → `namePlateBottom`, a 1 dp white top, a 2 dp `namePlateEdge`), no diagonal shine and no extra saturation (`layout.museum.cabinet.namePlate`).
10. **Chest rays:** `ui_chest`’s rays are three nested wedges each (19°, 28° and 38° at 60, 30 and 14 %) under a new alpha matte, `rays_matte`: a radial falloff from full at r 22 to clear at r 80, like the frames’ glow. Same layer name, keys and timing; `open_idle` still loops without a jump (LOTTIE.md → m7-6).
12. **The Daily before Level 2:** new frame 12.14, which is also where the widget leads before then (`daily_locked_title`, `daily_locked_body`).
14. **The tutorial’s second family:** three steps, all on the first family. The tutorial ends when that family completes: the scrim lifts over 200 ms as the counter bumps. A second family gets no tip and no hole.
15. **16 px text link:** `fontSize.textLink`, Fredoka 700 16/20.
16. **Family counter label:** it hugs its text up to 58 dp (“12 / 12” at 1.3× text is 57), so the pill is at most 92; past that it scales down to 0.85 and never wraps (`layout.hud.familyCounter`).
17. **Splash errors:** both are already named. The dim is `color.scrimLight` (#3C1E0A at 35 %), the glyphs are `icons.storageError` and `icons.contentError` (since m7-4); `layout.splash.errors` points to them.
20. **Fallback doll:** every size is a diameter. The splash shows no dolls until the skin is ready, then fades them in over 200 ms; the fallback draws only when a skin can’t load (12.12’s note and `layout.fallbackDoll.splash` updated).

**Choices (keep)**
3. Pause stays 48 dp in every strip form, centred on the 58 dp strip; 9.3i redrawn to match (`layout.rivalStrip.forms.pause`).
6. The check at weight 600, the bundled cut; 13.3–13.6 redrawn at 600.
9. The gift tally may cover the dimmed chapter card for its 1.2 s visit, as 13.5b and 13.6d draw it.
11. Home blends 2.1b into 2.1 by height (`layout.sizeBlend`); no 760 frame.
13. “Best moves by level” opens Chapters, where each level shows its best.
18. `boardPresets.oneShelf` as it is: plank 540, 150 dp dolls, up to 4 slots, for one-row boards.
19. The row of 6 is covered: pitch 62, stand 59.6 × 22.5, ice 63.6 wide (1.6 dp overlap, inside the 3 dp rule), and a tall case at most 59.8 wide under the fit’s horizontal limit, so the pitch − 2 cap never bites. The notes can retire.
21. An invalid drift onto an empty stand, glass case or ice slot stops at target base − 0.5 × the mover’s own height, drawn in front of the case or the ice (`motion.invalid.emptyTarget`).
