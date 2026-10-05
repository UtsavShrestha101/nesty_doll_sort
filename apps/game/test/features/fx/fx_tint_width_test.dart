// m7-4 4.3, 4.14, 4.15 (LOTTIE.md "Tint and width"): the ribbons are
// recoloured by their four named fills, and the family counter's pill takes
// any width, on the real bundled files.
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/features/fx/asset_fx_library.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

import 'support/fx_test_art.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AssetFxLibrary library;

  setUpAll(() async {
    library = AssetFxLibrary(yieldToFrames: () async {});
    await library.load();
  });

  /// How many pixels are within a few levels of [c] and opaque.
  int count(Snapshot s, Color c) {
    var n = 0;
    final r = (c.r * 255).round(), g = (c.g * 255).round();
    final b = (c.b * 255).round();
    for (var i = 0; i < s.bytes.length; i += 4) {
      if (s.bytes[i + 3] > 250 &&
          (s.bytes[i] - r).abs() < 4 &&
          (s.bytes[i + 1] - g).abs() < 4 &&
          (s.bytes[i + 2] - b).abs() < 4) {
        n++;
      }
    }
    return n;
  }

  const mine = RibbonColors(
    band: Color(0xFF12AB34),
    edge: Color(0xFF56CD78),
    tail: Color(0xFF9A0BCD),
    fold: Color(0xFFEF1234),
  );

  test('both ribbons list their five named fills for tinting', () {
    for (final id in [FxId.uiWinRibbon, FxId.uiChapterRibbon]) {
      expect(fxSpecOf(id).tintFills, [
        'band_fill',
        'edge_fill',
        'fold_fill',
        'hi_fill',
        'tail_fill',
      ]);
    }
    expect(fxSpecOf(FxId.uiFamilyCounter).sizedRects, [
      'glow_rect',
      'pill_rect',
    ]);
  });

  for (final (id, frame) in [
    (FxId.uiWinRibbon, 40.0),
    (FxId.uiChapterRibbon, 60.0),
  ]) {
    group('${id.fileName} at frame $frame', () {
      test('each of the band, edge, tail and fold takes its own colour, with '
          'no colour matrix', () async {
        final clip = FxDrawable.of(library, id)!;
        clip.params.setRibbonColors(mine);
        final snap = await snapshotDrawable(clip, frame, pixelRatio: 2);
        expect(count(snap, mine.band), greaterThan(200), reason: 'band');
        expect(count(snap, mine.edge), greaterThan(50), reason: 'edge');
        expect(count(snap, mine.tail), greaterThan(50), reason: 'tail');
        expect(count(snap, mine.fold), greaterThan(5), reason: 'fold');
      });

      test('clearing the colours restores the authored ones', () async {
        final clip = FxDrawable.of(library, id)!;
        final authored = await snapshotDrawable(clip, frame);
        clip.params.setRibbonColors(mine);
        final tinted = await snapshotDrawable(clip, frame);
        expect(authored.differingPixels(tinted), greaterThan(1000));
        clip.params.setRibbonColors(null);
        final back = await snapshotDrawable(clip, frame);
        expect(authored.differingPixels(back), 0);
      });
    });
  }

  test('the win ribbon as authored is tokens.winRibbon.default', () async {
    final clip = FxDrawable.of(library, FxId.uiWinRibbon)!;
    final snap = await snapshotDrawable(clip, 40, pixelRatio: 2);
    final c = WinRibbonTokens.defaultColors;
    expect(count(snap, c.band), greaterThan(200));
    expect(count(snap, c.edge), greaterThan(50));
    expect(count(snap, c.tail), greaterThan(50));
  });

  group('the family counter pill takes any width', () {
    Future<Rect> extent(double? width) async {
      final clip = FxDrawable.of(library, FxId.uiFamilyCounter)!;
      clip.params.pillWidth = width;
      final snap = await snapshotDrawable(clip, 0, pixelRatio: 2);
      // The walnut pill (#7B4824) and the cream mark on it.
      final pill = snap.boundsWhere((x, y) {
        final i = (y * snap.width + x) * 4;
        return snap.bytes[i + 3] > 250 &&
            (snap.bytes[i] - 0x7B).abs() < 6 &&
            (snap.bytes[i + 1] - 0x48).abs() < 6 &&
            (snap.bytes[i + 2] - 0x24).abs() < 6;
      });
      return pill!;
    }

    test('70 as authored, 100 when asked: wider by 30, centred', () async {
      final authored = await extent(null);
      final wide = await extent(100);
      expect(authored.width / 2, closeTo(70, 2));
      expect(wide.width / 2, closeTo(100, 2));
      expect(wide.center.dx, closeTo(authored.center.dx, 1));
    });

    test('64 and 78 (the hugged widths) draw at exactly that', () async {
      expect((await extent(64)).width / 2, closeTo(64, 2));
      expect((await extent(78)).width / 2, closeTo(78, 2));
    });

    test('the doll mark stays 14 dp in from the left edge', () async {
      for (final w in [64.0, 78.0, 100.0]) {
        final clip = FxDrawable.of(library, FxId.uiFamilyCounter)!;
        clip.params.pillWidth = w;
        final snap = await snapshotDrawable(clip, 0, pixelRatio: 2);
        final mark = snap.boundsWhere((x, y) {
          final i = (y * snap.width + x) * 4;
          return snap.bytes[i + 3] > 250 &&
              (snap.bytes[i] - 0xFF).abs() < 8 &&
              (snap.bytes[i + 1] - 0xF5).abs() < 8 &&
              (snap.bytes[i + 2] - 0xE0).abs() < 8;
        })!;
        final centre = mark.center.dx / 2;
        // The canvas is 120 wide, the pill centred at 60.
        expect(centre, closeTo(60 - w / 2 + 14, 1.5), reason: 'width $w');
      }
    });
  });
}
