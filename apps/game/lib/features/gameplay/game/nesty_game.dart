import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:lottie/lottie.dart' show LottieComposition;
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_game/features/gameplay/game/components/board_component.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

export 'package:nesty_game/features/gameplay/game/components/board_component.dart'
    show FamilyLandedCallback;

/// The Flame host of the board (spec §13.1; docs/plans/m2-lottie-design.md
/// §2, §16 "Flame board"). Menus, the HUD, the booster bar and the overlays
/// are Flutter widgets around the `GameWidget`; this only draws the shelves,
/// slots, dolls and board clips, and forwards input.
///
/// **The page's side of the bridge** (no flame_bloc):
/// - Build it once per page (never in `build`) with the DI [FxLibrary], a
///   `ServiceFeedbackSink(audio:, haptics:)` and `onIntent: bloc.add`. The
///   `GameWidget` fills the screen (the HUD and booster bar sit over it) and
///   the page sets [padding] to `MediaQuery.paddingOf(context)`: the board
///   lays itself out between the HUD and the bar (`BoardViewport`).
/// - `BlocListener(listenWhen: effectSeq changed)` → [apply] with
///   `state.effect!` and `state.board`; also apply the state's current
///   effect once when the game is first shown (the `BoardResetEffect` of
///   `GameplayStarted`). Effects are scheduled in order in the next tick.
/// - [onLayout] reports every new layout (every new level, even one shaped
///   like the last; +1 Slot; a resize): the page calls
///   `SkinService.prepareForLevel(level, geometry:, …)` and hands the result
///   to [skin]; the game owns it from then on and disposes the one it
///   replaces. Until a skin arrives dolls draw with the placeholder painter
///   and the board with flat shapes (rule 3). [layoutFor] on [viewport]
///   computes the same geometry ahead of time.
/// - [onFamilyLanded] bumps the HUD's family counter, [onWon] opens the win
///   overlay, [onOutOfMoves] the sheet; set [overlayOpen] while one is up.
/// - The pause dialog calls `pauseEngine()` / `resumeEngine()` (or sets
///   [paused]): time stands still and input is dropped.
/// - [reduceMotion] from `MediaQuery.disableAnimationsOf` (§13).
class NestyGame extends FlameGame {
  NestyGame({
    FxLibrary? fx,
    FeedbackSink? feedback,
    void Function(GameplayEvent intent)? onIntent,
    FamilyLandedCallback? onFamilyLanded,
    VoidCallback? onBoardIdle,
    void Function(int moveCount)? onWon,
    VoidCallback? onOutOfMoves,
    void Function(BoardGeometry geometry)? onLayout,
    EdgeInsets padding = EdgeInsets.zero,
    bool reduceMotion = false,
    DollSymbols symbols = DollSymbols.subtle,
    ComboTracker? combo,
  }) : _padding = padding,
       board = BoardComponent(
         library: fx ?? _NoFx(),
         feedback: feedback ?? const _Silent(),
         onIntent: onIntent,
         onFamilyLanded: onFamilyLanded,
         onBoardIdle: onBoardIdle,
         onWon: onWon,
         onOutOfMoves: onOutOfMoves,
         onLayout: onLayout,
         combo: combo,
       ) {
    board
      ..motion = MotionSpec.of(reduceMotion: reduceMotion)
      ..symbols = symbols;
  }

  /// The board (for the page's debug tools and tests).
  final BoardComponent board;

  EdgeInsets _padding;

  /// The laid-out board of [state] on [viewport]: what the game will show,
  /// for preparing its skin ahead of time.
  static BoardGeometry layoutFor(GameState state, BoardViewport viewport) =>
      boardGeometryOf(state, viewport);

  /// Transparent, so the chapter background behind the `GameWidget` shows
  /// through the shelves.
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    // World units are logical px from the canvas's top-left.
    camera.viewfinder.anchor = Anchor.topLeft;
    await world.add(board);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    board.layOut(size.x, size.y, padding: _padding);
  }

  /// Plays [effect] (the bloc's latest) and settles on [state], the board
  /// after it (m2-lottie-design §7, §11). Scheduled in the next tick.
  void apply(BoardEffect effect, GameState state) => board.apply(effect, state);

  /// The screen's safe areas (`MediaQuery.paddingOf`).
  EdgeInsets get padding => _padding;
  set padding(EdgeInsets value) {
    if (value == _padding) return;
    _padding = value;
    if (hasLayout) board.layOut(size.x, size.y, padding: value);
  }

  /// The committed layout, once a level is on the board.
  BoardGeometry? get geometry => board.geometry;

  /// The screen the board lays itself out on, once the game is sized. With
  /// [layoutFor] the page can prepare a level's art before showing it.
  BoardViewport? get viewport => board.viewport;

  /// The level's art; owned by the game from here (a new one disposes the
  /// old one).
  LevelSkin? get skin => board.skin;
  set skin(LevelSkin? value) => board.skin = value;

  /// Reduced motion (§13, D48): new batches play at half duration, without
  /// shakes, wobble or confetti.
  set reduceMotion(bool value) =>
      board.motion = MotionSpec.of(reduceMotion: value);

  /// The belly symbols of placeholder dolls (settings `symbols`).
  set symbols(DollSymbols value) => board.symbols = value;

  /// An overlay or sheet is up: the board drops input.
  bool get overlayOpen => board.overlayOpen;
  set overlayOpen(bool value) => board.overlayOpen = value;

  // The pause dialog pauses the engine: the board locks input and its
  // timeline stops too (§7 "Global lock").

  @override
  set paused(bool value) {
    super.paused = value;
    board.paused = value;
  }

  @override
  void pauseEngine() {
    super.pauseEngine();
    board.paused = true;
  }

  @override
  void resumeEngine() {
    super.resumeEngine();
    board.paused = false;
  }

  /// The `GameWidget` was disposed: the level's skin and the pools go.
  @override
  void onDispose() {
    board.dispose();
    super.onDispose();
  }
}

/// No compositions: every clip is skipped and the rest poses show (rule 3).
final class _NoFx implements FxLibrary {
  @override
  Future<void> load({void Function(double progress)? onProgress}) async =>
      onProgress?.call(1);

  @override
  bool get isLoaded => true;

  @override
  LottieComposition? operator [](FxId id) => null;

  @override
  Set<FxId> get failed => const {};

  @override
  Image? get blank => null;
}

/// No sounds, no haptics.
final class _Silent implements FeedbackSink {
  const _Silent();

  @override
  void play(FxCue cue) {}
}
