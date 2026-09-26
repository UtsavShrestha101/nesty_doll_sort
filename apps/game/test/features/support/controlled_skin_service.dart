import 'dart:async';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_render/nesty_render.dart';

/// A [LevelSkin] that remembers being disposed.
final class RecordingLevelSkin implements LevelSkin {
  RecordingLevelSkin(this.label);

  /// Which request made it (for failure messages).
  final String label;

  int disposeCount = 0;
  bool get disposed => disposeCount > 0;

  @override
  final FxImageSource images = const _NoImages();

  @override
  final DollRenderer restRenderer = PlaceholderDollPainter();

  @override
  BoardSprites? get sprites => null;

  @override
  void dispose() => disposeCount++;

  @override
  String toString() => 'RecordingLevelSkin($label)';
}

/// A [SkinService] whose `prepareForLevel` calls wait until the test
/// completes them ([complete], [fail]), in any order.
final class ControlledSkinService implements SkinService {
  final List<Completer<LevelSkin>> _pending = [];

  /// What each call asked for, in order.
  final List<({Level level, double devicePixelRatio, DollSymbols symbols})>
  requests = [];

  /// Skins handed out, in the order of their requests.
  final List<RecordingLevelSkin> made = [];

  @override
  ThemeBackground? get background => null;

  @override
  Future<void> load() async {}

  @override
  void dispose() {}

  @override
  Future<LevelSkin> prepareForLevel(
    Level level, {
    required BoardGeometry geometry,
    required double devicePixelRatio,
    required DollSymbols symbols,
  }) {
    requests.add((
      level: level,
      devicePixelRatio: devicePixelRatio,
      symbols: symbols,
    ));
    final completer = Completer<LevelSkin>();
    _pending.add(completer);
    return completer.future;
  }

  /// Completes request [index] (0-based) with a new skin.
  RecordingLevelSkin complete(int index) {
    final skin = RecordingLevelSkin('#$index');
    made.add(skin);
    _pending[index].complete(skin);
    return skin;
  }

  /// Fails request [index].
  void fail(int index) => _pending[index].completeError(StateError('no art'));
}

final class _NoImages implements FxImageSource {
  const _NoImages();

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) => null;
}
