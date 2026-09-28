import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/skin/showcase_board.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_render/nesty_render.dart';

/// The art of the dolls on the splash and Home shelves (frames 1.1 and
/// 2.1: `doll_idle` needs the selected skin's lid and body rasters, LOTTIE.md
/// "Image slots").
///
/// They come from [SkinService.prepareShowcase], the one door to the
/// skin's part rasters and their cache (m2-lottie-design §4), fed a
/// showcase board: a single tower holding one doll of each [colors]. One
/// slot keeps the layout's tallest doll at [artHeight] (140 dp on the
/// reference screen), above the tallest shelf doll (Home's 128 dp cherry),
/// so the rasters are never upscaled. It also yields the skin's plank tile
/// for `PlankStrip`.
///
/// The splash prepares it while it loads (so Home opens with its dolls),
/// and it stays for the app's life: Home keeps it while a level covers it,
/// so the shelf never flashes placeholder dolls on the way back (PROGRESS
/// D58). Never throws: without art the shelves draw the placeholder doll
/// (rule 3).
///
/// Renders through [SkinService.prepareShowcase] (m3-design §9.2), which
/// moved the board itself to `ShowcaseBoard`; [level], [geometry] and
/// [artHeight] stay here, delegating to it, so this class's public API is
/// unchanged for its callers (the splash and Home).
@lazySingleton
class ShowcaseDolls {
  ShowcaseDolls(this._skins, this._database);

  final SkinService _skins;
  final DatabaseService _database;

  /// Home's shelf (tangerine, leaf, cherry, sky, grape); cherry is also the
  /// splash trio's colour.
  static const colors = [
    DollColor.orange,
    DollColor.green,
    DollColor.red,
    DollColor.blue,
    DollColor.purple,
  ];

  /// The showcase board: one tower, one doll of each colour.
  static final Level level = ShowcaseBoard.levelFor(colors);

  /// The showcase board laid out on the reference screen.
  static final BoardGeometry geometry = ShowcaseBoard.geometry;

  /// The height the rasters are made for.
  static double get artHeight => ShowcaseBoard.artHeight;

  final ValueNotifier<LevelSkin?> _current = ValueNotifier(null);
  Future<void>? _preparing;
  double? _preparedFor;
  int _generation = 0;
  bool _disposed = false;

  /// The prepared art, or null until [prepare] lands (or after [release]).
  ValueListenable<LevelSkin?> get current => _current;

  /// Rasterizes the showcase dolls for a [devicePixelRatio] screen in the
  /// player's symbols mode. Returns the request in flight, or at once when
  /// that art is already here.
  Future<void> prepare({required double devicePixelRatio}) {
    if (_disposed) return Future.value();
    if (_current.value != null && _preparedFor == devicePixelRatio) {
      return Future.value();
    }
    final inFlight = _preparing;
    if (inFlight != null && _preparedFor == devicePixelRatio) return inFlight;
    _preparedFor = devicePixelRatio;
    final generation = ++_generation;
    final future = _prepare(devicePixelRatio, generation);
    _preparing = future;
    return future;
  }

  Future<void> _prepare(double devicePixelRatio, int generation) async {
    LevelSkin? skin;
    try {
      skin = await _skins.prepareShowcase(
        colors: colors,
        devicePixelRatio: devicePixelRatio,
        symbols: _database.symbolsMode.dollSymbols,
      );
    } on Object catch (error, stack) {
      developer.log(
        'the shelf dolls failed to prepare',
        name: 'nesty.showcase',
        error: error,
        stackTrace: stack,
      );
      // developer.log never reaches the `flutter run` terminal.
      if (kDebugMode) debugPrint('[nesty.showcase] prepare failed: $error');
    }
    if (generation != _generation) {
      skin?.dispose();
      return;
    }
    _preparing = null;
    if (_disposed || skin == null) {
      skin?.dispose();
      if (skin == null) _preparedFor = null;
      return;
    }
    final previous = _current.value;
    _current.value = skin;
    previous?.dispose();
  }

  /// Frees the rasters ([dispose]; a memory-pressure hook later);
  /// [prepare] brings them back.
  void release() {
    _generation++;
    _preparing = null;
    _preparedFor = null;
    final previous = _current.value;
    _current.value = null;
    previous?.dispose();
  }

  /// DI reset.
  @disposeMethod
  void dispose() {
    if (_disposed) return;
    release();
    _disposed = true;
    _current.dispose();
  }
}
