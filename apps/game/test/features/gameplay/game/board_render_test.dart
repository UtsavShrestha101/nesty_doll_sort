// What the shelf layer and the rest sprites draw (NestyBoard:161–168, D21;
// docs/plans/m2-lottie-design.md §4, §8, §9.1, §10.7): the stands and
// planks (flat stand-ins without board art), true-size tower silhouettes
// raised per depth, the pip bars, the "+N" tags, and each top doll on its
// base through the level's rest renderer.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/gameplay/bloc/board_effect.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/board_fixtures.dart';
import 'timeline/support/timeline_fixtures.dart' as tl;

/// One `DollRenderer.paint` call, copied.
typedef Painted = ({
  DollColor color,
  double height,
  double baseX,
  double baseY,
  bool silhouette,
  double scale,
});

/// Records every doll it is asked to paint (and paints nothing).
final class RecordingRenderer implements DollRenderer {
  final List<Painted> painted = [];

  @override
  Future<void> prepare({
    required Iterable<double> heights,
    required double devicePixelRatio,
  }) async {}

  @override
  bool isReadyFor(double height) => true;

  @override
  bool canPaint(double height) => true;

  @override
  void paint(Canvas canvas, DollPaintParams p) => painted.add((
    color: p.color,
    height: p.height,
    baseX: p.baseX,
    baseY: p.baseY,
    silhouette: p.silhouette,
    scale: p.scaleX,
  ));

  @override
  void dispose() {}
}

final class RecordingSkin implements LevelSkin {
  final RecordingRenderer renderer = RecordingRenderer();

  @override
  FxImageSource get images => const _NoImages();

  @override
  DollRenderer get restRenderer => renderer;

  @override
  BoardSprites? get sprites => null;

  @override
  void dispose() {}
}

final class _NoImages implements FxImageSource {
  const _NoImages();

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(GameHarness, RecordingRenderer)> mount(
    Level level, {
    List<FxId> files = const [],
  }) async {
    final skin = RecordingSkin();
    final h = await GameHarness.mount(
      level,
      fx: await libraryWith(files),
      skin: skin,
    );
    await h.start();
    return (h, skin.renderer);
  }

  test(
    'each top doll on its base at its size; none for the empty slot',
    () async {
      final (h, painted) = await mount(mainLevel);
      await h.render();
      final g = h.game.geometry!;
      final dolls = {
        for (final p in painted.painted.where((p) => !p.silhouette))
          (p.baseX, p.baseY): p,
      };
      void expectDoll(String id, DollColor color, int size, {double? baseY}) {
        final s = g.slot(id);
        final p = dolls[(s.centerX, baseY ?? s.surfaceY)];
        expect(p, isNotNull, reason: id);
        expect(p!.color, color, reason: id);
        expect(p.height, g.dollHeight(size), reason: id);
        expect(p.scale, 1, reason: id);
      }

      expectDoll('r0c0', DollColor.red, 4);
      expectDoll('r0c3', DollColor.purple, 3);
      expectDoll('r1c0', DollColor.blue, 2);
      // The sealed doll stands on the case floor (no glass file: its
      // static stand-in, so the sprite draws it).
      expectDoll(
        'r1c3',
        DollColor.green,
        2,
        baseY: g.slot('r1c3').lockedDollBaseY,
      );
      expectDoll('r2c1', DollColor.blue, 1);
      expect(dolls, hasLength(10));
    },
  );

  test('a buried nest is a true-size silhouette one step up (D21)', () async {
    final (h, painted) = await mount(tl.towerLevel);
    await h.render();
    final g = h.game.geometry!;
    final tower = g.slot('r0c0');
    // r0c0 buries green2 (depth 1) and green1 (depth 2) under blue3.
    final silhouettes = painted.painted.where((p) => p.silhouette).toList();
    final r0c0 = silhouettes.where((p) => p.baseX == tower.centerX).toList();
    expect(r0c0.map((p) => p.height), [g.dollHeight(1), g.dollHeight(2)]);
    expect(r0c0.map((p) => p.baseY), [
      tower.buriedBaseY(2, buried: 2),
      tower.buriedBaseY(1, buried: 2),
    ], reason: 'deepest first');
    expect(r0c0.first.baseY, lessThan(r0c0.last.baseY));
  });

  test('a reveal: doll_reveal drops the new top itself while the board '
      'shifts the nests still buried one step down (§9.1)', () async {
    final (h, painted) = await mount(tl.towerLevel, files: boardFiles);
    final tower = h.game.geometry!.slot('r0c0');
    await h.move('r0c0', 'r0c2');
    await h.run(60);
    painted.painted.clear();
    await h.render();
    final shift = h.board.scene.slot('r0c0')!.reveal!;
    final at = painted.painted
        .where((p) => p.silhouette && p.baseX == tower.centerX)
        .toList();
    // Only the one still buried (green1, new depth 1): the clip draws the
    // dropping top (green2), silhouette then colour, and hides its sprite.
    expect(at.map((p) => p.height), [h.game.geometry!.dollHeight(1)]);
    expect(at.single.baseY, closeTo(shift.buriedBaseY(1), 1e-9));
    expect(
      at.single.baseY,
      inExclusiveRange(
        tower.buriedBaseY(2, buried: 2),
        tower.buriedBaseY(1, buried: 2),
      ),
    );
    final reveal = h.board.fx.liveClips.singleWhere(
      (c) => c.fx == FxId.dollReveal,
    );
    expect(reveal.hides, ['r0c0']);
    expect(h.board.scene.slot('r0c0')!.spriteHidden, isTrue);
  });

  test(
    'without doll_pick, the selected nest is drawn lifted (§10.7)',
    () async {
      final (h, painted) = await mount(tutorial);
      await h.select('r0c0');
      painted.painted.clear();
      await h.render();
      final s = h.game.geometry!.slot('r0c0');
      final lifted = painted.painted.singleWhere((p) => p.baseX == s.centerX);
      expect(lifted.baseY, s.surfaceY - MotionTokens.pickLift);
      expect(lifted.scale, MotionTokens.pickScale);
    },
  );

  test('pips: the top nest\'s sizes filled in its colour, biggest on the '
      'left; none on an extra slot', () async {
    final (h, _) = await mount(mainLevel);
    final snap = await h.render(pixelRatio: 2);
    final s = h.game.geometry!.slot('r0c3');
    final purple = DollPalette.of(DollColor.purple).base;
    (int, int, int, int) pip(int position) => snap.at(
      (s.pipCenterX(position) * 2).round(),
      (s.pipCenterY * 2).round(),
    );
    // purple [3, 2, 1] of maxSize 4: position 0 (size 4) is empty.
    final empty = pip(0);
    expect(empty.$1, lessThan(80));
    for (final position in [1, 2, 3]) {
      final (r, g, b, _) = pip(position);
      expect((r - (purple.r * 255).round()).abs(), lessThan(12));
      expect((g - (purple.g * 255).round()).abs(), lessThan(12));
      expect((b - (purple.b * 255).round()).abs(), lessThan(12));
    }
  });

  test('the tag and the badge draw where the layout puts them', () async {
    final (h, _) = await mount(mainLevel);
    final snap = await h.render(pixelRatio: 2);
    final g = h.game.geometry!;
    final tag = g.slot('r1c0').towerTagOrigin;
    // Inside the walnut pill, clear of its text.
    final (r, gr, b, _) = snap.at(
      ((tag.dx + 2) * 2).round(),
      ((tag.dy + 8) * 2).round(),
    );
    expect((r, gr, b), (0x7B, 0x48, 0x24));
    final badge = g.slot('r2c1').iceBadgeRect;
    final edge = snap.at(
      ((badge.left + 3) * 2).round(),
      (badge.center.dy * 2).round(),
    );
    expect(edge.$3, greaterThan(edge.$1), reason: 'blue');
  });

  test('a paused board draws the same frame twice (no drift)', () async {
    final (h, _) = await mount(mainLevel, files: boardFiles);
    await h.apply(const SelectionChangedEffect(selected: 'r0c0'));
    await h.run(100);
    h.game.pauseEngine();
    final a = await h.render();
    await h.tick(500);
    final b = await h.render();
    expect(b.differingPixels(a, tolerance: 0), 0);
  });
}
