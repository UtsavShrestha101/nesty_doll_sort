import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/lottie/lottie_text_overlay.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/text/fit_text.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';

/// The race results' ribbon (frames 9.4, 9.5; ui-spec-game §1
/// "VersusRibbonTitle"): `ui_win_ribbon` recoloured to versus's indigo by its
/// named fills, `tokens.versus.ribbon` (band `#4E5FD9`, edge `#3242A8`, tail
/// `#4250C6`, fold `#1F297F`; m7-4 4.3: no separate file), with the title in
/// the ribbon's white Fredoka. It plays the ribbon's pop once, and rests on
/// its last frame under reduced motion.
///
/// A modal's title: it is a header that names the overlay's route, read as
/// [title]. On a screen narrower than 390 dp it scales down, as the win
/// card's ribbon does. Without the file (rule 3, R10) [VersusRibbonPainter]
/// draws its rest look.
class VersusRibbon extends StatefulWidget {
  const VersusRibbon({
    required this.title,
    this.shortTitle,
    this.library,
    super.key,
  });

  final String title;

  /// The ARB's short form (`raceWinTitleShort`, `raceLossTitleShort`),
  /// drawn when [title] needs more than textFit.winRibbon's `minScale`.
  final String? shortTitle;

  /// The FX library (the DI one by default).
  final FxLibrary? library;

  /// The ribbon's canvas (`ui_win_ribbon`'s, 410×110), centred on the band.
  static const Size canvas = Size(410, 110);

  @override
  State<VersusRibbon> createState() => _VersusRibbonState();
}

class _VersusRibbonState extends State<VersusRibbon> {
  final LottieFxController _controller = LottieFxController(FxId.uiWinRibbon);

  @override
  void initState() {
    super.initState();
    _controller.params.setRibbonColors(WinRibbonTokens.versusColors);
    _controller.playWhole();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final scale = width >= 390 ? 1.0 : (width / 390).clamp(0.0, 1.0);
    final shortTitle = widget.shortTitle;
    final label = shortTitle == null
        ? widget.title
        : RibbonLabel.pick(
            context,
            style: LottieLabelStyles.winRibbon,
            full: widget.title,
            short: shortTitle,
            minScale: TextFitTokens.winRibbonMinScale,
          );
    return Semantics(
      header: true,
      namesRoute: true,
      label: widget.title,
      excludeSemantics: true,
      child: SizedBox(
        width: VersusRibbon.canvas.width * scale,
        height: VersusRibbon.canvas.height * scale,
        child: LottieTextOverlay(
          label: label,
          semanticLabel: widget.title,
          style: LottieLabelStyles.winRibbon,
          lottie: LottieFxView(
            id: FxId.uiWinRibbon,
            controller: _controller,
            library: widget.library,
            label: label,
            fallback: const CustomPaint(painter: VersusRibbonPainter()),
          ),
        ),
      ),
    );
  }
}

/// The ribbon's rest look in versus colours: a 336×56 band (radius 16) over
/// its 6 dp edge, a soft highlight, and the two tails 22 past the band with a
/// notch and a fold, on the 410×110 canvas around (205, 55), in
/// `tokens.versus.ribbon`'s colours.
final class VersusRibbonPainter extends CustomPainter {
  const VersusRibbonPainter();

  static const _anchor = Offset(205, 55);

  static const _colors = WinRibbonTokens.versusColors;
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
        ..drawPath(_tailPath(side), Paint()..color = _colors.tail)
        ..drawPath(_foldPath(side), Paint()..color = _colors.fold);
    }
    canvas
      ..drawRRect(
        _band.shift(const Offset(0, 6)),
        Paint()..color = _colors.edge,
      )
      ..drawRRect(_band, Paint()..color = _colors.band)
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
