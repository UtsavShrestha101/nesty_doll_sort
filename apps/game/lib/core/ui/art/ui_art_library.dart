import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart' show ChangeNotifier, Listenable;
import 'package:flutter/services.dart' show AssetBundle, rootBundle;
import 'package:flutter/widgets.dart' show BuildContext, InheritedWidget, Size;
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/ui/art/ui_art.dart';
import 'package:nesty_render/nesty_render.dart' show loadSvgPicture;

/// The UI art's rasters (phase 4 architecture §3.4): each [UiArt] drawn once
/// per (art, logical box, device pixel ratio) into a cached `ui.Image`, so a
/// dense grid (Chapters' 20 stars a chapter, Records' 12 badges) and a Lottie
/// slot (`UiArtImageSource`) paint a lookup, never an SVG (CLAUDE.md rule 8).
///
/// A lazy singleton in both environments, like `FxLibrary`: the real one
/// reads the bundled SVGs ([AssetUiArtLibrary]); the fake has no art, so
/// every [imageOf] is null and widgets draw their empty box (rule 3's path,
/// exercised by every widget test).
abstract interface class UiArtLibrary {
  /// Rasterizes each of [arts] into each of [sizes] (logical px, the art
  /// fitted inside and centred, like `BoxFit.contain`) at
  /// [devicePixelRatio]. Rasters already made are kept. Never throws: an art
  /// that fails to load stays null. Completes once every raster is in.
  Future<void> prepare(
    Iterable<UiArt> arts, {
    required Iterable<Size> sizes,
    required double devicePixelRatio,
  });

  /// The raster of [art] for the logical box [size] at the latest prepared
  /// pixel ratio, or null while it isn't made (or can't be). A lookup that
  /// allocates nothing, safe in `paint`.
  ui.Image? imageOf(UiArt art, Size size);

  /// Notifies once a [prepare] has added rasters, so a widget that drew an
  /// empty box can repaint.
  Listenable get changes;

  /// Frees every raster (DI reset); unusable afterwards.
  Future<void> dispose();

  /// The library for widgets under [context]: the nearest [UiArtScope], else
  /// the app's registered one, else null (a widget test without DI draws
  /// empty boxes).
  static UiArtLibrary? of(BuildContext context) =>
      UiArtScope.maybeOf(context) ?? _fromLocator();

  static UiArtLibrary? _fromLocator() {
    final locator = GetIt.instance;
    return locator.isRegistered<UiArtLibrary>()
        ? locator<UiArtLibrary>()
        : null;
  }
}

/// Overrides the [UiArtLibrary] below it (tests, previews).
class UiArtScope extends InheritedWidget {
  const UiArtScope({required this.library, required super.child, super.key});

  final UiArtLibrary library;

  static UiArtLibrary? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<UiArtScope>()?.library;

  @override
  bool updateShouldNotify(UiArtScope oldWidget) =>
      !identical(oldWidget.library, library);
}

/// A [ChangeNotifier] whose owner may notify.
final class _Changes extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// A parsed SVG: its picture in its own coordinates, and its size.
typedef _ArtPicture = ({ui.Picture picture, Size size});

/// One raster of one art: its logical box and pixel ratio.
final class _UiArtRaster {
  _UiArtRaster(this.width, this.height, this.pixelRatio, this.image);

  final double width;
  final double height;
  final double pixelRatio;
  final ui.Image image;
}

/// The real [UiArtLibrary]: `assets/ui/**`, each SVG parsed once and kept as
/// a picture, each raster drawn with `Picture.toImageSync` (like the daily
/// card's background loader, so screens under `flutter_test`'s fake time need
/// no `runAsync`).
@LazySingleton(as: UiArtLibrary, env: [AppEnv.real])
class AssetUiArtLibrary implements UiArtLibrary {
  AssetUiArtLibrary({@ignoreParam AssetBundle? bundle})
    : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  /// Rasters are capped like `ThemeBackground.maxPixelRatio`: the art is
  /// small, and 3× adds bytes, not sharpness, at these sizes.
  static const double maxPixelRatio = 3;

  final Map<UiArt, Future<_ArtPicture?>> _pictures = {};
  final List<List<_UiArtRaster>> _rasters = List.generate(
    UiArt.values.length,
    (_) => <_UiArtRaster>[],
    growable: false,
  );
  final _Changes _changes = _Changes();
  double _pixelRatio = 1;
  bool _disposed = false;

  @override
  Listenable get changes => _changes;

  @override
  Future<void> prepare(
    Iterable<UiArt> arts, {
    required Iterable<Size> sizes,
    required double devicePixelRatio,
  }) async {
    if (_disposed || !devicePixelRatio.isFinite || devicePixelRatio <= 0) {
      return;
    }
    final ratio = math.min(devicePixelRatio, maxPixelRatio);
    _pixelRatio = ratio;
    final boxes = [
      for (final size in sizes)
        if (size.width.isFinite &&
            size.height.isFinite &&
            size.width > 0 &&
            size.height > 0)
          size,
    ];
    var added = false;
    for (final art in arts.toSet()) {
      final info = await (_pictures[art] ??= _load(art));
      if (info == null || _disposed) continue;
      for (final box in boxes) {
        if (_find(art, box.width, box.height, ratio) != null) continue;
        final image = _draw(info, box, ratio);
        if (image == null) continue;
        _rasters[art.index].add(
          _UiArtRaster(box.width, box.height, ratio, image),
        );
        added = true;
      }
    }
    if (added && !_disposed) _changes.notify();
  }

  @override
  ui.Image? imageOf(UiArt art, Size size) =>
      _find(art, size.width, size.height, _pixelRatio)?.image;

  _UiArtRaster? _find(UiArt art, double width, double height, double ratio) {
    final list = _rasters[art.index];
    for (var i = 0; i < list.length; i++) {
      final raster = list[i];
      if (raster.width == width &&
          raster.height == height &&
          raster.pixelRatio == ratio) {
        return raster;
      }
    }
    return null;
  }

  Future<_ArtPicture?> _load(UiArt art) async {
    try {
      final info = await loadSvgPicture(
        await _bundle.loadString(art.assetPath),
      );
      return (picture: info.picture, size: info.size);
    } on Object {
      // Rule 3: a missing or broken file leaves the box empty.
      return null;
    }
  }

  static ui.Image? _draw(_ArtPicture info, Size box, double ratio) {
    try {
      final art = info.size;
      final scale = math.min(box.width / art.width, box.height / art.height);
      final dx = (box.width - art.width * scale) / 2;
      final dy = (box.height - art.height * scale) / 2;
      final recorder = ui.PictureRecorder();
      ui.Canvas(recorder)
        ..scale(ratio)
        ..translate(dx, dy)
        ..scale(scale)
        ..drawPicture(info.picture);
      final picture = recorder.endRecording();
      try {
        return picture.toImageSync(
          math.max(1, (box.width * ratio).round()),
          math.max(1, (box.height * ratio).round()),
        );
      } finally {
        picture.dispose();
      }
    } on Object {
      return null;
    }
  }

  /// Frees every raster and picture (DI reset); unusable afterwards.
  @override
  @disposeMethod
  Future<void> dispose() async {
    _disposed = true;
    for (final list in _rasters) {
      for (final raster in list) {
        raster.image.dispose();
      }
      list.clear();
    }
    for (final future in _pictures.values) {
      (await future)?.picture.dispose();
    }
    _pictures.clear();
    _changes.dispose();
  }
}

/// A [UiArtLibrary] with no art (the fake env and widget tests): every
/// [imageOf] is what [images] holds for the art, whatever the size, so a test
/// can hand a widget a raster. [prepared] records what was asked for.
@LazySingleton(as: UiArtLibrary, env: [AppEnv.fake])
class FakeUiArtLibrary implements UiArtLibrary {
  /// What [imageOf] returns per art; empty by default.
  final Map<UiArt, ui.Image> images = {};

  /// Every art [prepare] was asked for, in order.
  final List<UiArt> prepared = [];

  final _Changes _changes = _Changes();

  @override
  Listenable get changes => _changes;

  @override
  Future<void> prepare(
    Iterable<UiArt> arts, {
    required Iterable<Size> sizes,
    required double devicePixelRatio,
  }) async {
    prepared.addAll(arts);
  }

  @override
  ui.Image? imageOf(UiArt art, Size size) => images[art];

  /// Tells listeners [images] changed.
  void notify() => _changes.notify();

  @override
  @disposeMethod
  Future<void> dispose() async => _changes.dispose();
}
