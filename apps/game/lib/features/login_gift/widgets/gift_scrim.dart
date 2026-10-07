import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The gift sheet's scrim (`gift.sheet.scrim`) and what a coin claim does
/// to it (frame 13.5, `gift.claim.coins.pill`): it opens a 122 × 54 hole
/// (radius 27) round Home's coin pill so the coins land on a lit pill, and
/// the pill ring (`motion.chest.collect.pillRing`) glows above it. The
/// sheet drives [holeOpen] and [ring]; [GiftSheetRoute]'s barrier paints
/// them.
class GiftScrim extends ChangeNotifier {
  /// Home's coin pill face on screen, or null (no hole, no ring).
  Rect? get pill => _pill;
  Rect? _pill;
  set pill(Rect? value) {
    if (value == _pill) return;
    _pill = value;
    notifyListeners();
  }

  /// 0 closed, 1 open.
  double get holeOpen => _holeOpen;
  double _holeOpen = 0;
  set holeOpen(double value) {
    if (value == _holeOpen) return;
    _holeOpen = value;
    notifyListeners();
  }

  /// The ring's opacity, 0–1.
  double get ring => _ring;
  double _ring = 0;
  set ring(double value) {
    if (value == _ring) return;
    _ring = value;
    notifyListeners();
  }

  /// The hole round [pill]: 54 tall (radius 27) and 6 wider than the pill
  /// on each side, the frame's 122 × 54 round its 110 dp pill. A longer
  /// balance widens the hole with the pill.
  static Rect holeOf(Rect pill) => Rect.fromCenter(
    center: pill.center,
    width: pill.width + _holeSide * 2,
    height: GiftClaimTokens.coinsPillHole.height,
  );

  /// (122 − the frame's 110 dp pill) / 2.
  static const double _holeSide = 6;
}

/// Paints [GiftScrim]: the scrim colour over the screen, less the hole
/// while it is open, then the pill ring.
class GiftScrimPainter extends CustomPainter {
  GiftScrimPainter(this.scrim, {this.color = GiftSheetTokens.scrim})
    : super(repaint: scrim);

  final GiftScrim scrim;
  final Color color;

  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final pill = scrim.pill;
    _paint.color = color;
    if (pill == null || scrim.holeOpen <= 0) {
      canvas.drawRect(full, _paint);
    } else {
      final hole = RRect.fromRectAndRadius(
        GiftScrim.holeOf(pill),
        const Radius.circular(GiftClaimTokens.coinsPillHoleRadius),
      );
      canvas.drawPath(
        Path()
          ..fillType = PathFillType.evenOdd
          ..addRect(full)
          ..addRRect(hole),
        _paint,
      );
      _paint.color = color.withValues(alpha: color.a * (1 - scrim.holeOpen));
      canvas.drawRRect(hole, _paint);
    }
    if (pill != null && scrim.ring > 0) {
      RingGlowPainter.paintRing(
        canvas,
        RRect.fromRectAndRadius(pill, Radius.circular(pill.height / 2)),
        ChestCollectTokens.pillRingShadow,
        opacity: scrim.ring,
      );
    }
  }

  @override
  bool shouldRepaint(GiftScrimPainter oldDelegate) =>
      oldDelegate.scrim != scrim || oldDelegate.color != color;
}

/// The gift sheet's route: a modal bottom sheet whose barrier is
/// [GiftScrim]'s (fading in and out with the route, as the plain sheet's
/// does), so a coin claim can open the hole round the pill. Taps on the
/// scrim still close the sheet.
class GiftSheetRoute<T> extends ModalBottomSheetRoute<T> {
  GiftSheetRoute({
    required this.scrim,
    required super.builder,
    required super.isScrollControlled,
    super.capturedThemes,
    super.barrierLabel,
    super.barrierOnTapHint,
    super.backgroundColor,
    super.sheetAnimationStyle,
  }) : super(modalBarrierColor: const Color(0x00000000));

  final GiftScrim scrim;

  @override
  Widget buildModalBarrier() => Stack(
    fit: StackFit.expand,
    children: [
      IgnorePointer(
        child: FadeTransition(
          opacity: animation!.drive(CurveTween(curve: barrierCurve)),
          child: CustomPaint(painter: GiftScrimPainter(scrim)),
        ),
      ),
      // The plain (transparent) barrier: it closes the sheet on a tap and
      // keeps the bottom sheet's screen-reader dismiss node.
      super.buildModalBarrier(),
    ],
  );

  @override
  void dispose() {
    super.dispose();
    scrim.dispose();
  }
}
