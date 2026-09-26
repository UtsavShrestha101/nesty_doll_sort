import 'dart:math' as math;
import 'dart:ui' as ui show Image;
import 'dart:ui' show Canvas, Color, FilterQuality, Offset, Paint, Rect, Size;

import 'package:flutter/foundation.dart'
    show ChangeNotifier, debugPrint, immutable;
import 'package:flutter/rendering.dart' show CustomPainter;
import 'package:flutter/services.dart' show AssetBundle;
import 'package:flutter_svg/flutter_svg.dart' show PictureInfo;
import 'package:nesty_render/src/raster/svg_raster.dart';
import 'package:nesty_render/src/theme/chapter_theme.dart';

/// Where the background art lands on a screen: scaled to cover it and
/// anchored top-centre (NestyBoard:257, `center top/390px auto`; at the
/// 390×844 reference the art's 390 × 845.3 already covers the screen).
@immutable
final class ThemeCover {
  const ThemeCover({required this.scale, required this.left});

  /// Fits [art] (the SVG's size) over [screen]: `max(W/aw, H/ah)`, centred
  /// horizontally, top-aligned, so the 1080×1920 safe area of the art
  /// (design/README.md) stays in view and overflow is cut at the bottom and
  /// the sides.
  factory ThemeCover.of(Size art, Size screen) {
    final scale = math.max(
      screen.width / art.width,
      screen.height / art.height,
    );
    return ThemeCover(
      scale: scale,
      left: (screen.width - art.width * scale) / 2,
    );
  }

  /// Logical px per art unit.
  final double scale;

  /// Where the art's left edge lands (≤ 0: cut equally on both sides).
  final double left;

  @override
  bool operator ==(Object other) =>
      other is ThemeCover && other.scale == scale && other.left == left;

  @override
  int get hashCode => Object.hash(scale, left);
}

/// The chapter background behind the gameplay screen (spec §12.4, render §1
/// "theme_background"): the theme's SVG rasterized once, exactly at the
/// screen's size, over the theme's fallback colour.
///
/// * The raster's pixel ratio is the device's, capped at [maxPixelRatio]
///   (2). A full-screen painting gains little past 2×, and at 390×844 that
///   is one 780×1688 image, 5.3 MB (render §1 "Performance budget").
/// * It holds one image at a time. [show] with a new theme or size keeps
///   the current image on screen until the new one is ready, then disposes
///   it, so both exist only while the new one is being rasterized. Only the
///   latest request is kept; an older raster that finishes late is dropped.
/// * Offline-first (CLAUDE.md rule 3): the art is bundled, and if it fails
///   the fallback colour stays and the error is reported, never thrown.
///
/// Listeners are told when the image or the colour changes. Draw it with
/// [paint], a [ThemeBackgroundPainter], or a `RawImage` of [image] (cover,
/// top-centre) over a box of [color].
final class ThemeBackground extends ChangeNotifier {
  /// Reads `<basePath>/<id>/background.svg` from [bundle]: the game's
  /// `assets/themes/`.
  ThemeBackground({
    required AssetBundle bundle,
    String basePath = 'assets/themes',
    double maxPixelRatio = 2,
    void Function(Object error, StackTrace stack)? onError,
  }) : this.fromLoader(
         (theme) => bundle.loadString(theme.assetKey(basePath), cache: false),
         maxPixelRatio: maxPixelRatio,
         onError: onError,
       );

  /// Reads each theme's SVG with [loadSvg] (tests, the admin's uploads).
  ThemeBackground.fromLoader(
    this._loadSvg, {
    this.maxPixelRatio = 2,
    void Function(Object error, StackTrace stack)? onError,
  }) : assert(maxPixelRatio > 0),
       _onError = onError;

  /// The highest pixel ratio the background is rasterized at.
  final double maxPixelRatio;

  final Future<String> Function(ChapterTheme theme) _loadSvg;
  final void Function(Object error, StackTrace stack)? _onError;

  final Paint _fill = Paint();
  final Paint _imagePaint = Paint()..filterQuality = FilterQuality.low;

  ChapterTheme? _requested;
  _Raster? _shown;
  _Key? _inFlight;
  Future<void>? _inFlightFuture;
  ChapterTheme? _pictureTheme;
  PictureInfo? _picture;
  int _generation = 0;
  bool _disposed = false;

  /// The theme of the latest [show], or null before the first.
  ChapterTheme? get theme => _requested;

  /// The theme of the image on screen (it lags [theme] while rasterizing).
  ChapterTheme? get shownTheme => _shown?.key.theme;

  /// The fallback colour to fill behind [image]: the shown image's theme's,
  /// else the requested theme's, else ch01's.
  Color get color =>
      (_shown?.key.theme ?? _requested ?? ChapterTheme.ch01).fallbackColor;

  /// The background raster, exactly [imageSize] logical px at
  /// [imagePixelRatio], or null until the first [show] completes.
  ui.Image? get image => _shown?.image;

  /// The logical screen size [image] was rasterized for.
  Size? get imageSize => _shown?.key.size;

  /// The pixel ratio [image] was rasterized at.
  double? get imagePixelRatio => _shown?.key.pixelRatio;

  /// Bytes held by [image] (RGBA8).
  int get byteSize {
    final image = _shown?.image;
    return image == null ? 0 : image.width * image.height * 4;
  }

  /// The pixel ratio a screen of [devicePixelRatio] is rasterized at:
  /// capped at [maxPixelRatio].
  double pixelRatioFor(double devicePixelRatio) =>
      math.min(devicePixelRatio, maxPixelRatio);

  /// The raster size for a [screen] of [devicePixelRatio], in px.
  ({int width, int height}) pixelSizeFor(Size screen, double devicePixelRatio) {
    final ratio = pixelRatioFor(devicePixelRatio);
    return (
      width: math.max(1, (screen.width * ratio).round()),
      height: math.max(1, (screen.height * ratio).round()),
    );
  }

  /// Shows [theme] on a screen of [size] (logical px) and
  /// [devicePixelRatio]. Call it when the chapter, the selected theme or
  /// the screen size changes; it does nothing when that raster is already
  /// shown or on its way. Completes when the image is on screen, or when a
  /// newer request replaced this one; never throws for bad art.
  Future<void> show(
    ChapterTheme theme, {
    required Size size,
    required double devicePixelRatio,
  }) {
    if (_disposed) throw StateError('ThemeBackground used after dispose');
    if (!devicePixelRatio.isFinite || devicePixelRatio <= 0) {
      throw ArgumentError.value(
        devicePixelRatio,
        'devicePixelRatio',
        'must be positive',
      );
    }
    final key = _Key(theme, size, pixelRatioFor(devicePixelRatio));
    final inFlight = _inFlightFuture;
    if (_inFlight == key && inFlight != null) return inFlight;
    final colorBefore = color;
    _requested = theme;
    // A newer request always wins: whatever is still rasterizing is dropped
    // when it lands (its generation is stale).
    final generation = ++_generation;
    _inFlight = null;
    _inFlightFuture = null;
    if (_shown?.key == key) {
      if (color != colorBefore) notifyListeners();
      return Future.value();
    }
    _inFlight = key;
    final future = _rasterize(key, generation);
    _inFlightFuture = future;
    if (color != colorBefore) notifyListeners();
    return future;
  }

  /// Fills [size] with [color] and draws [image] over it, cover-fitted and
  /// top-centred (it is exactly the screen once rasterized for this size;
  /// until a resize re-rasterizes it, it is scaled to cover).
  void paint(Canvas canvas, Size size) {
    _fill.color = color;
    canvas.drawRect(Offset.zero & size, _fill);
    final shown = _shown;
    if (shown == null) return;
    final image = shown.image;
    final cover = ThemeCover.of(shown.key.size, size);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(
        cover.left,
        0,
        shown.key.size.width * cover.scale,
        shown.key.size.height * cover.scale,
      ),
      _imagePaint,
    );
  }

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _shown?.image.dispose();
    _shown = null;
    _picture?.picture.dispose();
    _picture = null;
    super.dispose();
  }

  Future<void> _rasterize(_Key key, int generation) async {
    try {
      final info = await _pictureFor(key.theme, generation);
      if (info == null) return;
      final cover = ThemeCover.of(info.size, key.size);
      final ratio = key.pixelRatio;
      final image = await rasterizePictures(
        [SvgRasterPart(info.picture)],
        width: math.max(1, (key.size.width * ratio).round()),
        height: math.max(1, (key.size.height * ratio).round()),
        scale: cover.scale * ratio,
        left: -cover.left * ratio,
      );
      if (_disposed || generation != _generation) {
        image.dispose();
        return;
      }
      final previous = _shown;
      _shown = _Raster(key, image);
      previous?.image.dispose();
      notifyListeners();
    } on Object catch (error, stack) {
      final report = _onError;
      if (report != null) {
        report(error, stack);
      } else {
        debugPrint('ThemeBackground: ${key.theme.id} failed: $error');
      }
    } finally {
      if (generation == _generation) {
        _inFlight = null;
        _inFlightFuture = null;
      }
    }
  }

  /// The parsed art of [theme]: kept for the current theme, so a resize
  /// only re-rasterizes. Null when a newer request took over meanwhile.
  Future<PictureInfo?> _pictureFor(ChapterTheme theme, int generation) async {
    final cached = _picture;
    if (cached != null && _pictureTheme == theme) return cached;
    final info = await loadSvgPicture(await _loadSvg(theme));
    if (_disposed || generation != _generation) {
      info.picture.dispose();
      return null;
    }
    _picture?.picture.dispose();
    _picture = info;
    _pictureTheme = theme;
    return info;
  }
}

/// Paints a [ThemeBackground], repainting when it changes.
final class ThemeBackgroundPainter extends CustomPainter {
  ThemeBackgroundPainter(this.background) : super(repaint: background);

  final ThemeBackground background;

  @override
  void paint(Canvas canvas, Size size) => background.paint(canvas, size);

  @override
  bool shouldRepaint(ThemeBackgroundPainter oldDelegate) =>
      !identical(oldDelegate.background, background);
}

@immutable
final class _Key {
  const _Key(this.theme, this.size, this.pixelRatio);

  final ChapterTheme theme;
  final Size size;
  final double pixelRatio;

  @override
  bool operator ==(Object other) =>
      other is _Key &&
      other.theme == theme &&
      other.size == size &&
      other.pixelRatio == pixelRatio;

  @override
  int get hashCode => Object.hash(theme, size, pixelRatio);
}

final class _Raster {
  _Raster(this.key, this.image);

  final _Key key;
  final ui.Image image;
}
