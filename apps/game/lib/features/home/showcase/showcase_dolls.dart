import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
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
/// D58). It follows the Color symbols setting, which the bodies bake in:
/// a change made in Settings, which opens over Home, rasterizes the shelf
/// again in the new mode while the old art stays up (D91). Never throws:
/// without art the shelves draw the placeholder doll (rule 3).
///
/// Renders through [SkinService.prepareShowcase] (m3-design §9.2), which
/// moved the board itself to `ShowcaseBoard`; [level], [geometry] and
/// [artHeight] stay here, delegating to it, so this class's public API is
/// unchanged for its callers (the splash and Home).
@lazySingleton
class ShowcaseDolls {
  ShowcaseDolls(this._skins, this._database) {
    _symbolsSubscription = _database.symbolsModeChanges.listen(
      (_) => _followSymbols(),
    );
    _skinSubscription = _skins.selectedSkinChanges.listen((_) => _followSkin());
  }

  final SkinService _skins;
  final DatabaseService _database;
  late final StreamSubscription<SymbolsMode> _symbolsSubscription;
  late final StreamSubscription<String> _skinSubscription;

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
  DollSymbols? _preparedSymbols;
  int _generation = 0;
  bool _disposed = false;

  /// The prepared art, or null until [prepare] lands (or after [release]).
  ValueListenable<LevelSkin?> get current => _current;

  /// Rasterizes the showcase dolls for a [devicePixelRatio] screen in the
  /// player's symbols mode. Returns the request in flight, or at once when
  /// that art is already here.
  Future<void> prepare({required double devicePixelRatio}) {
    if (_disposed) return Future.value();
    final symbols = _database.symbolsMode.dollSymbols;
    if (_preparedFor == devicePixelRatio && _preparedSymbols == symbols) {
      final inFlight = _preparing;
      if (inFlight != null) return inFlight;
      if (_current.value != null) return Future.value();
    }
    _preparedFor = devicePixelRatio;
    _preparedSymbols = symbols;
    final generation = ++_generation;
    final future = _prepare(devicePixelRatio, symbols, generation);
    _preparing = future;
    return future;
  }

  /// The stored symbols mode changed: prepare the art again at the pixel
  /// ratio it was made for. Nothing to do before the first [prepare] or
  /// after [release], or when the mode is the one already prepared.
  void _followSymbols() {
    final devicePixelRatio = _preparedFor;
    if (_disposed || devicePixelRatio == null) return;
    unawaited(prepare(devicePixelRatio: devicePixelRatio));
  }

  /// The Shop equipped a new skin (`SkinService.selectSkin`, which writes
  /// the save before it emits, m7-design §18 "Home's shelf after a skin
  /// equip"): re-rasterize the shelf even though the pixel ratio and Color
  /// symbols mode haven't changed, which [prepare]'s own "already here"
  /// check would otherwise skip. Nothing to do before the first [prepare]
  /// or after [release]/[dispose].
  void _followSkin() {
    final devicePixelRatio = _preparedFor;
    if (_disposed || devicePixelRatio == null) return;
    // Forces prepare() past its cache check, which otherwise only compares
    // the pixel ratio and the symbols mode.
    _preparedFor = null;
    unawaited(prepare(devicePixelRatio: devicePixelRatio));
  }

  Future<void> _prepare(
    double devicePixelRatio,
    DollSymbols symbols,
    int generation,
  ) async {
    LevelSkin? skin;
    try {
      skin = await _skins.prepareShowcase(
        colors: colors,
        devicePixelRatio: devicePixelRatio,
        symbols: symbols,
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
    unawaited(_symbolsSubscription.cancel());
    unawaited(_skinSubscription.cancel());
    _current.dispose();
  }
}
