// The board host (docs/plans/m2-lottie-design.md §2 "Board", §5, §8, §14).
import 'dart:ui';

import 'package:flame/components.dart' hide Snapshot;
import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_layout.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/lottie_fx_component.dart';
import 'package:nesty_render/nesty_render.dart' show BoardFit;

import 'support/fx_test_art.dart';

const _red = Color(0xFFFF0000);
final _doll = insetBox(512, 768, _red);

FixedArt _dollArt() => FixedArt({
  FxImageSlot.dollLid: FxRaster(_doll, scale: 1),
  FxImageSlot.dollBody: FxRaster(_doll, scale: 1),
});

Future<LottieFxComponent> _component(
  FxId id, {
  FxImageSource? source,
  bool cacheRest = false,
}) async {
  final clip = await shippedDrawable(id, source: source ?? _dollArt());
  clip.images.request.doll = DollColor.red;
  return LottieFxComponent(clip, cacheRest: cacheRest);
}

Future<Snapshot> _render(PositionComponent component, {double w = 390}) =>
    snapshot(w, 844, component.renderTree);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('sized to its canvas and anchored on the file\'s anchor', () async {
    final pick = await _component(FxId.dollPick);
    expect(pick.size, Vector2(160, 260));
    expect(pick.anchor, const Anchor(80 / 160, 230 / 260));
    final move = await _component(FxId.dollMove);
    expect(move.anchor, Anchor.topLeft);
  });

  test('seek shows an authored frame; rest a rest look', () async {
    final glass = await _component(FxId.fxGlassUnlock)
      ..seek(3);
    expect(glass.active, isTrue);
    expect(glass.drawable.player.state, FxPlayState.seeking);
    glass.rest(0);
    expect(glass.drawable.player.isResting, isTrue);
  });

  test('inactive, it draws nothing', () async {
    final pick = await _component(FxId.dollPick)
      ..placeAt(195, 500, 1);
    expect((await _render(pick)).alphaBounds(), isNull);
    pick.rest(0);
    expect((await _render(pick)).alphaBounds(), isNotNull);
    pick.deactivate();
    expect((await _render(pick)).alphaBounds(), isNull);
  });

  test(
    'placeAt puts the doll base on the game point at the board scale',
    () async {
      const s = 0.8, h = 96.0;
      final pick = await _component(FxId.dollPick);
      FxLayout.applyDollHeights(
        pick.drawable.params,
        pick.drawable.spec,
        compositionScale: s,
        doll: h,
      );
      pick
        ..placeAt(150, 520, s)
        ..rest(0);
      final box = (await _render(pick)).alphaBounds()!;
      expect(box.center.dx, closeTo(150, 1));
      // The solid art is 768 units tall with its base at 742.
      expect(box.height, closeTo(h, 1.5));
      expect(box.bottom, closeTo(520 + h * 26 / 768, 1.5));
    },
  );

  test('placeBoardSpace lays the reference screen over the board', () async {
    final fit = BoardFit(scale: 1.1, originX: 11, originY: 150);
    final move = await _component(FxId.dollMove)
      ..placeBoardSpace(fit);
    const src = Offset(80, 400);
    move.drawable.params.setTravel(src, const Offset(300, 600));
    move.rest(0);
    final box = (await _render(move, w: 450)).alphaBounds()!;
    expect(box.center.dx, closeTo(fit.x(src.dx), 1.5));
  });

  test('explicitly driven: Flame\'s update does nothing unless '
      'autoAdvance', () async {
    final move = await _component(FxId.dollMove);
    var finished = 0;
    move.onFinished = (_) => finished++;
    move.play(FxPlan.whole(move.drawable.spec));
    move.update(0.1);
    expect(move.drawable.player.frame, 0);
    move.advance(100);
    expect(move.drawable.player.frame, closeTo(6, 1e-9));
    move.autoAdvance = true;
    move.update(0.2);
    expect(finished, 1);
    expect(move.drawable.player.isFinished, isTrue);
    move.update(0.1);
    expect(finished, 1);
  });

  test('mounted in a FlameGame it renders by priority', () async {
    final game = FlameGame()..onGameResize(Vector2(390, 844));
    await game.onLoad();
    // ignore: invalid_use_of_internal_member
    game.mount();
    game.camera.viewfinder.anchor = Anchor.topLeft;
    final under = await _component(FxId.dollPick)
      ..priority = 1
      ..placeAt(195, 500, 1)
      ..rest(0);
    final overClip = await shippedDrawable(
      FxId.dollPick,
      source: FixedArt({
        FxImageSlot.dollLid: FxRaster(
          insetBox(512, 768, const Color(0xFF0000FF)),
          scale: 1,
        ),
        FxImageSlot.dollBody: FxRaster(
          insetBox(512, 768, const Color(0xFF0000FF)),
          scale: 1,
        ),
      }),
    );
    overClip.images.request.doll = DollColor.blue;
    final over = LottieFxComponent(overClip, priority: 2)
      ..placeAt(195, 500, 1)
      ..rest(0);
    await game.world.addAll([over, under]);
    game.update(0);
    await game.ready();
    expect(over.isMounted && under.isMounted, isTrue);
    final snap = await snapshot(390, 844, game.render);
    final (r, _, b, _) = snap.at(195, 440);
    expect((r, b), (0, 255), reason: 'the higher priority draws on top');
  });

  group('cached rest picture (§8)', () {
    Future<LottieFxComponent> ice(FixedArt art) async {
      final component = await _component(
        FxId.fxIce,
        source: art,
        cacheRest: true,
      );
      component.placeAt(90, 200, 1);
      return component;
    }

    FixedArt iceArt() => FixedArt({
      FxImageSlot.dollLid: FxRaster(_doll, scale: 1),
      FxImageSlot.dollBody: FxRaster(_doll, scale: 1),
      for (final slot in [
        FxImageSlot.ice0,
        FxImageSlot.ice1,
        FxImageSlot.ice2,
        FxImageSlot.ice3,
      ])
        slot: FxRaster(
          blobArt(
            96,
            160,
            2,
            primary: const Color(0xFF80D8FF),
            secondary: Color(0xFF0000FF - slot.index),
          ),
          scale: 2,
        ),
    });

    test('recorded once and replayed while nothing changes', () async {
      final art = iceArt();
      final component = await ice(art)
        ..rest(16);
      final first = await _render(component);
      final second = await _render(component);
      expect(component.restRecordings, 1);
      expect(second.differingPixels(first, tolerance: 0), 0);

      // The replay equals a direct draw.
      final direct = LottieFxComponent(component.drawable)..placeAt(90, 200, 1);
      direct.rest(16);
      expect((await _render(direct)).differingPixels(first, tolerance: 0), 0);
    });

    test('re-recorded when the frame, params or a raster change', () async {
      final art = iceArt();
      final component = await ice(art)
        ..rest(0);
      await _render(component);
      expect(component.restRecordings, 1);

      component.rest(32);
      await _render(component);
      expect(component.restRecordings, 2);

      FxLayout.applyDollHeights(
        component.drawable.params,
        component.drawable.spec,
        compositionScale: 1,
        doll: 90,
      );
      await _render(component);
      expect(component.restRecordings, 3);

      // A sprite lands late: the slot now serves a different raster.
      art.rasters[FxImageSlot.ice2] = FxRaster(
        insetBox(192, 320, const Color(0xFF00FFFF)),
        scale: 2,
      );
      await _render(component);
      expect(component.restRecordings, 4);

      component.drawable.images.source = iceArt();
      await _render(component);
      expect(component.restRecordings, 5);

      await _render(component);
      expect(component.restRecordings, 5);
    });

    test('not cached while playing; dropped on deactivate', () async {
      final component = await ice(iceArt());
      component.play(FxPlan.marker(fxSpecOf(FxId.fxIce), 'crack_2')!);
      await _render(component);
      component.advance(50);
      await _render(component);
      expect(component.restRecordings, 0);
      component.rest(32);
      await _render(component);
      expect(component.hasRestPicture, isTrue);
      component.deactivate();
      expect(component.hasRestPicture, isFalse);
      expect(component.drawable.player.state, FxPlayState.idle);
    });
  });

  test('pools: one component per slot of the pool, reset on release', () async {
    final library = FakeFxLibrary()..blank = transparentPixel;
    expect(LottieFxComponent.pool(library, FxId.fxSparkle), isNull);
    library.compositions[FxId.fxSparkle] = await shipped(FxId.fxSparkle);
    final pool = LottieFxComponent.pool(library, FxId.fxSparkle)!;
    expect(pool.capacity, 9);
    final sparkle = pool.acquire()!
      ..placeAt(10, 10, 1.5)
      ..play(FxPlan.whole(fxSpecOf(FxId.fxSparkle)));
    expect(sparkle.active, isTrue);
    expect(sparkle.drawable.images.blank, same(transparentPixel));
    pool.release(sparkle);
    expect(sparkle.active, isFalse);
    expect(sparkle.drawable.player.state, FxPlayState.idle);
    expect(pool.acquire(), same(sparkle));
  });

  test('FxDrawable.of is null for a file that isn\'t loaded', () {
    expect(FxDrawable.of(FakeFxLibrary(), FxId.dollPick), isNull);
  });
}
