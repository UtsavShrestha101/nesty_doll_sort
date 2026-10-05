import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// Under reduced motion a loading spinner doesn't spin: `ui_spinner` rests on
/// frame 0 and this pulses its opacity 1 → 0.45 → 1 over 1,600 ms, `easeInOut`,
/// looping (tokens.json `motion.spinner.reducedMotion`; frames 12.5, 7.5;
/// m7-4 4.17). With motion allowed it is [child] itself.
class SpinnerPulse extends StatefulWidget {
  const SpinnerPulse({required this.child, super.key});

  final Widget child;

  /// The pulse's period and its lowest opacity.
  static const Duration period = Duration(
    milliseconds: SpinnerMotionTokens.reducedMotionPulseMs,
  );
  static const double minOpacity = SpinnerMotionTokens.reducedMotionMinOpacity;

  @override
  State<SpinnerPulse> createState() => _SpinnerPulseState();
}

class _SpinnerPulseState extends State<SpinnerPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SpinnerPulse.period,
  );

  late final Animation<double> _opacity = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: SpinnerPulse.minOpacity,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 1,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: SpinnerPulse.minOpacity,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.easeInOut)),
      weight: 1,
    ),
  ]).animate(_controller);

  bool _reduced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = context.reduceMotion;
    if (reduced == _reduced && (_controller.isAnimating || !reduced)) return;
    _reduced = reduced;
    if (reduced) {
      _controller.repeat();
    } else {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _reduced
      ? FadeTransition(opacity: _opacity, child: widget.child)
      : widget.child;
}
