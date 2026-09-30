part of 'board_timeline.dart';

/// The per-effect plans of docs/plans/m2-lottie-design.md §7 (the table),
/// §9 (hand-coded motions) and §10 (hand-off). Each writes one batch; times
/// are real ms from the batch start, derived from the files' frames.
extension _Plans on BoardTimeline {
  // ── Shared pieces ──

  double get _s => _geometry.scale;

  double _height(int size) => _geometry.dollHeight(size);

  Offset _ref(double x, double y) => _geometry.fit.toReference(x, y);

  /// A dragged doll's base in reference units, clamped to the board frame
  /// so a `doll_move` from the finger never starts outside its canvas (§5,
  /// R6). The board clamps it already; this keeps the timeline safe alone.
  Offset _dragRef(Offset base) {
    final frame = _geometry.fit.frame;
    return _ref(
      base.dx.clamp(frame.left, frame.right),
      base.dy.clamp(frame.top, frame.bottom),
    );
  }

  /// A doll's base in its slot: the case floor only while the slot is still
  /// a `LockedSlot` in [view] (a broken lock reads back as open, §8).
  double _baseY(SlotGeometry slot, Slot? view) =>
      view is LockedSlot ? slot.lockedDollBaseY : slot.surfaceY;

  Nest? _topOf(Slot view) => switch (view) {
    OpenSlot(:final nest) => nest,
    TowerSlot(:final top) => top,
    LockedSlot(:final nest) => nest,
  };

  Slot? _viewOf(GameState board, String slotId) =>
      board.slotIds.contains(slotId) ? board.slot(slotId) : null;

  /// The nest standing on [slotId] in [board], or null when it is empty.
  Nest? _topOfSlot(GameState board, String slotId) {
    final view = _viewOf(board, slotId);
    return view == null ? null : _topOf(view);
  }

  /// The nests [slotId]'s tower buried at the start of the level, for the
  /// silhouette spacing (`SlotGeometry.buriedBaseY`, review RENDER-4).
  int _buriedAtStart(GameState board, String slotId) {
    if (SlotId.isExtra(slotId)) return 0;
    final initial = board.level.slot(slotId);
    return initial is TowerSlot ? initial.hiddenCount : 0;
  }

  /// The tallest size [slotId]'s tower held at the start of the level, and
  /// whether it started iced: the rest of the tower stack's inputs
  /// (`SlotGeometry.towerStack`), so the reveal moves the same silhouettes
  /// the slot draws.
  ({int? topSize, bool iced}) _stackInputs(GameState board, String slotId) {
    if (SlotId.isExtra(slotId)) return (topSize: null, iced: false);
    final initial = board.level.slot(slotId);
    if (initial is! TowerSlot) return (topSize: null, iced: false);
    var tallest = 0;
    for (final nest in initial.stack) {
      if (nest.outerSize > tallest) tallest = nest.outerSize;
    }
    return (topSize: tallest, iced: initial.isFrozen);
  }

  /// Plays `fx_select_glow`'s `out` on [glow] from [at] and returns it to
  /// its pool when it ends.
  void _glowOut(_Batch b, _Track glow, double at) {
    final out = FxSegment.marker(
      _spec(FxId.fxSelectGlow),
      'out',
      speed: motion.oneShotSpeed,
    );
    b
      ..command(PlayClipSegment(at, glow.clip, out), track: glow)
      ..command(StopClip(at + out.durationMs, glow.clip), track: glow);
  }

  /// Starts `fx_select_glow` on [slot] for [purpose]: `in`, then the `pulse`
  /// loop at 1× (informational, §13).
  _Track _glowIn(
    _Batch b,
    SlotGeometry slot,
    FxClipPurpose purpose,
    double at, {
    double opacity = 1,
  }) {
    final spec = _spec(FxId.fxSelectGlow);
    final glow = _newClip(
      b,
      FxId.fxSelectGlow,
      purpose,
      FxPlacement.anchored(FxAnchor.glow, _geometry, slot),
      params: opacity == 1 ? FxClipParams.none : FxClipParams(opacity: opacity),
      slotId: slot.id,
      anchor: FxAnchor.glow,
    );
    final inSegment = FxSegment.marker(spec, 'in', speed: motion.oneShotSpeed);
    final pulse = FxSegment.marker(
      spec,
      'pulse',
      loop: true,
      speed: motion.informationalLoopSpeed,
    );
    b
      ..command(StartClip(at, glow.clip, inSegment), track: glow)
      ..command(
        PlayClipSegment(at + inSegment.durationMs, glow.clip, pulse),
        track: glow,
      );
    return glow;
  }

  FxClipParams _pickParams(Nest nest, BoardGeometry geometry) => FxClipParams(
    doll: nest.color,
    dollScale: LottieGeometry.roleScale(
      geometry.dollHeight(nest.outerSize),
      geometry.scale,
    ),
  );

  /// `doll_move` of [nest] from [from] to [to] (reference units), from
  /// [at]; hides [hides] while it flies. Returns its end.
  double _flight(
    _Batch b,
    Nest nest,
    Offset from,
    Offset to, {
    required double at,
    String? slotId,
    List<String> hides = const [],
  }) {
    final segment = FxSegment.whole(
      _spec(FxId.dollMove),
      speed: motion.oneShotSpeed,
    );
    final move = _newClip(
      b,
      FxId.dollMove,
      FxClipPurpose.move,
      FxPlacement.boardSpace(_geometry.fit),
      params: FxClipParams(
        doll: nest.color,
        dollScale: LottieGeometry.roleScale(_height(nest.outerSize), _s),
        travelFrom: from,
        travelTo: to,
      ),
      slotId: slotId,
      hides: hides,
    );
    final end = at + segment.durationMs;
    b
      ..command(StartClip(at, move.clip, segment), track: move)
      ..command(StopClip(end, move.clip), track: move);
    return end;
  }

  // ── Selection (tap policy, frame 2.6) ──

  void _planSelection(
    _Batch b,
    SelectionChangedEffect e,
    GameState board,
    Offset? dragBase,
  ) {
    final selected = e.selected;
    final current = _selection;
    if (current != null && current.slotId != selected) {
      final dragCancel =
          e.byDrag &&
          selected == null &&
          e.previous == current.slotId &&
          dragBase != null;
      if (dragCancel) {
        _planDragReturn(b, current.slotId, board, dragBase, current);
      } else {
        _planSettle(b, current);
      }
      _selection = null;
    } else if (current == null &&
        e.byDrag &&
        selected == null &&
        e.previous != null &&
        dragBase != null) {
      // A drag whose lift the timeline never saw (a reset in between).
      _planDragReturn(b, e.previous!, board, dragBase, null);
    }
    if (selected == null) return;
    final lifted = _selection;
    if (lifted != null && lifted.slotId == selected) {
      // A drag picks up the nest a tap already lifted: no second lift and
      // no second pick cue, it just stops wobbling (§7 "Drag start").
      if (e.byDrag) {
        b.command(
          PlayClipSegment(
            0,
            lifted.pick.clip,
            FxSegment.holdEndOf(_spec(FxId.dollPick), 'lift'),
          ),
          track: lifted.pick,
        );
      }
      return;
    }
    _planLift(b, selected, board, byDrag: e.byDrag);
  }

  /// `doll_pick` lift then wobble (or hold `lift`'s last frame while dragged
  /// and under reduced motion); `fx_select_glow` in then pulse; `pick` @0.
  void _planLift(
    _Batch b,
    String slotId,
    GameState board, {
    required bool byDrag,
  }) {
    final slot = _geometry.slotOrNull(slotId);
    final view = _viewOf(board, slotId);
    final nest = view == null ? null : _topOf(view);
    if (slot == null || nest == null) return;
    final settling = _settling.remove(slotId);
    if (settling != null) {
      b
        ..command(StopClip(0, settling.pick.clip), track: settling.pick)
        ..command(StopClip(0, settling.glow.clip), track: settling.glow);
    }
    final spec = _spec(FxId.dollPick);
    final pick = _newClip(
      b,
      FxId.dollPick,
      FxClipPurpose.selection,
      FxPlacement.anchored(FxAnchor.dollBase, _geometry, slot),
      params: _pickParams(nest, _geometry),
      slotId: slotId,
      anchor: FxAnchor.dollBase,
      hides: [slotId],
    );
    final lift = FxSegment.marker(spec, 'lift', speed: motion.oneShotSpeed);
    final next = byDrag || !motion.wobble
        ? FxSegment.holdEndOf(spec, 'lift')
        : FxSegment.marker(spec, 'wobble', loop: true);
    b
      ..command(StartClip(0, pick.clip, lift), track: pick)
      ..command(PlayClipSegment(lift.durationMs, pick.clip, next), track: pick);
    final glow = _glowIn(b, slot, FxClipPurpose.selectionGlow, 0);
    b.cue(
      const FxCue(atMs: 0, sound: SoundEffect.pick, haptic: HapticPattern.pick),
    );
    _selection = _Selection(slotId: slotId, nest: nest, pick: pick, glow: glow);
  }

  /// Deselect: `doll_pick` settle and glow out, no cue (§7).
  void _planSettle(_Batch b, _Selection selection) {
    final settle = FxSegment.marker(
      _spec(FxId.dollPick),
      'settle',
      speed: motion.oneShotSpeed,
    );
    final pick = selection.pick;
    b
      ..command(PlayClipSegment(0, pick.clip, settle), track: pick)
      ..command(StopClip(settle.durationMs, pick.clip), track: pick);
    _glowOut(b, selection.glow, 0);
    _settling[selection.slotId] = selection;
  }

  /// Drag cancel (§9.4): the doll flies from the finger back to its base by
  /// `doll_move`; the glow goes out. The slot is reserved for the flight.
  void _planDragReturn(
    _Batch b,
    String slotId,
    GameState board,
    Offset dragBase,
    _Selection? selection,
  ) {
    if (selection != null) {
      b.command(StopClip(0, selection.pick.clip), track: selection.pick);
      _glowOut(b, selection.glow, 0);
    }
    final slot = _geometry.slotOrNull(slotId);
    final view = _viewOf(board, slotId);
    final nest = view == null ? null : _topOf(view);
    if (slot == null || nest == null) return;
    final end = _flight(
      b,
      nest,
      _dragRef(dragBase),
      _ref(slot.centerX, slot.surfaceY),
      at: 0,
      slotId: slotId,
      hides: [slotId],
    );
    b.reserve(slotId, end);
  }

  // ── An applied move (spec §4 event order) ──

  void _planMove(
    _Batch b,
    MoveAppliedEffect e,
    GameState board,
    Offset? dragBase,
  ) {
    final result = e.result;
    final src = result.move.from;
    final dst = result.move.to;
    Picked? picked;
    Placed? placed;
    NestedInto? nested;
    Revealed? revealSource;
    Revealed? revealTarget;
    Completed? completed;
    Won? won;
    var outOfMoves = false;
    final slotEvents = <MoveEvent>[];
    for (final event in result.events) {
      switch (event) {
        case Picked():
          picked = event;
        case Placed():
          placed = event;
        case NestedInto():
          nested = event;
        case Revealed():
          if (completed == null && event.slotId == src) {
            revealSource = event;
          } else {
            revealTarget = event;
          }
        case Completed():
          completed = event;
        case Unlocked() || IceCracked() || IceShattered():
          slotEvents.add(event);
        case Won():
          won = event;
        case OutOfMoves():
          outOfMoves = true;
      }
    }
    final moving = placed?.nest ?? nested?.moving ?? picked?.nest;
    final gSrc = _geometry.slotOrNull(src);
    final gDst = _geometry.slotOrNull(dst);

    // 0: the lifted nest hands over from doll_pick to doll_move in the same
    // frame; its glow goes out.
    final selection = _selection;
    if (selection != null) {
      if (selection.slotId == src) {
        b.command(StopClip(0, selection.pick.clip), track: selection.pick);
        _glowOut(b, selection.glow, 0);
      } else {
        _planSettle(b, selection);
      }
      _selection = null;
    }
    b
      ..cue(const FxCue(atMs: 0, sound: SoundEffect.whoosh))
      // The source shows what it holds now (empty, or the tower's rest):
      // the moving doll is in the flight clip.
      ..command(SyncSlot(0, src, board));
    var sourceFree = 0.0;
    final reveal = revealSource;
    if (reveal != null) {
      sourceFree = _planReveal(b, reveal, board, at: 0);
    }

    var landed = 0.0;
    if (moving != null && gSrc != null && gDst != null) {
      final from = e.byDrag && dragBase != null
          ? _dragRef(dragBase)
          : _ref(gSrc.centerX, gSrc.surfaceY);
      final into = nested;
      final Offset to;
      if (into == null) {
        to = _ref(gDst.centerX, gDst.surfaceY);
      } else {
        final fraction = into.direction == NestDirection.inside
            ? LottieGeometry.nestHoverFraction
            : LottieGeometry.swallowHoverFraction;
        final targetHeight = _height(into.target.outerSize);
        to = _ref(gDst.centerX, gDst.surfaceY - fraction * targetHeight);
      }
      landed = _flight(b, moving, from, to, at: 0, slotId: src);
      if (into != null) {
        landed = _planNest(b, into, gDst, at: landed);
      }
    }
    if (completed == null) b.command(SyncSlot(landed, dst, board));
    b
      ..reserve(src, math.max(landed, sourceFree))
      ..reserve(dst, landed);
    if (moving != null) {
      // E.16: a doll standing on the +1 Slot's pad stops its pulse, and the
      // pulse restarts once the pad is empty again.
      if (SlotId.isExtra(dst)) _settlePulse(b, dst, landed);
      if (SlotId.isExtra(src) && _topOfSlot(board, src) == null) {
        _restartPulse(b, src, 0);
      }
    }

    final done = completed;
    if (done != null && SlotId.isExtra(dst) && _topOfSlot(board, dst) == null) {
      // The completed set leaves the pad when it flies.
      _restartPulse(
        b,
        dst,
        landed + b.at(FxSpec.msOf(FxTiming.completeFlyFrame)),
      );
    }
    if (done != null && gDst != null) {
      _planComplete(
        b,
        done,
        board,
        gDst,
        size: nested?.merged.outerSize ?? _geometry.shape.maxSize,
        t0: landed,
        reveal: revealTarget,
        slotEvents: slotEvents,
      );
    }
    final win = won;
    if (win != null) _planWon(b, win);
    if (outOfMoves) _planOutOfMoves(b);
  }

  /// `doll_nest` or `doll_swallow` on the target from [at]: both dolls are
  /// in the file, so the target's sprite hides; `clack` (the merged outer
  /// size) and the nest haptic when the lid shuts. Returns its end.
  double _planNest(
    _Batch b,
    NestedInto into,
    SlotGeometry target, {
    required double at,
  }) {
    final fx = into.direction == NestDirection.inside
        ? FxId.dollNest
        : FxId.dollSwallow;
    final segment = FxSegment.whole(_spec(fx), speed: motion.oneShotSpeed);
    final moverHeight = _height(into.moving.outerSize);
    final targetHeight = _height(into.target.outerSize);
    final nest = _newClip(
      b,
      fx,
      FxClipPurpose.nest,
      FxPlacement.anchored(FxAnchor.dollBase, _geometry, target),
      params: FxClipParams(
        mover: into.moving.color,
        target: into.target.color,
        moverScale: LottieGeometry.nestedMoverScale(moverHeight, targetHeight),
        targetScale: LottieGeometry.roleScale(targetHeight, _s),
        // Merges are one colour: the rim is the nest's (`target_rim` in
        // doll_nest, `mover_rim` in doll_swallow).
        rim: into.merged.color,
      ),
      slotId: into.slotId,
      anchor: FxAnchor.dollBase,
      hides: [into.slotId],
    );
    final end = at + segment.durationMs;
    b
      ..command(StartClip(at, nest.clip, segment), track: nest)
      ..command(StopClip(end, nest.clip), track: nest)
      ..cue(
        FxCue(
          atMs: at + b.at(FxSpec.msOf(FxTiming.nestClackFrame)),
          sound: SoundEffect.clack,
          haptic: HapticPattern.nest,
          dollSize: into.merged.outerSize,
        ),
      );
    return end;
  }

  /// `doll_reveal` from its first frame at [at] (LOTTIE.md v3): its `drop`
  /// null lowers the new top from its buried step onto the stand (frames
  /// 0–7, the step set for this tower), then the wipe paints it (7–19) and
  /// the splash drops fade (to 31). The nests still buried shift one step
  /// down with the drop (§9.1, D21). Returns the reveal's end. The caller
  /// syncs the slot at [at] (the "+N" tag counts down there).
  double _planReveal(
    _Batch b,
    Revealed reveal,
    GameState board, {
    required double at,
  }) {
    final slot = _geometry.slotOrNull(reveal.slotId);
    if (slot == null) return at;
    final buried = _buriedAtStart(board, reveal.slotId);
    final inputs = _stackInputs(board, reveal.slotId);
    final segment = FxSegment.whole(
      _spec(FxId.dollReveal),
      speed: motion.oneShotSpeed,
    );
    final clip = _newClip(
      b,
      FxId.dollReveal,
      FxClipPurpose.reveal,
      FxPlacement.anchored(FxAnchor.dollBase, _geometry, slot),
      params: FxClipParams(
        doll: reveal.nest.color,
        dollScale: LottieGeometry.roleScale(_height(reveal.nest.outerSize), _s),
        tint: reveal.nest.color,
        // The new top was buried at depth 1: the file picks it up there.
        revealDrop:
            (slot.surfaceY -
                slot.buriedBaseY(
                  1,
                  buried: buried,
                  topSize: inputs.topSize,
                  iced: inputs.iced,
                )) /
            _s,
      ),
      slotId: reveal.slotId,
      anchor: FxAnchor.dollBase,
      hides: [reveal.slotId],
    );
    final shift = RevealDropTween(
      slot: slot,
      buried: buried,
      topSize: inputs.topSize,
      iced: inputs.iced,
      durationMs: b.at(FxSpec.msOf(FxTiming.revealDropEndFrame)),
    );
    final end = at + segment.durationMs;
    b
      ..command(StartClip(at, clip.clip, segment), track: clip)
      ..command(StartTween(at, shift))
      ..command(EndTween(at + shift.durationMs, shift))
      ..command(StopClip(end, clip.clip), track: clip);
    return end;
  }

  /// `Completed` at [t0] (the landing's end): `doll_complete` (shine, hops,
  /// fly), dust and the sparkle trail when it flies (t0 + 700), the family
  /// counter when it lands (t0 + 1250), then a destination reveal and the
  /// slot events, 80 ms apart, from the fly.
  void _planComplete(
    _Batch b,
    Completed done,
    GameState board,
    SlotGeometry slot, {
    required int size,
    required double t0,
    required Revealed? reveal,
    required List<MoveEvent> slotEvents,
  }) {
    final spec = _spec(FxId.dollComplete);
    final segment = FxSegment.whole(spec, speed: motion.oneShotSpeed);
    final height = _height(size);
    final counter = _geometry.familyCounterTargetReference;
    assert(
      _geometry.familyCounterInBoardSpace,
      'the family counter is above the board-space canvas (§5)',
    );
    final complete = _newClip(
      b,
      FxId.dollComplete,
      FxClipPurpose.complete,
      FxPlacement.boardSpace(_geometry.fit),
      params: FxClipParams(
        doll: done.color,
        dollScale: LottieGeometry.roleScale(height, _s),
        travelFrom: _ref(slot.centerX, slot.surfaceY),
        travelTo: Offset(
          counter.dx,
          counter.dy + LottieGeometry.counterDropFraction * height / _s,
        ),
      ),
      slotId: done.slotId,
      hides: [done.slotId],
    );
    final fly = t0 + b.at(FxSpec.msOf(FxTiming.completeFlyFrame));
    final landed = t0 + segment.durationMs;
    final step = combo.register(delayMs: t0);
    b
      ..command(StartClip(t0, complete.clip, segment), track: complete)
      ..cue(
        FxCue(
          atMs: t0,
          sound: SoundEffect.complete,
          haptic: HapticPattern.complete,
          comboStep: step,
        ),
      )
      // The set leaves its slot: the slot shows its new rest look.
      ..command(ReleaseClipSlots(fly, complete.clip), track: complete)
      ..command(SyncSlot(fly, done.slotId, board));

    final dustSegment = FxSegment.whole(
      _spec(FxId.fxDustPuff),
      speed: motion.oneShotSpeed,
    );
    final dust = _newClip(
      b,
      FxId.fxDustPuff,
      FxClipPurpose.dust,
      FxPlacement.anchored(FxAnchor.surface, _geometry, slot),
      slotId: done.slotId,
      anchor: FxAnchor.surface,
    );
    b
      ..command(StartClip(fly, dust.clip, dustSegment), track: dust)
      ..command(StopClip(fly + dustSegment.durationMs, dust.clip), track: dust);

    final sparkleSegment = FxSegment.whole(
      _spec(FxId.fxSparkle),
      speed: motion.oneShotSpeed,
    );
    final interval = b.at(FxTiming.sparkleIntervalMs);
    for (var k = 0; fly + k * interval < landed - BoardTimeline._epsilon; k++) {
      final at = fly + k * interval;
      final sparkle = _newClip(
        b,
        FxId.fxSparkle,
        FxClipPurpose.sparkle,
        FxPlacement.trail(clipId: complete.clip.id, scale: _s),
      );
      b
        ..command(
          StartClip(at, sparkle.clip, sparkleSegment),
          track: sparkle,
          trailOf: complete,
        )
        ..command(
          StopClip(at + sparkleSegment.durationMs, sparkle.clip),
          track: sparkle,
          holdsBatch: false,
        );
    }
    b
      ..command(StopClip(landed, complete.clip), track: complete)
      ..command(
        FamilyLanded(
          landed,
          setsCompleted: done.setsCompleted,
          totalSets: done.totalSets,
        ),
      )
      // The HUD's counter bump is part of the batch (Won waits for it).
      ..extend(
        landed +
            FxSegment.marker(
              _spec(FxId.uiFamilyCounter),
              'bump',
              speed: motion.oneShotSpeed,
            ).durationMs,
      )
      ..reserve(done.slotId, fly);

    final uncovered = reveal;
    if (uncovered != null) {
      b.reserve(done.slotId, _planReveal(b, uncovered, board, at: fly));
    }

    final stagger = b.at(FxTiming.slotEventStaggerMs);
    for (var k = 0; k < slotEvents.length; k++) {
      _planSlotEvent(b, slotEvents[k], board, at: fly + k * stagger);
    }
  }

  /// The k-th `Unlocked`, `IceCracked` or `IceShattered` of a completion, on
  /// its slot's paused composition (§8). The slot syncs at the start (the
  /// badge counts down); its composition keeps drawing until it's released.
  void _planSlotEvent(
    _Batch b,
    MoveEvent event,
    GameState board, {
    required double at,
  }) {
    switch (event) {
      case Unlocked(:final slotId):
        // A sealed size-5 or size-6 doll has the tall case and its own file
        // (same 54 frames and timing).
        final glass = _geometry.slotOrNull(slotId)?.usesTallCase ?? false
            ? FxId.fxGlassUnlockTall
            : FxId.fxGlassUnlock;
        final segment = FxSegment.whole(
          _spec(glass),
          speed: motion.oneShotSpeed,
        );
        final end = at + segment.durationMs;
        b
          ..command(SyncSlot(at, slotId, board))
          ..command(PlaySlotFx(at, slotId, glass, segment))
          ..cue(
            FxCue(
              atMs: at,
              sound: SoundEffect.unlockGlass,
              haptic: HapticPattern.unlock,
            ),
          )
          ..command(ReleaseSlotFx(end, slotId, glass))
          ..reserve(slotId, end);
      case IceCracked(:final slotId, :final remaining):
        b
          ..command(SyncSlot(at, slotId, board))
          ..cue(
            FxCue(
              atMs: at,
              sound: SoundEffect.iceCrack,
              haptic: HapticPattern.iceCrack,
            ),
          );
        final initial = SlotId.isExtra(slotId)
            ? 0
            : board.level.slot(slotId).ice;
        if (initial < 1) {
          b.reserve(slotId, at);
          return;
        }
        // At most one set completes per move, so every counter drops by
        // exactly one (spec §3.4, §4).
        final from = BoardLayout.iceFrame(
          remaining: remaining + 1,
          initial: initial,
        );
        final to = BoardLayout.iceFrame(remaining: remaining, initial: initial);
        final spec = _spec(FxId.fxIce);
        // A new stage cracks to it; a hit that cracks nothing new (a counter
        // with more hits than stages) shakes and flashes the stage shown
        // (LOTTIE.md v3). Either way the ice then rests on `rest_n`.
        final marker = spec.marker(
          to > from ? FxIceSegments.crack(to) : FxIceSegments.crackHit(to),
        );
        if (marker == null) {
          // An export without the segment (rule 3): no clip, as D51 did;
          // the cue and the badge still count.
          b.reserve(slotId, at);
          return;
        }
        final segment = FxSegment(
          marker.start,
          marker.end,
          speed: motion.oneShotSpeed,
        );
        final end = at + segment.durationMs;
        b
          ..command(
            PlaySlotFx(at, slotId, FxId.fxIce, segment, shake: motion.shake),
          )
          ..command(
            PlaySlotFx(
              end,
              slotId,
              FxId.fxIce,
              FxSegment.hold(FxIceSegments.restFrame(spec, to)),
            ),
          )
          ..reserve(slotId, end);
      case IceShattered(:final slotId):
        final segment = FxSegment.marker(
          _spec(FxId.fxIce),
          FxIceSegments.shatter,
          speed: motion.oneShotSpeed,
        );
        final end = at + segment.durationMs;
        b
          ..command(SyncSlot(at, slotId, board))
          // D49: no haptic.
          ..cue(FxCue(atMs: at, sound: SoundEffect.iceShatter))
          ..command(
            PlaySlotFx(at, slotId, FxId.fxIce, segment, shake: motion.shake),
          )
          ..command(ReleaseSlotFx(end, slotId, FxId.fxIce))
          ..reserve(slotId, end);
        _planTagPop(b, slotId, board, at: at);
      default:
        break;
    }
  }

  /// The "+N" tag of a tower whose ice just shattered pops in with the
  /// shatter (frame 48, 0 ms into its segment): 240 ms from 60 % scale,
  /// `easeOutBack` (tokens `motion.tagPop`). The slot's `SyncSlot` at [at]
  /// shows the tag; the tween scales it.
  void _planTagPop(
    _Batch b,
    String slotId,
    GameState board, {
    required double at,
  }) {
    final view = _viewOf(board, slotId);
    if (view is! TowerSlot || view.hiddenCount < 1) return;
    final pop = TagPopTween(
      slotId: slotId,
      durationMs: b.at(MotionTokens.tagPopMs.toDouble()),
    );
    b
      ..command(StartTween(at, pop))
      ..command(EndTween(at + pop.durationMs, pop));
  }

  // ── Tap feedback (E.13, frame 12.13) ──

  /// A tap on an unpickable slot with nothing lifted: the stand dips 2 dp
  /// for 80 ms with a light haptic, the sealed case's padlock pings 1.15×
  /// for 160 ms, the ice counter bumps 1.2× for 160 ms. Never the invalid
  /// shake, no sound, and nothing is reserved: the next tap plays at once.
  /// Reduced motion halves the durations (the batch's scale).
  void _planNudge(_Batch b, SlotNudgeEffect e) {
    if (_geometry.slotOrNull(e.slotId) == null) return;
    final ms = switch (e.kind) {
      SlotNudgeKind.emptyStand => MotionTokens.tapDipMs,
      SlotNudgeKind.lockedCase => MotionTokens.padlockPingMs,
      SlotNudgeKind.iced => MotionTokens.iceBumpMs,
    };
    final tween = NudgeTween(
      slotId: e.slotId,
      kind: e.kind,
      durationMs: b.at(ms.toDouble()),
    );
    b
      ..command(StartTween(0, tween))
      ..command(EndTween(tween.durationMs, tween));
    if (e.kind == SlotNudgeKind.emptyStand) {
      b.cue(const FxCue(atMs: 0, haptic: HapticPattern.pick));
    }
  }

  /// Won: input locks now; `onWon` fires when everything playing is done,
  /// + 250 ms (§7).
  void _planWon(_Batch b, Won won) {
    final end = math.max(_busyUntil, b.startMs + b.end) - b.startMs;
    b
      ..command(
        BoardWon(end + b.at(FxTiming.wonDelayMs), moveCount: won.moveCount),
      )
      ..locksInput = true;
    _won = true;
  }

  /// OutOfMoves: `onOutOfMoves` when the board goes idle.
  void _planOutOfMoves(_Batch b) {
    final end = math.max(_busyUntil, b.startMs + b.end) - b.startMs;
    b.command(BoardOutOfMoves(end));
  }

  // ── A rejected move (D22) ──

  void _planRejected(
    _Batch b,
    MoveRejectedEffect e,
    GameState board,
    Offset? dragBase,
  ) {
    final src = e.source;
    final dst = e.target;
    final selection = _selection;
    if (selection != null) {
      if (selection.slotId == src) {
        b.command(StopClip(0, selection.pick.clip), track: selection.pick);
        _glowOut(b, selection.glow, 0);
      } else {
        _planSettle(b, selection);
      }
      _selection = null;
    }
    final gSrc = _geometry.slotOrNull(src);
    final gDst = _geometry.slotOrNull(dst);
    final srcView = _viewOf(board, src);
    final dstView = _viewOf(board, dst);
    if (gSrc == null || gDst == null || srcView == null || dstView == null) {
      return;
    }
    if (src == dst) return;
    final mover = _topOf(srcView);
    final target = _topOf(dstView);
    // The file only shakes a bare doll: a case, ice or a tower shakes by
    // hand instead, with the slot's own drawing (§9.3).
    final special =
        dstView is LockedSlot || dstView.isFrozen || dstView is TowerSlot;
    final moverHeight = mover == null ? 0.0 : _height(mover.outerSize);
    // TODO(design): an empty case or ice has no target doll; the drift uses
    // the mover's height.
    final targetHeight = target == null
        ? moverHeight
        : _height(target.outerSize);
    final targetBase = _baseY(gDst, dstView);
    // Without the finger's position there is nothing to fly back from: play
    // the tap variant.
    final dragged = e.byDrag && dragBase != null && mover != null;
    final segment = FxSegment.whole(
      _spec(FxId.dollInvalid),
      speed: motion.oneShotSpeed,
    );
    final invalid = _newClip(
      b,
      FxId.dollInvalid,
      FxClipPurpose.invalid,
      FxPlacement.boardSpace(_geometry.fit),
      params: FxClipParams(
        mover: mover?.color,
        target: target?.color,
        moverScale: LottieGeometry.roleScale(moverHeight, _s),
        targetScale: LottieGeometry.roleScale(targetHeight, _s),
        hideMover: dragged,
        hideTarget: special,
        travelFrom: _ref(gSrc.centerX, gSrc.surfaceY),
        travelTo: _ref(
          gDst.centerX,
          targetBase - LottieGeometry.invalidDriftFraction * targetHeight,
        ),
        targetPos: _ref(gDst.centerX, targetBase),
        shake: motion.shake,
      ),
      slotId: src,
      hides: [if (!dragged) src, if (!special && target != null) dst],
    );
    final end = segment.durationMs;
    b.command(StartClip(0, invalid.clip, segment), track: invalid);
    if (dragged) {
      // §9.4: the doll returns from the finger by doll_move; the invalid
      // file plays with its mover hidden.
      _flight(
        b,
        mover,
        _dragRef(dragBase),
        _ref(gSrc.centerX, gSrc.surfaceY),
        at: 0,
        slotId: src,
        hides: [src],
      );
    }
    final impact = b.at(FxSpec.msOf(FxTiming.invalidImpactFrame));
    b
      ..cue(
        FxCue(
          atMs: impact,
          sound: SoundEffect.bonk,
          haptic: HapticPattern.invalid,
        ),
      )
      ..command(StopClip(end, invalid.clip), track: invalid);
    if (special && motion.shake) {
      final start = b.at(FxSpec.msOf(FxTiming.invalidShakeStartFrame));
      final stop = b.at(FxSpec.msOf(FxTiming.invalidShakeEndFrame));
      final shake = ShakeTween(
        slotId: dst,
        amplitudeScale: _s,
        durationMs: stop - start,
      );
      b
        ..command(StartTween(start, shake))
        ..command(EndTween(stop, shake));
    }
    b
      ..reserve(src, end)
      ..reserve(dst, end);
  }

  // ── Drag hover (E.14, frame 12.13) ──

  /// Moves the drag hover's glow onto [slotId] (null: off): a legal stand
  /// under the finger of a dragged doll gets `fx_select_glow` at 60 %
  /// (tokens `motion.dragHover`, a pooled clip of its own), an illegal one
  /// nothing. The glow follows the stand, not the column. Per stand change,
  /// not per frame. Not a batch: it holds no input and keeps no order with
  /// the effects.
  void _planHover(_Batch b, String? slotId) {
    final old = _hover;
    if (old != null) {
      _glowOut(b, old.glow, 0);
      _hover = null;
    }
    final slot = slotId == null ? null : _geometry.slotOrNull(slotId);
    if (slot == null) return;
    const params = FxClipParams(opacity: MotionTokens.dragHoverGlowOpacity);
    final glow = _glowIn(
      b,
      slot,
      FxClipPurpose.hoverGlow,
      0,
      opacity: MotionTokens.dragHoverGlowOpacity,
    );
    _hover = _Hover(slotId: slot.id, glow: glow, params: params);
  }

  // ── Hint (frame 3.1) ──

  void _planHint(_Batch b, Move move, GameState board) {
    _planHintCleared(b);
    final source = _geometry.slotOrNull(move.from);
    final target = _geometry.slotOrNull(move.to);
    if (source == null || target == null) return;
    final view = _viewOf(board, move.from);
    final nest = view == null ? null : _topOf(view);
    final size = nest?.outerSize ?? _geometry.shape.maxSize;
    final arrow = _newClip(
      b,
      FxId.uiHintArrow,
      FxClipPurpose.hintArrow,
      FxPlacement.anchored(FxAnchor.hintArrow, _geometry, source, size: size),
      slotId: move.from,
      anchor: FxAnchor.hintArrow,
      anchorSize: size,
    );
    b.command(
      StartClip(
        0,
        arrow.clip,
        FxSegment.whole(
          _spec(FxId.uiHintArrow),
          loop: true,
          speed: motion.informationalLoopSpeed,
        ),
      ),
      track: arrow,
    );
    final glow = _glowIn(b, target, FxClipPurpose.hintGlow, 0);
    b.command(SetHintArc(0, move));
    _hint = _Hint(move: move, size: size, arrow: arrow, glow: glow);
  }

  void _planHintCleared(_Batch b) {
    final hint = _hint;
    if (hint == null) return;
    b.command(StopClip(0, hint.arrow.clip), track: hint.arrow);
    _glowOut(b, hint.glow, 0);
    b.command(const SetHintArc(0, null));
    _hint = null;
  }

  // ── +1 Slot (frame 3.6) ──

  void _planExtraSlot(
    _Batch b,
    ExtraSlotAddedEffect e,
    GameState board,
    BoardGeometry previous,
  ) {
    // No `button` cue here (BACKLOG "+1 Slot plays button twice"): whichever
    // button triggered this (the booster bar, the buy popup's confirm) is a
    // `TactileSurface` and already played `button` + the selection haptic
    // the moment it activated. Cueing it again here doubled it, because
    // this is the one board effect whose §7 cue happens to match a generic
    // button's own tactile feedback exactly.
    // A second +1 Slot while the first re-pitch still runs (a double tap)
    // waits for it: its re-pitch then starts from the layout the first one
    // ends on, where the row really is, instead of snapping the row there
    // mid-motion (review CORRECTNESS-4). Real ms, already scaled.
    final wait = math.max(0.0, _repitchUntil - _now);
    final duration = b.at(BoardLayoutConstants.extraSlotRepitchMs * 1.0);
    final end = wait + duration;
    if (!identical(previous, _geometry)) {
      final repitch = RepitchTween(
        from: previous,
        to: _geometry,
        durationMs: duration,
      );
      b
        ..command(StartTween(wait, repitch))
        ..command(EndTween(end, repitch));
    }
    b
      ..globalLock = end
      ..extend(end);
    _placeLasting(b, end);
    _startPulse(b, e.result.slotId, end);
  }

  /// `ui_extra_slot` on [slotId]'s stand, looping at 1× from [at], from the
  /// file's `rest` marker (frame 0), which is the static pad's own pose, so
  /// the hand-off has no pop (E.21, D184).
  void _startPulse(_Batch b, String slotId, double at) {
    final slot = _geometry.slotOrNull(slotId);
    if (slot == null) return;
    final pulse = _newClip(
      b,
      FxId.uiExtraSlot,
      FxClipPurpose.extraSlot,
      FxPlacement.anchored(FxAnchor.stand, _geometry, slot),
      slotId: slotId,
      anchor: FxAnchor.stand,
    );
    b.command(
      StartClip(
        at,
        pulse.clip,
        FxSegment(
          FxTiming.extraSlotRestFrame,
          _spec(FxId.uiExtraSlot).frames.toDouble(),
          loop: true,
          speed: motion.informationalLoopSpeed,
        ),
      ),
      track: pulse,
    );
    _extraPulses[slotId] = pulse;
    _pulseStartMs[slotId] = b.startMs + at;
  }

  /// E.16: a doll landed on the pad at [at]: the loop settles onto its rest
  /// frame over 150 ms (`motion.extraSlot.stopUnderDollMs`) and stops, and
  /// the static pad, in the same pose, draws again. The loop's frame at [at]
  /// is worked out from when it began (it runs at 1×), so it settles from
  /// where it is.
  void _settlePulse(_Batch b, String slotId, double at) {
    final pulse = _extraPulses.remove(slotId);
    final began = _pulseStartMs.remove(slotId);
    if (pulse == null || began == null) return;
    final elapsedMs = b.startMs + at - began;
    if (elapsedMs < 0) {
      // The loop hasn't started yet: it never does.
      pulse.done = true;
      return;
    }
    final total = _spec(FxId.uiExtraSlot).frames.toDouble();
    final frame =
        (elapsedMs * motion.informationalLoopSpeed * FxSpec.frameRate / 1000) %
        total;
    final remaining = total - frame;
    final duration = b.at(MotionTokens.extraSlotStopUnderDollMs.toDouble());
    if (remaining >= 0.5 && duration > 0) {
      b.command(
        PlayClipSegment(
          at,
          pulse.clip,
          FxSegment(frame, total, speed: FxSpec.msOf(remaining) / duration),
        ),
        track: pulse,
      );
    }
    b.command(
      StopClip(at + (remaining >= 0.5 ? duration : 0), pulse.clip),
      track: pulse,
    );
  }

  /// E.16: the pad is empty again at [at] (a doll left it, or its completed
  /// set flew): the loop restarts from frame 0.
  void _restartPulse(_Batch b, String slotId, double at) {
    if (_extraPulses.containsKey(slotId)) return;
    _startPulse(b, slotId, at);
  }

  /// Moves every lasting clip (the selection, the hint, the extra-slot
  /// stands) onto the current layout at [at].
  void _placeLasting(_Batch b, double at) {
    void place(_Track track, FxClipParams params, {int size = 1}) {
      final clip = track.clip;
      final anchor = clip.anchor;
      final slotId = clip.slotId;
      if (anchor == null || slotId == null) return;
      final slot = _geometry.slotOrNull(slotId);
      if (slot == null) return;
      b.command(
        PlaceClip(
          at,
          clip,
          FxPlacement.anchored(anchor, _geometry, slot, size: size),
          params,
        ),
        track: track,
        supersedes: false,
      );
    }

    final selection = _selection;
    if (selection != null) {
      place(selection.pick, _pickParams(selection.nest, _geometry));
      place(selection.glow, FxClipParams.none);
    }
    final hint = _hint;
    if (hint != null) {
      place(hint.arrow, FxClipParams.none, size: hint.size);
      place(hint.glow, FxClipParams.none);
    }
    final hover = _hover;
    if (hover != null) place(hover.glow, hover.params);
    for (final pulse in _extraPulses.values) {
      place(pulse, FxClipParams.none);
    }
  }

  // ── Board reset ──

  void _planReset(_Batch b, BoardResetEffect e) {
    _cancelAll();
    if (e.reason != BoardResetReason.undo) combo.reset();
    b.command(ResetBoard(0, e.snapshot, e.reason));
    // Extra slots survive a restart and an undo (D22): their empty stands
    // pulse again at once.
    for (final id in e.snapshot.slotIds) {
      // A pad with a doll on it rests (E.16).
      if (SlotId.isExtra(id) && _topOfSlot(e.snapshot, id) == null) {
        _startPulse(b, id, 0);
      }
    }
  }
}
