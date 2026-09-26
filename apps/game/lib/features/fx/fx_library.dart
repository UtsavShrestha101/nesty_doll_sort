import 'dart:ui' as ui;

import 'package:lottie/lottie.dart';
import 'package:nesty_game/features/fx/fx_id.dart';

/// Every Lottie composition, parsed once for the app's lifetime (LOTTIE.md
/// "Loading"; m2-lottie-design §2).
///
/// The real implementation (FX runtime lane) reads each
/// [FxId.assetPath] with `rootBundle.load` and parses it with
/// `LottieComposition.fromBytes`, which decodes no images: the placeholder
/// PNGs are never shipped (PROGRESS D50), and every image slot is filled by
/// the game (`FxImageSource`). It is loaded at splash, spread over frames.
///
/// A file that fails to load or parse is left out and logged, never thrown:
/// callers get null and show the rest pose instead (CLAUDE.md rule 3). The
/// fallbacks that must exist for that case are in m2-lottie-design §10.
abstract interface class FxLibrary {
  /// Loads every file once; later calls return the same future. Never
  /// throws. [onProgress] gets 0–1 as files finish (the splash loader's
  /// frame is its percentage).
  Future<void> load({void Function(double progress)? onProgress});

  /// True once [load] has finished (whatever failed).
  bool get isLoaded;

  /// The composition of [id], or null when it is not loaded (yet, or
  /// ever).
  LottieComposition? operator [](FxId id);

  /// The files that failed to load, for logs and tests.
  Set<FxId> get failed;

  /// A 1×1 transparent image, returned by image delegates for slots that
  /// must draw nothing (an unused role, a hidden doll). Null before [load]
  /// and in the fake, where compositions are null anyway.
  ui.Image? get blank;
}
