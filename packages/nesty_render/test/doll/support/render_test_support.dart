// Shared helpers for the doll/skin raster tests: a file-backed AssetBundle
// over the synced game assets, image capture and pixel comparison.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:nesty_render/nesty_render.dart';
import 'package:nesty_render/svg_tools.dart';

/// The game's synced assets (written by `sync_design_assets`), read from the
/// workspace so these tests exercise the files the app ships.
const gameAssetsDir = '../../apps/game/assets';

/// The design's reference renders, rasterized as the goldens' expectation.
const classicRendersDir = '../../design/skins/classic/renders';

/// Serves `assets/…` keys from [root] on disk, like `rootBundle` would.
final class FileAssetBundle extends CachingAssetBundle {
  FileAssetBundle([this.root = gameAssetsDir]);

  final String root;

  @override
  Future<ByteData> load(String key) async {
    const prefix = 'assets/';
    final path = key.startsWith(prefix) ? key.substring(prefix.length) : key;
    final file = File('$root/$path');
    if (!file.existsSync()) {
      throw FlutterError('Unable to load asset: "$key".');
    }
    final bytes = file.readAsBytesSync();
    return ByteData.sublistView(bytes);
  }
}

/// Reads a design reference render, without its C2PA `<metadata>`.
String readRender(String name) =>
    stripSvgMetadata(File('$classicRendersDir/$name.svg').readAsStringSync());

/// Raw premultiplied RGBA of [image].
Future<Uint8List> rgbaOf(ui.Image image) async {
  final data = await image.toByteData();
  return data!.buffer.asUint8List();
}

/// Records [draw] into a [width] × [height] image.
Future<ui.Image> capture(
  int width,
  int height,
  void Function(ui.Canvas canvas) draw,
) {
  final recorder = ui.PictureRecorder();
  draw(ui.Canvas(recorder));
  final picture = recorder.endRecording();
  return picture.toImage(width, height).whenComplete(picture.dispose);
}

/// How far two same-sized RGBA buffers are apart.
final class ImageDiff {
  ImageDiff(Uint8List a, Uint8List b, {this.tolerance = 8})
    : assert(a.length == b.length) {
    var within = 0;
    var total = 0;
    var worst = 0;
    for (var i = 0; i < a.length; i += 4) {
      var pixelMax = 0;
      for (var c = 0; c < 4; c++) {
        final d = (a[i + c] - b[i + c]).abs();
        total += d;
        if (d > pixelMax) pixelMax = d;
      }
      if (pixelMax <= tolerance) within++;
      if (pixelMax > worst) worst = pixelMax;
    }
    pixels = a.length ~/ 4;
    withinFraction = within / pixels;
    meanDiff = total / a.length;
    maxDiff = worst;
  }

  final int tolerance;
  late final int pixels;

  /// Share of pixels whose every channel is within [tolerance] / 255.
  late final double withinFraction;

  /// Mean absolute channel difference, in 1/255 steps.
  late final double meanDiff;

  late final int maxDiff;

  @override
  String toString() =>
      'within $tolerance: ${(withinFraction * 100).toStringAsFixed(3)} %, '
      'mean ${meanDiff.toStringAsFixed(3)}/255, max $maxDiff';
}

/// The pixels of [rect] (whole pixels, clamped to the image) cut out of a
/// [width]-wide RGBA buffer, for comparing one region of two images.
Uint8List cropRgba(Uint8List rgba, int width, ui.Rect rect) {
  final height = rgba.length ~/ (4 * width);
  final left = rect.left.floor().clamp(0, width);
  final right = rect.right.ceil().clamp(0, width);
  final top = rect.top.floor().clamp(0, height);
  final bottom = rect.bottom.ceil().clamp(0, height);
  final out = Uint8List((right - left) * (bottom - top) * 4);
  var at = 0;
  for (var y = top; y < bottom; y++) {
    final row = (y * width + left) * 4;
    out.setRange(at, at + (right - left) * 4, rgba, row);
    at += (right - left) * 4;
  }
  return out;
}

/// Loads the bundled classic skin through the real loader.
Future<SkinSource> loadClassic() =>
    AssetBundleSkinLoader(bundle: FileAssetBundle()).load('classic');

/// Loads the bundled symbols through the real loader.
Future<SymbolAtlas> loadSymbols() => SymbolAtlas.load(FileAssetBundle());
