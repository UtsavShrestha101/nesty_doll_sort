# Nesty: Doll Sort — Claude Design Brief & Prompt Script

**How to use this:** Start a Claude Design project and paste **Prompt 0** first so it has the full context. Then send prompts 1–13 **one at a time, in order**. After each one, review and ask for changes before moving on. Earlier prompts create the style that later ones reuse.

Export everything into your repo's `design/` folder using the names listed under each prompt. Claude Code will read from there.

> About 3D: Claude Design creates screens and 2D/vector art, not 3D model files. The "3D" look comes from glossy shading, highlights and shadows in layered art, and the doll's top half really lifts off in the game.

---

## Prompt 0 — Project context (paste first)

```
You are designing a mobile puzzle game called "Nesty: Doll Sort" (portrait, iOS + Android).

GAME: The player sorts colorful wooden nesting dolls (matryoshkas) on toy-shop shelves. A doll can go inside the doll exactly one size bigger of the same color. When a full family (all sizes, biggest to smallest) is nested, it completes with a celebration and flies away. Levels are short (1–3 min), cozy and satisfying. There are no timers and no lives.

ART DIRECTION: "Cozy folk-toy shop."
- Glossy lacquered wooden dolls with simple hand-painted faces: two dot eyes, rosy cheeks, a tiny smile and a headscarf. They should feel almost 3D: soft gradients, a strong glossy highlight, a gentle rim light and a soft contact shadow.
- Warm afternoon light and honey-colored wooden shelves. Background: a softly blurred sunny toy-shop window.
- UI: chunky, rounded, tactile buttons with a subtle bottom "pressed" edge. Cream and warm-wood base with candy-pastel accents. Friendly, never childish.
- Fonts: "Fredoka" (display/headings, bold) and "Nunito" (body). Both are Google Fonts.
- It must stay readable at small sizes. The smallest doll appears about 40 px tall on a phone.

DOLL COLORS (each also has a symbol painted on the belly, for color-blind players):
Cherry #E5484D heart · Tangerine #F2893B flower · Sunflower #F5C518 sun · Leaf #46A758 leaf · Lagoon #12A594 wave · Sky #3E8EDE drop · Grape #8E4EC6 star · Bubblegum #E93D82 bow · Midnight #2F3E8F moon · Cocoa #A0673C acorn · Gold (wild) = metallic gold gradient with a crown.

TARGET DEVICE: Design screens at 390×844 (iPhone 14/15). Keep important content away from the top 59 px and bottom 34 px safe areas.

Please keep this style consistent in everything I ask for in this project.
```

---

## Prompt 1 — Design system and tokens

```
Create the design system board for Nesty:
1. Color palette: UI colors (background cream, surface, wood light/mid/dark, text primary/secondary, success, warning, danger, coin gold, ad-button purple) plus the 11 doll colors, each shown with its darker "ink" shade (for the belly symbol) and a lighter highlight shade.
2. Typography scale using Fredoka and Nunito: display, h1, h2, button, body, caption, number (for coins/level).
3. Components: primary button, secondary button, rewarded-ad button (with a small ▶ play-video icon), icon button, coin counter pill, level badge (normal / HARD red / SUPER HARD purple), booster button with count bubble, toggle, tab bar, bottom sheet, modal card, toast/banner, progress bar.
4. Corner radii, shadow/elevation styles and spacing scale (4-pt grid).

Also give me the tokens as a JSON code block using this structure:
{ "color": {...}, "dollColor": { "red": {"base":"#E5484D","ink":"...","light":"..."}, ... },
  "font": {...}, "fontSize": {...}, "radius": {...}, "spacing": {...}, "shadow": {...} }
```
**Save as:** `design/system/design-system.png`, `design/tokens.json`

---

## Prompt 2 — Color symbols

```
Design 11 simple, bold, rounded icons, one per doll color: heart, flower, sun, leaf, wave, drop, star, bow, moon, acorn and crown.
They must be recognizable at 16 px and share the same visual weight.
Deliver each as a clean single-color SVG on a 128×128 artboard, using only paths (no text, filters or masks). Give me the SVG code for each.
```
**Save as:** `design/symbols/{heart|flower|sun|leaf|wave|drop|star|bow|moon|acorn|crown}.svg`

---

## Prompt 3 — Master doll ("Classic" skin): the most important asset

```
Design the master nesting doll for the "Classic" skin as ONE SVG on a 512×768 artboard. The game tints and animates the layers, so follow these rules exactly:

The SVG must contain these top-level groups, in this order, with exactly these ids:
- shadow: soft contact ellipse under the doll (dark, low opacity)
- bottom_mask: lower body silhouette in GRAYSCALE only (white = full color, light grays = baked shading and roundness). The game multiplies this by the doll color.
- bottom_detail: untinted hand-painted details on the lower body: apron outline, small flowers and trim lines in white, cream, gold and dark ink. Leave an empty round "belly badge" area centered at x=256, y=590 about 110 px wide (the game draws the color symbol there).
- top_mask: upper body and headscarf silhouette in GRAYSCALE only (same tint rule)
- face: untinted face oval (warm skin tone), hair fringe, two dot eyes, rosy cheeks, tiny smile
- top_detail: untinted scarf pattern and trim
- shine_top and shine_bottom: white glossy highlights with partial opacity (these make the doll look 3D)

The doll opens at a split line at y=400 (the waist). top_mask, face, top_detail and shine_top must sit entirely ABOVE y=412, and everything in the bottom groups must sit BELOW y=388. The overlap gives a small lip, so the halves look natural when the top lifts off.

Technical limits: use only paths, basic shapes, linear/radial gradients, opacity and clipPath. NO filters, blur, masks, text or embedded images.

Then show a preview board with:
(a) the doll tinted in all 11 colors with its symbol on the belly badge,
(b) the 6-size lineup at relative heights 0.42, 0.54, 0.66, 0.78, 0.89, 1.00,
(c) a 3-frame "opening" strip: closed → top lifted 120 px with a smaller doll dropping in → closed.
Give me the full SVG code, and separately a JSON block:
{ "skinId":"classic","splitY":400,"lidLiftPx":120,"symbolAnchor":[256,590],"symbolSize":110,"version":1 }
```
**Save as:** `design/skins/classic/classic.svg`, `design/skins/classic/skin.json`, `design/skins/classic/preview.png`

---

## Prompt 4 — Board pieces

```
Using the Classic style, design the board pieces as separate SVGs (same technical limits as the doll):
1. Slot stand (160×60): a small round wooden coaster. Its front face has room for a "pip bar": a row of up to 6 small round pips (show one version with 4 pips, 2 filled in Cherry and 2 empty).
2. Shelf plank (tileable horizontally, 390×40): honey wood with subtle grain.
3. Tower base (160×70): a slightly taller wooden stand with a small notch. Also design the "hidden doll silhouette" look: a flat, unpainted light-wood version of the doll shape used for dolls buried in a tower.
4. Locked glass case (180×300): a clear glass dome with a padlock tag holding a color-symbol slot. Include 3 break frames: intact, cracked, shattered shards.
5. Ice overlay (180×300): a frosty block with 3 crack stages and one shatter frame.
6. Extra slot stand (a glowing "+1" temporary stand).
7. Hint arrow (a pulsing bouncing arrow) and a selected-doll glow ring.
```
**Save as:** `design/board/*.svg`

---

## Prompt 5 — Default background (Chapter 1 theme)

```
Create the Chapter 1 background "Sunny Toy Shop" for a portrait screen (1290×2796). The important area is the centered 1080×1920 zone.
The scene is a warm, softly out-of-focus toy-shop interior with a sunny window. It should have low contrast and low detail in the middle 60% so the shelves and dolls stand out. Put gentle vignette-free color at the top where the HUD sits.
Then create 5 more chapter background variations in the same style: "Rainy Café Corner", "Seaside Market", "Snowy Cabin", "Night Carnival" and "Spring Garden Shed".
```
**Save as:** `design/themes/ch01_sunny_toy_shop.png` … `ch06_*.png`

---

## Prompt 6 — Gameplay screen

```
Design the main gameplay screen at 390×844 using the design system:
- Top bar: pause button (left), "Level 24" with a HARD badge (center), coin pill "830" (right).
- Board: 3 shelves. Shelf 1: 4 open slots. Shelf 2: 1 tower (3 nests: 2 hidden silhouettes + a colored top), 2 open slots and 1 locked glass slot. Shelf 3: 3 open slots, one of them frozen with ice showing "2". Show a mix of 4 colors and several sizes. Each slot has a stand with its pip bar filled correctly for the nest it holds.
- One doll is shown "selected" (lifted, glow ring).
- Bottom booster bar: Undo (count 2), Hint (count 3), +Slot (count 0, showing a small ▶ ad badge) and Restart.
Also show these states as separate frames: (a) first-level tutorial with a hand pointer, (b) the soft "looks stuck — try Undo?" banner, (c) the same board at maxSize 3 with 2 shelves (an easy early level).
```
**Save as:** `design/screens/gameplay*.png`

---

## Prompt 7 — Home screen

```
Design the Home screen at 390×844:
- Chapter background with a shelf showing a few dolls idling happily (cute ambient scene).
- Top: coin pill (tap → shop) and a settings gear.
- Center: a big chunky "Level 24" PLAY button with a small HARD badge.
- Tiles: Daily Puzzle (streak flame with the number 4), Museum (the next figurine as a silhouette with progress "7/20") and Remove Ads.
- Bottom nav: Shop · Home · Museum.
Also design the splash/loading screen and the app logo wordmark "Nesty" with a small doll forming the "y" or dotting the "e".
```
**Save as:** `design/screens/home.png`, `design/screens/splash.png`, `design/brand/logo.svg`

---

## Prompt 8 — Popups and sheets

```
Design these overlays on top of a dimmed gameplay screen:
1. Win screen: "Level Complete!" with confetti, the completed doll families hopping in a row, coins counting "+25", a rewarded button "▶ ×3 coins" and a "Continue" button, plus a museum progress bar "8/20 → The Sailor Family".
2. Out of Moves bottom sheet: "No moves left!" with 3 options: Undo (free), "+1 Slot" (▶ or 150 coins) and Restart.
3. Booster purchase popup (e.g. Hint): its icon, the benefit in one line, "60 coins" and "▶ Watch ad" buttons.
4. New mechanic intro card: "Towers!" with an illustration showing the hidden silhouettes and top reveal, one sentence and a "Got it" button. Also make versions for "Glass Cases" and "Ice".
5. Chapter complete: a figurine reveal under a spotlight, "Added to your Museum!" and "+150 coins".
6. Pause menu.
7. Remove Ads offer: a friendly and honest card with "$2.99" and "No thanks".
8. ATT pre-prompt: a friendly explanation screen shown before the iOS tracking dialog.
```
**Save as:** `design/screens/popup_*.png`

---

## Prompt 9 — Shop, Museum, Daily, Settings

```
Design these 4 screens at 390×844:
1. Shop with tabs Coins · Skins · Themes · No Ads. Coin packs: 600 / 4000 (BEST VALUE) / 9000 coins. The skin card previews a row of 5 colored dolls, with a price in coins or "Owned/Equipped".
2. Museum: wooden display shelves of collected figurine families by chapter, with locked slots as silhouettes, and a detail view of one figurine with its name and a one-line flavor text.
3. Daily Puzzle: a 7-day calendar strip with checkmarks, the streak flame count, today's "Play" button, a chest at day 7 and a streak-freeze indicator.
4. Settings: toggles for Sound, Music, Haptics and Color Symbols (Subtle / Large), plus Language, Restore Purchases, Privacy Policy, Support and a version footer.
```
**Save as:** `design/screens/shop.png`, `museum.png`, `museum_detail.png`, `daily.png`, `settings.png`

---

## Prompt 10 — Extra doll skins (same template)

```
Using EXACTLY the same SVG template rules as the Classic doll (same 512×768 artboard, same group ids, split line at y=400, belly badge at 256,590, same technical limits), design these skins. Each one needs its SVG code and a preview board with all colors and the size lineup:
1. "Ocean" — sailor collar, a little anchor on the scarf, wave trims.
2. "Space" — a round astronaut-helmet visor in place of the headscarf, star speckles.
3. "Sweets" — a frosting drip on the scarf, sprinkles and a candy stripe apron.
4. "Forest Friends" — animal-ear hood (fox/bear), leaf trims.
5. "Seasons: Winter" — knitted hat, snowflake pattern, fluffy trim.
The mask layers must stay grayscale so the game can tint them in any color.
```
**Save as:** `design/skins/{ocean|space|sweets|forest|winter}/{id}.svg` + `skin.json` + `preview.png`

---

## Prompt 11 — Museum figurines (chapter rewards)

```
Create 10 museum figurine illustrations (600×600, transparent background). Each shows a special themed family of nesting dolls standing in a row, from big to small, on a small display plinth:
1 The Classic Family · 2 The Sailor Family · 3 The Baker Family · 4 The Astronaut Family · 5 The Gardener Family · 6 The Snow Family · 7 The Circus Family · 8 The Musician Family · 9 The Royal Family (gold accents) · 10 The Explorer Family.
Also make a locked silhouette version of each (flat light-wood color).
```
**Save as:** `design/museum/{01..10}_{name}.png` and `{01..10}_{name}_locked.png`

---

## Prompt 12 — Store assets

```
Create store marketing assets:
1. App icon (1024×1024, no text): a single glossy Cherry doll with its top half lifted slightly, a smaller Sky doll peeking out, on a warm cream-to-honey gradient. It must read clearly at 48 px.
2. Google Play feature graphic (1024×500) with the "Nesty" logo and "Nest them all!".
3. 6 phone screenshots (1290×2796) with short headline captions:
   "Nest the dolls — biggest to smallest!", "So satisfying *clack*", "Hundreds of cozy puzzles", "Collect adorable doll families", "Daily puzzles & streaks", "Play offline, anytime".
```
**Save as:** `design/store/icon.png`, `feature_graphic.png`, `screenshot_{1..6}.png`

---

## Prompt 13 — Motion storyboard (for the developer)

```
Create a motion storyboard with numbered key frames and timing notes (in ms) for these animations, so a developer can recreate them in code:
1. Pick up (lift + wobble)
2. Move (arc path)
3. Nest inside (the target lid lifts, the small nest drops in, the lid snaps and squash/stretch)
4. Swallow (the big doll's lid opens in mid-air and it drops over the small doll)
5. Set complete (shine sweep, double hop, flies to the counter with a sparkle trail, dust puff)
6. Invalid move (shake)
7. Tower reveal (paint-splash fill)
8. Glass unlock and ice shatter
9. Win celebration
Use the timings: pick 120, move 260 easeOutBack, lid lift 80, drop-in 120, lid snap 70, squash settle 120, invalid shake 3×80.
```
**Save as:** `design/motion/storyboard.png`

---

## Optional Prompt 14 — Admin panel look

```
Design a clean desktop web admin panel (1440×900) for the Nesty level editor. Use a simple light theme with Nesty accent colors.
Screens: Levels table (order, id, chapter, tier badge, win rates, status, drag handles); Level Editor (left: shelf/slot builder and doll palette of 11 colors × 6 sizes; center: board preview; right: validation checklist, Solve/Simulate/Playtest buttons, metrics and a solution step list); Skin upload page (drag-drop SVG, validation results, live tinted preview grid).
```
**Save as:** `design/admin/*.png`

---

## Hand-off checklist before giving `design/` to Claude Code
- [ ] `tokens.json` saved and valid JSON
- [ ] `classic.svg` opens in a browser and contains the 8 group ids exactly
- [ ] All symbols are 128×128 path-only SVGs
- [ ] Screens exported for: gameplay, home, splash, all popups, shop, museum, daily, settings
- [ ] Sounds sourced separately (list in GAME_SPEC §11.3). Claude Design doesn't make audio.
