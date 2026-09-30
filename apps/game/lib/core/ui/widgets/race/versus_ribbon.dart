import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The race results' ribbon (frames 9.4, 9.5; ui-spec-game §1
/// "VersusRibbonTitle"): the celebration ribbon re-coloured to versus's
/// indigo (band `#7B8BEF → #4E5FD9`, shadow `#28358F`, tails `#3242A8`),
/// with the title in Fredoka 700 28 white over it.
///
/// Drawn by [VersusRibbonPainter], not by `ui_win_ribbon` re-tinted:
/// tinting that Lottie by a value delegate isn't supported by the game's
/// `LottieFxView`, and the win card's own painter is the file's orange.
/// TODO(design): confirm `ui_win_ribbon` can be tinted by its named fills,
/// or ship a versus variant of the file (ui-spec-game §1).
///
/// A modal's title: it is a header that names the overlay's route, read as
/// [title]. On a screen narrower than 390 dp it scales down, as the win
/// card's ribbon does.
class VersusRibbon extends StatelessWidget {
  const VersusRibbon({required this.title, super.key});

  final String title;

  /// The ribbon's canvas (the win ribbon's, 410×100 here), centred on the
  /// band.
  static const Size canvas = Size(410, 100);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width >= 390 ? 1.0 : (width / 390).clamp(0.0, 1.0);
    return Semantics(
      header: true,
      namesRoute: true,
      label: title,
      excludeSemantics: true,
      child: SizedBox(
        width: canvas.width * scale,
        height: canvas.height * scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(
              child: CustomPaint(painter: VersusRibbonPainter()),
            ),
            SizedBox(
              width: 300 * scale,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  style: AppTextStyleTokens.button.copyWith(
                    fontSize: 28,
                    height: 1.1,
                    color: const Color(0xFFFFFFFF),
                    shadows: const [
                      Shadow(color: Color(0x591E1E6E), offset: Offset(0, 2)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The ribbon's rest look in versus colours: a 336×56 band (radius 16) over
/// its 6 dp shadow, a soft highlight, and the two tails 22 past the band
/// with a notch and a fold, on the 410×100 canvas around (205, 50).
final class VersusRibbonPainter extends CustomPainter {
  const VersusRibbonPainter();

  static const _anchor = Offset(205, 50);

  static const _tail = Color(0xFF3242A8);
  static const _fold = Color(0xFF28358F);
  static const _shadow = Color(0xFF28358F);
  static const _highlight = Color(0x4DFFFFFF);

  static final RRect _band = RRect.fromRectAndRadius(
    Rect.fromCenter(center: Offset.zero, width: 336, height: 56),
    const Radius.circular(16),
  );
  static final RRect _shine = RRect.fromRectAndRadius(
    Rect.fromCenter(center: const Offset(0, -23), width: 320, height: 5),
    const Radius.circular(2.5),
  );

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(
        size.width / VersusRibbon.canvas.width,
        size.height / VersusRibbon.canvas.height,
      )
      ..translate(_anchor.dx, _anchor.dy);
    for (final side in const [-1.0, 1.0]) {
      canvas
        ..drawPath(_tailPath(side), Paint()..color = _tail)
        ..drawPath(_foldPath(side), Paint()..color = _fold);
    }
    final face = Paint()
      ..shader = AppGradientTokens.versus.createShader(_band.outerRect);
    canvas
      ..drawRRect(_band.shift(const Offset(0, 6)), Paint()..color = _shadow)
      ..drawRRect(_band, face)
      ..drawRRect(_shine, Paint()..color = _highlight)
      ..restore();
  }

  static Path _tailPath(double side) => Path()
    ..moveTo(154 * side, -14)
    ..lineTo(190 * side, -14)
    ..lineTo(178 * side, 8)
    ..lineTo(190 * side, 38)
    ..lineTo(154 * side, 38)
    ..close();

  static Path _foldPath(double side) => Path()
    ..moveTo(154 * side, 28)
    ..lineTo(168 * side, 28)
    ..lineTo(168 * side, 38)
    ..close();

  @override
  bool shouldRepaint(VersusRibbonPainter oldDelegate) => false;
}
