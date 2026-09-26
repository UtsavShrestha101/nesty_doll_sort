import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_layout.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

void main() {
  test('board pieces use the furniture scale, dolls and sparkles the board '
      'scale (§5)', () {
    for (final id in FxId.values.where((id) => id.host == FxHost.board)) {
      final expected = switch (id) {
        FxId.fxSelectGlow ||
        FxId.fxGlassUnlock ||
        FxId.fxIce ||
        FxId.fxDustPuff ||
        FxId.uiHintArrow ||
        FxId.uiExtraSlot => 0.6,
        _ => 0.8,
      };
      expect(
        FxLayout.scaleOf(id, boardScale: 0.8, furnitureScale: 0.6),
        expected,
        reason: id.fileName,
      );
    }
  });

  test('the anchor as canvas fractions, and the top-left it implies', () {
    final pick = fxSpecOf(FxId.dollPick);
    expect(FxLayout.anchorFraction(pick), (0.5, 230 / 260));
    expect(
      FxLayout.topLeft(pick, 100, 400, 0.5),
      const Offset(100 - 40, 400 - 115),
    );
    expect(FxLayout.anchorFraction(fxSpecOf(FxId.dollMove)), (0.0, 0.0));
  });

  test('size factors: h / (150 · scale); the nested mover is hM / hT', () {
    expect(FxLayout.sizeFactor(150, 1), 1);
    expect(FxLayout.sizeFactor(90, 0.75), closeTo(0.8, 1e-12));

    final nest = FxDrawableParams();
    FxLayout.applyDollHeights(
      nest,
      fxSpecOf(FxId.dollNest),
      compositionScale: 0.8,
      mover: 60,
      target: 96,
    );
    expect(nest.sizeOf(FxRole.target), const Offset(0.8, 0.8));
    expect(nest.sizeOf(FxRole.mover)!.dx, closeTo(60 / 96, 1e-12));
    expect(nest.sizeOf(FxRole.doll), isNull);

    final invalid = FxDrawableParams();
    FxLayout.applyDollHeights(
      invalid,
      fxSpecOf(FxId.dollInvalid),
      compositionScale: 0.8,
      mover: 60,
      target: 96,
    );
    expect(invalid.sizeOf(FxRole.mover)!.dx, closeTo(60 / 120, 1e-12));

    // Glass and ice: the doll inside scales with the furniture scale.
    final glass = FxDrawableParams();
    FxLayout.applyDollHeights(
      glass,
      fxSpecOf(FxId.fxGlassUnlock),
      compositionScale: 0.9,
      doll: 105.3,
    );
    expect(glass.sizeOf(FxRole.doll)!.dx, closeTo(0.78, 1e-9));

    // A missing height keeps the authored size.
    FxLayout.applyDollHeights(
      glass,
      fxSpecOf(FxId.fxGlassUnlock),
      compositionScale: 0.9,
    );
    expect(glass.sizeOf(FxRole.doll), isNull);
  });

  test('hover points (LOTTIE.md): 0.50 h for nest, 1.06 h for swallow', () {
    expect(FxLayout.hoverBaseY(FxId.dollNest, 500, 100), 450);
    expect(FxLayout.hoverBaseY(FxId.dollSwallow, 500, 100), 394);
  });

  test('every setter bumps the revision; reset restores the authored', () {
    final params = FxDrawableParams();
    var last = params.revision;
    void bumped() {
      expect(params.revision, greaterThan(last));
      last = params.revision;
    }

    params.setSize(FxRole.doll, 0.5);
    bumped();
    params.rimColor = const Color(0xFFE9BE4E);
    bumped();
    params.tintColor = const Color(0xFFFFF3B0);
    bumped();
    params.setTravel(Offset.zero, const Offset(1, 1));
    bumped();
    params.targetPos = const Offset(3, 4);
    bumped();
    params.reducedMotion = true;
    bumped();
    params.unlockSettle = false;
    bumped();
    params.markChanged();
    bumped();
    params.reset();
    bumped();
    expect(params.sizeOf(FxRole.doll), isNull);
    expect(params.rimColor, isNull);
    expect(params.travelSrc, isNull);
    expect(params.targetPos, isNull);
    expect(params.unlockSettle, isTrue);
    // Reduced motion is the board's, not the clip's: it survives reset.
    expect(params.reducedMotion, isTrue);
  });
}
