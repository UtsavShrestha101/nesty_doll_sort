# tools/levels/ — the authored levels

The source of the game's bundled levels (spec §13.4, design §4). `nesty_levels
bundle build` turns this folder into `apps/game/assets/levels/bundle.json`,
and CI's `nesty_levels bundle check` proves the result. Never edit the bundle
by hand; edit this folder and rebuild.

`bundle build` also writes each entry's `par`, the star rating's par
(spec-prop §7.10, D146): the fewest moves that solve the level from its
start, which the solver finds (validation rule 8 at the admin budget, A*
with a consistent heuristic). It is not in the level files and needs no
version bump. A level the solver doesn't prove (rules 1–7 fail, unsolvable,
or unknown within 500,000 nodes) is `build.parUnproven`, and nothing is
written.

```
tools/levels/
  manifest.json          # play order, id, chapter, declared tier, version
  authored/<id>.json     # one level per file, pure spec §5.1 JSON
```

## `manifest.json`

```json
{
  "format": "nesty.levels.manifest",
  "manifestVersion": 1,
  "levelsVersion": 0,
  "levels": [
    {
      "order": 1,
      "id": "L0001",
      "chapterId": "ch01",
      "tier": "easy",
      "version": 1,
      "notes": "Tutorial TUT1 …"
    }
  ]
}
```

| Key | Type | Meaning |
|---|---|---|
| `format` | `"nesty.levels.manifest"` | Tells a manifest from a bundle (`nesty.levels`) or a level. |
| `manifestVersion` | `1` | The version of this schema. |
| `levelsVersion` | integer ≥ 0 | Copied to the bundle's `levelsVersion`, which the game compares with the remote manifest (spec §13.4). |
| `levels` | array | The levels in play order. |

Each entry of `levels`:

| Key | Required | Meaning |
|---|---|---|
| `order` | yes | Global play order. It must equal the entry's position (1, 2, 3, …), so a reorder is always a visible edit. |
| `id` | yes | The level id: 1–64 letters, digits, `_` or `-` (it names the file). Unique. The level file `authored/<id>.json` must carry the same `id`. |
| `chapterId` | yes | `ch01` for levels 1–20, `ch02` for 21–40, … (20 per chapter, spec §7.1). |
| `tier` | yes | The declared tier: `easy`, `medium`, `hard` or `superhard`. It must follow the spec §6.6 pattern (`E E M E M H M E M S` per 10 levels) and equal the simulator's tier (spec §6.4, design A32). |
| `version` | yes | The level's edit version, 1 or more (spec §5.2). Raise it whenever the board changes: the game restores an in-progress save only while the version matches (spec §13.3). `bundle build` refuses a changed board at the same version. Changing only the tier or chapter needs no bump. |
| `tierOverride` | no | The reason the declared tier stands although the simulator suggests another. Allowed only for the tutorials (orders 1 and 2, spec §7.6) and for boards of open slots without ice, which always simulate easy (D26). Anywhere else it is an error; where the simulator agrees it is a warning. |
| `notes` | no | Free text for authors (the board's idea, its intended solution). Not copied into the bundle. |

The tools read the manifest strictly: unknown keys, wrong types, empty text
and out-of-range numbers are errors with a JSON pointer. Every
`authored/*.json` must be listed, so no level is silently left out. The
bundle's `rewardCoins` comes from the declared tier (spec §7.3, design A27:
easy and medium 10, hard 25, superhard 50).

## Level files

`authored/<id>.json` is exactly the level JSON of spec §5.1 (schema v1,
`nest: null` for an empty slot, `ice` only when above 0). Any whitespace is
fine: the bundle holds the codec's canonical form. `generatorVersion` and
`seed` are optional (design A20); a board drafted with `generate` may keep
them.

## What `bundle check` enforces

1. The committed bundle is byte-identical to what `bundle build` writes.
2. Every level passes validation rules 1–8 (spec §5.3), rule 8 at the admin
   budget of 500,000 nodes (spec §6.3). The game's loader only re-checks
   rules 1–7 (design A6), so this is where solvability is proven.
3. The declared tier follows the §6.6 pattern and equals the simulated tier.
   An expert-only level (smart bot below half, spec §6.4) is a warning on
   L1–L30 and an error from L31 (brainstorm §3 E12).
4. Chapters of 20 levels (spec §7.1).
5. The spec §3.7 schedule: L1 has 1 color and L2 has 2; L3–9 have at most 4
   colors; `maxSize` is 3 before L10, 4 at L10 and at most 4 before L71, 5
   at L71 and at most 5 before L121, and 6 only on a superhard level ("occasional
   maxSize 6 super hard levels" from L121); tower slots first at L16, locked
   slots first at L31, ice first at L51 (each introducing level must use it).
6. The M2 board layout: 2–3 shelves, at most 4 slots per shelf, which also
   leaves the bottom shelf room for both extra slots (D22).
7. Variety (E12): no two consecutive levels share a layout signature: the
   slots per shelf, the tower count and depths, the glass cases, the iced
   slots, the color count and `maxSize` (`tools/lib/src/levels/layout_signature.dart`).
   Which colors, where things stand and how the sets are cut are left out,
   since changing only those is a reskin. The tutorials (L1, L2) are exempt
   between themselves; L3–L30 already differ pairwise.
8. Par (spec-prop §7.10: par "is computed when the level bundle is built,
   and checked with it"): each committed entry's `par` equals the solver's
   optimal moves from rule 8's solve (no second search). A missing or
   different one is `bundle.parMismatch` ("committed 14, the solver's 13");
   `bundle build` fixes it. A level the solver doesn't prove already fails
   rule 8.

## Workflow

```
# edit tools/levels/authored/L0007.json (and bump its version in the manifest)
dart run nesty_tools:nesty_levels report tools/levels/manifest.json   # tiers, moves
dart run nesty_tools:nesty_levels bundle build
dart run nesty_tools:nesty_levels bundle check
dart run nesty_tools:nesty_levels report --stars   # optional: star shares per chapter
```

`report` shows each level's simulated tier, casual and smart win rates,
optimal moves and nodes, so a board can be tuned until its tier matches the
pattern. `generate` can draft candidate boards (spec §6.5); a draft becomes an
authored level by copying it here under its `L` id and listing it in the
manifest.

## Tuning a board's tier

The simulated tier (spec §6.4) comes from the casual bot's wins. What moves
it, as measured while authoring L1–L30:

- **Open slots only: always easy.** On such a board every color's remaining
  pieces always hold a merge, since each size is left the same number of
  times. So any order of merges wins, and the casual bot wins 300 of 300.
  Towers arrive at L16 (spec §3.7), so L3–L15 can't reach the medium, hard
  and superhard tiers of the §6.6 pattern. They keep their §6.6 tier (its
  badge and coins) with a `tierOverride` reason, which `bundle check`
  accepts on open-slot-only boards (D26; the owner may still choose another
  grading, PROGRESS Q30).
- **With towers, the share of tower slots decides.** A move out of a tower
  into an empty slot spends that slot. Few open slots, 1 empty slot and sets
  cut into small pieces make the bot run out of moves. In this set (all with
  1 empty slot unless noted):
  - 1–2 towers on 9–12 slots never left easy, with 1 or 2 empty slots.
  - Medium: 2 towers on 6–8 slots, or 3 towers 3 deep on 8–10.
  - Hard: 2 towers 4 deep on 7 slots, or 3 towers 3 deep on 8.
  - Superhard: 2 towers 4 deep on 6 slots, or 3 towers 3 deep on 7.

  The smart bot still won every run on all 30 levels.
- The simulator's seed comes from the board itself, so any edit, even
  swapping two nests, can move the tier. Re-run `report` after every change.
- What was measured while making L31–L200 (M7), over about 41,700
  generated candidates:
  - Boards with glass or ice but no towers simulated easy every time (44 of
    44), which is how L31, L51 and L71 teach their mechanic alone.
  - Boards with 7–9 towers 4 deep were superhard 93% of the time, and a
    third of them were expert only (the smart bot under half), which is an
    error from L31. Across all candidates 3.7% were expert only.
  - A single swap of two nests moved the optimal solution by a move or two
    and the casual wins by tens (L140: casual 24 to 3 of 300). Which nest
    sits behind glass matters as much: sealing navy4-3 instead of orange1
    turned the L40 draft from superhard (casual 16) into hard (casual 61).
    The finales were tuned one report-checked swap at a time.

## Par and the star shares (M7, D125)

A win earns 3★ at moves ≤ par + ⌈par × `star3_slack_pct` ÷ 100⌉, 2★ at
≤ par + ⌈par × `star2_slack_pct` ÷ 100⌉ and 1★ otherwise, with the slack at
20 and 60 by default (spec-prop §7.10). `report --stars` tells what those
keys would mean: per chapter, the share of the casual and smart bots' won
runs at each star count (300 `RivalBot` runs per bot and level, unassisted).
It is a report for tuning the two keys, never a gate.

The pars written on 2026-09-29 (L1–L30's data and versions unchanged):

| Chapter | ch01 | ch02 | ch03 | ch04 | ch05 | ch06 | ch07 | ch08 | ch09 | ch10 |
|---|---|---|---|---|---|---|---|---|---|---|
| Par | 2–12 | 6–22 | 7–24 | 8–29 | 13–30 | 13–31 | 13–32 | 14–33 | 14–34 | 15–35 |

At 20 / 60 the smart bot's wins were 97–100% 3★ in every chapter and never
1★; the casual bot's were 65% 3★ in ch01 and 9–27% from ch02, with 25–42% at
1★ (all levels: 24.0% 3★, 47.9% 2★, 27.9% 1★).

## Levels 31–200 (M7)

Chapters 2–10 follow the chapter plan in `docs/plans/offline-game-brainstorm.md`
§4 (D92 E11): glass from L31, ice from L51, `maxSize` 5 from L71 and
`maxSize` 6 in the super hard slots L130, L140 … L200.

- **Drafts:** `nesty_levels generate` on the curve's stage row for the level's
  tier (`DifficultyCurve`, confirmed in Q34), varied as the plan allows (±1
  color, another uniform shape, towers ±1) plus the knobs a chapter twist
  names (glass and ice counts, towers 4 deep in chapters 5, 8 and 10, no
  empty slot in chapters 5 and 10, a second empty slot for chapter 6's
  relaxing easy levels). Seeds are `5_000_000 + order × 100 + k`, apart from
  the bonus (`1_000_000 + n`) and daily (`yyyymmdd`) seeds. Each level keeps
  its `generatorVersion` and `seed`, and its manifest notes give the exact
  `--params`, so `generate --params '<json>' --seed <seed>` reproduces the
  draft.
- **Picks:** per level, the draft that passes `bundle check`, differs from
  both neighbours' layouts, has a smart win rate of at least half, fits the
  chapter twist, solves from its start within 20,000 nodes (the device's
  soft-stuck budget, spec §6.3, so hints and the stuck check are exact from
  the first move), has at least as many solver moves as the level 10 before
  it in its chapter (the intro levels may dip), and fewer than its chapter's
  finale.
- **Near duplicates (H/S review, 2026-09-28):** no level reads like one
  within two of it. Two levels read alike when nothing structural tells them
  apart: the glass cases, iced slots, deepest tower, empty slots, tier,
  `maxSize`, a tower count two or more apart and, two levels apart, the
  shelf shape. The colour count, one tower more or less and the move count
  don't on their own. The review found four such pairs, and the same check
  over every level found 27 more. 21 levels were replaced to fix them, and
  their notes name the first pick. Four side-by-side easy pairs stay alike
  (L81/L82, L91/L92, L141/L142, L151/L152), told apart only by their shelf
  count (two against three). Chapters 5 and 8 fix glass, ice, depth and
  empty slots. Chapter 8's towers are its row's count or one more, and
  chapter 5's easy boards with two towers more take a medium's 17–18 moves.
  The review also replaced L170, the chest level, which never won by chance
  (casual 0/300), and re-tuned L160 (below).
- **Hand-tuned:** L31, L51 and L71 (each mechanic alone and easy), L130 (the
  first `maxSize` 6) and the finales L40, L60 … L200, each the longest level
  of its chapter (22, 24, 29, 30, 31, 32, 33, 34 and 35 moves). Their notes
  say what was changed, why, and the report's numbers before and after.
  L160 was re-tuned after the review in two more swaps at 33 moves, taking
  casual 0 to 7 of 300. L200 stays at casual 0 of 300: no single swap
  keeps it longer than L180 (34 moves) and lets the casual bot win.
- The golden doll (L101, spec §3.5) is v1.1, so L101 is an ordinary level.
