import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';

/// Frame 4.7's new-chapter ribbon, "CHAPTER {n} · {name}", on
/// `ui_chapter_ribbon` (2.6 s: it pops in, holds and fades; LOTTIE.md "New
/// chapter (4.7)"; m2-lottie-design §12). The localized label follows the
/// file's `ribbon` null, fitted to a 312 × 32 box on it (LOTTIE.md v3).
///
/// It plays once when it appears and calls [onDone] when it has finished
/// (half as long under reduced motion). Without the file (rule 3, R10) a
/// flat blue band carries the label for as long and then fades.
///
/// The widget is the file's 410×100 canvas: place it with [rectIn], which
/// scales it by `LottieRibbonFit.scaleFor` (full size on a 390 dp screen,
/// where the canvas overhangs both edges and the tails pass them by up to
/// 6 dp during the pop, as the owner accepted). It takes no touches.
class ChapterRibbon extends StatefulWidget {
  const ChapterRibbon({
    required this.number,
    required this.chapterId,
    required this.onDone,
    this.library,
    super.key,
  });

  final int number;

  /// The `chapterName` select key (`ch02`).
  final String chapterId;
  final VoidCallback onDone;
  final FxLibrary? library;

  /// The file's canvas (`LottieLabelStyles.chapterRibbon.canvas`).
  static const Size canvas = Size(410, 100);

  /// The ribbon's centre below the safe-area top: over the top shelf,
  /// where frame 4.7 names Chapter 4 (NestyBoard: top 150 on a 59 safe
  /// area, about 58 tall).
  static const double centerTop = 120;

  /// Where the ribbon goes on a [screen] with safe-area [padding]: the
  /// canvas at `LottieRibbonFit.scaleFor(screen.width)`, centred across the
  /// screen (so it may start left of 0), its centre [centerTop] below the
  /// safe area. For a `Positioned.fromRect` in the page's stack.
  static Rect rectIn(Size screen, EdgeInsets padding) =>
      LottieRibbonFit.rectFor(
        canvas,
        screenWidth: screen.width,
        centerY: padding.top + centerTop,
      );

  @override
  State<ChapterRibbon> createState() => _ChapterRibbonState();
}

class _ChapterRibbonState extends State<ChapterRibbon> {
  final LottieFxController _controller = LottieFxController(
    FxId.uiChapterRibbon,
  );
  Timer? _done;
  bool _fading = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller
      ..onFinished = _finish
      ..playWhole();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The timer ends the ribbon whether or not the file plays (without a
    // composition the view has no ticker, so onFinished never comes).
    if (_done == null) {
      final length = fxSpecOf(FxId.uiChapterRibbon).durationMs;
      final scale = context.reduceMotion
          ? UiMotionTokens.reducedMotionDurationScale
          : 1.0;
      final total = Duration(milliseconds: (length * scale).round());
      final fade = context.uiDuration(UiMotionTokens.modalInMs);
      _done = Timer(total - fade, () {
        if (!mounted) return;
        setState(() => _fading = true);
        _done = Timer(fade, _finish);
      });
    }
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    _done?.cancel();
    widget.onDone();
  }

  @override
  void dispose() {
    _done?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final label = l10n.chapterRibbon(
      widget.number,
      l10n.chapterName(widget.chapterId),
    );
    return IgnorePointer(
      child: LottieTextOverlay(
        label: label,
        style: LottieLabelStyles.chapterRibbon,
        lottie: LottieFxView(
          id: FxId.uiChapterRibbon,
          controller: _controller,
          library: widget.library,
          label: label,
          fallback: AnimatedOpacity(
            opacity: _fading ? 0 : 1,
            duration: context.uiDuration(UiMotionTokens.modalInMs),
            child: const CustomPaint(painter: ChapterRibbonPainter()),
          ),
        ),
      ),
    );
  }
}

/// The ribbon's rest look without its file (rule 3, R10): what
/// `ui_chapter_ribbon` shows while it holds (frames 18–138), on the 410×100
/// canvas around the anchor (205, 50). The 336×48 band (radius 16,
/// `#3D8FDE`) over its `#2B6BB0` edge 6 below, a 30 % white highlight, and
/// the `#2E7AC7` tails 22 past the band with a 12 notch and a `#1C4F82`
/// fold under it.
final class ChapterRibbonPainter extends CustomPainter {
  const ChapterRibbonPainter();

  static const _anchor = Offset(205, 50);

  static final Paint _tail = Paint()..color = const Color(0xFF2E7AC7);
  static final Paint _fold = Paint()..color = const Color(0xFF1C4F82);
  static final Paint _edge = Paint()..color = const Color(0xFF2B6BB0);
  static final Paint _face = Paint()..color = const Color(0xFF3D8FDE);
  static final Paint _highlight = Paint()..color = const Color(0x4DFFFFFF);

  static final RRect _band = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset.zero, width: 336, height: 48),
    const Radius.circular(16),
  );
  static final RRect _shine = RRect.fromRectAndRadius(
    Rect.fromCenter(center: const Offset(0, -19), width: 320, height: 5),
    const Radius.circular(2.5),
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(
        size.width / ChapterRibbon.canvas.width,
        size.height / ChapterRibbon.canvas.height,
      )
      ..translate(_anchor.dx, _anchor.dy);
    for (final side in const [-1.0, 1.0]) {
      canvas
        ..drawPath(_tailPath(side), _tail)
        ..drawPath(_foldPath(side), _fold);
    }
    canvas
      ..drawRRect(_band.shift(const Offset(0, 6)), _edge)
      ..drawRRect(_band, _face)
      ..drawRRect(_shine, _highlight)
      ..restore();
  }

  static Path _tailPath(double side) => Path()
    ..moveTo(154 * side, -10)
    ..lineTo(190 * side, -10)
    ..lineTo(178 * side, 8)
    ..lineTo(190 * side, 34)
    ..lineTo(154 * side, 34)
    ..close();

  static Path _foldPath(double side) => Path()
    ..moveTo(154 * side, 24)
    ..lineTo(168 * side, 24)
    ..lineTo(168 * side, 34)
    ..close();

  @override
  bool shouldRepaint(ChapterRibbonPainter oldDelegate) => false;
}
