import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../../helpers/level_fixtures.dart';

void main() {
  test('prepares a placeholder board: procedural rest dolls, empty image '
      'slots, no sprites', () async {
    final level = levelFrom(tutorialLevelJson);
    final geometry = BoardLayout.compute(
      BoardShape(
        rows: [
          for (var r = 0; r < 2; r++)
            [
              for (var c = 0; c < 3; c++)
                SlotShape('r${r}c$c', SlotShapeKind.open),
            ],
        ],
        maxSize: level.maxSize,
      ),
      BoardViewport.reference,
    );
    final service = FakeSkinService();
    await service.load();

    final skin = await service.prepareForLevel(
      level,
      geometry: geometry,
      devicePixelRatio: 3,
      symbols: DollSymbols.subtle,
    );

    expect(service.background, isNull);
    expect(skin.restRenderer, isA<PlaceholderDollPainter>());
    expect(skin.sprites, isNull);
    final request = FxImageRequest()..doll = DollColor.red;
    for (final slot in FxImageSlot.values) {
      expect(skin.images.rasterFor(slot, request), isNull);
    }
    skin
      ..dispose()
      ..dispose();
  });

  test('selectSkin always succeeds and prepareShowcase always returns a '
      'placeholder board (m3-design §9.2)', () async {
    final service = FakeSkinService();
    expect(service.selectedSkinId, 'classic');

    expect(await service.selectSkin('ocean'), isTrue);
    expect(service.selectedSkinId, 'ocean');

    final showcase = await service.prepareShowcase(
      colors: [DollColor.red],
      devicePixelRatio: 1,
      symbols: DollSymbols.subtle,
      skinId: 'winter',
    );
    expect(showcase, isNotNull);
    expect(showcase!.restRenderer, isA<PlaceholderDollPainter>());
    // The showcase's skinId never disturbs the selected one.
    expect(service.selectedSkinId, 'ocean');
    showcase.dispose();
  });
}
