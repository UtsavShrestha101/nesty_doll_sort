# tools/levels/ — the authored levels

The source of the game's bundled levels (spec §13.4, design §4). `nesty_levels
bundle build` turns this folder into `apps/game/assets/levels/bundle.json`,
and CI's `nesty_levels bundle check` proves the result. Never edit the bundle
by hand; edit this folder and rebuild.

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
   An expert-only level (smart bot below half, spec §6.4) is a warning.
4. Chapters of 20 levels (spec §7.1).
5. The spec §3.7 schedule: L1 has 1 color and L2 has 2; L3–9 have at most 4
   colors; `maxSize` is 3 before L10, 4 at L10 and at most 4 before L71, 5
   at L71 and at most 5 before L121; tower slots first at L16, locked slots
   first at L31, ice first at L51 (each introducing level must use it).
6. The M2 board layout: 2–3 shelves, at most 4 slots per shelf, which also
   leaves the bottom shelf room for both extra slots (D22).

## Workflow

```
# edit tools/levels/authored/L0007.json (and bump its version in the manifest)
dart run nesty_tools:nesty_levels report tools/levels/manifest.json   # tiers, moves
dart run nesty_tools:nesty_levels bundle build
dart run nesty_tools:nesty_levels bundle check
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
