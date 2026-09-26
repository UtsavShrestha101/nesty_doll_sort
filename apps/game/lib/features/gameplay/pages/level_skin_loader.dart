import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_render/nesty_render.dart';

/// Keeps the art of the level in play (m2-lottie-design §4 "SkinService"):
/// asks [SkinService.prepareForLevel] behind the route transition, again
/// after an extra slot re-pitches the row, and hands each result over
/// through [onReady] before disposing the one it replaces.
///
/// The latest request wins: a result that lands after a newer request was
/// made is disposed unseen, so a quick Continue never shows the previous
/// level's dolls. `prepareForLevel` never throws (rule 3); a failure here
/// still keeps the current skin.
///
/// [prefetch] prepares the next level's art ahead (while the win overlay is
/// up), and the [prepare] for that level and layout adopts it at once: in
/// the same frame the board lays the level out, so its first frame already
/// draws its own dolls (review CORRECTNESS-1). The previous level's skin
/// holds only its own colours, and a colour a skin lacks draws nothing.
final class LevelSkinLoader {
  LevelSkinLoader(this._skins, {required this.onReady});

  final SkinService _skins;

  /// Called with each new current skin, before the previous one is
  /// disposed.
  final void Function(LevelSkin skin) onReady;

  LevelSkin? _current;
  _Ahead? _ahead;
  int _generation = 0;
  bool _disposed = false;

  /// The art in use, or null before the first request lands.
  LevelSkin? get current => _current;

  /// Prepares [level] on [geometry]. Completes when this request has
  /// landed (or was superseded).
  ///
  /// A [prefetch] of the same level and layout is adopted instead of asked
  /// for again: synchronously when it has landed, or when it lands.
  Future<void> prepare(
    Level level, {
    required BoardGeometry geometry,
    required double devicePixelRatio,
    required DollSymbols symbols,
  }) async {
    if (_disposed) return;
    final generation = ++_generation;
    final ahead = _claimAhead(level, geometry, devicePixelRatio, symbols);
    final landed = ahead?.take();
    if (landed != null) {
      _adopt(landed);
      return;
    }
    // Still rasterizing: wait for it rather than asking twice. One that
    // failed is asked for again.
    var skin = ahead == null || ahead.settled ? null : await ahead.future;
    if (skin == null) {
      try {
        skin = await _skins.prepareForLevel(
          level,
          geometry: geometry,
          devicePixelRatio: devicePixelRatio,
          symbols: symbols,
        );
      } on Object catch (error, stack) {
        // Rule 3: never thrown into the page; the board keeps what it has.
        _log(error, stack);
        return;
      }
    }
    if (_disposed || generation != _generation) {
      skin.dispose();
      return;
    }
    _adopt(skin);
  }

  /// Prepares [level]'s art for [geometry] before the board shows it,
  /// without handing it over (the next level, while the win overlay is up).
  /// The [prepare] that asks for the same level and layout adopts it; a
  /// newer prefetch, a [prepare] of that level on another layout, or
  /// [dispose] drops it (disposed now, or when it lands). Completes when it
  /// has landed. Never throws.
  Future<void> prefetch(
    Level level, {
    required BoardGeometry geometry,
    required double devicePixelRatio,
    required DollSymbols symbols,
  }) {
    if (_disposed) return Future<void>.value();
    final current = _ahead;
    if (current != null &&
        current.matches(level, geometry, devicePixelRatio, symbols)) {
      return current.landed;
    }
    current?.drop();
    final ahead = _Ahead(
      level,
      geometry,
      devicePixelRatio,
      symbols,
      _skins.prepareForLevel(
        level,
        geometry: geometry,
        devicePixelRatio: devicePixelRatio,
        symbols: symbols,
      ),
    );
    _ahead = ahead;
    return ahead.landed;
  }

  /// Disposes the current skin and any prefetch; later results are disposed
  /// on arrival.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _ahead?.drop();
    _ahead = null;
    _current?.dispose();
    _current = null;
  }

  /// The prefetch [prepare] can use, taken out of [_ahead]: one of this
  /// level on this layout. One of this level on another layout (a resize)
  /// is stale and dropped; one of another level stays for its own turn.
  _Ahead? _claimAhead(
    Level level,
    BoardGeometry geometry,
    double devicePixelRatio,
    DollSymbols symbols,
  ) {
    final ahead = _ahead;
    if (ahead == null || ahead.level != level) return null;
    _ahead = null;
    if (ahead.matches(level, geometry, devicePixelRatio, symbols)) {
      return ahead;
    }
    ahead.drop();
    return null;
  }

  void _adopt(LevelSkin skin) {
    final previous = _current;
    _current = skin;
    onReady(skin);
    previous?.dispose();
  }

  static void _log(Object error, StackTrace stack) {
    developer.log(
      'the level art failed to prepare',
      name: 'nesty.gameplay',
      error: error,
      stackTrace: stack,
    );
    // developer.log never reaches the `flutter run` terminal.
    if (kDebugMode) debugPrint('[nesty.gameplay] level art failed: $error');
  }
}

/// One prefetched skin: what it was asked for, and the skin once it lands.
/// Exactly one owner ends up with the skin: the [prepare] that [take]s it
/// (or awaits [future]), or [drop], which disposes it.
final class _Ahead {
  _Ahead(
    this.level,
    this.geometry,
    this.devicePixelRatio,
    this.symbols,
    Future<LevelSkin> request,
  ) {
    future = request.then<LevelSkin?>(
      (skin) {
        settled = true;
        if (_dropped) {
          skin.dispose();
          return null;
        }
        return _skin = skin;
      },
      onError: (Object error, StackTrace stack) {
        settled = true;
        LevelSkinLoader._log(error, stack);
        return null;
      },
    );
  }

  final Level level;
  final BoardGeometry geometry;
  final double devicePixelRatio;
  final DollSymbols symbols;

  /// The skin, or null when preparing failed or it was dropped.
  late final Future<LevelSkin?> future;

  LevelSkin? _skin;
  bool _dropped = false;

  /// The request has landed or failed.
  bool settled = false;

  /// Completes when the skin has landed (or failed).
  Future<void> get landed => future.then<void>((_) {});

  bool matches(
    Level level,
    BoardGeometry geometry,
    double devicePixelRatio,
    DollSymbols symbols,
  ) =>
      level == this.level &&
      devicePixelRatio == this.devicePixelRatio &&
      symbols == this.symbols &&
      _sameLayout(geometry, this.geometry);

  /// The landed skin, handed to the caller; null while it is still on its
  /// way.
  LevelSkin? take() {
    final skin = _skin;
    _skin = null;
    return skin;
  }

  /// Nobody will use it: dispose the skin now, or when it lands.
  void drop() {
    if (_dropped) return;
    _dropped = true;
    _skin?.dispose();
    _skin = null;
  }

  /// `BoardLayout.compute` is pure: the same shape on the same screen
  /// (whose board area and counter target it keeps) is the same layout.
  static bool _sameLayout(BoardGeometry a, BoardGeometry b) =>
      identical(a, b) ||
      (a.shape == b.shape &&
          a.boardArea == b.boardArea &&
          a.familyCounterTarget == b.familyCounterTarget);
}
