import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/asset_skin_service.dart';
import 'package:nesty_game/core/services/skin/doll_part_source.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../../helpers/level_fixtures.dart';

/// A locked slot (opened by red) and an iced one, from nesty_core's
/// `006_ice_thaws` and `007_lock_opens` fixtures.
const _lockedAndIcedJson = '''
{
  "schemaVersion": 1,
  "id": "T_lock_ice",
  "maxSize": 3,
  "shelves": [
    [ {"type": "locked", "unlockColor": "red", "nest": ["blue3"]},
      {"type": "open", "nest": ["red3"]},
      {"type": "open", "nest": ["red2", "red1"]} ],
    [ {"type": "open", "nest": ["blue2", "blue1"], "ice": 2},
      {"type": "open", "nest": null} ]
  ]
}
''';

Future<ui.Image> _image(int width, int height) {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
    ui.Paint(),
  );
  return recorder.endRecording().toImage(width, height);
}

/// Builds real `DollPartSet`s from blank images, or fails on request.
final class _FakeParts implements DollPartSource {
  _FakeParts({this.failSkin = false, this.failPlaceholder = false});

  final bool failSkin;
  final bool failPlaceholder;
  final List<String> calls = [];
  List<DollColor>? colors;
  DollSymbols? symbols;
  int? artHeightPx;

  /// The board library each call was given, for the wood-blank silhouette.
  final List<BoardSpriteLibrary?> boards = [];
  bool disposed = false;

  @override
  Future<DollPartSet> prepare({
    required SkinRasterizer skin,
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
    BoardSpriteLibrary? board,
  }) async {
    calls.add('skin');
    boards.add(board);
    if (failSkin) throw StateError('skin raster failed');
    return _set(skin.cacheKey, colors, symbols, artHeightPx);
  }

  @override
  Future<DollPartSet> preparePlaceholder({
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
    BoardSpriteLibrary? board,
  }) async {
    calls.add('placeholder');
    boards.add(board);
    if (failPlaceholder) throw StateError('placeholder raster failed');
    return _set('placeholder', colors, symbols, artHeightPx);
  }

  Future<DollPartSet> _set(
    String key,
    Iterable<DollColor> colors,
    DollSymbols symbols,
    int artHeightPx,
  ) async {
    this.colors = colors.toList();
    this.symbols = symbols;
    this.artHeightPx = artHeightPx;
    final width = (DollArt.width * artHeightPx / DollArt.height).round();
    return DollPartSet(
      skinKey: key,
      symbols: symbols,
      artHeightPx: artHeightPx,
      lids: {for (final c in colors) c: await _image(width, artHeightPx)},
      bodies: {for (final c in colors) c: await _image(width, artHeightPx)},
      silhouette: await _image(width, artHeightPx),
    );
  }

  @override
  void dispose() => disposed = true;
}

final class _FailingLoader implements SkinLoader {
  @override
  Future<SkinSource> load(String skinId) async =>
      throw SkinLoadException(skinId, StateError('missing'));
}

/// rootBundle, except for the keys [blocked] refuses.
final class _Bundle extends CachingAssetBundle {
  _Bundle(this.blocked);

  final bool Function(String key) blocked;

  @override
  Future<ByteData> load(String key) async {
    if (blocked(key)) throw StateError('Unable to load asset: $key');
    return rootBundle.load(key);
  }
}

BoardGeometry _geometryOf(Level level) {
  final ids = level.slotIds;
  var i = 0;
  return BoardLayout.compute(
    BoardShape(
      rows: [
        for (final shelf in level.shelves)
          [
            for (final slot in shelf)
              SlotShape(ids[i++], switch (slot) {
                OpenSlot() => SlotShapeKind.open,
                TowerSlot() => SlotShapeKind.tower,
                LockedSlot() => SlotShapeKind.locked,
              }),
          ],
      ],
      maxSize: level.maxSize,
    ),
    BoardViewport.reference,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final tutorial = levelFrom(tutorialLevelJson);
  final lockedAndIced = levelFrom(_lockedAndIcedJson);

  Future<(AssetSkinService, LevelSkin)> prepare(
    Level level, {
    DollPartSource? parts,
    SkinLoader? skinLoader,
    AssetBundle? bundle,
    double dpr = 2,
    DollSymbols symbols = DollSymbols.subtle,
  }) async {
    final service = AssetSkinService(
      parts: parts ?? _FakeParts(),
      skinLoader: skinLoader,
      bundle: bundle,
    );
    addTearDown(service.dispose);
    final skin = await service.prepareForLevel(
      level,
      geometry: _geometryOf(level),
      devicePixelRatio: dpr,
      symbols: symbols,
    );
    addTearDown(skin.dispose);
    return (service, skin);
  }

  test('prepares a board from the bundled Classic skin: part rasters for '
      'the colours on the board, sprites, part-raster rest dolls', () async {
    final parts = _FakeParts();
    final geometry = _geometryOf(tutorial);
    final (service, skin) = await prepare(
      tutorial,
      parts: parts,
      symbols: DollSymbols.large,
    );

    expect(service.hasSkin, isTrue);
    expect(service.hasBoardArt, isTrue);
    expect(parts.calls, ['skin']);
    expect(parts.colors, [DollColor.red]);
    expect(parts.symbols, DollSymbols.large);
    expect(
      parts.artHeightPx,
      DollPartRasters.artHeightPxFor(
        tallestDollHeight: geometry.maxDollHeight,
        devicePixelRatio: 2,
      ),
    );
    expect(skin.restRenderer, isA<PartRasterDollRenderer>());
    final sprites = skin.sprites!;
    expect(sprites.imagesOf(BoardSprite.slotStand), isNotEmpty);
    expect(sprites.imagesOf(BoardSprite.dollSilhouette), isNotEmpty);
    expect(sprites.imagesOf(BoardSprite.extraSlot), isNotEmpty);
    expect(sprites.imagesOf(BoardSprite.ice0), isEmpty);
  });

  test('doll slots show the role\'s colour; unset, hidden and absent roles '
      'draw nothing', () async {
    final parts = _FakeParts();
    final (_, skin) = await prepare(tutorial, parts: parts);
    final images = skin.images;
    final artScale = parts.artHeightPx! / DollArt.height;
    final request = FxImageRequest()..doll = DollColor.red;

    for (final slot in [
      FxImageSlot.dollLid,
      FxImageSlot.dollBody,
      FxImageSlot.dollSilhouette,
    ]) {
      final raster = images.rasterFor(slot, request)!;
      expect(raster.scale, artScale, reason: slot.name);
      expect(raster.origin, ui.Offset.zero);
      expect(raster.image.height, parts.artHeightPx);
      // Built once: the same object on every draw (rule 8).
      expect(images.rasterFor(slot, request), same(raster));
    }
    expect(
      images.rasterFor(FxImageSlot.dollLid, request),
      isNot(same(images.rasterFor(FxImageSlot.dollBody, request))),
    );
    expect(images.rasterFor(FxImageSlot.moverLid, request), isNull);
    expect(images.rasterFor(FxImageSlot.targetBody, request), isNull);

    request
      ..mover = DollColor.red
      ..target = DollColor.blue; // not on this board
    expect(images.rasterFor(FxImageSlot.moverBody, request), isNotNull);
    expect(images.rasterFor(FxImageSlot.targetBody, request), isNull);

    request
      ..hideDoll = true
      ..hideMover = true;
    expect(images.rasterFor(FxImageSlot.dollLid, request), isNull);
    expect(images.rasterFor(FxImageSlot.moverLid, request), isNull);
  });

  test('board pieces come at the slot\'s furniture scale, with the crop '
      'offset as the origin', () async {
    const dpr = 2.0;
    final (_, skin) = await prepare(tutorial, dpr: dpr);
    final slot = _geometryOf(tutorial).slots.first;
    final request = FxImageRequest()..furnitureScale = slot.furnitureScale;

    for (final piece in [
      FxImageSlot.glowRing,
      FxImageSlot.hintArrow,
      FxImageSlot.extraSlot,
    ]) {
      final raster = skin.images.rasterFor(piece, request)!;
      final sprite = skin.sprites!.image(piece.piece!, slot.furnitureScale)!;
      expect(raster.image, same(sprite.image), reason: piece.name);
      expect(raster.scale, closeTo(slot.furnitureScale * dpr, 1e-9));
      expect(
        raster.origin.dx,
        closeTo(sprite.offset.dx / sprite.pixelScale, 1e-9),
      );
      expect(
        raster.origin.dy,
        closeTo(sprite.offset.dy / sprite.pixelScale, 1e-9),
      );
      expect(skin.images.rasterFor(piece, request), same(raster));
    }
    // No lock on this board: no unlock symbol.
    request.unlockColor = DollColor.red;
    expect(skin.images.rasterFor(FxImageSlot.unlockSymbol, request), isNull);
  });

  test('a locked slot gets its unlock symbol at 12 × fs × DPR px, and an '
      'iced slot every ice frame', () async {
    const dpr = 3.0;
    final geometry = _geometryOf(lockedAndIced);
    final (_, skin) = await prepare(lockedAndIced, dpr: dpr);
    final locked = geometry.slot(lockedAndIced.slotIds.first);
    final iced = geometry.slot(lockedAndIced.slotIds[3]);

    final request = FxImageRequest()
      ..unlockColor = DollColor.red
      ..furnitureScale = locked.furnitureScale;
    final symbol = skin.images.rasterFor(FxImageSlot.unlockSymbol, request)!;
    expect(symbol.image.width, (12 * locked.furnitureScale * dpr).round());
    expect(symbol.image.height, symbol.image.width);
    expect(symbol.scale, symbol.image.width / 12);
    expect(
      skin.images.rasterFor(
        FxImageSlot.unlockSymbol,
        request..unlockColor = DollColor.blue,
      ),
      isNull,
    );

    final sprites = skin.sprites!;
    expect(sprites.forSlot(BoardSprite.glassCase0, locked), isNotNull);
    for (final frame in [
      BoardSprite.ice0,
      BoardSprite.ice1,
      BoardSprite.ice2,
      BoardSprite.ice3,
      BoardSprite.iceShatter,
    ]) {
      expect(
        sprites.imagesOf(frame).map((i) => i.pixelScale),
        contains(closeTo(iced.furnitureScale * dpr, 1e-9)),
        reason: frame.name,
      );
    }
    expect(AssetSkinService.colorsOf(lockedAndIced), [
      DollColor.red,
      DollColor.blue,
    ]);
  });

  test('a skin that fails to load falls back to placeholder parts, drawn by '
      'the same part-raster renderer', () async {
    final parts = _FakeParts();
    final (service, skin) = await prepare(
      tutorial,
      parts: parts,
      skinLoader: _FailingLoader(),
    );

    expect(service.hasSkin, isFalse);
    expect(parts.calls, ['placeholder']);
    expect(skin.restRenderer, isA<PartRasterDollRenderer>());
    expect(
      skin.images.rasterFor(
        FxImageSlot.dollBody,
        FxImageRequest()..doll = DollColor.red,
      ),
      isNotNull,
    );
  });

  test(
    'skin parts that fail to rasterize fall back to the placeholder',
    () async {
      final parts = _FakeParts(failSkin: true);
      final (_, skin) = await prepare(tutorial, parts: parts);

      expect(parts.calls, ['skin', 'placeholder']);
      expect(skin.restRenderer, isA<PartRasterDollRenderer>());
    },
  );

  test('the part rasters get the board library, so every skin\'s buried '
      'nests show the wood blank (owner decision 3e)', () async {
    final parts = _FakeParts(failSkin: true);
    final (service, _) = await prepare(tutorial, parts: parts);

    expect(service.hasBoardArt, isTrue);
    expect(parts.calls, ['skin', 'placeholder']);
    // The skin path and the rule-3 placeholder path both draw the blank.
    expect(parts.boards, hasLength(2));
    expect(parts.boards, everyElement(isA<BoardSpriteLibrary>()));
    expect(parts.boards.first, same(parts.boards.last));
  });

  test('a missing wood blank reaches the part rasters as unavailable, so '
      'they keep the skin\'s own silhouette (rule 3)', () async {
    final parts = _FakeParts();
    await prepare(
      tutorial,
      parts: parts,
      bundle: _Bundle((key) => key == 'assets/board/doll-silhouette.svg'),
    );

    final board = parts.boards.single!;
    expect(board.isAvailable(BoardSprite.dollSilhouette), isFalse);
    expect(board.isAvailable(BoardSprite.slotStand), isTrue);
  });

  test('when no parts can be made at all, the placeholder painter draws the '
      'rest dolls and doll slots stay empty', () async {
    final (_, skin) = await prepare(
      tutorial,
      parts: _FakeParts(failSkin: true, failPlaceholder: true),
    );

    expect(skin.restRenderer, isA<PlaceholderDollPainter>());
    expect(
      skin.images.rasterFor(
        FxImageSlot.dollLid,
        FxImageRequest()..doll = DollColor.red,
      ),
      isNull,
    );
    expect(skin.sprites, isNotNull);
  });

  test('with no art at all it still returns a board that draws '
      '(rule 3)', () async {
    final (service, skin) = await prepare(
      lockedAndIced,
      parts: _FakeParts(failSkin: true, failPlaceholder: true),
      skinLoader: _FailingLoader(),
      bundle: _Bundle((_) => true),
    );

    expect(service.hasSkin, isFalse);
    expect(skin.restRenderer, isA<PlaceholderDollPainter>());
    final request = FxImageRequest()
      ..doll = DollColor.red
      ..unlockColor = DollColor.red;
    for (final slot in FxImageSlot.values) {
      expect(skin.images.rasterFor(slot, request), isNull, reason: slot.name);
    }
  });

  test('load runs once, and every board shares it', () async {
    final parts = _FakeParts();
    final service = AssetSkinService(parts: parts);
    addTearDown(service.dispose);

    expect(identical(service.load(), service.load()), isTrue);
    await service.load();
    for (var i = 0; i < 2; i++) {
      final skin = await service.prepareForLevel(
        tutorial,
        geometry: _geometryOf(tutorial),
        devicePixelRatio: 1,
        symbols: DollSymbols.subtle,
      );
      skin
        ..dispose()
        ..dispose();
    }
    expect(parts.calls, ['skin', 'skin']);
  });

  test('the theme background is one per app, and dispose releases it', () {
    final service = AssetSkinService(parts: _FakeParts());

    final background = service.background;
    expect(background, isNotNull);
    expect(service.background, same(background));

    service
      ..dispose()
      ..dispose();
    expect(service.background, isNull);
  });

  test('+Slot art is prepared only while a stand can still be added', () {
    final geometry = _geometryOf(tutorial);
    expect(AssetSkinService.canStillAddExtraSlot(geometry), isTrue);

    final twoAdded = BoardLayout.compute(
      geometry.shape.withExtraSlot('x0').withExtraSlot('x1'),
      BoardViewport.reference,
    );
    expect(AssetSkinService.canStillAddExtraSlot(twoAdded), isFalse);
  });

  test('the real part rasters (nesty_render) never make it throw', () async {
    final (_, skin) = await prepare(tutorial, parts: DollPartRastersSource());
    final raster = skin.images.rasterFor(
      FxImageSlot.dollLid,
      FxImageRequest()..doll = DollColor.red,
    );
    // Null only while the render lane's rasterizer is missing.
    if (raster != null) {
      expect(raster.image.height % 3, 0);
      expect(raster.scale, raster.image.height / DollArt.height);
    }
  });
}
