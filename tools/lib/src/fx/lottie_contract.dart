/// The Lottie contract: what every file of `design/lottie/` must be, taken
/// from the owner's `design/lottie/LOTTIE.md` v3 ("Format", "Files", "Image
/// slots", "Doll size, rim and tint", "Travel remap", "Text layers") and the
/// placement decisions of `docs/plans/m2-lottie-design.md` (§2 table, §5,
/// §8).
///
/// `sync_design_assets` validates each export against its entry, and
/// `gen_fx_spec` takes from here the facts the JSON can't carry: the anchor,
/// the kind, whether the file loops, and the travel null's S/T (the `drop`
/// null's start is validated only; `FxSpec` has no field for it). A test
/// keeps this table equal to LOTTIE.md's, so a changed LOTTIE.md fails CI
/// until the table (and the game) follow.
///
/// Pure Dart: `tools/` can't import `apps/game` (Flutter), so the file ids
/// and image slot ids are repeated here; a test compares them with the
/// game's `FxId` and `FxImageSlot` enums.
library;

/// Repo-relative folder of the owner's exports (read-only, D40).
const designLottieDir = 'design/lottie';

/// The owner's contract document in [designLottieDir]: read by tests, never
/// shipped.
const lottieContractDoc = 'LOTTIE.md';

/// The placeholder PNGs in [designLottieDir]: never shipped or decoded
/// (PROGRESS D50).
const lottiePlaceholderDir = 'images';

/// Where the files ship, under `apps/game/assets/` (`FxId.assetDirectory`).
const gameLottieDir = 'lottie';

/// A point in canvas units (1 unit = 1 dp at 390×844).
final class LottiePoint {
  const LottiePoint(this.x, this.y);

  final double x;
  final double y;

  static const zero = LottiePoint(0, 0);

  @override
  bool operator ==(Object other) =>
      other is LottiePoint && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);

  @override
  String toString() => '($x, $y)';
}

/// How a file is placed; mirrors the game's `FxKind` member names.
enum LottieKind { inPlace, boardSpace, segmented }

/// A named segment in composition frames; `tm`/`dr` of a JSON marker.
final class LottieMarker {
  const LottieMarker(this.name, this.start, this.duration);

  final String name;
  final double start;
  final double duration;

  double get end => start + duration;

  @override
  bool operator ==(Object other) =>
      other is LottieMarker &&
      other.name == name &&
      other.start == start &&
      other.duration == duration;

  @override
  int get hashCode => Object.hash(name, start, duration);

  @override
  String toString() => '$name $start+$duration';
}

/// Which doll a `<role>_size` null sizes; mirrors the game's `FxRole`.
///
/// The board files use [doll], [mover] and [target]; the mechanic intro
/// loops (m7-3, LOTTIE.md "Image slots") add [revealed] (`ui_intro_towers`),
/// [family], [family2] and [freed] (`ui_intro_glass`, `ui_intro_ice`).
enum LottieRole {
  doll('doll'),
  mover('mover'),
  target('target'),
  revealed('revealed'),
  family('family'),

  /// Its slots and null are `family_2_*`, so the prefix is explicit.
  family2('family_2'),
  freed('freed');

  const LottieRole(this.prefix);

  /// The id prefix of the role's image slots (`<prefix>_lid`,
  /// `<prefix>_body`) and of its size null.
  final String prefix;

  /// The null LOTTIE.md "Doll size" names for this role.
  String get sizeNull => '${prefix}_size';

  /// The role whose [prefix] is [prefix], or null.
  static LottieRole? ofPrefix(String prefix) {
    for (final role in values) {
      if (role.prefix == prefix) return role;
    }
    return null;
  }
}

/// The LOTTIE.md hook layers other than the size nulls: the nulls whose
/// position the runtime overrides (`travel`, remapped S→T; `target_pos`, set
/// to the target base; `drop`, `doll_reveal`'s per-tower start). A file has
/// one of these exactly when its contract lists it, so a stray hook (the
/// runtime would never drive it) is an issue too.
const lottieHookLayers = {'travel', 'target_pos', 'drop'};

/// The fills the game recolours (LOTTIE.md "Rim" and "Tint"), in the order
/// `FxSpec.colorFills` lists them.
const lottieHookFills = ['rim_tint', 'tint'];

/// An image slot (LOTTIE.md "Image slots"): the asset id and its declared
/// `w`/`h`, which LOTTIE.md v2+ makes the pixel size of the raster that fills
/// it (lottie 3.6.1 draws an image at its own pixel size). Mirrors the
/// game's `FxImageSlot`, in its declaration order.
final class LottieImageSlot {
  const LottieImageSlot(this.id, this.width, this.height);

  final String id;
  final double width;
  final double height;
}

/// Every image asset id any file may use, with its declared size. Doll parts
/// are the whole 512×768 skin artboard (layers at 19.53 %); board pieces are
/// declared at 3× their dp size (layers at 33.33 %, anchor ×3): glow ring
/// 116×52 dp, hint arrow 40×50, extra slot 90×34, glass case 86×143, tall
/// glass case 93×152, unlock symbol 12×12, ice 96×160. The UI art of m7-3 is
/// at 3× too: stars 44×44 (glow 73.3), chest 130×108.3; and m7-4's rival
/// portrait 96×96 and Museum figurine 62×62.
const lottieImageSlots = [
  LottieImageSlot('doll_lid', 512, 768),
  LottieImageSlot('doll_body', 512, 768),
  LottieImageSlot('mover_lid', 512, 768),
  LottieImageSlot('mover_body', 512, 768),
  LottieImageSlot('target_lid', 512, 768),
  LottieImageSlot('target_body', 512, 768),
  LottieImageSlot('doll_silhouette', 512, 768),
  LottieImageSlot('glow_ring', 348, 156),
  LottieImageSlot('hint_arrow', 120, 150),
  LottieImageSlot('extra_slot', 270, 102),
  LottieImageSlot('glass_case_0', 258, 429),
  LottieImageSlot('glass_case_1', 258, 429),
  LottieImageSlot('glass_case_2', 258, 429),
  LottieImageSlot('unlock_symbol', 36, 36),
  LottieImageSlot('ice_0', 288, 480),
  LottieImageSlot('ice_1', 288, 480),
  LottieImageSlot('ice_2', 288, 480),
  LottieImageSlot('ice_3', 288, 480),
  LottieImageSlot('ice_shatter', 288, 480),
  // m7-3: `fx_glass_unlock_tall`, `ui_stars`, `ui_chest` and the intro
  // loops' doll roles (LOTTIE.md "Image slots").
  LottieImageSlot('glass_case_tall_0', 279, 456),
  LottieImageSlot('glass_case_tall_1', 279, 456),
  LottieImageSlot('glass_case_tall_2', 279, 456),
  LottieImageSlot('star_filled', 132, 132),
  LottieImageSlot('star_empty', 132, 132),
  LottieImageSlot('star_glow', 220, 220),
  LottieImageSlot('chest_closed', 390, 325),
  LottieImageSlot('chest_open', 390, 325),
  LottieImageSlot('revealed_lid', 512, 768),
  LottieImageSlot('revealed_body', 512, 768),
  LottieImageSlot('family_lid', 512, 768),
  LottieImageSlot('family_body', 512, 768),
  LottieImageSlot('family_2_lid', 512, 768),
  LottieImageSlot('family_2_body', 512, 768),
  LottieImageSlot('freed_lid', 512, 768),
  LottieImageSlot('freed_body', 512, 768),
  // m7-4 (LOTTIE.md "Image slots"): the rival's portrait in
  // `ui_rival_react` (96 dp at 3×) and the collected figurine in
  // `ui_museum_idle` (62 dp at 3×).
  LottieImageSlot('rival_portrait', 288, 288),
  LottieImageSlot('figurine', 186, 186),
];

/// The slot for [id], or null.
LottieImageSlot? lottieImageSlotOf(String id) {
  for (final slot in lottieImageSlots) {
    if (slot.id == id) return slot;
  }
  return null;
}

/// What one file must be.
final class LottieFileContract {
  const LottieFileContract(
    this.name, {
    required this.width,
    required this.height,
    required this.frames,
    required this.kind,
    this.anchor = LottiePoint.zero,
    this.markers = const [],
    this.loops = false,
    this.travelS,
    this.travelT,
    this.dropFrom,
    this.imageAssets = const {},
    this.roles = const {},
    this.sizesAuthored = false,
    this.hookLayers = const {},
    this.requiredLayers = const {},
    this.scaleNulls = const {},
    this.fills = const {},
    this.tintFills = const {},
    this.sizedRects = const {},
    this.textLayers = const [],
  });

  /// The file name without `.json`; also the game's `FxId.fileName`.
  final String name;

  /// Canvas `w`/`h`.
  final double width;
  final double height;

  /// `op − ip`; `ip` is always 0.
  final int frames;

  final LottieKind kind;

  /// The point placed on the game point (m2-lottie-design §2 table).
  /// [LottiePoint.zero] for board-space files (placed by the canvas's
  /// top-left), for the "box" files, `ui_toggle`, `ui_splash_loader` and the
  /// three `ui_intro_*` loops, whose canvas is the widget's box, and for
  /// `ui_stars`, placed by its canvas (`layout.winStars.starsCanvas`).
  final LottiePoint anchor;

  /// Exactly the JSON's markers, in order.
  final List<LottieMarker> markers;

  /// LOTTIE.md "Length" says "loop".
  final bool loops;

  /// The `travel` null's authored S and T (board-space files only).
  final LottiePoint? travelS;
  final LottiePoint? travelT;

  /// The `drop` null's authored start (`doll_reveal` only): it lowers the
  /// whole doll from here to (0, 0), and the runtime overrides the start per
  /// tower depth (LOTTIE.md "Doll size, rim and tint" → "Reveal drop").
  final LottiePoint? dropFrom;

  /// Exactly the image asset ids the file declares.
  final Set<String> imageAssets;

  /// Exactly the `<role>_size` nulls the file has.
  final Set<LottieRole> roles;

  /// The `<role>_size` nulls are the file's own animation, never driven by
  /// the game (m7-3's intro loops: the fixed-size card dolls, and the
  /// families that shrink into the counter). Their scale may animate, and
  /// `FxSpec.roles` is empty, so the runtime installs no size delegate; the
  /// image slots still say which role (colour) each doll part is.
  final bool sizesAuthored;

  /// Exactly the [lottieHookLayers] the file has.
  final Set<String> hookLayers;

  /// Other root layers LOTTIE.md names and the FX runtime keys on or relies
  /// on (m2-lottie-design §6–§13; the parent nulls that carry every lift,
  /// bob, pulse, burst and shake, LOTTIE.md v3 "Format"): they must exist,
  /// once.
  final Set<String> requiredLayers;

  /// Root nulls other than the `<role>_size` ones whose scale the runtime
  /// overrides with `ValueDelegate.transformScale` (LOTTIE.md "Case size":
  /// `fx_glass_unlock_tall`'s `case_size`, set to the same h / 150 as
  /// `doll_size`). Each must be a null with a static scale, once; the game
  /// reads them as `FxSpec.scaleNulls`.
  final Set<String> scaleNulls;

  /// Exactly the [lottieHookFills] the file has.
  final Set<String> fills;

  /// Exactly the fills named `<part>_fill` the file has (LOTTIE.md m7-4
  /// "Tint and width"): the ribbons' `band_fill`, `edge_fill`, `hi_fill`,
  /// `tail_fill` and `fold_fill`, the family counter's `pill_fill` and
  /// `glow_fill`. The game reaches each through a colour delegate on
  /// `['**', '<name>']`, so every one must be a fill.
  final Set<String> tintFills;

  /// Exactly the rectangles named `<part>_rect` the file has (LOTTIE.md
  /// "Tint and width": the family counter's `pill_rect` and `glow_rect`;
  /// since m7-5 the ribbons' `band_rect`, `edge_rect` and `hi_rect`), which
  /// `ValueDelegate.rectangleSize` widens. Each must be a rectangle.
  final Set<String> sizedRects;

  /// Exactly the text layer names; only the three text files have any.
  final List<String> textLayers;
}

const _dollBase = LottiePoint(80, 230);
const _dollParts = {'doll_lid', 'doll_body'};
const _moverTargetParts = {
  'mover_lid',
  'mover_body',
  'target_lid',
  'target_body',
};

/// The ribbons' named rectangles (LOTTIE.md m7-5): `band_rect`, `edge_rect`
/// and `hi_rect` on `band`, which the game resizes to set the band's width
/// (`tokens.winRibbon.size.rects`; the tails move by the half-difference).
const _ribbonRects = {'band_rect', 'edge_rect', 'hi_rect'};

/// The ribbons' named fills (LOTTIE.md m7-4 "Tint and width"): `band_fill`,
/// `edge_fill` and `hi_fill` on `band`, `tail_fill` and `fold_fill` on
/// `tail_l` and `tail_r`.
const _ribbonFills = {
  'band_fill',
  'edge_fill',
  'hi_fill',
  'tail_fill',
  'fold_fill',
};
const _travelS = LottiePoint(100, 500);
const _travelT = LottiePoint(300, 500);

/// The 37 files, in LOTTIE.md "Files" order (the game's `FxId` order): the
/// 29 of v3, then m7-3's `fx_glass_unlock_tall` (after `fx_glass_unlock`)
/// and its five `ui_*` files, then m7-4's `ui_rival_react` and
/// `ui_museum_idle` (last).
const lottieContracts = [
  LottieFileContract(
    'doll_pick',
    width: 160,
    height: 260,
    frames: 41,
    kind: LottieKind.segmented,
    anchor: _dollBase,
    markers: [
      LottieMarker('lift', 0, 7),
      LottieMarker('wobble', 7, 24),
      LottieMarker('settle', 31, 10),
    ],
    imageAssets: _dollParts,
    roles: {LottieRole.doll},
  ),
  LottieFileContract(
    'doll_move',
    width: 390,
    height: 844,
    frames: 16,
    kind: LottieKind.boardSpace,
    travelS: _travelS,
    travelT: _travelT,
    imageAssets: _dollParts,
    roles: {LottieRole.doll},
    hookLayers: {'travel'},
  ),
  LottieFileContract(
    'doll_nest',
    width: 160,
    height: 260,
    frames: 24,
    kind: LottieKind.inPlace,
    anchor: _dollBase,
    imageAssets: _moverTargetParts,
    roles: {LottieRole.mover, LottieRole.target},
    // The target's lid lift, off the image layer since v3.
    requiredLayers: {'target_lid_lift'},
    fills: {'rim_tint'},
  ),
  LottieFileContract(
    'doll_swallow',
    width: 180,
    height: 380,
    frames: 24,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(90, 350),
    imageAssets: _moverTargetParts,
    roles: {LottieRole.mover, LottieRole.target},
    // The mover's lid lift, off the image layer since v3.
    requiredLayers: {'mover_lid_lift'},
    fills: {'rim_tint'},
  ),
  LottieFileContract(
    'doll_complete',
    width: 390,
    height: 844,
    frames: 75,
    kind: LottieKind.boardSpace,
    travelS: LottiePoint(100, 650),
    travelT: LottiePoint(195, 144),
    imageAssets: _dollParts,
    roles: {LottieRole.doll},
    hookLayers: {'travel'},
  ),
  LottieFileContract(
    'doll_invalid',
    width: 390,
    height: 844,
    frames: 36,
    kind: LottieKind.boardSpace,
    travelS: _travelS,
    travelT: _travelT,
    imageAssets: _moverTargetParts,
    roles: {LottieRole.mover, LottieRole.target},
    hookLayers: {'travel', 'target_pos'},
    // The shake null: static (0,0) under reduced motion (§13).
    requiredLayers: {'target'},
  ),
  LottieFileContract(
    'doll_reveal',
    width: 160,
    height: 260,
    frames: 31,
    kind: LottieKind.inPlace,
    anchor: _dollBase,
    // `drop` lowers the doll 0–7, then the wipe runs 7–19.
    dropFrom: LottiePoint(0, -18),
    imageAssets: {'doll_silhouette', 'doll_lid', 'doll_body'},
    roles: {LottieRole.doll},
    hookLayers: {'drop'},
    // The silhouette ends with the wipe (frame 19); the colour doll is the
    // precomp its lid and body are compensated through (§3).
    requiredLayers: {'doll_silhouette', 'color_doll'},
    fills: {'tint'},
  ),
  LottieFileContract(
    'doll_idle',
    width: 160,
    height: 260,
    frames: 180,
    kind: LottieKind.inPlace,
    anchor: _dollBase,
    loops: true,
    imageAssets: _dollParts,
    roles: {LottieRole.doll},
  ),
  LottieFileContract(
    'doll_win_dance',
    width: 160,
    height: 260,
    frames: 84,
    kind: LottieKind.inPlace,
    anchor: _dollBase,
    loops: true,
    imageAssets: _dollParts,
    roles: {LottieRole.doll},
  ),
  LottieFileContract(
    'doll_win_hop',
    width: 160,
    height: 260,
    frames: 78,
    kind: LottieKind.inPlace,
    anchor: _dollBase,
    loops: true,
    imageAssets: _dollParts,
    roles: {LottieRole.doll},
  ),
  LottieFileContract(
    'fx_select_glow',
    width: 140,
    height: 80,
    frames: 113,
    kind: LottieKind.segmented,
    anchor: LottiePoint(70, 40),
    markers: [
      LottieMarker('in', 0, 7),
      LottieMarker('pulse', 7, 96),
      LottieMarker('out', 103, 10),
    ],
    imageAssets: {'glow_ring'},
    // The ring's pulse, off the image layer since v2.
    requiredLayers: {'glow_pulse'},
  ),
  LottieFileContract(
    'fx_glass_unlock',
    width: 180,
    height: 240,
    frames: 54,
    kind: LottieKind.inPlace,
    // The doll base → (cx, lockedDollBaseY); the case's top-left (47, 40)
    // follows (§8).
    anchor: LottiePoint(90, 163),
    imageAssets: {
      'glass_case_0',
      'glass_case_1',
      'glass_case_2',
      'unlock_symbol',
      'doll_lid',
      'doll_body',
    },
    roles: {LottieRole.doll},
    // `doll` carries the freed doll's hop, which lands on the stand surface
    // (90, 174) at frame 53; `padlock_ping` starts at frame 1, so the rest
    // frame 0 shows the unlock symbol (LOTTIE.md v2, v3).
    requiredLayers: {'doll', 'padlock_ping'},
  ),
  // m7-1: the tall case for a sealed size-5 or size-6 doll. Every piece but
  // the doll hangs from `case_size` on the stand surface (the anchor), and
  // the doll stands on the surface, so it rests and lands at (100, 212).
  LottieFileContract(
    'fx_glass_unlock_tall',
    width: 200,
    height: 280,
    frames: 54,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(100, 212),
    imageAssets: {
      'glass_case_tall_0',
      'glass_case_tall_1',
      'glass_case_tall_2',
      'unlock_symbol',
      'doll_lid',
      'doll_body',
    },
    roles: {LottieRole.doll},
    requiredLayers: {'doll', 'padlock_ping', 'case_size'},
    scaleNulls: {'case_size'},
  ),
  LottieFileContract(
    'fx_ice',
    width: 180,
    height: 240,
    frames: 150,
    kind: LottieKind.segmented,
    // The doll base → (cx, surfaceY); the ice's top-left (42, 40) follows.
    anchor: LottiePoint(90, 170.8),
    // In the JSON's order: the cracks and the shatter, the rest markers
    // (dr 0; stage n rests on `rest_n`), then the stage-less hits (v3).
    markers: [
      LottieMarker('crack_1', 0, 16),
      LottieMarker('crack_2', 16, 16),
      LottieMarker('crack_3', 32, 16),
      LottieMarker('shatter', 48, 33),
      LottieMarker('rest_0', 0, 0),
      LottieMarker('rest_1', 16, 0),
      LottieMarker('rest_2', 32, 0),
      LottieMarker('rest_3', 48, 0),
      LottieMarker('crack_hit_0', 82, 16),
      LottieMarker('crack_hit_1', 99, 16),
      LottieMarker('crack_hit_2', 116, 16),
      LottieMarker('crack_hit_3', 133, 16),
    ],
    imageAssets: {
      'ice_0',
      'ice_1',
      'ice_2',
      'ice_3',
      'ice_shatter',
      'doll_lid',
      'doll_body',
    },
    roles: {LottieRole.doll},
    // `ice`: the shake null, static (42, 40) under reduced motion (§13).
    // `shatter_burst`: the shatter's burst, off the image layer since v2.
    requiredLayers: {'ice', 'shatter_burst'},
  ),
  LottieFileContract(
    'fx_dust_puff',
    width: 160,
    height: 80,
    frames: 24,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(80, 62),
  ),
  LottieFileContract(
    'fx_sparkle',
    width: 64,
    height: 64,
    frames: 16,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(32, 32),
  ),
  LottieFileContract(
    'fx_confetti',
    width: 390,
    height: 844,
    frames: 102,
    // Full screen, but placed about its burst point (§5), not board space.
    kind: LottieKind.inPlace,
    anchor: LottiePoint(195, 190),
  ),
  LottieFileContract(
    'fx_coin_burst',
    width: 160,
    height: 140,
    frames: 40,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(80, 100),
  ),
  LottieFileContract(
    'fx_twinkle',
    width: 32,
    height: 32,
    frames: 120,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(16, 16),
    loops: true,
    fills: {'tint'},
  ),
  LottieFileContract(
    'ui_family_counter',
    width: 120,
    height: 60,
    frames: 12,
    kind: LottieKind.segmented,
    anchor: LottiePoint(60, 30),
    markers: [LottieMarker('bump', 0, 12)],
    // The localized count follows `counter` (§12). m7-4 ("Tint and
    // width"): the pill widens through `pill_rect` and `glow_rect`, and the
    // doll mark `icon` moves with it (`transformPosition`).
    requiredLayers: {'counter', 'icon'},
    tintFills: {'pill_fill', 'glow_fill'},
    sizedRects: {'pill_rect', 'glow_rect'},
    textLayers: ['count_new', 'count_old'],
  ),
  LottieFileContract(
    'ui_hint_arrow',
    width: 60,
    height: 80,
    frames: 54,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(30, 45),
    loops: true,
    imageAssets: {'hint_arrow'},
    // The arrow's bob, off the image layer since v3.
    requiredLayers: {'arrow_bob'},
  ),
  LottieFileContract(
    'ui_extra_slot',
    width: 110,
    height: 50,
    frames: 96,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(55, 25),
    // m7-3 (E.21): the loop starts and ends on the static pad's pose, so
    // the game starts it at `rest`, frame 0 (undoing D116's frame 24).
    markers: [LottieMarker('rest', 0, 0)],
    loops: true,
    imageAssets: {'extra_slot'},
    // The stand's pulse, off the image layer since v2.
    requiredLayers: {'slot_pulse'},
  ),
  LottieFileContract(
    'ui_booster_glow',
    width: 130,
    height: 110,
    frames: 84,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(65, 55),
    loops: true,
  ),
  // The ribbons: a 410-wide canvas since v3. m7-5: the win band is 290 × 56
  // with tails to ±167, the chapter band stays 336; the game's own text fits
  // a 266×40 (win) or 312×32 (chapter) box on the anchor, and both bands
  // take a width through their named rects.
  LottieFileContract(
    'ui_win_ribbon',
    width: 410,
    height: 110,
    frames: 18,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(205, 55),
    requiredLayers: {'ribbon'},
    tintFills: _ribbonFills,
    sizedRects: _ribbonRects,
    textLayers: ['label', 'label_shadow'],
  ),
  LottieFileContract(
    'ui_chapter_ribbon',
    width: 410,
    height: 100,
    frames: 156,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(205, 50),
    requiredLayers: {'ribbon'},
    tintFills: _ribbonFills,
    sizedRects: _ribbonRects,
    textLayers: ['label', 'label_shadow'],
  ),
  LottieFileContract(
    'ui_toggle',
    width: 54,
    height: 30,
    frames: 22,
    kind: LottieKind.segmented,
    markers: [LottieMarker('on', 0, 11), LottieMarker('off', 11, 11)],
  ),
  LottieFileContract(
    'ui_spinner',
    width: 16,
    height: 16,
    frames: 54,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(8, 8),
    loops: true,
  ),
  LottieFileContract(
    'ui_splash_loader',
    width: 278,
    height: 22,
    frames: 100,
    kind: LottieKind.inPlace,
  ),
  LottieFileContract(
    'ui_tap_hand',
    width: 128,
    height: 144,
    frames: 72,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(48, 32),
    loops: true,
  ),
  LottieFileContract(
    'ui_drag_hand',
    width: 390,
    height: 844,
    frames: 144,
    kind: LottieKind.boardSpace,
    loops: true,
    travelS: _travelS,
    travelT: _travelT,
    hookLayers: {'travel'},
  ),
  // m7-2: the win card's star rating. Placed by its canvas
  // (`layout.winStars.starsCanvas`), not by a point: three empty stars at
  // rest, `star_n` pops the n-th filled star on its parent null.
  LottieFileContract(
    'ui_stars',
    width: 240,
    height: 110,
    frames: 120,
    kind: LottieKind.segmented,
    markers: [
      LottieMarker('star_1', 0, 20),
      LottieMarker('star_2', 20, 20),
      LottieMarker('star_3', 40, 20),
      LottieMarker('flourish', 60, 60),
    ],
    imageAssets: {'star_filled', 'star_empty', 'star_glow'},
  ),
  // m7-2: the milestone and day-7 chest. `idle` and `open_idle` loop as
  // segments; the file itself plays once.
  LottieFileContract(
    'ui_chest',
    width: 200,
    height: 200,
    frames: 410,
    kind: LottieKind.segmented,
    anchor: LottiePoint(100, 186),
    markers: [
      LottieMarker('arrive', 0, 36),
      LottieMarker('idle', 36, 180),
      LottieMarker('wiggle', 216, 29),
      LottieMarker('open', 245, 45),
      LottieMarker('open_idle', 290, 120),
    ],
    imageAssets: {'chest_closed', 'chest_open'},
  ),
  // m7-3 (D): the mechanic intro cards' loops, on the card's 302×230
  // illustration box (placed by its top-left, like `ui_toggle`). One
  // `loop` marker spans each file. Every size null is authored, not driven:
  // the role ones (some animate) and the glass and ice files' `case_size`
  // and `ice_size`.
  LottieFileContract(
    'ui_intro_towers',
    width: 302,
    height: 230,
    frames: 240,
    kind: LottieKind.inPlace,
    markers: [LottieMarker('loop', 0, 240)],
    loops: true,
    imageAssets: {
      'mover_lid',
      'mover_body',
      'revealed_lid',
      'revealed_body',
      'doll_silhouette',
    },
    roles: {LottieRole.mover, LottieRole.revealed},
    sizesAuthored: true,
  ),
  LottieFileContract(
    'ui_intro_glass',
    width: 302,
    height: 230,
    frames: 240,
    kind: LottieKind.inPlace,
    markers: [LottieMarker('loop', 0, 240)],
    loops: true,
    imageAssets: {
      'family_lid',
      'family_body',
      'freed_lid',
      'freed_body',
      'glass_case_0',
      'glass_case_1',
      'glass_case_2',
      'unlock_symbol',
    },
    roles: {LottieRole.family, LottieRole.freed},
    sizesAuthored: true,
  ),
  LottieFileContract(
    'ui_intro_ice',
    width: 302,
    height: 230,
    frames: 300,
    kind: LottieKind.inPlace,
    markers: [LottieMarker('loop', 0, 300)],
    loops: true,
    imageAssets: {
      'family_lid',
      'family_body',
      'family_2_lid',
      'family_2_body',
      'freed_lid',
      'freed_body',
      'ice_0',
      'ice_1',
      'ice_shatter',
    },
    roles: {LottieRole.family, LottieRole.family2, LottieRole.freed},
    sizesAuthored: true,
  ),
  // m7-4 (C.6): the rival's portrait reacting, on the strip (the canvas at
  // 47.5 dp) and the race's result cards. `idle` loops as a segment; the
  // file itself plays once. Every move is on the `react` null and the
  // portrait's `react_size` under it.
  LottieFileContract(
    'ui_rival_react',
    width: 120,
    height: 120,
    frames: 380,
    kind: LottieKind.segmented,
    anchor: LottiePoint(60, 64),
    markers: [
      LottieMarker('idle', 0, 180),
      LottieMarker('family', 180, 40),
      LottieMarker('win', 220, 80),
      LottieMarker('lose', 300, 80),
    ],
    imageAssets: {'rival_portrait'},
    requiredLayers: {'react', 'react_size'},
  ),
  // m7-4 (J.2): a collected figurine's idle in its Museum niche, started
  // at a random frame per niche; the bob is on the `bob` null.
  LottieFileContract(
    'ui_museum_idle',
    width: 90,
    height: 90,
    frames: 240,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(45, 80),
    markers: [LottieMarker('loop', 0, 240)],
    loops: true,
    imageAssets: {'figurine'},
    requiredLayers: {'bob'},
  ),
];

/// The contract for [name], or null.
LottieFileContract? lottieContractOf(
  String name, [
  List<LottieFileContract> contracts = lottieContracts,
]) {
  for (final c in contracts) {
    if (c.name == name) return c;
  }
  return null;
}

/// `doll_pick` → `dollPick`: the Dart enum member name of a file id or an
/// image slot id (`glass_case_0` → `glassCase0`).
String lottieMemberName(String id) {
  final parts = id.split('_');
  return [
    parts.first,
    for (final part in parts.skip(1))
      if (part.isNotEmpty) '${part[0].toUpperCase()}${part.substring(1)}',
  ].join();
}
