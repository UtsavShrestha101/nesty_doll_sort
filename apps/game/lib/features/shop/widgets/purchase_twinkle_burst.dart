import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';

/// A skin or theme purchase's celebration (tokens `motion.purchaseItem`, m7-4
/// 4.11; no card): `jingle_reward` plays at 0 (`JingleCues.reward`, called by
/// the cubit when the purchase lands); [celebrate] adds the `success` haptic
/// at 0 and three `fx_sparkle` around the card or button that was just bought
/// (`PurchaseItemTokens.sparkleCount`), a few tens of ms apart. The price
/// chip's swap to Equip / Use with `motion.tagPop` is `TagPop`'s, and the
/// header balance's count down over 400 ms is `ScreenHeader`'s.
///
/// Reduce motion: no sparkles; the jingle and the haptic stay.
abstract final class PurchaseTwinkleBurst {
  /// The sparkles start with the swap: no wait (m7-4 4.11; the 300 ms of the
  /// coin pack's 7.2 is that card's).
  static const Duration burstDelay = Duration.zero;

  /// The full celebration for a purchase that just landed in [context]'s
  /// card: the success haptic now and the sparkles, unless motion is
  /// reduced. [haptics] defaults to the app's service, when one is
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
    showOver(context, library: library);
  }

  /// A sparkle's canvas is 64 dp (`fx_sparkle`); the art in it is a small
  /// star, so these draw it a little larger than the old twinkles.
  static const List<({double dx, double dy, double size, int delayMs})>
  _points = [
    (dx: 0.18, dy: 0.22, size: 44, delayMs: 0),
    (dx: 0.82, dy: 0.18, size: 38, delayMs: 90),
    (dx: 0.5, dy: 0.82, size: 42, delayMs: 180),
  ];

  /// Long enough for the last sparkle (16 frames) to finish.
  static const Duration _duration = Duration(milliseconds: 900);

  /// Finds [context]'s render box (a card's `GlobalKey`-free `context` is
  /// enough: it is called from inside the card that was tapped) and shows
  /// the sparkles over it in the nearest `Overlay`. A missing overlay or an
  /// unattached box (the widget was already disposed) does nothing.
  static void showOver(BuildContext context, {FxLibrary? library}) {
    // The cards celebrate from didUpdateWidget, inside a build: the overlay
    // can't be marked dirty then, and the card's box isn't laid out yet.
    // Measure and insert once the frame is done.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) showOver(context, library: library);
      });
      return;
    }
    final overlay = Overlay.maybeOf(context);
    final renderObject = context.findRenderObject();
    if (overlay == null ||
        renderObject is! RenderBox ||
        !renderObject.attached) {
      return;
    }
    assert(_points.length == PurchaseItemTokens.sparkleCount);
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
            clipBehavior: Clip.none,
            children: [
              for (final t in _points)
                Positioned(
                  left: size.width * t.dx - t.size / 2,
                  top: size.height * t.dy - t.size / 2,
                  width: t.size,
                  height: t.size,
                  child: _Sparkle(delayMs: t.delayMs, library: library),
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

/// One `fx_sparkle`, played once after [delayMs] (nothing is drawn before).
class _Sparkle extends StatefulWidget {
  const _Sparkle({required this.delayMs, this.library});

  final int delayMs;
  final FxLibrary? library;

  @override
  State<_Sparkle> createState() => _SparkleState();
}

class _SparkleState extends State<_Sparkle> {
  Timer? _timer;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    if (widget.delayMs == 0) {
      _started = true;
    } else {
      _timer = Timer(Duration(milliseconds: widget.delayMs), () {
        if (mounted) setState(() => _started = true);
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_started) return const SizedBox.shrink();
    return LottieFxView(id: FxId.fxSparkle, library: widget.library);
  }
}
