import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Where a reward sprite flies to: the on-screen rect of a target widget
/// (the HUD coin pill, the Hint booster button), read live at collect time
/// rather than cached, so a rotation or a late layout still lands
/// correctly. Null means the target doesn't exist on this screen (the day-7
/// chest has no HUD): the caller bursts in place instead of flying
/// (m7-design chest sequence step 4 "Collect").
typedef RewardFlightTarget = Rect? Function();

/// A reward flight still in the air; [dispose] tears it down early (the
/// widget that started it was removed before the flight finished).
final class RewardFlightHandle {
  RewardFlightHandle._(this._entry, this._controller, this._timers);

  final OverlayEntry _entry;
  final AnimationController _controller;
  final List<Timer> _timers;
  bool _disposed = false;

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    for (final timer in _timers) {
      timer.cancel();
    }
    if (_entry.mounted) _entry.remove();
    _controller.dispose();
  }
}

/// Flies [count] copies of [spriteBuilder] from [from]'s centre to [to]'s
/// centre along a short upward arc (`tokens.json` `easing.fly`, the same
/// curve the doll completion flight uses), staggered [stagger] apart
/// (m7-design chest sequence step 4: "staggered about 40 ms"). Drawn in the
/// nearest [Overlay] (the shop's `PurchaseTwinkleBurst` precedent), so a
/// sprite crosses the whole screen regardless of the modal card's own
/// bounds.
///
/// [onLanded] fires once per sprite, in the order they land, the instant
/// each reaches [to] (releases a HUD count hold, ticks a haptic).
/// [onAllLanded] fires once, after the last one; always fires, even with
/// [count] 0 (nothing to fly), so a caller can chain the next step
/// unconditionally.
///
/// The arc's control point, every sprite's start and every landing time are
/// computed once, here; per tick only the small widget tree of the sprites
/// in the air is rebuilt, as any Flutter animation's is. This is Flutter UI,
/// not the Flame update/render hot path that CLAUDE.md rule 8 covers.
final class RewardFlight {
  const RewardFlight._();

  static RewardFlightHandle? launch(
    BuildContext context, {
    required Rect from,
    required Rect to,
    required int count,
    required WidgetBuilder spriteBuilder,
    required TickerProvider vsync,
    Duration stagger = const Duration(milliseconds: 40),
    Duration flightDuration = const Duration(milliseconds: 520),
    double arcHeight = 90,
    void Function(int index)? onLanded,
    VoidCallback? onAllLanded,
  }) {
    final overlay = Overlay.maybeOf(context);
    if (overlay == null || count <= 0) {
      onAllLanded?.call();
      return null;
    }
    final staggerMs = stagger.inMicroseconds / 1000;
    final flightMs = flightDuration.inMicroseconds / 1000;
    final starts = List<double>.generate(count, (i) => staggerMs * i);
    final totalMs = starts.last + flightMs;
    final controller = AnimationController(
      vsync: vsync,
      duration: Duration(microseconds: (totalMs * 1000).round()),
    );
    final start = from.center;
    final end = to.center;
    // The arc's apex: the midpoint, lifted (a shallow parabola, not the
    // straight line a linear lerp would fly).
    final control = Offset.lerp(start, end, 0.5)! - Offset(0, arcHeight);
    Offset positionOf(double t) {
      final eased = UiMotionTokens.curveFly.transform(t.clamp(0.0, 1.0));
      final u = 1 - eased;
      return Offset(
        u * u * start.dx + 2 * u * eased * control.dx + eased * eased * end.dx,
        u * u * start.dy + 2 * u * eased * control.dy + eased * eased * end.dy,
      );
    }

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final elapsedMs = controller.value * totalMs;
            final children = <Widget>[];
            for (var i = 0; i < count; i++) {
              final t = (elapsedMs - starts[i]) / flightMs;
              if (t < 0 || t > 1) continue;
              final at = positionOf(t);
              // A quick fade at both ends of its own flight, not the whole
              // sequence's: never mid-flight, so it costs nothing extra.
              final opacity = t < 0.12
                  ? t / 0.12
                  : (t > 0.88 ? (1 - t) / 0.12 : 1.0);
              children.add(
                Positioned(
                  left: at.dx,
                  top: at.dy,
                  child: FractionalTranslation(
                    translation: const Offset(-0.5, -0.5),
                    child: Opacity(
                      opacity: opacity,
                      child: spriteBuilder(context),
                    ),
                  ),
                ),
              );
            }
            return Stack(children: children);
          },
        ),
      ),
    );
    overlay.insert(entry);

    final timers = <Timer>[
      for (var i = 0; i < count; i++)
        Timer(
          Duration(microseconds: ((starts[i] + flightMs) * 1000).round()),
          () => onLanded?.call(i),
        ),
    ];
    final handle = RewardFlightHandle._(entry, controller, timers);
    controller.forward().whenComplete(() {
      if (handle._disposed) return;
      handle._disposed = true;
      if (entry.mounted) entry.remove();
      controller.dispose();
      onAllLanded?.call();
    });
    return handle;
  }
}
