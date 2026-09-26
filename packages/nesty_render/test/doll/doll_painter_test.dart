import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/nesty_render.dart';

final class _Capture implements DollRenderer {
  final painted = <DollPaintParams>[];

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
  void paint(Canvas canvas, DollPaintParams p) =>
      painted.add(DollPaintParams()..copyFrom(p));

  @override
  void dispose() {}
}

void main() {
  final canvas = Canvas(PictureRecorder());

  group('DollPainter', () {
    test('fits the 2:3 artboard bottom-centred in the size', () {
      final renderer = _Capture();
      DollPainter(renderer: renderer, color: DollColor.teal)
        ..paint(canvas, const Size(60, 120)) // width-limited: h = 90
        ..paint(canvas, const Size(200, 150)); // height-limited: h = 150
      final [tall, wide] = renderer.painted;
      expect(tall.height, 90);
      expect(tall.baseX, 30);
      expect(tall.baseY, closeTo(120 - 90 * 26 / 768, 1e-9));
      expect(wide.height, 150);
      expect(wide.baseX, 100);
      expect(wide.baseY, closeTo(150 * 742 / 768, 1e-9));
      expect(tall.color, DollColor.teal);
      expect(DollPainter.heightFor(const Size(60, 120)), 90);
    });

    test('forwards every option', () {
      final renderer = _Capture();
      DollPainter(
        renderer: renderer,
        color: DollColor.gold,
        symbols: DollSymbols.large,
        part: DollPart.lid,
        silhouette: true,
        lidLift: 0.3,
        open: true,
        opacity: 0.5,
        shine: 0.2,
        reveal: 0.7,
      ).paint(canvas, const Size(40, 60));
      final p = renderer.painted.single;
      expect(p.symbols, DollSymbols.large);
      expect(p.part, DollPart.lid);
      expect(p.silhouette, isTrue);
      expect(p.lidLift, 0.3);
      expect(p.open, isTrue);
      expect(p.opacity, 0.5);
      expect(p.shine, 0.2);
      expect(p.reveal, 0.7);
    });

    test('paints nothing into an empty size', () {
      final renderer = _Capture();
      DollPainter(
        renderer: renderer,
        color: DollColor.red,
      ).paint(canvas, Size.zero);
      expect(renderer.painted, isEmpty);
    });

    test('repaints only when something changed', () {
      final renderer = _Capture();
      DollPainter make({
        DollColor color = DollColor.red,
        DollRenderer? r,
        double lift = 0,
      }) => DollPainter(renderer: r ?? renderer, color: color, lidLift: lift);
      expect(make().shouldRepaint(make()), isFalse);
      expect(make().shouldRepaint(make(color: DollColor.blue)), isTrue);
      expect(make().shouldRepaint(make(lift: 0.1)), isTrue);
      expect(make().shouldRepaint(make(r: _Capture())), isTrue);
    });
  });

  group('DollPaintParams', () {
    test('reset restores the defaults and copyFrom copies every field', () {
      final a = DollPaintParams()
        ..color = DollColor.navy
        ..height = 10
        ..baseX = 1
        ..baseY = 2
        ..lidLift = 0.3
        ..open = true
        ..part = DollPart.body
        ..symbols = DollSymbols.none
        ..silhouette = true
        ..opacity = 0.4
        ..scaleX = 1.1
        ..scaleY = 0.9
        ..rotation = 0.2
        ..shine = 0.5
        ..reveal = 0.6;
      final b = DollPaintParams()..copyFrom(a);
      for (final p in [a, b]) {
        expect(p.color, DollColor.navy);
        expect(p.height, 10);
        expect(p.baseX, 1);
        expect(p.baseY, 2);
        expect(p.lidLift, 0.3);
        expect(p.open, isTrue);
        expect(p.part, DollPart.body);
        expect(p.symbols, DollSymbols.none);
        expect(p.silhouette, isTrue);
        expect(p.opacity, 0.4);
        expect(p.scaleX, 1.1);
        expect(p.scaleY, 0.9);
        expect(p.rotation, 0.2);
        expect(p.shine, 0.5);
        expect(p.reveal, 0.6);
      }
      b.reset();
      final d = DollPaintParams();
      expect(b.color, d.color);
      expect(b.height, 0);
      expect(b.part, DollPart.full);
      expect(b.symbols, DollSymbols.subtle);
      expect(b.silhouette, isFalse);
      expect(b.opacity, 1);
      expect(b.scaleX, 1);
      expect(b.shine, -1);
      expect(b.reveal, -1);
    });
  });
}
