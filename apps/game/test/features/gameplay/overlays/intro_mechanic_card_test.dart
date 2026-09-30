import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/intro_mechanic.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/gameplay/overlays/intro_mechanic_card.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_board.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_render/nesty_render.dart';

import '../../../core/ui/support/ui_harness.dart';
import '../../support/lottie_library.dart';
import '../../support/screen_harness.dart';
import '../bloc/support/bloc_fixtures.dart' show defaultLevel;

Widget _card({
  IntroMechanic mechanic = IntroMechanic.towers,
  VoidCallback? onGotIt,
  LevelSkin? skin,
  List<DollColor> levelColors = const [],
}) => IntroMechanicCard(
  mechanic: mechanic,
  onGotIt: onGotIt ?? () {},
  skin: skin,
  levelColors: levelColors,
  library: FakeFxLibrary(),
);

/// A solid rectangle filling a [w]×[h] SVG box.
String _solid(double w, double h) =>
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $w $h" '
    'width="$w" height="$h"><rect width="$w" height="$h" '
    'fill="#8B5A2B"/></svg>';

final class _NoImages implements FxImageSource {
  const _NoImages();

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) => null;
}

/// A level's art with real board sprites (solid SVG boxes) and no doll
/// rasters.
final class _SpriteSkin implements LevelSkin {
  _SpriteSkin(this.sprites);

  @override
  final BoardSprites sprites;

  @override
  final FxImageSource images = const _NoImages();

  @override
  final DollRenderer restRenderer = PlaceholderDollPainter();

  @override
  void dispose() {
    sprites.dispose();
    restRenderer.dispose();
  }
}

/// Sprites prepared for [defaultLevel]'s layout, from solid SVG boxes.
Future<_SpriteSkin> _spriteSkin(WidgetTester tester) async {
  final skin = await tester.runAsync(() async {
    final library = await BoardSpriteLibrary.fromSvgs({
      for (final sprite in BoardSprite.values)
        sprite: _solid(sprite.designSize.width, sprite.designSize.height),
    });
    addTearDown(library.dispose);
    final geometry = FakeGameplayBoard(
      GameplayBoardCallbacks(
        onIntent: (_) {},
        onLayout: (_) {},
        onFamilyLanded: (_, _, _) {},
        onWon: () {},
        onOutOfMoves: () {},
      ),
      fx: FakeFxLibrary(),
      feedback: RecordingCues(),
    ).layoutFor(GameState.initial(defaultLevel))!;
    final sprites = BoardSprites(library);
    await sprites.prepare(geometry, devicePixelRatio: 1);
    return _SpriteSkin(sprites);
  });
  addTearDown(skin!.dispose);
  return skin;
}

List<IntroSpritePiece> _sprites(IntroMechanic mechanic) => [
  for (final piece in IntroIllustration.piecesOf(mechanic))
    if (piece case final IntroSpritePiece sprite) sprite,
];

List<IntroDollPiece> _dolls(IntroMechanic mechanic) => [
  for (final piece in IntroIllustration.piecesOf(mechanic))
    if (piece case final IntroDollPiece doll) doll,
];

void main() {
  setUpAll(loadBundledFonts);

  testWidgets('frame 4.1, Towers: the NEW chip, title and text', (
    tester,
  ) async {
    await pumpScreen(tester, _card());
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('NEW'), findsOneWidget);
    expect(find.text('Towers!'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
  });

  testWidgets('frame 4.2, Glass Cases', (tester) async {
    await pumpScreen(tester, _card(mechanic: IntroMechanic.glass));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Glass Cases'), findsOneWidget);
  });

  testWidgets('frame 4.3, Ice', (tester) async {
    await pumpScreen(tester, _card(mechanic: IntroMechanic.ice));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ice'), findsOneWidget);
  });

  testWidgets('Got it calls back', (tester) async {
    var gotIt = 0;
    await pumpScreen(tester, _card(onGotIt: () => gotIt++));
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Got it'));
    await tester.pump();
    expect(gotIt, 1);
  });

  // Review FIDELITY-6: NestyOverlay INTRO, piece by piece, in the 302×230
  // slot's px (a doll is `doll(c, cx, base, h)`, a board piece `img(src,
  // x, y, w, h)`).
  group('the illustration follows NestyOverlay INTRO', () {
    test('towers: two tower bases, the buried silhouettes, sky and leaf, '
        '"+2" and "+1"', () {
      expect(_sprites(IntroMechanic.towers), [
        const IntroSpritePiece(
          BoardSprite.towerBase,
          Rect.fromLTWH(26, 172, 90, 39),
        ),
        const IntroSpritePiece(
          BoardSprite.dollSilhouette,
          Rect.fromLTWH(31, 64, 80, 120),
        ),
        const IntroSpritePiece(
          BoardSprite.dollSilhouette,
          Rect.fromLTWH(37, 80, 68, 102),
        ),
        const IntroSpritePiece(
          BoardSprite.towerBase,
          Rect.fromLTWH(196, 172, 90, 39),
        ),
        const IntroSpritePiece(
          BoardSprite.dollSilhouette,
          Rect.fromLTWH(201, 64, 80, 120),
        ),
      ]);
      expect(_dolls(IntroMechanic.towers), const [
        IntroDollPiece(DollColor.blue, centerX: 71, baseY: 185, height: 84),
        IntroDollPiece(DollColor.green, centerX: 241, baseY: 185, height: 102),
      ]);
      final pieces = IntroIllustration.piecesOf(IntroMechanic.towers);
      expect(pieces.whereType<IntroArrowPiece>(), [const IntroArrowPiece(133)]);
      expect(pieces.whereType<IntroChipPiece>(), const [
        IntroChipPiece.buried(2, Offset(90, 160)),
        IntroChipPiece.buried(1, Offset(260, 160)),
      ]);
      // A silhouette is drawn behind its doll (the frame's order).
      expect(
        pieces.indexOf(_sprites(IntroMechanic.towers)[2]),
        lessThan(pieces.indexOf(_dolls(IntroMechanic.towers)[0])),
      );
    });

    test('glass: a leaf doll in glass-case-0, then free in glass-case-2, '
        'the star chip', () {
      final pieces = IntroIllustration.piecesOf(IntroMechanic.glass);
      expect(pieces, const [
        IntroDollPiece(DollColor.green, centerX: 72, baseY: 158, height: 86),
        IntroSpritePiece(
          BoardSprite.glassCase0,
          Rect.fromLTWH(26, 36, 92, 153),
        ),
        IntroDollPiece(DollColor.green, centerX: 244, baseY: 172, height: 86),
        IntroSpritePiece(
          BoardSprite.glassCase2,
          Rect.fromLTWH(198, 36, 92, 153),
        ),
        IntroArrowPiece(133),
        IntroChipPiece.unlock(Offset(128, 40)),
      ]);
    });

    test('ice: three stands, ice-0, ice-2 and the shatter, "2" and "1"', () {
      expect(_sprites(IntroMechanic.ice), const [
        IntroSpritePiece(BoardSprite.slotStand, Rect.fromLTWH(20, 170, 70, 26)),
        IntroSpritePiece(BoardSprite.ice0, Rect.fromLTWH(17, 60, 76, 127)),
        IntroSpritePiece(
          BoardSprite.slotStand,
          Rect.fromLTWH(124, 170, 70, 26),
        ),
        IntroSpritePiece(BoardSprite.ice2, Rect.fromLTWH(121, 60, 76, 127)),
        IntroSpritePiece(
          BoardSprite.slotStand,
          Rect.fromLTWH(228, 170, 70, 26),
        ),
        IntroSpritePiece(
          BoardSprite.iceShatter,
          Rect.fromLTWH(225, 60, 76, 127),
        ),
      ]);
      expect(_dolls(IntroMechanic.ice), const [
        IntroDollPiece(DollColor.blue, centerX: 55, baseY: 179, height: 76),
        IntroDollPiece(DollColor.blue, centerX: 159, baseY: 179, height: 76),
        IntroDollPiece(DollColor.blue, centerX: 263, baseY: 179, height: 76),
      ]);
      final pieces = IntroIllustration.piecesOf(IntroMechanic.ice);
      expect(pieces.whereType<IntroArrowPiece>(), isEmpty);
      expect(pieces.whereType<IntroChipPiece>(), const [
        IntroChipPiece.ice(2, Offset(76, 56)),
        IntroChipPiece.ice(1, Offset(180, 56)),
      ]);
    });
  });

  testWidgets("with the level's art: the board sprites draw from its "
      'BoardSprites, and the dolls are its dolls in its colours', (
    tester,
  ) async {
    final skin = await _spriteSkin(tester);
    expect(skin.sprites.imagesOf(BoardSprite.glassCase2), isEmpty);
    await pumpScreen(
      tester,
      _card(
        mechanic: IntroMechanic.glass,
        skin: skin,
        levelColors: const [DollColor.red],
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    // The pieces the frame uses are rasterized on demand, then drawn.
    await tester.runAsync(() => Future<void>.delayed(Durations.medium2));
    await tester.pump();
    for (final sprite in [BoardSprite.glassCase0, BoardSprite.glassCase2]) {
      expect(skin.sprites.imagesOf(sprite), isNotEmpty, reason: '$sprite');
    }
    final dolls = tester.widgetList<LottieDoll>(find.byType(LottieDoll));
    expect(dolls, hasLength(2));
    for (final doll in dolls) {
      expect(doll.images, same(skin.images));
      expect(doll.renderer, same(skin.restRenderer));
      // Leaf isn't on this level: a skin draws only its own colours.
      expect(doll.color, DollColor.red);
    }
  });

  testWidgets('a level that has the frame colour keeps it', (tester) async {
    final skin = await _spriteSkin(tester);
    await pumpScreen(
      tester,
      _card(
        skin: skin,
        levelColors: const [DollColor.red, DollColor.blue, DollColor.yellow],
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    final colors = [
      for (final doll in tester.widgetList<LottieDoll>(find.byType(LottieDoll)))
        doll.color,
    ];
    // Sky stays sky; leaf (absent) takes the first colour not in use.
    expect(colors, [DollColor.blue, DollColor.red]);
  });

  testWidgets("without the level's art: placeholder dolls in the frame's "
      'colours (rule 3)', (tester) async {
    await pumpScreen(tester, _card(mechanic: IntroMechanic.ice));
    await tester.pump(const Duration(milliseconds: 300));
    final dolls = tester.widgetList<LottieDoll>(find.byType(LottieDoll));
    expect(dolls, hasLength(3));
    for (final doll in dolls) {
      expect(doll.images, isNull);
      expect(doll.color, DollColor.blue);
    }
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('the card sits at NestyOverlay isIntro top 170', (tester) async {
    await pumpScreen(tester, _card());
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getTopLeft(find.byType(IntroCard)).dy, closeTo(170, 0.5));
    expect(tester.getTopLeft(find.byType(IntroCard)).dx, closeTo(24, 0.5));
  });

  for (final mechanic in IntroMechanic.values) {
    for (final size in screenSizes) {
      for (final scale in textScales) {
        testWidgets(
          '${mechanic.id} fits ${size.width.toInt()} wide at $scale× text',
          (tester) async {
            await pumpScreen(
              tester,
              _card(mechanic: mechanic),
              size: size,
              textScale: scale,
            );
            await tester.pump(const Duration(milliseconds: 300));
            expectNoLayoutErrors(tester);
          },
        );
      }
    }
  }

  group('the loops (frames 4.1–4.3; `ui_intro_towers`, `_glass`, `_ice`)', () {
    Widget loopCard(
      IntroMechanic mechanic,
      FakeFxLibrary library, {
      LevelSkin? skin,
    }) => IntroMechanicCard(
      mechanic: mechanic,
      onGotIt: () {},
      skin: skin,
      levelColors: const [
        DollColor.red,
        DollColor.blue,
        DollColor.green,
        DollColor.yellow,
      ],
      library: library,
    );

    for (final (mechanic, id) in [
      (IntroMechanic.towers, FxId.uiIntroTowers),
      (IntroMechanic.glass, FxId.uiIntroGlass),
      (IntroMechanic.ice, FxId.uiIntroIce),
    ]) {
      testWidgets('${mechanic.name}: with the level\'s skin the picture is '
          '${id.fileName}, looping, its roles in the level\'s colours', (
        tester,
      ) async {
        final library = (await tester.runAsync(widgetLottieLibrary))!;
        final skin = await _spriteSkin(tester);
        await pumpScreen(tester, loopCard(mechanic, library, skin: skin));
        await tester.pump(const Duration(milliseconds: 300));
        final view = tester.widget<LottieFxView>(
          find.byWidgetPredicate((w) => w is LottieFxView && w.id == id),
        );
        final controller = view.controller!;
        expect(controller.isPlaying, isTrue);
        expect(view.images, same(skin.images));
        // No box for the still pieces once the loop plays.
        final request = controller.images.request;
        switch (mechanic) {
          case IntroMechanic.towers:
            expect(request.mover, isNotNull);
            expect(request.revealed, isNotNull);
          case IntroMechanic.glass:
            expect(request.family, isNotNull);
            expect(request.freed, isNotNull);
            expect(
              request.unlockColor,
              request.family,
              reason: 'the padlock carries the family\'s symbol',
            );
          case IntroMechanic.ice:
            expect(request.family, isNotNull);
            expect(request.family2, isNotNull);
            expect(request.freed, isNotNull);
        }
        // The slot is the design's 302 × 230.
        expect(tester.getSize(find.byWidget(view)), IntroCard.illustrationSize);
      });

      testWidgets('${mechanic.name}: reduce motion rests on frame 0, still', (
        tester,
      ) async {
        final library = (await tester.runAsync(widgetLottieLibrary))!;
        final skin = await _spriteSkin(tester);
        await pumpScreen(
          tester,
          loopCard(mechanic, library, skin: skin),
          reduceMotion: true,
        );
        await tester.pump(const Duration(milliseconds: 300));
        final view = tester.widget<LottieFxView>(
          find.byWidgetPredicate((w) => w is LottieFxView && w.id == id),
        );
        expect(view.controller!.isPlaying, isFalse);
        expect(view.controller!.player.frame, 0);
      });
    }

    testWidgets('without a skin the still picture stays (rule 3): no loop', (
      tester,
    ) async {
      final library = (await tester.runAsync(widgetLottieLibrary))!;
      await pumpScreen(tester, loopCard(IntroMechanic.towers, library));
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.byWidgetPredicate(
          (w) => w is LottieFxView && w.id == FxId.uiIntroTowers,
        ),
        findsNothing,
      );
    });

    testWidgets('the picture is decorative: no semantics of its own', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final library = (await tester.runAsync(widgetLottieLibrary))!;
      final skin = await _spriteSkin(tester);
      await pumpScreen(
        tester,
        loopCard(IntroMechanic.ice, library, skin: skin),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.bySemanticsLabel('Ice'), findsOneWidget);
      handle.dispose();
    });
  });
}
