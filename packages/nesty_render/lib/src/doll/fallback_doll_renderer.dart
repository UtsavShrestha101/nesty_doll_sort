import 'dart:ui' show Canvas;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:nesty_render/src/doll/doll_paint_params.dart';
import 'package:nesty_render/src/doll/doll_renderer.dart';

/// Draws with [primary] (the skin) whenever it can paint a doll's height
/// (`DollRenderer.canPaint`: any prepared raster, resampled if the height
/// itself isn't prepared yet), and with [fallback] (the placeholder, spec
/// §12.5) otherwise: before the skin's first rasters exist, and for good if
/// the skin fails to load. A re-layout that changes every doll's height
/// (the extra slot, `BoardLayout`) therefore keeps the skin on screen while
/// the new heights are prepared.
///
/// Owns both renderers.
final class FallbackDollRenderer implements DollRenderer {
  FallbackDollRenderer({
    required this.primary,
    required this.fallback,
    this.onPrimaryError,
  });

  final DollRenderer primary;
  final DollRenderer fallback;

  /// Told when [primary] fails to prepare (e.g. for Crashlytics, M4).
  /// Without it the error is only printed in debug builds.
  final void Function(Object error, StackTrace stack)? onPrimaryError;

  /// Prepares [fallback] first so something is always drawable, then
  /// [primary]. A primary failure is reported, never thrown: the game keeps
  /// the placeholder (CLAUDE.md rule 3 "fail gracefully").
  @override
  Future<void> prepare({
    required Iterable<double> heights,
    required double devicePixelRatio,
  }) async {
    final list = heights.toList(growable: false);
    await fallback.prepare(heights: list, devicePixelRatio: devicePixelRatio);
    try {
      await primary.prepare(heights: list, devicePixelRatio: devicePixelRatio);
    } on Object catch (error, stack) {
      final report = onPrimaryError;
      if (report != null) {
        report(error, stack);
      } else {
        debugPrint('FallbackDollRenderer: skin failed to prepare: $error');
      }
    }
  }

  // ── Hot path: runs every frame. No allocation (CLAUDE.md rule 8). ──

  @override
  bool isReadyFor(double height) =>
      primary.isReadyFor(height) || fallback.isReadyFor(height);

  @override
  bool canPaint(double height) =>
      primary.canPaint(height) || fallback.canPaint(height);

  @override
  void paint(Canvas canvas, DollPaintParams p) {
    if (primary.canPaint(p.height)) {
      primary.paint(canvas, p);
    } else {
      fallback.paint(canvas, p);
    }
  }

  // ── End of hot path. ──

  @override
  void dispose() {
    primary.dispose();
    fallback.dispose();
  }
}
