import 'dart:async';
import 'dart:ui' as ui;

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
/// With [trail], [trailDots] 6 dp dots follow each sprite along the path, at
/// path t − 0.1, − 0.2, … behind it, from 0.95 opacity near the sprite to
/// 0.35 at the tail; they fade over 200 ms once it lands (tokens.json
/// `motion.chest.collect.trail`, m7-4 1.7). One preallocated painter draws
/// them all, so a tick allocates no widgets for them (rule 8's spirit).
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

  /// The trail's `CustomPaint`, for tests.
  static const Key trailKey = Key('reward-flight-trail');

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
    bool trail = false,
    int trailDots = 5,
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
    // With a trail the last dots fade after the last sprite lands, so the
    // controller outlasts the flight; `onAllLanded` still fires at the
    // landing (below).
    final fadeMs = trail ? ChestCollectTokens.trailFadeMs.toDouble() : 0.0;
    final controller = AnimationController(
      vsync: vsync,
      duration: Duration(microseconds: ((totalMs + fadeMs) * 1000).round()),
    );
    final start = from.center;
    final end = to.center;
    // The arc's apex: the midpoint, lifted (a shallow parabola, not the
    // straight line a linear lerp would fly).
    final control = Offset.lerp(start, end, 0.5)! - Offset(0, arcHeight);
    // The path itself, by its own parameter p (0 at the start, 1 at the
    // target); the trail's dots sit on it behind the sprite.
    Offset pathAt(double p) {
      final q = 1 - p;
      return Offset(
        q * q * start.dx + 2 * q * p * control.dx + p * p * end.dx,
        q * q * start.dy + 2 * q * p * control.dy + p * p * end.dy,
      );
    }

    double eased(double t) =>
        UiMotionTokens.curveFly.transform(t.clamp(0.0, 1.0));
    Offset positionOf(double t) => pathAt(eased(t));

    final trailPainter = trail
        ? TrailDotsPainter(
            progress: controller,
            starts: starts,
            flightMs: flightMs,
            totalMs: totalMs + fadeMs,
            dots: trailDots,
            eased: eased,
            pathAt: pathAt,
          )
        : null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => IgnorePointer(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final elapsedMs = controller.value * (totalMs + fadeMs);
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
            return Stack(
              children: [
                if (trailPainter != null)
                  Positioned.fill(
                    child: CustomPaint(
                      key: RewardFlight.trailKey,
                      painter: trailPainter,
                    ),
                  ),
                ...children,
              ],
            );
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
      Timer(
        Duration(microseconds: (totalMs * 1000).round()),
        () => onAllLanded?.call(),
      ),
    ];
    final handle = RewardFlightHandle._(entry, controller, timers);
    controller.forward().whenComplete(() {
      if (handle._disposed) return;
      handle._disposed = true;
      if (entry.mounted) entry.remove();
      controller.dispose();
    });
    return handle;
  }
}

/// Draws the trail dots of every sprite in the air (tokens.json
/// `motion.chest.collect.trail`, m7-4 1.7): [dots] 6 dp dots in `#FFF1C9`
/// sit on the path behind the sprite at path t − 0.1, − 0.2, − 0.3, − 0.45,
/// − 0.6, at 0.95 opacity near the sprite and 0.35 at the tail. Once the
/// sprite lands they hold their place and fade out over 200 ms.
///
/// Built once per flight, with its [Paint] preallocated; [paint] only reads
/// the controller and draws circles.
class TrailDotsPainter extends CustomPainter {
  TrailDotsPainter({
    required this.progress,
    required this.starts,
    required this.flightMs,
    required this.totalMs,
    required this.dots,
    required this.eased,
    required this.pathAt,
  }) : assert(dots >= 1 && dots <= spacing.length, 'one to five dots'),
       super(repaint: progress);

  final Animation<double> progress;
  final List<double> starts;
  final double flightMs;

  /// The controller's whole run: the last flight and the fade after it.
  final double totalMs;

  /// How many dots follow a sprite (5 for a coin, 3 for the hint).
  final int dots;

  /// The flight's easing, time 0–1 to path 0–1.
  final double Function(double t) eased;

  /// The path's point at parameter 0–1.
  final Offset Function(double p) pathAt;

  /// A dot's diameter, near and tail opacities, and how long the trail takes
  /// to fade once its sprite has landed.
  static const double dotSize = ChestCollectTokens.trailDot;
  static const double headOpacity = ChestCollectTokens.trailOpacityHead;
  static const double tailOpacity = ChestCollectTokens.trailOpacityTail;
  static const double fadeMs = 0.0 + ChestCollectTokens.trailFadeMs;

  /// Each dot's distance behind the sprite on the path.
  static const List<double> spacing = ChestCollectTokens.trailSpacing;

  final ui.Paint _paint = ui.Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final elapsed = progress.value * totalMs;
    for (final start in starts) {
      final t = (elapsed - start) / flightMs;
      if (t < 0) continue;
      // After landing the trail holds at the end of the path and fades.
      final fade = t <= 1 ? 1.0 : 1 - (t - 1) * flightMs / fadeMs;
      if (fade <= 0) continue;
      final head = eased(t);
      for (var k = 0; k < dots; k++) {
        final p = head - spacing[k];
        if (p < 0) continue;
        final along = dots == 1 ? 0.0 : k / (dots - 1);
        _paint.color = ChestCollectTokens.trailColor.withValues(
          alpha: (headOpacity + (tailOpacity - headOpacity) * along) * fade,
        );
        canvas.drawCircle(pathAt(p), dotSize / 2, _paint);
      }
    }
  }

  @override
  bool shouldRepaint(TrailDotsPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.starts != starts ||
      oldDelegate.flightMs != flightMs;
}
