import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_render/nesty_render.dart';

/// Records what the fallback asks of it.
final class _Recording implements DollRenderer {
  _Recording(this.name, this.log, {this.readyHeights = const {}, this.error});

  final String name;
  final List<String> log;
  Set<double> readyHeights;
  final Object? error;
  bool disposed = false;

  @override
  Future<void> prepare({
    required Iterable<double> heights,
    required double devicePixelRatio,
  }) async {
    log.add('$name.prepare ${heights.toList()} @$devicePixelRatio');
    if (error != null) throw error!;
    readyHeights = {...readyHeights, ...heights};
  }

  @override
  bool isReadyFor(double height) => readyHeights.contains(height);

  // Like SvgSkinRenderer: any prepared raster can draw any height.
  @override
  bool canPaint(double height) => readyHeights.isNotEmpty;

  @override
  void paint(Canvas canvas, DollPaintParams p) =>
      log.add('$name.paint ${p.height}');

  @override
  void dispose() => disposed = true;
}

void main() {
  final canvas = Canvas(PictureRecorder());

  group('FallbackDollRenderer', () {
    test(
      'paints with the fallback until the primary can paint at all',
      () async {
        final log = <String>[];
        final renderer = FallbackDollRenderer(
          primary: _Recording('svg', log),
          fallback: _Recording('placeholder', log, readyHeights: {99, 117}),
        );
        final p = DollPaintParams()..height = 99;
        renderer.paint(canvas, p);
        await renderer.prepare(heights: const [99], devicePixelRatio: 3);
        renderer.paint(canvas, p);
        expect(log, [
          'placeholder.paint 99.0',
          'placeholder.prepare [99.0] @3.0',
          'svg.prepare [99.0] @3.0',
          'svg.paint 99.0',
        ]);
        expect(renderer.isReadyFor(99), isTrue);
        expect(renderer.isReadyFor(117), isTrue);
        expect(renderer.isReadyFor(50), isFalse);
      },
    );

    test(
      'a height the skin has not prepared yet stays on the skin (re-layout)',
      () async {
        // +Slot re-pitches the bottom row: every doll's height changes
        // (140 → 135.5 dp) before the new heights are prepared. Flashing
        // the placeholder for those frames was review RENDER-2.
        final log = <String>[];
        final renderer = FallbackDollRenderer(
          primary: _Recording('svg', log, readyHeights: {140}),
          fallback: _Recording('placeholder', log),
        );
        renderer.paint(canvas, DollPaintParams()..height = 135.5);
        expect(log, ['svg.paint 135.5']);
        expect(renderer.isReadyFor(135.5), isFalse);
        expect(renderer.canPaint(135.5), isTrue);
      },
    );

    test(
      'a failing skin is reported, not thrown, and the fallback stays',
      () async {
        final log = <String>[];
        final errors = <Object>[];
        final renderer = FallbackDollRenderer(
          primary: _Recording('svg', log, error: StateError('bad skin')),
          fallback: _Recording('placeholder', log),
          onPrimaryError: (e, _) => errors.add(e),
        );
        await renderer.prepare(heights: const [63], devicePixelRatio: 2);
        renderer.paint(canvas, DollPaintParams()..height = 63);
        expect(errors.single, isA<StateError>());
        expect(log.last, 'placeholder.paint 63.0');
      },
    );

    test('passes a one-shot iterable to both renderers', () async {
      final log = <String>[];
      final renderer = FallbackDollRenderer(
        primary: _Recording('svg', log),
        fallback: _Recording('placeholder', log),
      );
      await renderer.prepare(
        heights: [1.0, 2.0].map((h) => h * 10),
        devicePixelRatio: 1,
      );
      expect(log, [
        'placeholder.prepare [10.0, 20.0] @1.0',
        'svg.prepare [10.0, 20.0] @1.0',
      ]);
    });

    test('disposes both renderers', () {
      final primary = _Recording('svg', []);
      final fallback = _Recording('placeholder', []);
      FallbackDollRenderer(primary: primary, fallback: fallback).dispose();
      expect(primary.disposed, isTrue);
      expect(fallback.disposed, isTrue);
    });
  });
}
