import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The dim behind overlays: `rgba(60,30,10,.55)` for the win, pause and
/// out-of-moves overlays, [Scrim.strong] `rgba(25,12,4,.86)` for Chapter
/// complete (tokens.json `color.scrim`, `color.scrimStrong`).
///
/// It blocks input to what's behind it. With [onDismiss] a tap on it
/// dismisses the overlay (the out-of-moves sheet); screen readers get
/// [dismissLabel] as the action.
class Scrim extends StatelessWidget {
  const Scrim({this.onDismiss, this.dismissLabel, this.opacity, super.key})
    : color = AppColorTokens.scrim;

  const Scrim.strong({
    this.onDismiss,
    this.dismissLabel,
    this.opacity,
    super.key,
  }) : color = AppColorTokens.scrimStrong;

  final Color color;
  final VoidCallback? onDismiss;
  final String? dismissLabel;

  /// Fades the scrim in and out with an overlay's transition
  /// (`motion.ui.modalIn`); null is fully shown.
  final Animation<double>? opacity;

  @override
  Widget build(BuildContext context) {
    final onDismiss = this.onDismiss;
    Widget scrim = ColoredBox(color: color);
    final opacity = this.opacity;
    if (opacity != null) scrim = FadeTransition(opacity: opacity, child: scrim);
    return Semantics(
      label: onDismiss == null ? null : dismissLabel,
      onTap: onDismiss,
      button: onDismiss != null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: onDismiss ?? () {},
        child: SizedBox.expand(child: scrim),
      ),
    );
  }
}
