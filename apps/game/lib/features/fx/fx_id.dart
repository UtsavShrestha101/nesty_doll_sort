/// Where a file is drawn (docs/plans/m2-lottie-design.md §2).
enum FxHost {
  /// Inside the Flame board, by `LottieFxComponent` over a `LottieDrawable`,
  /// so it sorts with the dolls, shelves and glow rings (z-order, pooling,
  /// same-frame sprite hand-off).
  board,

  /// A Flutter `Lottie` widget in the HUD, an overlay or a meta screen.
  widget,
}

/// The 29 Lottie files of `design/lottie/` (LOTTIE.md "Files"), shipped as
/// `apps/game/assets/lottie/<fileName>.json` (owner decision 2026-09-26:
/// every animation in the design ships as Lottie, PROGRESS D40).
///
/// LOTTIE.md says 28; the folder and its own table hold 29 (10 doll, 8 fx,
/// 11 ui). Declared in the LOTTIE.md table order. Timing, markers, canvas and
/// anchors live in each file's `FxSpec` (`fx_spec.gen.dart`, generated from
/// the JSON by `nesty_tools`), never here.
enum FxId {
  dollPick('doll_pick', FxHost.board),
  dollMove('doll_move', FxHost.board),
  dollNest('doll_nest', FxHost.board),
  dollSwallow('doll_swallow', FxHost.board),
  dollComplete('doll_complete', FxHost.board),
  dollInvalid('doll_invalid', FxHost.board),
  dollReveal('doll_reveal', FxHost.board),

  /// Splash and Home shelf dolls.
  dollIdle('doll_idle', FxHost.widget),

  /// Not played in M2: the board is empty at Won, and the families hop in
  /// the win overlay instead (App Flow 2.8; PROGRESS D47). Still shipped.
  dollWinDance('doll_win_dance', FxHost.widget),
  dollWinHop('doll_win_hop', FxHost.widget),
  fxSelectGlow('fx_select_glow', FxHost.board),

  /// One paused composition per locked slot (its rest look), played once on
  /// `Unlocked`.
  fxGlassUnlock('fx_glass_unlock', FxHost.board),

  /// One paused composition per iced slot (its rest look), with a segment
  /// per crack stage and the shatter.
  fxIce('fx_ice', FxHost.board),
  fxDustPuff('fx_dust_puff', FxHost.board),

  /// The completion's sparkle trail on the board; also the 1.5× burst over
  /// the HUD's family counter when a family lands (LOTTIE.md "Completed"),
  /// drawn there by a `LottieFxView`.
  fxSparkle('fx_sparkle', FxHost.board),
  fxConfetti('fx_confetti', FxHost.widget),
  fxCoinBurst('fx_coin_burst', FxHost.widget),
  fxTwinkle('fx_twinkle', FxHost.widget),
  uiFamilyCounter('ui_family_counter', FxHost.widget),
  uiHintArrow('ui_hint_arrow', FxHost.board),
  uiExtraSlot('ui_extra_slot', FxHost.board),
  uiBoosterGlow('ui_booster_glow', FxHost.widget),
  uiWinRibbon('ui_win_ribbon', FxHost.widget),
  uiChapterRibbon('ui_chapter_ribbon', FxHost.widget),
  uiToggle('ui_toggle', FxHost.widget),

  /// Skin downloading (frame 7.5), M3.
  uiSpinner('ui_spinner', FxHost.widget),
  uiSplashLoader('ui_splash_loader', FxHost.widget),

  /// Level 1 tutorial (frames 1.3, 1.4), M3.
  uiTapHand('ui_tap_hand', FxHost.widget),

  /// Level 2 tutorial (frame 1.6), M3. Board space, but drawn above the
  /// tutorial scrim, so it is a widget placed through `BoardFit`.
  uiDragHand('ui_drag_hand', FxHost.widget);

  const FxId(this.fileName, this.host);

  /// The folder every file ships in (`sync_design_assets` writes it; it is
  /// declared in `apps/game/pubspec.yaml`).
  static const assetDirectory = 'assets/lottie';

  /// The file name without `.json`, exactly as in `design/lottie/`.
  final String fileName;

  final FxHost host;

  /// The bundle key `FxLibrary` loads with `rootBundle.load`.
  String get assetPath => '$assetDirectory/$fileName.json';

  /// The id whose [fileName] is [name], or null.
  static FxId? fromFileName(String name) {
    for (final id in values) {
      if (id.fileName == name) return id;
    }
    return null;
  }
}
