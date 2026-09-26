import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:lottie/lottie.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';

/// The real [FxLibrary]: the 29 bundled files (`assets/lottie/`), parsed
/// once at splash (m2-lottie-design §2 "Loading", PROGRESS D40, D50).
///
/// - Parses with `LottieComposition.fromBytes`, which decodes no images:
///   the placeholder PNGs never ship, and every slot is the game's.
/// - One file per event-loop turn ([_yield]), so the ~60 ms (host) of
///   parsing is spread over frames and the splash keeps animating;
///   `ui_splash_loader` goes first so the loader can draw itself.
/// - A file that is missing, doesn't parse or doesn't match its generated
///   spec (canvas, length) is left out and logged, never thrown (rule 3):
///   `this[id]` is null and the game shows the rest pose.
@LazySingleton(as: FxLibrary, env: [AppEnv.real])
class AssetFxLibrary implements FxLibrary {
  AssetFxLibrary({
    @ignoreParam AssetBundle? bundle,
    @ignoreParam Future<void> Function()? yieldToFrames,
  }) : _bundle = bundle ?? rootBundle,
       _yield = yieldToFrames ?? _nextTurn;

  final AssetBundle _bundle;
  final Future<void> Function() _yield;

  final Map<FxId, LottieComposition> _compositions = {};
  final Set<FxId> _failed = {};
  final List<void Function(double progress)> _listeners = [];
  Future<void>? _loading;
  bool _loaded = false;
  double _progress = 0;
  ui.Image? _blank;

  /// The load order: the splash loader first, then [FxId] order.
  static final List<FxId> loadOrder = [
    FxId.uiSplashLoader,
    for (final id in FxId.values)
      if (id != FxId.uiSplashLoader) id,
  ];

  @override
  Future<void> load({void Function(double progress)? onProgress}) {
    if (onProgress != null) {
      if (_loaded) {
        onProgress(1);
      } else {
        _listeners.add(onProgress);
        if (_progress > 0) onProgress(_progress);
      }
    }
    return _loading ??= _loadAll();
  }

  @override
  bool get isLoaded => _loaded;

  @override
  LottieComposition? operator [](FxId id) => _compositions[id];

  @override
  Set<FxId> get failed => Set.unmodifiable(_failed);

  @override
  ui.Image? get blank => _blank;

  Future<void> _loadAll() async {
    try {
      _blank = _makeBlank();
    } on Object catch (error, stack) {
      // Image slots then fall through to lottie's (null) asset image, which
      // draws nothing either.
      _log('the blank image failed', error, stack);
    }
    final total = loadOrder.length;
    for (var i = 0; i < total; i++) {
      final id = loadOrder[i];
      final composition = await _loadOne(id);
      if (composition == null) {
        _failed.add(id);
      } else {
        _compositions[id] = composition;
      }
      _report((i + 1) / total);
      if (i + 1 < total) await _yield();
    }
    _loaded = true;
    _listeners.clear();
  }

  Future<LottieComposition?> _loadOne(FxId id) async {
    try {
      final data = await _bundle.load(id.assetPath);
      final composition = await LottieComposition.fromBytes(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final mismatch = _mismatch(id, composition);
      if (mismatch != null) {
        _log('${id.fileName} does not match its spec: $mismatch');
        return null;
      }
      return composition;
    } on Object catch (error, stack) {
      _log('${id.fileName} failed to load', error, stack);
      return null;
    }
  }

  /// Why [composition] can't be played as [id]'s spec says, or null. The
  /// drift tests keep the two equal; this guards a shipped build against a
  /// file swapped without regenerating `fx_spec.gen.dart`.
  static String? _mismatch(FxId id, LottieComposition composition) {
    final spec = fxSpecOf(id);
    final bounds = composition.bounds;
    if (bounds.width != spec.width || bounds.height != spec.height) {
      return 'canvas ${bounds.width}×${bounds.height}, '
          'spec ${spec.width}×${spec.height}';
    }
    final frames = FxPlayer.durationFramesOf(spec);
    if ((composition.durationFrames - frames).abs() > 1e-6 ||
        composition.startFrame != 0) {
      return 'frames ${composition.startFrame}–${composition.endFrame}, '
          'spec 0–$frames';
    }
    if (composition.frameRate != 60) {
      return '${composition.frameRate} fps';
    }
    return null;
  }

  void _report(double progress) {
    _progress = progress;
    for (var i = 0; i < _listeners.length; i++) {
      try {
        _listeners[i](progress);
      } on Object catch (error, stack) {
        _log('a progress listener threw', error, stack);
      }
    }
  }

  static ui.Image _makeBlank() {
    final recorder = ui.PictureRecorder();
    ui.Canvas(recorder);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(1, 1);
    picture.dispose();
    return image;
  }

  static Future<void> _nextTurn() => Future<void>.delayed(Duration.zero);

  static void _log(String message, [Object? error, StackTrace? stack]) {
    developer.log(message, name: 'nesty.fx', error: error, stackTrace: stack);
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) {
      debugPrint('[nesty.fx] $message${error == null ? '' : ': $error'}');
    }
  }
}
