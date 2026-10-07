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
import 'package:nesty_game/features/fx/fx_ribbon.dart';
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

  group('a ribbon takes a band width through its named rects (m7-5)', () {
    bool near(Snapshot s, int x, int y, Color c) {
      final i = (y * s.width + x) * 4;
      return s.bytes[i + 3] > 250 &&
          (s.bytes[i] - (c.r * 255).round()).abs() < 4 &&
          (s.bytes[i + 1] - (c.g * 255).round()).abs() < 4 &&
          (s.bytes[i + 2] - (c.b * 255).round()).abs() < 4;
    }

    /// The band's and the whole ribbon's extent, in dp, at rest.
    Future<(Rect band, Rect ribbon)> extent(
      FxRibbon ribbon,
      double? width,
    ) async {
      final clip = FxDrawable.of(library, ribbon.id)!;
      clip.params
        ..setRibbonColors(mine)
        ..ribbonBandWidth = width;
      // The win ribbon holds from 18, the chapter one from 18 to 138.
      final snap = await snapshotDrawable(clip, 18, pixelRatio: 2);
      final band = snap.boundsWhere((x, y) => near(snap, x, y, mine.band))!;
      final all = snap.alphaBounds()!;
      Rect dp(Rect r) => Rect.fromLTRB(
        r.left / 2,
        r.top / 2,
        (r.right + 1) / 2,
        (r.bottom + 1) / 2,
      );
      return (dp(band), dp(all));
    }

    test('the win band is 290 with its tails to 334, as authored, and fits '
        'a 360 dp phone with 13 dp to spare', () async {
      expect(WinRibbonTokens.bandSize, const Size(290, 56));
      expect(WinRibbonTokens.reach, 334);
      expect(FxRibbon.win.band, WinRibbonTokens.bandSize);
      expect(FxRibbon.win.reachFor(290), WinRibbonTokens.reach);
      final (band, all) = await extent(FxRibbon.win, null);
      expect(band.width, closeTo(290, 1.5));
      expect(all.width, closeTo(334, 1.5));
      expect(FxRibbon.win.bandWidthFor(360), 290);
      expect((360 - FxRibbon.win.reachFor(290)) / 2, 13);
    });

    for (final (ribbon, width) in [
      (FxRibbon.win, 250.0),
      (FxRibbon.win, 270.0),
      (FxRibbon.chapter, 320.0),
      (FxRibbon.chapter, 290.0),
    ]) {
      test('${ribbon.id.fileName} at $width: the band and edge take it, the '
          'tails stay 22 past it, centred on the anchor', () async {
        final (authoredBand, authored) = await extent(ribbon, null);
        final (band, all) = await extent(ribbon, width);
        expect(band.width, closeTo(width, 1.5));
        expect(all.width, closeTo(ribbon.reachFor(width), 1.5));
        expect(band.center.dx, closeTo(authoredBand.center.dx, 0.5));
        expect(all.center.dx, closeTo(authored.center.dx, 0.5));
        // The height is the file's.
        expect(band.height, closeTo(authoredBand.height, 0.5));
        expect(all.height, closeTo(authored.height, 0.5));
      });
    }

    test(
      'the highlight stays 16 narrower than the band (274 in 290)',
      () async {
        // hi_fill is 30 % white over the band. The colour match also takes a
        // few antialiased pixels at the band's corners, so this compares the
        // highlight at each width with the authored one.
        final hi = Color.lerp(mine.band, const Color(0xFFFFFFFF), 0.3)!;
        Future<double> shineWidth(double? width) async {
          final clip = FxDrawable.of(library, FxId.uiWinRibbon)!;
          clip.params
            ..setRibbonColors(mine)
            ..ribbonBandWidth = width;
          final snap = await snapshotDrawable(clip, 18, pixelRatio: 2);
          final shine = snap.boundsWhere((x, y) {
            final i = (y * snap.width + x) * 4;
            return snap.bytes[i + 3] > 250 &&
                (snap.bytes[i] - (hi.r * 255).round()).abs() < 6 &&
                (snap.bytes[i + 1] - (hi.g * 255).round()).abs() < 6 &&
                (snap.bytes[i + 2] - (hi.b * 255).round()).abs() < 6;
          })!;
          return (shine.width + 1) / 2;
        }

        final authored = await shineWidth(null);
        expect(authored, closeTo(290 - FxRibbon.hiInset, 4));
        for (final width in [270.0, 250.0]) {
          expect(
            await shineWidth(width),
            closeTo(authored - (290 - width), 1),
            reason: 'band $width',
          );
        }
      },
    );

    test('clearing the width restores the authored ribbon exactly', () async {
      final clip = FxDrawable.of(library, FxId.uiChapterRibbon)!;
      final authored = await snapshotDrawable(clip, 60);
      clip.params.ribbonBandWidth = 300;
      final narrow = await snapshotDrawable(clip, 60);
      expect(authored.differingPixels(narrow), greaterThan(100));
      clip.params.ribbonBandWidth = null;
      final back = await snapshotDrawable(clip, 60);
      expect(authored.differingPixels(back), 0);
    });

    test("a ribbon's label box keeps its 24 dp margin to the band", () {
      expect(FxRibbon.win.labelFor(290).maxWidth, 266);
      expect(FxRibbon.win.labelFor(250).maxWidth, 226);
      expect(FxRibbon.chapter.labelFor(336).maxWidth, 312);
      expect(FxRibbon.chapter.labelFor(320).maxWidth, 296);
      expect(identical(FxRibbon.win.labelFor(290), FxRibbon.win.label), isTrue);
    });
  });

  test('the m7-5 Lottie-only fixes draw as authored: the game names no '
      "fill to tint in ui_chest's rays, the glass flash or ui_spinner "
      '(items 6, 9, 10)', () {
    for (final id in [
      FxId.uiChest,
      FxId.fxGlassUnlock,
      FxId.fxGlassUnlockTall,
      FxId.uiSpinner,
    ]) {
      final spec = fxSpecOf(id);
      expect(spec.tintFills, isEmpty, reason: id.fileName);
      expect(spec.colorFills, isEmpty, reason: id.fileName);
      expect(spec.sizedRects, isEmpty, reason: id.fileName);
    }
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
