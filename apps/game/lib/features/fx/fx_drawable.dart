import 'dart:ui';

import 'package:flutter/painting.dart' show BoxFit;
import 'package:lottie/lottie.dart';
import 'package:nesty_game/features/fx/fx_delegates.dart';
import 'package:nesty_game/features/fx/fx_drawable_params.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_images.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/fx_player.dart';
import 'package:nesty_game/features/fx/fx_spec.dart';
import 'package:nesty_game/features/fx/fx_spec.gen.dart';
import 'package:nesty_game/features/fx/fx_text_overlay.dart';

/// One drawable of one file, with everything that plays it: the
/// composition's `LottieDrawable` (delegates set once, §2 rules 1–3), its
/// [params], [images] and [player]. Hosted by `LottieFxComponent` on the
/// board and `LottieFxView` in widgets; one per pooled clip (§14).
///
/// Draws its canvas at `(0, 0)–(width, height)` in the current transform;
/// the host places and scales it.
final class FxDrawable {
  FxDrawable(
    this.composition, {
    required this.spec,
    FxDrawableParams? params,
    FxImages? images,
    FxPlayer? player,
  }) : params = params ?? FxDrawableParams(),
       images = images ?? FxImages(),
       player = player ?? FxPlayer(durationFrames: composition.durationFrames),
       textHook = FxTextHook.of(spec.id),
       _rect = Rect.fromLTWH(0, 0, spec.width, spec.height),
       lottie = LottieDrawable(composition, frameRate: FrameRate.max) {
    // Delegates only after construction: passing value delegates to the
    // constructor throws a LateInitializationError on 3.6.1 (rule 1).
    lottie
      ..filterQuality = FilterQuality.medium
      ..delegates = FxDelegates.build(
        spec,
        params: this.params,
        images: this.images,
        player: this.player,
      );
    lottie.setProgress(this.player.progress);
  }

  /// A clip of [id] from [library], or null when that file isn't loaded
  /// (rule 3: the caller shows the rest pose). Its images get the
  /// library's blank.
  static FxDrawable? of(FxLibrary library, FxId id) {
    final composition = library[id];
    if (composition == null) return null;
    return FxDrawable(
      composition,
      spec: fxSpecOf(id),
      images: FxImages(blank: library.blank),
    );
  }

  final LottieComposition composition;
  final FxSpec spec;
  final FxDrawableParams params;
  final FxImages images;
  final FxPlayer player;

  /// The text null the host's label follows, for the three text files.
  final FxTextHook? textHook;

  /// Frame rate `max` renders sub-frames (0.5×, 2×, 120 Hz); medium
  /// filtering, because 512-unit art is drawn at 63–150 dp (§2).
  final LottieDrawable lottie;

  final Rect _rect;

  FxId get id => spec.id;

  /// Back to idle, frame 0, authored params, no request (a clip returned to
  /// its pool). The image source and blank stay (they belong to the level
  /// and the library).
  void reset() {
    player.reset();
    params.reset();
    images.request.reset();
  }

  // ── Hot path: every tick and frame of a live clip. No allocation here
  // (lottie allocates inside its own draw, PROGRESS D42). ──

  /// Advances the player by [dtMs]; true on the tick a one-shot ends.
  bool advance(double dtMs) => player.advance(dtMs);

  /// Draws the current frame.
  void draw(Canvas canvas) {
    lottie.setProgress(player.progress);
    final hook = textHook;
    if (hook != null) {
      params
        ..textNullPosition = hook.style.restNull
        ..textNullScale = 1;
    }
    lottie.draw(canvas, _rect, fit: BoxFit.fill);
  }

  // ── End of hot path. ──
}

/// The generated specs through the library, so hosts read one object.
extension FxLibrarySpecs on FxLibrary {
  /// [id]'s spec (always available, loaded or not).
  FxSpec specOf(FxId id) => fxSpecOf(id);
}
