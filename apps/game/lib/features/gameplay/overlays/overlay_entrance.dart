import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// How an overlay arrives (design/README.md "Motion": widget transitions
/// stay Flutter animations on `tokens.motion.ui`, PROGRESS D40).
enum OverlayEntranceKind {
  /// Modal cards (pause 3.9, all levels done 4.9): fade and grow from 0.92,
  /// `modalIn` 240 ms.
  modal(UiMotionTokens.modalInMs),

  /// Bottom sheets (out of moves 3.5): rise from below the screen,
  /// `sheetIn` 280 ms.
  sheet(UiMotionTokens.sheetInMs),

  /// Full-screen celebrations (win 2.8): the scrim and content fade in, the
  /// content's own motion is Lottie.
  fade(UiMotionTokens.modalInMs);

  const OverlayEntranceKind(this.milliseconds);

  final int milliseconds;
}

/// Plays an overlay's entrance once when it is inserted: [builder] gets
/// the 0–1 progress for the scrim, and [child] arrives with [kind]'s
/// motion. Halved under reduced motion (D48). To a screen reader the
/// overlay is modal ([ModalSemanticsScope]).
class OverlayEntrance extends StatefulWidget {
  const OverlayEntrance({
    required this.kind,
    required this.builder,
    required this.child,
    super.key,
  });

  final OverlayEntranceKind kind;

  /// Lays out the overlay: the scrim (fed [Animation] as its opacity) and
  /// the already-animated content.
  final Widget Function(
    BuildContext context,
    Animation<double> progress,
    Widget content,
  )
  builder;

  final Widget child;

  @override
  State<OverlayEntrance> createState() => _OverlayEntranceState();
}

class _OverlayEntranceState extends State<OverlayEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this);
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: UiMotionTokens.curveEaseOut,
  );
  late final Animation<double> _scale = Tween<double>(
    begin: 0.92,
    end: 1,
  ).animate(_curve);
  late final Animation<Offset> _rise = Tween<Offset>(
    begin: const Offset(0, 1),
    end: Offset.zero,
  ).animate(_curve);

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _controller
      ..duration = context.uiDuration(widget.kind.milliseconds)
      ..forward();
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = widget.child;
    // The content is in the semantics tree from its first frame, so the
    // scope below is announced as the overlay opens, not once the fade is
    // done.
    final Widget content = switch (widget.kind) {
      OverlayEntranceKind.modal => FadeTransition(
        opacity: _curve,
        alwaysIncludeSemantics: true,
        child: ScaleTransition(scale: _scale, child: child),
      ),
      OverlayEntranceKind.sheet => SlideTransition(
        position: _rise,
        child: child,
      ),
      OverlayEntranceKind.fade => FadeTransition(
        opacity: _curve,
        alwaysIncludeSemantics: true,
        child: child,
      ),
    };
    // A route of its own to a screen reader, over a page it hides: nothing
    // behind the overlay can be reached or activated (review R11).
    return ModalSemanticsScope(child: widget.builder(context, _curve, content));
  }
}
