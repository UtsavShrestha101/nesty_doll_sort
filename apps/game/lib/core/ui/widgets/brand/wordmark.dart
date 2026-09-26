import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_render/nesty_render.dart'
    show DollPainter, DollRenderer, PlaceholderDollPainter;

/// The wordmark's two sizes (NestyMenus): the splash logo and the Home
/// header.
enum WordmarkSize {
  /// Splash 1.1: Fredoka 88/700, a 4 px outline, a 9 px drop edge, a soft
  /// shadow and the tilted cherry doll dotting the "e".
  large(fontSize: 88, outline: 4, drop: 9, letterSpacing: -0.88, doll: true),

  /// Home 2.1: 30/700, a 2 px outline and a 4 px drop edge, no doll.
  small(fontSize: 30, outline: 2, drop: 4, letterSpacing: 0, doll: false);

  const WordmarkSize({
    required this.fontSize,
    required this.outline,
    required this.drop,
    required this.letterSpacing,
    required this.doll,
  });

  final double fontSize;
  final double outline;
  final double drop;
  final double letterSpacing;
  final bool doll;
}

/// "Nesty" in cream `#FFF6E6` with a `#5B3A21` outline and drop edge
/// (NestyMenus splash and Home header; design/README.md 1.1).
///
/// The design builds the outline from eight 4 px text shadows plus a
/// `0 9px 0` copy; here it is a round-joined stroke of twice the outline
/// width under the fill, and a filled copy 9 px lower. The large
/// size dots the "e" with a cherry doll rotated −8° (30×45 at 88 px, its
/// base 56 % up the line box), drawn by [dollRenderer] or, by default, the
/// procedural placeholder doll (spec §12.5), so it needs no skin.
///
/// It is a logo: text scaling doesn't apply, and screen readers read the
/// app name.
class Wordmark extends StatelessWidget {
  const Wordmark({
    this.size = WordmarkSize.large,
    this.dollRenderer,
    this.dollShown = true,
    super.key,
  });

  final WordmarkSize size;

  /// Draws the cherry doll; null uses the shared placeholder painter.
  final DollRenderer? dollRenderer;

  /// False hides the cherry doll while its art is on the way; it fades in
  /// when this turns true (the splash, Q58).
  final bool dollShown;

  static final DollRenderer _placeholder = PlaceholderDollPainter();

  static const _ink = AppColorTokens.textPrimary;

  /// The splash's soft shadow, `0 14px 18px rgba(90,45,15,.35)`.
  static const _softShadow = Shadow(
    color: Color(0x595A2D0F),
    offset: Offset(0, 14),
    blurRadius: 18,
  );

  @override
  Widget build(BuildContext context) {
    final text = context.localizations.appName;
    final base = AppTextStyleTokens.display.copyWith(
      fontSize: size.fontSize,
      height: 1,
      letterSpacing: size.letterSpacing,
    );
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.outline * 2
      ..strokeJoin = StrokeJoin.round
      ..color = _ink;
    Widget layer(TextStyle style) => Text(
      text,
      style: style,
      maxLines: 1,
      softWrap: false,
      textScaler: TextScaler.noScaling,
    );
    final mark = Stack(
      clipBehavior: Clip.none,
      children: [
        // The soft shadow alone, under everything (splash only).
        if (size.doll)
          layer(
            base.copyWith(
              color: const Color(0x00000000),
              shadows: const [_softShadow],
            ),
          ),
        // The drop edge: `0 9px 0 #5B3A21`, the filled glyphs [drop] lower.
        Transform.translate(
          offset: Offset(0, size.drop),
          child: layer(base.copyWith(color: _ink)),
        ),
        layer(base.copyWith(foreground: stroke)),
        layer(base.copyWith(color: AppColors.cream)),
        if (size.doll && text.length >= 2)
          _dotDoll(
            base,
            text,
            Directionality.of(context),
            context.reduceMotion
                ? Duration.zero
                : const Duration(milliseconds: UiMotionTokens.modalInMs),
          ),
      ],
    );
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Padding(
        // Keep the outline and drop edge inside the widget's box.
        padding: EdgeInsets.fromLTRB(
          size.outline,
          size.outline,
          size.outline,
          math.max(size.outline, size.drop),
        ),
        child: mark,
      ),
    );
  }

  /// The doll over the second glyph, measured from the text itself so any
  /// brand name keeps it on its second letter.
  Widget _dotDoll(
    TextStyle style,
    String text,
    TextDirection direction,
    Duration fade,
  ) {
    final before = TextPainter(
      text: TextSpan(text: text.substring(0, 1), style: style),
      textDirection: direction,
      textScaler: TextScaler.noScaling,
    )..layout();
    final glyph = TextPainter(
      text: TextSpan(text: text.substring(1, 2), style: style),
      textDirection: direction,
      textScaler: TextScaler.noScaling,
    )..layout();
    final k = size.fontSize / 88;
    final width = 30 * k;
    final height = 45 * k;
    final centerX = before.width + glyph.width / 2;
    final bottom = size.fontSize * 0.56;
    before.dispose();
    glyph.dispose();
    return Positioned(
      left: centerX - width / 2,
      bottom: bottom,
      width: width,
      height: height,
      child: AnimatedOpacity(
        opacity: dollShown ? 1 : 0,
        duration: fade,
        curve: UiMotionTokens.curveEaseOut,
        child: Transform.rotate(
          angle: -8 * math.pi / 180,
          child: CustomPaint(
            painter: DollPainter(
              renderer: dollRenderer ?? _placeholder,
              color: DollColor.red,
            ),
          ),
        ),
      ),
    );
  }
}
