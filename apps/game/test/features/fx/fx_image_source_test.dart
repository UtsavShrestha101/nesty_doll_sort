import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';

import 'support/design_lottie.dart';

void main() {
  test('FxImageSlot covers every image asset of every file, at its declared '
      'size', () {
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
        (slot.declaredWidth, slot.declaredHeight),
        declared[slot.assetId],
        reason: slot.assetId,
      );
      expect(FxImageSlot.fromAssetId(slot.assetId), slot);
    }
    expect(FxImageSlot.fromAssetId('doll_matte'), isNull);
  });

  test('doll slots name their role and part; board pieces their sprite', () {
    for (final slot in FxImageSlot.values) {
      expect(slot.isDoll, slot.part != null);
      if (slot == FxImageSlot.unlockSymbol) {
        expect(slot.piece, isNull);
      } else {
        expect(slot.isDoll || slot.piece != null, isTrue, reason: slot.name);
      }
    }
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
