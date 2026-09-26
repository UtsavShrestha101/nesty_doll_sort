import 'dart:ui' as ui;

import 'package:injectable/injectable.dart';
import 'package:lottie/lottie.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';

/// An [FxLibrary] with no compositions: every clip is skipped and the board
/// shows rest poses, as it would if every file failed to load (rule 3).
/// Tests put the compositions they need into [compositions] (and a [blank]
/// when their clips draw images). The real env uses `AssetFxLibrary`.
@LazySingleton(as: FxLibrary, env: [AppEnv.fake])
class FakeFxLibrary implements FxLibrary {
  /// What `operator []` returns; empty by default.
  final Map<FxId, LottieComposition> compositions = {};

  bool _loaded = false;

  @override
  Future<void> load({void Function(double progress)? onProgress}) async {
    _loaded = true;
    onProgress?.call(1);
  }

  @override
  bool get isLoaded => _loaded;

  @override
  LottieComposition? operator [](FxId id) => compositions[id];

  @override
  Set<FxId> get failed => const {};

  @override
  ui.Image? blank;
}
