import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart' show GameState;
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart'
    show TutorialCue, TutorialCueKind;
import 'package:nesty_game/l10n/app_localizations.dart';
import 'package:nesty_render/nesty_render.dart';

/// The scripted tutorial's scrim, holes, arc, tooltip and hand (frames 1.3,
/// 1.4, step 3, 1.6; docs/plans/m3-design.md §10.4): drawn over the board
/// and under the HUD while `GameplayState.tutorial` is set. Every touch but
/// the cue's own scripted move already goes nowhere (the bloc gates it,
/// §10.4); this only shows the player where to touch.
///
/// Positions come from the board's current [geometry] (null before the
/// first layout, when nothing draws): the hole ellipse is NestyBoard's own
/// (`rx = h·.42 + 16`, `ry = h·.6 + 14`, centred `surf − h·.42`) around
/// both [cue.from] and [cue.to]'s top nest.
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    required this.cue,
    required this.board,
    this.geometry,
    this.maxSize = 3,
    this.library,
    super.key,
  });

  final TutorialCue cue;

  /// The live board, for each slot's top-nest size (the hole's radius).
  final GameState board;

  /// The board's current layout; null draws nothing (rule 3: a tutorial
  /// step never blocks the board before its first layout, since the cue
  /// only gates input, drawn here or not).
  final BoardGeometry? geometry;

  /// The level's own doll cap, when a slot is empty.
  final int maxSize;

  final FxLibrary? library;

  @override
  Widget build(BuildContext context) {
    final geometry = this.geometry;
    if (geometry == null) return const SizedBox.shrink();
    final l10n = context.localizations;
    final from = geometry.slotOrNull(cue.from);
    final to = geometry.slotOrNull(cue.to);
    if (from == null || to == null) return const SizedBox.shrink();
    final fromSize = _topSize(cue.from);
    final toSize = _topSize(cue.to, empty: fromSize);
    final fromHole = _Hole.of(from, fromSize);
    final toHole = _Hole.of(to, toSize);
    final isDrag = cue.kind == TutorialCueKind.drag;
    // The tapped point of this step: the source while it shows step 1 (or
    // the drag's start), the target once it shows step 2 (m3-design §10.4).
    final tapHole = cue.kind == TutorialCueKind.tapTarget ? toHole : fromHole;
    final tapPoint = Offset(tapHole.cx, tapHole.cy);
    // LOTTIE.md "Travel remap": `ui_drag_hand` travels from the tap point
    // on the big doll to the target's surface − 0.4 × its height.
    final dragTo = isDrag
        ? Offset(to.centerX, to.surfaceY - to.dollHeight(toSize) * 0.4)
        : null;
    final arc = TutorialArc.of(
      cue,
      geometry: geometry,
      board: board,
      maxSize: maxSize,
    );
    final (chip, title, text) = _copyFor(cue.step, l10n);
    final topInset = MediaQuery.paddingOf(context).top;
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(
            painter: _ScrimHolesPainter(holes: [fromHole, toHole]),
            size: Size.infinite,
          ),
          if (arc != null)
            CustomPaint(painter: _ArcPainter(arc), size: Size.infinite),
          Positioned(
            left: 28,
            right: 28,
            // NestyBoard: the card's top at 124 on a 59 safe area.
            top: topInset + (124 - 59),
            child: _TooltipCard(chip: chip, title: title, text: text),
          ),
          _Hand(point: tapPoint, dragTo: dragTo, library: library),
        ],
      ),
    );
  }

  /// Level 1's steps: "STEP n OF 3" on all three (copy.md E `tut_step_chip`,
  /// newer than frames 1.3, 1.4 and 10.8b's "OF 2"; lead note 6). Level 2's
  /// swallow step keeps "NEW MOVE".
  static const levelOneSteps = 3;

  /// The chip, title and text of [step] (spec §7.6; m3-design §10.4).
  (String?, String, String) _copyFor(int step, AppLocalizations l10n) =>
      switch (step) {
        1 => (
          l10n.tutorialStepChip(1, levelOneSteps),
          l10n.tutorialStep1Title,
          l10n.tutorialStep1Text,
        ),
        2 => (
          l10n.tutorialStepChip(2, levelOneSteps),
          l10n.tutorialStep2Title,
          l10n.tutorialStep2Text,
        ),
        3 => (
          l10n.tutorialStepChip(3, levelOneSteps),
          l10n.tutorialStep3Title,
          l10n.tutorialStep3Text,
        ),
        _ => (
          l10n.tutorialSwallowChip,
          l10n.tutorialSwallowTitle,
          l10n.tutorialSwallowText,
        ),
      };

  int _topSize(String slotId, {int? empty}) {
    final nests = board.slot(slotId).nests;
    return nests.isEmpty ? (empty ?? maxSize) : nests.last.outerSize;
  }
}

/// The dotted arc of a tutorial step (NestyBoard `tutArc`, a quadratic
/// from [start] through [control] to [end]; review FIDELITY-4), from the
/// board's current geometry. Every step draws one, taps as well as the
/// drag: it shows where the source doll goes, whichever doll the hand
/// taps.
///
/// With `dt` a doll's top (`surf − h·742/768`, the art's base at 742 of
/// its 768):
/// - a tap step (tut1a/tut1b): from above the source doll's left
///   (`S.cx − 10, S.dt − 8`) to above the target's right (`T.cx + 24,
///   T.dt − 6`), its control 30 above the higher end, midway;
/// - the drag (tut2, the source over the target): from the source's right
///   (`S.cx + 44, S.dt + 36`) to the target's (`T.cx + 46, T.dt + 12`),
///   bowing out to `S.cx + 124`, halfway down.
@immutable
final class TutorialArc {
  const TutorialArc({
    required this.start,
    required this.control,
    required this.end,
  });

  /// [cue]'s arc on [geometry], its doll sizes from [board] (an empty
  /// target takes the source's size, as its hole does); null when either
  /// slot isn't on the board.
  static TutorialArc? of(
    TutorialCue cue, {
    required BoardGeometry geometry,
    required GameState board,
    int maxSize = 3,
  }) {
    final from = geometry.slotOrNull(cue.from);
    final to = geometry.slotOrNull(cue.to);
    if (from == null || to == null) return null;
    final fromSize = _topSizeOf(board, cue.from, maxSize);
    final toSize = _topSizeOf(board, cue.to, fromSize);
    final sTop = from.dollTopY(fromSize, from.surfaceY);
    final tTop = to.dollTopY(toSize, to.surfaceY);
    if (cue.kind == TutorialCueKind.drag) {
      final start = Offset(from.centerX + 44, sTop + 36);
      final end = Offset(to.centerX + 46, tTop + 12);
      return TutorialArc(
        start: start,
        control: Offset(from.centerX + 124, (start.dy + end.dy) / 2),
        end: end,
      );
    }
    final start = Offset(from.centerX - 10, sTop - 8);
    final end = Offset(to.centerX + 24, tTop - 6);
    return TutorialArc(
      start: start,
      control: Offset((start.dx + end.dx) / 2, math.min(start.dy, end.dy) - 30),
      end: end,
    );
  }

  /// The top nest's size at [slotId], or [empty] for an empty slot.
  static int _topSizeOf(GameState board, String slotId, int empty) {
    final nests = board.slot(slotId).nests;
    return nests.isEmpty ? empty : nests.last.outerSize;
  }

  final Offset start;
  final Offset control;
  final Offset end;

  @override
  bool operator ==(Object other) =>
      other is TutorialArc &&
      other.start == start &&
      other.control == control &&
      other.end == end;

  @override
  int get hashCode => Object.hash(start, control, end);

  @override
  String toString() => 'TutorialArc($start → $control → $end)';
}

/// A hole's ellipse (NestyBoard: `cy = surf − h·.42`, `rx = h·.42 + 16`,
/// `ry = h·.6 + 14`).
@immutable
final class _Hole {
  const _Hole({
    required this.cx,
    required this.cy,
    required this.rx,
    required this.ry,
  });

  factory _Hole.of(SlotGeometry slot, int size) {
    final h = slot.dollHeight(size);
    return _Hole(
      cx: slot.centerX,
      cy: slot.surfaceY - h * 0.42,
      rx: h * 0.42 + 16,
      ry: h * 0.6 + 14,
    );
  }

  final double cx;
  final double cy;
  final double rx;
  final double ry;

  Rect get rect =>
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
}

/// The scrim (`rgba(52,26,8,.6)`) with both holes cut out (evenodd fill,
/// NestyBoard `tutPath`).
final class _ScrimHolesPainter extends CustomPainter {
  const _ScrimHolesPainter({required this.holes});

  final List<_Hole> holes;

  static final Paint _paint = Paint()..color = const Color(0x99341A08);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size);
    for (final hole in holes) {
      path.addOval(hole.rect);
    }
    canvas.drawPath(path, _paint);
  }

  @override
  bool shouldRepaint(_ScrimHolesPainter oldDelegate) =>
      oldDelegate.holes.length != holes.length ||
      [
        for (var i = 0; i < holes.length; i++) oldDelegate.holes[i] != holes[i],
      ].any((changed) => changed);
}

/// A step's [TutorialArc] (NestyBoard `tutArc`/`tutHead`: `#FFF4E0`,
/// 4 wide, round caps, dashes `2 10`, and the arrowhead 12 past the end
/// along the last tangent, 9 either side).
final class _ArcPainter extends CustomPainter {
  const _ArcPainter(this.arc);

  final TutorialArc arc;

  static final Paint _paint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4
    ..strokeCap = StrokeCap.round
    ..color = const Color(0xFFFFF4E0);
  static final Paint _headFill = Paint()..color = const Color(0xFFFFF4E0);

  @override
  void paint(Canvas canvas, Size size) {
    final TutorialArc(start: from, :control, end: to) = arc;
    final curve = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
    final dashes = Path();
    for (final metric in curve.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        dashes.addPath(
          metric.extractPath(d, math.min(d + 2, metric.length)),
          Offset.zero,
        );
      }
    }
    canvas.drawPath(dashes, _paint);
    final tangent = to - control;
    final unit = tangent / (tangent.distance == 0 ? 1 : tangent.distance);
    final perp = Offset(-unit.dy, unit.dx);
    final tip = to + unit * 12;
    final left = to - perp * 9 - unit * 4;
    final right = to + perp * 9 - unit * 4;
    canvas.drawPath(
      Path()
        ..moveTo(tip.dx, tip.dy)
        ..lineTo(left.dx, left.dy)
        ..lineTo(right.dx, right.dy)
        ..close(),
      _headFill,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => oldDelegate.arc != arc;
}

/// The tooltip card (NestyBoard: 28/124 on a 59 safe area, radius 22,
/// surface gradient; the step chip, title 22, text 15, a rotated diamond
/// tail).
class _TooltipCard extends StatelessWidget {
  const _TooltipCard({
    required this.chip,
    required this.title,
    required this.text,
  });

  final String? chip;
  final String title;
  final String text;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5)],
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      NestySurface(
        style: _style,
        radius: const BorderRadius.all(Radius.circular(22)),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (chip != null) ...[_Chip(chip!), const SizedBox(height: 8)],
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyleTokens.h2.copyWith(fontSize: 22, height: 1.15),
            ),
            const SizedBox(height: 6),
            Text(
              text,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                fontSize: 15,
                height: 1.4,
                color: AppColorTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
      Transform.rotate(
        angle: math.pi / 4,
        child: const DecoratedBox(
          decoration: BoxDecoration(color: Color(0xFFFCEBD0)),
          child: SizedBox(width: 18, height: 18),
        ),
      ),
    ],
  );
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFF2893B),
      borderRadius: BorderRadius.circular(9),
    ),
    child: Text(
      label,
      style: AppTextStyleTokens.tierChip.copyWith(
        fontSize: 11,
        color: const Color(0xFFFFFFFF),
      ),
    ),
  );
}

/// `ui_tap_hand` or `ui_drag_hand` (fallback: the static `touch_app` glyph,
/// rule 3), its fingertip on [point]; a drag travels on to [dragTo].
class _Hand extends StatelessWidget {
  const _Hand({required this.point, this.dragTo, this.library});

  final Offset point;
  final Offset? dragTo;
  final FxLibrary? library;

  /// The glyph's own visual "fingertip", offset from its top-left corner
  /// (NestyBoard's static fallback: `handX = tx − 24, handY = ty − 6`).
  static const Offset _glyphFingertip = Offset(24, 6);
  static const double _glyphSize = 58;

  /// `ui_tap_hand`'s canvas and fingertip (LOTTIE.md: 128×144, fingertip
  /// (48, 32) on the target).
  static const Size _tapCanvas = Size(128, 144);
  static const Offset _tapFingertip = Offset(48, 32);

  static const Widget _glyph = Icon(
    NestyIcons.touchApp,
    size: _glyphSize,
    color: Color(0xFFFFFFFF),
    shadows: [Shadow(color: Color(0xFFC4631E), offset: Offset(0, 3))],
  );

  @override
  Widget build(BuildContext context) {
    final dragTo = this.dragTo;
    if (dragTo != null) {
      return library?[FxId.uiDragHand] != null
          ? Positioned.fill(
              child: _BoardDragHand(from: point, to: dragTo, library: library!),
            )
          : _GlyphDragHand(from: point, to: dragTo);
    }
    return Positioned(
      left: point.dx - _tapFingertip.dx,
      top: point.dy - _tapFingertip.dy,
      width: _tapCanvas.width,
      height: _tapCanvas.height,
      child: _HandLoop(
        id: FxId.uiTapHand,
        library: library,
        // The glyph's fingertip on the canvas's.
        fallback: Stack(
          children: [
            Positioned(
              left: _tapFingertip.dx - _glyphFingertip.dx,
              top: _tapFingertip.dy - _glyphFingertip.dy,
              width: _glyphSize,
              height: _glyphSize,
              child: _glyph,
            ),
          ],
        ),
      ),
    );
  }
}

/// `ui_drag_hand` (frame 1.6): a board-space file (LOTTIE.md, 390×844)
/// laid over the whole overlay, its `travel` null remapped from the
/// authored S → T onto [from] → [to]. The view fits the canvas into its box
/// (`BoxFit.contain`, centred), so the two points go through the same
/// mapping into the file's reference units.
class _BoardDragHand extends StatefulWidget {
  const _BoardDragHand({
    required this.from,
    required this.to,
    required this.library,
  });

  final Offset from;
  final Offset to;
  final FxLibrary library;

  @override
  State<_BoardDragHand> createState() => _BoardDragHandState();
}

class _BoardDragHandState extends State<_BoardDragHand> {
  final LottieFxController _controller = LottieFxController(FxId.uiDragHand);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Reduce motion: the hand rests at the start; it doesn't loop
    // (ui-spec-game §2.4).
    if (context.reduceMotion) {
      _controller.seek(0);
    } else {
      _controller.playWhole();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final canvas = Size(_controller.spec.width, _controller.spec.height);
      final box = constraints.biggest;
      final scale = math.min(
        box.width / canvas.width,
        box.height / canvas.height,
      );
      final origin = Offset(
        (box.width - canvas.width * scale) / 2,
        (box.height - canvas.height * scale) / 2,
      );
      Offset toReference(Offset point) => (point - origin) / scale;
      final src = toReference(widget.from);
      final dst = toReference(widget.to);
      final params = _controller.params;
      if (params.travelSrc != src || params.travelDst != dst) {
        params.setTravel(src, dst);
      }
      return LottieFxView(
        id: FxId.uiDragHand,
        controller: _controller,
        library: widget.library,
      );
    },
  );
}

/// The drag step without `ui_drag_hand` (rule 3): the glyph ping-pongs
/// from [from] to [to] and back (NestyBoard `nb-hand`, 2.4 s).
class _GlyphDragHand extends StatefulWidget {
  const _GlyphDragHand({required this.from, required this.to});

  final Offset from;
  final Offset to;

  @override
  State<_GlyphDragHand> createState() => _GlyphDragHandState();
}

class _GlyphDragHandState extends State<_GlyphDragHand>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    // Reduce motion: the glyph rests at the start of its path.
    if (!context.reduceMotion) _controller.repeat();
  }

  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.easeInOut),
    reverseCurve: const Interval(0.75, 1, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _curve,
    builder: (context, child) {
      final point = Offset.lerp(widget.from, widget.to, _curve.value)!;
      return Positioned(
        left: point.dx - _Hand._glyphFingertip.dx,
        top: point.dy - _Hand._glyphFingertip.dy,
        width: _Hand._glyphSize,
        height: _Hand._glyphSize,
        child: child!,
      );
    },
    child: _Hand._glyph,
  );
}

/// A looping hand file that rests on frame 0 under reduce motion (the tap
/// hand doesn't tap-loop, ui-spec-game §2.4).
class _HandLoop extends StatefulWidget {
  const _HandLoop({required this.id, required this.library, this.fallback});

  final FxId id;
  final FxLibrary? library;
  final Widget? fallback;

  @override
  State<_HandLoop> createState() => _HandLoopState();
}

class _HandLoopState extends State<_HandLoop> {
  late final LottieFxController _controller = LottieFxController(widget.id);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (context.reduceMotion) {
      _controller.seek(0);
    } else {
      _controller.playWhole();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LottieFxView(
    id: widget.id,
    controller: _controller,
    library: widget.library,
    fallback: widget.fallback,
  );
}
