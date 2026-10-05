# nesty-design-m7-4

Cumulative handoff root: every m7-3 file plus the changes below. Answers follow the request’s numbering; every “keep” is under Choices.

## Files changed
| path | what changed |
|---|---|
| `tokens.json` | v4. Changed values: `textLink.minTapHeight` 44 → 48, `layout.chestCard.card.top` 214 → 168, `color.starEmpty` → `starEmptyOutline` + `starEmptyTop` / `starEmptyBottom`. New: the frame colours, `toast`, `screenHeader`, `textFit`, `font.scripts`, `layout.tutorial`, `layout.languageSheet`, `layout.museumDetail`, `layout.noCoins`, `layout.sizeBlend` and the entries named below. |
| `copy.md` | “Changes in m7-4” at the top; placeholders, rewritten race lines, new ids, `## A11y`, `## Short forms`; `records_families_value` and `records_three_star_levels` withdrawn |
| `prototypes/NestyBoard.dc.html` | tutorial (tip in the HUD row, Pause hole, STEP n OF 3); one-line chapter ribbon |
| `prototypes/NestyMenus.dc.html` | `dailyPaused`; freeze line on 5.2; `streak_lit` on 5.5; left-aligned header; language sheet with script fonts and 56 dp rows; `languageShort` (731 dp) |
| `prototypes/NestyMeta.dc.html` | 9.6 [Race Button]; rival pace lines; new race lines; “+Slot” on 12.9; `oomRelaxedLarge` |
| `prototypes/NestyHub.dc.html` | rival lines, locked-card ring; `settingsOff`, Turn off, 48-tall segmented control; Families completed; Chapters scroll and name fit |
| `prototypes/NestyShop.dc.html` | left-aligned header |
| `prototypes/Nesty App Flow.dc.html` | new frames 5.2b, 8.2b, 10.2h, 10.9c (139 frames); notes |
| `lottie/ui_win_ribbon.json`, `ui_chapter_ribbon.json`, `ui_family_counter.json`, `ui_chest.json` | named fills and rects; `ui_chest` loop fix |
| `lottie/LOTTIE.md`, `audio/AUDIO.md`, `README.md` | as below |

## 1 · Tokens
1. `icons.storageError` sd_card_alert, `icons.contentError` inventory_2.
2. All in `color` under the `AppColors` names. Toast kinds: `toastSuccess*`, `toastInfo*`, `toastBadge*` (+ `toastWarn*`). Peach card: `streakCard*` hold the frame values, #FFF1DE → #FFE2C2, edge #E3AE8C (your samples were close). Divider #F0DFC4 (`divider`). Locked row name `textLocked` #8A6A4E. Splash error dim `scrimLight` rgba(60,30,10,0.35). Disabled booster `disabledFace` / `disabledShade`, its label and “+1” in `disabledText`, the limit badge `limitBadge*`. Tile tints: `layout.records.statsGrid.cell.tints` and `layout.settingsRows.iconTiles`.
3. `starEmptyOutline` #DDBE8E; the art reference left the colour map.
4. `textLink`: 48 dp box, `pressed` #6E4526 (= `computerTagText`), `accent` #C4631E / #A94F12.
5. **Changed:** the app-wide toast sits **4 dp under the safe top** (y 58 in the frames, whose status bar is 54), not 58 below it. Geometry in `toast.app`, `toast.inPlace`, `toast.pill`, with icon discs per kind.
6. `motion.firstLaunch`, as shipped.
7. `motion.chest.collect.pillRing`, `hintRing`, `gainTag`, `trail`. **Rays: no full turn.** `ui_chest` sways them ±6°; drop the 24 s turn and draw no rays over the Lottie.
8. Diameters, as the game reads them (`layout.fallbackDoll`).

## 2 · Copy
1. `strip_ready`, `race_pause_title`, `gen_busy`, `relaxed_free_chip`, `chest_gain_tag`, `museum_all_home_sub`, `daily_chest_title` / `_to_go` / `_to_go_today` / `_opened`, `chapter_stars_total_all`, and its own `reminder_not_now`. “Owned” is screen-reader only (`a11y_skin_owned`; the card shows Equip). “Suggested” isn’t on screen: the ring marks 12.7’s Restart, and `a11y_booster_suggested` reads it.
2. Placeholders: `museum_intro` `{levels}`, `oom_undo_spent` and `slot_limit` plurals with `{count}`, `records_stars_value` `{total}`; also `daily_locked`, `rival_locked_mode`, `chapter_stars_total`, `splash_storage_body`.
3. Rewritten, so no exemptions: `rival_1/2/3_skill` Gentle / Steady / Lively pace; `rival_2_personality` “Checks each move twice, then makes it.”; `rival_3_personality` “Lively, tidy and hard to catch.”; `race_win_body` “Every family is complete. {rival} was still sorting.”; `race_quit_body` “The race stops here. No coins, and you keep everything.” Frames updated.
5. Frames 1.3, 1.4, 10.8b read OF 3.

## 3 · Screen-reader strings
All in `copy.md` → `## A11y`: badge how-to lines (`<badge>_how`, read after “not earned yet”, **screen reader only**), level cells including `a11y_level_finale`, chapter rows, `a11y_chest_contents`, `a11y_share_daily`, `notification_channel_name` / `_description`, Home’s chapter card, Bonus card and vs Computer tile, the Museum’s niches and count, Records cells and race rows, `a11y_rival_beaten`, `a11y_race_start_button`, `a11y_reduce_motion_group`, `a11y_reminder_time_chip`, `a11y_booster_slot_used` (“+Slot, 2 of 2 used”).

## 4 · Frames and looks
1. Interposes before 9.4’s chosen action (any button or back), once per rival; [Race {rival}] races the new rival, [Not now] carries on with 9.4’s action. `jingle_reward` plays as the card lands.
3. Fills named (`band_fill`, `edge_fill`, `hi_fill`, `tail_fill`, `fold_fill`); versus colours in `versus.ribbon`. No separate file needed.
5. The pick lasts for the visit (as built). On a new visit: the New rival, else the last rival raced.
10. Yes: the first Home visit after a relight, in any session, once (`motion.relitHome`).
11. Space’s chip: white 92 % with #2A2766. Skin or theme bought: no card; the price chip turns into Equip / Use with a pop, three sparkles, the coins count down, `jingle_reward`, success haptic (`motion.purchaseItem`).
12. Keep the helper note on 16:9 (tip or helper, never both) and drop the 760 switch: the card blends by height like Home (`layout.sizeBlend`).
14. The pill takes any width: `pill_rect` / `glow_rect` with `rectangleSize`, the icon moved with `transformPosition` (LOTTIE.md → Tint and width). The 0.9–1.2 scale can go.
15. The Lottie stays; 4.7 is redrawn one-line; fills named as in 4.3, palette `ribbonTail` / `ribbonFold` per chapter.
16. 10.2h draws the Off row; 10.2f gets a Turn off link; the segmented control is 48 tall.
17. 5.2b (paused card before the solve); 5.2’s streak card reads “A freeze kept your flame lit.”; relit twinkle at the flame disc’s top-right (`motion.relitTwinkle`); “Reminder set” stays silent; 12.5 under reduce motion: a slow pulse (`motion.spinner`).

## 5 · Board
1. Glass, tall glass and ice scale with the stand; tall case capped at pitch − 2; neighbouring ice may overlap up to 3 dp. A second +1 Slot goes to the next shelf up; a row of 6 only when every row holds 5 (`layout.extraSlot`, `board.overlays`).
2. `fourShelves.pieces` scale with k; `boardPresets.oneShelf` added (tokens only).
3. True sizes with raised bases (D21), but keep the 8 dp: a smaller step, or fewer silhouettes (`towerStack.d21`).
4. The tokens’ arch with no arrowhead is right (3.1 superseded). `hintMiddle.clampTop`: the arrow’s highest point stays ≥ 112, moving down over the doll if needed.

## 6 · Lottie and art
1. LOTTIE.md “Doll size” now names the three authored `_size` nulls; never override them.
2. Documented: 26.67 %, 9.6 dp, under `lock`, matched to the 80 % case.
3. No digits anywhere: no “+2” / “+1” tags in the loops or their art; ice counts with pips.
4. The 180×150 SVG is right; the 200×170 box was the pre-m7 card. The card top is 168 (`layout.chestCard`).
5. 10.9c: German at 1.3×; the Free chip moves under the sub instead of shrinking (`textFit.sheetRows`).

## 7 · Housekeeping
1. README’s glyph list: comma fixed, “19 glyphs” stated, plus the two splash glyphs.
2. README “Components” matches the tokens (text link, toasts, screen header).

## 8 · Device run
1. Dim the HUD and the bar too, with a hole that keeps Pause lit and tappable; the tip moves into the HUD row (left 76, right 16, top 62), so it no longer meets the counter (`layout.tutorial`).
2. A 1.5 px #E2CBA6 ring on the locked card, and the page gradient as `gradient.canvas`.
3. `layout.chestCard`: top 168 / 176, padding 44/22/22, art box 156×130, `ui_chest` at 1.2 overlaying it.
4. Scroll so the current card has at most two finished rows above it (`chapters.openScroll`). Locked number #B99A7A (`chapters.lockedCell.number`). The won count is right-aligned, flush with the bar.
5. “Families completed” (`records_families`) with the family counter’s doll mark.

## 9 · Translations
1. `font.scripts`: Baloo 2 (Devanagari), M PLUS Rounded 1c (Japanese), both OFL, with weights, size and line heights.
2. `textFit` per surface plus `## Short forms` in copy.md.
3. 8.2 and the new 8.2b (731 dp, scrolling) show all nine languages with their script fonts (`layout.languageSheet`).

## 10 · Fidelity audit
1. In tokens: `shop.cardName` (skins 16, themes 14), `layout.noCoins` (heading 24, body 16, item name 18), `layout.records.statsGrid.cell`, `layout.museum` title and next-card name (up to two balanced lines). 7.4c’s chip shows the number alone; the coin says the rest, and screen readers hear “coins”.
2. **One alignment:** the title sits on the left, beside the button, on every screen. Daily, the Shop, the Museum detail and Skin detail are redrawn (`screenHeader`).
3. Drawn in code: `layout.museumDetail.spotlight` (250 × 320 cone, 38–62 % top edge, white 55 % → 0).
5. The visible chest is 101 dp inside a 130 dp box in `ui_chest`; at the card’s 1.2 it is 121 dp, and its top sits 56 dp below the card top. Your 55 is right (`layout.chestCard.artFit`).
7. 5.2’s blue banner is the app toast (info kind): ship it as `toast.app`, with the “0 left” chip on the streak card.

## Choices (keep what the game ships)
2.4 drop “Levels with 3 stars” (id withdrawn). 2.6 the locale’s `MMMd`. 2.7 7:00 PM is an example; the hour of the solve. 4.2 Keep racing closes the whole Pause. 4.4 screen width; 6 dp dots, 2 dp gap. 4.6 the empty plank; 9.3f’s tone and 52 dp refresh. 4.7 the straight blend for Home. 4.8 the accordion and the 1.3× marks as built. 4.9 Best moves by level opens Chapters. 4.13 the dimmed board behind 12.6. 4.18 toast timing. 5.5 only the unlock symbol pings. 5.6 the 0.7 dp overlap. 8.6 a still “Thinking…”. 8.7 ios_share on iOS, share on Android. 9.3 a language change applies at once, no confirmation. 10.4 the fade and padding on short phones. 10.6 red (cherry) fallback dolls on the splash.
