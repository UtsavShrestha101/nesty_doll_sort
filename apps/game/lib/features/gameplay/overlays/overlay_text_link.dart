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

  /// The 48 dp touch area's margin above and below the 16 px line at 1×
  /// text: (48 − 16) / 2.
  static const double slack = (48 - 16) / 2;

  /// NestyOverlay: `font:700 16px/1 'Fredoka'; color:#8A5B3A`.
  // TODO(design): tokens.json has no 16 px Fredoka style for a text link;
  // this is `buttonSmall` (17 px) at the frame's 16 px.
  static final TextStyle style = AppTextStyleTokens.buttonSmall.copyWith(
    fontSize: 16,
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
