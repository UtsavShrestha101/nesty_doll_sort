import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart' show ColorFilter;
import 'package:flutter_svg/flutter_svg.dart' show PictureInfo;
import 'package:nesty_render/src/palette/doll_palette.dart';
import 'package:nesty_render/src/raster/svg_raster.dart';
import 'package:nesty_render/src/skin/part_rows.dart';
import 'package:nesty_render/src/skin/skin_image_set.dart';
import 'package:nesty_render/src/skin/skin_layer.dart';
import 'package:nesty_render/src/skin/skin_loader.dart';
import 'package:nesty_render/src/skin/skin_manifest.dart';
import 'package:nesty_render/src/skin/svg/svg_color_rewriter.dart';
import 'package:nesty_render/src/svg_tools/svg_validator.dart';

/// Draws one [SkinLayer] from a skin's parsed vector pictures in art units,
/// through a colour-filter layer when [tint] is given. Handed to
/// [SkinRasterizer.rasterizeArtboard]'s `paint` callback, and valid only
/// while that callback runs.
typedef SkinLayerPainter = void Function(SkinLayer layer, {ColorFilter? tint});

/// Turns a [SkinSource] into [SkinImageSet]s (spec §12.2, CLAUDE.md rule 8).
///
/// The layer SVGs are parsed once into pictures, on first use. A crop probe
/// then rasterizes every layer small ([probeHeightPx] for the full artboard
/// height), finds its opaque bounds and pads them by [cropPaddingPx] probe
/// pixels; every later raster covers only that box. Cropping keeps a DPR 3
/// board's doll layers at a few MB instead of 9 full-artboard images per
/// height (design doc §1 "Performance budget").
///
/// Gold's masks are separate rasters with their grays rewritten through the
/// ramp ([SvgColorRewriter]), since a gradient map cannot be a draw-time
/// colour filter (D19).
///
/// [rasterizeArtboard] draws whole-artboard images from the same parsed
/// layers without the crop probe: the game's doll part rasters
/// (`DollPartRasters`, docs/plans/m2-lottie-design.md §4).
final class SkinRasterizer {
  SkinRasterizer(this.source, {this.probeHeightPx = 96, this.cropPaddingPx = 2})
    : assert(probeHeightPx > 0),
      assert(cropPaddingPx >= 0);

  final SkinSource source;
  final int probeHeightPx;
  final int cropPaddingPx;

  SkinManifest get manifest => source.manifest;

  /// Cache identity: skin id and version.
  String get cacheKey => manifest.cacheKey;

  Future<_Prepared>? _parsed;
  Future<_Prepared>? _prepared;
  bool _disposed = false;

  /// Parses the layers and runs the crop probe, if not done yet. Optional:
  /// [rasterize] does it on first use.
  Future<void> ensureReady() => _prepare();

  /// The probed crop of every layer in art units (null: the layer is
  /// empty). Exposed for tests and tooling.
  Future<Map<SkinLayer, ui.Rect?>> cropRects() async {
    final prepared = await _prepare();
    return {
      for (final layer in SkinLayer.values) layer: prepared.crops[layer.index],
    };
  }

  /// Rasterizes every layer so the artboard height is [artHeightPx]
  /// physical pixels (a logical doll height × DPR, rounded).
  Future<SkinImageSet> rasterize(int artHeightPx) async {
    if (artHeightPx < 1) {
      throw ArgumentError.value(artHeightPx, 'artHeightPx', 'must be ≥ 1');
    }
    final prepared = await _prepare();
    // The pictures are drawn synchronously below; after a dispose they may
    // already be gone.
    if (_disposed) throw StateError('SkinRasterizer used after dispose');
    final scale = artHeightPx / manifest.artboard.height;
    final layers = await Future.wait([
      for (final layer in SkinLayer.values)
        _rasterizeLayer(prepared, layer, scale),
    ]);
    final set = SkinImageSet(
      skinKey: cacheKey,
      artHeightPx: artHeightPx,
      pxPerArt: scale,
      layers: layers,
    );
    if (_disposed) {
      set.dispose();
      throw StateError('SkinRasterizer disposed while rasterizing');
    }
    return set;
  }

  /// Rasterizes one whole-artboard image of `widthPx × artHeightPx` px,
  /// `widthPx = round(artboard.width · r)` with `r = artHeightPx /
  /// artboard.height`, for `DollPartRasters` (m2-lottie-design §4).
  ///
  /// [paint] draws in art units (the canvas is scaled by `r`) and calls its
  /// `layer` argument to draw one [SkinLayer] from the parsed vector
  /// pictures, through a [ColorFilter] layer when given a `tint` (the flat
  /// colours' `BlendMode.modulate`: linear in the gray, so it equals
  /// `SvgSkinRenderer`'s draw-time tint of the gray raster).
  ///
  /// Only the pixel rows `[rowTop, rowBottom)` are kept, cut on whole
  /// pixels: the hard lid/body split, so the two parts never share a pixel.
  ///
  /// Needs the parsed layers only, not the crop probe.
  Future<ui.Image> rasterizeArtboard(
    int artHeightPx, {
    required void Function(ui.Canvas canvas, SkinLayerPainter layer) paint,
    int rowTop = 0,
    int? rowBottom,
  }) async {
    if (artHeightPx < 1) {
      throw ArgumentError.value(artHeightPx, 'artHeightPx', 'must be ≥ 1');
    }
    final bottom = rowBottom ?? artHeightPx;
    if (rowTop < 0 || bottom > artHeightPx || rowTop > bottom) {
      throw RangeError('rows [$rowTop, $bottom) are not inside the raster');
    }
    final parsed = await _parse();
    // The pictures are drawn synchronously below; after a dispose they may
    // already be gone.
    if (_disposed) throw StateError('SkinRasterizer used after dispose');
    final artboard = manifest.artboard;
    final scale = artHeightPx / artboard.height;
    final width = math.max(1, (artboard.width * scale).round());
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder)
      ..save()
      ..scale(scale);
    void layer(SkinLayer layer, {ColorFilter? tint}) {
      if (tint != null) canvas.saveLayer(null, ui.Paint()..colorFilter = tint);
      _drawParts(canvas, parsed.parts[layer.index]);
      if (tint != null) canvas.restore();
    }

    paint(canvas, layer);
    canvas.restore();
    eraseRowsOutside(canvas, width, artHeightPx, rowTop, bottom);
    final picture = recorder.endRecording();
    try {
      return await picture.toImage(width, artHeightPx);
    } finally {
      picture.dispose();
    }
  }

  /// Frees the parsed pictures. Image sets already made stay valid.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _parsed?.then((p) => p.dispose(), onError: (Object _) {});
  }

  /// [rasterizePictures]' drawing, onto a canvas already in art units.
  static void _drawParts(ui.Canvas canvas, List<SvgRasterPart> parts) {
    for (final part in parts) {
      final layered = part.opacity < 1 || part.colorFilter != null;
      if (layered) {
        final paint = ui.Paint()
          ..color = ui.Color.fromRGBO(0, 0, 0, part.opacity.clamp(0, 1));
        if (part.colorFilter case final filter?) paint.colorFilter = filter;
        canvas.saveLayer(null, paint);
      }
      canvas.drawPicture(part.picture);
      if (layered) canvas.restore();
    }
  }

  Future<SkinLayerImage?> _rasterizeLayer(
    _Prepared prepared,
    SkinLayer layer,
    double scale,
  ) async {
    final crop = prepared.crops[layer.index];
    if (crop == null) return null;
    // Whole-pixel edges: the image's pixel grid is the artboard's pixel grid
    // at this scale, so drawing it back is a 1:1 copy at the prepared size.
    final left = (crop.left * scale).floor();
    final top = (crop.top * scale).floor();
    final right = (crop.right * scale).ceil();
    final bottom = (crop.bottom * scale).ceil();
    final image = await rasterizePictures(
      prepared.parts[layer.index],
      width: right - left,
      height: bottom - top,
      scale: scale,
      left: left.toDouble(),
      top: top.toDouble(),
    );
    return SkinLayerImage(
      image: image,
      dst: ui.Rect.fromLTRB(
        left / scale,
        top / scale,
        right / scale,
        bottom / scale,
      ),
    );
  }

  /// Parsed and probed: what [rasterize] and [cropRects] need.
  Future<_Prepared> _prepare() {
    if (_disposed) {
      return Future.error(StateError('SkinRasterizer used after dispose'));
    }
    return _prepared ??= _parse().then((prepared) async {
      await _probe(prepared);
      return prepared;
    });
  }

  /// Parsed only: what [rasterizeArtboard] needs.
  Future<_Prepared> _parse() {
    if (_disposed) {
      return Future.error(StateError('SkinRasterizer used after dispose'));
    }
    return _parsed ??= _parseLayers();
  }

  Future<_Prepared> _parseLayers() async {
    final gold = DollPalette.values.firstWhere((s) => s.usesGradientMap).tint;
    final layers = source.layers;
    final sources = <String, String>{
      for (final id in skinGroupIds) id: layers[id],
      for (final id in _goldGroups)
        _goldKey(id): SvgColorRewriter.rewriteGrays(layers[id], gold.mapGray),
    };
    final keys = sources.keys.toList();
    final infos = await Future.wait([
      for (final key in keys) loadSvgPicture(sources[key]!),
    ]);
    final pictures = <String, PictureInfo>{
      for (var i = 0; i < keys.length; i++) keys[i]: infos[i],
    };
    final prepared = _Prepared(pictures);
    try {
      for (final entry in pictures.entries) {
        if (entry.value.size != manifest.artboard) {
          throw StateError(
            'Layer ${entry.key} is ${entry.value.size}, expected the '
            '${manifest.artboard} artboard',
          );
        }
      }
      for (final layer in SkinLayer.values) {
        prepared.parts.add(_partsFor(layer, pictures));
      }
    } on Object {
      prepared.dispose();
      rethrow;
    }
    return prepared;
  }

  List<SvgRasterPart> _partsFor(
    SkinLayer layer,
    Map<String, PictureInfo> pictures,
  ) {
    ui.Picture picture(String key) => pictures[key]!.picture;
    return switch (layer) {
      SkinLayer.goldBottomMask || SkinLayer.goldLidMask => [
        for (final id in layer.groups) SvgRasterPart(picture(_goldKey(id))),
      ],
      // design/README.md "Doll rendering" step 5; wood × gray is linear, so
      // a modulate layer equals the JS's per-value `mul(WOOD, g)` rewrite.
      SkinLayer.silhouette => [
        SvgRasterPart(picture('bottom_mask'), colorFilter: _woodFilter),
        SvgRasterPart(picture('top_mask'), colorFilter: _woodFilter),
        SvgRasterPart(picture('shine_top'), opacity: _silhouetteShine),
        SvgRasterPart(picture('shine_bottom'), opacity: _silhouetteShine),
      ],
      _ => [for (final id in layer.groups) SvgRasterPart(picture(id))],
    };
  }

  Future<void> _probe(_Prepared prepared) async {
    final artboard = manifest.artboard;
    final scale = probeHeightPx / artboard.height;
    final width = (artboard.width * scale).ceil();
    final pad = cropPaddingPx;
    for (final layer in SkinLayer.values) {
      final twin = _probeTwin[layer];
      if (twin != null) {
        // Same geometry, different colours: reuse the gray mask's box.
        prepared.crops.add(prepared.crops[twin.index]);
        continue;
      }
      final image = await rasterizePictures(
        prepared.parts[layer.index],
        width: width,
        height: probeHeightPx,
        scale: scale,
      );
      final bounds = await alphaBounds(image);
      image.dispose();
      prepared.crops.add(
        bounds == null
            ? null
            : ui.Rect.fromLTRB(
                math.max(0, (bounds.left - pad) / scale),
                math.max(0, (bounds.top - pad) / scale),
                math.min(artboard.width, (bounds.right + pad) / scale),
                math.min(artboard.height, (bounds.bottom + pad) / scale),
              ),
      );
    }
  }

  static const _goldGroups = ['bottom_mask', 'top_mask'];
  static String _goldKey(String id) => 'gold:$id';
  static const _probeTwin = {
    SkinLayer.goldBottomMask: SkinLayer.bottomMask,
    SkinLayer.goldLidMask: SkinLayer.lidMask,
  };
  static const _woodFilter = ColorFilter.mode(
    DollPalette.wood,
    ui.BlendMode.modulate,
  );

  /// design/README.md "Doll rendering" step 5: "set shine to 45%".
  static const _silhouetteShine = 0.45;
}

final class _Prepared {
  _Prepared(this.pictures);

  final Map<String, PictureInfo> pictures;
  final List<List<SvgRasterPart>> parts = [];
  final List<ui.Rect?> crops = [];

  void dispose() {
    for (final info in pictures.values) {
      info.picture.dispose();
    }
  }
}
