import 'package:flame/game.dart';
import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/widgets.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_decor.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_render/nesty_render.dart';

export 'package:nesty_game/features/gameplay/game/components/slot_decor.dart'
    show BoardLabels;

/// What the Flame board tells the gameplay page (m2-lottie-design §7, §11;
/// `NestyGame`'s "page's side of the bridge").
@immutable
final class GameplayBoardCallbacks {
  const GameplayBoardCallbacks({
    required this.onIntent,
    required this.onLayout,
    required this.onFamilyLanded,
    required this.onWon,
    required this.onOutOfMoves,
  });

  /// A tap or drag the board accepted (`SlotTapped`, `SlotDragStarted`,
  /// `SlotDragDropped`): the page adds it to the bloc (CLAUDE.md rule 10).
  final void Function(GameplayEvent intent) onIntent;

  /// A new layout (a level, +1 Slot's re-pitch, a resize): the page
  /// prepares the level's art for it (`SkinService.prepareForLevel`) and
  /// hands it back through [GameplayBoard.levelSkin].
  final void Function(BoardGeometry geometry) onLayout;

  /// A completed set reached the family counter (§7 `Completed` at
  /// t0 + 1250): the HUD bumps `ui_family_counter` to [setsCompleted], with
  /// an `fx_sparkle` [sparkleScale]× the trail's over it (LOTTIE.md
  /// "Completed").
  final void Function(int setsCompleted, int totalSets, double sparkleScale)
  onFamilyLanded;

  /// The winning batch has played (+ 250 ms): the win overlay opens.
  final VoidCallback onWon;

  /// The board went idle with no legal move: the sheet of frame 3.5 opens.
  final VoidCallback onOutOfMoves;
}

/// The Flame board as the gameplay page drives it (m2-lottie-design §11
/// "Bridge", §16 lane "Screens"): the page owns one, built once, and feeds
/// it every bloc effect; the board renders nesty_core's state and never
/// owns game truth (CLAUDE.md rule 10). The seam lets page tests run on a
/// recording fake instead of Flame.
abstract interface class GameplayBoard {
  /// The board's widget, built once and kept for the page's life (inside a
  /// `RepaintBoundary`, so the HUD never repaints it). It fills the screen;
  /// the HUD and the booster bar sit over it.
  Widget get view;

  /// Whether the board reports [GameplayBoardCallbacks.onFamilyLanded],
  /// `onWon` and `onOutOfMoves` after playing each batch. When false (a
  /// board with no timeline) the page reacts to the bloc's state at once.
  bool get drivesOutcomes;

  /// Plays [effect] and settles on [board], the bloc's state after it (§7).
  void apply(BoardEffect effect, GameState board);

  /// The layout the board would give [state] on its screen now, or null
  /// before it is sized: the page prepares the next level's art for it
  /// while the win overlay is up (`NestyGame.layoutFor`).
  BoardGeometry? layoutFor(GameState state);

  /// The screen's safe areas: the board lays itself out between the HUD
  /// and the booster bar (`BoardViewport`).
  set padding(EdgeInsets padding);

  /// The level's art, for the layout last reported through `onLayout`.
  /// The board owns it from here and disposes the one it replaces
  /// (disposing is idempotent).
  set levelSkin(LevelSkin? skin);

  /// Reduced motion (§13, D48), from `MediaQuery.disableAnimationsOf`.
  set reduceMotion(bool reduce);

  /// The player's belly symbols, for placeholder dolls.
  set symbols(DollSymbols symbols);

  /// The board's localized "+N" tower tag and ice badge text and direction
  /// (ARB `boardTowerHidden`/`boardIceCount`, spec §16): the page passes
  /// `AppLocalizations.of(context)`'s two methods and
  /// `Directionality.of(context)`, wrapped in a [BoardLabels], at build and
  /// again on any dependency change that could mean a new locale (the same
  /// place it re-reads [reduceMotion]). Before the page's first hand-off
  /// (and in tests) the board shows `BoardLabels.fallback`'s English
  /// pattern.
  set boardLabels(BoardLabels labels);

  /// The legal drop targets of the lifted nest, `GameplayState.dropTargets`
  /// (core's `Rules.legalTargets`, computed by the bloc on the pick): the
  /// board glows the legal stand under a dragged doll (E.14). The page sets
  /// it with each effect it applies; the board never decides legality.
  set dropTargets(Set<String> targets);

  /// The pause dialog: time stops and every slot drops input.
  set paused(bool paused);

  /// An overlay or sheet is open (win, out of moves): input is dropped.
  set overlayOpen(bool open);

  /// True while a hint's arrow over the middle top-shelf stand rises into
  /// the family counter's place (frame 3.1b; tokens `layout.hintMiddle`;
  /// `SlotGeometry.hintNeedsCounter`): the HUD fades the counter out and
  /// back when the hint ends (phase 4 architecture §2.6 E.20, §6.6). The
  /// board drives it from the hint it plays.
  ValueListenable<bool> get familyCounterYield;
}

/// Builds the page's board with its callbacks and services.
typedef GameplayBoardFactory =
    GameplayBoard Function(
      GameplayBoardCallbacks callbacks, {
      required FxLibrary fx,
      required FeedbackSink feedback,
    });

/// The real board: the Flame [NestyGame] in a [GameWidget].
final class NestyGameBoard implements GameplayBoard {
  NestyGameBoard(
    GameplayBoardCallbacks callbacks, {
    required FxLibrary fx,
    required FeedbackSink feedback,
  }) : game = NestyGame(
         fx: fx,
         feedback: feedback,
         onIntent: callbacks.onIntent,
         onLayout: callbacks.onLayout,
         onFamilyLanded: callbacks.onFamilyLanded,
         onWon: (_) => callbacks.onWon(),
         onOutOfMoves: callbacks.onOutOfMoves,
       );

  final NestyGame game;

  // TODO(v1.1): the board has no screen-reader nodes (Flame adds none), so
  // a VoiceOver or TalkBack player can't pick a slot. The owner decides
  // whether that is v1 (M7 review R12, its PROGRESS question): a semantics
  // layer from the page's `BoardGeometry`, one node per slot labelled from
  // core's `GameState`, whose tap goes through the board's own input
  // policy, with Claude Design's copy for the colours and slot states.
  @override
  late final Widget view = RepaintBoundary(
    child: GameWidget<NestyGame>(game: game),
  );

  @override
  bool get drivesOutcomes => true;

  @override
  void apply(BoardEffect effect, GameState board) => game.apply(effect, board);

  @override
  BoardGeometry? layoutFor(GameState state) {
    final viewport = game.viewport;
    return viewport == null ? null : NestyGame.layoutFor(state, viewport);
  }

  @override
  set padding(EdgeInsets padding) => game.padding = padding;

  @override
  set levelSkin(LevelSkin? skin) => game.skin = skin;

  @override
  set reduceMotion(bool reduce) => game.reduceMotion = reduce;

  @override
  set symbols(DollSymbols symbols) => game.symbols = symbols;

  @override
  set boardLabels(BoardLabels labels) => game.boardLabels = labels;

  @override
  set paused(bool paused) {
    if (paused) {
      game.pauseEngine();
    } else {
      game.resumeEngine();
    }
  }

  @override
  set dropTargets(Set<String> targets) => game.dropTargets = targets;

  @override
  set overlayOpen(bool open) => game.overlayOpen = open;

  @override
  ValueListenable<bool> get familyCounterYield => game.familyCounterYield;
}
