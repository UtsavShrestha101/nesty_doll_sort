// BoardSprites (render §1 "board_sprites"): the 15 board SVGs rasterized at
// logical size × layout scale × DPR, cropped, with lazy glass/ice frames and
// a tiled plank shader, inside the render design's memory budget ("board
// sprites 1–2 MB (≤ 5 MB with glass/ice)").
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show EdgeInsets;
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

import '../doll/support/render_test_support.dart';
import 'board_fixtures.dart';

const _mib = 1 << 20;

String _mb(int bytes) => '${(bytes / _mib).toStringAsFixed(2)} MiB';

String _svg(BoardSprite sprite) =>
    File('$gameAssetsDir/board/${sprite.fileName}').readAsStringSync();

/// Waits until [sprites] has an image of [sprite] at [scale].
Future<BoardSpriteImage> _landed(
  BoardSprites sprites,
  BoardSprite sprite,
  double scale,
) async {
  for (var i = 0; i < 200; i++) {
    final image = sprites.image(sprite, scale);
    if (image != null && (image.pixelScale - scale * 3).abs() < 1e-3) {
      return image;
    }
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  throw TimeoutException('$sprite @ $scale never landed');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BoardSpriteLibrary library;

  setUpAll(() async {
    library = await BoardSpriteLibrary.load(FileAssetBundle());
  });

  tearDownAll(() => library.dispose());

  group('BoardSprite', () {
    test('covers exactly the 18 synced board SVGs', () {
      final files = Directory('$gameAssetsDir/board')
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .toSet();
      expect(BoardSprite.values.map((s) => s.fileName).toSet(), files);
      expect(BoardSprite.values, hasLength(18));
    });

    test('boxes are the NestyBoard sizes', () {
      const expected = {
        BoardSprite.slotStand: ui.Size(90, 34), // :163
        BoardSprite.towerBase: ui.Size(90, 39), // :163
        BoardSprite.extraSlot: ui.Size(90, 34), // :163
        BoardSprite.shelfPlank: ui.Size(390, 40), // :12
        BoardSprite.glowRing: ui.Size(116, 52), // :167
        BoardSprite.hintArrow: ui.Size(40, 50), // :208
        BoardSprite.glassCase0: ui.Size(86, 143), // :169
        BoardSprite.glassCase1: ui.Size(86, 143),
        BoardSprite.glassCase2: ui.Size(86, 143),
        // m7-3 `layout.board.glassCaseTall`: 0.62h × 1.0133h at h 150.
        BoardSprite.glassCaseTall0: ui.Size(93, 152),
        BoardSprite.glassCaseTall1: ui.Size(93, 152),
        BoardSprite.glassCaseTall2: ui.Size(93, 152),
        BoardSprite.ice0: ui.Size(96, 160), // :180
        BoardSprite.ice1: ui.Size(96, 160),
        BoardSprite.ice2: ui.Size(96, 160),
        BoardSprite.ice3: ui.Size(96, 160),
        BoardSprite.iceShatter: ui.Size(96, 160),
        BoardSprite.dollSilhouette: ui.Size(12, 18), // :31
      };
      for (final sprite in BoardSprite.values) {
        expect(sprite.designSize, expected[sprite], reason: sprite.name);
      }
      expect(BoardSprite.values.where((s) => s.tiles), [
        BoardSprite.shelfPlank,
      ]);
    });

    test('frame and stand helpers', () {
      expect(
        [for (var f = 0; f < 3; f++) BoardSprite.glassCase(f)],
        [
          BoardSprite.glassCase0,
          BoardSprite.glassCase1,
          BoardSprite.glassCase2,
        ],
      );
      expect(
        [for (var f = 0; f < 4; f++) BoardSprite.ice(f)],
        [
          BoardSprite.ice0,
          BoardSprite.ice1,
          BoardSprite.ice2,
          BoardSprite.ice3,
        ],
      );
      expect(
        [for (var f = 0; f < 3; f++) BoardSprite.glassCaseTall(f)],
        [
          BoardSprite.glassCaseTall0,
          BoardSprite.glassCaseTall1,
          BoardSprite.glassCaseTall2,
        ],
      );
      expect(() => BoardSprite.glassCaseTall(3), throwsRangeError);
      // The tall box is the tokens' ratios at the 150-unit reference doll.
      expect(
        BoardSprite.glassCaseTallSize.width,
        closeTo(GlassCaseTallTokens.widthPerHeight * 150, 0.5),
      );
      expect(
        BoardSprite.glassCaseTallSize.height,
        closeTo(GlassCaseTallTokens.heightPerHeight * 150, 0.5),
      );
      expect(() => BoardSprite.glassCase(3), throwsRangeError);
      expect(() => BoardSprite.ice(-1), throwsRangeError);
      expect(BoardSprite.standFor(SlotShapeKind.open), BoardSprite.slotStand);
      expect(BoardSprite.standFor(SlotShapeKind.locked), BoardSprite.slotStand);
      expect(BoardSprite.standFor(SlotShapeKind.tower), BoardSprite.towerBase);
      expect(BoardSprite.standFor(SlotShapeKind.extra), BoardSprite.extraSlot);
    });
  });

  test('lookups and draws sit in the allocation-guarded hot path', () {
    // test/doll/hot_path_allocation_test.dart scans these regions.
    final source = File('lib/src/board/board_sprites.dart').readAsStringSync();
    final hot = RegExp(
      r'// ── Hot path:[^\n]*\n([\s\S]*?)// ── End of hot path\. ──',
    ).allMatches(source).map((m) => m[1]!).join();
    for (final signature in [
      'void draw(Canvas canvas, Rect dst, [Paint? paint])',
      'BoardSpriteImage? image(BoardSprite sprite, double furnitureScale)',
      'BoardSpriteImage? standFor(SlotGeometry slot)',
      'BoardSpriteImage? forSlot(BoardSprite sprite, SlotGeometry slot)',
      'void drawPlanks(Canvas canvas, BoardGeometry geometry)',
      'void drawPlank(Canvas canvas, ShelfGeometry shelf)',
    ]) {
      expect(hot, contains(signature));
    }
  });

  group('BoardSpriteLibrary', () {
    test('loads all 15 from the bundle with their art sizes', () {
      expect(library.failures, isEmpty);
      expect(library.artSize(BoardSprite.slotStand), const ui.Size(160, 60));
      expect(library.artSize(BoardSprite.towerBase), const ui.Size(160, 70));
      expect(library.artSize(BoardSprite.glassCase0), const ui.Size(180, 300));
      expect(library.artSize(BoardSprite.shelfPlank), const ui.Size(390, 40));
      expect(
        library.artSize(BoardSprite.dollSilhouette),
        const ui.Size(512, 768),
      );
    });

    test('crop boxes hold every visible pixel and little else', () async {
      for (final sprite in BoardSprite.values) {
        final art = library.artSize(sprite)!;
        final crop = await library.cropBox(sprite);
        expect(
          (ui.Offset.zero & art).intersect(crop),
          crop,
          reason: '$sprite inside its art',
        );
        // Ground truth at 4 px per unit: the crop must contain it, and be
        // at most a probe pixel (≤ 3 units) plus margin wider.
        final image = await rasterizeSvg(_svg(sprite), scale: 4);
        final bounds = (await alphaBounds(image))!;
        image.dispose();
        final truth = ui.Rect.fromLTRB(
          bounds.left / 4,
          bounds.top / 4,
          bounds.right / 4,
          bounds.bottom / 4,
        );
        expect(crop.intersect(truth), truth, reason: '$sprite keeps it all');
        final slack = 2 * math.max(art.width, art.height) / 256 + 0.5;
        expect(truth.left - crop.left, lessThanOrEqualTo(slack));
        expect(truth.top - crop.top, lessThanOrEqualTo(slack));
        expect(crop.right - truth.right, lessThanOrEqualTo(slack));
        expect(crop.bottom - truth.bottom, lessThanOrEqualTo(slack));
      }
      expect(
        await library.cropBox(BoardSprite.shelfPlank),
        const ui.Rect.fromLTWH(0, 0, 390, 40),
        reason: 'a tile is never cropped',
      );
    });

    test('rasterizes at design size × pixel scale, cropped', () async {
      final stand = await library.rasterize(BoardSprite.slotStand, 3);
      addTearDown(stand.dispose);
      expect(stand.fullWidth, 270);
      expect(stand.fullHeight, 102);
      expect(stand.pixelScale, 3);
      expect(stand.tilePaint, isNull);
      expect(stand.offset.dx, stand.offset.dx.roundToDouble());
      expect(stand.offset.dx + stand.image.width, lessThanOrEqualTo(270));
      expect(stand.offset.dy + stand.image.height, lessThanOrEqualTo(102));
      expect(
        stand.image.width * stand.image.height,
        lessThan(270 * 102),
        reason: 'the transparent margin is cropped off',
      );
      expect(stand.byteSize, stand.image.width * stand.image.height * 4);

      final plank = await library.rasterize(BoardSprite.shelfPlank, 3);
      addTearDown(plank.dispose);
      expect((plank.image.width, plank.image.height), (1170, 120));
      expect(plank.byteSize, 561600);
      expect(plank.offset, ui.Offset.zero);
      expect(plank.tilePaint?.shader, isNotNull);
    });

    test('cropping loses nothing: drawn sprites match the whole art', () async {
      const px = 2.0;
      for (final sprite in BoardSprite.values.where((s) => !s.tiles)) {
        final box = sprite.designSize;
        final width = (box.width * px).ceil();
        final height = (box.height * px).ceil();
        final cropped = await library.rasterize(sprite, px);
        final drawn = await capture(width, height, (canvas) {
          canvas.scale(px);
          cropped.draw(canvas, ui.Offset.zero & box);
        });
        // The expectation: the uncropped art, fitted into its box the way
        // CSS draws an SVG background (xMidYMid meet), centred.
        final art = library.artSize(sprite)!;
        final fit =
            math.min(box.width / art.width, box.height / art.height) * px;
        final whole = await rasterizeSvg(
          _svg(sprite),
          scale: fit,
          width: width,
          height: height,
          left: -(box.width * px - art.width * fit) / 2,
          top: -(box.height * px - art.height * fit) / 2,
        );
        final drawnRgba = await rgbaOf(drawn);
        final wholeRgba = await rgbaOf(whole);
        // Same art, same pixel grid: only antialiasing at thick stroke
        // corners may differ (Skia's coverage depends a little on the
        // target's bounds), as in the renderer goldens' gate.
        final diff = ImageDiff(drawnRgba, wholeRgba);
        expect(
          diff.withinFraction,
          greaterThan(0.995),
          reason: '$sprite $diff',
        );
        expect(diff.meanDiff, lessThan(0.5), reason: '$sprite $diff');
        var dropped = 0;
        for (var i = 3; i < wholeRgba.length; i += 4) {
          if (wholeRgba[i] >= 8 && drawnRgba[i] == 0) dropped++;
        }
        expect(dropped, 0, reason: '$sprite: the crop cut visible pixels');
        cropped.dispose();
        drawn.dispose();
        whole.dispose();
      }
    });

    test(
      'pixelScale and cropOrigin place the image as a Lottie slot',
      () async {
        // m2-lottie-design §3: an image layer authored at scale k = 1 and
        // anchor a over the declared box, filled with this raster, is drawn
        // at scale k / pixelScale and anchor (a − cropOrigin) × pixelScale.
        // The result must be the sprite's own draw into the declared box.
        const px = 2.5; // a fractional DPR × furniture scale
        const a = ui.Offset(58, 26); // glow_ring's authored anchor
        const position = ui.Offset(70, 40); // its layer position
        for (final sprite in BoardSprite.values.where((s) => !s.tiles)) {
          final image = await library.rasterize(sprite, px);
          expect(image.cropOrigin, image.offset / image.pixelScale);
          final box = sprite.designSize;
          final width = ((position.dx - a.dx + box.width) * px).ceil();
          final height = ((position.dy - a.dy + box.height) * px).ceil();
          final lottie = await capture(width, height, (canvas) {
            final anchor = (a - image.cropOrigin) * image.pixelScale;
            canvas
              ..scale(px)
              ..translate(position.dx, position.dy)
              ..scale(1 / image.pixelScale)
              ..translate(-anchor.dx, -anchor.dy)
              ..drawImageRect(
                image.image,
                ui.Offset.zero &
                    ui.Size(
                      image.image.width.toDouble(),
                      image.image.height.toDouble(),
                    ),
                ui.Offset.zero &
                    ui.Size(
                      image.image.width.toDouble(),
                      image.image.height.toDouble(),
                    ),
                ui.Paint()..filterQuality = ui.FilterQuality.low,
              );
          });
          final sprited = await capture(width, height, (canvas) {
            canvas.scale(px);
            image.draw(canvas, (position - a) & box);
          });
          final diff = ImageDiff(await rgbaOf(lottie), await rgbaOf(sprited));
          expect(diff.withinFraction, 1, reason: '$sprite $diff');
          image.dispose();
          lottie.dispose();
          sprited.dispose();
        }
      },
    );

    test('reports and skips a sprite that fails to parse', () async {
      final errors = <Object>[];
      final partial = await BoardSpriteLibrary.fromSvgs({
        BoardSprite.slotStand: _svg(BoardSprite.slotStand),
        BoardSprite.glowRing: '<svg this is not xml',
      }, onError: (error, _) => errors.add(error));
      addTearDown(partial.dispose);
      expect(partial.isAvailable(BoardSprite.slotStand), isTrue);
      expect(partial.isAvailable(BoardSprite.glowRing), isFalse);
      expect(partial.failures.keys, contains(BoardSprite.glowRing));
      expect(partial.failures, hasLength(BoardSprite.values.length - 1));
      expect(errors, hasLength(1));
      await expectLater(
        partial.rasterize(BoardSprite.glowRing, 1),
        throwsStateError,
      );
    });
  });

  group('BoardSprites', () {
    late BoardSprites sprites;

    setUp(() => sprites = BoardSprites(library));
    tearDown(() => sprites.dispose());

    BoardGeometry main([BoardViewport viewport = BoardViewport.reference]) =>
        BoardLayout.compute(mainBoard, viewport);

    test('prepare rasterizes what the board always shows', () async {
      expect(sprites.isPrepared, isFalse);
      expect(sprites.image(BoardSprite.slotStand, 1), isNull);
      var notified = 0;
      sprites.addListener(() => notified++);
      await sprites.prepare(main(), devicePixelRatio: 3);
      expect(sprites.isPrepared, isTrue);
      expect(sprites.devicePixelRatio, 3);
      expect(notified, greaterThan(0));
      const eager = {
        BoardSprite.shelfPlank,
        BoardSprite.slotStand,
        BoardSprite.towerBase,
        BoardSprite.glowRing,
        BoardSprite.hintArrow,
        BoardSprite.glassCase0, // MAIN has a locked slot
      };
      for (final sprite in BoardSprite.values) {
        expect(
          sprites.imagesOf(sprite),
          hasLength(eager.contains(sprite) ? 1 : 0),
          reason: sprite.name,
        );
      }
      final geometry = main();
      final stand = sprites.standFor(geometry.slot('r0c0'))!;
      expect(stand.sprite, BoardSprite.slotStand);
      expect(stand.pixelScale, 3);
      expect(
        sprites.standFor(geometry.slot('r1c0'))!.sprite,
        BoardSprite.towerBase,
      );
      expect(
        sprites.standFor(geometry.slot('r1c3'))!.sprite,
        BoardSprite.slotStand,
        reason: 'the glass case stands on a plain stand (NestyBoard:163)',
      );
    });

    test('a tall case is prepared instead of the normal one (m7-3)', () async {
      final tall = BoardLayout.compute(
        board(['oooo', 'oloo', 'oooo'], maxSize: 5, lockedSize: 5),
        BoardViewport.reference,
      );
      expect(tall.slot('r1c1').usesTallCase, isTrue);
      await sprites.prepare(tall, devicePixelRatio: 3);
      expect(sprites.imagesOf(BoardSprite.glassCaseTall0), hasLength(1));
      expect(sprites.imagesOf(BoardSprite.glassCase0), isEmpty);
      // A sealed size-4 doll keeps the normal case, so the normal frame is
      // the one prepared.
      final normal = BoardLayout.compute(
        board(['oooo', 'oloo', 'oooo'], maxSize: 5, lockedSize: 4),
        BoardViewport.reference,
      );
      final other = BoardSprites(library);
      addTearDown(other.dispose);
      await other.prepare(normal, devicePixelRatio: 3);
      expect(other.imagesOf(BoardSprite.glassCase0), hasLength(1));
      expect(other.imagesOf(BoardSprite.glassCaseTall0), isEmpty);
    });

    test('glass and ice frames are lazy: a miss starts them', () async {
      await sprites.prepare(main(), devicePixelRatio: 3);
      final ice = main().slot('r2c1');
      final landed = Completer<void>();
      sprites.addListener(() {
        if (!landed.isCompleted &&
            sprites.imagesOf(BoardSprite.ice1).isNotEmpty) {
          landed.complete();
        }
      });
      expect(sprites.forSlot(BoardSprite.ice1, ice), isNull);
      // A second miss before it lands starts nothing new.
      expect(sprites.forSlot(BoardSprite.ice1, ice), isNull);
      await landed.future.timeout(const Duration(seconds: 5));
      expect(sprites.imagesOf(BoardSprite.ice1), hasLength(1));
      expect(sprites.forSlot(BoardSprite.ice1, ice)!.pixelScale, 3);
    });

    test('prepare(also:) and ensure() rasterize frames up front', () async {
      await sprites.prepare(
        main(),
        devicePixelRatio: 3,
        also: {BoardSprite.ice0, BoardSprite.dollSilhouette},
      );
      expect(sprites.imagesOf(BoardSprite.ice0), hasLength(1));
      final silhouette = sprites.image(BoardSprite.dollSilhouette, 1)!;
      expect(silhouette.fullWidth, 36, reason: 'HUD icon 12 dp × DPR 3');
      await sprites.ensure(BoardSprite.glassCase1, 1);
      expect(sprites.imagesOf(BoardSprite.glassCase1), hasLength(1));
      expect(
        () => BoardSprites(library).ensure(BoardSprite.ice0, 1),
        throwsStateError,
        reason: 'no DPR before prepare',
      );
    });

    test('an extra slot re-pitch adds scales; a re-layout evicts', () async {
      final before = BoardLayout.compute(fullBoard, BoardViewport.reference);
      await sprites.prepare(before, devicePixelRatio: 3);
      expect(sprites.imagesOf(BoardSprite.slotStand), hasLength(1));

      final crowded = BoardLayout.compute(
        fullBoard.withExtraSlot('x0').withExtraSlot('x1'),
        BoardViewport.reference,
      );
      final bottom = crowded.slot('x1');
      expect(bottom.pieceScale, lessThan(1), reason: '5 slots shrink stands');
      await sprites.prepare(crowded, devicePixelRatio: 3);
      expect(sprites.imagesOf(BoardSprite.slotStand), hasLength(2));
      expect(sprites.standFor(bottom)!.sprite, BoardSprite.extraSlot);
      expect(
        sprites.standFor(bottom)!.pixelScale,
        closeTo(bottom.furnitureScale * 3, 1e-3),
      );
      expect(
        sprites.standFor(crowded.slot('r2c0'))!.fullWidth,
        closeTo(bottom.standRect.width * 3, 0.01),
      );

      // Back to the original layout: the crowded scale is released.
      await sprites.prepare(before, devicePixelRatio: 3);
      expect(sprites.imagesOf(BoardSprite.slotStand), hasLength(1));
      expect(sprites.imagesOf(BoardSprite.extraSlot), isEmpty);
    });

    test(
      'a miss returns the nearest scale while the exact one loads',
      () async {
        await sprites.prepare(main(), devicePixelRatio: 3);
        final nearest = sprites.image(BoardSprite.slotStand, 0.9);
        expect(nearest, isNotNull);
        expect(nearest!.pixelScale, 3, reason: 'the scale-1 stand, resized');
        final exact = await _landed(sprites, BoardSprite.slotStand, 0.9);
        expect(exact.fullWidth, closeTo(90 * 0.9 * 3, 1e-9));
      },
    );

    test(
      'an animated scale near a held one starts no raster per frame',
      () async {
        // Review RENDER-6: a re-pitch or pulse animation passing its
        // changing scale must not rasterize (and keep) one image per frame.
        await sprites.prepare(main(), devicePixelRatio: 3);
        for (var scale = 0.91; scale <= 1.09; scale += 0.01) {
          expect(sprites.image(BoardSprite.slotStand, scale), isNotNull);
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
        expect(sprites.imagesOf(BoardSprite.slotStand), hasLength(1));
        expect(BoardSprites.missTolerance, 0.1);
      },
    );

    test('release drops a sprite; dispose ends it', () async {
      await sprites.prepare(main(), devicePixelRatio: 3);
      var notified = 0;
      sprites.addListener(() => notified++);
      sprites.release({BoardSprite.glassCase0});
      expect(sprites.imagesOf(BoardSprite.glassCase0), isEmpty);
      expect(notified, 1);

      final other = BoardSprites(library);
      await other.prepare(main(), devicePixelRatio: 2);
      final image = other.image(BoardSprite.slotStand, 1)!.image;
      other.dispose();
      expect(image.debugDisposed, isTrue);
      expect(other.image(BoardSprite.slotStand, 1), isNull);
      expect(
        () => other.prepare(main(), devicePixelRatio: 2),
        throwsStateError,
      );
    });

    test('a missing sprite is skipped, never retried per frame', () async {
      final errors = <Object>[];
      final partial = await BoardSpriteLibrary.fromSvgs({
        BoardSprite.slotStand: _svg(BoardSprite.slotStand),
      }, onError: (error, _) => errors.add(error));
      final board = BoardSprites(partial);
      addTearDown(() {
        board.dispose();
        partial.dispose();
      });
      await board.prepare(main(), devicePixelRatio: 2);
      expect(board.imagesOf(BoardSprite.slotStand), hasLength(1));
      expect(board.image(BoardSprite.glowRing, 1), isNull);
      expect(board.image(BoardSprite.glowRing, 1), isNull);
      expect(board.imageCount, 1);
      expect(errors, isEmpty, reason: 'absent, not broken');
    });

    test('the plank tiles seamlessly from x 0', () async {
      // 1000 dp wide: s = 1 (height-bound), planks span the full width.
      final geometry = BoardLayout.compute(
        mainBoard,
        const BoardViewport(
          size: ui.Size(1000, 844),
          padding: EdgeInsets.only(top: 59, bottom: 34),
        ),
      );
      expect(geometry.scale, 1);
      await sprites.prepare(geometry, devicePixelRatio: 2);
      final shelf = geometry.shelves.first;
      final image = await capture(2000, 844 * 2, (canvas) {
        canvas.scale(2);
        sprites.drawPlanks(canvas, geometry);
      });
      final rgba = await rgbaOf(image);
      final tile = sprites.imagesOf(BoardSprite.shelfPlank).single.image;
      expect((tile.width, tile.height), (780, 80));
      final tileRgba = await rgbaOf(tile);
      var mismatched = 0;
      for (final dy in [2, 20, 40, 60, 78]) {
        final y = (shelf.plankTop * 2).round() + dy;
        for (var x = 0; x < 2000; x++) {
          final at = (y * 2000 + x) * 4;
          final tileAt = (dy * 780 + x % 780) * 4;
          for (var c = 0; c < 4; c++) {
            if ((rgba[at + c] - tileRgba[tileAt + c]).abs() > 2) {
              mismatched++;
              break;
            }
          }
        }
      }
      expect(mismatched, 0);
      // Nothing is drawn between planks.
      final gap = ((shelf.plankRect.bottom + 30) * 2).round();
      expect(rgba[(gap * 2000 + 10) * 4 + 3], 0);
      image.dispose();
    });

    test('draws a flat wood plank until the tile exists', () async {
      final geometry = main();
      final image = await capture(390, 844, (canvas) {
        sprites.drawPlanks(canvas, geometry);
      });
      final rgba = await rgbaOf(image);
      final at = (332 * 390 + 4) * 4;
      expect(rgba.sublist(at, at + 4), [0xDC, 0xA1, 0x5D, 0xFF]);
      image.dispose();
    });

    // "Memory math": the render design's budget is board sprites 1–2 MB,
    // ≤ 5 MB with glass/ice, at DPR 3 on the reference phone.
    test('fits the render design memory budget', () async {
      final geometry = main();
      await sprites.prepare(geometry, devicePixelRatio: 3);
      final eager = sprites.byteSize;
      var sum = 0;
      for (final sprite in BoardSprite.values) {
        for (final image in sprites.imagesOf(sprite)) {
          sum += image.image.width * image.image.height * 4;
        }
      }
      expect(eager, sum);
      // The plank alone is 1170 × 120 × 4.
      expect(sprites.imagesOf(BoardSprite.shelfPlank).single.byteSize, 561600);
      expect(eager, inInclusiveRange(1 * _mib, 2 * _mib));

      // Every lazy frame at once (a level never shows them all together).
      // A case is normal or tall (m7-3 `glassCaseTall`, by its sealed doll's
      // size), so the budget counts the normal frames; the tall set is
      // checked on its own below.
      const tall = {
        BoardSprite.glassCaseTall0,
        BoardSprite.glassCaseTall1,
        BoardSprite.glassCaseTall2,
      };
      for (final sprite in BoardSprite.values) {
        if (tall.contains(sprite)) continue;
        await sprites.ensure(sprite, 1);
      }
      final everything = sprites.byteSize;
      expect(everything, lessThanOrEqualTo(5 * _mib));
      for (final sprite in tall) {
        await sprites.ensure(sprite, 1);
      }
      expect(sprites.byteSize - everything, lessThanOrEqualTo(2 * _mib));

      // The same eager set on the five acceptance screens, at their
      // typical DPR.
      const dprs = {
        '360×640': 3.0,
        '375×667': 2.0,
        '390×844': 3.0,
        '430×932': 3.0,
        '768×1024': 2.0,
      };
      final perScreen = <String>[];
      for (final MapEntry(key: name, value: viewport) in screens.entries) {
        final board = BoardSprites(library);
        await board.prepare(
          BoardLayout.compute(mainBoard, viewport),
          devicePixelRatio: dprs[name]!,
        );
        perScreen.add('$name@${dprs[name]} ${_mb(board.byteSize)}');
        expect(board.byteSize, lessThanOrEqualTo(2 * _mib), reason: name);
        board.dispose();
      }
      // ignore: avoid_print
      print(
        'board sprites (MAIN, 390×844@3): eager ${_mb(eager)}, '
        'with every glass/ice frame ${_mb(everything)}; '
        '${perScreen.join(', ')}',
      );
    });
  });
}
