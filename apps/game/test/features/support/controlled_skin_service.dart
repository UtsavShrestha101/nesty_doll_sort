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
  final List<
    ({
      Level level,
      double devicePixelRatio,
      DollSymbols symbols,
      String? themeId,
    })
  >
  requests = [];

  /// Skins handed out, in the order of their requests.
  final List<RecordingLevelSkin> made = [];

  @override
  ThemeBackground? get background => null;

  @override
  Future<void> load() async {}

  @override
  void dispose() => unawaited(_selectedSkinChanges.close());

  final StreamController<String> _selectedSkinChanges =
      StreamController<String>.broadcast();

  @override
  Stream<String> get selectedSkinChanges => _selectedSkinChanges.stream;

  @override
  Future<LevelSkin> prepareForLevel(
    Level level, {
    required BoardGeometry geometry,
    required double devicePixelRatio,
    required DollSymbols symbols,
    String? themeId,
  }) {
    requests.add((
      level: level,
      devicePixelRatio: devicePixelRatio,
      symbols: symbols,
      themeId: themeId,
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

  @override
  String selectedSkinId = 'classic';

  @override
  Future<bool> selectSkin(String skinId) async {
    final changed = skinId != selectedSkinId;
    selectedSkinId = skinId;
    if (changed && !_selectedSkinChanges.isClosed) {
      _selectedSkinChanges.add(skinId);
    }
    return true;
  }

  /// What each [prepareShowcase] call asked for, in order.
  final List<
    ({
      List<DollColor> colors,
      double devicePixelRatio,
      DollSymbols symbols,
      String skinId,
    })
  >
  showcaseRequests = [];
  final List<Completer<LevelSkin?>> _pendingShowcase = [];

  /// A [prepareShowcase] call waits until the test completes it
  /// ([completeShowcase], [failShowcase]), in any order — the same pattern
  /// as [prepareForLevel], so callers like `ShowcaseDolls` can be tested
  /// through their in-flight/release/dispose races (m3-design §9.2).
  @override
  Future<LevelSkin?> prepareShowcase({
    required List<DollColor> colors,
    required double devicePixelRatio,
    required DollSymbols symbols,
    String? skinId,
  }) {
    final id = skinId ?? selectedSkinId;
    showcaseRequests.add((
      colors: colors,
      devicePixelRatio: devicePixelRatio,
      symbols: symbols,
      skinId: id,
    ));
    final completer = Completer<LevelSkin?>();
    _pendingShowcase.add(completer);
    return completer.future;
  }

  /// Completes showcase request [index] (0-based) with a new skin.
  RecordingLevelSkin completeShowcase(int index) {
    final skin = RecordingLevelSkin('showcase:$index');
    made.add(skin);
    _pendingShowcase[index].complete(skin);
    return skin;
  }

  /// Fails showcase request [index] (the requested skin's art can't be
  /// prepared at all, `SkinService.prepareShowcase`'s null case).
  void failShowcase(int index) => _pendingShowcase[index].complete(null);
}

final class _NoImages implements FxImageSource {
  const _NoImages();

  @override
  FxRaster? rasterFor(FxImageSlot slot, FxImageRequest request) => null;
}
