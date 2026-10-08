import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/lottie/lottie_text_overlay.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart' show HudTokens;
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/game/timeline/fx_placement.dart';

/// The HUD's family counter, "setsCompleted / totalSets" under the level
/// pill (frame 2.2; spec §10.2 #3), on `ui_family_counter`
/// (m2-lottie-design §12, PROGRESS D44).
///
/// The file draws the pill, the doll icon and the bump; its text layers are
/// hidden and the localized "{done} / {total}" is painted following its
/// `counter` null. When [done] rises (a family landed, lottie §7 at
/// t0 + 1250) the `bump` segment plays and the old count shows until the
/// swap frame, and an `fx_sparkle` [sparkleScale]× the trail's bursts over
/// the counter (LOTTIE.md "Completed"; a one-shot, at 2× under reduced
/// motion). A lower count (undo, restart, a new level) changes at once.
///
/// It hugs its text (E.18; `layout.hud.familyCounter`): the pill is
/// [hugWidth] wide (the label + 34: 64 for "4 / 4", 78 for "12 / 12"). The
/// label follows the text setting up to 1.3× and hugs its text up to 58 dp
/// ("12 / 12" at 1.3× is 57), so the pill is at most 92; a longer label
/// scales down to fit and never wraps (m7-6 item 16). The file's pill takes
/// that width
/// as it is, at any width: `pill_rect` and `glow_rect` resized and the doll
/// mark moved with them (LOTTIE.md "Tint and width"; m7-4 4.14), with no
/// scale on the whole counter.
///
/// The widget is the file's 120×60 canvas; the counter's centre is the
/// canvas centre (LOTTIE.md: (60, 30) = (195, 129) on the reference
/// screen). If the file is missing (rule 3, R10) a static pill in the same
/// place carries the label.
class FamilyCounter extends StatefulWidget {
  const FamilyCounter({
    required this.done,
    required this.total,
    this.sparkleScale = defaultSparkleScale,
    this.library,
    super.key,
  });

  final int done;
  final int total;

  /// The landing sparkle's size, × the trail's `fx_sparkle` (64 × 64 at the
  /// board's reference scale).
  final double sparkleScale;

  /// The DI library by default.
  final FxLibrary? library;

  /// The file's canvas (`LottieLabelStyles.familyCounter.canvas`).
  static const Size canvas = Size(120, 60);

  /// The file's own pill width (`FamilyCounterPillPainter`: 70×26).
  static const double filePillWidth = 70;

  /// The text setting the label follows: the context's, from 1 up to 1.3
  /// (the HUD's label is part of the file's art, so it never goes smaller).
  static double textScaleOf(BuildContext context) =>
      (MediaQuery.textScalerOf(context).scale(1)).clamp(1.0, 1.3);

  /// The label's style at the text scale [k]: the table's, with its size and
  /// baseline following the setting.
  static LottieLabelStyle labelStyleFor(double k) {
    const base = LottieLabelStyles.familyCounter;
    if (k == 1) return base;
    return LottieLabelStyle(
      fontSize: base.fontSize * k,
      color: base.color,
      maxWidth: base.maxWidth,
      maxHeight: base.maxHeight,
      baseline: Offset(base.baseline.dx, base.baseline.dy * k),
      restNull: base.restNull,
      canvas: base.canvas,
      shadowOffset: base.shadowOffset,
      shadowColor: base.shadowColor,
    );
  }

  /// The pill's width around [label] (tokens `hud.familyCounter`): the label
  /// as wide as its text at the text scale [k], at least
  /// [HudTokens.familyCounterLabelMinWidth] and at most
  /// [HudTokens.familyCounterLabelMaxWidth], plus
  /// [HudTokens.familyCounterPillChrome]. Never above
  /// [HudTokens.familyCounterPillMaxWidth].
  static double hugWidth(String label, {double k = 1}) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: labelStyleFor(k).textStyle()),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.noScaling,
    )..layout();
    final textWidth = painter.width;
    painter.dispose();
    return HudTokens.familyCounterPillChrome +
        textWidth
            .clamp(
              HudTokens.familyCounterLabelMinWidth,
              HudTokens.familyCounterLabelMaxWidth,
            )
            .toDouble();
  }

  /// LOTTIE.md "Completed": "a 1.5× `fx_sparkle` @1250".
  static const double defaultSparkleScale = LottieGeometry.counterSparkleScale;

  @override
  State<FamilyCounter> createState() => _FamilyCounterState();
}

class _FamilyCounterState extends State<FamilyCounter> {
  final LottieFxController _controller = LottieFxController(
    FxId.uiFamilyCounter,
  );

  /// The landing sparkle over the counter: drawn only while it plays.
  late final LottieFxController _sparkle = LottieFxController(FxId.fxSparkle)
    ..onFinished = _sparkleDone;
  bool _sparkling = false;

  /// The count before the running bump, shown until its swap frame.
  int? _previous;

  @override
  void initState() {
    super.initState();
    _controller.rest(0);
  }

  @override
  void didUpdateWidget(FamilyCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.done > oldWidget.done && widget.total == oldWidget.total) {
      _previous = oldWidget.done;
      _controller.playMarker('bump');
      _sparkling = true;
      _sparkle.playWhole();
    } else if (widget.done != oldWidget.done ||
        widget.total != oldWidget.total) {
      _previous = null;
      _controller.rest(0);
      // A build follows: no setState.
      _stopSparkle();
    }
  }

  /// The sparkle ended: stop drawing it.
  void _sparkleDone() {
    if (!_sparkling || !mounted) return;
    setState(_stopSparkle);
  }

  void _stopSparkle() {
    if (!_sparkling) return;
    _sparkling = false;
    _sparkle.rest(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _sparkle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final label = l10n.familyCounter(widget.done, widget.total);
    final previous = _previous;
    final k = FamilyCounter.textScaleOf(context);
    final labelStyle = FamilyCounter.labelStyleFor(k);
    final pillWidth = FamilyCounter.hugWidth(label, k: k);
    _controller.params.pillWidth = pillWidth;
    final counter = LottieTextOverlay(
      label: label,
      style: labelStyle,
      semanticLabel: l10n.familyCounterSemantics(widget.done, widget.total),
      lottie: LottieFxView(
        id: FxId.uiFamilyCounter,
        controller: _controller,
        library: widget.library,
        label: label,
        labelStyle: labelStyle,
        previousLabel: previous == null
            ? null
            : l10n.familyCounter(previous, widget.total),
        fallback: CustomPaint(
          painter: FamilyCounterPillPainter(pillWidth: pillWidth),
        ),
      ),
    );
    // The counter sizes the stack and keeps its place in it, so the
    // sparkle coming and going never rebuilds it. The sparkle's anchor,
    // its canvas centre, sits on the counter's centre (the canvas centre
    // too); it bursts past the counter's box.
    final spec = fxSpecOf(FxId.fxSparkle);
    final scale = widget.sparkleScale;
    const center = Offset(60, 30);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // The pill hugs its label at its own width; the sparkle stays 1.5×
        // the trail's, on the counter's centre.
        counter,
        if (_sparkling)
          Positioned(
            left: center.dx - spec.anchor.dx * scale,
            top: center.dy - spec.anchor.dy * scale,
            width: spec.width * scale,
            height: spec.height * scale,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: LottieFxView(
                  id: FxId.fxSparkle,
                  controller: _sparkle,
                  library: widget.library,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// The counter's rest look without its file (m2-lottie-design §10 R10):
/// the file's own 70×26 walnut pill and cream doll icon at the canvas
/// centre, scaled with the canvas; the label is drawn over it.
class FamilyCounterPillPainter extends CustomPainter {
  const FamilyCounterPillPainter({
    this.pillWidth = FamilyCounter.filePillWidth,
  });

  /// The pill's width (the file's 70 unless the label needs more).
  final double pillWidth;

  static final Paint _pill = Paint()..color = const Color(0xFF7B4824);
  static final Paint _edge = Paint()..color = const Color(0xFF4E2C14);
  static final Paint _ring = Paint()..color = const Color(0xFFFFF4E0);
  static final Paint _icon = Paint()..color = const Color(0xFFFFF5E0);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / FamilyCounter.canvas.width;
    final sy = size.height / FamilyCounter.canvas.height;
    canvas
      ..save()
      ..scale(sx, sy)
      ..translate(60, 30);
    final iconX = -pillWidth / 2 + 14;
    // NestyBoard: `0 3px 0 #4E2C14, 0 0 0 2px #FFF4E0` around a 13-radius
    // pill.
    final pill = Rect.fromLTWH(-pillWidth / 2, -13, pillWidth, 26);
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(pill.inflate(2), const Radius.circular(15)),
        _ring,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(
          pill.shift(const Offset(0, 3)),
          const Radius.circular(13),
        ),
        _edge,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(pill, const Radius.circular(13)),
        _pill,
      )
      // The file's icon: a head of 8 over an 11×11 body, 14 in from the
      // pill's left edge ((−21, 0) at the file's 70).
      ..drawCircle(Offset(iconX, -4.5), 4, _icon)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(iconX, 3.5), width: 11, height: 11),
          const Radius.circular(5),
        ),
        _icon,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(FamilyCounterPillPainter oldDelegate) =>
      oldDelegate.pillWidth != pillWidth;
}
