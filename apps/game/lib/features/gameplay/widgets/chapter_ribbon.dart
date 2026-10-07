import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_ribbon.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/pages/chapter_progress.dart';
import 'package:nesty_render/nesty_render.dart' show ChapterPalette;

/// Frame 4.7's new-chapter ribbon, "CHAPTER {n} · {name}", on
/// `ui_chapter_ribbon` (2.6 s: it pops in, holds and fades; LOTTIE.md "New
/// chapter (4.7)"; m2-lottie-design §12). The localized label follows the
/// file's `ribbon` null, fitted to the `textFit.chapterRibbon` box on it
/// (312 × 32 in the 336 band). One line: 4.7's two-line plate is superseded
/// (tokens.theme.ribbonTint).
///
/// The ribbon's four named fills take the chapter's [palette] (m7-4 4.15,
/// m7-5 item 7, LOTTIE.md "Tint and width"), never a colour matrix: the
/// band its `accent`, the edge its `accentEdge`, the tails its `ribbonTail`
/// and the fold its `ribbonFold`; the highlight stays white, and the label's
/// shadow takes the fold at the authored 35 %.
///
/// It plays once when it appears and calls [onDone] when it has finished
/// (half as long under reduced motion). Without the file (rule 3, R10) a
/// flat band carries the label for as long and then fades.
///
/// The widget is the file's 410×100 canvas at full size: place it with
/// [rectIn]. On a phone narrower than 406 dp its band is the screen − 70
/// (320 on a 390 phone, frame 4.7), set through the file's named rects
/// (LOTTIE.md m7-5), and the label's box narrows with it. It takes no
/// touches.
class ChapterRibbon extends StatefulWidget {
  const ChapterRibbon({
    required this.number,
    required this.chapterId,
    required this.onDone,
    this.library,
    this.palette,
    super.key,
  });

  final int number;

  /// The `chapterName` select key (`ch02`).
  final String chapterId;
  final VoidCallback onDone;
  final FxLibrary? library;

  /// The chapter's colours (`ChapterTheme.palette`): the band, its tails and
  /// their fold take its accent (frame 4.7's per-chapter ribbons; lead note
  /// 7). Null keeps the file's own blue.
  final ChapterPalette? palette;

  /// The file's canvas (`LottieLabelStyles.chapterRibbon.canvas`).
  static const Size canvas = Size(410, 100);

  /// The ribbon's centre below the safe-area top: over the top shelf,
  /// where frame 4.7 names Chapter 4 (NestyBoard: top 150 on a 59 safe
  /// area, about 58 tall).
  static const double centerTop = 120;

  /// Where the ribbon goes on a [screen] with safe-area [padding]: the
  /// canvas at full size, centred across the screen (so it may start left
  /// of 0), its centre [centerTop] below the safe area. For a
  /// `Positioned.fromRect` in the page's stack.
  static Rect rectIn(Size screen, EdgeInsets padding) =>
      LottieRibbonFit.rectFor(
        canvas,
        screenWidth: screen.width,
        centerY: padding.top + centerTop,
      );

  /// The colours the file's four named fills take on [palette].
  static RibbonColors colorsOf(ChapterPalette palette) => RibbonColors(
    band: palette.accent,
    edge: palette.accentEdge,
    tail: palette.ribbonTail,
    fold: palette.ribbonFold,
  );

  /// The file's own colours (its blue), when no palette is given.
  static const RibbonColors authoredColors = RibbonColors(
    band: Color(0xFF3D8FDE),
    edge: Color(0xFF2B6BB0),
    tail: Color(0xFF2E7AC7),
    fold: Color(0xFF1C4F82),
  );

  /// The label's shadow on [palette]: its `ribbonFold` at the authored
  /// shadow's alpha (35 %, tokens.theme.ribbonTint "label shadow =
  /// ribbonFold"); null keeps the authored `#1C4F82`.
  static Color? labelShadowOf(ChapterPalette? palette) => palette?.ribbonFold
      .withValues(alpha: LottieLabelStyles.chapterRibbon.shadowColor!.a);

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
    _tint();
  }

  /// Gives the file's named fills the palette's colours (null: as authored).
  void _tint() {
    final palette = widget.palette;
    _controller.params.setRibbonColors(
      palette == null ? null : ChapterRibbon.colorsOf(palette),
    );
  }

  @override
  void didUpdateWidget(ChapterRibbon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.palette != widget.palette) _tint();
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
    final name = ChapterProgress.nameOf(l10n, widget.chapterId, widget.number);
    final fullLabel = l10n.chapterRibbon(widget.number, name);
    final palette = widget.palette;
    final bandWidth = FxRibbon.chapter.bandWidthFor(
      MediaQuery.sizeOf(context).width,
    );
    _controller.params.ribbonBandWidth = bandWidth;
    final style = FxRibbon.chapter.labelFor(
      bandWidth,
      shadow: ChapterRibbon.labelShadowOf(palette),
    );
    // textFit.chapterRibbon: the name alone when the full line would shrink
    // below its minScale.
    final label = RibbonLabel.pick(
      context,
      style: style,
      full: fullLabel,
      short: l10n.chapterRibbonShort(name),
      minScale: TextFitTokens.chapterRibbonMinScale,
    );
    return IgnorePointer(
      child: LottieTextOverlay(
        label: label,
        semanticLabel: fullLabel,
        style: style,
        lottie: LottieFxView(
          id: FxId.uiChapterRibbon,
          controller: _controller,
          library: widget.library,
          label: label,
          labelStyle: style,
          fallback: AnimatedOpacity(
            opacity: _fading ? 0 : 1,
            duration: context.uiDuration(UiMotionTokens.modalInMs),
            child: CustomPaint(
              painter: RibbonRestPainter(
                ribbon: FxRibbon.chapter,
                colors: palette == null
                    ? ChapterRibbon.authoredColors
                    : ChapterRibbon.colorsOf(palette),
                bandWidth: bandWidth,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
