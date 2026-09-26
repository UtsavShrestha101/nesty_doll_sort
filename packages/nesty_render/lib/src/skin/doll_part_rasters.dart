import 'dart:async' show Completer, unawaited;
import 'dart:ui' as ui;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_render/src/doll/doll_art.dart';
import 'package:nesty_render/src/doll/doll_paint_params.dart';
import 'package:nesty_render/src/doll/placeholder_doll_painter.dart';
import 'package:nesty_render/src/palette/doll_palette.dart';
import 'package:nesty_render/src/palette/doll_tint.dart';
import 'package:nesty_render/src/skin/part_rows.dart';
import 'package:nesty_render/src/skin/skin_layer.dart';
import 'package:nesty_render/src/skin/skin_rasterizer.dart';
import 'package:nesty_render/src/skin/symbol_atlas.dart';
import 'package:nesty_render/src/tokens/render_token_types.dart';
import 'package:nesty_render/src/tokens/render_tokens.gen.dart';

/// One board's doll art as whole-artboard rasters: a lid and a body per
/// colour, and one wood silhouette, all `512·r × 768·r` px with
/// `r = [artScale]` (docs/plans/m2-lottie-design.md §4).
///
/// The game's Lottie image slots and its rest sprites draw the same images,
/// so a sprite and a clip's first or last frame are pixel-identical
/// (PROGRESS D45):
/// - **lid** = `top_mask` (tinted, or gold-rewritten), `face`,
///   `top_detail`, `shine_top`; alpha 0 for art y ≥ `splitY` (400).
/// - **body** = `shadow`, `bottom_mask` (tinted, or gold-rewritten),
///   `bottom_detail`, the belly symbol in the set's [symbols] mode,
///   `shine_bottom`; alpha 0 for art y < `splitY`. The split is hard: no
///   388–412 overlap band as in the SVG and `SvgSkinRenderer`, because the
///   Lottie draws the nest rim between the two.
///
///   It falls on the whole pixel row [DollPartRasters.splitRowPx] (within
///   half a pixel of `splitY · r`), so lid and body never share a pixel.
///   Outside the band, lid over body equals `SvgSkinRenderer` and the
///   design renders.
/// - **silhouette** = `shadow` + `SkinLayer.silhouette` (wood masks, shines
///   at 45 %), whole, not split (spec §3.2, D21).
///
/// Handles follow `ui.Image.clone` semantics like `SkinImageSet`: [clone]
/// gives independent handles to the same pixels, and the memory is freed
/// when the last handle is disposed.
final class DollPartSet {
  /// Wraps rasters made by [DollPartRasters] (or a test). [lids] and
  /// [bodies] must hold the same colours, and every image must be exactly
  /// `widthPx × artHeightPx`.
  DollPartSet({
    required this.skinKey,
    required this.symbols,
    required this.artHeightPx,
    required Map<DollColor, ui.Image> lids,
    required Map<DollColor, ui.Image> bodies,
    required this.silhouette,
  }) : _lids = Map.unmodifiable(lids),
       _bodies = Map.unmodifiable(bodies) {
    if (artHeightPx < 1) {
      throw ArgumentError.value(artHeightPx, 'artHeightPx', 'must be ≥ 1');
    }
    if (lids.length != bodies.length || !lids.keys.every(bodies.containsKey)) {
      throw ArgumentError('lids and bodies must hold the same colours');
    }
    for (final image in [...lids.values, ...bodies.values, silhouette]) {
      if (image.width != widthPx || image.height != artHeightPx) {
        throw ArgumentError(
          'every part raster must be $widthPx×$artHeightPx, '
          'got ${image.width}×${image.height}',
        );
      }
    }
  }

  /// `SkinManifest.cacheKey` of the skin (`classic@1`), or `placeholder`
  /// for the procedural fallback art.
  final String skinKey;

  /// The belly-symbol mode baked into the bodies (settings `symbols`).
  final DollSymbols symbols;

  /// Physical px of the full 768-unit artboard height: the board's tallest
  /// doll × DPR, rounded up ([DollPartRasters.artHeightPxFor]).
  final int artHeightPx;

  final Map<DollColor, ui.Image> _lids;
  final Map<DollColor, ui.Image> _bodies;

  /// The buried-nest silhouette, shadow included.
  final ui.Image silhouette;

  bool _disposed = false;

  /// Raster px per art unit (`r`): the `FxRaster.scale` of every doll slot.
  /// A clip's image layer authored at scale `k` and anchor `a` (art units)
  /// draws this raster correctly at scale `k / r` and anchor `a · r`.
  double get artScale => artHeightPx / DollArt.height;

  /// Width of every raster: the 512-unit artboard at [artScale].
  int get widthPx => (DollArt.width * artScale).round();

  /// The colours this set holds, in `DollColor` order.
  Iterable<DollColor> get colors => DollColor.values.where(_lids.containsKey);

  /// The lid of [color], or null when the set doesn't hold it. A map
  /// lookup: image delegates call it on every draw.
  ui.Image? lid(DollColor color) => _lids[color];

  /// The body of [color], or null when the set doesn't hold it.
  ui.Image? body(DollColor color) => _bodies[color];

  /// GPU bytes held (RGBA8).
  int get byteSize => (_lids.length * 2 + 1) * widthPx * artHeightPx * 4;

  bool get debugDisposed => _disposed;

  DollPartSet clone() {
    if (_disposed) throw StateError('DollPartSet used after dispose');
    return DollPartSet(
      skinKey: skinKey,
      symbols: symbols,
      artHeightPx: artHeightPx,
      lids: {for (final e in _lids.entries) e.key: e.value.clone()},
      bodies: {for (final e in _bodies.entries) e.key: e.value.clone()},
      silhouette: silhouette.clone(),
    );
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final image in _lids.values) {
      image.dispose();
    }
    for (final image in _bodies.values) {
      image.dispose();
    }
    silhouette.dispose();
  }
}

/// Builds and caches [DollPartSet]s (m2-lottie-design §4), with
/// `SkinCache`'s clone/dispose rules: the cache keeps one handle per image
/// and hands out clones, so evicting or clearing never pulls an image out
/// from under a board.
///
/// The cache is per image, so sets for different boards share what they
/// have in common:
/// - a lid per (skin@version, colour, artHeightPx);
/// - a body per (skin@version, colour, symbols mode, artHeightPx), plus
///   whether a symbol atlas drew its symbol;
/// - the silhouette per (skin@version, artHeightPx).
///
/// A symbols-mode change therefore re-rasterizes only the bodies, and the
/// next level at the same doll height reuses every colour it shares.
/// Concurrent requests for the same image share one rasterization.
///
/// Every part is the whole `512·r × 768·r` artboard, split hard on the
/// pixel row [splitRowPx] (art y `splitY`, 400): the lid keeps the rows
/// above it, the body that row and below, so the two never share a pixel
/// (PROGRESS D45).
final class DollPartRasters {
  DollPartRasters({this.maxBytes = 24 * 1024 * 1024}) : assert(maxBytes >= 0);

  /// Evicts least recently used images while the cache holds more than
  /// this; the images of the newest set (and of any set still being
  /// prepared) are always kept.
  final int maxBytes;

  /// [DollPartSet.skinKey] of [preparePlaceholder]'s sets.
  static const placeholderKey = 'placeholder';

  // Insertion-ordered (a LinkedHashMap): the first key is the least
  // recently used.
  final _images = <_PartKey, ui.Image>{};
  final _pending = <_PartKey, Future<void>>{};
  // Keys some prepare call is waiting on or about to clone: never evicted.
  final _pins = <_PartKey, int>{};
  int _bytes = 0;
  bool _disposed = false;

  /// The artboard pixel height for a board whose tallest doll is
  /// [tallestDollHeight] logical px on a [devicePixelRatio] screen: the
  /// tallest doll is sampled 1:1 (or a hair finer), smaller ones are drawn
  /// down from it.
  ///
  /// Rounded up to a multiple of 3, so the 512:768 artboard is a whole
  /// number of pixels wide (`2/3` of the height) and the image layers'
  /// scale and anchor compensation is exact on both axes.
  static int artHeightPxFor({
    required double tallestDollHeight,
    required double devicePixelRatio,
  }) {
    if (!(tallestDollHeight > 0) || !(devicePixelRatio > 0)) {
      throw ArgumentError('the doll height and pixel ratio must be positive');
    }
    final px = (tallestDollHeight * devicePixelRatio).ceil();
    return (px + 2) ~/ 3 * 3;
  }

  /// The first pixel row of the body at [artHeightPx]: the row whose centre
  /// is at or below art y [splitY]. The lid holds the rows above it.
  ///
  /// The split sits on a whole pixel so the parts are disjoint: a lid drawn
  /// over its body at the raster's own size reproduces the closed doll with
  /// no seam of half-covered pixels. It is at most half a pixel from
  /// `splitY · r`.
  static int splitRowPx({
    required int artHeightPx,
    double splitY = SkinTokens.splitY,
  }) {
    final row = (splitY * artHeightPx / DollArt.height - 0.5).ceil();
    return row.clamp(0, artHeightPx);
  }

  /// A clone of the set for [skin] holding [colors] (gold uses the
  /// gray-rewritten masks, never a tint) with [symbols] bodies at
  /// [artHeightPx], rasterized on a miss. [symbolAtlas] draws the belly
  /// symbols; without it the bodies have none (the large mode still draws
  /// its disc and ring). The caller owns the clone.
  ///
  /// Called off the hot path, behind the route transition, and again when
  /// the symbols setting changes (bodies depend on it).
  ///
  /// Throws when the skin can't be rasterized (the caller falls back to
  /// [preparePlaceholder], CLAUDE.md rule 3) and [StateError] after
  /// [dispose].
  Future<DollPartSet> prepare({
    required SkinRasterizer skin,
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
  }) {
    if (skin.manifest.artboard != SkinTokens.artboard) {
      return Future.error(
        ArgumentError.value(
          skin.manifest.artboard,
          'skin',
          'part rasters need the ${SkinTokens.artboard} artboard',
        ),
      );
    }
    return _prepare(
      _SkinArtist(skin, symbolAtlas),
      colors,
      symbols,
      artHeightPx,
    );
  }

  /// The same set drawn by the procedural `PlaceholderDollPainter` (spec
  /// §12.5), with the same split: the rule-3 fallback when the skin can't
  /// load. Its [DollPartSet.skinKey] is [placeholderKey].
  ///
  /// The placeholder's full closed doll is cut on the split row, so its
  /// lid seam is shared by the two parts.
  Future<DollPartSet> preparePlaceholder({
    required Iterable<DollColor> colors,
    required DollSymbols symbols,
    required int artHeightPx,
    SymbolAtlas? symbolAtlas,
  }) => _prepare(_PlaceholderArtist(symbolAtlas), colors, symbols, artHeightPx);

  /// Bytes held by the cache's own handles (RGBA8).
  int get byteSize => _bytes;

  /// Number of images the cache holds.
  int get length => _images.length;

  /// Disposes every cached handle. Clones held by callers stay valid; a
  /// prepare still running rasterizes what it lost again.
  void clear() {
    for (final image in _images.values) {
      image.dispose();
    }
    _images.clear();
    _bytes = 0;
  }

  /// [clear], and the cache is unusable afterwards: [prepare] and
  /// [preparePlaceholder] throw [StateError], and rasterizations still
  /// running dispose their images when they land.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    clear();
  }

  Future<DollPartSet> _prepare(
    _Artist artist,
    Iterable<DollColor> colors,
    DollSymbols symbols,
    int artHeightPx,
  ) async {
    if (_disposed) throw StateError('DollPartRasters used after dispose');
    if (artHeightPx < 1) {
      throw ArgumentError.value(artHeightPx, 'artHeightPx', 'must be ≥ 1');
    }
    final wanted = colors.toSet();
    final ordered = [
      for (final color in DollColor.values)
        if (wanted.contains(color)) color,
    ];
    final skin = artist.skinKey;
    final symbolArt = artist.drawsSymbols && symbols != DollSymbols.none;
    final silhouette = _PartKey.silhouette(skin, artHeightPx);
    final lids = [
      for (final color in ordered) _PartKey.lid(skin, color, artHeightPx),
    ];
    final bodies = [
      for (final color in ordered)
        _PartKey.body(skin, color, symbols, symbolArt, artHeightPx),
    ];
    final keys = [silhouette, ...lids, ...bodies];
    for (final key in keys) {
      _pins[key] = (_pins[key] ?? 0) + 1;
    }
    try {
      // A clear() while waiting drops images this call needs; rasterize
      // them again. Twice in a row means someone clears in a loop.
      for (var attempt = 0; ; attempt++) {
        final missing = [
          for (final key in keys)
            if (!_images.containsKey(key) && !_pending.containsKey(key)) key,
        ];
        if (missing.isNotEmpty) _start(artist, missing, artHeightPx);
        await Future.wait({for (final key in keys) ?_pending[key]});
        if (_disposed) {
          throw StateError('DollPartRasters disposed while preparing');
        }
        if (keys.every(_images.containsKey)) break;
        if (attempt >= 2) {
          throw StateError('DollPartRasters cleared while preparing');
        }
      }
      for (final key in keys) {
        _images[key] = _images.remove(key)!; // most recently used
      }
      return DollPartSet(
        skinKey: skin,
        symbols: symbols,
        artHeightPx: artHeightPx,
        lids: {
          for (var i = 0; i < ordered.length; i++)
            ordered[i]: _images[lids[i]]!.clone(),
        },
        bodies: {
          for (var i = 0; i < ordered.length; i++)
            ordered[i]: _images[bodies[i]]!.clone(),
        },
        silhouette: _images[silhouette]!.clone(),
      );
    } finally {
      // Evict before unpinning, so this call's images survive as the
      // newest set.
      _evict();
      for (final key in keys) {
        final count = _pins[key]! - 1;
        if (count == 0) {
          _pins.remove(key);
        } else {
          _pins[key] = count;
        }
      }
    }
  }

  /// Rasterizes [keys] in one batch (one symbol page, one painter) and
  /// registers it as pending for each of them before anything runs.
  void _start(_Artist artist, List<_PartKey> keys, int artHeightPx) {
    final done = Completer<void>();
    for (final key in keys) {
      _pending[key] = done.future;
    }
    unawaited(_rasterize(artist, keys, artHeightPx, done));
  }

  Future<void> _rasterize(
    _Artist artist,
    List<_PartKey> keys,
    int artHeightPx,
    Completer<void> done,
  ) async {
    try {
      final needsSymbols = keys.any((k) => k.part == _Part.body && k.symbolArt);
      final session = await artist.open(artHeightPx, symbols: needsSymbols);
      final List<ui.Image> images;
      try {
        images = await Future.wait([
          for (final key in keys) session.rasterize(key),
        ], cleanUp: (image) => image.dispose());
      } finally {
        session.close();
      }
      for (var i = 0; i < keys.length; i++) {
        final image = images[i];
        if (_disposed || _images.containsKey(keys[i])) {
          image.dispose();
          continue;
        }
        _images[keys[i]] = image;
        _bytes += _bytesOf(image);
      }
      _unregister(keys, done.future);
      done.complete();
    } on Object catch (error, stack) {
      _unregister(keys, done.future);
      done.completeError(error, stack);
    }
  }

  void _unregister(List<_PartKey> keys, Future<void> job) {
    for (final key in keys) {
      if (identical(_pending[key], job)) _pending.remove(key);
    }
  }

  void _evict() {
    if (_bytes <= maxBytes) return;
    final victims = <_PartKey>[];
    var bytes = _bytes;
    for (final entry in _images.entries) {
      if (bytes <= maxBytes) break;
      if (_pins.containsKey(entry.key)) continue;
      victims.add(entry.key);
      bytes -= _bytesOf(entry.value);
    }
    for (final key in victims) {
      _images.remove(key)!.dispose();
    }
    _bytes = bytes;
  }

  static int _bytesOf(ui.Image image) => image.width * image.height * 4;
}

enum _Part { lid, body, silhouette }

/// One cached image. Fields that don't apply to a part are fixed, so equal
/// images get equal keys.
final class _PartKey {
  _PartKey.lid(this.skin, DollColor color, this.artHeightPx)
    : part = _Part.lid,
      color = color.index,
      symbols = DollSymbols.none,
      symbolArt = false;

  _PartKey.body(
    this.skin,
    DollColor color,
    this.symbols,
    this.symbolArt,
    this.artHeightPx,
  ) : part = _Part.body,
      color = color.index;

  _PartKey.silhouette(this.skin, this.artHeightPx)
    : part = _Part.silhouette,
      color = -1,
      symbols = DollSymbols.none,
      symbolArt = false;

  final String skin;
  final _Part part;

  /// `DollColor.index`, −1 for the silhouette.
  final int color;
  final DollSymbols symbols;

  /// Whether a symbol atlas drew the belly symbol (bodies only).
  final bool symbolArt;
  final int artHeightPx;

  DollColor get dollColor => DollColor.values[color];

  @override
  bool operator ==(Object other) =>
      other is _PartKey &&
      other.skin == skin &&
      other.part == part &&
      other.color == color &&
      other.symbols == symbols &&
      other.symbolArt == symbolArt &&
      other.artHeightPx == artHeightPx;

  @override
  int get hashCode =>
      Object.hash(skin, part, color, symbols, symbolArt, artHeightPx);
}

/// Draws one kind of art (a skin, or the placeholder) into part rasters.
abstract interface class _Artist {
  String get skinKey;

  /// Whether bodies get a symbol image (an atlas is available).
  bool get drawsSymbols;

  /// Gets ready to rasterize at [artHeightPx]; [symbols] asks for the
  /// symbol page too.
  Future<_Session> open(int artHeightPx, {required bool symbols});
}

/// One batch at one height.
abstract interface class _Session {
  Future<ui.Image> rasterize(_PartKey key);

  /// Releases the batch's symbol page or painter. The recorded pictures
  /// keep what they drew alive until they are rasterized.
  void close();
}

/// Rows `[top, bottom)` of a part at [artHeightPx] split at [splitY].
(int, int) _rowsOf(_Part part, int artHeightPx, double splitY) {
  final split = DollPartRasters.splitRowPx(
    artHeightPx: artHeightPx,
    splitY: splitY,
  );
  return switch (part) {
    _Part.lid => (0, split),
    _Part.body => (split, artHeightPx),
    _Part.silhouette => (0, artHeightPx),
  };
}

final class _SkinArtist implements _Artist {
  _SkinArtist(this.skin, this.atlas);

  final SkinRasterizer skin;
  final SymbolAtlas? atlas;

  @override
  String get skinKey => skin.cacheKey;

  @override
  bool get drawsSymbols => atlas != null;

  @override
  Future<_Session> open(int artHeightPx, {required bool symbols}) async {
    final atlas = this.atlas;
    final page = symbols && atlas != null
        ? await atlas.obtain(artHeightPx)
        : null;
    return _SkinSession(skin, atlas, page, artHeightPx);
  }
}

/// Mirrors `SvgSkinRenderer`'s layer order and symbol drawing, so a part
/// set drawn at its own height equals the SVG renderer outside the split
/// band (m2-lottie-design §17).
final class _SkinSession implements _Session {
  _SkinSession(this.skin, this.atlas, this.page, this.artHeightPx);

  final SkinRasterizer skin;
  final SymbolAtlas? atlas;
  final SymbolAtlasPage? page;
  final int artHeightPx;

  @override
  Future<ui.Image> rasterize(_PartKey key) {
    final (top, bottom) = _rowsOf(key.part, artHeightPx, skin.manifest.splitY);
    return skin.rasterizeArtboard(
      artHeightPx,
      rowTop: top,
      rowBottom: bottom,
      paint: (canvas, layer) {
        switch (key.part) {
          case _Part.silhouette:
            layer(SkinLayer.shadow);
            layer(SkinLayer.silhouette);
          case _Part.lid:
            final swatch = DollPalette.of(key.dollColor);
            switch (swatch.tint) {
              case ModulateTint(:final color):
                layer(SkinLayer.lidMask, tint: _modulate(color));
              case GradientMapTint():
                layer(SkinLayer.goldLidMask);
            }
            layer(SkinLayer.lidOverlay);
          case _Part.body:
            final swatch = DollPalette.of(key.dollColor);
            layer(SkinLayer.shadow);
            switch (swatch.tint) {
              case ModulateTint(:final color):
                layer(SkinLayer.bottomMask, tint: _modulate(color));
              case GradientMapTint():
                layer(SkinLayer.goldBottomMask);
            }
            layer(SkinLayer.bottomDetail);
            _paintSymbol(canvas, key.symbols, swatch);
            layer(SkinLayer.bodyShine);
        }
      },
    );
  }

  void _paintSymbol(ui.Canvas canvas, DollSymbols mode, DollSwatch swatch) {
    if (mode == DollSymbols.none) return;
    final anchor = skin.manifest.symbolAnchor;
    if (mode == DollSymbols.large) {
      final disc = DollArt.ellipsePath(
        TokenEllipse(
          cx: anchor.dx,
          cy: anchor.dy,
          rx: SkinTokens.badgeRadius,
          ry: SkinTokens.badgeRadius,
        ),
      );
      canvas
        ..drawPath(disc, ui.Paint()..color = SkinTokens.badgeFill)
        ..drawPath(
          disc,
          ui.Paint()
            ..style = ui.PaintingStyle.stroke
            ..strokeWidth = SkinTokens.badgeStroke
            ..color = swatch.ink,
        );
    }
    final atlas = this.atlas;
    final page = this.page;
    if (atlas == null || page == null) return;
    final index = atlas.indexOf(swatch.symbol);
    if (index < 0) return;
    final geometry = atlas.geometry;
    final large = mode == DollSymbols.large;
    // Atlas cells are laid out for the atlas geometry; a skin whose
    // skin.json moves or resizes the symbol box gets the cell moved and
    // scaled to match, as `SvgSkinRenderer` does (the identity for every
    // shipped skin).
    final ratio = large ? 1.0 : skin.manifest.symbolSize / geometry.subtleSize;
    final cell = large ? page.largeDst : page.subtleDst;
    final from = geometry.anchor;
    canvas.drawImageRect(
      page.image,
      large ? page.largeSrc(index) : page.subtleSrc(index),
      ui.Rect.fromLTRB(
        anchor.dx + (cell.left - from.dx) * ratio,
        anchor.dy + (cell.top - from.dy) * ratio,
        anchor.dx + (cell.right - from.dx) * ratio,
        anchor.dy + (cell.bottom - from.dy) * ratio,
      ),
      ui.Paint()
        ..filterQuality = ui.FilterQuality.medium
        ..colorFilter = ui.ColorFilter.mode(
          large
              ? swatch.ink
              : swatch.ink.withValues(alpha: DollArt.subtleSymbolOpacity),
          ui.BlendMode.srcIn,
        ),
    );
  }

  static ui.ColorFilter _modulate(ui.Color color) =>
      ui.ColorFilter.mode(color, ui.BlendMode.modulate);

  @override
  void close() => page?.dispose();
}

final class _PlaceholderArtist implements _Artist {
  _PlaceholderArtist(this.atlas);

  final SymbolAtlas? atlas;

  @override
  String get skinKey => DollPartRasters.placeholderKey;

  @override
  bool get drawsSymbols => atlas != null;

  @override
  Future<_Session> open(int artHeightPx, {required bool symbols}) async {
    final painter = PlaceholderDollPainter(symbols: symbols ? atlas : null);
    try {
      // At pixel ratio 1 the painter's symbol page is the artboard height.
      await painter.prepare(
        heights: [artHeightPx.toDouble()],
        devicePixelRatio: 1,
      );
    } on Object {
      painter.dispose();
      rethrow;
    }
    return _PlaceholderSession(painter, artHeightPx);
  }
}

final class _PlaceholderSession implements _Session {
  _PlaceholderSession(this.painter, this.artHeightPx);

  final PlaceholderDollPainter painter;
  final int artHeightPx;

  @override
  Future<ui.Image> rasterize(_PartKey key) async {
    final (top, bottom) = _rowsOf(key.part, artHeightPx, SkinTokens.splitY);
    final r = artHeightPx / DollArt.height;
    final width = (DollArt.width * r).round();
    // The closed full doll, cut on the split row: the lid gets the upper
    // body, head, face and the top half of the seam; the body the shadow,
    // lower body, symbol and the seam's lower half.
    final params = DollPaintParams()
      ..height = artHeightPx.toDouble()
      ..baseX = DollArt.base.dx * r
      ..baseY = DollArt.base.dy * r
      ..silhouette = key.part == _Part.silhouette
      ..symbols = key.symbols;
    if (key.part != _Part.silhouette) params.color = key.dollColor;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    painter.paint(canvas, params);
    eraseRowsOutside(canvas, width, artHeightPx, top, bottom);
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(width, artHeightPx);
    } finally {
      picture.dispose();
    }
  }

  @override
  void close() => painter.dispose();
}
