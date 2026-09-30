// DebugBoardPainter: a whole static board through BoardLayout +
// BoardSprites + DollRenderer, for golden-free visual smoke tests and the
// admin's preview. The board is the design's MAIN one (NestyBoard:80–84,
// the default `play` scene, frame 2.2).
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart' show DollColor;
import 'package:nesty_render/nesty_render.dart';

import '../doll/support/render_test_support.dart';
import 'board_fixtures.dart';
import 'main_board_contents.dart';

const _screen = Size(390, 844);

DebugBoardPainter _mainPainter(
  BoardSprites sprites, {
  SymbolAtlas? symbols,
  Map<String, DebugSlot> slots = mainBoardContents,
}) => DebugBoardPainter(
  shape: mainBoard,
  slots: slots,
  sprites: sprites,
  renderer: PlaceholderDollPainter(),
  padding: BoardViewport.reference.padding,
  symbolAtlas: symbols,
);

/// The capture's RGBA at reference point ([x], [y]) on a 2× raster.
List<int> _at(Uint8List rgba, double x, double y) {
  final at = ((y * 2).round() * 780 + (x * 2).round()) * 4;
  return rgba.sublist(at, at + 4);
}

Matcher _near(List<int> expected, [int tolerance = 8]) => predicate<List<int>>(
  (actual) => [
    for (var c = 0; c < 4; c++) (actual[c] - expected[c]).abs() <= tolerance,
  ].every((ok) => ok),
  'within $tolerance of $expected',
);

List<int> _rgba(ui.Color c) => [
  (c.r * 255).round(),
  (c.g * 255).round(),
  (c.b * 255).round(),
  255,
];

void main() {
  group('DebugSlot', () {
    test('value equality', () {
      const a = DebugSlot(color: DollColor.red, sizes: [4, 3], ice: 2);
      // A separate instance with an equal (not identical) list.
      final b = DebugSlot(color: DollColor.red, sizes: List.of([4, 3]), ice: 2);
      expect(identical(a, b), isFalse);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a == const DebugSlot(color: DollColor.red, sizes: [4]), isFalse);
      expect(a.hasNest, isTrue);
      expect(DebugSlot.empty.hasNest, isFalse);
    });
  });

  group('widget', () {
    late BoardSpriteLibrary library;

    testWidgets('pumps the design\'s MAIN board without errors', (
      tester,
    ) async {
      tester.view
        ..physicalSize = const Size(1170, 2532)
        ..devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      final painter = (await tester.runAsync(() async {
        library = await BoardSpriteLibrary.load(FileAssetBundle());
        final painter = _mainPainter(BoardSprites(library));
        await painter.prepare(size: _screen, devicePixelRatio: 3);
        return painter;
      }))!;
      addTearDown(() {
        painter
          ..dispose()
          ..sprites.dispose();
        library.dispose();
      });

      await tester.pumpWidget(
        SizedBox.expand(child: CustomPaint(painter: painter)),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(CustomPaint)), _screen);
      // Planks (tiled shader), then sprites, pips, tags and badge text.
      expect(
        find.byType(CustomPaint),
        paints
          ..clipRect()
          ..something((method, _) => method == #drawPaint)
          ..something((method, _) => method == #drawImage)
          ..circle()
          ..rrect()
          ..paragraph(),
      );
    });

    testWidgets('paints before its sprites exist, then repaints', (
      tester,
    ) async {
      final sprites = (await tester.runAsync(() async {
        library = await BoardSpriteLibrary.load(FileAssetBundle());
        return BoardSprites(library);
      }))!;
      final painter = _mainPainter(sprites);
      addTearDown(() {
        sprites.dispose();
        library.dispose();
      });
      await tester.pumpWidget(
        SizedBox.expand(child: CustomPaint(painter: painter)),
      );
      expect(tester.takeException(), isNull);
      await tester.runAsync(
        () => painter.prepare(size: _screen, devicePixelRatio: 3),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      expect(sprites.isPrepared, isTrue);
    });
  });

  group('visual smoke at 390×844 @2', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    late BoardSpriteLibrary library;
    late BoardSprites sprites;
    late SymbolAtlas atlas;
    late DebugBoardPainter painter;
    late Uint8List rgba;
    late BoardGeometry geometry;

    setUpAll(() async {
      library = await BoardSpriteLibrary.load(FileAssetBundle());
      sprites = BoardSprites(library);
      atlas = await loadSymbols();
      painter = _mainPainter(sprites, symbols: atlas);
      geometry = await painter.prepare(size: _screen, devicePixelRatio: 2);
      final image = await capture(780, 1688, (canvas) {
        canvas.scale(2);
        painter.paint(canvas, _screen);
      });
      rgba = await rgbaOf(image);
      image.dispose();
    });

    tearDownAll(() {
      painter.dispose();
      sprites.dispose();
      atlas.dispose();
      library.dispose();
    });

    test('prepares the ice frame the board shows', () {
      expect(painter.frames, {BoardSprite.ice0});
      expect(sprites.imagesOf(BoardSprite.ice0), hasLength(1));
      expect(
        _mainPainter(
          sprites,
          slots: {
            ...mainBoardContents,
            'r1c3': const DebugSlot(
              color: DollColor.green,
              sizes: [2],
              unlockColor: DollColor.purple,
              glassFrame: 1,
            ),
            'r2c1': const DebugSlot(
              color: DollColor.blue,
              sizes: [1],
              ice: 1,
              iceInitial: 3,
            ),
          },
        ).frames,
        {BoardSprite.glassCase1, BoardSprite.ice2},
      );
    });

    test('planks tile from the plank art', () async {
      final tile = sprites.imagesOf(BoardSprite.shelfPlank).single;
      final tileRgba = await rgbaOf(tile.image);
      for (final shelf in geometry.shelves) {
        for (final dy in [4.0, 20.0, 36.0]) {
          final at = ((dy * 2).round() * tile.image.width + 8) * 4;
          expect(
            _at(rgba, 4, shelf.plankTop + dy),
            _near(tileRgba.sublist(at, at + 4), 2),
            reason: 'row ${shelf.row} +$dy',
          );
        }
      }
    });

    test('pips show the top nest, biggest on the left (spec §10.3)', () {
      // r0c0 holds red [4, 3]: pips 0 and 1 red, 2 and 3 empty.
      final slot = geometry.slot('r0c0');
      final red = _rgba(DollPalette.of(DollColor.red).base);
      final empty = _rgba(BoardTokens.pipEmptyColor);
      expect(_at(rgba, slot.pipCenterX(0), slot.pipCenterY), _near(red));
      expect(_at(rgba, slot.pipCenterX(1), slot.pipCenterY), _near(red));
      expect(_at(rgba, slot.pipCenterX(2), slot.pipCenterY), _near(empty, 16));
      expect(_at(rgba, slot.pipCenterX(3), slot.pipCenterY), _near(empty, 16));
      // r0c3 holds purple [3, 2, 1].
      final purple = geometry.slot('r0c3');
      expect(
        _at(rgba, purple.pipCenterX(0), purple.pipCenterY),
        _near(empty, 16),
      );
      expect(
        _at(rgba, purple.pipCenterX(3), purple.pipCenterY),
        _near(_rgba(DollPalette.of(DollColor.purple).base)),
      );
    });

    test('dolls stand on their stands', () {
      final slot = geometry.slot('r0c0');
      // Below the fallback doll's cream belly disc.
      final body = _at(rgba, slot.centerX, slot.surfaceY - 8);
      expect(body[0], greaterThan(body[1] + 60), reason: 'red doll: $body');
      expect(body[0], greaterThan(body[2] + 60), reason: 'red doll: $body');
      // Above the tallest doll the board is empty (no background given).
      expect(_at(rgba, 195, 150)[3], 0);
    });

    test('the tower tag, the ice and its badge, the glass case', () {
      final tower = geometry.slot('r1c0');
      final tag = tower.towerTagOrigin;
      expect(
        _at(rgba, tag.dx + 2.5, tag.dy + 9),
        _near([0x7B, 0x48, 0x24, 0xFF]),
        reason: 'walnut "+1" tag (NestyBoard:16)',
      );

      final ice = geometry.slot('r2c1');
      final frost = _at(rgba, ice.iceRect.left + 13, ice.iceRect.top + 20);
      expect(frost[3], greaterThan(100), reason: 'ice overlay: $frost');
      expect(frost[2], greaterThanOrEqualTo(frost[0]), reason: 'bluish');
      final badge = ice.iceBadgeRect;
      final blue = _at(rgba, badge.center.dx, badge.top + 2.5);
      expect(blue[2], greaterThan(200), reason: 'badge: $blue');
      expect(blue[0], lessThan(150), reason: 'badge: $blue');

      final locked = geometry.slot('r1c3');
      final wood = _at(
        rgba,
        locked.glassCaseRect.left + 9,
        locked.glassCaseRect.top + locked.glassCaseRect.height * 0.9,
      );
      expect(wood[3], 255, reason: 'the case base is opaque: $wood');
      expect(wood[0], greaterThan(wood[2] + 40), reason: 'wood: $wood');
    });

    test('the padlock carries the unlock colour\'s symbol', () {
      final locked = geometry.slot('r1c3');
      final ink = DollPalette.of(DollColor.purple).ink;
      final center = _at(
        rgba,
        locked.padlockSymbolCenter.dx,
        locked.padlockSymbolCenter.dy,
      );
      expect(center, _near(_rgba(ink), 24), reason: 'purple star: $center');
    });
  });
}
