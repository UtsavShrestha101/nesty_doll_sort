import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/design_lottie.dart';

void main() {
  test('FxImageSlot covers every image asset of every file, at its declared '
      'asset size', () {
    final declared = <String, (double, double)>{};
    for (final name in designLottieNames()) {
      for (final asset in readDesignLottie(name)['assets']! as List<Object?>) {
        final a = asset! as Map<String, Object?>;
        if (a['p'] == null) continue; // a precomp
        declared[a['id']! as String] = (
          (a['w']! as num).toDouble(),
          (a['h']! as num).toDouble(),
        );
      }
    }
    expect(
      FxImageSlot.values.map((s) => s.assetId).toSet(),
      declared.keys.toSet(),
    );
    for (final slot in FxImageSlot.values) {
      expect(
        (slot.assetWidth, slot.assetHeight),
        declared[slot.assetId],
        reason: slot.assetId,
      );
      expect(FxImageSlot.fromAssetId(slot.assetId), slot);
    }
    expect(FxImageSlot.fromAssetId('doll_matte'), isNull);
  });

  test('board pieces and the unlock symbol are declared at 3× their box '
      '(LOTTIE.md v3); rasters count in the box, which the skin service '
      'knows', () {
    expect(FxImageSlot.pieceDensity, 3);
    for (final slot in FxImageSlot.values) {
      final piece = slot.piece;
      expect(slot.assetWidth, slot.declaredWidth * slot.density);
      expect(slot.assetHeight, slot.declaredHeight * slot.density);
      if (slot.isDoll) {
        expect(slot.density, 1);
        expect((slot.declaredWidth, slot.declaredHeight), (512.0, 768.0));
      } else if (piece != null) {
        expect(slot.density, 3);
        // The sprite's reference-board box (glow ring 116×52).
        expect(
          (slot.declaredWidth, slot.declaredHeight),
          (piece.designSize.width, piece.designSize.height),
          reason: slot.assetId,
        );
      } else if (slot.art != null) {
        // m7-3's UI art (`ui_stars`, `ui_chest`): at 3× like the pieces, its
        // box the file's own (44 stars, the 73.3 glow, the 130×108.3 chest).
        expect(slot.density, 3, reason: slot.assetId);
      } else if (slot == FxImageSlot.unlockSymbol) {
        expect(slot.density, 3);
        expect((slot.declaredWidth, slot.declaredHeight), (12.0, 12.0));
      } else {
        // m7-4: the rival portrait (96) and the Museum figurine (62), at 3×;
        // which rival or figurine is the caller's.
        expect(slot, isIn([FxImageSlot.rivalPortrait, FxImageSlot.figurine]));
        expect(slot.density, 3);
      }
    }
    expect(FxImageSlot.starFilled.declaredWidth, 44);
    expect(FxImageSlot.starGlow.declaredWidth, closeTo(73.33, 0.01));
    expect(FxImageSlot.chestOpen.declaredWidth, 130);
    expect(FxImageSlot.rivalPortrait.declaredWidth, 96);
    expect(FxImageSlot.figurine.declaredHeight, 62);
    expect(FxImageSlot.chestOpen.declaredHeight, closeTo(108.33, 0.01));
    expect(
      (FxImageSlot.glowRing.assetWidth, FxImageSlot.glowRing.declaredWidth),
      (348, 116),
    );
  });

  test('a board sprite fills its piece slot as it comes: pixelScale per box '
      'unit, its crop in box units', () async {
    final library = await BoardSpriteLibrary.fromSvgs({
      BoardSprite.glowRing:
          '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 116 52" '
          'width="116" height="52"><ellipse cx="58" cy="26" rx="40" ry="14" '
          'fill="#FFD27A"/></svg>',
    });
    addTearDown(library.dispose);
    final sprite = await library.rasterize(BoardSprite.glowRing, 2.4);
    addTearDown(sprite.image.dispose);
    // What LevelSkinImages serves (m2-lottie-design §3).
    final raster = FxRaster(
      sprite.image,
      scale: sprite.pixelScale,
      origin: sprite.cropOrigin,
    );
    expect(raster.origin.dx, greaterThan(0), reason: 'the ellipse is cropped');
    // The compensation: 2.4 raster px per box unit are 0.8 per asset px, so
    // the layer's 33.33 % becomes 1/2.4 and a raster px lands on
    // 1/2.4 box units, whatever the export's density.
    const k = 1 / 3;
    final r = raster.scale / FxImageSlot.glowRing.density;
    expect(r, closeTo(0.8, 1e-12));
    expect(k / r, closeTo(1 / 2.4, 1e-12));
  });

  test('doll slots name their role and part; board pieces their sprite; UI '
      'art its UiArt', () {
    for (final slot in FxImageSlot.values) {
      expect(slot.isDoll, slot.part != null);
      if (const [
        FxImageSlot.unlockSymbol,
        FxImageSlot.rivalPortrait,
        FxImageSlot.figurine,
      ].contains(slot)) {
        // Filled per use (the padlock's colour, the rival, the figurine).
        expect(slot.piece, isNull);
        expect(slot.art, isNull);
      } else {
        // Exactly one source per slot.
        expect(
          [slot.isDoll, slot.piece != null, slot.art != null].where((b) => b),
          hasLength(1),
          reason: slot.name,
        );
      }
    }
    expect(FxImageSlot.glassCaseTall1.piece, BoardSprite.glassCaseTall1);
    expect(FxImageSlot.moverBody.role, FxRole.mover);
    expect(FxImageSlot.moverBody.part, FxDollPart.body);
    expect(FxImageSlot.dollSilhouette.part, FxDollPart.silhouette);
  });

  test('FxImageRequest resolves roles, honours hidden roles and resets', () {
    final request = FxImageRequest()
      ..doll = DollColor.red
      ..mover = DollColor.blue
      ..target = DollColor.green;
    expect(request.colorOf(FxRole.doll), DollColor.red);
    expect(request.colorOf(FxRole.mover), DollColor.blue);
    expect(request.colorOf(FxRole.target), DollColor.green);

    request
      ..hideMover = true
      ..hideTarget = true;
    expect(request.colorOf(FxRole.mover), isNull);
    expect(request.colorOf(FxRole.target), isNull);
    expect(request.colorOf(FxRole.doll), DollColor.red);

    request
      ..furnitureScale = 0.8
      ..unlockColor = DollColor.pink
      ..reset();
    expect(request.colorOf(FxRole.doll), isNull);
    expect(request.hideMover, isFalse);
    expect(request.unlockColor, isNull);
    expect(request.furnitureScale, 1);
  });
}
