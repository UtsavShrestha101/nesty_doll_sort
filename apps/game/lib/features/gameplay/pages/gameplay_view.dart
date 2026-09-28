import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nesty_core/nesty_core.dart' show GameState;
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/music/music_duck.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/overlays/booster_buy_popup.dart';
import 'package:nesty_game/features/gameplay/overlays/chapter_complete_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/intro_mechanic_card.dart';
import 'package:nesty_game/features/gameplay/overlays/next_level_failed_card.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/tutorial_overlay.dart';
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

/// Which page-timed overlay covers the board (frames 2.8, 3.5, 3.9, 4.6,
/// 4.9); the booster popup, the tutorial overlay and the intro card are
/// drawn straight from the bloc's `offer`/`tutorial`/`intro` fields instead,
/// since they need no page-side sequencing.
enum GameplayOverlay {
  none,
  pause,
  win,
  outOfMoves,
  chapterComplete,
  allLevelsDone,

  /// Continue's next level couldn't be made (review CORRECTNESS-3).
  continueFailed,
}

/// The gameplay screen (frame 2.2; spec §10.2 #3; m2-lottie-design §11,
/// §16 lane "Screens"), bottom to top:
/// - the chapter's theme background;
/// - the Flame board, built once and fed every bloc effect
///   (`BlocListener` on `effectSeq` → [GameplayBoard.apply]);
/// - the HUD at the safe-area top, the booster bar at the bottom, the
///   soft-stuck banner (3.4) and the new-chapter ribbon (4.7, L21);
/// - the overlays: win (2.8), out of moves (3.5), pause (3.9), all levels
///   done (4.9), and the retry card of a Continue whose next level
///   couldn't be made.
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
    required this.request,
    required this.services,
    required this.onHome,
    required this.onSettings,
    this.boardFactory = NestyGameBoard.new,
    super.key,
  });

  /// What the route opened (docs/plans/m3-design.md §6): the retry target.
  final PlayRequest request;
  final GameplayServices services;

  /// Leaves for Home (pause 3.9, all levels done 4.9).
  final VoidCallback onHome;

  /// Opens Settings over the level (pause 3.9's Settings tile); completes
  /// when the player is back.
  final Future<void> Function() onSettings;

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

  /// Why the last Continue's next level couldn't be made, while
  /// [GameplayOverlay.continueFailed] shows it (review CORRECTNESS-3).
  AppException? _continueFailure;
  PauseSettings? _settings;

  /// The next level's art, prepared while the win overlay is up; Continue
  /// waits for it so the level never shows with this level's skin
  /// (review CORRECTNESS-1).
  Future<void>? _nextArt;

  /// The `moveSeq` the out-of-moves sheet last opened for: a dismissed
  /// sheet stays closed until another move runs out again.
  int? _outOfMovesSeq;
  double _devicePixelRatio = 1;

  /// The Color symbols mode the board and the level's art were given.
  DollSymbols _symbols = DollSymbols.subtle;

  /// The board's current layout, for the tutorial overlay's holes (it draws
  /// from the same geometry the board just laid its dolls out on).
  BoardGeometry? _geometry;

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
    _symbols = widget.services.database.symbolsMode.dollSymbols;
    _board
      ..padding = MediaQuery.paddingOf(context)
      ..reduceMotion = context.reduceMotion
      ..symbols = _symbols;
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
    if (value case AsyncValueError<GameplayState>(:final exception)) {
      _onContinueFailed(exception);
    }
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
    // A restored board that was already out of moves or won (review
    // CORRECTNESS-1) plays no batch, so the board never reports it: open
    // its overlay now, as `_syncOutcome` would for a board with no
    // timeline (it then finds it open and does nothing).
    if (effect case BoardResetEffect(reason: BoardResetReason.start)) {
      switch (state.status) {
        case GameplayStatus.won:
          _openWin(state);
        // TODO(M7): a restored board whose intro card was never dismissed
        // shows the card over this sheet, whose rows then wait for "Got it".
        case GameplayStatus.outOfMoves when _overlay == GameplayOverlay.none:
          _openOutOfMoves(state);
        case GameplayStatus.playing ||
            GameplayStatus.outOfMoves ||
            GameplayStatus.allLevelsDone:
          break;
      }
    }
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
      _continueFailure = null;
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

  /// The board laid a level out ([geometry]): rasterize its art for it and
  /// keep it for the tutorial overlay's holes.
  void _onLayout(BoardGeometry geometry) {
    final state = _state;
    if (!mounted || state == null) return;
    setState(() => _geometry = geometry);
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
        dailyStreak: state.dailyStreak,
      );
      _overlay = GameplayOverlay.win;
    });
    unawaited(_prefetchNextLevel(state));
  }

  /// Rasterizes the next level's art for the layout the board will give it,
  /// while the win overlay is up and the board is idle, from whatever
  /// `nextRequest` is: the next campaign level, a generated Bonus Endless
  /// level (already prefetching in `LevelResolver`, so this resolves at
  /// once) or nothing after a daily (m3-design §10.8; the resolver never
  /// throws, rule 3). The layout the board reports for that level then
  /// adopts it in the same frame, so its first frame draws its own dolls:
  /// the previous level's skin holds only its own colours (review
  /// CORRECTNESS-1).
  Future<void> _prefetchNextLevel(GameplayState state) async {
    final nextRequest = state.nextRequest;
    if (nextRequest == null) return;
    final next = await widget.services.resolver.resolve(nextRequest);
    if (next == null || !mounted) return;
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
    _bloc.add(const PauseChanged(paused: true));
    _board.paused = true;
    setState(() {
      _settings = _readPauseSettings();
      _overlay = GameplayOverlay.pause;
    });
  }

  /// The pause dialog's toggles as the settings store has them now.
  PauseSettings _readPauseSettings() {
    final database = widget.services.database;
    return PauseSettings(
      sound: database.soundEnabled,
      music: database.musicEnabled,
      haptics: database.hapticsEnabled,
    );
  }

  /// Pause's Settings tile (frame 3.9): Settings opens over the level and
  /// writes the same settings (review CORRECTNESS-4). Back here, the
  /// dialog shows them as they are now, and the board takes the Color
  /// symbols mode, re-preparing the level's art, which bakes the symbols
  /// in (`SkinService.prepareForLevel`), when it changed.
  Future<void> _openSettings() async {
    await widget.onSettings();
    if (!mounted) return;
    final symbols = widget.services.database.symbolsMode.dollSymbols;
    final changed = symbols != _symbols;
    _symbols = symbols;
    _board.symbols = symbols;
    setState(() {
      if (_overlay == GameplayOverlay.pause) _settings = _readPauseSettings();
    });
    final state = _state;
    final geometry = _geometry;
    if (!changed || state == null || geometry == null) return;
    await _skins.prepare(
      state.entry.level,
      geometry: geometry,
      devicePixelRatio: _devicePixelRatio,
      symbols: symbols,
    );
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
      case GameplayOverlay.win ||
          GameplayOverlay.chapterComplete ||
          GameplayOverlay.allLevelsDone:
        break;
      // The failure card's way out (review CORRECTNESS-3).
      case GameplayOverlay.continueFailed:
        widget.onHome();
    }
  }

  /// The win overlay's Continue (m3-design §8.4, §9.3): back to Daily after
  /// a daily win (it has no `nextRequest`, spec §7.5); Chapter complete
  /// (4.6) after a win that completed one; the next level otherwise.
  void _onWinContinue(GameplayState state) {
    if (_continuing) return;
    if (state.dailyStreak != null) {
      _backToDaily();
      return;
    }
    if (state.completedChapterId != null) {
      _openChapterComplete();
      return;
    }
    unawaited(_continue());
  }

  /// Frame 5.4's "Back to Daily": pops back to the Daily route it was
  /// pushed from (`DailyPage._playDaily`), never `NextLevelPressed` (the
  /// daily has no next, spec §7.5). `pop`, not `maybePop`: this page's own
  /// `PopScope` vetoes a `maybePop` (it turns system back into Pause).
  void _backToDaily() {
    setState(() => _continuing = true);
    context.router.pop();
  }

  /// Chapter complete (frame 4.6, m3-design §9.3): the music fades out for
  /// `jingle_chapter` as it opens; its own Continue plays `music_game`
  /// again and resolves `nextRequest` like a normal win.
  void _openChapterComplete() {
    widget.services.jingleCues.chapterComplete();
    setState(() => _overlay = GameplayOverlay.chapterComplete);
  }

  void _continueFromChapterComplete() {
    if (_continuing) return;
    widget.services.music.playGame();
    unawaited(_continue());
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

  /// Continue asked for a level that couldn't be made (review
  /// CORRECTNESS-3): the bloc keeps the won state and emits the error, so
  /// the win or Chapter-complete overlay would stay up with its Continue
  /// spent. The failure card replaces it instead, with Try again and Back
  /// to Home. An error with no Continue in flight is the route's own
  /// (the page's [RetryView]) or one the bloc recovers from itself.
  void _onContinueFailed(AppException exception) {
    final continuingFrom = switch (_overlay) {
      GameplayOverlay.win ||
      GameplayOverlay.chapterComplete ||
      GameplayOverlay.continueFailed => true,
      GameplayOverlay.none ||
      GameplayOverlay.pause ||
      GameplayOverlay.outOfMoves ||
      GameplayOverlay.allLevelsDone => false,
    };
    if (!_continuing || !continuingFrom) return;
    setState(() {
      _continuing = false;
      _continueFailure = exception;
      _overlay = GameplayOverlay.continueFailed;
    });
  }

  /// The failure card's Try again: the bloc still holds the won level, so
  /// Continue's `NextLevelPressed` asks for the same next level again.
  void _retryContinue() => unawaited(_continue());

  /// "Next: Chapter N+1 · Name" (frame 4.6), from the next campaign level's
  /// own chapter; null past the last catalog chapter (`nextRequest` is a
  /// bonus level instead) hides the line.
  String? _nextChapterLine(GameplayState state) {
    final nextRequest = state.nextRequest;
    if (nextRequest is! CampaignPlay) return null;
    final nextEntry = widget.services.levels.entryAt(nextRequest.order);
    if (nextEntry == null) return null;
    final next = ChapterProgress.of(nextEntry, widget.services.levels);
    return context.localizations.chapterCompleteNext(
      next.number,
      next.displayName(context.localizations),
    );
  }

  /// The daily puzzle's date chip, "Sep 26" (frame 5.3, `LevelPill.daily`).
  String _dailyDateLabel(BuildContext context, int yyyymmdd) {
    final date = LocalDate.fromYyyymmdd(yyyymmdd);
    return DateFormat.MMMd(
      Localizations.localeOf(context).toString(),
    ).format(date.startOfDay);
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
          // The player's fixed theme, else the level's own chapter (or the
          // last chapter's/current chapter's for bonus/daily, m3-design
          // §9.1); `_chapter` (the entry's own bundle chapter) only while
          // nothing has loaded yet.
          final theme = state == null
              ? _chapter?.theme ?? ChapterTheme.ch01
              : ChapterTheme.byId(
                      widget.services.save.document.selectedTheme ??
                          state.play.themeId,
                    ) ??
                    ChapterTheme.ch01;
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
                      onRetry: () => _bloc.add(GameplayStarted(widget.request)),
                    ),
                  ),
                // A generated request (bonus, daily) resolves behind a
                // spinner over the old board, kept on screen underneath
                // (m3-design §6.4 item 1, §10.8).
                if (value.isLoading)
                  const _GeneratingOverlay(key: ValueKey('generatingSpinner')),
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
    final screen = MediaQuery.sizeOf(context);
    final overlay = _overlay;
    final skin = _skins.current;
    final chapter = _chapter;
    final symbols = services.database.symbolsMode.dollSymbols;
    final bloc = _bloc;
    // All Levels Done (4.9): a bonus request past the last campaign level.
    final nextRequest = state.nextRequest;
    final bonusRequest = nextRequest is BonusPlay ? nextRequest : null;
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
    // Frames 4.10, 5.3: Bonus Endless and the daily puzzle name themselves
    // on the level pill instead of "Level N".
    final request = state.play.request;
    final bonusNumber = request is BonusPlay ? request.number : null;
    final dailyDateLabel = switch (request) {
      DailyPlay(:final yyyymmdd) => _dailyDateLabel(context, yyyymmdd),
      _ => null,
    };
    return [
      // Under the HUD (m3-design §10.4): its scrim never dims the pause
      // button or the coin pill.
      if (state.tutorial case final cue?)
        Positioned.fill(
          key: const ValueKey('tutorialOverlay'),
          child: TutorialOverlay(
            cue: cue,
            board: state.board,
            geometry: _geometry,
            library: services.fx,
          ),
        ),
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
          bonusNumber: bonusNumber,
          dailyDateLabel: dailyDateLabel,
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
        // The 410-wide canvas 1:1 on the design's 390 dp screen and scaled
        // down on narrower ones, never up (LOTTIE.md v3 "Ribbons"): at rest
        // the ribbon is 380 wide, and during its 106 % pop the tails may
        // pass a 390 dp edge by up to 6 dp for about 100 ms (owner-accepted).
        Positioned.fromRect(
          key: const ValueKey('chapterRibbon'),
          rect: ChapterRibbon.rectIn(screen, padding),
          child: ChapterRibbon(
            key: ValueKey(state.levelNumber),
            number: chapter.number,
            chapterId: chapter.chapterId,
            library: services.fx,
            onDone: () => setState(() => _showRibbon = false),
          ),
        ),
      // Each overlay ducks the music while it is up (AUDIO.md "Music
      // rules"); the sheet also plays jingle_oom once the duck is in. The
      // keys keep each overlay's state (and its jingle) where it is when the
      // ribbon above it leaves the stack.
      if (overlay == GameplayOverlay.outOfMoves)
        Positioned.fill(
          key: const ValueKey(GameplayOverlay.outOfMoves),
          child: MusicDuck(
            music: services.music,
            reason: DuckReason.outOfMoves,
            jingles: services.jingles,
            jingle: Jingle.outOfMoves,
            child: OutOfMovesSheet(
              freeUndosLeft: state.freeUndosLeft,
              showFreeUndos: !state.unlimitedBoosters,
              undoPrice: state.undoPrice,
              slotPrice: state.slotPrice,
              extraSlotsLeft: state.extraSlotsLeft,
              unlimitedBoosters: state.unlimitedBoosters,
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
        ),
      if (overlay == GameplayOverlay.win && _win != null)
        Positioned.fill(
          key: const ValueKey(GameplayOverlay.win),
          // Down to 0.3 while it is up; back over 800 ms once Continue has
          // opened the next level.
          child: MusicDuck(
            music: services.music,
            reason: DuckReason.win,
            child: WinOverlay(
              key: ValueKey(state.levelNumber),
              summary: _win!,
              images: skin?.images,
              renderer: skin?.restRenderer,
              symbols: symbols,
              feedback: services.feedback,
              library: services.fx,
              onContinue: _continuing ? () {} : () => _onWinContinue(state),
            ),
          ),
        ),
      if (overlay == GameplayOverlay.chapterComplete && chapter != null)
        Positioned.fill(
          key: const ValueKey(GameplayOverlay.chapterComplete),
          child: ChapterCompleteOverlay(
            chapterNumber: chapter.number,
            chapterName: chapter.displayName(context.localizations),
            figurineId: chapter.figurineId,
            coins: state.chapterReward,
            nextLine: _nextChapterLine(state),
            library: services.fx,
            onContinue: _continuing ? () {} : _continueFromChapterComplete,
          ),
        ),
      if (overlay == GameplayOverlay.continueFailed && _continueFailure != null)
        Positioned.fill(
          key: const ValueKey(GameplayOverlay.continueFailed),
          child: NextLevelFailedCard(
            exception: _continueFailure!,
            onRetry: _continuing ? null : _retryContinue,
            onHome: widget.onHome,
          ),
        ),
      if (overlay == GameplayOverlay.pause && _settings != null)
        Positioned.fill(
          key: const ValueKey(GameplayOverlay.pause),
          child: MusicDuck(
            music: services.music,
            reason: DuckReason.pause,
            // The toggles only write the settings: the Music one reaches
            // the music service through DatabaseService.musicEnabledChanges,
            // and the Sound one gates every SFX and jingle as it plays.
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
              onSettings: () => unawaited(_openSettings()),
            ),
          ),
        ),
      if (overlay == GameplayOverlay.allLevelsDone)
        Positioned.fill(
          key: const ValueKey(GameplayOverlay.allLevelsDone),
          child: AllLevelsDone(
            families: WinSummary.familiesOf(state.entry.level, state.board),
            images: skin?.images,
            renderer: skin?.restRenderer,
            symbols: symbols,
            library: services.fx,
            onHome: widget.onHome,
            bonusNumber: bonusRequest?.number,
            // TODO(M7): if this bonus level can't be generated the card
            // stays up with its button live; Continue's failure has the
            // retry card (`NextLevelFailedCard`), this path doesn't yet.
            onPlayBonus: bonusRequest == null
                ? null
                : () => bloc.add(GameplayStarted(bonusRequest)),
          ),
        ),
      if (state.offer case final offer?)
        Positioned.fill(
          key: const ValueKey('boosterOffer'),
          child: BoosterBuyPopup(
            type: offer.type,
            price: offer.price,
            coins: state.coins,
            freeUndosPerLevel: services.save.freeUndosPerLevel,
            onBuy: state.coins >= offer.price
                ? () => bloc.add(BoosterPurchaseConfirmed(offer.type))
                : null,
            onDismiss: () => bloc.add(const BoosterPurchaseDismissed()),
          ),
        ),
      if (state.intro case final mechanic?)
        Positioned.fill(
          key: const ValueKey('introCard'),
          // The level's own dolls and board pieces (review FIDELITY-6).
          child: IntroMechanicCard(
            mechanic: mechanic,
            skin: skin,
            levelColors: [
              for (final color in state.entry.level.setsByColor.keys)
                if (!color.isWild) color,
            ],
            symbols: symbols,
            library: services.fx,
            onGotIt: () => bloc.add(const IntroDismissed()),
          ),
        ),
    ];
  }
}

/// `ui_spinner` over the old board while a generated request resolves
/// (m3-design §6.4 item 1, §10.8): it absorbs touches, since the board
/// beneath is the level just left, not the one loading.
class _GeneratingOverlay extends StatelessWidget {
  const _GeneratingOverlay({super.key});

  @override
  Widget build(BuildContext context) => const Positioned.fill(
    child: AbsorbPointer(
      child: Center(
        child: SizedBox.square(
          dimension: 48,
          child: LottieFxView(
            id: FxId.uiSpinner,
            fallback: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColorTokens.primary,
            ),
          ),
        ),
      ),
    ),
  );
}
