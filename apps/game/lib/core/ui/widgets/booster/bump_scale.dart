import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// A one-off bump: [child] grows to [scale] and back over [duration] each
/// time [trigger] changes (the chest's Collect: the coin pill and the Hint
/// badge bump 1.3× for 240 ms as the sprites land; `motion.chest.collect.
/// targetBump`). [trigger] 0 at the start plays nothing. Under reduced motion
/// it never moves.
class BumpScale extends StatefulWidget {
  const BumpScale({
    required this.trigger,
    required this.child,
    this.scale = ChestMotionTokens.collectTargetBump,
    this.duration = const Duration(
      milliseconds: ChestMotionTokens.collectTargetBumpMs,
    ),
    super.key,
  });

  /// Play once each time this value changes.
  final int trigger;
  final Widget child;
  final double scale;
  final Duration duration;

  @override
  State<BumpScale> createState() => _BumpScaleState();
}

class _BumpScaleState extends State<BumpScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void didUpdateWidget(BumpScale oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger && !context.reduceMotion) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    child: widget.child,
    builder: (context, child) {
      // Up over the first half, back over the second.
      final t = _controller.value;
      final k = t < 0.5 ? t * 2 : (1 - t) * 2;
      return Transform.scale(
        scale: 1 + (widget.scale - 1) * Curves.easeOut.transform(k),
        child: child,
      );
    },
  );
}
