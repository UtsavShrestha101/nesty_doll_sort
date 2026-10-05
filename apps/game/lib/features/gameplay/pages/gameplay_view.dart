import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:nesty_core/nesty_core.dart' show GameState, LayoutLimits;
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/music/music_duck.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/overlays/all_levels_done.dart';
import 'package:nesty_game/features/gameplay/overlays/booster_buy_popup.dart';
import 'package:nesty_game/features/gameplay/overlays/chapter_complete_overlay.dart';
import 'package:nesty_game/features/gameplay/overlays/intro_mechanic_card.dart';
import 'package:nesty_game/features/gameplay/overlays/milestone_chest_modal.dart';
import 'package:nesty_game/features/gameplay/overlays/next_level_failed_card.dart';
import 'package:nesty_game/features/gameplay/overlays/out_of_moves_sheet.dart';
import 'package:nesty_game/features/gameplay/overlays/pause_dialog.dart';
import 'package:nesty_game/features/gameplay/overlays/race_result_overlay.dart';
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
import 'package:nesty_game/features/gameplay/widgets/generating_overlay.dart';
import 'package:nesty_game/features/gameplay/widgets/race_action_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/soft_stuck_banner.dart';
import 'package:nesty_game/features/gameplay/widgets/theme_background_view.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_game/features/race/widgets/rival_strip.dart';
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

  /// The milestone chest (E5; m7-design §9, §15.4): after the win overlay's
  /// Continue, when `GameplayState.chest != null`, before Chapter complete.
  milestoneChest,
  chapterComplete,
  allLevelsDone,

  /// Continue's next level couldn't be made (review CORRECTNESS-3; also the
  /// All Levels Done bonus retry, its M7 follow-up).
  continueFailed,

  /// Frame 9.4, a race's win (vs Computer; m7-design P2.10).
  raceWin,

  /// Frame 9.5, a race's loss ("The computer finished first").
  raceLoss,
}

/// What the win overlay's Continue does next, decided from the state alone
/// (m7-design §6 replay, §8 daily, §9 the chest, §13 the first win): a
/// replay pops back to Chapters, a daily pops back to Daily, a milestone
/// chest opens its modal first, a completed chapter opens Chapter complete
/// first, the player's first-ever win goes Home instead of the next level,
/// otherwise the next level loads. A public, pure function so a test can
/// assert the decision without a router in the tree.
enum WinContinueAction { chapters, daily, chest, chapterComplete, home, next }

WinContinueAction winContinueActionFor(GameplayState state) => switch (state) {
  _ when state.isReplay => WinContinueAction.chapters,
  _ when state.dailyStreak != null => WinContinueAction.daily,
  _ when state.chest != null => WinContinueAction.chest,
  _ when state.completedChapterId != null => WinContinueAction.chapterComplete,
  _ when state.firstWin => WinContinueAction.home,
  _ => WinContinueAction.next,
};

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
    this.onShop,
    this.boardFactory = NestyGameBoard.new,
    this.race,
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

  /// Opens the Shop's Coins tab (the booster popup's "Go to Shop" after
  /// its Not enough coins dialog, D195); null leaves that path closed.
  final VoidCallback? onShop;

  /// Relaxed mode's toast shows once per app launch, on the first level
  /// entered with the mode on (ui-spec-game §2.5).
  static bool _relaxedToastShown = false;

  /// Forgets the once-per-launch toasts (tests start a fresh launch).
  @visibleForTesting
  static void resetLaunchToasts() => _relaxedToastShown = false;

  /// Builds the board; tests pass a recording fake.
  final GameplayBoardFactory boardFactory;

  /// The race beside the board when [request] is a `PlayRequest.race`
  /// (vs Computer, spec-prop §7.7; docs/plans/m7-design.md P2.5, P2.8), or
  /// null. The view drives it: `playerBoardLoaded` on the bloc's start
  /// effect, `playerBoardChanged` on every board, Start, the holds, the
  /// gate (`RaceGateChanged`), and Rematch and New race on the same page.
  final RaceCubit? race;

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

  /// The HUD's coin pill and the Hint booster button, so the milestone
  /// chest modal's Collect step can fly reward sprites to them (m7-design
  /// chest sequence step 4).
  final _coinPillKey = GlobalKey();
  final _hintButtonKey = GlobalKey();

  /// How much of the pending chest's coins the Collect flight has released
  /// so far (m7-design §9's coin hold, extended per-landing): reset when a
  /// chest opens, counted up as each coin sprite lands, folded into
  /// [_chrome]'s `hudCoins` alongside the win reward's hold.
  int _chestCoinsRevealed = 0;

  /// Each coin sprite that lands bumps the HUD's coin pill (frame 10.3d).
  int _coinBump = 0;

  /// The gold ring round the coin pill from the first coin's landing until
  /// the last one's, then it fades out over 240 ms (`motion.chest.collect.
  /// pillRing`, m7-4 1.7; the ring widget owns the 80 and 240 ms fades).
  bool _coinRing = false;

  /// A brief `ui_booster_glow` pulse behind Hint the instant the chest's
  /// hint sprite lands; cleared a moment later by [_hintGlowTimer].
  bool _hintGlowPulse = false;
  int _hintBump = 0;
  Timer? _hintGlowTimer;

  /// The green "+N" tag over the Hint badge as the chest's hint lands,
  /// held for `gainTag.holdMs` (1,200 ms); 0 shows none.
  int _hintGain = 0;
  Timer? _hintGainTimer;

  /// The board toasts' queue (the host under this page, at y 152), set on
  /// each build.
  ToastQueue? _toasts;

  /// The level the +1 Slot limit toast last showed for: once per level.
  int? _slotLimitToastLevel;

  /// Why the last Continue's next level couldn't be made, while
  /// [GameplayOverlay.continueFailed] shows it (review CORRECTNESS-3).
  AppException? _continueFailure;

  /// Set while retrying All Levels Done's "Play Bonus Level N" (review
  /// CORRECTNESS-3 follow-up, M7): what Try again resends. Null means
  /// a normal Continue failure, whose Try again resends `NextLevelPressed`.
  BonusPlay? _pendingBonusRetry;
  PauseSettings? _settings;

  /// The next level's art, prepared while the win overlay is up; Continue
  /// waits for it so the level never shows with this level's skin
  /// (review CORRECTNESS-1).
  Future<void>? _nextArt;

  /// The `moveSeq` the out-of-moves sheet last opened for: a dismissed
  /// sheet stays closed until another move runs out again.
  int? _outOfMovesSeq;

  /// A restore left the board out of moves with its intro card still up
  /// (`GameplayState.intro`, m3-design §10.4): the sheet's open is deferred
  /// until "Got it" clears it, since dismissing the card is not a board
  /// effect the Flame board would otherwise report (review CORRECTNESS-1
  /// follow-up, M7).
  bool _outOfMovesAwaitingIntro = false;
  double _devicePixelRatio = 1;

  /// The Color symbols mode the board and the level's art were given.
  DollSymbols _symbols = DollSymbols.subtle;

  /// The board's current layout, for the tutorial overlay's holes (it draws
  /// from the same geometry the board just laid its dolls out on).
  BoardGeometry? _geometry;

  /// The last phase the `RaceCubit` reported (m7-design P2.5, P2.10), so the
  /// gate and the result overlay open only on a transition, never on every
  /// emission (the cubit emits once per rival step while running).
  RacePhase? _lastRacePhase;
  StreamSubscription<AsyncValue<RaceState>>? _raceSub;

  GameplayBloc get _bloc => context.read<GameplayBloc>();
  GameplayState? get _state => _bloc.state.data;
  RaceCubit? get _race => widget.race;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: _onAppHidden,
      onStateChange: _onRaceLifecycleStateChanged,
    );
    _raceSub = _race?.stream.listen(_onRaceState);
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
      ..boardLabels = BoardLabels(
        towerTag: context.localizations.boardTowerHidden,
        iceBadge: context.localizations.boardIceCount,
        textDirection: Directionality.of(context),
      )
      ..symbols = _symbols;
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _hintGlowTimer?.cancel();
    _hintGainTimer?.cancel();
    unawaited(_raceSub?.cancel());
    // The board disposes its own skin with the game (idempotent).
    _skins.dispose();
    super.dispose();
  }

  // --- The race (vs Computer; spec-prop §7.7; m7-design P2.5, P2.10) ----

  /// The `RaceCubit`'s state (a rival step, a hold, the result): opens the
  /// bloc's input gate once the race starts running, closes it once it
  /// finishes, and clears a leftover result card the moment Rematch or New
  /// race leaves [RacePhase.finished] (the new board's own
  /// `BoardResetEffect.start` then clears it for good through
  /// [_startLevel]).
  ///
  /// The computer's finish opens 9.5 at once over the frozen board
  /// (m7-design P2.10). The player's win opens 9.4 in [_openWin] instead,
  /// once the board has played the winning batch, as 2.8 does: the cubit
  /// decides the race synchronously on the bloc's won board, before the
  /// batch flies.
  void _onRaceState(AsyncValue<RaceState> value) {
    final state = value.data;
    if (!mounted || state == null) return;
    final previous = _lastRacePhase;
    _lastRacePhase = state.phase;
    if (state.phase == RacePhase.running && previous != RacePhase.running) {
      _bloc.add(const RaceGateChanged(open: true));
    } else if (state.phase == RacePhase.finished &&
        previous != RacePhase.finished) {
      _bloc.add(const RaceGateChanged(open: false));
      if (state.result == RaceResult.rivalWon) {
        // 9.5 replaces Pause (defence in depth: the cubit keeps the clock
        // off under a pause hold), so lift the pause it replaces. Otherwise
        // the bloc would stay paused and the next Rematch board would carry
        // `paused: true` with no dialog on screen (M7 review R8).
        if (_overlay == GameplayOverlay.pause) {
          _bloc.add(const PauseChanged(paused: false));
          _board.paused = false;
          _race?.setHold(RaceHold.pause, held: false);
        }
        _board.overlayOpen = true;
        setState(() => _overlay = GameplayOverlay.raceLoss);
      }
    } else if ((state.phase == RacePhase.waiting ||
            state.phase == RacePhase.ready) &&
        (_overlay == GameplayOverlay.raceWin ||
            _overlay == GameplayOverlay.raceLoss)) {
      setState(() => _overlay = GameplayOverlay.none);
    }
  }

  /// Every state but `resumed` holds the race's clock; `hidden` also opens
  /// Pause through [_onAppHidden] (m7-design P2.10 "Holds from the view").
  void _onRaceLifecycleStateChanged(AppLifecycleState state) {
    _race?.setHold(RaceHold.app, held: state != AppLifecycleState.resumed);
  }

  /// Rematch and New race load their board on this same page (m7-design
  /// P2.5): `_continuing` is set until its `BoardResetEffect.start`
  /// ([_startLevel]), so a second tap sends nothing and a board that can't
  /// be made opens the failure card ([_onContinueFailed]).
  void _raceRematch() {
    final race = _race;
    if (race == null || _continuing) return;
    setState(() => _continuing = true);
    _bloc.add(GameplayStarted(race.rematch()));
  }

  void _raceNewRace() {
    final race = _race;
    if (race == null || _continuing) return;
    final request = race.newRace();
    if (request == null) return;
    setState(() => _continuing = true);
    _bloc.add(GameplayStarted(request));
  }

  /// The result cards' "Back to rivals", Pause's "Quit race" and the
  /// failure card's link (m7-design P2.4, P2.10, Q133: one tap, no
  /// confirmation): pops the whole gameplay route back to rival select.
  /// `pop`, not `maybePop`: this page's own `PopScope` vetoes a `maybePop`
  /// (it turns system back into Pause). `RaceCubit.close()` (the route's
  /// own `BlocProvider`) writes nothing (spec-prop §7.7 "leaving it ends it
  /// with no reward").
  void _leaveRace() => context.router.pop();

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
    // A restore's out-of-moves sheet was waiting behind its intro card:
    // dismissing "Got it" is not a new effect (same effectSeq), so this is
    // the only place that notices it is now clear (review CORRECTNESS-1
    // follow-up, M7).
    if (_outOfMovesAwaitingIntro &&
        state.intro == null &&
        _overlay == GameplayOverlay.none) {
      _outOfMovesAwaitingIntro = false;
      _openOutOfMoves(state);
    }
    // Forwards every board to the race (m7-design P2.5): a won one while
    // the race runs is the player's win, synchronously, ahead of the next
    // frame (spec-prop §7.7 "on the same frame the player wins").
    _race?.playerBoardChanged(state.board);
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
    // Core's legal targets of the lifted nest, for E.14's drag hover
    // (D185): every change of `dropTargets` rides on an effect (the pick's
    // selection, the drop's move or rejection), so the board has them
    // before it plays that effect.
    _board.dropTargets = state.dropTargets;
    _board.apply(effect, state.board);
    // A restored board that was already out of moves or won (review
    // CORRECTNESS-1) plays no batch, so the board never reports it: open
    // its overlay now, as `_syncOutcome` would for a board with no
    // timeline (it then finds it open and does nothing).
    if (effect case BoardResetEffect(reason: BoardResetReason.start)) {
      switch (state.status) {
        case GameplayStatus.won:
          _openWin(state);
        // A restored board whose intro card was never dismissed defers the
        // sheet until "Got it" (review CORRECTNESS-1 follow-up, M7):
        // `_onBlocState` opens it once `state.intro` clears.
        case GameplayStatus.outOfMoves when _overlay == GameplayOverlay.none:
          if (state.intro == null) {
            _openOutOfMoves(state);
          } else {
            _outOfMovesAwaitingIntro = true;
          }
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
      // Frame 4.7 names a chapter on its first level: only a bundled board
      // (campaign or replay) is in a chapter. A daily or bonus board wears a
      // chapter's theme but starts none, though its one-level progress
      // reads as a chapter's first level.
      _showRibbon = state.play.request.isBundled && chapter.opensWithRibbon;
      _win = null;
      _continuing = false;
      _continueFailure = null;
      _pendingBonusRetry = null;
      _outOfMovesAwaitingIntro = false;
      if (_overlay != GameplayOverlay.pause) _overlay = GameplayOverlay.none;
    });
    _board.overlayOpen = false;
    _slotLimitToastLevel = null;
    _maybeToastRelaxed(state);
    _lastRacePhase = null;
    // The rival is built on this very `PlayEntry` (m7-design P2.5): the
    // page calls this on the bloc's own start effect, so both sides start
    // from identical copies of the same `Level`.
    _race?.playerBoardLoaded(state.play);
  }

  /// Frame 10.9: "Relaxed mode is on. Undo as often as you like.", once per
  /// launch, on the first level entered with the mode on (a race's free undo
  /// is its own rule, not this mode).
  void _maybeToastRelaxed(GameplayState state) {
    if (GameplayView._relaxedToastShown || !state.relaxed || state.isRace) {
      return;
    }
    GameplayView._relaxedToastShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _toasts?.enqueue(
        ToastSpec(
          tone: ToastTone.success,
          title: context.localizations.relaxedModeOn,
          icon: IconUses.relaxedMode,
        ),
      );
    });
  }

  /// Frame 12.9: a tap on the sunk +1 Slot face says why, once per level.
  void _onSlotLimitTapped(GameplayState state) {
    if (_slotLimitToastLevel == state.levelNumber) return;
    _slotLimitToastLevel = state.levelNumber;
    _toasts?.enqueue(
      ToastSpec(
        tone: ToastTone.info,
        title: context.localizations.extraSlotLimitToast(
          LayoutLimits.maxExtraSlots,
        ),
        icon: NestyIcons.addBox,
      ),
    );
  }

  /// Opens the outcome overlays the bloc's state calls for, when the board
  /// doesn't report them itself (a board with no timeline), and All Levels
  /// Done in any case.
  void _syncOutcome(GameplayState state) {
    if (state.status == GameplayStatus.allLevelsDone) {
      // The bonus retry's own failure (review CORRECTNESS-3 follow-up, M7)
      // rides in on this same stale, still-`allLevelsDone`
      // state: never let it clobber the failure card `_onContinueFailed`
      // (called just before this, on the same emission) just opened.
      if (_overlay != GameplayOverlay.allLevelsDone &&
          _overlay != GameplayOverlay.continueFailed) {
        _board.overlayOpen = true;
        // Continue's flight lands here (there is no further level to
        // start, so `_startLevel` never runs to reset it): without this,
        // "Play Bonus Level N" reads `_continuing` as still true forever
        // (review CORRECTNESS-3 follow-up, M7).
        setState(() {
          _overlay = GameplayOverlay.allLevelsDone;
          _continuing = false;
        });
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
        themeId: _boardThemeId(state.play.themeId),
      ),
    );
  }

  /// The theme behind the board: the player's fixed one, else the level's
  /// own; chapters 7 to 10 draw their own board wood on it (m7-4 A.5).
  String _boardThemeId(String levelThemeId) =>
      widget.services.save.document.selectedTheme ?? levelThemeId;

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
    if (state.isRace) {
      _openRaceWin(state, chapter);
      return;
    }
    setState(() {
      _setsShown = state.totalSets;
      _win = WinSummary(
        reward: state.winReward,
        families: WinSummary.familiesOf(state.entry.level, state.board),
        chapter: chapter,
        dailyStreak: state.dailyStreak,
        dailyRelit: state.dailyRelit,
        winMoves: state.winMoves,
        bestMoves: state.bestMoves,
        chestLevelsLeft: state.chestLevelsLeft,
        isReplay: state.isReplay,
        newBadges: state.newBadges,
        stars: state.stars,
        starsNewBest: state.starsNewBest,
        starTarget: state.starTarget,
        starTip: state.starTip,
        starsCapped: state.starsCapped,
        bonusNumber: switch (state.play.request) {
          BonusPlay(:final number) => number,
          _ => null,
        },
        dailyDate: switch (state.play.request) {
          DailyPlay(:final yyyymmdd) => LocalDate.fromYyyymmdd(yyyymmdd),
          _ => null,
        },
      );
      _overlay = GameplayOverlay.win;
    });
    unawaited(_prefetchNextLevel(state));
  }

  /// A race's won board (m7-design P2.10): 9.4, never 2.8, whose Continue
  /// would ask for a next level a race doesn't have. Only when the race is
  /// the player's: a move the bloc applied just after the computer
  /// finished (the tie's other side, P2.5) keeps 9.5 up. [_win] marks the
  /// win as handled, so [_syncOutcome] opens it once.
  void _openRaceWin(GameplayState state, ChapterProgress chapter) {
    final playerWon = _race?.state.data?.result == RaceResult.playerWon;
    setState(() {
      _setsShown = state.totalSets;
      _win = WinSummary(
        reward: 0,
        families: WinSummary.familiesOf(state.entry.level, state.board),
        chapter: chapter,
        winMoves: state.winMoves,
      );
      if (playerWon) _overlay = GameplayOverlay.raceWin;
    });
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
      themeId: _boardThemeId(next.themeId),
    );
  }

  void _openOutOfMoves(GameplayState state) {
    _outOfMovesSeq = state.moveSeq;
    _board.overlayOpen = true;
    // The sheet stops the rival too (m7-design P2.10 "Holds from the
    // view"): the player can't act on it while deciding.
    _race?.setHold(RaceHold.overlay, held: true);
    setState(() => _overlay = GameplayOverlay.outOfMoves);
  }

  void _closeOverlay() {
    _board.overlayOpen = false;
    _race?.setHold(RaceHold.overlay, held: false);
    setState(() => _overlay = GameplayOverlay.none);
  }

  void _openPause() {
    final state = _state;
    if (state == null || _overlay != GameplayOverlay.none) return;
    // A race's own board never gates Pause on `raceLive` (the boosters'
    // gate): the player may pause before Start too, and a hold set then
    // still counts at Start (m7-design P2.5).
    final allowed = state.isRace
        ? state.status == GameplayStatus.playing
        : state.acceptsInput;
    if (!allowed) return;
    _bloc.add(const PauseChanged(paused: true));
    _board.paused = true;
    _race?.setHold(RaceHold.pause, held: true);
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

  /// The booster popup's "Go to Shop" (D195): the popup closes, the level
  /// pauses (its in-progress save keeps it, as Pause → Home does) and the
  /// Shop's Coins tab opens.
  void _goToShopFromOffer() {
    _bloc
      ..add(const BoosterPurchaseDismissed())
      ..add(const PauseChanged(paused: true));
    widget.onShop?.call();
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
      themeId: _boardThemeId(state.play.themeId),
    );
  }

  void _resume() {
    if (_overlay != GameplayOverlay.pause) return;
    _bloc.add(const PauseChanged(paused: false));
    _board.paused = false;
    _race?.setHold(RaceHold.pause, held: false);
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
          GameplayOverlay.milestoneChest ||
          GameplayOverlay.chapterComplete ||
          GameplayOverlay.allLevelsDone ||
          GameplayOverlay.raceWin ||
          GameplayOverlay.raceLoss:
        break;
      // The failure card's way out (review CORRECTNESS-3): a race's goes
      // back to rival select (m7-design P2.4).
      case GameplayOverlay.continueFailed:
        _race == null ? widget.onHome() : _leaveRace();
    }
  }

  /// The win overlay's Continue (m3-design §8.4, §9.3; m7-design §6, §9,
  /// §13): [winContinueActionFor] decides, this performs it.
  void _onWinContinue(GameplayState state) {
    if (_continuing) return;
    switch (winContinueActionFor(state)) {
      case WinContinueAction.chapters:
        _backToChapters();
      case WinContinueAction.daily:
        _backToDaily();
      case WinContinueAction.chest:
        _openMilestoneChest();
      case WinContinueAction.chapterComplete:
        _openChapterComplete();
      case WinContinueAction.home:
        _goHomeAfterFirstWin();
      case WinContinueAction.next:
        unawaited(_continue());
    }
  }

  /// Frame 5.4's "Back to Daily": pops back to the Daily route it was
  /// pushed from (`DailyPage._playDaily`), never `NextLevelPressed` (the
  /// daily has no next, spec §7.5). `pop`, not `maybePop`: this page's own
  /// `PopScope` vetoes a `maybePop` (it turns system back into Pause).
  void _backToDaily() {
    setState(() => _continuing = true);
    context.router.pop();
  }

  /// A replay's Continue (E7; m7-design §6, §11): pops back to Chapters,
  /// same as [_backToDaily] pops back to Daily (never `NextLevelPressed`:
  /// a replay's `nextRequest` is always null).
  void _backToChapters() {
    setState(() => _continuing = true);
    context.router.pop();
  }

  /// The player's first-ever win (E9; m7-design §13): Continue goes to
  /// Home, never the next level, with nothing left in the stack (a fresh
  /// splash → L1 has no Home underneath it yet, m7-design §13).
  void _goHomeAfterFirstWin() {
    setState(() => _continuing = true);
    context.router.replaceAll([
      const MainShellRoute(children: [HomeRoute()]),
    ]);
  }

  /// The milestone chest (E5; m7-design §9, §15.4): its contents are
  /// already paid, so opening it just shows the modal.
  void _openMilestoneChest() {
    _chestCoinsRevealed = 0;
    setState(() => _overlay = GameplayOverlay.milestoneChest);
  }

  /// The chest modal's Collect: Chapter complete next when this win also
  /// completed one (never both at once on the campaign, m7-design §9), else
  /// the next level.
  void _continueFromMilestoneChest() {
    if (_continuing) return;
    if (_state?.completedChapterId != null) {
      _openChapterComplete();
      return;
    }
    unawaited(_continue());
  }

  /// The chest modal's Collect step (m7-design chest sequence step 4): the
  /// HUD's coin pill and the Hint booster button, in global (screen)
  /// coordinates, or null while unattached (the overlay just opened, or a
  /// layout pass hasn't happened yet) — the flight then bursts in place
  /// instead of flying nowhere.
  Rect? _coinPillRect() => _globalRectOf(_coinPillKey);
  Rect? _hintButtonRect() => _globalRectOf(_hintButtonKey);

  static Rect? _globalRectOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Releases the chest's coin hold one flight-landing at a time instead of
  /// all at once when the modal closes (m7-design §9's coin hold, extended
  /// per the chest sequence's step 4).
  void _onChestCoinsRevealed(int revealed) {
    if (!mounted) return;
    setState(() {
      _chestCoinsRevealed = revealed;
      _coinBump++;
      if (revealed > 0) _coinRing = true;
    });
    // Once every coin is in, the ring fades out (240 ms, its own).
    if (revealed >= (_state?.chest?.coins ?? 0)) {
      setState(() => _coinRing = false);
    }
  }

  /// The chest's hint sprite landed on the Hint booster (step 4): a brief
  /// glow pulse: the badge's own count (`state.hintsLeft`) is already
  /// correct throughout, since the chest's hint is paid at the win
  /// (m7-design §9), so nothing here changes a number, only the flourish.
  void _onChestHintLanded() {
    if (!mounted) return;
    _hintGlowTimer?.cancel();
    _hintGainTimer?.cancel();
    setState(() {
      _hintGlowPulse = true;
      _hintBump++;
      _hintGain = _state?.chest?.hints ?? 1;
    });
    _hintGainTimer = Timer(
      const Duration(milliseconds: ChestCollectTokens.gainTagHoldMs),
      () {
        if (mounted) setState(() => _hintGain = 0);
      },
    );
    _hintGlowTimer = Timer(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _hintGlowPulse = false);
    });
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

  /// All Levels Done's "Play Bonus Level N" (review CORRECTNESS-3
  /// follow-up, M7): a fresh `GameplayStarted`, tracked so a failure
  /// retries the same bonus request instead of `NextLevelPressed` (the
  /// state's status is `allLevelsDone`, not `won`, so that would no-op).
  void _startBonusFromAllLevelsDone(BonusPlay request) {
    if (_continuing) return;
    setState(() => _continuing = true);
    _pendingBonusRetry = request;
    _bloc.add(GameplayStarted(request));
  }

  /// Continue asked for a level that couldn't be made (review
  /// CORRECTNESS-3), or All Levels Done's own bonus retry failed the same
  /// way (the M7 follow-up): the bloc keeps the won/all-levels-done state
  /// and emits the error, so the overlay it came from would stay up with
  /// its button spent. The failure card replaces it instead, with Try
  /// again and Back to Home. An error with no Continue in flight is the
  /// route's own (the page's [RetryView]) or one the bloc recovers from
  /// itself.
  void _onContinueFailed(AppException exception) {
    // A race's Rematch, New race or retry that couldn't be made (m7-design
    // P2.4): the same card, with Back to rivals, whatever is up.
    if (_race != null) {
      if (!_continuing) return;
      _board.overlayOpen = true;
      setState(() {
        _continuing = false;
        _continueFailure = exception;
        _overlay = GameplayOverlay.continueFailed;
      });
      return;
    }
    final continuingFrom = switch (_overlay) {
      GameplayOverlay.win ||
      GameplayOverlay.milestoneChest ||
      GameplayOverlay.chapterComplete ||
      GameplayOverlay.allLevelsDone ||
      GameplayOverlay.continueFailed => true,
      GameplayOverlay.none ||
      GameplayOverlay.pause ||
      GameplayOverlay.outOfMoves ||
      GameplayOverlay.raceWin ||
      GameplayOverlay.raceLoss => false,
    };
    if (!_continuing || !continuingFrom) return;
    setState(() {
      _continuing = false;
      _continueFailure = exception;
      _overlay = GameplayOverlay.continueFailed;
    });
  }

  /// The failure card's Try again: a pending bonus retry (All Levels Done)
  /// resends the same `GameplayStarted`; otherwise the bloc still holds the
  /// won level, so Continue's `NextLevelPressed` asks for the same next
  /// level again.
  void _retryContinue() {
    final race = _race;
    if (race != null) {
      if (_continuing) return;
      setState(() => _continuing = true);
      _bloc.add(GameplayStarted(race.request));
      return;
    }
    final bonus = _pendingBonusRetry;
    if (bonus != null) {
      _startBonusFromAllLevelsDone(bonus);
      return;
    }
    unawaited(_continue());
  }

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
            // Board toasts (relaxed mode, the +1 Slot limit) sit at y 152,
            // under the family counter (ui-spec-game §1 "Toast").
            body: ToastHost(
              top: ToastHost.boardTop,
              child: Builder(
                builder: (toastContext) {
                  _toasts = ToastHost.maybeOf(toastContext);
                  return Stack(
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
                      if (state == null &&
                          value is AsyncValueError<GameplayState>)
                        _race == null && !widget.request.isGenerated
                            ? Center(
                                child: RetryView(
                                  exception: value.exception,
                                  onRetry: () => _bloc.add(
                                    GameplayStarted(widget.request),
                                  ),
                                ),
                              )
                            // A generated board that couldn't be made: a race's
                            // (m7-design P2.4, 9.3f: Try again, or back to rival
                            // select) or a bonus or daily level's (12.6: Try
                            // again, or Back to Home), never the splash's
                            // "didn't unpack" card.
                            : Positioned.fill(
                                key: const ValueKey('raceLoadFailed'),
                                child: NextLevelFailedCard(
                                  title: _race == null
                                      ? context
                                            .localizations
                                            .gameplayFailedTitle
                                      : context.localizations.raceFailedTitle,
                                  body: _race == null
                                      ? context.localizations.gameplayFailedBody
                                      : context.localizations.raceFailedBody,
                                  retryLabel: context.localizations.retry,
                                  secondaryLabel: _race == null
                                      ? context
                                            .localizations
                                            .nextLevelFailedHome
                                      : context.localizations.raceBackToRivals,
                                  versus: _race != null,
                                  onRetry: () => _bloc.add(
                                    GameplayStarted(widget.request),
                                  ),
                                  onSecondary: _race == null
                                      ? widget.onHome
                                      : _leaveRace,
                                ),
                              ),
                      // A generated request (bonus, daily) resolves behind a
                      // spinner over the old board, kept on screen underneath
                      // (m3-design §6.4 item 1, §10.8).
                      if (value.isLoading)
                        GeneratingOverlay(
                          key: const ValueKey('generatingSpinner'),
                          library: widget.services.fx,
                        ),
                    ],
                  );
                },
              ),
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
    // The bloc pays the reward (and a milestone chest's coins) at Won, so
    // the save's balance already holds them. Frames 1.5 and 2.8 keep the
    // HUD at the old balance while the set flies and the overlay counts
    // "+N" up, so it holds from Won until the next level starts (Q57;
    // m7-design §9's coin hold). The chest's own share of the hold is
    // released one coin-flight landing at a time instead of all at once
    // (`_chestCoinsRevealed`, m7-design chest sequence step 4), so the HUD
    // visibly counts up in step with the modal's Collect instead of
    // jumping once it closes.
    final chestHeld = math.max(
      0,
      (state.chest?.coins ?? 0) - _chestCoinsRevealed,
    );
    // A race holds nothing back (m7-design P2.10 "the live balance, no coin
    // hold"): the save's own balance, so a win's reward shows as it is paid
    // (the cubit pays it, not the bloc, whose `coins` catch up on the next
    // board).
    final hudCoins = state.isRace
        ? services.save.coins
        : won
        ? math.max(0, state.coins - state.winReward - chestHeld)
        : state.coins;
    // Frames 4.10, 5.3: Bonus Endless and the daily puzzle name themselves
    // on the level pill instead of "Level N".
    final request = state.play.request;
    final bonusNumber = request is BonusPlay ? request.number : null;
    final dailyDateLabel = switch (request) {
      DailyPlay(:final yyyymmdd) => _dailyDateLabel(context, yyyymmdd),
      _ => null,
    };
    final race = _race;
    // A race's Pause never gates on `raceLive` (m7-design P2.10): it opens
    // before Start too, whenever the board is still in play.
    final pauseAvailable = state.isRace
        ? state.status == GameplayStatus.playing
        : state.acceptsInput;
    return [
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        // The board yields the counter's place to a hint over the middle
        // top stand (frame 3.1b; `GameplayBoard.familyCounterYield`).
        child: ValueListenableBuilder<bool>(
          valueListenable: _board.familyCounterYield,
          builder: (context, counterYields, _) => GameplayHud(
            level: state.levelNumber,
            tier: state.entry.tier,
            coins: hudCoins,
            setsDone: math.min(_setsShown, state.totalSets),
            setsTotal: state.totalSets,
            sparkleScale: _counterSparkleScale,
            bonusNumber: bonusNumber,
            dailyDateLabel: dailyDateLabel,
            // Frame 9.3: the strip takes the top row in a race, in place of
            // the level and coin pills (phase 4 architecture §6.6).
            raceStrip: state.isRace && race != null
                ? RivalStrip(cubit: race)
                : null,
            familyCounterHidden: counterYields,
            library: services.fx,
            coinPillKey: _coinPillKey,
            coinBump: _coinBump,
            coinRing: _coinRing,
            onPause: won || (overlay == GameplayOverlay.none && pauseAvailable)
                ? _openPause
                : null,
            locked: won,
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: state.isRace && race != null
            ? BlocBuilder<RaceCubit, AsyncValue<RaceState>>(
                bloc: race,
                builder: (context, raceValue) {
                  final ready =
                      raceValue.data?.phase != RacePhase.running &&
                      raceValue.data?.phase != RacePhase.finished;
                  return RaceActionBar(
                    ready: ready,
                    onStart: race.start,
                    canUndo: state.canUndo && state.acceptsInput,
                    onUndo: () => bloc.add(const UndoPressed()),
                    onRestart: () => bloc.add(const RestartPressed()),
                  );
                },
              )
            : BoosterBar(
                model: BoosterBarModel.of(state),
                library: services.fx,
                onUndo: () => bloc.add(const UndoPressed()),
                onHint: () => bloc.add(const HintPressed()),
                onExtraSlot: () => bloc.add(const ExtraSlotPressed()),
                onRestart: () => bloc.add(const RestartPressed()),
                hintKey: _hintButtonKey,
                hintGlow: _hintGlowPulse,
                hintBump: _hintBump,
                hintRing: _hintGlowPulse,
                hintGain: _hintGain,
                onSlotLimit: () => _onSlotLimitTapped(state),
              ),
      ),
      // Above the HUD and the booster bar (frames 1.3, 10.8b; phase 5
      // F-TUT, over m3-design §10.4's "under the HUD"): the scrim dims them
      // and the card covers the family chip. It is IgnorePointer, so Pause
      // and the boosters still take taps beneath it.
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
            palette: chapter.theme.palette,
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
              freeUndosTotal: services.save.freeUndosPerLevel,
              showFreeUndos: !state.unlimitedBoosters,
              undoPrice: state.undoPrice,
              slotPrice: state.slotPrice,
              extraSlotsLeft: state.extraSlotsLeft,
              unlimitedBoosters: state.unlimitedBoosters,
              // A race's undo is free and unlimited, like relaxed mode
              // (spec-prop §7.7), and +1 Slot is off: Undo and Restart only
              // (m7-design P2.10).
              relaxed: state.isRace || state.relaxed,
              onUndo: state.canUndo
                  ? () {
                      _closeOverlay();
                      bloc.add(const UndoPressed());
                    }
                  : null,
              onExtraSlot: state.isRace || !state.canAddSlot
                  ? null
                  : () {
                      _closeOverlay();
                      bloc.add(const ExtraSlotPressed());
                    },
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
              uiArt: services.uiArt,
              share: services.share,
              onTipShown: services.save.markStarTipShown,
              onContinue: _continuing ? () {} : () => _onWinContinue(state),
            ),
          ),
        ),
      if ((overlay == GameplayOverlay.raceWin ||
              overlay == GameplayOverlay.raceLoss) &&
          race != null)
        Positioned.fill(
          key: ValueKey(overlay),
          child: RaceResultLayer(
            race: race,
            overlay: overlay,
            state: state,
            services: services,
            continuing: _continuing,
            onRematch: _raceRematch,
            onNewRace: _raceNewRace,
            onBackToRaces: _leaveRace,
            // The plank's dolls in the level's own skin, as the win card's
            // (rule 3: the placeholder doll draws until the skin is ready).
            images: skin?.images,
            renderer: skin?.restRenderer,
            symbols: symbols,
          ),
        ),
      if (overlay == GameplayOverlay.milestoneChest && state.chest != null)
        Positioned.fill(
          key: const ValueKey(GameplayOverlay.milestoneChest),
          // JingleCues.reward() ducks and unducks the music on its own
          // (E5; m7-design §15.4), so no MusicDuck wrapper here.
          child: MilestoneChestModal(
            chest: state.chest!,
            feedback: services.feedback,
            jingleCues: services.jingleCues,
            library: services.fx,
            uiArt: services.uiArt,
            coinTarget: _coinPillRect,
            hintTarget: _hintButtonRect,
            onCoinsRevealed: _onChestCoinsRevealed,
            onHintLanded: _onChestHintLanded,
            onCollect: _continuing ? () {} : _continueFromMilestoneChest,
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
            title: race == null
                ? context.localizations.gameplayFailedTitle
                : context.localizations.raceFailedTitle,
            body: race == null
                ? context.localizations.gameplayFailedBody
                : context.localizations.raceFailedBody,
            retryLabel: context.localizations.retry,
            secondaryLabel: race == null
                ? context.localizations.nextLevelFailedHome
                : context.localizations.raceBackToRivals,
            versus: race != null,
            onRetry: _continuing ? () {} : _retryContinue,
            onSecondary: race == null ? widget.onHome : _leaveRace,
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
              level: state.isRace ? null : state.levelNumber,
              tier: state.isRace ? null : state.entry.tier,
              race: switch (state.play.request) {
                RacePlay(:final rival) => RacePauseInfo(rival: rival),
                _ => null,
              },
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
              onHome: state.isRace ? null : widget.onHome,
              // Settings in a race's Pause too (9.7, Q132's design answer,
              // D192): the Pause dialog stays under the pushed Settings, so
              // its pause hold (set in `_openPause`, lifted only by
              // `_resume`) keeps the rival paused until the player resumes.
              onSettings: () => unawaited(_openSettings()),
              onLeaveRace: state.isRace ? _leaveRace : null,
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
            // A generation failure gets the same retry card as Continue's
            // (review CORRECTNESS-3 follow-up, resolved in M7):
            // `_onContinueFailed` now treats `allLevelsDone` as continuing.
            onPlayBonus: bonusRequest == null
                ? null
                : _continuing
                ? () {}
                : () => _startBonusFromAllLevelsDone(bonusRequest),
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
            onNeedCoins: widget.onShop == null ? null : _goToShopFromOffer,
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
