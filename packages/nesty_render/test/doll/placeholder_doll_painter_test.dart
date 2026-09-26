import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

import 'support/render_test_support.dart';

const _w = 128;
const _h = 192;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final placeholder = PlaceholderDollPainter();
  tearDownAll(placeholder.dispose);

  Future<Uint8List> draw(
    void Function(DollPaintParams p) setUp, {
    DollRenderer? using,
    int top = 0,
    int height = _h,
  }) async {
    final p = DollPaintParams()
      ..height = _h.toDouble()
      ..baseX = _w / 2
      ..baseY = _h * 742 / 768 - top;
    setUp(p);
    final image = await capture(
      _w,
      height,
      (c) => (using ?? placeholder).paint(c, p),
    );
    final bytes = await rgbaOf(image);
    image.dispose();
    return bytes;
  }

  int opaque(Uint8List rgba) {
    var n = 0;
    for (var i = 3; i < rgba.length; i += 4) {
      if (rgba[i] == 255) n++;
    }
    return n;
  }

  List<int> px(Uint8List rgba, double artX, double artY, {int top = 0}) {
    final x = (artX * _w / 512).round();
    final y = (artY * _h / 768).round() - top;
    final i = (y * _w + x) * 4;
    return rgba.sublist(i, i + 4);
  }

  group('PlaceholderDollPainter (spec §12.5)', () {
    test('is always ready and needs no async work', () {
      expect(placeholder.isReadyFor(10), isTrue);
      expect(placeholder.isReadyFor(1000), isTrue);
      expect(placeholder.canPaint(1000), isTrue);
    });

    test('draws a doll for every colour, each in its own colour', () async {
      final seen = <String>{};
      for (final color in DollColor.values) {
        final rgba = await draw((p) => p.color = color);
        expect(opaque(rgba), greaterThan(_w * _h * 0.3), reason: color.id);
        // The belly is the colour's base (the gradient's white stop).
        final belly = px(rgba, 200, 470);
        seen.add(belly.join(','));
      }
      expect(seen, hasLength(DollColor.values.length));
    });

    test('has a white face with dark eyes', () async {
      final rgba = await draw((p) => p.color = DollColor.navy);
      final face = px(rgba, 256, 180);
      expect(face[0], greaterThan(240));
      expect(face[2], greaterThan(230));
      final eye = px(rgba, 220, 226);
      expect(eye[0], lessThan(80));
    });

    test('silhouettes are wood with no face', () async {
      final rgba = await draw(
        (p) => p
          ..silhouette = true
          ..color = DollColor.blue,
      );
      final belly = px(rgba, 200, 470);
      // Near the gradient's highlight, i.e. the wood colour itself.
      for (final (c, wood) in [(0, 0xE6), (1, 0xC0), (2, 0x8C)]) {
        expect(belly[c], closeTo(wood, 3));
      }
      final face = px(rgba, 256, 180);
      expect(face[0], lessThan(240), reason: 'no white face');
    });

    test('the lid rises with lidLift and opens the rim', () async {
      final closed = await draw(
        (p) => p.color = DollColor.red,
        top: -100,
        height: _h + 100,
      );
      final lifted = await draw(
        (p) => p
          ..color = DollColor.red
          ..lidLift = 0.3,
        top: -100,
        height: _h + 100,
      );
      int firstRow(Uint8List rgba) {
        for (var i = 3; i < rgba.length; i += 4) {
          if (rgba[i] > 128) return (i ~/ 4) ~/ _w;
        }
        return -1;
      }

      final rise = firstRow(closed) - firstRow(lifted);
      expect(rise, closeTo(0.3 * _h, 2));
      // The dark interior shows at the opening.
      final rim = px(lifted, 256, 401, top: -100);
      expect(rim[0], lessThan(90));
    });

    test('body and lid parts split at splitY', () async {
      final body = await draw(
        (p) => p
          ..color = DollColor.green
          ..part = DollPart.body,
      );
      final lid = await draw(
        (p) => p
          ..color = DollColor.green
          ..part = DollPart.lid,
      );
      expect(px(body, 256, 150)[3], 0, reason: 'no head on the body part');
      expect(px(lid, 256, 150)[3], 255);
      expect(px(lid, 256, 600)[3], 0, reason: 'no belly on the lid part');
      expect(px(body, 256, 600)[3], 255);
    });

    test('reveal 0 is the silhouette, reveal 1 the coloured doll', () async {
      final wood = await draw((p) => p.silhouette = true);
      final coloured = await draw((p) => p.color = DollColor.teal);
      expect(
        await draw(
          (p) => p
            ..color = DollColor.teal
            ..reveal = 0,
        ),
        wood,
      );
      expect(
        await draw(
          (p) => p
            ..color = DollColor.teal
            ..reveal = 1,
        ),
        coloured,
      );
    });

    test('the shine stays inside the doll', () async {
      final plain = await draw((p) => p.color = DollColor.purple);
      final shiny = await draw(
        (p) => p
          ..color = DollColor.purple
          ..shine = 0.5,
      );
      bool clearAround(int x, int y) {
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            final nx = x + dx;
            final ny = y + dy;
            if (nx < 0 || ny < 0 || nx >= _w || ny >= _h) continue;
            if (plain[(ny * _w + nx) * 4 + 3] != 0) return false;
          }
        }
        return true;
      }

      var changed = 0;
      for (var i = 0; i < plain.length; i += 4) {
        final x = (i ~/ 4) % _w;
        final y = (i ~/ 4) ~/ _w;
        // Off the doll (not just an antialiased edge) nothing appears.
        if (clearAround(x, y)) expect(shiny[i + 3], 0, reason: '($x, $y)');
        if (shiny[i] != plain[i]) changed++;
      }
      expect(changed, greaterThan(200));
    });

    test('draws symbols once an atlas page is prepared', () async {
      final atlas = await loadSymbols();
      final withSymbols = PlaceholderDollPainter(symbols: atlas);
      addTearDown(() {
        withSymbols.dispose();
        atlas.dispose();
      });
      Future<Uint8List> mode(DollSymbols s) => draw(
        (p) => p
          ..color = DollColor.red
          ..symbols = s,
        using: withSymbols,
      );
      // Before prepare: no page, so subtle draws like none.
      expect(await mode(DollSymbols.subtle), await mode(DollSymbols.none));
      await withSymbols.prepare(heights: const [192], devicePixelRatio: 1);
      final none = await mode(DollSymbols.none);
      final subtle = await mode(DollSymbols.subtle);
      final large = await mode(DollSymbols.large);
      // The large disc (r 92 + half its 8-unit ring) bounds every change.
      final box = Rect.fromCircle(
        center: SkinTokens.symbolAnchor,
        radius: SkinTokens.badgeRadius + SkinTokens.badgeStroke,
      );
      var inside = 0;
      for (var i = 0; i < none.length; i += 4) {
        final x = (i ~/ 4) % _w * 512 / _w;
        final y = (i ~/ 4) ~/ _w * 768 / _h;
        final differs = none[i] != subtle[i] || none[i] != large[i];
        if (!differs) continue;
        expect(box.contains(Offset(x, y)), isTrue, reason: 'at ($x, $y)');
        inside++;
      }
      expect(inside, greaterThan(100));
      // Large mode: cream disc at the anchor's edge.
      expect(px(large, 256 - 80, 590)[0], greaterThan(240));
    });

    testWidgets('DollPainter + placeholder paints without async work', (
      tester,
    ) async {
      final renderer = PlaceholderDollPainter();
      addTearDown(renderer.dispose);
      await tester.pumpWidget(
        Center(
          child: CustomPaint(
            size: const Size(60, 90),
            painter: DollPainter(renderer: renderer, color: DollColor.pink),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    test('refuses to prepare after dispose', () async {
      final own = PlaceholderDollPainter()..dispose();
      expect(own.isReadyFor(10), isFalse);
      expect(own.canPaint(10), isFalse);
      expect(
        own.prepare(heights: const [10], devicePixelRatio: 1),
        throwsStateError,
      );
    });
  });
}
