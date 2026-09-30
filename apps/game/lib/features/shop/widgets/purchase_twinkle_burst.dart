import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';

/// A skin or theme purchase's celebration (tokens `motion.purchase`, F.5,
/// frame 7.2; menus spec 8.3).
///
/// `jingle_reward` and the music duck to 0.4 play at 0 (`JingleCues.reward`,
/// called by the cubit when the purchase lands). [celebrate] adds the rest:
/// the `success` haptic at 0 and, at [burstDelay] (300 ms), a short burst of
/// `fx_twinkle` stars over the card that was just bought, then gone
/// (LOTTIE.md "Win, Chapter complete, Shop": 2.0-2.4 s).
///
/// Reduce motion: no burst; the jingle and the haptic stay. There is no
/// coin count-up: that belongs to a coin pack (M6), and a skin or theme
/// spends coins rather than adding them.
///
/// `TODO(design)`: 7.2 draws the coin-pack purchase; what a skin or a theme
/// purchase shows beyond the jingle (the "card in") is undrawn, so this
/// keeps the small twinkle over the bought card (menus spec 8.3; BACKLOG "M7
/// phase 4 design gaps").
abstract final class PurchaseTwinkleBurst {
  /// When the burst starts (`motion.purchase.coinBurstAtMs`).
  static const Duration burstDelay = Duration(
    milliseconds: PurchaseMotionTokens.coinBurstAtMs,
  );

  /// The full celebration for a purchase that just landed in [context]'s
  /// card: the success haptic now, the burst after [burstDelay] unless
  /// motion is reduced. [haptics] defaults to the app's service, when one is
  /// registered.
  static void celebrate(
    BuildContext context, {
    FxLibrary? library,
    HapticsService? haptics,
  }) {
    final service =
        haptics ??
        (GetIt.instance.isRegistered<HapticsService>()
            ? GetIt.instance<HapticsService>()
            : null);
    // The success family (level won: medium then light).
    if (service != null) unawaited(service.play(HapticPattern.win));
    if (context.reduceMotion) return;
    Timer(burstDelay, () {
      if (!context.mounted) return;
      showOver(context, library: library);
    });
  }

  static const Duration _duration = Duration(milliseconds: 2200);

  static const List<({double dx, double dy, double size, double phaseMs})>
  _points = [
    (dx: 0.18, dy: 0.22, size: 22, phaseMs: 0),
    (dx: 0.82, dy: 0.18, size: 18, phaseMs: 300),
    (dx: 0.5, dy: 0.82, size: 20, phaseMs: 600),
  ];

  /// Finds [context]'s render box (a card's `GlobalKey`-free `context` is
  /// enough: it is called from inside the card that was tapped) and shows
  /// the burst over it in the nearest `Overlay`. A missing overlay or an
  /// unattached box (the widget was already disposed) does nothing.
  static void showOver(BuildContext context, {FxLibrary? library}) {
    final overlay = Overlay.maybeOf(context);
    final renderObject = context.findRenderObject();
    if (overlay == null ||
        renderObject is! RenderBox ||
        !renderObject.attached) {
      return;
    }
    final origin = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: origin.dx,
        top: origin.dy,
        width: size.width,
        height: size.height,
        child: IgnorePointer(
          child: Stack(
            children: [
              for (final t in _points)
                Positioned(
                  left: size.width * t.dx - t.size / 2,
                  top: size.height * t.dy - t.size / 2,
                  child: LottieTwinkle(
                    size: t.size,
                    phaseMs: t.phaseMs,
                    library: library,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Timer(_duration, () {
      if (entry.mounted) entry.remove();
    });
  }
}
