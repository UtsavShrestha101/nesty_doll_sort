import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/asset_fx_library.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/fx/rival_portrait_image_source.dart';

import '../../features/fx/support/fx_test_art.dart';
import '../../features/support/screen_harness.dart';

/// m7-4 C.6 (tokens.json `motion.rivalReact`): the rival's portrait on
/// `ui_rival_react`, in the strip (38 → a 47.5 dp canvas) and on a result
/// card (56 → 70).
void main() {
  Widget host({
    int familyCount = 0,
    RivalReaction? reaction,
    double size = 56,
    UiArtLibrary? art,
  }) => Center(
    child: RivalReact(
      number: 2,
      size: size,
      familyCount: familyCount,
      reaction: reaction,
      library: FakeFxLibrary(),
      uiArt: art ?? FakeUiArtLibrary(),
    ),
  );

  LottieFxController controllerOf(WidgetTester tester) =>
      tester.widget<LottieFxView>(find.byType(LottieFxView)).controller!;

  testWidgets('takes the layout of a portrait of its size; the canvas is '
      '120/96 of it, the portrait centre (60, 64) on the box centre', (
    tester,
  ) async {
    await pumpScreen(tester, host());
    expect(tester.getSize(find.byType(RivalReact)), const Size(56, 56));
    final canvas = tester.getRect(find.byType(LottieFxView));
    expect(canvas.size, const Size(70, 70));
    final box = tester.getRect(find.byType(RivalReact));
    // (60, 64) of the 120 canvas at 56/96.
    expect(canvas.left + 35, closeTo(box.center.dx, 0.01));
    expect(canvas.top + 64 * 56 / 96, closeTo(box.center.dy, 0.01));
    await pumpScreen(tester, host(size: 38));
    expect(tester.getSize(find.byType(LottieFxView)), const Size(47.5, 47.5));
  });

  testWidgets('without the file the static portrait stands in, under its own '
      'ring', (tester) async {
    await pumpScreen(tester, host());
    final portrait = tester.widget<RivalPortrait>(find.byType(RivalPortrait));
    expect(portrait.number, 2);
    expect(portrait.ring, isFalse, reason: 'RivalReact draws the ring');
    expect(portrait.size, 56);
  });

  testWidgets('idles in a loop; a result card\'s reaction plays first, then '
      'idle', (tester) async {
    // No composition here, so no ticker: the controller is advanced by hand.
    await pumpScreen(tester, host());
    final idle = controllerOf(tester);
    expect(idle.isPlaying, isTrue);
    idle.advance(500);
    expect(idle.player.frame, inInclusiveRange(0, 180));
    idle.advance(6000);
    expect(idle.isPlaying, isTrue, reason: 'idle loops');

    await pumpScreen(tester, const SizedBox());
    await pumpScreen(tester, host(reaction: RivalReaction.win));
    final win = controllerOf(tester);
    win.advance(100);
    expect(win.player.frame, inInclusiveRange(220, 300));
    expect(RivalReaction.win.marker, 'win');
    expect(RivalReaction.lose.marker, 'lose');
  });

  testWidgets('a rising family count plays `family`; a drop does not', (
    tester,
  ) async {
    await pumpScreen(tester, host(familyCount: 1));
    await pumpScreen(tester, host(familyCount: 2));
    final controller = controllerOf(tester);
    controller.advance(100);
    expect(controller.player.frame, inInclusiveRange(180, 220));
    controller.advance(2000);
    expect(controller.player.frame, inInclusiveRange(0, 180), reason: 'idle');
    await pumpScreen(tester, host(familyCount: 0));
    controller.advance(100);
    expect(controller.player.frame, inInclusiveRange(0, 180));
  });

  testWidgets('reduced motion: frame 0, still, even for a reaction', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      host(reaction: RivalReaction.lose),
      reduceMotion: true,
    );
    final controller = controllerOf(tester);
    expect(controller.isPlaying, isFalse);
    expect(controller.player.frame, 0);
    await pumpScreen(
      tester,
      host(familyCount: 1, reaction: RivalReaction.lose),
      reduceMotion: true,
    );
    await pumpScreen(
      tester,
      host(familyCount: 2, reaction: RivalReaction.lose),
      reduceMotion: true,
    );
    expect(controller.isPlaying, isFalse);
    expect(controller.player.frame, 0);
  });

  testWidgets('follows an OS reduce-motion toggle mid-race', (tester) async {
    await pumpScreen(tester, host());
    final controller = controllerOf(tester);
    expect(controller.isPlaying, isTrue);
    await pumpScreen(tester, host(), reduceMotion: true);
    expect(controller.isPlaying, isFalse);
    expect(controller.player.frame, 0);
    await pumpScreen(tester, host());
    expect(controller.isPlaying, isTrue, reason: 'the idle loop resumes');
  });

  testWidgets('prepares the rival\'s portrait art at 96 dp', (tester) async {
    final art = FakeUiArtLibrary();
    await pumpScreen(tester, host(art: art));
    await tester.pump();
    expect(art.prepared, [UiArt.rival2]);
  });

  group('RivalPortraitImageSource', () {
    test('fills only the rival_portrait slot, at 3x of 96 dp', () async {
      final art = FakeUiArtLibrary();
      final image = insetBox(288, 288, const Color(0xFF123456));
      art.images[UiArt.rival3] = image;
      final source = RivalPortraitImageSource(art, 3);
      expect(
        source.rasterFor(FxImageSlot.rivalPortrait, FxImageRequest()),
        isNull,
        reason: 'not prepared yet',
      );
      await source.prepare(devicePixelRatio: 3);
      expect(art.prepared, [UiArt.rival3]);
      final raster = source.rasterFor(
        FxImageSlot.rivalPortrait,
        FxImageRequest(),
      )!;
      expect(raster.image, same(image));
      expect(raster.scale, 3);
      expect(source.rasterFor(FxImageSlot.figurine, FxImageRequest()), isNull);
      expect(source.rasterFor(FxImageSlot.chestOpen, FxImageRequest()), isNull);
      image.dispose();
    });
  });

  group('on the real file', () {
    late AssetFxLibrary library;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      library = AssetFxLibrary(yieldToFrames: () async {});
      await library.load();
    });

    test('the portrait slot draws the rival raster at its place, and the '
        '`family` segment draws more than `idle`', () async {
      final art = FakeUiArtLibrary();
      final raster = insetBox(288, 288, const Color(0xFFFF00FF));
      art.images[UiArt.rival1] = raster;
      final source = RivalPortraitImageSource(art, 1);
      await source.prepare(devicePixelRatio: 3);
      final clip = FxDrawable.of(library, FxId.uiRivalReact)!
        ..images.source = source;
      final idle = await snapshotDrawable(clip, 10, pixelRatio: 2);
      // The magenta portrait is 96 dp centred on (60, 64).
      final bounds = idle.boundsWhere((x, y) {
        final i = (y * idle.width + x) * 4;
        return idle.bytes[i + 3] > 250 &&
            idle.bytes[i] > 240 &&
            idle.bytes[i + 1] < 20 &&
            idle.bytes[i + 2] > 240;
      })!;
      expect(bounds.width / 2, closeTo(96, 4));
      expect(bounds.center.dx / 2, closeTo(60, 2));
      expect(bounds.center.dy / 2, closeTo(64, 4));
      // `family` pops a ring and sparkles around it: pixels idle lacks.
      final family = await snapshotDrawable(clip, 195, pixelRatio: 2);
      expect(family.differingPixels(idle), greaterThan(200));
      raster.dispose();
    });
  });
}
