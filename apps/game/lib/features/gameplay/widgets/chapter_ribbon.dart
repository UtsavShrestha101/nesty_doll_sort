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
/// file's `ribbon` null.
///
/// It plays once when it appears and calls [onDone] when it has finished
/// (half as long under reduced motion). Without the file (rule 3, R10) a
/// flat blue band carries the label for as long and then fades.
///
/// The widget is the file's 360×100 canvas (scaled down on narrower
/// screens); it takes no touches.
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

  static const Size canvas = Size(360, 100);

  /// The ribbon's centre below the safe-area top: over the top shelf,
  /// where frame 4.7 names Chapter 4 (NestyBoard: top 150 on a 59 safe
  /// area, about 58 tall).
  static const double centerTop = 120;

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
            child: const CustomPaint(painter: _RibbonBandPainter()),
          ),
        ),
      ),
    );
  }
}

/// The ribbon's rest look without its file: frame 4.7's blue band
/// (`#6FA8DC → #3E7FC0`, a 5 px `#2B5E93` edge, radius 14) with folded
/// tails, 290 wide on the 360×100 canvas.
final class _RibbonBandPainter extends CustomPainter {
  const _RibbonBandPainter();

  static final Paint _tail = Paint()..color = const Color(0xFF2B5E93);
  static final Paint _edge = Paint()..color = const Color(0xFF2B5E93);
  static final Paint _face = Paint();
  static final Paint _highlight = Paint()..color = const Color(0x66FFFFFF);

  static const _band = Rect.fromLTWH(35, 28, 290, 40);
  static const _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF6FA8DC), Color(0xFF3E7FC0)],
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(
        size.width / ChapterRibbon.canvas.width,
        size.height / ChapterRibbon.canvas.height,
      );
    final left = Path()
      ..moveTo(_band.left - 14, _band.top + 12)
      ..lineTo(_band.left + 20, _band.top + 12)
      ..lineTo(_band.left + 20, _band.bottom + 10)
      ..lineTo(_band.left - 14, _band.bottom + 10)
      ..lineTo(_band.left - 2, _band.top + 12 + (_band.height - 2) / 2)
      ..close();
    final right = Path()
      ..moveTo(_band.right + 14, _band.top + 12)
      ..lineTo(_band.right - 20, _band.top + 12)
      ..lineTo(_band.right - 20, _band.bottom + 10)
      ..lineTo(_band.right + 14, _band.bottom + 10)
      ..lineTo(_band.right + 2, _band.top + 12 + (_band.height - 2) / 2)
      ..close();
    final face = RRect.fromRectAndRadius(_band, const Radius.circular(14));
    _face.shader = _gradient.createShader(_band);
    canvas
      ..drawPath(left, _tail)
      ..drawPath(right, _tail)
      ..drawRRect(face.shift(const Offset(0, 5)), _edge)
      ..drawRRect(face, _face)
      ..save()
      ..clipRRect(face)
      ..drawRect(
        Rect.fromLTWH(_band.left, _band.top, _band.width, 2),
        _highlight,
      )
      ..restore()
      ..restore();
  }

  @override
  bool shouldRepaint(_RibbonBandPainter oldDelegate) => false;
}
