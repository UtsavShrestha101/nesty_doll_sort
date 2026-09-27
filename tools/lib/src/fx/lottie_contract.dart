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
enum LottieRole {
  doll,
  mover,
  target;

  /// The null LOTTIE.md "Doll size" names for this role.
  String get sizeNull => '${name}_size';
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
/// 116×52 dp, hint arrow 40×50, extra slot 90×34, glass case 86×143, unlock
/// symbol 12×12, ice 96×160.
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
    this.hookLayers = const {},
    this.requiredLayers = const {},
    this.fills = const {},
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
  /// top-left) and for the two "box" files, `ui_toggle` and
  /// `ui_splash_loader`, whose canvas is the widget's box.
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

  /// Exactly the [lottieHookLayers] the file has.
  final Set<String> hookLayers;

  /// Other root layers LOTTIE.md names and the FX runtime keys on or relies
  /// on (m2-lottie-design §6–§13; the parent nulls that carry every lift,
  /// bob, pulse, burst and shake, LOTTIE.md v3 "Format"): they must exist,
  /// once.
  final Set<String> requiredLayers;

  /// Exactly the [lottieHookFills] the file has.
  final Set<String> fills;

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
const _travelS = LottiePoint(100, 500);
const _travelT = LottiePoint(300, 500);

/// The 29 files, in LOTTIE.md "Files" order (the game's `FxId` order).
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
    // The localized count follows `counter` (§12).
    requiredLayers: {'counter'},
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
  // The ribbons: 410 wide since v3 (band 336, tails 22 past it); the game's
  // own text fits a 312×40 (win) or 312×32 (chapter) box on the anchor.
  LottieFileContract(
    'ui_win_ribbon',
    width: 410,
    height: 110,
    frames: 18,
    kind: LottieKind.inPlace,
    anchor: LottiePoint(205, 55),
    requiredLayers: {'ribbon'},
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
