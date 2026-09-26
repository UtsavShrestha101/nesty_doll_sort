# tools/ — `nesty_tools`

Developer CLIs for Nesty. `tools/` is a pure-Dart workspace member
(`nesty_tools`, `resolution: workspace`), so every script runs from any
directory of the repo with `dart run nesty_tools:<script>`. Scripts find the
repo root themselves.

## Ground rules for every script here

- **No game rules here.** Scripts import `nesty_core` for parsing, validation,
  solving and generation (CLAUDE.md rule 2). If a script needs a rule that
  `nesty_core` does not expose, add it to core first.
- **Deterministic.** The same input gives byte-identical output, so generated
  files diff cleanly and CI can check them for drift. Anything that generates
  or orders levels takes an explicit seed and uses core's PRNG (CLAUDE.md
  rule 7, spec §6.5).
- **Fail loudly.** An input of an unexpected shape is an error with the path
  and the reason, never a guess.
- **Pure Dart** (`dart run`, no Flutter), so scripts run in CI. The one
  Flutter package imported here is `nesty_render`, and only its Flutter-free
  `svg_tools.dart` library (a test in `nesty_render` keeps it Flutter-free).
- **No secrets.** Firestore access (M5) goes through the owner's own
  credentials at run time, never a committed key.
- **Packages:** `nesty_core`, `nesty_render` (path), `path`, `xml`; dev:
  `lints`, `test`. Arguments are parsed by hand (`lib/src/cli_args.dart`).
  A new dependency needs its reason in `docs/PROGRESS.md` (CLAUDE.md rule 9).

## Scripts

Every script prints a short summary. `--check` writes nothing and exits 1 on
drift; CI runs the checks in the "Generated code is committed and fresh" job.

| Command | Reads | Writes |
|---|---|---|
| `dart run nesty_tools:gen_design_tokens [--check]` | `design/tokens.json` | `packages/nesty_render/lib/src/tokens/render_tokens.gen.dart`, `apps/game/lib/core/ui/tokens/ui_tokens.gen.dart` |
| `dart run nesty_tools:sync_design_assets [--check]` | `design/{skins,symbols,board,themes,audio}` | `apps/game/assets/{skins,symbols,board,themes,audio}/` |
| `dart run nesty_tools:gen_nesty_icons [--check]` | `tools/fonts/nesty_symbols.txt`, `apps/game/assets/fonts/NestySymbolsRounded.codepoints` | `apps/game/lib/core/ui/icons/nesty_icons.gen.dart` |
| `dart run nesty_tools:todo_index [--check]` | every first-party source file | `docs/TODO_INDEX.md` |
| `dart run nesty_tools:nesty_levels bundle build` / `bundle check` | `tools/levels/manifest.json`, `tools/levels/authored/*.json` | `apps/game/assets/levels/bundle.json` (`bundle check` writes nothing) |
| `tools/fonts/build_fonts.sh [--verify]` | pinned upstream fonts (network) | `apps/game/assets/fonts/`, `tools/fonts/SHA256SUMS`, then runs `gen_nesty_icons` |

All outputs are generated: never edit them by hand
(`.claude/hooks/block-generated.sh` blocks it). Change the source or the
generator and re-run.

### `gen_design_tokens`

Turns `design/tokens.json` into `static const` Dart:

- **nesty_render** (`render_tokens.gen.dart`, exported from
  `package:nesty_render/nesty_render.dart`): `DollColorTokens` (base, ink,
  light, symbol per `DollColor` id; gold's gradient-map ramp and `gray^2`
  input), `DollColorDerivationTokens`, `SkinTokens`, `BoardTokens` (reference
  screen, board layout, pips, doll heights, HUD and booster-bar geometry),
  `MotionTokens` (every `motion.*`: durations in ms, easings as `Cubic`,
  reduced motion).
- **apps/game** (`ui_tokens.gen.dart`): `AppColorTokens`, `AppGradientTokens`
  (CSS angles → `Alignment`; the wood bar's `14px` stop stays a
  `PxLinearGradient` to `resolve(extent)`), `AppFontTokens`,
  `AppTextStyleTokens` (17 styles), `AppRadii` (`2xl` → `xxl`), `AppSpacing`,
  `AppShadowTokens` (CSS box-shadow lists as `NestyShadow`, which keeps
  `inset`), `HudTokens`, `BoosterBarTokens`, `BottomNavTokens`,
  `UiMotionTokens`, `SoundTokens`.

The value types are hand-written next to the output
(`render_token_types.dart`, `ui_token_types.dart`). Every tokens.json leaf
must be emitted or explicitly documented (prose such as `motion.swallow`;
`haptics.*` is hand-written in the haptics service): an unmapped leaf, an
unknown value shape, doll colors that differ from `nesty_core`'s `DollColor`,
or a text style weight that isn't bundled all stop the codegen. The test
`test/tokens/design_tokens_codegen_test.dart` checks that parity.

### `sync_design_assets`

Copies the runtime art and sound from the owner-managed `design/` into the
game: `skins/<id>/skin.svg` + `skin.json` (all 7), `symbols/*.svg` (11),
`board/*.svg` (15: not `slot-stand.svg` / `tower-base.svg`, whose pips are
baked in), `themes/chNN/background.svg` (6), `audio/*.wav` (17 placeholders).
SVGs lose their C2PA `<metadata>` block (about 7.7 KB each) and must pass the
spec §12.2 rules in `package:nesty_render/svg_tools.dart` (no filters, masks,
text, images, `style`, nested `<svg>` or blend modes; skins need the eight
groups in paint order and a valid `skin.json`). Nothing is written if any
file fails. Files the design no longer has are removed, and `--check` also
fails when `apps/game/pubspec.yaml` doesn't list a synced folder.

Not synced on purpose: `design/skins/classic/renders/` (golden references for
the renderer tests), `museum/` and `store/` (nested `<svg>` and
`mix-blend-mode`, which flutter_svg can't draw; museum PNGs come in M3 and
store icons in M8), `generator/` and `prototypes/`.

### Fonts and icons (`tools/fonts/`)

`build_fonts.sh` downloads Fredoka, Nunito (SIL OFL 1.1) and Material Symbols
Rounded (Apache 2.0) at pinned commits, checks their SHA-256, cuts static
instances with fontTools (Fredoka 500/600/700, Nunito 500–800), subsets the
icon font to `nesty_symbols.txt` (the 48 glyphs of design/README.md
"Typography & icons") at FILL 1 / wght 600 / GRAD 0 / opsz 24 (first
`bake_feature_variations.py` points the cmap at the `<name>.fill` glyphs the
font swaps in at FILL 1 through GSUB, which the subset drops), installs
everything plus the licence texts into `apps/game/assets/fonts/`, records
`SHA256SUMS` and regenerates `NestyIcons`. `SOURCE_DATE_EPOCH` makes the
bytes reproducible; `--verify` rebuilds in a temp dir and compares. The
licences are registered with `LicenseRegistry` in `apps/game/lib/bootstrap.dart`.

To add an icon: add its upstream name to `nesty_symbols.txt`, run
`tools/fonts/build_fonts.sh`, then use `NestyIcons.<camelCaseName>`.

### `todo_index`

Collects every `TODO(<tag>)` / `FIXME(<tag>)` comment marker (Dart, YAML,
Gradle/KTS, Kotlin, Swift, plist, Firebase rules, shell, Markdown prose) into
`docs/TODO_INDEX.md`, grouped by tag, so work deferred to a later milestone
is never lost. Tags: `M1`…`M8`, `v1.1`, `design`, `later`, and combinations
such as `M3/M4` (listed under each milestone). `--check` fails when the index
is stale, when a tag is unknown, or when a code comment has a marker with no
tag. Markers inside `backticks` or fenced code are references and are
skipped; `design/`, `.claude/`, build output and generated files are not
scanned.

### `nesty_levels`

The level tools (design §4). Every rule, the solver, the simulator and the
generator come from `nesty_core`; the CLI only reads files, calls core and
prints. Run `dart run nesty_tools:nesty_levels --help` for the full usage.

| Command | Does |
|---|---|
| `validate [paths] [--loader] [--budget N]` | Validation rules 1–8 (spec §5.3); `--loader` checks rules 1–7 like the game's loader (design A6). |
| `solve [paths] [--budget N]` | Verdict, optimal moves, nodes, branching and the move list (spec §6.3). Fails unless every level is solved. |
| `simulate [paths] [--runs N] [--seed S] [--move-cap N]` | Casual and smart bot wins, the suggested tier and "expert only" (spec §6.4). |
| `report [paths] [--budget N] [--json]` | One row per level: order, id, chapter, declared and simulated tier, casual %, smart %, solver moves, nodes, status. `--json` prints the same as a JSON array. |
| `bundle build` | `tools/levels/manifest.json` + `authored/` → `apps/game/assets/levels/bundle.json` (2-space indent, fixed key order, sorted by order, `rewardCoins` from the tier). Refuses a changed board whose `version` wasn't raised (spec §13.3). |
| `bundle check` | CI: the bundle is fresh, and every level passes rules 1–8, has the declared tier the simulator gives (design A32; a `tierOverride` reason may keep the declared tier on the tutorials and on open-slot-only boards, which always simulate easy, D26), and follows the §6.6 pattern, the §3.7 schedule, 20-level chapters and the M2 layout (2–3 shelves, ≤ 4 slots per shelf). |
| `generate --params <json\|file> --seed S [--count N]`, `--bonus N [--count C]`, `--daily YYYYMMDD` `[--verify] [--out DIR]` | Runs the generator (spec §6.5) on explicit params and seeds, the Bonus Endless curve (§7.1) or a date's daily puzzle (§7.5). `--verify` re-validates each level with rules 1–8 on a fresh solve (the M1 acceptance check). |
| `fixtures check` | nesty_core's solver fixtures (`packages/nesty_core/test/fixtures/`) are canonical, pass rules 1–7 and give the verdicts and optimal move counts in `test/solver/fixture_expectations.dart`. |

A path is a level file (spec §5.1), a bundle, the manifest or a folder of
level files, relative to the current directory; with no path, commands read
the game's bundle. The kind is told from the file's `format`, never from its
name. Exit codes: 0 ok, 1 a check failed, 64 bad usage. Findings go to
stderr as `severity subject path: code: message`, with core's `IssueCodes` or
the tools' own `FindingCodes` (`lib/src/levels/finding.dart`).

`generate --params` takes the spec §6.5 params by their `GeneratorParams`
names, with `targetTier` as a tier id, for example
`{"colors":3,"maxSize":3,"shelves":2,"slotsPerShelf":3,"emptySlots":1,"targetTier":"medium"}`.
`setsPerColor`, `towers`, `towerDepth`, `locked` and `iceSlots` are optional.

The manifest's schema and the authoring workflow are in
[`levels/README.md`](levels/README.md).

## Planned scripts

| Script | Milestone | Purpose |
|---|---|---|
| `export_level_bundle` | M5 | Headless version of the admin's "Export bundle" (spec §15 screen 9): read the first N `levels` where `status == published` ordered by `order` (the query and composite index from spec §13.4 / `firebase/firestore.indexes.json`), validate each one, and write `apps/game/assets/levels/bundle.json` through `LevelBundleCodec`, then run `nesty_levels bundle check`'s checks on it. The admin button stays the primary path; the script exists so a bundle can be rebuilt reproducibly in CI or on a release branch. |
