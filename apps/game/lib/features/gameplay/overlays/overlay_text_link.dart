import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The quiet text action under an overlay card's one button (NestyOverlay
/// `isBonus`'s "Back to Home", 4.9): Fredoka 16/700 in `textSecondary`
/// (#8A5B3A), with no face of its own, so the button above stays the card's
/// only call to action (review FIDELITY-11).
///
/// Its touch area is at least 48 dp (spec §16) around the text, which sits
/// centred in it: a caller that wants the frame's gap to the text subtracts
/// [slack] from it (above) and from the card's bottom padding (below).
/// Activating it plays the `button` sound and haptic ([TactileFeedback]),
/// like every other control.
class OverlayTextLink extends StatelessWidget {
  const OverlayTextLink({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;

  /// Null disables it.
  final VoidCallback? onPressed;

  /// The 48 dp touch area's margin above and below the 20 dp line at 1×
  /// text (`fontSize.textLink` is 16/20): (48 − 20) / 2.
  static const double slack = (48 - 20) / 2;

  /// `fontSize.textLink` (m7-6 item 15): Fredoka 700 16/20, in
  /// `#8A5B3A`.
  static final TextStyle style = AppTextStyleTokens.textLink.copyWith(
    color: AppColorTokens.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    final VoidCallback? activate = onPressed == null
        ? null
        : () {
            TactileFeedback.of(context)?.activate();
            onPressed();
          };
    return Semantics(
      button: true,
      enabled: activate != null,
      onTap: activate,
      child: TouchTarget(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          excludeFromSemantics: true,
          onTap: activate,
          child: Text(label, textAlign: TextAlign.center, style: style),
        ),
      ),
    );
  }
}
