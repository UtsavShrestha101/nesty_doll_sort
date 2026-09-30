// GENERATED — do not edit; run dart run nesty_tools:gen_fx_spec
//
// Source: design/lottie/*.json (validated by sync_design_assets, shipped
// to apps/game/assets/lottie/) and, for what the JSON does not carry
// (anchor, kind, loop, travel S/T, scale nulls), the LOTTIE.md v3 contract
// table in tools/lib/src/fx/lottie_contract.dart. Validation guarantees
// that no travel null holds and no image layer animates its transform.

import 'dart:ui' show Offset;

import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';

/// Every file's [FxSpec], one per [FxId]
/// (docs/plans/m2-lottie-design.md §2 "Generated specs").
const Map<FxId, FxSpec> fxSpecs = {
  // doll_pick: 41 f (683 ms), 160×260.
  FxId.dollPick: FxSpec(
    id: FxId.dollPick,
    frames: 41,
    width: 160,
    height: 260,
    anchor: Offset(80, 230),
    kind: FxKind.segmented,
    markers: [
      FxMarker('lift', 0, 7),
      FxMarker('wobble', 7, 24),
      FxMarker('settle', 31, 10),
    ],
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
  ),
  // doll_move: 16 f (267 ms), 390×844.
  FxId.dollMove: FxSpec(
    id: FxId.dollMove,
    frames: 16,
    width: 390,
    height: 844,
    anchor: Offset.zero,
    kind: FxKind.boardSpace,
    travel: FxTravel(s: Offset(100, 500), t: Offset(300, 500)),
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
  ),
  // doll_nest: 24 f (400 ms), 160×260.
  FxId.dollNest: FxSpec(
    id: FxId.dollNest,
    frames: 24,
    width: 160,
    height: 260,
    anchor: Offset(80, 230),
    kind: FxKind.inPlace,
    roles: [FxRole.mover, FxRole.target],
    imageLayers: [
      FxImageLayer(
        keyPath: ['target_lid'],
        slot: FxImageSlot.targetLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['target_body'],
        slot: FxImageSlot.targetBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['mover_lid'],
        slot: FxImageSlot.moverLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['mover_body'],
        slot: FxImageSlot.moverBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    colorFills: ['rim_tint'],
  ),
  // doll_swallow: 24 f (400 ms), 180×380.
  FxId.dollSwallow: FxSpec(
    id: FxId.dollSwallow,
    frames: 24,
    width: 180,
    height: 380,
    anchor: Offset(90, 350),
    kind: FxKind.inPlace,
    roles: [FxRole.mover, FxRole.target],
    imageLayers: [
      FxImageLayer(
        keyPath: ['mover_lid'],
        slot: FxImageSlot.moverLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['mover_body'],
        slot: FxImageSlot.moverBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['target_lid'],
        slot: FxImageSlot.targetLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['target_body'],
        slot: FxImageSlot.targetBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    colorFills: ['rim_tint'],
  ),
  // doll_complete: 75 f (1250 ms), 390×844.
  FxId.dollComplete: FxSpec(
    id: FxId.dollComplete,
    frames: 75,
    width: 390,
    height: 844,
    anchor: Offset.zero,
    kind: FxKind.boardSpace,
    travel: FxTravel(s: Offset(100, 650), t: Offset(195, 144)),
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['shine_matte', 'lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(1, 1),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['shine_matte', 'body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(1, 1),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
  ),
  // doll_invalid: 36 f (600 ms), 390×844.
  FxId.dollInvalid: FxSpec(
    id: FxId.dollInvalid,
    frames: 36,
    width: 390,
    height: 844,
    anchor: Offset.zero,
    kind: FxKind.boardSpace,
    travel: FxTravel(s: Offset(100, 500), t: Offset(300, 500)),
    roles: [FxRole.mover, FxRole.target],
    imageLayers: [
      FxImageLayer(
        keyPath: ['mover_lid'],
        slot: FxImageSlot.moverLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['mover_body'],
        slot: FxImageSlot.moverBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['target_lid'],
        slot: FxImageSlot.targetLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['target_body'],
        slot: FxImageSlot.targetBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
  ),
  // doll_reveal: 31 f (517 ms), 160×260.
  FxId.dollReveal: FxSpec(
    id: FxId.dollReveal,
    frames: 31,
    width: 160,
    height: 260,
    anchor: Offset(80, 230),
    kind: FxKind.inPlace,
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['color_doll', 'lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(1, 1),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['color_doll', 'body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(1, 1),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['doll_silhouette'],
        slot: FxImageSlot.dollSilhouette,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    colorFills: ['tint'],
  ),
  // doll_idle: 180 f (3000 ms), 160×260, loops.
  FxId.dollIdle: FxSpec(
    id: FxId.dollIdle,
    frames: 180,
    width: 160,
    height: 260,
    anchor: Offset(80, 230),
    kind: FxKind.inPlace,
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    loops: true,
  ),
  // doll_win_dance: 84 f (1400 ms), 160×260, loops.
  FxId.dollWinDance: FxSpec(
    id: FxId.dollWinDance,
    frames: 84,
    width: 160,
    height: 260,
    anchor: Offset(80, 230),
    kind: FxKind.inPlace,
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    loops: true,
  ),
  // doll_win_hop: 78 f (1300 ms), 160×260, loops.
  FxId.dollWinHop: FxSpec(
    id: FxId.dollWinHop,
    frames: 78,
    width: 160,
    height: 260,
    anchor: Offset(80, 230),
    kind: FxKind.inPlace,
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    loops: true,
  ),
  // fx_select_glow: 113 f (1883 ms), 140×80.
  FxId.fxSelectGlow: FxSpec(
    id: FxId.fxSelectGlow,
    frames: 113,
    width: 140,
    height: 80,
    anchor: Offset(70, 40),
    kind: FxKind.segmented,
    markers: [
      FxMarker('in', 0, 7),
      FxMarker('pulse', 7, 96),
      FxMarker('out', 103, 10),
    ],
    imageLayers: [
      FxImageLayer(
        keyPath: ['glow_ring'],
        slot: FxImageSlot.glowRing,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(174, 78),
      ),
    ],
  ),
  // fx_glass_unlock: 54 f (900 ms), 180×240.
  FxId.fxGlassUnlock: FxSpec(
    id: FxId.fxGlassUnlock,
    frames: 54,
    width: 180,
    height: 240,
    anchor: Offset(90, 163),
    kind: FxKind.inPlace,
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['padlock_ping', 'lock'],
        slot: FxImageSlot.glassCase0,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['unlock_symbol'],
        slot: FxImageSlot.unlockSymbol,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(18, 18),
      ),
      FxImageLayer(
        keyPath: ['glass_case_0'],
        slot: FxImageSlot.glassCase0,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['glass_case_1'],
        slot: FxImageSlot.glassCase1,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['glass_case_2'],
        slot: FxImageSlot.glassCase2,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
  ),
  // fx_glass_unlock_tall: 54 f (900 ms), 200×280.
  FxId.fxGlassUnlockTall: FxSpec(
    id: FxId.fxGlassUnlockTall,
    frames: 54,
    width: 200,
    height: 280,
    anchor: Offset(100, 212),
    kind: FxKind.inPlace,
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['padlock_ping', 'lock'],
        slot: FxImageSlot.glassCaseTall0,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['unlock_symbol'],
        slot: FxImageSlot.unlockSymbol,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(18, 18),
      ),
      FxImageLayer(
        keyPath: ['glass_case_tall_0'],
        slot: FxImageSlot.glassCaseTall0,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['glass_case_tall_1'],
        slot: FxImageSlot.glassCaseTall1,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['glass_case_tall_2'],
        slot: FxImageSlot.glassCaseTall2,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    scaleNulls: ['case_size'],
  ),
  // fx_ice: 150 f (2500 ms), 180×240.
  FxId.fxIce: FxSpec(
    id: FxId.fxIce,
    frames: 150,
    width: 180,
    height: 240,
    anchor: Offset(90, 170.8),
    kind: FxKind.segmented,
    markers: [
      FxMarker('crack_1', 0, 16),
      FxMarker('crack_2', 16, 16),
      FxMarker('crack_3', 32, 16),
      FxMarker('shatter', 48, 33),
      FxMarker('rest_0', 0, 0),
      FxMarker('rest_1', 16, 0),
      FxMarker('rest_2', 32, 0),
      FxMarker('rest_3', 48, 0),
      FxMarker('crack_hit_0', 82, 16),
      FxMarker('crack_hit_1', 99, 16),
      FxMarker('crack_hit_2', 116, 16),
      FxMarker('crack_hit_3', 133, 16),
    ],
    roles: [FxRole.doll],
    imageLayers: [
      FxImageLayer(
        keyPath: ['ice_shatter'],
        slot: FxImageSlot.iceShatter,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(144, 240),
      ),
      FxImageLayer(
        keyPath: ['ice_3'],
        slot: FxImageSlot.ice3,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_2'],
        slot: FxImageSlot.ice2,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_1'],
        slot: FxImageSlot.ice1,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_0'],
        slot: FxImageSlot.ice0,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_0_hit'],
        slot: FxImageSlot.ice0,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_1_hit'],
        slot: FxImageSlot.ice1,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_2_hit'],
        slot: FxImageSlot.ice2,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_3_hit'],
        slot: FxImageSlot.ice3,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['doll_lid'],
        slot: FxImageSlot.dollLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['doll_body'],
        slot: FxImageSlot.dollBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
  ),
  // fx_dust_puff: 24 f (400 ms), 160×80.
  FxId.fxDustPuff: FxSpec(
    id: FxId.fxDustPuff,
    frames: 24,
    width: 160,
    height: 80,
    anchor: Offset(80, 62),
    kind: FxKind.inPlace,
  ),
  // fx_sparkle: 16 f (267 ms), 64×64.
  FxId.fxSparkle: FxSpec(
    id: FxId.fxSparkle,
    frames: 16,
    width: 64,
    height: 64,
    anchor: Offset(32, 32),
    kind: FxKind.inPlace,
  ),
  // fx_confetti: 102 f (1700 ms), 390×844.
  FxId.fxConfetti: FxSpec(
    id: FxId.fxConfetti,
    frames: 102,
    width: 390,
    height: 844,
    anchor: Offset(195, 190),
    kind: FxKind.inPlace,
  ),
  // fx_coin_burst: 40 f (667 ms), 160×140.
  FxId.fxCoinBurst: FxSpec(
    id: FxId.fxCoinBurst,
    frames: 40,
    width: 160,
    height: 140,
    anchor: Offset(80, 100),
    kind: FxKind.inPlace,
  ),
  // fx_twinkle: 120 f (2000 ms), 32×32, loops.
  FxId.fxTwinkle: FxSpec(
    id: FxId.fxTwinkle,
    frames: 120,
    width: 32,
    height: 32,
    anchor: Offset(16, 16),
    kind: FxKind.inPlace,
    colorFills: ['tint'],
    loops: true,
  ),
  // ui_family_counter: 12 f (200 ms), 120×60.
  FxId.uiFamilyCounter: FxSpec(
    id: FxId.uiFamilyCounter,
    frames: 12,
    width: 120,
    height: 60,
    anchor: Offset(60, 30),
    kind: FxKind.segmented,
    markers: [FxMarker('bump', 0, 12)],
    textLayers: ['count_new', 'count_old'],
  ),
  // ui_hint_arrow: 54 f (900 ms), 60×80, loops.
  FxId.uiHintArrow: FxSpec(
    id: FxId.uiHintArrow,
    frames: 54,
    width: 60,
    height: 80,
    anchor: Offset(30, 45),
    kind: FxKind.inPlace,
    imageLayers: [
      FxImageLayer(
        keyPath: ['hint_arrow'],
        slot: FxImageSlot.hintArrow,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(60, 75),
      ),
    ],
    loops: true,
  ),
  // ui_extra_slot: 96 f (1600 ms), 110×50, loops.
  FxId.uiExtraSlot: FxSpec(
    id: FxId.uiExtraSlot,
    frames: 96,
    width: 110,
    height: 50,
    anchor: Offset(55, 25),
    kind: FxKind.inPlace,
    markers: [FxMarker('rest', 0, 0)],
    imageLayers: [
      FxImageLayer(
        keyPath: ['extra_slot'],
        slot: FxImageSlot.extraSlot,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(135, 51),
      ),
    ],
    loops: true,
  ),
  // ui_booster_glow: 84 f (1400 ms), 130×110, loops.
  FxId.uiBoosterGlow: FxSpec(
    id: FxId.uiBoosterGlow,
    frames: 84,
    width: 130,
    height: 110,
    anchor: Offset(65, 55),
    kind: FxKind.inPlace,
    loops: true,
  ),
  // ui_win_ribbon: 18 f (300 ms), 410×110.
  FxId.uiWinRibbon: FxSpec(
    id: FxId.uiWinRibbon,
    frames: 18,
    width: 410,
    height: 110,
    anchor: Offset(205, 55),
    kind: FxKind.inPlace,
    textLayers: ['label', 'label_shadow'],
  ),
  // ui_chapter_ribbon: 156 f (2600 ms), 410×100.
  FxId.uiChapterRibbon: FxSpec(
    id: FxId.uiChapterRibbon,
    frames: 156,
    width: 410,
    height: 100,
    anchor: Offset(205, 50),
    kind: FxKind.inPlace,
    textLayers: ['label', 'label_shadow'],
  ),
  // ui_toggle: 22 f (367 ms), 54×30.
  FxId.uiToggle: FxSpec(
    id: FxId.uiToggle,
    frames: 22,
    width: 54,
    height: 30,
    anchor: Offset.zero,
    kind: FxKind.segmented,
    markers: [FxMarker('on', 0, 11), FxMarker('off', 11, 11)],
  ),
  // ui_spinner: 54 f (900 ms), 16×16, loops.
  FxId.uiSpinner: FxSpec(
    id: FxId.uiSpinner,
    frames: 54,
    width: 16,
    height: 16,
    anchor: Offset(8, 8),
    kind: FxKind.inPlace,
    loops: true,
  ),
  // ui_splash_loader: 100 f (1667 ms), 278×22.
  FxId.uiSplashLoader: FxSpec(
    id: FxId.uiSplashLoader,
    frames: 100,
    width: 278,
    height: 22,
    anchor: Offset.zero,
    kind: FxKind.inPlace,
  ),
  // ui_tap_hand: 72 f (1200 ms), 128×144, loops.
  FxId.uiTapHand: FxSpec(
    id: FxId.uiTapHand,
    frames: 72,
    width: 128,
    height: 144,
    anchor: Offset(48, 32),
    kind: FxKind.inPlace,
    loops: true,
  ),
  // ui_drag_hand: 144 f (2400 ms), 390×844, loops.
  FxId.uiDragHand: FxSpec(
    id: FxId.uiDragHand,
    frames: 144,
    width: 390,
    height: 844,
    anchor: Offset.zero,
    kind: FxKind.boardSpace,
    travel: FxTravel(s: Offset(100, 500), t: Offset(300, 500)),
    loops: true,
  ),
  // ui_stars: 120 f (2000 ms), 240×110.
  FxId.uiStars: FxSpec(
    id: FxId.uiStars,
    frames: 120,
    width: 240,
    height: 110,
    anchor: Offset.zero,
    kind: FxKind.segmented,
    markers: [
      FxMarker('star_1', 0, 20),
      FxMarker('star_2', 20, 20),
      FxMarker('star_3', 40, 20),
      FxMarker('flourish', 60, 60),
    ],
    imageLayers: [
      FxImageLayer(
        keyPath: ['star_1_filled'],
        slot: FxImageSlot.starFilled,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(66, 69),
      ),
      FxImageLayer(
        keyPath: ['star_2_filled'],
        slot: FxImageSlot.starFilled,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(66, 69),
      ),
      FxImageLayer(
        keyPath: ['star_3_filled'],
        slot: FxImageSlot.starFilled,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(66, 69),
      ),
      FxImageLayer(
        keyPath: ['star_1_empty'],
        slot: FxImageSlot.starEmpty,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(66, 69),
      ),
      FxImageLayer(
        keyPath: ['star_2_empty'],
        slot: FxImageSlot.starEmpty,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(66, 69),
      ),
      FxImageLayer(
        keyPath: ['star_3_empty'],
        slot: FxImageSlot.starEmpty,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(66, 69),
      ),
      FxImageLayer(
        keyPath: ['star_glow'],
        slot: FxImageSlot.starGlow,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(110, 112),
      ),
    ],
  ),
  // ui_chest: 410 f (6833 ms), 200×200.
  FxId.uiChest: FxSpec(
    id: FxId.uiChest,
    frames: 410,
    width: 200,
    height: 200,
    anchor: Offset(100, 186),
    kind: FxKind.segmented,
    markers: [
      FxMarker('arrive', 0, 36),
      FxMarker('idle', 36, 180),
      FxMarker('wiggle', 216, 29),
      FxMarker('open', 245, 45),
      FxMarker('open_idle', 290, 120),
    ],
    imageLayers: [
      FxImageLayer(
        keyPath: ['chest_closed'],
        slot: FxImageSlot.chestClosed,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(195, 325),
      ),
      FxImageLayer(
        keyPath: ['chest_open'],
        slot: FxImageSlot.chestOpen,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset(195, 325),
      ),
    ],
  ),
  // ui_intro_towers: 240 f (4000 ms), 302×230, loops.
  FxId.uiIntroTowers: FxSpec(
    id: FxId.uiIntroTowers,
    frames: 240,
    width: 302,
    height: 230,
    anchor: Offset.zero,
    kind: FxKind.inPlace,
    markers: [FxMarker('loop', 0, 240)],
    imageLayers: [
      FxImageLayer(
        keyPath: ['mover_lid'],
        slot: FxImageSlot.moverLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['mover_body'],
        slot: FxImageSlot.moverBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['revealed_lid'],
        slot: FxImageSlot.revealedLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['revealed_body'],
        slot: FxImageSlot.revealedBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['buried_silhouette'],
        slot: FxImageSlot.dollSilhouette,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    loops: true,
  ),
  // ui_intro_glass: 240 f (4000 ms), 302×230, loops.
  FxId.uiIntroGlass: FxSpec(
    id: FxId.uiIntroGlass,
    frames: 240,
    width: 302,
    height: 230,
    anchor: Offset.zero,
    kind: FxKind.inPlace,
    markers: [FxMarker('loop', 0, 240)],
    imageLayers: [
      FxImageLayer(
        keyPath: ['unlock_symbol'],
        slot: FxImageSlot.unlockSymbol,
        scale: Offset(0.2667, 0.2667),
        anchor: Offset(18, 18),
      ),
      FxImageLayer(
        keyPath: ['glass_case_0'],
        slot: FxImageSlot.glassCase0,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['glass_case_1'],
        slot: FxImageSlot.glassCase1,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['glass_case_2'],
        slot: FxImageSlot.glassCase2,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['freed_lid'],
        slot: FxImageSlot.freedLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['freed_body'],
        slot: FxImageSlot.freedBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['family_lid'],
        slot: FxImageSlot.familyLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['family_body'],
        slot: FxImageSlot.familyBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    loops: true,
  ),
  // ui_intro_ice: 300 f (5000 ms), 302×230, loops.
  FxId.uiIntroIce: FxSpec(
    id: FxId.uiIntroIce,
    frames: 300,
    width: 302,
    height: 230,
    anchor: Offset.zero,
    kind: FxKind.inPlace,
    markers: [FxMarker('loop', 0, 300)],
    imageLayers: [
      FxImageLayer(
        keyPath: ['ice_0'],
        slot: FxImageSlot.ice0,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_1'],
        slot: FxImageSlot.ice1,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['ice_shatter'],
        slot: FxImageSlot.iceShatter,
        scale: Offset(0.3333, 0.3333),
        anchor: Offset.zero,
      ),
      FxImageLayer(
        keyPath: ['freed_lid'],
        slot: FxImageSlot.freedLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['freed_body'],
        slot: FxImageSlot.freedBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['family_lid'],
        slot: FxImageSlot.familyLid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['family_body'],
        slot: FxImageSlot.familyBody,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['family_2_lid'],
        slot: FxImageSlot.family2Lid,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
      FxImageLayer(
        keyPath: ['family_2_body'],
        slot: FxImageSlot.family2Body,
        scale: Offset(0.1953, 0.1953),
        anchor: Offset(256, 742),
      ),
    ],
    loops: true,
  ),
};

/// The spec of [id]. Every [FxId] has one: the generator emits
/// one per LOTTIE.md file, and `fx_spec_drift_test` checks it.
FxSpec fxSpecOf(FxId id) => fxSpecs[id]!;
