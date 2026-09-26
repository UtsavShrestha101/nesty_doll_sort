import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter_svg/flutter_svg.dart' show PictureInfo;
import 'package:nesty_render/src/palette/doll_palette.dart';
import 'package:nesty_render/src/raster/svg_raster.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// Where belly symbols sit on the artboard (spec §12.3, design/README.md
/// "Doll rendering" step 3), in art units.
@immutable
final class SymbolGeometry {
  const SymbolGeometry({
    this.anchor = SkinTokens.symbolAnchor,
    this.subtleSize = SkinTokens.symbolSize,
    this.largeSize = SkinTokens.symbolSizeLarge,
    this.artboardHeight = 768,
  });

  /// The design tokens; every shipped skin's `skin.json` matches them.
  static const standard = SymbolGeometry();

  /// Centre of the symbol box.
  final ui.Offset anchor;

  /// Box side in the default (subtle) mode: 110.
  final double subtleSize;

  /// Box side in large-symbols mode: 117 (the JS `150 × 0.78`).
  final double largeSize;

  /// The artboard height the page scale is measured against.
  final double artboardHeight;

  /// The symbol box for one mode.
  ui.Rect box({required bool large}) {
    final side = large ? largeSize : subtleSize;
    return ui.Rect.fromCenter(center: anchor, width: side, height: side);
  }

  @override
  bool operator ==(Object other) =>
      other is SymbolGeometry &&
      other.anchor == anchor &&
      other.subtleSize == subtleSize &&
      other.largeSize == largeSize &&
      other.artboardHeight == artboardHeight;

  @override
  int get hashCode =>
      Object.hash(anchor, subtleSize, largeSize, artboardHeight);
}

/// Every symbol as a white alpha mask at one artboard pixel height, both
/// sizes. Painters tint a cell with `ColorFilter.mode(ink, BlendMode.srcIn)`.
final class SymbolAtlasPage {
  SymbolAtlasPage._({
    required this.artHeightPx,
    required this.pxPerArt,
    required this.image,
    required this.subtleDst,
    required this.largeDst,
    required List<ui.Rect> subtleSrc,
    required List<ui.Rect> largeSrc,
  }) : _subtleSrc = subtleSrc,
       _largeSrc = largeSrc;

  final int artHeightPx;
  final double pxPerArt;
  final ui.Image image;

  /// Where a subtle / large cell lands, in art units. The cell edges sit on
  /// whole pixels at [pxPerArt], so a doll drawn at this height samples the
  /// symbol 1:1, like the design renders.
  final ui.Rect subtleDst;
  final ui.Rect largeDst;

  final List<ui.Rect> _subtleSrc;
  final List<ui.Rect> _largeSrc;

  /// The cell of symbol [index] (see [SymbolAtlas.indexOf]).
  ui.Rect subtleSrc(int index) => _subtleSrc[index];
  ui.Rect largeSrc(int index) => _largeSrc[index];

  int get byteSize => image.width * image.height * 4;

  SymbolAtlasPage clone() => SymbolAtlasPage._(
    artHeightPx: artHeightPx,
    pxPerArt: pxPerArt,
    image: image.clone(),
    subtleDst: subtleDst,
    largeDst: largeDst,
    subtleSrc: _subtleSrc,
    largeSrc: _largeSrc,
  );

  void dispose() => image.dispose();
}

/// The belly symbols (spec §12.3), rasterized per artboard pixel height.
///
/// Pages are built on demand, kept least-recently-used up to [maxPages],
/// and handed out as clones the caller disposes (the same ownership as
/// `SkinCache`), so the placeholder and the skin renderer can share one
/// atlas.
final class SymbolAtlas {
  SymbolAtlas._(this.names, this._pictures, this.geometry, this.maxPages)
    : _indexByName = {for (var i = 0; i < names.length; i++) names[i]: i};

  /// Parses [svgs] (symbol name → 128 × 128 single-colour SVG).
  static Future<SymbolAtlas> fromSvgs(
    Map<String, String> svgs, {
    SymbolGeometry geometry = SymbolGeometry.standard,
    int maxPages = 8,
  }) async {
    final names = svgs.keys.toList(growable: false);
    final pictures = await Future.wait([
      for (final name in names) loadSvgPicture(svgs[name]!),
    ]);
    return SymbolAtlas._(names, pictures, geometry, maxPages);
  }

  /// Loads `<basePath>/<name>.svg` for [names] (default: every palette
  /// colour's symbol) from [bundle]: the game's `apps/game/assets/symbols`.
  static Future<SymbolAtlas> load(
    AssetBundle bundle, {
    String basePath = 'assets/symbols',
    Iterable<String>? names,
    SymbolGeometry geometry = SymbolGeometry.standard,
    int maxPages = 8,
  }) async {
    final wanted = (names ?? DollPalette.values.map((s) => s.symbol))
        .toSet()
        .toList();
    final texts = await Future.wait([
      for (final name in wanted)
        bundle.loadString('$basePath/$name.svg', cache: false),
    ]);
    return fromSvgs(
      {for (var i = 0; i < wanted.length; i++) wanted[i]: texts[i]},
      geometry: geometry,
      maxPages: maxPages,
    );
  }

  /// Symbol names, in cell order.
  final List<String> names;
  final SymbolGeometry geometry;
  final int maxPages;

  final List<PictureInfo> _pictures;
  final Map<String, int> _indexByName;
  final _pages = <int, SymbolAtlasPage>{};
  final _pending = <int, Future<SymbolAtlasPage>>{};
  bool _disposed = false;

  /// The cell index of [name], or -1 when the atlas has no such symbol.
  int indexOf(String name) => _indexByName[name] ?? -1;

  /// A clone of the page for [artHeightPx], rasterized on a miss. The
  /// caller disposes it.
  Future<SymbolAtlasPage> obtain(int artHeightPx) async {
    if (_disposed) throw StateError('SymbolAtlas used after dispose');
    final hit = _pages.remove(artHeightPx);
    if (hit != null) {
      _pages[artHeightPx] = hit;
      return hit.clone();
    }
    var pending = _pending[artHeightPx];
    if (pending == null) {
      pending = _rasterizeAndInsert(artHeightPx);
      _pending[artHeightPx] = pending;
    }
    await pending;
    // Clone whatever is cached now: a small maxPages can evict (and a later
    // request re-insert) the page before this waiter resumes.
    final current = _pages[artHeightPx];
    return current != null ? current.clone() : obtain(artHeightPx);
  }

  /// Disposes the atlas's own page handles (clones stay valid).
  void clear() {
    for (final page in _pages.values) {
      page.dispose();
    }
    _pages.clear();
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    clear();
    for (final info in _pictures) {
      info.picture.dispose();
    }
  }

  Future<SymbolAtlasPage> _rasterizeAndInsert(int artHeightPx) async {
    try {
      final page = await _rasterize(artHeightPx);
      if (_disposed) {
        page.dispose();
        throw StateError('SymbolAtlas disposed while rasterizing');
      }
      _pages[artHeightPx] = page;
      while (_pages.length > math.max(1, maxPages)) {
        _pages.remove(_pages.keys.first)!.dispose();
      }
      return page;
    } finally {
      final removed = _pending.remove(artHeightPx);
      assert(removed != null, 'pending page $artHeightPx');
    }
  }

  Future<SymbolAtlasPage> _rasterize(int artHeightPx) async {
    final scale = artHeightPx / geometry.artboardHeight;
    final subtle = _Cell(geometry.box(large: false), scale);
    final large = _Cell(geometry.box(large: true), scale);
    // One transparent pixel between cells, on top of each cell's own 1 px
    // margin, so bilinear sampling never bleeds a neighbour in.
    final stride = math.max(subtle.width, large.width) + 1;
    final largeTop = subtle.height + 1;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final white = ui.Paint()
      ..colorFilter = const ui.ColorFilter.mode(
        ui.Color(0xFFFFFFFF),
        ui.BlendMode.srcIn,
      );
    final subtleSrc = <ui.Rect>[];
    final largeSrc = <ui.Rect>[];
    for (var i = 0; i < _pictures.length; i++) {
      final info = _pictures[i];
      for (final (cell, top, size, rects) in [
        (subtle, 0, geometry.subtleSize, subtleSrc),
        (large, largeTop, geometry.largeSize, largeSrc),
      ]) {
        final x = i * stride;
        rects.add(
          ui.Rect.fromLTWH(
            x.toDouble(),
            top.toDouble(),
            cell.width.toDouble(),
            cell.height.toDouble(),
          ),
        );
        // design/generator/nesty-doll.js symbolGroup(): the symbol's box is
        // scaled to fit `size` and centred on the anchor.
        final k = size / math.max(info.size.width, info.size.height);
        canvas
          ..save()
          ..translate(x - cell.left.toDouble(), top - cell.top.toDouble())
          ..scale(scale)
          ..translate(
            geometry.anchor.dx - info.size.width / 2 * k,
            geometry.anchor.dy - info.size.height / 2 * k,
          )
          ..scale(k)
          ..saveLayer(null, white)
          ..drawPicture(info.picture)
          ..restore()
          ..restore();
      }
    }
    final picture = recorder.endRecording();
    final ui.Image image;
    try {
      image = await picture.toImage(
        math.max(1, _pictures.length * stride),
        largeTop + large.height,
      );
    } finally {
      picture.dispose();
    }
    return SymbolAtlasPage._(
      artHeightPx: artHeightPx,
      pxPerArt: scale,
      image: image,
      subtleDst: subtle.dst(scale),
      largeDst: large.dst(scale),
      subtleSrc: List.unmodifiable(subtleSrc),
      largeSrc: List.unmodifiable(largeSrc),
    );
  }
}

/// A symbol box snapped outwards to whole pixels, plus a 1 px margin.
final class _Cell {
  _Cell(ui.Rect box, double scale)
    : left = (box.left * scale).floor() - 1,
      top = (box.top * scale).floor() - 1,
      right = (box.right * scale).ceil() + 1,
      bottom = (box.bottom * scale).ceil() + 1;

  final int left;
  final int top;
  final int right;
  final int bottom;

  int get width => right - left;
  int get height => bottom - top;

  ui.Rect dst(double scale) => ui.Rect.fromLTRB(
    left / scale,
    top / scale,
    right / scale,
    bottom / scale,
  );
}
