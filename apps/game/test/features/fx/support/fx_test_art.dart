import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:lottie/lottie.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/features/fx/fx_drawable.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_images.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

/// The shipped export of [id] (`flutter test` runs in apps/game), parsed the
/// way the game parses it: `fromBytes`, no images.
Future<LottieComposition> shipped(FxId id) =>
    LottieComposition.fromBytes(File(id.assetPath).readAsBytesSync());

final Map<FxId, LottieComposition> _compositions = {};

/// [shipped], parsed once per test file.
Future<LottieComposition> shippedOnce(FxId id) async =>
    _compositions[id] ??= await shipped(id);

/// A clip of [id] over the shipped composition, drawing [source]'s art.
Future<FxDrawable> shippedDrawable(
  FxId id, {
  FxImageSource? source,
  ui.Image? blank,
}) async => FxDrawable(
  await shippedOnce(id),
  spec: fxSpecOf(id),
  images: FxImages(source: source, blank: blank ?? transparentPixel),
);

/// A 1×1 transparent image (`FxLibrary.blank`).
final ui.Image transparentPixel = () {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder);
  return recorder.endRecording().toImageSync(1, 1);
}();

/// An RGBA snapshot of what [draw] paints on a [width]×[height] logical
/// canvas at [pixelRatio].
final class Snapshot {
  Snapshot(this.width, this.height, this.bytes);

  final int width;
  final int height;
  final Uint8List bytes;

  int alphaAt(int x, int y) => bytes[(y * width + x) * 4 + 3];

  /// (r, g, b, a) at pixel (x, y).
  (int, int, int, int) at(int x, int y) {
    final i = (y * width + x) * 4;
    return (bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3]);
  }

  /// The box of pixels with alpha above [threshold], in pixels
  /// (right/bottom exclusive), or null when empty.
  Rect? alphaBounds({int threshold = 8}) =>
      boundsWhere((x, y) => alphaAt(x, y) > threshold);

  Rect? boundsWhere(bool Function(int x, int y) test) {
    var minX = width, minY = height, maxX = -1, maxY = -1;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (!test(x, y)) continue;
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
    if (maxX < 0) return null;
    return Rect.fromLTRB(
      minX.toDouble(),
      minY.toDouble(),
      maxX + 1.0,
      maxY + 1.0,
    );
  }

  /// The mean position of pixels matching [test], or null.
  Offset? centroidWhere(bool Function(int r, int g, int b, int a) test) {
    var sx = 0.0, sy = 0.0, n = 0;
    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        final i = (y * width + x) * 4;
        if (!test(bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3])) {
          continue;
        }
        sx += x;
        sy += y;
        n++;
      }
    }
    return n == 0 ? null : Offset(sx / n, sy / n);
  }

  bool pixelDiffers(Snapshot other, int i, int tolerance) {
    for (var c = 0; c < 4; c++) {
      if ((bytes[i + c] - other.bytes[i + c]).abs() > tolerance) return true;
    }
    return false;
  }

  /// How many pixels differ from [other] by more than [tolerance] in any
  /// channel.
  int differingPixels(Snapshot other, {int tolerance = 8}) {
    var n = 0;
    for (var i = 0; i < bytes.length; i += 4) {
      if (pixelDiffers(other, i, tolerance)) n++;
    }
    return n;
  }
}

Future<Snapshot> snapshot(
  double width,
  double height,
  void Function(ui.Canvas canvas) draw, {
  double pixelRatio = 1,
}) async {
  final w = (width * pixelRatio).ceil();
  final h = (height * pixelRatio).ceil();
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)..scale(pixelRatio);
  draw(canvas);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(w, h);
  final data = await image.toByteData();
  image.dispose();
  picture.dispose();
  return Snapshot(w, h, data!.buffer.asUint8List());
}

/// [clip] at [frame] (seeked: not a rest pose), at [pixelRatio].
Future<Snapshot> snapshotDrawable(
  FxDrawable clip,
  double frame, {
  double pixelRatio = 1,
}) {
  clip.player.seek(frame);
  return snapshot(
    clip.spec.width,
    clip.spec.height,
    clip.draw,
    pixelRatio: pixelRatio,
  );
}

/// Draws the same soft art at any resolution: two radial blobs in the
/// declared box of an image slot, so a raster at [factor] × the declared
/// size is "the same image" at another resolution (no hard edges to
/// resample). The blobs are asymmetric, so a flip or offset shows.
ui.Image blobArt(
  double declaredWidth,
  double declaredHeight,
  double factor, {
  required Color primary,
  required Color secondary,
}) {
  final w = (declaredWidth * factor).round();
  final h = (declaredHeight * factor).round();
  final recorder = ui.PictureRecorder();
  final canvas = ui.Canvas(recorder)
    ..scale(w / declaredWidth, h / declaredHeight);
  void blob(Offset centre, double radius, Color color) {
    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..shader = ui.Gradient.radial(centre, radius, [
          color,
          color.withValues(alpha: 0),
        ]),
    );
  }

  final m = declaredWidth < declaredHeight ? declaredWidth : declaredHeight;
  blob(Offset(declaredWidth * 0.36, declaredHeight * 0.38), m * 0.34, primary);
  blob(
    Offset(declaredWidth * 0.66, declaredHeight * 0.70),
    m * 0.24,
    secondary,
  );
  return recorder.endRecording().toImageSync(w, h);
}

/// A solid rectangle [inset] from each edge of a [width]×[height] image.
ui.Image insetBox(int width, int height, Color color, {double inset = 0}) {
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder).drawRect(
    Rect.fromLTRB(inset, inset, width - inset, height - inset),
    Paint()..color = color,
  );
  return recorder.endRecording().toImageSync(width, height);
}

const _roleColors = {
  FxRole.doll: Color(0xFFE53935),
  FxRole.mover: Color(0xFF1E88E5),
  FxRole.target: Color(0xFF43A047),
};

/// An [FxImageSource] of [blobArt] rasters at [factor] × every doll slot's
/// declared size and [pieceFactor] × every other slot's, coloured by role
/// (and by colour, so a colour change swaps rasters). Records the slots it
/// was asked for.
final class BlobArt implements FxImageSource {
  BlobArt(this.factor, {double? pieceFactor})
    : pieceFactor = pieceFactor ?? factor;

  final double factor;
  final double pieceFactor;
  final Map<(FxImageSlot, DollColor?), FxRaster> _rasters = {};
  final Set<FxImageSlot> requested = {};

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) {
    final role = slot.role;
    DollColor? color;
    if (role != null) {
      color = request.colorOf(role);
      if (color == null) return null;
    } else if (slot == FxImageSlot.unlockSymbol) {
      color = request.unlockColor;
      if (color == null) return null;
    }
    requested.add(slot);
    return _rasters[(slot, color)] ??= _make(slot, color);
  }

  FxRaster _make(FxImageSlot slot, DollColor? color) {
    final primary = switch (slot.role) {
      final FxRole role => _roleColors[role]!,
      null => const Color(0xFFFFB300),
    };
    // Lid and body of one role differ; so do two colours of one role.
    final shift = (slot.part?.index ?? 0) * 40 + (color?.index ?? 0) * 9;
    final secondary = Color.fromARGB(255, shift % 256, 40, 200 - shift % 150);
    return FxRaster(
      blobArt(
        slot.declaredWidth,
        slot.declaredHeight,
        slot.isDoll ? factor : pieceFactor,
        primary: primary,
        secondary: secondary,
      ),
      scale: slot.isDoll ? factor : pieceFactor,
    );
  }
}

/// An [FxImageSource] that serves one fixed raster per slot.
final class FixedArt implements FxImageSource {
  FixedArt(this.rasters);

  final Map<FxImageSlot, FxRaster> rasters;
  final List<FxImageSlot> requests = [];

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) {
    final role = slot.role;
    if (role != null && request.colorOf(role) == null) return null;
    requests.add(slot);
    return rasters[slot];
  }
}
