import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
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

  /// Every `skin.cacheKey` a `prepare` call was given (`skinId@version`), so
  /// tests can tell which skin's art a board or showcase actually used.
  final List<String> keys = [];
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
    keys.add(skin.cacheKey);
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

/// Like the real `DollPartRasters`: draws from the rasterizer it is given
/// (so a rasterizer disposed mid-prepare throws `StateError`, and the
/// service falls back to the placeholder), but only once [gate] opens, so
/// a test can hold several prepares in flight at once (CORRECTNESS-2).
final class _GatedParts implements DollPartSource {
  final Completer<void> gate = Completer<void>();
  final List<String> calls = [];

  /// Every rasterizer a `prepare` call was given, in call order.
  final List<SkinRasterizer> skins = [];

  @override
  Future<DollPartSet> prepare({
    required SkinRasterizer skin,
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
    BoardSpriteLibrary? board,
  }) async {
    skins.add(skin);
    await gate.future;
    // Throws once the rasterizer is disposed, as DollPartRasters does.
    final image = await skin.rasterizeArtboard(4, paint: (_, _) {});
    calls.add(skin.cacheKey);
    return DollPartSet(
      skinKey: skin.cacheKey,
      symbols: symbols,
      artHeightPx: 4,
      lids: {for (final c in colors) c: image.clone()},
      bodies: {for (final c in colors) c: image.clone()},
      silhouette: image,
    );
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
    final image = await _image((DollArt.width * 4 / DollArt.height).round(), 4);
    return DollPartSet(
      skinKey: 'placeholder',
      symbols: symbols,
      artHeightPx: 4,
      lids: {for (final c in colors) c: image.clone()},
      bodies: {for (final c in colors) c: image.clone()},
      silhouette: image,
    );
  }

  @override
  void dispose() {}
}

/// Whether [skin] was disposed: a disposed rasterizer refuses to draw.
Future<bool> _isDisposed(SkinRasterizer skin) async {
  try {
    (await skin.rasterizeArtboard(1, paint: (_, _) {})).dispose();
    return false;
  } on StateError {
    return true;
  }
}

final class _FailingLoader implements SkinLoader {
  @override
  Future<SkinSource> load(String skinId) async =>
      throw SkinLoadException(skinId, StateError('missing'));
}

/// Loads real bundled skins through [_inner] (normally
/// `AssetBundleSkinLoader(bundle: rootBundle)`), recording every id asked
/// for and failing the ids in [failIds] (m3-design §9.2 growth: `selectSkin`
/// and `prepareShowcase` tests need to tell whether a skin was reloaded).
final class _CountingLoader implements SkinLoader {
  _CountingLoader(this._inner, {this.failIds = const {}});

  final SkinLoader _inner;
  final Set<String> failIds;
  final List<String> calls = [];

  @override
  Future<SkinSource> load(String skinId) async {
    calls.add(skinId);
    if (failIds.contains(skinId)) {
      throw SkinLoadException(skinId, StateError('blocked for test'));
    }
    return _inner.load(skinId);
  }
}

/// rootBundle, except for the keys [blocked] refuses.
final class _Bundle extends CachingAssetBundle {
  _Bundle(this.blocked);

  final bool Function(String key) blocked;
  final List<String> loaded = [];

  @override
  Future<ByteData> load(String key) async {
    loaded.add(key);
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
      FakeSaveService(),
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

  test('chapter 7 to 10 levels draw their own board wood (m7-4 A.5): the '
      'stand, tower base and plank come from board/chNN, the rest is '
      'shared; other themes load none', () async {
    final bundle = _Bundle((_) => false);
    final service = AssetSkinService(
      FakeSaveService(),
      parts: _FakeParts(),
      bundle: bundle,
    );
    addTearDown(service.dispose);
    Future<void> run(String? themeId) async {
      final skin = await service.prepareForLevel(
        tutorial,
        geometry: _geometryOf(tutorial),
        devicePixelRatio: 2,
        symbols: DollSymbols.subtle,
        themeId: themeId,
      );
      skin.dispose();
    }

    await run('ch03');
    expect(bundle.loaded.where((k) => k.contains('/board/ch')), isEmpty);
    await run('ch07');
    expect(bundle.loaded.where((k) => k.contains('/board/ch07/')).toSet(), {
      'assets/board/ch07/slot-stand-blank.svg',
      'assets/board/ch07/tower-base-blank.svg',
      'assets/board/ch07/shelf-plank.svg',
    });
    expect(
      bundle.loaded,
      isNot(contains('assets/board/ch07/glass-case-0.svg')),
    );
    // Loaded once per theme.
    final before = bundle.loaded.length;
    await run('ch07');
    expect(
      bundle.loaded.skip(before).where((k) => k.contains('/board/ch07/')),
      isEmpty,
    );
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
    final service = AssetSkinService(FakeSaveService(), parts: parts);
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
    final service = AssetSkinService(FakeSaveService(), parts: _FakeParts());

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

  group('selectSkin, prepareShowcase and the LRU cache (m3-design §9.2)', () {
    final realLoader = AssetBundleSkinLoader(bundle: rootBundle);

    Future<LevelSkin?> showcase(
      AssetSkinService service, {
      String? skinId,
      List<DollColor> colors = const [DollColor.red],
    }) => service.prepareShowcase(
      colors: colors,
      devicePixelRatio: 1,
      symbols: DollSymbols.subtle,
      skinId: skinId,
    );

    test('switches every later board to a different bundled skin, and keeps '
        'the one it replaced ready in the cache', () async {
      final parts = _FakeParts();
      final loader = _CountingLoader(realLoader);
      final service = AssetSkinService(
        FakeSaveService(),
        parts: parts,
        skinLoader: loader,
      );
      addTearDown(service.dispose);
      await service.load();
      expect(service.selectedSkinId, AssetSkinService.defaultSkinId);
      expect(loader.calls, ['classic']);

      final ok = await service.selectSkin('ocean');
      expect(ok, isTrue);
      expect(service.selectedSkinId, 'ocean');
      expect(service.hasSkin, isTrue);
      expect(loader.calls, ['classic', 'ocean']);

      final skin = await service.prepareForLevel(
        tutorial,
        geometry: _geometryOf(tutorial),
        devicePixelRatio: 1,
        symbols: DollSymbols.subtle,
      );
      addTearDown(skin.dispose);
      expect(parts.keys.last, startsWith('ocean@'));

      // classic was cached as the replaced skin: a showcase for it does not
      // reload.
      loader.calls.clear();
      final classicShowcase = await showcase(service, skinId: 'classic');
      addTearDown(classicShowcase!.dispose);
      expect(loader.calls, isEmpty);
      expect(parts.keys.last, startsWith('classic@'));
    });

    test('selecting the already-equipped skin is a no-op: no reload, no '
        'change', () async {
      final loader = _CountingLoader(realLoader);
      final service = AssetSkinService(
        FakeSaveService(),
        parts: _FakeParts(),
        skinLoader: loader,
      );
      addTearDown(service.dispose);
      await service.load();
      loader.calls.clear();

      final ok = await service.selectSkin('classic');
      expect(ok, isTrue);
      expect(service.selectedSkinId, 'classic');
      expect(loader.calls, isEmpty);
    });

    test('a skin that fails to load on selectSkin keeps the current skin '
        'equipped and reports failure (spec §13.5)', () async {
      final loader = _CountingLoader(realLoader, failIds: {'winter'});
      final service = AssetSkinService(
        FakeSaveService(),
        parts: _FakeParts(),
        skinLoader: loader,
      );
      addTearDown(service.dispose);
      await service.load();

      final ok = await service.selectSkin('winter');
      expect(ok, isFalse);
      expect(service.selectedSkinId, 'classic');
      expect(service.hasSkin, isTrue);
    });

    test('renders a requested skin for the showcase without disturbing the '
        'selected one', () async {
      final parts = _FakeParts();
      final service = AssetSkinService(
        FakeSaveService(),
        parts: parts,
        skinLoader: _CountingLoader(realLoader),
      );
      addTearDown(service.dispose);
      await service.load();

      final skin = await showcase(
        service,
        skinId: 'space',
        colors: [DollColor.red, DollColor.blue],
      );
      addTearDown(skin!.dispose);

      expect(parts.keys.last, startsWith('space@'));
      expect(service.selectedSkinId, 'classic');
      expect(service.hasSkin, isTrue);
    });

    test('defaults to the selected skin when no skinId is given', () async {
      final parts = _FakeParts();
      final service = AssetSkinService(FakeSaveService(), parts: parts);
      addTearDown(service.dispose);
      await service.load();

      final skin = await showcase(service);
      addTearDown(skin!.dispose);
      expect(parts.keys.last, startsWith('classic@'));
    });

    test('a showcase skin that fails to load falls back to the currently '
        'equipped skin\'s art rather than nothing (rule 3)', () async {
      final parts = _FakeParts();
      final loader = _CountingLoader(realLoader, failIds: {'winter'});
      final service = AssetSkinService(
        FakeSaveService(),
        parts: parts,
        skinLoader: loader,
      );
      addTearDown(service.dispose);
      await service.load();

      final skin = await showcase(service, skinId: 'winter');
      addTearDown(() => skin?.dispose());
      expect(skin, isNotNull);
      expect(parts.keys.last, startsWith('classic@'));
    });

    test('at most two non-selected skins stay ready (LRU); a third evicts '
        'the least recently touched one', () async {
      final loader = _CountingLoader(realLoader);
      final service = AssetSkinService(
        FakeSaveService(),
        parts: _FakeParts(),
        skinLoader: loader,
      );
      addTearDown(service.dispose);
      await service.load(); // classic selected; not part of this cache.
      loader.calls.clear();

      Future<void> touch(String id) async {
        (await showcase(service, skinId: id))?.dispose();
      }

      await touch('ocean');
      await touch('space');
      expect(loader.calls, ['ocean', 'space']);
      loader.calls.clear();

      // Both stay ready; touching 'ocean' again marks it the newer one.
      await touch('ocean');
      expect(loader.calls, isEmpty);
      loader.calls.clear();

      // A third distinct skin evicts 'space' (untouched since it was
      // loaded), not 'ocean' (just touched).
      await touch('sweets');
      expect(loader.calls, ['sweets']);
      loader.calls.clear();

      // 'ocean' and 'sweets' both survive.
      await touch('ocean');
      await touch('sweets');
      expect(loader.calls, isEmpty);
      loader.calls.clear();

      // 'space' was evicted, so it reloads.
      await touch('space');
      expect(loader.calls, ['space']);
    });

    test('concurrent showcases of more skins than the cache holds all get '
        'their own art: an evicted rasterizer is only disposed once its last '
        'prepare finishes, and the cache still ends bounded '
        '(CORRECTNESS-2)', () async {
      final parts = _GatedParts();
      final service = AssetSkinService(
        FakeSaveService(),
        parts: parts,
        skinLoader: _CountingLoader(realLoader),
      );
      addTearDown(service.dispose);
      await service.load(); // classic selected.

      // The Shop grid: one card per sold, non-selected skin, all at once.
      const ids = ['space', 'ocean', 'sweets', 'forest', 'winter'];
      final pending = [for (final id in ids) showcase(service, skinId: id)];
      // Hold every prepare until all five skins are loaded (and the LRU
      // has already evicted three of them).
      while (parts.skins.length < ids.length) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      parts.gate.complete();
      final skins = await Future.wait(pending);
      for (final skin in skins) {
        addTearDown(() => skin?.dispose());
      }

      expect(parts.calls, isNot(contains('placeholder')));
      expect(skins, everyElement(isNotNull));
      expect(
        [for (final key in parts.calls) key.split('@').first]..sort(),
        [...ids]..sort(),
      );
      // Bounded: two stay cached, the three evicted ones were freed.
      final disposed = [for (final s in parts.skins) await _isDisposed(s)];
      expect(disposed.where((d) => d), hasLength(3));
      expect(disposed.where((d) => !d), hasLength(2));
    });
  });
}
