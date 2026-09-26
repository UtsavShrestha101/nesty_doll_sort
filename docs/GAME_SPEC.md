# Nesty: Doll Sort — Game & Technical Specification

Version 1.0 · Working title "Nesty: Doll Sort" (final name TBD)

---

## 0. Summary

**One-liner:** A cozy sorting puzzle where you nest colorful wooden dolls inside each other, from biggest to smallest, to complete each family before you run out of space.

**Why it stands out:** Normal sort puzzles only ask "same color?" Nesty also asks "the next size?" A doll only goes into the doll exactly one size bigger. This size rule creates a new kind of planning. Nesting also has a very satisfying physical moment: the lid lifts, the small doll drops in, and the lid snaps shut with a wooden *clack*.

**Design pillars**

1. **Understood in 3 seconds.** Anyone who has seen a matryoshka gets it without a tutorial.
2. **Satisfying every move.** Every merge gets a lid-lift + clack + squash animation, a haptic tick and a pitch that matches the doll's size.
3. **Short sessions, long goals.** Levels take 1–3 minutes. Chapters unlock collectible museum figurines. Daily puzzles and streaks bring players back.
4. **Respectful monetization.** Rewarded ads are always optional. Interstitials only appear between levels, never during play. A one-time "Remove Ads" purchase is offered.
5. **Offline-first.** Everything playable offline. Online only adds new levels and new skins.

**Platforms:** Android (primary), iOS. Portrait only. Min Android 7 (API 24), iOS 14.

---

## 1. Target players

- Adults 18–55 who play sort, match and screw-style puzzles. Commuters and people winding down.
- Store listing age target: 13+ or 18+ (see §17). The game is not designed for children.
- Tone: warm, gentle, never punishing. There are no timers in normal levels and no lives system.

---

## 2. Core gameplay

### 2.1 Objects

- **Doll:** has a `color` (see §12.3) and a `size` from 1 (smallest) to `maxSize` (3–6, set per level).
- **Nest:** one or more dolls of the **same color** nested together. They are stored from the outer doll to the inner doll, and sizes must be **consecutive and decreasing**. Examples: `[red4, red3]` and `[blue2]` are valid. `[red4, red2]` is invalid. A nest shows only its outer doll. A **pip bar** on the stand under the slot shows which sizes are inside (§10.3).
- **Full set:** a nest containing every size from `maxSize` down to 1. When it forms, it **completes**. It celebrates, flies to the collection counter and frees its slot.
- **Slot:** a spot on a shelf that holds nests. Types are listed in §3.
- **Shelf:** a row of slots. A board has 1–4 shelves with 2–5 slots each.

### 2.2 The move

The player picks up a whole nest from a slot and drops it on another slot. Both input styles are supported:

- **Tap–tap:** tap a nest to lift it (it rises and wobbles). Tap the target slot to drop. Tapping the same slot again cancels. Tapping a different pickable nest switches the selection.
- **Drag & drop:** press and drag. Release over a slot to drop there. Release over nothing to cancel.

A drop is legal when **any** of these is true:

1. The target slot is an empty open slot. The nest moves there.
2. The target's top nest `T` has the same color as the moving nest `M`, and `M.outer.size == T.inner.size − 1`. **M goes inside T.**
3. Same color, and `T.outer.size == M.inner.size − 1`. **T goes inside M** (the "swallow"). The merged nest stays in the target slot.

Any other drop is **invalid**. The target shakes, a soft "bonk" plays and the selection is cleared.

### 2.3 Win and stuck

- **Win:** every doll on the board has been completed into full sets.
- **Out of moves:** there is no legal move at all (no empty open slot and no possible merge). The "Out of moves" sheet opens (§10.2).
- **Soft stuck:** legal moves still exist but the on-device solver proves the level can't be won anymore within its node budget (§6.3). A gentle banner appears: *"Hmm, this looks stuck — try Undo?"* This check runs in the background after each move and never blocks input.

### 2.4 Undo and permanence

- Undo reverts the last move. The undo history is **cleared whenever a set completes**. Completions and unlocks are permanent.
- Restart is always free and resets the level to its start.

---

## 3. Slot types and mechanics

Mechanics are introduced gradually (§3.7). Each new one gets a one-time intro card (§10.2).

### 3.1 Open slot
Holds 0 or 1 nest. It is the basic slot. All open slots follow the same rules, so the solver treats them as interchangeable (§6.2).

### 3.2 Tower slot
Holds a stack of nests (bottom → top), up to 4 deep. Only the **top** nest can be picked up or merged into.

- Nests under the top are shown as **wooden silhouettes**. Their size (height) is visible but their color is hidden. When a nest becomes the top, its color fills in with a paint-splash reveal.
- You cannot place a new nest onto a tower. Towers only accept merges into their top nest.
- An empty tower becomes a normal open slot.

### 3.3 Locked slot (glass case)
Shows a padlock tagged with a color symbol. It may contain a nest that is visible behind glass but can't be used. The case breaks and the slot becomes an open slot the moment the **first full set of its `unlockColor`** completes.

### 3.4 Ice (modifier on any slot)
The slot is frozen with a counter `n`. It can't be picked from or dropped onto. Each full set completed anywhere lowers every ice counter by 1, with crack stages shown. At 0 the ice shatters and the slot works normally.

### 3.5 Golden doll (v1.1, optional)
A gold doll of a fixed size that counts as **any color** for merging. A nest with gold in it takes the color of its non-gold dolls. A nest that is only gold matches any color. At most one gold doll per level. It counts toward the set it ends up in.

### 3.6 Extra slot (booster)
Adds one temporary open slot at the right end of the bottom shelf, or below it if the shelf is full. It lasts until the level ends. Max 2 per level.

### 3.7 Introduction schedule

| Level | Introduces |
|---|---|
| 1 | Basic nesting, 1 color, `maxSize` 3 (guided tutorial) |
| 2 | Swallow (drop big onto small), 2 colors |
| 3–9 | Up to 3–4 colors, `maxSize` 3 |
| 10 | `maxSize` 4 |
| 16 | Tower slots |
| 31 | Locked slots |
| 51 | Ice |
| 71 | `maxSize` 5 |
| 101 | Golden doll (if shipped) |
| 121+ | Occasional `maxSize` 6 "super hard" levels |

---

## 4. Formal rules (implement in `nesty_core`)

```text
Doll   { color: DollColor, size: int (1..6) }
Nest   { dolls: List<Doll> }   // outer→inner; same color; size[i+1] == size[i]-1
         outer = dolls.first ; inner = dolls.last
Slot   = OpenSlot   { nest?: Nest }
       | TowerSlot  { stack: List<Nest> }          // bottom→top, top = stack.last
       | LockedSlot { unlockColor: DollColor, nest?: Nest, unlocked: bool }
       + modifier ice: int (0 = none)
Level  { maxSize, shelves: List<List<Slot>>, goldPresent? }
State  { slots (flattened, stable ids "r{row}c{col}" + "x{n}" for extra slots),
         completedSets: int, completedByColor: Map<DollColor,int>, moveCount }
```

```text
interactable(slot) = slot.ice == 0 && !(slot is LockedSlot && !slot.unlocked)
top(slot)          = Open: nest | Tower: stack.last? | Locked(unlocked): nest

canPick(s)         = interactable(s) && top(s) != null

tryMove(src, dst) -> MoveResult:
  require src != dst, canPick(src), interactable(dst)
  M = top(src)
  if top(dst) == null:
     if dst is Open (or unlocked Locked, or empty Tower treated as Open): place M
     else invalid
  else:
     T = top(dst)
     require colorsMatch(T, M)              // gold rule §3.5
     if   M.outer.size == T.inner.size - 1: merged = T.dolls ++ M.dolls
     elif T.outer.size == M.inner.size - 1: merged = M.dolls ++ T.dolls
     else invalid
     replace top(dst) with merged
  remove M from src (tower pops top → emit Revealed if a new top appears)
  if merged is full (outer.size == maxSize && inner.size == 1):
     remove it; completedSets++, completedByColor[c]++
     emit Completed(slotId, color)
     for each Locked with unlockColor == c and !unlocked: unlock → emit Unlocked
     for each slot with ice > 0: ice-- → emit IceCracked / IceShattered
     clear undo history
  moveCount++
  return MoveResult(events: [...], newState)
```

`MoveEvent` types (the game animates them in this order): `Picked`, `Placed`, `NestedInto(dstId, direction: inside|swallow)`, `Revealed(slotId)`, `Completed(slotId, color)`, `Unlocked(slotId)`, `IceCracked(slotId, remaining)`, `IceShattered(slotId)`, `Won`, `OutOfMoves`.

Core also exposes `legalMoves(state)`, `isWon(state)`, `isOutOfMoves(state)`, `undo()`, `addExtraSlot()`, and `hint(state, budget) → Move?` (from the solver).

---

## 5. Level format

### 5.1 JSON (schema v1)

Dolls are written compactly as `"<color><size>"`, for example `"red4"`. Nests are arrays from outer to inner. Tower stacks go from bottom to top.

```json
{
  "schemaVersion": 1,
  "id": "L0042",
  "maxSize": 4,
  "shelves": [
    [ {"type": "open",  "nest": ["red4", "red3"]},
      {"type": "open",  "nest": null},
      {"type": "tower", "stack": [["blue2"], ["green4"], ["red2", "red1"]]} ],
    [ {"type": "locked", "unlockColor": "red", "nest": ["green3", "green2", "green1"]},
      {"type": "open",  "nest": ["blue4", "blue3"], "ice": 2},
      {"type": "open",  "nest": ["blue1"]} ]
  ]
}
```

### 5.2 Firestore level document wrapper

```json
{
  "order": 42,                 // global play order (1-based), unique among published
  "chapterId": "ch03",
  "status": "draft | published | archived",
  "data": { ...level JSON above... },
  "tier": "easy | medium | hard | superhard",
  "metrics": { "solverMoves": 14, "casualWinRate": 0.38, "smartWinRate": 0.81,
               "branching": 3.4, "nodes": 18233 },
  "rewardCoins": 25,
  "version": 3,                // bump on every edit
  "updatedAt": "<timestamp>", "updatedBy": "<uid>"
}
```

### 5.3 Validation (shared by admin and game loaders)

1. `schemaVersion` is supported. `maxSize` is 3–6.
2. 1–4 shelves, 2–5 slots per shelf, and the total including extra slots fits the layout (§10.3).
3. Every nest is valid (§2.1). No nest is already a full set.
4. For every color, the doll counts equal `k × (one of each size 1..maxSize)` for some k ≥ 1. Gold dolls are exempt from this count.
5. Tower depth ≤ 4. A tower's stack is never empty at the start.
6. Each locked `unlockColor` appears among the level's dolls, and not every doll of that color is sealed inside the lock itself.
7. There is at least one legal first move.
8. The solver proves the level is solvable (admin budget, §6.3).

Invalid levels are rejected by the admin and skipped with a log entry in the game.

---

## 6. Solver, simulator, generator, difficulty

### 6.1 Purpose
- **Admin:** proves a level is solvable, shows the optimal solution, plays it back and suggests a tier.
- **Game:** powers hints and soft-stuck detection. It runs in an isolate with a small budget.
- **Generator:** creates endless bonus levels and daily puzzles on the device.

### 6.2 State encoding and canonical form
Encode each nest as `(color, outerSize, len)` packed into an int. Open slots are interchangeable, so the canonical key **sorts open-slot contents**. Towers, locked slots and ice slots keep their fixed identity. Use a 64-bit hash of the canonical form for the visited set.

### 6.3 Search
A* (or IDA* for memory) where each move costs 1. Heuristic `h = nestsOnBoard − setsRemaining` (every merge lowers the nest count by exactly 1, so it never overestimates). Skip moves from one empty open slot to another, and moves that shift a lone nest from one open slot into an empty open slot, since they're pointless.

Budgets: admin 500,000 nodes. Hint on device 30,000 nodes. Soft-stuck check on device 20,000 nodes. If the budget runs out, return `unknown`, never `unsolvable`.

The fallback hint when the budget runs out is the first legal merge that doesn't take the last empty slot. Otherwise, any move into an empty slot.

### 6.4 Simulator (difficulty)
Run two bots, each for 300 seeded playthroughs with a 250-move cap:

- **Casual bot:** takes a random merge with 70% chance when one exists. Otherwise it makes a random legal move. No undo.
- **Smart bot:** greedy. It prefers moves that complete a set, then merges, then moves that don't fill the last empty slot, with 1-ply lookahead.

**Tier from casual win rate:** easy ≥ 0.65, medium 0.35–0.65, hard 0.12–0.35, superhard < 0.12. Every level must have a smart win rate ≥ 0.5 or be flagged "expert only" in the admin.

### 6.5 Generator (deterministic)
PRNG: a small seeded generator implemented in core (e.g. xoshiro128** or PCG32). **Don't use `dart:math Random` because its sequence may change between SDK versions.** Record `generatorVersion` with every generated level.

Params: `colors`, `setsPerColor` (default 1), `maxSize`, `shelves`, `slotsPerShelf`, `towers`, `towerDepth`, `emptySlots`, `locked`, `iceSlots`, `targetTier`, `seed`.

Algorithm:
1. Create the full sets. Split each set's run `maxSize..1` into 1–`maxSize` consecutive segments at random cut points.
2. Shuffle the segments into towers (top segments of towers should not be immediately mergeable too often) and open slots. Leave `emptySlots` empty.
3. Place locked and ice slots on randomly chosen occupied slots, respecting validation rule 6.
4. Validate, solve and simulate. Retry with the next sub-seed up to 50 times until the tier matches `targetTier`. If none match, return the closest.

### 6.6 Difficulty curve (authored and generated)
Inside every block of 10 levels, the tier pattern is `E E M E M H M E M S` (S = superhard). Chapters raise the baseline by adding colors, size, towers and fewer empty slots. Hard levels show a red "HARD" badge. Superhard levels show a purple "SUPER HARD" badge and pay more (§7.3).

---

## 7. Progression and meta

### 7.1 Levels and chapters
- Levels are played in global `order`. The next level unlocks when one is won.
- **Chapters** are 20 levels each, with their own board theme (background + shelf wood).
- Launch target: 200 authored levels (10 chapters). After that, add about 20 per week from the admin.
- **Bonus Endless:** if the player passes the last published level, the game generates levels on the device with `seed = 1_000_000 + levelNumber`, following the curve. The UI shows "Bonus Level N" and a note that new chapters are coming.

### 7.2 Doll Museum (collection)
Every completed chapter awards a **museum figurine**, which is a special themed doll family (e.g. "The Sailor Family"). The Museum screen shows shelves of earned figurines and locked silhouettes for the next ones. There is a progress bar on the win screen ("7/20 to the Sailor Family").

### 7.3 Coins
| Source | Coins |
|---|---|
| Win easy/medium | 10 |
| Win hard | 25 |
| Win superhard | 50 |
| Rewarded "×3" on win screen | multiply that level's coins (Remote Config) |
| Daily puzzle | 50, and day-7 streak chest 300 |
| Chapter complete | 150 |

| Spend | Coins |
|---|---|
| Undo (after the 2 free per level) | 20 |
| Hint | 60 |
| Extra slot | 150 |
| Doll skin | 800–3000 |
| Board theme | 500–2000 |

All prices come from Remote Config / Firestore so they can be tuned without an update.

### 7.4 Cosmetics
- **Doll skins:** full art sets that change how every doll looks (Classic, Ocean, Space, Sweets, Forest Friends, Seasons…). They are uploaded through the admin and downloaded on demand. Classic is bundled.
- **Board themes:** background + shelf art. Chapter themes can be used freely in any chapter once unlocked.

### 7.5 Daily puzzle
One puzzle per day. The level is generated from `seed = yyyymmdd`, pinned `generatorVersion` and tier medium/hard. If an admin override document exists for that date, it replaces the generated one. The streak calendar shows 7 days. Missing a day resets the streak, but one "streak freeze" is earned each week.

### 7.6 Tutorial
- **L1:** a hand pointer shows "tap the small doll → tap the big doll". Other input is blocked until the demonstrated move is made.
- **L2:** the hand demonstrates the swallow move.
- **L16, L31, L51:** mechanic intro cards with a short looping animation.

---

## 8. Boosters

| Booster | Effect | How to get |
|---|---|---|
| Undo | Revert last move (§2.4) | 2 free per level, then coins or a rewarded ad |
| Hint | Highlights the next move from the solver with a pulsing arrow | Coins or a rewarded ad |
| Extra slot | §3.6 | Coins or a rewarded ad. Also offered on the Out of Moves sheet |

Inventory counts appear on booster buttons. New players get 3 hints and 2 extra slots as starting gifts.

---

## 9. Monetization

### 9.1 Ads (AdMob via `google_mobile_ads`; mediation later)
- **Rewarded (optional, always opt-in):** booster purchase buttons, Out of Moves "+1 slot", win screen "×3 coins" and daily chest double. The button shows a small ▶ ad icon.
- **Interstitial:** only on the transition *after* a win (win screen → Continue → ad → next level). It never appears during play, on restart or right after a fail. Rules:
  - None before `interstitial_first_level` (default 8).
  - Then every `interstitial_every_n_levels` wins (default 3).
  - At least `interstitial_min_seconds` (default 90) since the last interstitial or rewarded ad.
  - Never in the first 5 minutes of a session.
  - Disabled completely when `adsRemoved == true`.
- **No banners in gameplay.** An optional small banner on the Home screen is controlled by Remote Config and defaults to off.
- **App open ads:** off in v1.
- Preload one rewarded and one interstitial ad. Reload after they're shown, and when connectivity returns.
- **Offline:** ad-based buttons change to their coin price. If the player has no coins, the button is disabled with the hint "Connect to watch an ad". The game never hangs waiting for an ad (3 s timeout).

### 9.2 In-app purchases (`in_app_purchase`)
| Product ID | Type | Suggested price |
|---|---|---|
| `remove_ads` | Non-consumable | $2.99 |
| `starter_pack` | Non-consumable, one-time | $1.99 (1500 coins + 3 extra slots + 5 hints) |
| `coins_small` | Consumable | $0.99 (600) |
| `coins_medium` | Consumable | $4.99 (4000) |
| `coins_large` | Consumable | $9.99 (9000) |
| `no_ads_bundle` | Non-consumable | $4.99 (remove ads + 3000 coins) |

The "Remove Ads" offer appears after the 3rd interstitial and is always in the Shop. **Restore Purchases** is in Settings (required on iOS). v1 verifies receipts on the client. Adding server-side verification through Cloud Functions is a later milestone.

### 9.3 Consent and privacy
- Show the Google UMP consent form (via `google_mobile_ads` `ConsentInformation`) **before** initializing ads when it's required (EEA/UK).
- iOS: show the ATT prompt after the first win of level 3, not at launch, with a friendly pre-prompt screen before it.
- A privacy policy URL is required. It's linked in Settings and in the store listings.

### 9.4 Remote Config keys (with defaults in code)
```
interstitial_first_level        8
interstitial_every_n_levels     3
interstitial_min_seconds        90
interstitial_session_grace_sec  300
home_banner_enabled             false
rewarded_coin_multiplier        3
free_undos_per_level            2
price_undo / price_hint / price_slot   20 / 60 / 150
reward_easy / reward_hard / reward_superhard   10 / 25 / 50
daily_reward / streak7_reward   50 / 300
remove_ads_offer_after_interstitials   3
rate_prompt_level               15
```

---

## 10. Screens and UX

### 10.1 Flow
```
Splash/loading → (first launch: consent) → Home
Home → Play → Gameplay → Win screen → [interstitial?] → Gameplay (next)
                        → Out of Moves sheet → Undo / +Slot / Restart
Home → Daily · Museum · Shop · Settings
```

### 10.2 Screen list
1. **Splash:** logo and a quick loading bar. It loads the save file, bundled levels and the skin while the level sync starts in the background.
2. **Home:** cozy toy-shop background. A big **"Level 24"** play button (with a HARD badge if the level is hard). The top bar shows coins (tap → Shop) and a settings gear. Tiles for Daily (streak flame), Museum (next figurine progress) and Remove Ads (hidden if purchased). A bottom nav with Shop · Home · Museum.
3. **Gameplay:** top bar with pause, "Level 24" + tier badge and coins. The board is centered. The bottom booster bar has Undo (count), Hint (count), +Slot (count) and Restart.
4. **Win:** the completed families hop, confetti falls and coins count up. Buttons are "▶ ×3 coins" (rewarded) and "Continue". The museum progress bar appears here.
5. **Out of Moves sheet:** "No moves left!" with Undo (free / ▶), "+1 Slot" (▶ / coins) and Restart.
6. **Soft-stuck banner** (non-modal, §2.3).
7. **Booster purchase popup:** shown when the player taps a booster with 0 count. Choices are coins or ▶ ad.
8. **Mechanic intro card:** title, a looping mini animation, one sentence and "Got it".
9. **Chapter complete:** a figurine reveal with a spotlight, "Added to your Museum!" and +150 coins.
10. **Museum:** shelves of figurines by chapter. Tap one to see a larger view with its name and short flavor text.
11. **Daily:** a 7-day calendar strip, today's puzzle button, the streak count and the chest.
12. **Shop:** tabs for Coins · Skins · Themes · No Ads. Skins show a preview of the whole color lineup.
13. **Settings:** sound, music, haptics, color symbols (always / assist mode), language, restore purchases, privacy policy, support email and version.
14. **Pause:** resume, restart, home and settings shortcuts.
15. **Bonus Endless intro:** "You've finished all levels! New chapters are coming — play bonus levels meanwhile."
16. **Rate prompt:** native `in_app_review` after winning `rate_prompt_level` if the player hasn't failed in the last 3 levels.

### 10.3 Board layout
- The board fits between the top bar and the booster bar with 16 dp side margins. Slot width is `min(96dp, availableWidth / slotsInWidestShelf)`. The shelf height fits the tallest doll (`maxSize`) plus the stand.
- **Doll height by size**, as a fraction of the slot's maximum doll height: 1 → 0.42, 2 → 0.54, 3 → 0.66, 4 → 0.78, 5 → 0.89, 6 → 1.00. At `maxSize` 3, scale up so size 3 = 1.00.
- Each slot has a wooden **stand**. Its front shows a **pip bar**: `maxSize` pips, filled in the nest's color for the sizes inside it. This way players never need to remember what's hidden inside.
- Towers draw stacked nests with a slight vertical offset (silhouettes below, colored top).
- Tap targets are at least 48 dp. The whole slot column is the hit area.

---

## 11. Game feel

### 11.1 Animations (durations are defaults, tune by feel)
| Event | Animation |
|---|---|
| Pick | Nest rises 14 dp, scales to 1.05 and wobbles ±3° (loop while selected) — 120 ms |
| Move | Arc path to target — 260 ms `easeOutBack` |
| Nest inside | Target's top half lifts 30% of its height (80 ms). The moving nest shrinks into the bottom half (120 ms). The lid snaps down (70 ms). Squash 0.92/1.08 then settle (120 ms) |
| Swallow | Same, but the big doll's lid lifts in mid-air and it drops over the small one |
| Complete | A shine sweeps across the doll, it hops twice, then flies to the top-bar collection counter with a sparkle trail. Dust puff on the stand |
| Invalid | Target shakes 3× (±6 dp, 80 ms each) and the picked nest drifts back |
| Reveal (tower) | The silhouette fills with a color paint-splash wipe — 200 ms |
| Unlock | Padlock pops, glass cracks and shatters into shards |
| Ice | 3 crack stages, then a shatter burst |
| Win | Confetti burst. Board dolls do a staggered little dance |

Combo: completing sets within 4 s of each other raises the completion chime's pitch (up to 5 steps).

### 11.2 Haptics
Light tick on pick, medium on nest, success pattern on complete, soft error on invalid. All of them can be turned off.

### 11.3 Audio (owner supplies the files; list for sourcing)
- `pick.ogg` — wooden tick
- `clack_1..3.ogg` — wooden lid clack. **Pitch-shifted by size** (bigger = lower)
- `whoosh.ogg`, `bonk.ogg`
- `complete_1..5.ogg` — rising chime steps for combos
- `win.ogg`, `coins.ogg`, `unlock_glass.ogg`, `ice_crack.ogg`, `ice_shatter.ogg`, `button.ogg`
- Music: 2 cozy acoustic loops (home and gameplay), 60–90 s, seamless

Use `flame_audio` or `flutter_soloud` for low-latency SFX. Keep music and SFX on separate volume controls.

---

## 12. Art pipeline

### 12.1 Direction
"Cozy folk-toy shop." Glossy lacquered wooden dolls with simple hand-painted faces. Warm afternoon light. Chunky rounded UI in cream, warm wood and soft pastels. See `design/` for the approved look and `design/tokens.json` for exact values.

### 12.2 Doll skin format (canonical: one SVG per skin)
The artboard is **512 × 768**. All layers share the same origin, so they align when drawn on top of each other. The SVG contains these top-level `<g id="...">` groups:

| Group id | Tinted? | Content |
|---|---|---|
| `shadow` | no | soft contact ellipse under the doll |
| `bottom_mask` | **yes** | lower body shape in grayscale (white = full color, grays = baked shading) |
| `bottom_detail` | no | painted apron, lines and flowers in white/gold/dark ink |
| `top_mask` | **yes** | upper body/headscarf in grayscale |
| `face` | no | face oval, eyes, cheeks, smile, hair |
| `top_detail` | no | scarf pattern and trims |
| `shine_top`, `shine_bottom` | no | white highlights with opacity (drawn with a screen/plus blend) |

Plus a `<metadata>` block, or a sidecar `skin.json`:

```json
{ "skinId": "classic", "splitY": 400, "lidLiftPx": 120,
  "symbolAnchor": [256, 590], "symbolSize": 110, "version": 1 }
```

Allowed SVG features: paths, basic shapes, linear and radial gradients, opacity, clipPath. **Not allowed:** filters/blur, masks, text, embedded raster images. (This keeps them compatible with `flutter_svg`.)

**Rendering:** the admin splits the SVG into per-group SVG strings on upload (using the `xml` package), validates them and stores them in Storage. The game downloads them, rasterizes each layer once per needed size into `ui.Image` (through `flutter_svg` → `Picture.toImage`) and caches them to disk as PNG. Tinting uses `ColorFilter.mode(color, BlendMode.modulate)` on the mask layers. The top layers (`top_mask`, `face`, `top_detail`, `shine_top`) are drawn with a Y offset during lid-lift. PNG layers (one file per group, same 512×768 canvas) are also accepted as an alternative format.

### 12.3 Doll colors (each has a symbol for color-blind accessibility)
| id | Name | Hex | Symbol |
|---|---|---|---|
| `red` | Cherry | `#E5484D` | heart |
| `orange` | Tangerine | `#F2893B` | flower |
| `yellow` | Sunflower | `#F5C518` | sun |
| `green` | Leaf | `#46A758` | leaf |
| `teal` | Lagoon | `#12A594` | wave |
| `blue` | Sky | `#3E8EDE` | drop |
| `purple` | Grape | `#8E4EC6` | star |
| `pink` | Bubblegum | `#E93D82` | bow |
| `navy` | Midnight | `#2F3E8F` | moon |
| `brown` | Cocoa | `#A0673C` | acorn |
| `gold` | Gold (wild) | gradient | crown |

Symbols are 128×128 SVGs in `design/symbols/`. They are drawn on the doll's belly at `symbolAnchor` in a darker shade of the doll color. By default they are always visible (subtly). Assist mode makes them bigger with a white backing.

### 12.4 Board theme format
`background` (portrait art, 1290×2796 PNG/WebP, with the important content centered in a 1080×1920 safe area), `shelf` (tileable wooden plank strip, SVG or PNG), `stand` (slot stand SVG), and a `palette` JSON (for UI accents).

### 12.5 Procedural placeholder (build this first)
`nesty_render/PlaceholderDollPainter` draws the doll in code: a body made of a rounded bottom path and a circular head, radial-gradient shading in the doll color, a white oval face with dot eyes, a split line and a symbol. The game must look acceptable with this alone, and it stays as the fallback if a skin fails to load.

### 12.6 Phase 2 (not v1): true 3D
When Flutter GPU reaches stable, a 3D renderer can revolve the doll silhouette into a lathe mesh generated in code (no model files needed) and render it with `flutter_scene`. Keep rendering behind a `DollRenderer` interface so this can be swapped in later.

---

## 13. Technical architecture

### 13.1 Packages
- `nesty_core` (pure Dart): models, `LevelCodec` (JSON ⇄ model), `Validator`, `Rules`, `GameSession` (state + undo + extra slots + events), `Solver`, `Simulator`, `Generator`, `Prng`.
- `nesty_render` (Flutter): `DollRenderer` interface, `SvgSkinRenderer`, `PlaceholderDollPainter`, `SkinCache`, `BoardLayout` (pure layout math shared by game and admin).
- `apps/game`: Flame `NestyGame` + components (`BoardComponent`, `SlotComponent`, `NestComponent`, `FxLayer`). Flutter overlays for all menus and popups. `auto_route` for screens. Cubits (`flutter_bloc`) resolved through `get_it` + `injectable` for app and UI state (owner decision, see `docs/PROGRESS.md`).
- `apps/admin`: a Flutter Web app. Its playtest board is a `CustomPainter` built on `nesty_render` (no Flame).

### 13.2 Preferred dependencies
`flame`, `flame_audio` (or `flutter_soloud`), `flutter_bloc` + `bloc`, `get_it` + `injectable`, `auto_route`, `freezed_annotation`, `json_annotation`, `flutter_svg`, `xml`, `path_provider`, `hive_ce` + `hive_ce_flutter` (game-only local database: device settings now; whether the save document also moves there is an open M3 decision, §13.3), `connectivity_plus`, `google_mobile_ads`, `in_app_purchase`, `in_app_review`, `firebase_core`, `cloud_firestore`, `firebase_storage`, `firebase_analytics`, `firebase_crashlytics`, `firebase_remote_config`, `firebase_auth` (admin; optional anonymous auth in the game later), `vibration` or `HapticFeedback`, `intl` + `flutter_localizations`. Dev and codegen: `build_runner`, `freezed`, `json_serializable`, `injectable_generator`, `auto_route_generator`, `hive_ce_generator`, `bloc_test`, `mocktail`.

### 13.3 Save data
Save is JSON stored in the app documents folder. Writes are atomic (write a temp file, then rename). The file has a schema version and migrations.

```json
{ "schema": 1, "currentLevel": 24, "highestLevel": 24, "coins": 830,
  "inventory": {"hint": 3, "slot": 2},
  "adsRemoved": false, "ownedSkins": ["classic"], "selectedSkin": "classic",
  "ownedThemes": ["ch01"], "selectedTheme": null, "museum": ["ch01"],
  "daily": {"streak": 4, "lastDate": "2026-09-24", "freezes": 1, "done": ["2026-09-24"]},
  "inProgress": { "levelId": "L0024", "levelVersion": 2, "state": {...}, "undo": [...] },
  "settings": {"sound": true, "music": true, "haptics": true, "symbols": "subtle", "locale": "en"},
  "adCounters": {"winsSinceInterstitial": 1, "lastAdAt": 0, "interstitialsShown": 2},
  "stats": {"wins": 23, "moves": 612, "boostersUsed": {...}} }
```

The in-progress level is saved on every move and on app pause. On resume it's restored if the `levelVersion` still matches. Otherwise the level restarts.

### 13.4 Level repository (offline-first)
1. **Bundled:** `apps/game/assets/levels/bundle.json` holds the first 200 levels, exported from the admin (§15). This file is the minimum available offline.
2. **Cache:** `levels_cache.json` holds remote levels plus `manifestVersion`.
3. **Sync** (on launch and on resume, if online, without blocking): read `config/manifest`. If `levelsVersion` is greater than the cached one, page through `levels where status == published orderBy order` (200 per page), validate each, write the cache and swap it in atomically.
4. **Lookup:** build the level list by `order`. Cache entries override bundled ones with the same `id`. When the player passes the last entry, switch to Bonus Endless (§7.1).
5. Never replace the level currently in progress in the middle of a session.

### 13.5 Skin and theme repository
The Classic skin and chapter 1 theme are bundled. Others are downloaded from Storage when bought or selected, rasterized and cached. Show a spinner on the shop card while downloading. If a download fails, keep the current skin.

---

## 14. Firebase

### 14.1 Firestore collections
```
config/manifest            { levelsVersion:int, publishedCount:int, updatedAt }
levels/{levelId}           §5.2
chapters/{chapterId}       { order, title, themeId, museumItemId, status }
skins/{skinId}             { name, priceCoins, status, version, layers:{group:storagePath}, meta:{...skin.json} , previewPath }
themes/{themeId}           { name, priceCoins, status, version, backgroundPath, shelfPath, standPath, palette:{...} }
museumItems/{itemId}       { name, flavor, imagePath, chapterId }
dailyOverrides/{yyyymmdd}  { data: level JSON, tier }
admins/{uid}               { email, addedAt }   // created manually in the console
```

### 14.2 Storage layout
`skins/{skinId}/v{version}/{group}.svg` (or `.png`), `skins/{skinId}/preview.png`, `themes/{themeId}/v{version}/...`, `museum/{itemId}.png`.

### 14.3 Security rules (sketch; finalize in `firebase/`)
```
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    function isAdmin() { return request.auth != null &&
      exists(/databases/$(db)/documents/admins/$(request.auth.uid)); }
    match /levels/{id}   { allow read: if resource.data.status == 'published' || isAdmin();
                           allow write: if isAdmin(); }
    match /{col}/{id}    { allow read: if col in ['config','chapters','skins','themes','museumItems','dailyOverrides'];
                           allow write: if isAdmin(); }
    match /admins/{uid}  { allow read: if request.auth != null && request.auth.uid == uid;
                           allow write: if false; }
  }
}
```
For Storage: public read of `skins/`, `themes/` and `museum/`. Writes only when the user's uid has a document in `admins/` (through a `firestore.exists` check in Storage rules).

### 14.4 Analytics events
`tutorial_step{step}`, `level_start{level, tier, attempt}`, `level_win{level, tier, moves, seconds, undos, hints, slots}`, `level_out_of_moves{level}`, `level_soft_stuck{level}`, `level_restart{level}`, `booster_use{type, source: free|coins|ad}`, `rewarded_offer{placement}`, `rewarded_complete{placement}`, `interstitial_shown{level}`, `iap_purchase{product}`, `daily_complete{streak}`, `chapter_complete{chapter}`, `skin_equip{skin}`, `bonus_level_start{n}`.

Link AdMob to Firebase for ad revenue data. Use Crashlytics for crashes and for non-fatal errors like level validation failures.

---

## 15. Admin panel (Flutter Web)

**Auth:** email/password sign-in with Firebase Auth. Users without an `admins/{uid}` document see "Not authorized".

**Screens:**
1. **Dashboard:** counts by status, manifest version, last publish and a "levels remaining ahead of players" estimate.
2. **Levels list:** table with order, id, chapter, tier, casual/smart win rates, solver moves and status. Filters and search. Drag to reorder within drafts/published. Bulk publish, unpublish and archive.
3. **Level editor:**
   - Shelf builder (add/remove shelves and slots) and slot type picker (open/tower/locked + ice count).
   - A doll palette (color × size). Click a slot to append a doll to its nest or tower. Right-click removes one.
   - Live validation panel (§5.3).
   - **Solve** button: result, move count and step-by-step animated playback.
   - **Simulate** button: bot win rates and a suggested tier.
   - **Playtest:** play the level in the browser using the real core rules.
   - Save Draft (bumps `version`) and Publish.
4. **Generator:** a form with the §6.5 params plus count and seed. It generates a batch that appears as preview cards with metrics. Accept adds them to drafts in the chosen chapter. Reject discards them.
5. **Chapters:** CRUD, theme and museum item assignment.
6. **Skins:** upload an SVG (or a PNG layer set) with a sidecar JSON. Checks group ids, artboard size and disallowed features. Shows a live preview of all colors × sizes, including the lid-lift animation. Set price and status.
7. **Themes** and **Museum items:** upload with preview.
8. **Daily overrides:** calendar view where you can pick or generate a level for a date.
9. **Export bundle:** downloads `bundle.json` of the first N published levels, to put in `apps/game/assets/levels/`.

**Publishing:** publishing, unpublishing or reordering levels runs a batched write that also increments `config/manifest.levelsVersion` and updates `publishedCount`. `order` values must stay unique and continuous among published levels. The admin re-numbers them inside the batch.

---

## 16. Accessibility and localization
- Color symbols are always present (§12.3), with an assist mode that makes them larger.
- Pip bars show nest contents, so no memory load is needed.
- Respect system text scaling in menus (up to 1.3×). Support reduced motion (shorter animations, no screen shake).
- ARB localization from day one. Launch in English, then add es, pt-BR, id, hi, de, fr, tr and ja. Keep strings short.

---

## 17. Compliance checklist
- Privacy policy URL (covers ads SDK, analytics and crash data).
- UMP consent before ads when it's required. iOS ATT pre-prompt + prompt (§9.3). Complete the App Privacy / Data Safety forms accurately.
- Declare the target audience honestly in Play Console and don't market to children. If under-13 players are ever included, the Families policy applies (certified ad SDKs only, no personalized ads).
- Offer Restore Purchases on iOS.
- (The owner should confirm the legal details for their own situation.)

---

## 18. Milestones and acceptance criteria

**M1 — Core (`nesty_core`)**
Models, codec, validator, rules, `GameSession` with undo/extra slot/events, solver, simulator, PRNG and generator.
✅ All §4 rules are unit-tested. Solver fixtures pass. Generator is deterministic. 100 generated levels pass validation and solve.

**M2 — Playable game (placeholder art)**
Flame board, placeholder dolls, tap-tap and drag input, all §11.1 animations in basic form, win and out-of-moves flows, restart, undo, hint, extra slot (free in debug), 30 hand-written test levels in the bundle.
✅ Levels 1–30 can be played start to finish at 60 fps on a mid-range Android device.

**M3 — App shell and meta**
Home, win screen, pause, settings, save/resume, coins, boosters inventory, chapters, museum, daily puzzle, bonus endless, tutorial and intro cards, localization scaffolding, audio and haptics service (placeholder sounds OK).
✅ Kill the app mid-level → it resumes exactly where it was. The daily puzzle is identical across two devices on the same date.

**M4 — Firebase content**
Firebase init, level sync (§13.4), skin/theme download and cache, Remote Config, Analytics and Crashlytics.
✅ Airplane mode on first launch → fully playable. Publishing new levels in the admin → they appear on the next app resume.

**M5 — Admin panel**
Everything in §15, plus security rules and the bundle export.
✅ The owner can build, solve, simulate, playtest and publish a level, and upload a skin that then shows up in the game.

**M6 — Monetization**
`AdsService` (AdMob, test IDs in debug), UMP, ATT, interstitial pacing, rewarded placements, IAP products, restore purchases, remove-ads offer and rate prompt.
✅ All the pacing rules in §9.1 are covered by unit tests using a fake clock. Offline ad buttons fall back to coins correctly.

**M7 — Art and polish**
Integrate the `design/` exports, the Classic skin SVG pipeline, chapter themes, final UI, the full animation polish pass and final audio.
✅ Matches the design screens. There are no layout overflows on 5 test screen sizes (small Android, standard phone, tall phone, small iPhone, iPad portrait).

**M8 — Release prep**
App icons, splash, store screenshots support, app size check (< 60 MB), performance profiling, release build configs with `--dart-define` ad IDs, and privacy links.
✅ Release builds run on real Android and iOS devices with production Firebase.

---

## 19. Later ideas (not v1)
Golden doll (if not in v1), weekend events with special skins, cloud save through anonymous Auth, server-side receipt checks, ad mediation (AppLovin MAX / ironSource), a "relaxed mode" with unlimited undo, seasonal skins, true 3D renderer (§12.6), and a level-sharing code for friends.
