import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nesty_core/nesty_core.dart' show GameState;
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/widgets/retry_view.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/win_overlay.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_board.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/level_skin_loader.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/chapter_ribbon.dart';
import 'package:nesty_game/features/gameplay/widgets/family_counter.dart';
import 'package:nesty_game/features/gameplay/widgets/gameplay_hud.dart';
import 'package:nesty_game/features/gameplay/widgets/soft_stuck_banner.dart';
import 'package:nesty_game/features/gameplay/widgets/theme_background_view.dart';
import 'package:nesty_render/nesty_render.dart';

/// Which overlay covers the board (frames 2.8, 3.5, 3.9, 4.9).
enum GameplayOverlay { none, pause, win, outOfMoves, allLevelsDone }

/// The gameplay screen (frame 2.2; spec §10.2 #3; m2-lottie-design §11,
/// §16 lane "Screens"), bottom to top:
/// - the chapter's theme background;
/// - the Flame board, built once and fed every bloc effect
///   (`BlocListener` on `effectSeq` → [GameplayBoard.apply]);
/// - the HUD at the safe-area top, the booster bar at the bottom, the
///   soft-stuck banner (3.4) and the new-chapter ribbon (4.7, L21);
/// - the overlays: win (2.8), out of moves (3.5), pause (3.9) and all
///   levels done (4.9).
///
/// It owns no game truth (CLAUDE.md rule 10): the bloc decides, the board
/// plays, and this page times the overlays on the board's reports (the
/// family counter bumps when a family lands, the win overlay opens when the
/// winning batch has played). It prepares the level's art for every layout
/// the board reports (`SkinService.prepareForLevel`: a level, behind the
/// route transition; +1 Slot's re-pitch; a resize), and the next level's
/// while the win overlay is up, so Continue shows it with its own art from
/// its first frame; and it passes the safe areas, reduced motion (D48) and
/// the symbols mode to the board.
class GameplayView extends StatefulWidget {
  const GameplayView({
    required this.levelNumber,
    required this.services,
    required this.onHome,
    this.boardFactory = NestyGameBoard.new,
    super.key,
  });

  /// The level the route opened (1-based play order): the retry target.
  final int levelNumber;
  final GameplayServices services;

  /// Leaves for Home (pause 3.9, all levels done 4.9).
  final VoidCallback onHome;

  /// Builds the board; tests pass a recording fake.
  final GameplayBoardFactory boardFactory;

  /// Continue waits at most this long for the next level's art (rule 3: a
  /// stuck rasterization never blocks the game; the board then shows the
  /// level with the art it has until the new one lands).
  static const Duration nextArtWait = Duration(seconds: 2);

  @override
  State<GameplayView> createState() => _GameplayViewState();
}

class _GameplayViewState extends State<GameplayView> {
  late final GameplayBoard _board = widget.boardFactory(
    GameplayBoardCallbacks(
      onIntent: _onIntent,
      onLayout: _onLayout,
      onFamilyLanded: _onFamilyLanded,
      onWon: _onBoardWon,
      onOutOfMoves: _onBoardOutOfMoves,
    ),
    fx: widget.services.fx,
    feedback: widget.services.feedback,
  );

  late final LevelSkinLoader _skins = LevelSkinLoader(
    widget.services.skins,
    onReady: _onSkinReady,
  );

  late final AppLifecycleListener _lifecycle;

  GameplayOverlay _overlay = GameplayOverlay.none;
  int _appliedEffectSeq = 0;
  ChapterProgress? _chapter;
  bool _showRibbon = false;
  int _setsShown = 0;

  /// The sparkle over the counter when a family lands (LOTTIE.md
  /// "Completed": 1.5× the trail's), as the board reports it.
  double _counterSparkleScale = FamilyCounter.defaultSparkleScale;

  WinSummary? _win;
  bool _continuing = false;
  PauseSettings? _settings;

  /// The next level's art, prepared while the win overlay is up; Continue
  /// waits for it so the level never shows with this level's skin
  /// (review CORRECTNESS-1).
  Future<void>? _nextArt;

  /// The `moveSeq` the out-of-moves sheet last opened for: a dismissed
  /// sheet stays closed until another move runs out again.
  int? _outOfMovesSeq;
  double _devicePixelRatio = 1;

  GameplayBloc get _bloc => context.read<GameplayBloc>();
  GameplayState? get _state => _bloc.state.data;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onHide: _onAppHidden);
    // The bloc may have loaded before this listened: play what it has.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onBlocState(context, _bloc.state);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    // The board lays itself out between the HUD and the bar, and reports
    // each new layout (onLayout).
    _board
      ..padding = MediaQuery.paddingOf(context)
      ..reduceMotion = context.reduceMotion
      ..symbols = widget.services.database.symbolsMode.dollSymbols;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    // The board disposes its own skin with the game (idempotent).
    _skins.dispose();
    super.dispose();
  }

  // --- The bloc --------------------------------------------------------

  void _onBlocState(BuildContext context, AsyncValue<GameplayState> value) {
    final state = value.data;
    if (state == null) return;
    if (state.effectSeq != _appliedEffectSeq) {
      _appliedEffectSeq = state.effectSeq;
      final effect = state.effect;
      if (effect != null) _applyEffect(effect, state);
    }
    _syncOutcome(state);
  }

  void _applyEffect(BoardEffect effect, GameplayState state) {
    if (effect case BoardResetEffect(reason: BoardResetReason.start)) {
      _startLevel(state);
    }
    if (effect is BoardResetEffect) {
      // Undo, restart and a new level show their own count at once.
      setState(() => _setsShown = state.setsCompleted);
    } else if (!_board.drivesOutcomes && effect is MoveAppliedEffect) {
      setState(() => _setsShown = state.setsCompleted);
    }
    _board.apply(effect, state.board);
  }

  /// A new level (the route's, or Continue's): its chapter, a fresh
  /// counter, and every overlay closed. Its art follows the board's layout.
  void _startLevel(GameplayState state) {
    final entry = state.entry;
    final chapter = ChapterProgress.of(entry, widget.services.levels);
    setState(() {
      _chapter = chapter;
      _showRibbon = chapter.opensWithRibbon;
      _win = null;
      _continuing = false;
      if (_overlay != GameplayOverlay.pause) _overlay = GameplayOverlay.none;
    });
    _board.overlayOpen = false;
  }

  /// Opens the outcome overlays the bloc's state calls for, when the board
  /// doesn't report them itself (a board with no timeline), and All Levels
  /// Done in any case.
  void _syncOutcome(GameplayState state) {
    if (state.status == GameplayStatus.allLevelsDone) {
      if (_overlay != GameplayOverlay.allLevelsDone) {
        _board.overlayOpen = true;
        setState(() => _overlay = GameplayOverlay.allLevelsDone);
      }
      return;
    }
    if (_board.drivesOutcomes) return;
    switch (state.status) {
      case GameplayStatus.won when _win == null:
        _openWin(state);
      case GameplayStatus.outOfMoves
          when _overlay == GameplayOverlay.none &&
              _outOfMovesSeq != state.moveSeq:
        _openOutOfMoves(state);
      case GameplayStatus.playing ||
          GameplayStatus.won ||
          GameplayStatus.outOfMoves ||
          GameplayStatus.allLevelsDone:
        break;
    }
  }

  /// The board laid a level out ([geometry]): rasterize its art for it.
  void _onLayout(BoardGeometry geometry) {
    final state = _state;
    if (!mounted || state == null) return;
    unawaited(
      _skins.prepare(
        state.entry.level,
        geometry: geometry,
        devicePixelRatio: _devicePixelRatio,
        symbols: widget.services.database.symbolsMode.dollSymbols,
      ),
    );
  }

  void _onSkinReady(LevelSkin skin) {
    _board.levelSkin = skin;
    // The win overlay's hopping families use the same rasters.
    if (mounted) setState(() {});
  }

  // --- The board's reports ----------------------------------------------

  void _onIntent(GameplayEvent intent) => _bloc.add(intent);

  void _onFamilyLanded(int setsCompleted, int totalSets, double sparkleScale) {
    if (!mounted) return;
    setState(() {
      _setsShown = setsCompleted;
      _counterSparkleScale = sparkleScale;
    });
  }

  void _onBoardWon() {
    final state = _state;
    if (!mounted || state == null || state.status != GameplayStatus.won) {
      return;
    }
    _openWin(state);
  }

  void _onBoardOutOfMoves() {
    final state = _state;
    if (!mounted ||
        state == null ||
        state.status != GameplayStatus.outOfMoves ||
        _overlay != GameplayOverlay.none) {
      return;
    }
    _openOutOfMoves(state);
  }

  // --- Overlays ---------------------------------------------------------

  void _openWin(GameplayState state) {
    final chapter =
        _chapter ?? ChapterProgress.of(state.entry, widget.services.levels);
    _board.overlayOpen = true;
    setState(() {
      _setsShown = state.totalSets;
      _win = WinSummary(
        reward: state.winReward,
        families: WinSummary.familiesOf(state.entry.level, state.board),
        chapter: chapter,
      );
      _overlay = GameplayOverlay.win;
    });
    _prefetchNextLevel(state);
  }

  /// Rasterizes the next level's art for the layout the board will give it,
  /// while the win overlay is up and the board is idle. The layout the
  /// board reports for that level then adopts it in the same frame, so its
  /// first frame draws its own dolls: the previous level's skin holds only
  /// its own colours (review CORRECTNESS-1).
  void _prefetchNextLevel(GameplayState state) {
    // The bloc's `NextLevelPressed` asks the same repository for the same
    // order, so both get the same entry.
    final next = widget.services.levels.entryAt(state.levelNumber + 1);
    // TODO(M3): Bonus Endless past the last level prefetches the bonus
    // level (spec §7.1); All Levels Done needs no board art.
    if (next == null) return;
    final geometry = _board.layoutFor(GameState.initial(next.level));
    if (geometry == null) return;
    _nextArt = _skins.prefetch(
      next.level,
      geometry: geometry,
      devicePixelRatio: _devicePixelRatio,
      symbols: widget.services.database.symbolsMode.dollSymbols,
    );
  }

  void _openOutOfMoves(GameplayState state) {
    _outOfMovesSeq = state.moveSeq;
    _board.overlayOpen = true;
    setState(() => _overlay = GameplayOverlay.outOfMoves);
  }

  void _closeOverlay() {
    _board.overlayOpen = false;
    setState(() => _overlay = GameplayOverlay.none);
  }

  void _openPause() {
    final state = _state;
    if (state == null ||
        _overlay != GameplayOverlay.none ||
        !state.acceptsInput) {
      return;
    }
    final database = widget.services.database;
    _bloc.add(const PauseChanged(paused: true));
    _board.paused = true;
    setState(() {
      _settings = PauseSettings(
        sound: database.soundEnabled,
        music: database.musicEnabled,
        haptics: database.hapticsEnabled,
      );
      _overlay = GameplayOverlay.pause;
    });
  }

  void _resume() {
    if (_overlay != GameplayOverlay.pause) return;
    _bloc.add(const PauseChanged(paused: false));
    _board.paused = false;
    setState(() => _overlay = GameplayOverlay.none);
  }

  void _restartFromPause() {
    _resume();
    _bloc.add(const RestartPressed());
  }

  void _setSetting(PauseSettings next, Future<void> Function() write) {
    setState(() => _settings = next);
    unawaited(
      write().catchError((Object error, StackTrace stack) {
        // Rule 3: a setting that fails to save holds for this session.
        developer.log(
          'a setting failed to save',
          name: 'nesty.gameplay',
          error: error,
          stackTrace: stack,
        );
        if (kDebugMode) debugPrint('[nesty.gameplay] setting failed: $error');
      }),
    );
  }

  void _onAppHidden() {
    // The player left mid-level: come back to the pause dialog.
    if (mounted && _overlay == GameplayOverlay.none) _openPause();
  }

  void _onBack() {
    switch (_overlay) {
      case GameplayOverlay.none:
        _openPause();
      case GameplayOverlay.pause:
        _resume();
      case GameplayOverlay.outOfMoves:
        _closeOverlay();
      case GameplayOverlay.win || GameplayOverlay.allLevelsDone:
        break;
    }
  }

  Future<void> _continue() async {
    if (_continuing) return;
    setState(() => _continuing = true);
    // The overlay stays up until the next level's art has landed (almost
    // always already: it started when the overlay opened).
    final art = _nextArt;
    _nextArt = null;
    if (art != null) {
      await art.timeout(GameplayView.nextArtWait, onTimeout: () {});
    }
    if (!mounted) return;
    _bloc.add(const NextLevelPressed());
  }

  // --- Build ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: BlocConsumer<GameplayBloc, AsyncValue<GameplayState>>(
        listener: _onBlocState,
        builder: (context, value) {
          final state = value.data;
          final theme = _chapter?.theme ?? ChapterTheme.ch01;
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: theme.fallbackColor,
            body: Stack(
              fit: StackFit.expand,
              children: [
                ThemeBackgroundView(
                  theme: theme,
                  background: widget.services.skins.background,
                ),
                // Built once: the same widget every build, so the game is
                // never rebuilt with the HUD.
                _board.view,
                if (state != null) ..._chrome(context, state),
                if (state == null && value is AsyncValueError<GameplayState>)
                  Center(
                    child: RetryView(
                      exception: value.exception,
                      onRetry: () =>
                          _bloc.add(GameplayStarted(widget.levelNumber)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _chrome(BuildContext context, GameplayState state) {
    final services = widget.services;
    final padding = MediaQuery.paddingOf(context);
    final width = MediaQuery.sizeOf(context).width;
    final overlay = _overlay;
    final skin = _skins.current;
    final chapter = _chapter;
    final symbols = services.database.symbolsMode.dollSymbols;
    final bloc = _bloc;
    final ribbonWidth = math.min(ChapterRibbon.canvas.width, width - 16);
    final ribbonHeight =
        ribbonWidth * ChapterRibbon.canvas.height / ChapterRibbon.canvas.width;
    // Won: input is locked for the winning batch (~2.4 s) and the win
    // overlay, but the chrome keeps its look (frame 2.5 draws it at full
    // strength while the set flies) and only swallows touches, instead of
    // flashing disabled before the scrim dims it (review FIDELITY-2).
    final won = state.status == GameplayStatus.won;
    // The bloc pays the reward at Won, so the save's balance already holds
    // it. Frames 1.5 and 2.8 keep the HUD at the old balance while the set
    // flies and the overlay counts "+N" up, so it holds from Won until the
    // next level starts (Q57).
    final hudCoins = won
        ? math.max(0, state.coins - state.winReward)
        : state.coins;
    return [
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        child: GameplayHud(
          level: state.levelNumber,
          tier: state.entry.tier,
          coins: hudCoins,
          setsDone: math.min(_setsShown, state.totalSets),
          setsTotal: state.totalSets,
          sparkleScale: _counterSparkleScale,
          library: services.fx,
          onPause:
              won || (overlay == GameplayOverlay.none && state.acceptsInput)
              ? _openPause
              : null,
          locked: won,
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: BoosterBar(
          model: BoosterBarModel.of(state),
          library: services.fx,
          onUndo: () => bloc.add(const UndoPressed()),
          onHint: () => bloc.add(const HintPressed()),
          onExtraSlot: () => bloc.add(const ExtraSlotPressed()),
          onRestart: () => bloc.add(const RestartPressed()),
        ),
      ),
      Positioned(
        left: SoftStuckBanner.side,
        right: SoftStuckBanner.side,
        top: padding.top + SoftStuckBanner.top,
        child: SoftStuckBanner(
          visible:
              state.softStuck &&
              state.status == GameplayStatus.playing &&
              overlay == GameplayOverlay.none,
          onUndo: state.canUndo && state.acceptsInput
              ? () => bloc.add(const UndoPressed())
              : null,
          // Nothing to undo (a completing move cleared the history, spec
          // §2.4, or the free undos are spent): Restart, always free, is
          // the way out it suggests instead (review FIDELITY-6).
          onRestart: state.acceptsInput
              ? () => bloc.add(const RestartPressed())
              : null,
        ),
      ),
      if (_showRibbon && chapter != null)
        Positioned(
          left: (width - ribbonWidth) / 2,
          top: padding.top + ChapterRibbon.centerTop - ribbonHeight / 2,
          width: ribbonWidth,
          height: ribbonHeight,
          child: ChapterRibbon(
            key: ValueKey(state.levelNumber),
            number: chapter.number,
            chapterId: chapter.chapterId,
            library: services.fx,
            onDone: () => setState(() => _showRibbon = false),
          ),
        ),
      if (overlay == GameplayOverlay.outOfMoves)
        Positioned.fill(
          child: OutOfMovesSheet(
            freeUndosLeft: state.freeUndosLeft,
            showFreeUndos: !state.unlimitedBoosters,
            onUndo: state.canUndo
                ? () {
                    _closeOverlay();
                    bloc.add(const UndoPressed());
                  }
                : null,
            onExtraSlot: state.canAddSlot
                ? () {
                    _closeOverlay();
                    bloc.add(const ExtraSlotPressed());
                  }
                : null,
            onRestart: () {
              _closeOverlay();
              bloc.add(const RestartPressed());
            },
            onDismiss: _closeOverlay,
          ),
        ),
      if (overlay == GameplayOverlay.win && _win != null)
        Positioned.fill(
          child: WinOverlay(
            key: ValueKey(state.levelNumber),
            summary: _win!,
            images: skin?.images,
            renderer: skin?.restRenderer,
            symbols: symbols,
            feedback: services.feedback,
            library: services.fx,
            onContinue: _continuing ? () {} : _continue,
          ),
        ),
      if (overlay == GameplayOverlay.pause && _settings != null)
        Positioned.fill(
          child: PauseDialog(
            level: state.levelNumber,
            tier: state.entry.tier,
            settings: _settings!,
            library: services.fx,
            onSoundChanged: (on) => _setSetting(
              _settings!.copyWith(sound: on),
              () => services.database.setSoundEnabled(on),
            ),
            onMusicChanged: (on) => _setSetting(
              _settings!.copyWith(music: on),
              () => services.database.setMusicEnabled(on),
            ),
            onHapticsChanged: (on) => _setSetting(
              _settings!.copyWith(haptics: on),
              () => services.database.setHapticsEnabled(on),
            ),
            onResume: _resume,
            onRestart: _restartFromPause,
            onHome: widget.onHome,
          ),
        ),
      if (overlay == GameplayOverlay.allLevelsDone)
        Positioned.fill(
          child: AllLevelsDone(
            families: WinSummary.familiesOf(state.entry.level, state.board),
            images: skin?.images,
            renderer: skin?.restRenderer,
            symbols: symbols,
            library: services.fx,
            onHome: widget.onHome,
          ),
        ),
    ];
  }
}
