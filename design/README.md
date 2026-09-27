# Handoff: Nesty: Doll Sort — full mobile app

## Overview
Nesty is a cozy sorting puzzle. The player nests wooden matryoshka dolls, each into the same color one size bigger, until every family is complete. This bundle has everything needed to build the whole player-facing app for iOS and Android: all screens and states (62 frames in 8 flows), the component and token system, the parametric doll asset system, every game-feel animation with exact timings, placeholder sound files, and haptics.

The source of truth for rules is `docs/GAME_SPEC.md` in the repo. This bundle is the source of truth for **look, layout, motion, sound and copy**. The section numbers used here (§x.y) refer to GAME_SPEC.md.

## Latest changes (2026-09-26)
- Lottie v3: Claude Code's v2 is the baseline, plus wider ribbons (336 band, 410 canvas), `fx_ice` `crack_hit_0…3`, the glass landing on frame 53, no animated image transforms, and every file inside its canvas. Details in `design/lottie/LOTTIE.md` → Changes.
- Jingles re-rendered to −17 dBFS RMS with true peaks at or below −1.3 dBTP. Levels in `design/audio/AUDIO.md`.
- `Nesty Soundtrack.dc.html` plays the shipped files and defaults the music volume to 0.5.

## About the design files
The `.dc.html` files are **design references built in HTML**. They are prototypes that show the intended look and behavior. They are not production code. Recreate them in the repo's stack: **Flutter + Flame**, `auto_route`, Cubits, `nesty_render` for dolls and board painting (see the repo's CLAUDE.md). Don't port the HTML or CSS directly. Use the numbers, colors, copy and timings documented here and in `design/tokens.json`.

Open `prototypes/Nesty App Flow.dc.html` in a browser for the complete flow. It is a pan-and-zoom canvas; every frame has an id like `2.4` that this README uses.

## Fidelity
**High-fidelity.** Final colors, type, spacing, copy, states and motion. Recreate pixel-accurately at 390×844 logical px, then let the board layout math (below) handle other screen sizes.

## Bundle contents
```
design/                         → copy to the repo's design/ folder (owner-managed, read-only for Claude Code)
  tokens.json                   every color, gradient, font size, radius, spacing, shadow, layout, motion, sound, haptic value
  symbols/{heart…crown}.svg     11 color symbols, 128×128, single path, fill="currentColor"
  skins/{id}/{id}.svg           7 layered skins (classic, ocean, space, sweets, forest, forest-bear, winter), 512×768, 8 group ids
  skins/{id}/skin.json          splitY 400, lidLiftPx 120, symbolAnchor [256,590], symbolSize 110
  skins/classic/renders/*.svg   baked references per DollColor id: closed, _open (lid 1.0), _large_symbol, silhouette (reference only)
  board/*.svg                   stand, tower base, shelf plank, glass case ×3, ice ×5, extra slot, hint arrow, glow ring, doll-silhouette (wood blank for buried nests)
  themes/ch01…ch06_*.svg        chapter backgrounds, 1290×2796, safe area 1080×1920 centered
  museum/{01..10}_{name}.svg    chapter figurines + _locked silhouettes (PNG copies in museum/png/)
  store/                        app icon 1024 / 180 / 48 + SVG, open-doll art
  audio/*.wav                   17 SFX with the §11.3 file names (v2 wooden-toy set; clacks baked at size 3.5)
  audio/*.ogg                   music_home, music_game (seamless loops) + jingle_chapter, jingle_reward, jingle_oom
  audio/AUDIO.md                when each track plays, fades, ducking, volumes, flutter_soloud notes
  lottie/*.json                 29 Lottie files, one per animation in the design (doll motion, board effects, HUD, UI)
  lottie/images/*.png           placeholder images for the Lottie image slots (the game supplies its own rasters)
  lottie/LOTTIE.md              how to play them: anchors, segments, image slots, travel remap, events, sound and haptics
  generator/nesty-doll.js       reference implementation of the doll tint/symbol/lid algorithm
  generator/nesty-sfx.js        reference synth for the SFX
  generator/nesty-music.js      reference synth and score for the music and jingles
prototypes/                     the HTML design references (open in a browser over http; keep the folder structure)
  support.js                    the runtime every .dc.html page loads; keep it in the same folder as the pages
  nesty-doll.js, nesty-music.js, nesty-sfx.js   copies of the generators that the pages load
  Nesty App Flow.dc.html        all 62 frames, flow arrows, spec coverage
  NestyBoard / NestyOverlay / NestyMenus / NestyShop .dc.html   the screen components the flow page imports
  Doll Studio.dc.html           parametric doll editor (any color, any symbol SVG, any skin)
  Nesty Motion & Sound.dc.html  every §11 animation looping live with sound, timing tables
  Lottie FX.dc.html             all 29 Lottie files playing, with anchors, segment chips and a doll-color tint picker
  Nesty Soundtrack.dc.html      plays the shipped audio files (or the live synth, which can mute each part of a loop): loops, jingles, every SFX, and the music rules
  Nesty Design System.dc.html   component sheet
```

## Design tokens (summary — full values in `design/tokens.json`)
- **Palette:** cream canvas `#FBEAD0 → #F4D9AE`, surface `#FFF9EE → #FCEBD0` with a solid bottom edge `#D8B07A`. Text `#5B3A21`, secondary `#8A5B3A`, muted `#9A6A44`. Primary tangerine `#F7A15E → #F2893B`, edge `#C4631E`. Success `#6CC07C → #46A758`, edge `#2F7A3E`. Rewarded ad purple `#9A72EC → #7C4DDB`, edge `#5530A8`. Count bubble `#E93D82`. Wood bar `#D8995A → #BD7B40 (14px) → #A56A34`. Walnut `#7B4824`.
- **Doll colors:** keyed by the `nesty_core` `DollColor` id, never by display name. red Cherry `#E5484D`, orange Tangerine `#F2893B`, yellow Sunflower `#F5C518`, green Leaf `#46A758`, teal Lagoon `#12A594`, blue Sky `#3E8EDE`, purple Grape `#8E4EC6`, pink Bubblegum `#E93D82`, navy Midnight `#2F3E8F`, brown Cocoa `#A0673C`, gold (wild). Each has `ink` (belly symbol) and `light` shades in tokens. This fills the `// TODO(design)` in `nesty_render/lib/src/doll_palette.dart`.
- **Radii:** 6 / 10 / 14 / 18 / 22 / 30, cards 32, sheets 34 (top corners), pills 999.
- **Spacing:** 4-pt grid: 4, 8, 12, 16, 20, 24, 32, 40, 48, 64. Screen side margin 16.
- **Tactile depth:** every pressable surface has a 2px white inner top highlight plus a solid bottom edge (5–8px) in a darker tone plus a soft drop shadow. On press it moves down (edge − 2)px and the edge shrinks to 2px, over 80 ms.

## Typography & icons
- **Fredoka** (500/600/700) for display, buttons, numbers and HUD. **Nunito** (500–800) for body text and rows. Both are OFL Google Fonts. **Bundle the TTFs in `apps/game/assets/fonts`**, because the game must work offline from first launch. Use tabular figures for coins and counters.
- Scale (size/line-height/weight): display 56/56/700 · h1 40/42 · sheet title 30/33 · h2 28/31 · screen title 26 · card title 20/22 · button 21 · small button 17 · HUD level 18 · numbers 17 tabular · booster label 13/600 · tier chip 11/700 +0.06em · tab label 12 · body 16/23/600 · small body 14/20 · list row 17/700 · caption 12/16/700.
- **Icons:** Material Symbols Rounded, FILL 1, weight 600. Glyphs used: pause, undo, lightbulb, add_box, restart_alt, settings, home, storefront, museum, local_fire_department, bolt, star, calendar_today, close, check, check_circle, arrow_back, chevron_right, volume_up, volume_off, music_note, vibration, visibility, translate, restore, admin_panel_settings, shield, mail, wifi_off, sentiment_neutral, sentiment_satisfied, touch_app, auto_awesome, ac_unit, play_arrow, redeem, extension, lock, favorite, thumb_up, smart_display, block, play_circle, arrow_forward, add, download, casino, shuffle. Bundle the font or export these glyphs as SVG. The play-video triangle on ad buttons is a CSS triangle inside a white 30×24 rounded rectangle, so draw it as a shape.

## Components
| Component | Spec |
|---|---|
| Primary button | Height 58–60, radius 22, primary gradient, 6px edge `#C4631E`, white Fredoka 21/700, text shadow `0 2px 0 rgba(150,60,10,.35)`. Full width inside cards (left/right 22–28). |
| Secondary button | Height 50–56, radius 18–20, `#FFFDF7`, 5px edge `#D8B07A`, text `#6E4526` Fredoka 16–18/600, optional 21px icon. |
| Rewarded ad button | Primary shape in the ad gradient, 6px edge `#5530A8`. Leading white 30×24 radius-7 box holding a purple play triangle. Label such as "×3 coins", "Watch ad" or "Double it". Offline: hidden, or replaced by the coin price (§9.1). |
| Coin price button | Primary gradient with a 22px coin (radial `#FFF3B0 → #F2C230 → #B8860B`) and "60 coins". Disabled: `#E8DCCB`, text `#A48B72`, gray coin, sunk inner shadow. |
| Icon button | 46–48 square, radius 17, surface gradient, 5px edge, 26–28px glyph `#6E4526`. Close button: 36–38 circle `#F6E2C2` with a 3px inner bottom shadow. |
| Coin pill | Height 40, radius 20, padding 0 14 0 6, 28px coin plus a tabular number. On Home it adds a 24px green "+" circle (opens Shop). |
| Level pill | Height 46, radius 18. **Normal:** surface. **Hard:** red gradient, white text plus chip (flame icon, "HARD", `#FFF1EE`/`#C33338`). **Super Hard:** purple gradient plus "SUPER HARD" chip (`#F4ECFF`/`#6A31A6`, 10px). **Daily:** yellow gradient, calendar icon, "Daily" plus date chip. **Bonus:** teal gradient "Bonus Level N". Always centered at x = 195, top 62. |
| Family counter | Centered under the level pill (top ≈ 116). Height 26, radius 13, walnut, cream Fredoka 13 "1 / 4", 12×18 doll silhouette icon. It is the target of the complete fly-in, and bumps to 1.14 with a gold glow. |
| Booster button | 80×58, radius 18, surface gradient, 5px edge `#CFA36A`, 25px glyph plus 13/600 label. Badges sit at top-right, offset (−6, −7): **count** is a 22px pink circle with a 2px `#FFF4E0` ring; **ad** is a purple 26×22 radius-8 box with a white triangle; **coin price** is a cream-gold pill with a 15px coin and number ("20"). A glowing state (pulse 1.4 s) is used to suggest Undo when stuck. |
| Booster bar | Wood gradient from y = 734 to the bottom, grain overlay, 3px light top edge. 4 buttons (Undo, Hint, +Slot, Restart) at x = 23 + i·88, y = 746. |
| Bottom nav | Wood bar from y = 738. Items Shop · Home · Museum, 80 wide. Inactive: 48 square, 18% cream fill, cream glyph. Active: 58×52 surface tile lifted −6px, glyph `#C4631E`. |
| Tabs (segmented) | Track height 44–46, radius 23, `#EAD3B0` with a sunk shadow, padding 4. Active segment is a surface gradient with a 3px edge. |
| Toggle | 54×30 track, radius 15, on `#46A758`, off `#D9C2A0`, 24px knob `#FFFDF7` at x 3 / 27, spring `cubic-bezier(.3,1.4,.5,1)` 180 ms. |
| Modal card | Left/right 24–32, radius 32, surface gradient, card shadow. Orange **ribbon title** pill at top −18 (padding 9/22, radius 16, 18/700 white). Close button at top-right, inset 12. |
| Bottom sheet | Radius 34 on top, surface, 44×5 grabber, title 30/700, rows are 20-radius white cards with a 44px icon tile, title 18/700, subtitle 13/600, and a trailing action. |
| Banners / toasts | Radius 20–22, 2px white inner top, 4px colored edge. Warning `#FFE3D0`/`#E3AE8C` + orange icon. Danger `#FFE1E1`/`#E8A5A7` + red icon ("Offline"). Success `#EAF7EC`/`#A6DDB3`. Info (ice) `#E8F3FF`/`#9CC4EA`. Title Fredoka 16–17/700, sub Nunito 12–13/700. |
| Progress bar | Track `#EAD3B0` with a sunk shadow, radius = height/2, padding 2–3. Fill is the green gradient with a white inner top highlight (the splash loader adds stripes). |
| Home tile | 132 tall, radius 24, surface, 5px edge. 58px colored icon tile plus 15/700 label. Streak badge (flame + number) sits at top-right. |

## Board layout (§10.3)
- Board area runs from under the HUD to y = 734 (booster bar). 3 shelves: plank tops at y = 312 / 498 / 684. 2 shelves: 430 / 650. Plank height 40, tileable `board/shelf-plank.svg`.
- Slot centers: `cx = 195 + (i − (n − 1)/2) × min(96, 372/n)`. Stand 90×34 (`slot-stand-blank.svg`), top = plankTop + 9 − 34. The doll base sits at standTop + 12.3. Tower stand is 90×39.
- Doll height = slotMaxDollHeight × fraction[size]: fractions 0.42, 0.54, 0.66, 0.78, 0.89, 1.00; slotMaxDollHeight is 150 for 3 shelves and 140 for 2. When maxSize = 3, divide by 0.66 so size 3 = 1.00. Doll width = height × 2/3; the base is at 742/768 of the art height.
- **Pips:** maxSize dots, 6px, pitch 7.8, centered on the stand face (y = standTop + 21; tower + 28.9). The left pip is the biggest size. Filled pips use the doll base color with a 1px cream ring; empty pips are `#2C170A` inset.
- **Selected:** lift 14, glow ring (`board/glow-ring.svg` 116×52 at surface −28), pulse 1.6 s.
- **Tower:** buried nests are the unpainted wood blank `board/doll-silhouette.svg` (the same for every skin), drawn behind the top, height = topHeight + 18 × depth, plus a walnut "+N" tag at the stand's right (cx + 21, standTop + 16).
- **Glass case:** 86×143 at top = surface − 134; the doll inside sits at caseTop + 123. The unlock color's symbol (12px, ink) sits on the padlock at caseTop + 116. Frames 0 intact / 1 cracked / 2 shattered.
- **Ice:** 96×160 overlay at top = plankTop + 9 − 152.5, frames ice-0…3 then ice-shatter. Blue 28px counter badge at the top-right.
- **Extra slot:** `extra-slot.svg` appended to the bottom shelf, pulsing, no pips.

## Doll rendering — the parametric template
Every skin is one layered SVG (512×768) with the group ids `shadow, bottom_mask, bottom_detail, top_mask, face, top_detail, shine_top, shine_bottom` (§12.2). A doll can be built for **any color and any symbol**:
1. **Tint:** `bottom_mask` and `top_mask` are grayscale, and every pixel's RGB is multiplied by the base color (`ColorFilter.mode(base, BlendMode.modulate)`). **Gold** uses a gradient map instead: input = gray², ramp `#4A3008 → #7A5210 → #B07E1C → #D9A634 → #F0C452 → #FFE89A` at 0 / .3 / .55 / .75 / .9 / 1. The simplest route is to pre-rasterize gold layers once.
2. **Paint:** detail, face and shine layers draw untinted on top.
3. **Symbol:** any single-color SVG is scaled to fit a 110px box centered on (256, 590) and filled with `ink` at 94% opacity. **Large / assist mode:** a cream `#FFF8EC` disc, r 92, with an 8px ink ring, and the symbol at 117px.
4. **Lid:** `top_mask, face, top_detail, shine_top` translate up by `lidLiftPx × t` (120 at t = 1). While open, draw the interior rim before the lid: ellipse (256, 398, 148×21) in base × `#D6D6D6`, then (256, 401, 134×15) `#2A1608` at 88%. The game draws lid and body as two layers so they animate independently.
5. **Buried tower nests** don't use the skin. Draw the wood-grain blank `board/doll-silhouette.svg` (owner decision, 2026-09-26): a skin-tinted silhouette keeps the face disc and the details, so it reads as a painted doll. `skins/classic/renders/silhouette.svg` and the generator's silhouette mode are references only.
6. **Shades for new colors:** OKLCH, ink = (L − 0.17, C × 0.85), light = (L + 0.17, C × 0.6), with chroma reduced until the color fits sRGB.

`design/generator/nesty-doll.js` is a working reference of exactly this algorithm. `Doll Studio.dc.html` shows it with a color picker, 11 symbols, custom SVG upload and all 7 skins. **Note:** the art pipeline supports unlimited colors, but `DollColor` in `nesty_core` is a fixed enum that the level codec uses. Making the playable color set open-ended is a spec change for the owner to approve. New skins, symbols and cosmetic variants need no code change.

## Screens (ids match the flow canvas)
**01 First launch & onboarding**
- **1.1 Splash:** ch01 background, radial cream glow, wordmark "Nesty" (Fredoka 88/700, cream fill `#FFF6E6`, 4px `#5B3A21` outline plus a 9px drop edge; a tilted cherry doll dots the "e"), orange "DOLL SORT" chip (18/700, +0.12em). A plank at y 566 holds 3 idling cherry dolls. Loading bar at y 690 (left/right 56, 22 tall, striped orange fill) with caption "Dusting the shelves…".
- **1.2 Consent:** Google UMP form over the dimmed splash. Only EEA/UK, before ads initialize. The wording is configured in AdMob.
- **1.3 / 1.4 Level 1 tutorial:** one color, maxSize 3, 2 shelves. Scrim with holes on the source and target, dotted arc, tooltip (step chip, title, text), tapping hand. Copy: "STEP 1 OF 2 · Tap the small doll · Dolls nest into the same color, one size bigger." then "STEP 2 OF 2 · Now tap the big one · The small doll drops inside with a clack." All other input is blocked.
- **1.5 Level 1 complete:** win layout (below), +10, chapter bar "Chapter 1 · 1 / 20 · Next up: The Classic Family".
- **1.6 Level 2 swallow:** "NEW MOVE · Big can swallow small · Drop a big doll onto the next size down and it closes right over it." The hand drags big → small.

**02 Home & core loop**
- **2.1 Home:** background = current chapter theme. Top row: coin pill (+), wordmark 30px, gear. Plank at 372 with 5 idle dolls (bob 2.4–3.6 s, ±2°). Play button (left/right 36, top 446, 96 tall, radius 32, edge 8) with a cream play disc, "PLAY" 14/700 +0.14em and "Level 56" 36/700; the HARD badge is rotated 8° at the top-right. 3 tiles at y 584: Daily Puzzle (flame badge with the streak), Museum (next figurine silhouette plus bar "15/20"), Remove Ads (hidden once purchased; the other two widen). Bottom nav.
- **2.2 Gameplay:** HUD, board, booster bar as specified above.
- **2.3 Pick up / 2.4 Nest / 2.5 Complete / 2.6 Invalid / 2.7 Glass & ice break:** see Motion. Play the events in `MoveEvent` order (§4): Picked, Placed, NestedInto, Revealed, Completed, Unlocked, IceCracked, IceShattered, Won.
- **2.8 Win:** dim, confetti, "Level Complete!" ribbon (top 118, orange with folded tails; in the game it is `ui_win_ribbon`, band 336 dp), plank at 350 with the families hopping (1.3 s, 150 ms stagger), coin pill "+25" at 404 (Fredoka 30), progress card at 484 (chapter · count · bar · "Next up: …" · 62px locked figurine), then "×3 coins" (ad) and "Continue" at 630.
- **2.9 Reward claimed:** the pill reads "+75" with a "×3" chip; the ad button becomes "Reward added" (`#E9DDF9`, check icon).
- **2.10 Interstitial:** only on Win → Continue, following the §9.1 pacing. Ad placeholder with a close button after 5 s.
- **2.11 Next level.**

**03 Boosters & recovery**
- **3.1 Hint:** bouncing `hint-arrow.svg` (40×50, 0.9 s) over the source, a dashed orange arc, and a glow ring on the target.
- **3.2 / 3.3 Buy popup:** ribbon title, 112px icon disc with an 8px halo, benefit line (17/700), [coins] [▶ Watch ad], "You have 830 coins". Undo copy: "Your 2 free undos are used. Take back one more move." · 20 coins. Hint: "Shows your next best move." · 60 coins.
- **3.4 Soft stuck:** warning banner (top 152), Undo booster glowing.
- **3.5 Out of moves sheet:** "No moves left!" / "Pick a way to keep sorting." Rows: Undo ("Free · 1 left"), +1 Slot ([▶] [150 coins], green 3px ring), Restart ("Start this level fresh, for free").
- **3.6 Extra slot added.**
- **3.7 Offline Out of moves:** danger banner "Offline · Ad buttons switch to coin prices"; the ▶ option is removed.
- **3.8 Can't afford offline:** the coin button is disabled, with "Connect to watch an ad" in red.
- **3.9 Pause:** ribbon "Paused", "Level 56 · Hard", Sound/Music/Haptics toggles, Resume, then [Restart][Home][Settings] tiles (62 tall).

**04 Mechanics & chapters**
- **4.1–4.3, 4.8 Intro cards:** "NEW" chip (or "v1.1" for gold), title 34/700, a 302×230 illustration with plank, text 16/600, "Got it". Copy: Towers — "Only the top nest can move. Clear it to reveal the doll hiding underneath." Glass Cases — "A locked doll is freed when the family on its padlock is complete." Ice — "Every family you finish cracks the ice. At zero, the doll is free." Golden Doll — "Gold counts as any color. It joins whichever family it nests into."
- **4.4 Super Hard board. 4.5 Win (+50).**
- **4.6 Chapter complete:** dark scrim (`rgba(25,12,4,.86)`), spotlight cone, "CHAPTER 3 COMPLETE", figurine art 310px, "Added to your Museum!", "+150 coins", "Next: Chapter 4 · Snowy Cabin", Continue.
- **4.7 New chapter:** blue ribbon "CHAPTER 4 · Snowy Cabin" on the first level, fades after about 2 s.
- **4.9 Bonus intro:** "You've finished all levels!" / "New chapters are coming — play bonus levels meanwhile." [★ Play Bonus Level 1] (teal) · "Back to Home".
- **4.10 Bonus level.**

**05 Daily** — **5.1** streak card (orange gradient, "4 days", "Play today to keep your streak", freeze chip), a 7-day strip (done = green check, today = raised orange, day 7 = chest), chest row "Day 7 chest · 300 coins", puzzle card (date title, "5 colors · Hard", preview, Play with a "50" coin chip). **5.2** "Streak saved!" info banner. **5.3** daily board (date pill). **5.4** "Daily solved!" (+50, streak card, no ×3). **5.5** solved state with the countdown "Next puzzle in 14h 12m" and [Play Level 56]. **5.6** chest modal: "7-day streak!", open chest, "+300", [▶ Double it] [Collect].

**06 Museum** — **6.1** collection card ("2 / 10" plus the next-figurine line), then a walnut cabinet with 4 shelves × 3 figurines (76px art; earned in color, next with a "15/20" chip, others as locked silhouettes at 55%). **6.2** detail modal: spotlight panel with the art at 272px, chapter chip, name 28/700, italic flavor text, "Collected · Sep 12". **6.3** locked: "Finish Chapter 3 to bring this family home.", bar, [▶ Play Level 56].

**07 Shop** — tabs Coins · Skins · Themes · No Ads. **7.1** Starter Pack (one-time, $1.99: 1,500 coins, +3 slots, +5 hints), then 600 $0.99 / 4,000 $4.99 (BEST VALUE, pink ring) / 9,000 $9.99. **7.2** "Thank you! +4,000". **7.3** 2-column skin cards (84px preview of 3 dolls on a plank; states Equipped / Equip / coin price). **7.4** skin detail: all 11 colors on 2 shelves, size lineup, "Buy · 800", balance. **7.5** downloading state on the card (purple, spinner, "Downloading 64%"). **7.6** skin in play. **7.7** themes: "Match each chapter" toggle plus a 2-column grid (74px thumbnail; In use / Use / locked "Ch N" plus price). **7.8** Remove Ads $2.99, No-Ads Bundle $4.99 (Remove Ads + 3,000 coins), the note "Reward videos stay optional. They only play when you tap a ▶ button.", Restore purchases. **7.9** Remove Ads offer (after the 3rd interstitial). **7.10** Home without the Remove Ads tile, toast "Ads removed. Thank you!".

**08 Settings & system** — **8.1** toggles (Sound, Music, Haptics), Color symbols (Subtle / Large cards), rows (Language · English, Restore Purchases, Privacy choices, Privacy Policy, Support · Email us), footer "Nesty: Doll Sort · v1.0.0 (build 42) · Player ID". **8.2** language sheet: English, Español, Português (Brasil), Bahasa Indonesia, हिन्दी, Deutsch, Français, Türkçe, 日本語. **8.3** toast "Purchases restored · Remove Ads is active on this device." **8.4** large symbols on the board. **8.5** ATT pre-prompt: "Help keep Nesty free", 2 reason cards, one Continue. **8.6** iOS ATT alert with the purpose string "Your data is used to show ads that fit you better. It helps keep Nesty free." **8.7** native review sheet after the Level 15 win.

## Navigation & state
Suggested routes: `SplashRoute → HomeRoute`; `GameRoute(levelId | daily | bonusN)`; `DailyRoute`; `MuseumRoute`; `ShopRoute(tab)`; `SkinDetailRoute(skinId)`; `SettingsRoute`; `AttPrePromptRoute`. Overlays inside GameRoute: Win, OutOfMovesSheet, BoosterPurchaseDialog(type), MechanicIntroDialog(mechanic), PauseDialog, ChapterCompleteOverlay, BonusIntroDialog, RemoveAdsOfferDialog, SoftStuckBanner. Home dialogs: FigurineDetailDialog, DailyChestDialog, LanguageSheet.
Win → Continue → [interstitial if the pacing allows] → [Remove Ads offer after the 3rd interstitial] → [ChapterComplete if the chapter ended] → next GameRoute. The state fields shown come from the save model in §13.3: coins, currentLevel, inventory, adsRemoved, ownedSkins/selectedSkin, ownedThemes/selectedTheme (null = match chapter), museum, daily {streak, freezes, done}, settings {sound, music, haptics, symbols}.

## Motion (full table in tokens.json → motion; see it live in `Nesty Motion & Sound.dc.html`)
**Every animation ships as Lottie** in `design/lottie/` (owner decision). Follow `design/lottie/LOTTIE.md` for anchors, segments, image slots, the travel remap and the event map. Widget transitions (button press, sheets, modals, tabs, banners) stay Flutter animations using `tokens.motion.ui`.

Pick 120 ms (lift 14, scale 1.05, wobble ±3° loop) · Move 260 ms easeOutBack `cubic-bezier(.34,1.56,.64,1)`, 42px arc · Nest: lid lift 80 (30% of height), drop-in 120 (scale 0.92), lid snap 70 `cubic-bezier(.55,0,1,.45)`, squash 1.08/0.92 settle 120 · Swallow: the moving doll's lid opens mid-air, then its body drops over the target · Complete: shine 300, hops 22/14 over 400, fly 550 to the family counter (end scale 0.2, 24°), counter bump 1.22, dust puff · Invalid: 3 × 80 ms ±6 shake, nest drifts back · Tower reveal 200 ms circular paint wipe from the doll's centre (art 256, 476) plus splash · Glass: padlock pop 200, cracked at 200, shattered at 400, shards 500 · Ice: 3 crack stages then shatter 300 · Win: ribbon 300, confetti 1700, dance loop 1400 with 120 stagger · Combo: sets within 4 s step up the chime (max 5) · Reduced motion: durations × 0.5, no shake, no confetti, no wobble.

## Sound & haptics
Full rules in `design/audio/AUDIO.md`; hear the shipped files in `Nesty Soundtrack.dc.html`. **SFX** (WAV, 44.1 kHz mono): pick, clack_1…3, whoosh, bonk, complete_1…5, win, coins, unlock_glass, ice_crack, ice_shatter, button. Clack pitch: `playbackRate = 2^(−2·(size − 3.5)/12)`, which is +5 semitones for size 1 and −5 for size 6; the clack files are baked at size 3.5 (0 semitones); pick clack_1–3 at random. Combo notes C6 D6 E6 G6 A6. **Music** (OGG, seamless, no loop points): `music_home` (66.7 s, Splash, Home and the meta screens) and `music_game` (68.6 s, every level), in C and F major so the combo notes always fit. **Jingles**: `jingle_chapter` (4.6), `jingle_reward` (figurine, unlock, daily chest, purchase) and `jingle_oom` (3.5). Music bus 0.5, SFX bus 0.8; jingles use the SFX bus and duck the music (tokens.json → `sound.musicDuck`, `sound.musicFadeMs`). Haptics: pick light, nest medium, complete/win success (medium, then light after 80 ms), invalid soft error (two light ticks 60 ms apart), buttons selection. All haptics follow the Haptics setting.

## Decisions to confirm with the owner
1. The flow uses **Level 56 (Hard)** as the main example instead of the brief's "Level 24", so the tier pattern (§6.6) and the mechanic schedule (glass at 31, ice at 51) stay true.
2. A **family counter** was added under the level pill, as the target for the §11.1 fly-in.
3. **Privacy choices** was added in Settings so UMP consent can be changed later.
4. No "watch a video for coins" shop row, because the spec doesn't list that ad placement.
5. **Gold** uses a gradient-map tint, not modulate.
6. **Unlimited playable colors** would need `DollColor` to become data-driven (spec change). Unlimited cosmetic variants work today.
7. Frames 1.2, 8.6 and 8.7 show system UI for placement only.

## Files
Design references: `prototypes/*.dc.html` (open `Nesty App Flow.dc.html`). Assets and tokens: `design/`. Reference algorithms: `design/generator/nesty-doll.js`, `design/generator/nesty-sfx.js`, `design/generator/nesty-music.js`. Audio: `design/audio/` with `design/audio/AUDIO.md`. Animations: `design/lottie/` with `design/lottie/LOTTIE.md`.
