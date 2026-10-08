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
| `dart run nesty_tools:sync_design_assets [--check]` | `design/{skins,symbols,board,themes,audio,lottie,museum/png,ui}` | `apps/game/assets/{skins,symbols,board,themes,audio,lottie,museum,ui}/`, the Android notification icon `apps/game/android/app/src/main/res/drawable/ic_notification.xml`, and the home-screen widget's native art (`apps/game/ios/NestyWidget/Assets.xcassets/`, Android `res/drawable{,-night,-nodpi}/nesty_widget_*`) |
| `dart run nesty_tools:gen_fx_spec [--check]` | `design/lottie/*.json`, the contract table `lib/src/fx/lottie_contract.dart` | `apps/game/lib/features/fx/fx_spec.gen.dart` |
| `dart run nesty_tools:gen_nesty_icons [--check]` | `tools/fonts/nesty_symbols.txt`, `apps/game/assets/fonts/NestySymbolsRounded.codepoints` | `apps/game/lib/core/ui/icons/nesty_icons.gen.dart` |
| `dart run nesty_tools:gen_widget_strings [--check]` | `apps/game/lib/l10n/app_*.arb` (`widgetGalleryName`, `widgetGalleryDescription`, `widgetLockedTitle`; pt_BR falls back to pt per key) | the widget's native strings: `apps/game/ios/NestyWidget/<lang>.lproj/Localizable.strings` (`pt-BR.lproj`) and `apps/game/android/app/src/main/res/values{,-<lang>}/widget_strings.xml` (`values-id`, `values-pt-rBR`) |
| `dart run nesty_tools:todo_index [--check]` | every first-party source file | `docs/TODO_INDEX.md` |
| `dart run nesty_tools:nesty_levels bundle build` / `bundle check` | `tools/levels/manifest.json`, `tools/levels/authored/*.json` | `apps/game/assets/levels/bundle.json` (`bundle check` writes nothing) |
| `dart run nesty_tools:gen_font_subsets [--check]` | `apps/game/lib/l10n/app_{hi,ja}.arb` (when they exist), intl's dates, the Flutter SDK's `material_{hi,ja}.arb` (found through `$FLUTTER_ROOT` or `flutter` on PATH), the language sheet's autonyms, the bundled Fredoka and Nunito cmaps, `design/tokens.json` `font.scripts` | `tools/fonts/subset/{hi,ja}.txt` |
| `tools/fonts/build_fonts.sh [--verify]` | pinned upstream fonts (network), `tools/fonts/nesty_symbols.txt`, `tools/fonts/subset/*.txt`, `design/tokens.json` `font.scripts` | `apps/game/assets/fonts/`, `tools/fonts/SHA256SUMS`, then runs `gen_nesty_icons` |

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
  `MotionTokens` (every board `motion.*`: durations in ms, easings as
  `Cubic`, reduced motion). Tokens v3 (m7-3) adds `plankTopsThreeShelvesTall`
  (the shelf keys parse as `Nshelves` or `3shelvesTall`), the tall ice,
  `GlassCaseTallTokens`, `BoardFitTokens`, `BoardPresetTokens` (the NestyBoard
  presets with the design's own fit results, `rowOfFive`), `TowerStackTokens`,
  `IcedTowerTokens`, `HintArcTokens`, `FallbackDollTokens` and
  `ChapterThemeTokens` (ten chapters: id, `ChapterPalette`, the Shop crop),
  plus the tag pop, row-of-5, tap-feedback, drag-hover and extra-slot
  timings in `MotionTokens`. Tokens v4 (m7-4) adds each palette's
  `ribbonTail`/`ribbonFold` and chapters 7–10's `boardArtDir` (their own
  wood, `board/chNN/`), the overlay caps (`tallGlassPitchInset`,
  `iceMaxOverlap`) and `HintArcTokens.arrowhead`; the fallback doll's sizes
  read as diameters, and `boardPresets.oneShelf` is documentation (no
  bundled level has one shelf).
- **apps/game** (`ui_tokens.gen.dart`): `AppColorTokens`, `AppGradientTokens`
  (CSS angles → `Alignment`; the wood bar's `14px` stop stays a
  `PxLinearGradient` to `resolve(extent)`), `AppFontTokens`,
  `AppTextStyleTokens` (17 styles), `AppRadii` (`2xl` → `xxl`), `AppSpacing`,
  `AppShadowTokens` (CSS box-shadow lists as `NestyShadow`, which keeps
  `inset`), `HudTokens`, `BoosterBarTokens`, `BottomNavTokens`,
  `UiMotionTokens`, `SoundTokens`. Tokens v3 adds the family counter's hug
  (E.18), one class per screen section from a generic emitter
  (`lib/src/tokens/screen_tokens_codegen.dart`: `RivalStripTokens`,
  `RaceBarTokens`, `Short169Tokens`, `WinStarsTokens`, `WinStarsShortTokens`,
  `ChestCardTokens`, `HomeTokens`, `HomeShortTokens`, `ChaptersTokens`,
  `MuseumTokens`, `RecordsTokens`, `RivalSelectTokens`, `ReplayCardTokens`,
  `HintMiddleTokens`, `WinTwinklesTokens`, `GeneratingTokens`, `ShopTokens`,
  `ChestModalTokens`, `SettingsTokens`, `TextLinkTokens`), the M7 UI motion
  (`StarMotionTokens`, `ChestMotionTokens`, `RivalMotionTokens`,
  `ToastTokens`, `ChaptersMotionTokens`, `PurchaseMotionTokens`) and
  `IconTokens` (each use's glyph, all in the bundled font). Tokens v4 (m7-4)
  adds every colour the frames draw (`AppColorTokens.sunkFace`, the toast
  kinds, the day dots…; a `$`-key is a note), `gradient.canvas` and
  `coinChip` (with its `coinChipEdge`), the sections `TutorialTokens`,
  `SizeBlendTokens`, `SettingsRowsTokens`, `NoCoinsTokens`,
  `MuseumDetailTokens`, `LanguageSheetTokens`, `ToastLayoutTokens`,
  `TextFitTokens`, `ScreenHeaderTokens`, the motion sections
  `ChestCollectTokens`, `RivalReactTokens`, `MuseumIdleTokens`,
  `FirstLaunchTokens`, `SpinnerMotionTokens`, `PurchaseItemTokens`,
  `RelitHomeTokens`, `RelitTwinkleTokens`, and `WinRibbonTokens` (the
  ribbons' `RibbonColors`, `winRibbon.default` and `versus.ribbon`, and the
  fills' key paths). `font.scripts` (hi, ja; tokens v4) becomes
  `AppFontTokens`' script families, their weight maps, size factors, line
  heights and letter spacing, and the `displayFallback` / `bodyFallback`
  lists that every generated `TextStyle` sets as `fontFamilyFallback`.
  Tokens v5 (m7-5) adds the daily gift's sections (`GiftButtonTokens`,
  `GiftSheetTokens`, `GiftTileTokens`, `GiftTallyTokens`, `GiftClaimTokens`,
  `GiftReducedMotionTokens`, `GiftShortTokens`; `gift.chest` is copy ids and
  behaviour, documented with checks; `gift.button.hiddenUntil` is a rule),
  `ChestSlotChipTokens` (the +1 slot chip is look, so it leaves the `chest`
  rules), `SplashTokens` (the top fade, a `PxLinearGradient`), one
  `<Surface>TypeTokens` class per `type.<surface>` (a `TextStyle` per entry,
  `…Caps` for capitals, `…ShortSize` for 16:9; the gift's sizes are checked
  against `gift.sheet` and `gift.short`), `WinRibbonTokens`' size, reach,
  text box, rect key paths (checked against both ribbons' `sizedRects`) and
  `maxWidthInset`, `MotionTokens.pickWobbleToMove*`, and
  `font.scripts.latnTr`: a whole-string face (`lib/src/tokens/
  script_fonts.dart`: a `latn…` key) that replaces Fredoka in its locales,
  emitted as `AppFontTokens.latnTrFamily` (`Baloo2LatnTr`), `latnTrLocales`,
  `latnTrDisplayWeights` (every bundled Fredoka weight must be mapped),
  `latnTrSizeFactor` and `latnTrTitleLineHeight`, and kept out of the
  fallback lists.
  Tokens v6 (m7-6) adds the local habits' sections (`HabitsWelcomeTokens`,
  `HabitsMonthTokens` with `HabitsMonthShortTokens` and `HabitsDayCellTokens`,
  `HabitsPastDayTokens`, `HabitsWidgetTokens` and `HabitsWidgetColorTokens`
  for the native widget; `habits.respect`, the welcome card's `when`, the
  month's `window` and a past day's `rules` are rules, documented),
  `ComputerTagTokens` (the tag leaves the `versus` rules), `RibbonTitleTokens`
  (`gift.chest.ribbon`), `fontSize.*.use` (a doc), an elliptical
  `gradient.<name>.shape` (`ellipse rx% ry% at x% y%`: a `RadialGradient`
  with an `EllipseGradientTransform`, apps/game's `ui_token_types.dart`),
  the family counter's maxima, the splash's fallback-doll fade and body
  radius, and `MotionTokens.invalidEmptyTargetStop`. `TokenReader` reaches a
  key with a dot (`habits.widget.art.files.flame_lit.svg`).

The generic emitter turns each leaf into the Dart type its shape says: a
number is a `double` (an `int` for counts and `…Ms`), `padding` an
`EdgeInsets` in CSS order, two numbers under a size key a `Size`, `origin` and
`offset` an `Offset`, `rect` (4 numbers) a `Rect`, `points` a `List<Offset>`,
a colour a `Color`, a list of colours a `List<Color>`, `short` the copy.md ids
of a surface's short forms, `gradient.<name>` a checked `AppGradientTokens`
reference, `Fredoka|Nunito <weight> <size>[/<line height>] …` a `TextStyle`
(an unbundled weight fails; a line height below 4 is a multiple, above it
px), `<n>px <color>` a `TokenStroke`,
`linear-gradient(…)` a `LinearGradient`, a box-shadow a `List<NestyShadow>`,
a glyph key the glyph's name (checked against `icons`). Tokens v5 adds
`color.<name>` (a checked `AppColorTokens` reference), `radial-gradient(circle
at x% y%, …)` (a `RadialGradient`), an art path `ui/<folder>/<file>.svg`
(documented: `UiArt` draws it; `… at <n>` emits `<member>Size`), and a
copy.md id under `label`, `a11y` or `body` (documented: the ARB key). Tokens
v6 adds a day number `#RRGGBB <weight>` under `number` (`…Color` and
`…Weight`), a face of `none`, a mark's `means` and a copy id under `copy`
(documented). A `note` or `use` leaf is a design note. Any other string is prose: a strict parser reads its
numbers, or a list in the emitter names it with its reason; an unknown string
fails the build.

Rules the design repeats (`versus.*`, `chest.*`,
`layout.extraSlot.limitPerLevel`, `settings.reduceMotion.default`) are
documentation only: rules never come from tokens, and the game's
`test/core/ui/tokens/rule_tokens_test.dart` pins each to its source
(`RemoteConfigKeys`, `MilestoneChest`, `LayoutLimits`, `SettingsDefaults`).
`layout.extraSlot.placement` contradicts spec §3.6 and is documented (D172).
Formulas the hand-written code follows (the board fit's limits, the tower
stack rule, the iced tower's tag) are pinned word for word
(`TokenReader.documentedExact`), so a reworded formula fails until the code is
re-read.

`SoundTokens` (tokens.json `sound`, `design/audio/AUDIO.md`) has a
`SoundCue` per event, including the three jingles (`chapterComplete`,
`reward`, `outOfMoves`); `allFiles` (the SFX, WAV only), `jingleFiles` and
`musicFiles` (OGG); the clack table and `clackBakedSemitones`; per loop
`musicHome`/`musicGame` (the file) plus `…Seconds`, `…Frames` (checked
against the seconds at 44.1 kHz), `…Bpm`, `…Meter` and `…Key`; the
`musicFade…Ms` timings; the `musicDuck…` factors and `musicDuckFactors` by
reason; the mix defaults and `jingleBus` (`sfx` or `music`). A jingle
(`jingle_*`) may only be a single-file event, and `none` (optionally with a
note, `none (no sound, no haptic)`: tokens v4's `reminderSet`) is an empty
cue that plays nothing. `sound.format` and
`sound.music.*.screens` are prose (documented). Two prose leaves are parsed
strictly: `motion.reveal.type` gives `MotionTokens.revealWipeCenter` (the
wipe grows from the doll's centre, art (256, 476), owner decision 3d) and
`layout.towerSilhouettes` gives `BoardTokens.towerDepthRaise` and
`towerSilhouetteSprite` (every skin's buried nests draw the wood-grain blank
`board/doll-silhouette.svg`, owner decision 3e).

The value types are hand-written next to the output
(`render_token_types.dart`, `ui_token_types.dart`). Every tokens.json leaf
must be emitted or explicitly documented (prose such as `motion.swallow`;
`haptics.*` is hand-written in the haptics service): an unmapped leaf, an
unknown value shape, doll colors that differ from `nesty_core`'s `DollColor`,
or a text style weight that isn't bundled all stop the codegen. The test
`test/tokens/design_tokens_codegen_test.dart` checks that parity.

### `sync_design_assets`

Copies the runtime art and sound from the owner-managed `design/` into the
game:

| Folder | Files |
|---|---|
| `skins/<id>/skin.svg` + `skin.json` | 7 skins |
| `symbols/*.svg` | 11 |
| `board/*.svg` | 18 (not `slot-stand.svg` / `tower-base.svg`, whose pips are baked in) |
| `board/chNN/*.svg` | 12: chapters 7–10's own plank, blank stand and blank tower (m7-4 A.5), from `design/board/chNN/`; the folder and its files are exactly what tokens.json `theme.chapters.N.boardArt` lists |
| `themes/chNN/background.svg` | 10 |
| `audio/` | 31: 24 SFX `*.wav` (m7-5 adds `gift_claim`) + 7 `*.ogg` (2 music loops, 5 jingles) |
| `lottie/*.json` | 37 (see "Lottie" below) |
| `museum/NN-<id>[-locked].png` | 20 figurine PNGs (see below) |
| `ui/<badges,chest,gift,rivals,sprites,stars>/*.svg` | 38: the M7 UI art (24 badges, 2 chests and m7-5's slot chip, m7-5's gift glyph, 4 rival portraits, 3 flight sprites with m7-5's `slot_flight`, 3 stars) |

SVGs lose their C2PA `<metadata>` block (about 7.7 KB each) and must pass the
spec §12.2 rules in `package:nesty_render/svg_tools.dart` (no filters, masks,
text, images, `style`, nested `<svg>` or blend modes; skins need the eight
groups in paint order and a valid `skin.json`).

Audio ships byte for byte (`lib/src/assets/audio_formats.dart`, tokens.json
`sound.format`): a WAV must be 44.1 kHz mono 16-bit PCM with its chunks
inside the file (other chunks, such as the C2PA one, are fine); an OGG must be
one logical Ogg Vorbis stream, 44.1 kHz stereo, every page with the `OggS`
capture pattern and a valid CRC, begun on the first page and ended on the
last. Against tokens.json `sound`: every event file ships (SFX as `.wav`,
`jingle_*` as `.ogg`), every `sound.music.*.file` ships as `.ogg` and ends at
exactly its `frames`, and no other audio ships. `design/audio/AUDIO.md` is
never copied.

Nothing is written if any file fails. Files the design no longer has are
removed, and `--check` also fails when `apps/game/pubspec.yaml` doesn't list
a synced folder.

The 37 Lottie exports ship byte for byte too, `design/lottie/*.json` →
`lottie/<name>.json`; see "Lottie" below.

The UI art (`design/ui/<folder>/<name>.svg`, names `[a-z0-9_]+`) is
sanitized and validated like the board art. A file in `design/ui/icons/` is
an issue (every icon use is a glyph of the bundled font), and so is any
other folder. `design/ui/notification/ic_notification.svg` is not an asset:
`lib/src/assets/android_vector.dart` converts it into the Android vector
drawable the daily reminder names as its small icon
(`apps/game/android/app/src/main/res/drawable/ic_notification.xml`, the main
source set, every flavor; `res/raw/keep.xml` keeps it through R8). Only
white-filled `<path>`s on a `0 0 W H` viewBox convert (even-odd kept); a
group, transform, stroke, other colour or shape is an issue. `--check`
compares its bytes like any asset.

`design/ui/widget/` (m7-6) is not an asset either: it is the native
home-screen widget's art. `lib/src/assets/widget_native_art.dart` turns it
into the iOS asset catalog (`WidgetFlameLit`, `WidgetFlameUnlit`,
`WidgetFlameUnlitDark`, `WidgetDoll` as a template, `WidgetDailyMark`; each PNG
with its C2PA `caBX` chunk stripped) and the Android vector drawables (the dark
unlit flame under `drawable-night` with the same name) plus the 2 × 2 preview
PNG; the 4 × 2 preview is validated, not shipped (local habits stage 4,
PROGRESS D312). `lib/src/assets/widget_art.dart` keeps it to what tokens
`habits.widget.art` promises: each SVG flat (solid `#RRGGBB` fills on paths,
rects, circles and ellipses; no gradient, filter, mask, clip, image, text,
stroke, opacity or transform), its viewBox at the dp size's aspect, the doll
one colour (#000000), `name.png`/`-2x`/`-3x` at the dp size × 1/2/3, the two
previews at their pixel sizes, and nothing else. Nothing goes to
`apps/game/assets/`: the widget's art is never a Flutter asset.

The 20 museum figurine PNGs (`design/museum/png/NN-<id>.png` and its
`-locked` silhouette, one pair per bundled chapter figurine, m3-design §9.5)
ship byte for byte too, after checking the PNG signature and that each is
600×600 (`lib/src/assets/png_formats.dart`) and that the file set is exactly
the ten ids `BundledCatalogRepository.figurineIds` lists (the sync keeps its
own copy, since `tools/` does not depend on `apps/game`). An unexpected file
or a missing figurine blocks the whole sync, like every other family here.

Not synced on purpose: `design/skins/classic/renders/` (golden references for
the renderer tests), `design/museum/*.svg` and `store/` (nested `<svg>` and
`mix-blend-mode`, which flutter_svg can't draw; store icons come in M8),
`generator/` and `prototypes/`, `design/audio/AUDIO.md`, and
`design/lottie/`'s `LOTTIE.md` and `images/` (the placeholder PNGs are
never shipped or decoded, PROGRESS D50; a PNG found in `assets/lottie/` is
removed like any stale file). Each placeholder is still named after its image
slot (`<slot id>.png`): any other file in `images/` is an issue.

### Lottie (`lib/src/fx/`, `gen_fx_spec`)

Every animation ships as Lottie (PROGRESS D40–D52,
[docs/plans/m2-lottie-design.md](../docs/plans/m2-lottie-design.md)).

- **The contract** (`lottie_contract.dart`) is LOTTIE.md v3's "Files" table
  as Dart, in `FxId` order: canvas, length, markers (in the JSON's order;
  `fx_ice` has `rest_0` … `rest_3` at dr 0 and `crack_hit_0` … `crack_hit_3`;
  `ui_extra_slot` rests on `rest` at frame 0 since m7-3), loop, and the
  anchor, kind, travel S/T and `drop` start the JSON can't carry. m7-3 adds
  `fx_glass_unlock_tall` (its `case_size` null is a `scaleNulls` entry the
  game drives with `doll_size`), `ui_stars`, `ui_chest` and the three
  `ui_intro_*` loops, whose `<role>_size` nulls (`mover`, `revealed`,
  `family`, `family_2`, `freed`) are the file's own animation
  (`sizesAuthored`: validated as present, never driven, so their `FxSpec`
  lists no roles). m7-4 adds `ui_rival_react` (segments `idle`, `family`,
  `win`, `lose`; the `rival_portrait` slot, 96 dp at 3×) and
  `ui_museum_idle` (a loop; the `figurine` slot, 62 dp at 3×), and the
  named shapes of "Tint and width": the ribbons' `tintFills` (`band_fill`,
  `edge_fill`, `hi_fill`, `tail_fill`, `fold_fill`) and the family
  counter's `pill_fill`/`glow_fill` and `sizedRects` (`pill_rect`,
  `glow_rect`; its `icon` null is required). m7-5 gives both ribbons
  `sizedRects` too (`band_rect`, `edge_rect`, `hi_rect`), so the game can
  set a band's width. m7-6 gives `ui_chest` a `matteFills` entry
  (`falloff_fill`, a radial gradient fill on the `rays_matte` alpha matte):
  a gradient `<part>_fill` is allowed only when the contract lists it and it
  sits on an alpha matte layer (`td: 1` over a layer with `tt` 1 or 2); it
  is never tinted, and every other `_fill` must still be a plain fill. It also lists the image slots (`FxImageSlot` ids and declared sizes:
  dolls 512×768, board pieces at 3× their dp size) and, per file, the hooks
  the runtime keys on: the `<role>_size` nulls, `travel`, `target_pos`,
  `drop`, the `rim_tint` and `tint` fills, the text layers, the nulls of
  §6–§13 (`target`, `ice`, `doll`, `padlock_ping`, `doll_silhouette`,
  `color_doll`, `counter`, `ribbon`) and the parent nulls that carry every
  lift, bob, pulse and burst (`target_lid_lift`, `mover_lid_lift`,
  `arrow_bob`, `glow_pulse`, `slot_pulse`, `shatter_burst`).
  `test/fx/lottie_contract_test.dart` parses LOTTIE.md (the Files and Image
  slots tables, the Format list of parent nulls) and the game's
  `FxId`/`FxImageSlot` sources, so the table can't drift from either.
- **Validation** (`lottie_validation.dart`, run by both scripts; nothing is
  written on an issue): it parses; `v` 5.7.x, `fr` 60, `ip` 0; `w`/`h`/`op`
  and the markers equal the contract; the image asset ids are exactly the
  contract's, each an image slot at its declared size, none embedded, every
  `refId` resolves; the hooks are present, unique, and nowhere else; no image
  layer animates its anchor, position, scale or rotation (the compensation of
  §3 needs a static transform; opacity may animate); `travel` is an
  unparented null at S with a static zero anchor, on the S→T line, with no
  spatial tangents (the remap is a projection); `drop` likewise runs from its
  start to (0, 0); every fill named `*_fill` and rectangle named `*_rect` is
  exactly the contract's and of that shape type; neither remapped null ever
  holds (two equal consecutive keys or `h: 1`:
  lottie skips the position callback there). Features are **blocked,
  not allow-listed**, so trim paths and polystars stay fine: expressions,
  effects (`ef`), layer styles (`sy`), merge paths (`mm`), luma mattes
  (`tt` 3/4), matte parents (`tp`), 3D (`ddd`), time remap (`tm`), layer
  types above 5, shape types lottie 3.6.1 drops, and text outside
  `ui_family_counter`, `ui_win_ribbon` and `ui_chapter_ribbon`.
- **`gen_fx_spec`** writes `const Map<FxId, FxSpec> fxSpecs` and
  `fxSpecOf(id)`: frames, canvas, anchor, kind, markers, travel S/T, size
  roles, image layers with their key paths (precomp children as
  `[precomp, child]`) and their static authored scale and anchor, text
  layers, colour fills, the named fills and rectangles (`tintFills`,
  `sizedRects`), scale nulls, loop. Validation rules out holds and animated image
  scales, so it never emits `FxHold`s or `scaleAnimated`. The board timeline
  reads it and stays pure Dart. `test/fx/fx_spec_codegen_test.dart` checks
  the committed file; the game's `fx_spec_drift_test.dart` re-reads the
  shipped JSON independently.

The contract follows Claude Design's v3 export (2026-09-26,
[docs/plans/claude-design-v3-changes.md](../docs/plans/claude-design-v3-changes.md))
and its m7-3 and m7-4 deliveries (LOTTIE.md "Changes").
When another export arrives: it goes into `design/lottie/`, then run
`sync_design_assets` and `gen_fx_spec`. A changed length, marker, canvas,
image size or hook fails validation until the contract table (and LOTTIE.md,
which the contract test reads) agree.

### Fonts and icons (`tools/fonts/`)

`build_fonts.sh` downloads Fredoka, Nunito (SIL OFL 1.1) and Material Symbols
Rounded (Apache 2.0) at pinned commits, checks their SHA-256, cuts static
instances with fontTools (Fredoka 500/600/700, Nunito 500–800), subsets the
icon font to `nesty_symbols.txt` (the 48 glyphs of design/README.md
"Typography & icons", the 18 its "m7 adds" names and the splash errors'
`sd_card_alert` and `inventory_2`: 68) at FILL 1 / wght 600 / GRAD 0 / opsz 24 (first
`bake_feature_variations.py` points the cmap at the `<name>.fill` glyphs the
font swaps in at FILL 1 through GSUB, which the subset drops), installs
everything plus the licence texts into `apps/game/assets/fonts/`, records
`SHA256SUMS` and regenerates `NestyIcons`. `SOURCE_DATE_EPOCH` makes the
bytes reproducible; `--verify` rebuilds in a temp dir and compares. The
licences are registered with `LicenseRegistry` in `apps/game/lib/bootstrap.dart`.

To add an icon: add its upstream name to `nesty_symbols.txt`, run
`tools/fonts/build_fonts.sh`, then use `NestyIcons.<camelCaseName>`.

**The script faces** (hi and ja, docs l10n.md §4). The same run downloads
Baloo 2 (Devanagari) and M PLUS Rounded 1c (Japanese) from google/fonts at
the same pin, cuts Baloo 2 at 500/600/700 and takes M PLUS's static
Medium/Bold/ExtraBold (the weights `tokens.json` `font.scripts` names), and
subsets them to `tools/fonts/subset/hi.txt` (the whole Devanagari block,
ZWNJ/ZWJ, the dotted circle) and `ja.txt` (kana, CJK punctuation and
full-width forms whole, plus the kanji the sources use), keeping every
layout feature. `script_faces.py` then writes one family per Latin role,
`Baloo2Display`/`Baloo2Body` and `MPLUSRounded1cDisplay`/`MPLUSRounded1cBody`,
whose files carry the Fredoka or Nunito weight they answer as their OS/2
weight class (the engine matches a style's `fontWeight` against it and never
reads pubspec's `weight:`): `Baloo2Body-SemiBold.ttf` is Baloo 2 SemiBold at
weight class 700, because `font.scripts.deva.weights.body700` is 600. The
families are never a style's `fontFamily`; every style lists them in
`fontFamilyFallback`, and they map no Latin letters or digits, so they draw
only their script. M PLUS Rounded 1c's folder has no OFL.txt: the build
writes `MPLUSRounded1c-OFL.txt` from its METADATA.pb copyright line and the
OFL text of `ofl/mplus1p/OFL.txt`.

`gen_font_subsets` writes the two lists. A list holds its blocks, then every
character outside them that `app_<locale>.arb`, intl's `DateFormat.EEEE` and
`MMMd` output, the SDK's `material_<locale>.arb` and the autonym use and
neither Fredoka nor Nunito draws. A new kanji in the Japanese copy therefore
needs `dart run nesty_tools:gen_font_subsets`, then
`tools/fonts/build_fonts.sh`; a Hindi copy change needs neither.
`test/fonts/` checks it all without fontTools: `ttf_cmap.dart` reads the
bundled files' cmaps and weight classes in pure Dart, and
`font_coverage_test.dart` fails, naming the character, its codepoint, the
locale and the key, when an ARB character or an autonym has no face in a
style's chain at some bundled weight; it also checks that each role family
answers every `font.scripts` weight with the right outlines, that the lists
are fresh, and that `SHA256SUMS` lists exactly the bundled files.

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
| `report [paths] --stars [--star3-slack 20] [--star2-slack 60] [--runs 300] [--json]` | The star shares instead (spec-prop §7.10, m7-design P3.3): per chapter and bot, the share of won runs at 3★/2★/1★ (unassisted) against each level's par, from `RivalBot` runs with race seeds 0…runs−1; then `all`. The slack defaults mirror the game's Remote Config keys. A report, never a gate. |
| `bundle build` | `tools/levels/manifest.json` + `authored/` → `apps/game/assets/levels/bundle.json` (2-space indent, fixed key order, sorted by order, `rewardCoins` from the tier, `par` the solver's optimal moves: validation rule 8 at the admin budget). Refuses a changed board whose `version` wasn't raised (spec §13.3) and a level the solver doesn't prove (`build.parUnproven`). |
| `bundle check` | CI: the bundle is fresh (a missing or different `par` is `bundle.parMismatch`), and every level passes rules 1–8, has the declared tier the simulator gives (design A32; a `tierOverride` reason may keep the declared tier on the tutorials and on open-slot-only boards, which always simulate easy, D26), and follows the §6.6 pattern, the §3.7 schedule (maxSize 6 only on superhard levels), 20-level chapters and the M2 layout (2–3 shelves, ≤ 4 slots per shelf). E12: no two consecutive levels share a layout signature (the tutorials excepted), and from L31 no level is expert only (smart bot under half its runs). |
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
