import 'dart:async';
import 'dart:ui' show Canvas, Offset, Size;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/board_shape_of.dart';
import 'package:nesty_game/features/gameplay/game/components/board_scene.dart';
import 'package:nesty_game/features/gameplay/game/components/fx_layer.dart';
import 'package:nesty_game/features/gameplay/game/components/hint_layer.dart';
import 'package:nesty_game/features/gameplay/game/components/shelf_layer.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_component.dart';
import 'package:nesty_game/features/gameplay/game/components/slot_view.dart';
import 'package:nesty_game/features/gameplay/game/timeline/timeline.dart';
import 'package:nesty_render/nesty_render.dart';

/// A family landed on the counter (`FamilyLanded`): the HUD bumps
/// `ui_family_counter` to [setsCompleted] / [totalSets] with a sparkle
/// [sparkleScale]× the trail's (m2-lottie-design §7).
typedef FamilyLandedCallback =
    void Function(int setsCompleted, int totalSets, double sparkleScale);

/// The board of one level (spec §13.1; docs/plans/m2-lottie-design.md §2, §5,
/// §7–§10, §14): the Flame side of the gameplay page.
///
/// - **Renders, never decides** (CLAUDE.md rules 2 and 10). The page hands it
///   every `BoardEffect` with the state after it ([apply]); the
///   [BoardTimeline] plans the Lottie clips, hand-coded tweens, sprite syncs,
///   cues and input reservations, and this component executes its
///   [FxCommand]s ([execute]). After each batch it reconciles every slot
///   with the latest state.
/// - **Input is only forwarded** as the bloc's intents: a tap on a slot's
///   column (`BoardGeometry.slotAt`, ≥ 48 dp) is `SlotTapped`; a drag is
///   `SlotDragStarted` then `SlotDragDropped` (null over nothing, or over a
///   slot the timeline reserved). The lifted doll follows the finger,
///   clamped to the board frame, and the next `byDrag` effect flies from
///   there. Input on reserved slots, while paused, during an overlay or
///   the re-pitch is dropped.
/// - **Children, back to front:** [ShelfLayer] (planks, stands,
///   silhouettes, pips, tags), the FX underlay (glow rings, the pulsing
///   extra stand), one [SlotComponent] per slot (its rest sprite, paused
///   glass/ice composition and ice badge), the [HintLayer] (the dashed arc)
///   and the [FxLayer] (the pooled clips).
/// - **One tick** ([update]): advance the live clips and compositions by
///   `dt`, advance the timeline (its due commands run), then schedule the
///   effects [apply] queued (their time-0 commands run now, at the new
///   time, so a clip's own clock equals the timeline's from its batch
///   start), then follow the drag and the re-pitch. Everything runs before
///   any render, so a clip starts in the frame its sprite hides and ends in
///   the frame it shows (§10.1). Nothing here allocates per frame (rule 8).
class BoardComponent extends PositionComponent
    with TapCallbacks, DragCallbacks
    implements FxCommandSink {
  BoardComponent({
    required this.library,
    required FeedbackSink feedback,
    this.onIntent,
    this.onFamilyLanded,
    this.onBoardIdle,
    this.onWon,
    this.onOutOfMoves,
    this.onLayout,
    ComboTracker? combo,
  }) : _feedback = feedback,
       _combo = combo {
    scene = BoardScene(isAvailable: _isAvailable);
    shelf = ShelfLayer(scene, priority: shelfPriority);
    fx = FxLayer(scene, priority: fxPriority, underlayPriority: underPriority);
    hint = HintLayer(scene, priority: hintPriority);
    _unmounted = _UnmountedSlots(_slotList, priority: slotPriority - 1);
  }

  // Priorities of the layers (§8 z-order): shelf → glow/extra stand →
  // slots (row-major) → hint arc → clips.
  static const shelfPriority = 0;
  static const underPriority = 5;
  static const slotPriority = 100;
  static const hintPriority = 200;
  static const fxPriority = 300;

  /// Every Lottie composition. A file it lacks is skipped: its sprite rests
  /// and its static fallback draws (rule 3).
  final FxLibrary library;

  final FeedbackSink _feedback;
  final ComboTracker? _combo;

  /// Where taps and drags go: the gameplay bloc's `add`.
  final void Function(GameplayEvent intent)? onIntent;

  /// The HUD's counter bump when a completed set lands.
  final FamilyLandedCallback? onFamilyLanded;

  /// Everything scheduled has played (loops may still run).
  final VoidCallback? onBoardIdle;

  /// The winning batch is done (+ 250 ms): open the win overlay.
  final void Function(int moveCount)? onWon;

  /// The board went idle after the move that left no legal move: open the
  /// Out-of-Moves sheet.
  final VoidCallback? onOutOfMoves;

  /// The layout changed (a new level, +1 Slot, a resize): the page prepares
  /// the level's skin for it (`SkinService.prepareForLevel`).
  final void Function(BoardGeometry geometry)? onLayout;

  late final BoardScene scene;
  late final ShelfLayer shelf;
  late final FxLayer fx;
  late final HintLayer hint;

  final Map<String, SlotComponent> _slots = {};
  final List<SlotComponent> _slotList = [];

  /// Draws the slots Flame hasn't mounted yet (see [_UnmountedSlots]).
  late final Component _unmounted;

  BoardTimeline? _timeline;
  BoardViewport? _viewport;
  BoardShape? _shape;
  GameState? _latestBoard;
  final List<_Pending> _pending = [];
  MotionSpec _motion = MotionSpec.standard;
  bool _paused = false;
  bool _overlayOpen = false;
  bool _wasIdle = true;
  bool _libraryReady = false;
  bool _libraryLoading = false;

  /// Slots still on a static stand-in after the library loaded mid-batch:
  /// they trade it for their composition at the next idle.
  bool _upgradePending = false;

  // The drag in progress: its pointer, where the finger started and where
  // the dragged doll's base started.
  int? _dragPointer;
  double _fingerStartX = 0;
  double _fingerStartY = 0;
  double _fingerX = 0;
  double _fingerY = 0;
  double _baseStartX = 0;
  double _baseStartY = 0;
  Offset? _dropBase;

  /// The board's timeline, once a level is on it.
  BoardTimeline? get timeline => _timeline;

  /// The latest state the page applied.
  GameState? get board => _latestBoard;

  /// The committed layout, once a level is on it.
  BoardGeometry? get geometry => scene.geometry;

  /// The screen the board is laid out on.
  BoardViewport? get viewport => _viewport;

  /// The slot components by slot id (for tests and the page's debug tools).
  Map<String, SlotComponent> get slots => Map.unmodifiable(_slots);

  /// Called with every command before it runs (tests, debug overlays).
  @visibleForTesting
  void Function(FxCommand command, double lateMs)? debugOnCommand;

  bool _isAvailable(FxId id) => fx.hasPool(id);

  // ── Settings from the page ──

  /// The pause dialog (frame 3.9): input is dropped and time stands still.
  bool get paused => _paused;
  set paused(bool value) {
    _paused = value;
    _timeline?.paused = value;
  }

  /// An overlay or sheet is open (win, out of moves): input is dropped.
  bool get overlayOpen => _overlayOpen;
  set overlayOpen(bool value) {
    _overlayOpen = value;
    _timeline?.overlayOpen = value;
  }

  /// §13: the platform asks for less motion. New batches plan with it.
  MotionSpec get motion => _motion;
  set motion(MotionSpec value) {
    _motion = value;
    _timeline?.motion = value;
  }

  /// Belly symbols of the placeholder dolls (the part rasters bake theirs).
  set symbols(DollSymbols value) => scene.symbols = value;

  /// The level's art (`SkinService.prepareForLevel`), owned from here: a new
  /// one replaces and disposes the previous one (§4).
  LevelSkin? get skin => scene.skin;
  set skin(LevelSkin? value) {
    final old = scene.skin;
    if (identical(old, value)) return;
    scene.skin = value;
    final source = value?.images;
    fx.setImageSource(source);
    for (final slot in _slotList) {
      slot.setImageSource(source);
    }
    _ensureGlass();
    old?.dispose();
  }

  // ── Lifecycle ──

  @override
  Future<void> onLoad() async {
    await addAll([shelf, fx.underlay, _unmounted, hint, fx]);
    _loadLibrary();
  }

  /// The files the library holds get their pools now; the rest when the
  /// library finishes loading (the splash normally loaded it already).
  void _loadLibrary() {
    fx.buildPools(library);
    if (library.isLoaded || _libraryLoading) return;
    _libraryLoading = true;
    unawaited(
      library.load().then<void>(
        (_) => _libraryReady = true,
        onError: (Object _) => _libraryReady = true,
      ),
    );
  }

  /// The board's size and the safe areas of the screen it fills.
  void layOut(double width, double height, {EdgeInsets? padding}) {
    size.setValues(width, height);
    final viewport = BoardViewport(
      size: Size(width, height),
      padding: padding ?? _viewport?.padding ?? EdgeInsets.zero,
    );
    if (viewport == _viewport) return;
    _viewport = viewport;
    final board = _latestBoard;
    if (board == null || _timeline == null) return;
    _relayout(boardGeometryOf(board, viewport));
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;

  /// Queues [effect] with [board], the state after it: it is scheduled in
  /// the next tick, in order (§7).
  void apply(BoardEffect effect, GameState board) =>
      _pending.add(_Pending(effect, board));

  /// The game is going away: every clip back to its pool, every paused
  /// composition's recorded picture and the level's art freed.
  void dispose() {
    fx.stopAll();
    for (final slot in _slotList) {
      slot.disposeCompositions();
    }
    scene.skin?.dispose();
    scene.skin = null;
    scene.dispose();
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void update(double dt) {
    // The pause dialog: time stands still (§7 "Global lock").
    if (_paused) return;
    if (_libraryReady) _onLibraryReady();
    final ms = dt * 1000;
    // The FxCommandSink protocol: live clips first, then the timeline, so a
    // clip one of its commands starts isn't advanced twice in its first
    // frame.
    fx.advance(ms);
    for (var i = 0; i < _slotList.length; i++) {
      _slotList[i].advance(ms);
    }
    _timeline?.advance(ms);
    // New batches start at the new time: their time-0 clips draw frame 0
    // now and their clocks match the timeline's from here on.
    if (_pending.isNotEmpty) _drain();
    final timeline = _timeline;
    if (timeline == null) return;
    _afterAdvance(timeline);
  }

  void _afterAdvance(BoardTimeline timeline) {
    scene.selectedSlotId = timeline.selectedSlotId;
    final repitch = scene.repitch;
    if (repitch != null) fx.followRepitch(repitch);
    _followDrag(timeline);
    final idle = timeline.isIdle && scene.repitch == null;
    if (idle && !_wasIdle) _becameIdle();
    _wasIdle = idle;
  }

  /// The lifted doll follows the finger: its `doll_pick` clip holds
  /// `lift`'s last frame at the dragged base (§7 "Drag start").
  void _followDrag(BoardTimeline timeline) {
    final dragged = scene.dragSlotId;
    if (dragged == null || timeline.selectedSlotId != dragged) return;
    final clip = timeline.selectionClip;
    if (clip == null) return;
    fx
        .componentOf(clip.id)
        ?.placeAt(scene.dragBaseX, scene.dragBaseY, timeline.geometry.scale);
  }

  // ── End of hot path. ──

  void _onLibraryReady() {
    _libraryReady = false;
    fx.buildPools(library);
    _upgradePending = true;
    // Slots built before the files arrived trade their stand-ins for the
    // compositions, only while resting (a frame swap may be playing): now,
    // or at the next idle.
    if (_timeline?.isIdle ?? true) _upgradeCompositions();
  }

  void _upgradeCompositions() {
    _upgradePending = false;
    for (final slot in _slotList) {
      if (slot.drawsGlassFallback || slot.drawsIceFallback) {
        slot.buildCompositions(library, reducedMotion: !_motion.shake);
      }
    }
  }

  void _drain() {
    // Nothing is laid out before the first resize: keep them for then.
    if (_viewport == null) return;
    for (var i = 0; i < _pending.length; i++) {
      _schedule(_pending[i]);
    }
    _pending.clear();
  }

  void _schedule(_Pending pending) {
    final viewport = _viewport!;
    final effect = pending.effect;
    final board = pending.board;
    _latestBoard = board;
    final shape = boardShapeOf(board);
    // A new level always gets (and reports) its own layout, even when its
    // shape equals the last level's: the page prepares each level's art,
    // its colours included, from `onLayout`.
    final newLevel =
        effect is BoardResetEffect && effect.reason == BoardResetReason.start;
    BoardGeometry? layout;
    if (_timeline == null || newLevel || shape != _shape) {
      layout = BoardLayout.compute(shape, viewport);
      _shape = shape;
    }
    var timeline = _timeline;
    if (timeline == null) {
      fx.buildPools(library);
      timeline = _timeline =
          BoardTimeline(
              commands: this,
              feedback: _feedback,
              geometry: layout!,
              motion: _motion,
              isAvailable: _isAvailable,
              poolSizes: FxLayer.poolSizes,
              combo: _combo,
            )
            ..paused = _paused
            ..overlayOpen = _overlayOpen;
    }
    // Whatever it plans, the board reconciles once it is idle again.
    _wasIdle = false;
    final dragBase = _endsDrag(effect) ? _takeDropBase() : null;
    final batch = timeline.schedule(
      effect,
      board,
      geometry: layout,
      dragBase: dragBase,
    );
    if (layout != null) {
      // A reset built the slots on it already; +1 Slot commits at the
      // re-pitch's end. Anything else (a viewport or shape change without
      // one) commits now.
      if (!identical(scene.geometry, layout) &&
          effect is! ExtraSlotAddedEffect) {
        _commit(layout);
      }
      onLayout?.call(layout);
    }
    _prefetch(batch);
  }

  /// The effects that end a drag: the doll flies from the finger (§9.4).
  static bool _endsDrag(BoardEffect effect) => switch (effect) {
    MoveAppliedEffect(:final byDrag) => byDrag,
    MoveRejectedEffect(:final byDrag) => byDrag,
    SelectionChangedEffect(:final byDrag, :final selected) =>
      byDrag && selected == null,
    _ => false,
  };

  Offset? _takeDropBase() {
    final base = _dropBase;
    _dropBase = null;
    return base;
  }

  /// Rasterizes the glass case's cracked and shattered frames as soon as a
  /// batch will unlock a case (700 ms ahead of the clip; the services
  /// lane's `BoardSprites.ensure`).
  void _prefetch(TimelineBatch batch) {
    final sprites = scene.sprites;
    if (sprites == null || !sprites.isPrepared) return;
    for (final command in batch.commandsOf<PlaySlotFx>()) {
      if (command.fx != FxId.fxGlassUnlock) continue;
      final slot = scene.slot(command.slotId);
      if (slot == null) continue;
      final scale = slot.geometry.furnitureScale;
      unawaited(
        sprites.ensure(BoardSprite.glassCase1, scale).catchError(_ignore),
      );
      unawaited(
        sprites.ensure(BoardSprite.glassCase2, scale).catchError(_ignore),
      );
    }
  }

  /// The intact case of every locked slot (a restart brings released cases
  /// back).
  void _ensureGlass() {
    final sprites = scene.sprites;
    if (sprites == null || !sprites.isPrepared) return;
    for (final slot in scene.slots) {
      if (!slot.view.locked) continue;
      unawaited(
        sprites
            .ensure(BoardSprite.glassCase0, slot.geometry.furnitureScale)
            .catchError(_ignore),
      );
    }
  }

  static void _ignore(Object _) {}

  // ── FxCommandSink ──

  @override
  void execute(FxCommand command, double lateMs) {
    debugOnCommand?.call(command, lateMs);
    final timeline = _timeline;
    if (timeline == null) return;
    switch (command) {
      case StartClip():
        fx.start(command, lateMs, timeline.geometry);
      case PlayClipSegment():
        fx.play(command, lateMs);
      case PlaceClip():
        fx.place(command, timeline.geometry);
      case ReleaseClipSlots():
        fx.releaseSlots(command);
      case StopClip():
        fx.stop(command);
      case PlaySlotFx(:final slotId, :final segment, :final shake):
        _slots[slotId]?.playComposition(
          command.fx,
          segment,
          lateMs,
          shake: shake,
        );
      case ReleaseSlotFx(:final slotId):
        _slots[slotId]?.releaseComposition(command.fx);
        if (command.fx == FxId.fxGlassUnlock) _releaseGlassIfDone();
      case SyncSlot(:final slotId, :final state):
        scene.slot(slotId)?.setView(SlotView.of(state, slotId));
      case StartTween(:final tween):
        _startTween(tween);
      case EndTween(:final tween):
        _endTween(tween);
      case SetHintArc(:final move):
        scene.hint = move;
        hint.show(move);
      case FamilyLanded():
        onFamilyLanded?.call(
          command.setsCompleted,
          command.totalSets,
          command.sparkleScale,
        );
      case BoardWon(:final moveCount):
        onWon?.call(moveCount);
      case BoardOutOfMoves():
        onOutOfMoves?.call();
      case ResetBoard(:final snapshot):
        _reset(snapshot, timeline.geometry);
    }
  }

  /// Every case has shattered: the glass frames go (the services lane's
  /// `BoardSprites.release`). A restart ensures them again.
  void _releaseGlassIfDone() {
    for (final slot in _slotList) {
      if (slot.glass != null || slot.drawsGlassFallback) return;
    }
    scene.sprites?.release(const [
      BoardSprite.glassCase0,
      BoardSprite.glassCase1,
      BoardSprite.glassCase2,
    ]);
  }

  void _startTween(HandTween tween) {
    switch (tween) {
      case RevealDropTween(:final slotId):
        scene.slot(slotId ?? '')?.reveal = tween;
      case ShakeTween(:final slotId):
        scene.slot(slotId ?? '')?.shake = tween;
      case RepitchTween(:final from, :final to):
        // A re-pitch queued behind another (a double +1 Slot) that a resize
        // overtook: its layouts are the old screen's, and the resize has
        // committed the new one already.
        if (!identical(to, _timeline?.geometry)) break;
        scene
          ..repitch = tween
          ..geometry = to;
        for (final slot in scene.slots) {
          slot
            ..from = from.slotOrNull(slot.id)
            ..geometry = to.slotOrNull(slot.id) ?? slot.geometry;
        }
        // The slot +1 Slot adds grows in at its new place.
        for (final g in to.slots) {
          if (scene.slot(g.id) == null) _addSlot(g, _viewOf(g.id));
        }
        scene.sortSlots();
        shelf.relayout();
    }
    for (final id in tween.hides) {
      scene.slot(id)?.hide();
    }
  }

  void _endTween(HandTween tween) {
    switch (tween) {
      case RevealDropTween(:final slotId):
        final slot = scene.slot(slotId ?? '');
        if (identical(slot?.reveal, tween)) slot?.reveal = null;
      case ShakeTween(:final slotId):
        final slot = scene.slot(slotId ?? '');
        if (identical(slot?.shake, tween)) slot?.shake = null;
      case RepitchTween(:final to):
        // Only the re-pitch still on screen commits: a later one, a resize
        // (which committed its own layout) or a reset superseded it.
        if (identical(scene.repitch, tween)) {
          scene.repitch = null;
          _commit(to);
        }
    }
    for (final id in tween.hides) {
      scene.slot(id)?.show();
    }
  }

  SlotView _viewOf(String slotId) {
    final board = _latestBoard;
    return board == null ? SlotView.empty : SlotView.of(board, slotId);
  }

  /// A board reset (§7 `BoardResetEffect`): every clip back to its pool,
  /// every tween and hide gone, the slots rebuilt from [snapshot] on
  /// [layout] (glass on frame 0, ice on its stage).
  void _reset(GameState snapshot, BoardGeometry layout) {
    fx
      ..stopAll()
      ..buildPools(library);
    scene
      ..repitch = null
      ..hint = null
      // A drag held by another finger ends here (undo, restart or a new
      // level from a second finger): its doll is back at rest, and its
      // release sends nothing (review CORRECTNESS-2).
      ..dragSlotId = null;
    _dragPointer = null;
    _dropBase = null;
    hint.show(null);
    final reuse = identical(scene.geometry, layout);
    if (!reuse) {
      // A new level: the last one's slots stop drawing in this very frame
      // (Flame drops them only at the next tick), and the new ones draw in
      // it too (`_UnmountedSlots` until Flame mounts them).
      for (final slot in _slotList) {
        slot
          ..retire()
          ..removeFromParent();
      }
      _slotList.clear();
      _slots.clear();
      scene
        ..clearSlots()
        ..geometry = layout;
      shelf.relayout();
      for (final g in layout.slots) {
        _addSlot(g, SlotView.of(snapshot, g.id));
      }
    }
    for (final slot in scene.slots) {
      slot
        ..clearHides()
        ..pulses = 0
        ..shake = null
        ..reveal = null
        ..from = null;
      if (reuse) slot.setView(SlotView.of(snapshot, slot.id));
    }
    if (reuse) {
      for (final component in _slotList) {
        component.buildCompositions(library, reducedMotion: !_motion.shake);
      }
    }
    _ensureGlass();
  }

  /// Adds the slot of [g] showing [view], with its glass or ice composition
  /// on its rest frame (§8).
  void _addSlot(SlotGeometry g, SlotView view) {
    final state = SlotState(g.id, g)..setView(view);
    scene.addSlot(state);
    final component = SlotComponent(
      scene,
      state,
      priority: slotPriority + g.index,
    );
    _slots[g.id] = component;
    _slotList.add(component);
    add(component);
    component.buildCompositions(library, reducedMotion: !_motion.shake);
  }

  /// Commits [layout] now: the slots move onto it, new ones appear, the
  /// compositions and the hint follow.
  void _commit(BoardGeometry layout) {
    scene.geometry = layout;
    for (final g in layout.slots) {
      final slot = scene.slot(g.id);
      if (slot == null) {
        _addSlot(g, _viewOf(g.id));
      } else {
        slot.setGeometry(g);
      }
    }
    for (final component in _slotList) {
      final g = layout.slotOrNull(component.slotId);
      component.priority = slotPriority + (g?.index ?? 0);
      component.relayout();
    }
    scene.sortSlots();
    shelf.relayout();
    hint.rebuild();
  }

  /// The viewport changed under a level: move everything onto [layout] now
  /// (no re-pitch), lasting clips included. A re-pitch still running is
  /// settled here: its end won't commit the layout it was heading for.
  void _relayout(BoardGeometry layout) {
    scene.repitch = null;
    _commit(layout);
    _timeline?.relayout(layout);
    onLayout?.call(layout);
  }

  /// Everything scheduled has played: every slot must show what core says
  /// (a sync a batch didn't plan is fixed here), then tell the page.
  void _becameIdle() {
    _reconcile();
    if (_upgradePending) _upgradeCompositions();
    onBoardIdle?.call();
  }

  void _reconcile() {
    final board = _latestBoard;
    if (board == null) return;
    for (final component in _slotList) {
      final slot = component.slot;
      final view = SlotView.of(board, slot.id);
      if (view == slot.view) continue;
      if (kDebugMode) {
        debugPrint('[nesty.board] reconcile ${slot.id}: ${slot.view} → $view');
      }
      final rebuild =
          view.locked != slot.view.locked || view.frozen != slot.view.frozen;
      slot.setView(view);
      if (rebuild) {
        component.buildCompositions(library, reducedMotion: !_motion.shake);
      }
    }
  }

  // ── Input (forwarded only, CLAUDE.md rule 10) ──

  /// The slot whose column holds ([x], [y]) (board px), or null: the whole
  /// column is the hit area, at least 48 dp; where 48 dp columns overlap,
  /// the nearest centre wins (spec §10.3).
  String? slotIdAt(double x, double y) {
    final g = scene.geometry;
    if (g == null) return null;
    final index = g.slotIndexAt(x, y);
    return index < 0 ? null : g.slots[index].id;
  }

  bool _accepts(String slotId) {
    if (_paused || _overlayOpen) return false;
    return _timeline?.acceptsInput(slotId) ?? false;
  }

  @override
  void onTapUp(TapUpEvent event) {
    final p = event.canvasPosition;
    handleTap(p.x, p.y);
  }

  /// A tap at ([x], [y]): `SlotTapped` unless nothing is there or the slot
  /// drops input now. Returns the slot the tap went to.
  @visibleForTesting
  String? handleTap(double x, double y) {
    final id = slotIdAt(x, y);
    if (id == null || !_accepts(id)) return null;
    onIntent?.call(SlotTapped(id));
    return id;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final p = event.canvasPosition;
    beginDrag(event.pointerId, p.x, p.y);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    final p = event.canvasEndPosition;
    moveDrag(event.pointerId, p.x, p.y);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    endDrag(event.pointerId);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    // Cancelled: the doll goes back (a drop over nothing).
    endDrag(event.pointerId, cancelled: true);
    super.onDragCancel(event);
  }

  /// A drag began at ([x], [y]) with [pointer]: `SlotDragStarted` on the
  /// slot under it, unless another drag is on or the slot drops input.
  @visibleForTesting
  bool beginDrag(int pointer, double x, double y) {
    if (_dragPointer != null) return false;
    final id = slotIdAt(x, y);
    if (id == null || !_accepts(id)) return false;
    final slot = scene.slot(id);
    if (slot == null) return false;
    // A drop the bloc ignored (a drag from an unpickable slot) left its
    // base behind; this drag's own drop replaces it.
    _dropBase = null;
    _dragPointer = pointer;
    _fingerStartX = _fingerX = x;
    _fingerStartY = _fingerY = y;
    _baseStartX = slot.geometry.centerX;
    _baseStartY = slot.restBaseY(null);
    scene
      ..dragSlotId = id
      ..dragBaseX = _baseStartX
      ..dragBaseY = _baseStartY;
    onIntent?.call(SlotDragStarted(id));
    return true;
  }

  // ── Hot path: runs per pointer move. No allocation (CLAUDE.md rule 8). ──

  /// The finger moved to ([x], [y]): the dragged base moves with it,
  /// clamped to the board frame (§5, R6). While paused the doll stays where
  /// it is drawn, so a release during the pause flies it home from there
  /// (review CORRECTNESS-3).
  @visibleForTesting
  void moveDrag(int pointer, double x, double y) {
    if (pointer != _dragPointer || _paused) return;
    _fingerX = x;
    _fingerY = y;
    final frame = scene.geometry?.fit.frame;
    var bx = _baseStartX + x - _fingerStartX;
    var by = _baseStartY + y - _fingerStartY;
    if (frame != null) {
      if (bx < frame.left) bx = frame.left;
      if (bx > frame.right) bx = frame.right;
      if (by < frame.top) by = frame.top;
      if (by > frame.bottom) by = frame.bottom;
    }
    scene
      ..dragBaseX = bx
      ..dragBaseY = by;
  }

  // ── End of hot path. ──

  /// The drag with [pointer] ended: `SlotDragDropped` with the slot under
  /// the finger, or null when [cancelled], over nothing, or over a slot
  /// that drops input now. Returns the slot sent.
  @visibleForTesting
  String? endDrag(int pointer, {bool cancelled = false}) {
    if (pointer != _dragPointer) return null;
    _dragPointer = null;
    var target = cancelled ? null : slotIdAt(_fingerX, _fingerY);
    if (target != null && !_accepts(target)) target = null;
    _dropBase = Offset(scene.dragBaseX, scene.dragBaseY);
    scene.dragSlotId = null;
    onIntent?.call(SlotDragDropped(target));
    return target;
  }

  /// Whether a drag is in progress.
  bool get isDragging => _dragPointer != null;
}

final class _Pending {
  _Pending(this.effect, this.board);

  final BoardEffect effect;
  final GameState board;
}

/// Draws the board's slots that Flame hasn't mounted yet, just under the
/// mounted ones (§10.1). A component added during `update` (a new level's
/// slots, the one +1 Slot adds) is mounted only at the start of the next
/// tick, so without this the frame it was built in would show the new
/// shelves with no dolls on them. Everything added to an unmounted slot is
/// attached to it at once, so its whole tree draws. From its first mounted
/// tick on, Flame draws it in its own place and this skips it.
class _UnmountedSlots extends Component {
  _UnmountedSlots(this._slots, {super.priority});

  final List<SlotComponent> _slots;

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < _slots.length; i++) {
      final slot = _slots[i];
      if (!slot.isMounted) slot.renderTree(canvas);
    }
  }

  // ── End of hot path. ──
}
