import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_feedback.dart';
import 'package:nesty_game/core/ui/widgets/tactile/touch_target.dart';

/// A text-only action under a card's primary button ("Not now", "No thanks",
/// "Turn off"; tokens `textLink`, m7-4 1.4): Fredoka 700 16 in `color` (#8A5B3A),
/// `pressed` (#6E4526) while pressed, no underline, in a 48 dp tall box
/// (`minTapHeight`: the hit box and the layout box are the same, so a card's
/// gap to the link is the frame's). It plays the `button` sound and haptic
/// like every control; under reduce motion nothing else changes (the colour
/// swap is all).
///
/// [accent] is the orange sibling ("Change time" in the reminder offer, frame
/// 10.2): `accentColor` (#C4631E), `accentPressed` (#A94F12) while pressed.
class TextLink extends StatefulWidget {
  const TextLink({
    required this.label,
    required this.onPressed,
    this.accent = false,
    this.semanticLabel,
    this.inline = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool accent;

  /// Overrides the screen-reader label ([label] by default).
  final String? semanticLabel;

  /// A link set in a row of actions (Settings' blocked reminder): no side
  /// padding, so the gap to its neighbour is the frame's and a wrapped link
  /// lines up with the first action's edge. The 48 dp hit box stays.
  final bool inline;

  /// The box's height: the 48 dp hit box (`textLink.minTapHeight`).
  static const double boxHeight = TextLinkTokens.minTapHeight;

  @override
  State<TextLink> createState() => _TextLinkState();
}

class _TextLinkState extends State<TextLink> {
  bool _pressed = false;

  void _set(bool value) {
    if (_pressed != value && mounted) setState(() => _pressed = value);
  }

  void _activate() {
    final onPressed = widget.onPressed;
    if (onPressed == null) return;
    TactileFeedback.of(context)?.activate();
    onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final color = widget.accent
        ? (_pressed ? TextLinkTokens.accentPressed : TextLinkTokens.accentColor)
        : (_pressed ? TextLinkTokens.pressed : TextLinkTokens.color);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel ?? widget.label,
      onTap: enabled ? _activate : null,
      excludeSemantics: true,
      child: TouchTarget(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _set(true) : null,
          onTapCancel: () => _set(false),
          onTapUp: (_) => _set(false),
          onTap: enabled ? _activate : null,
          child: SizedBox(
            height: TextLink.boxHeight,
            child: Center(
              widthFactor: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.inline ? 0 : 12,
                ),
                child: Text(
                  widget.label,
                  style: TextLinkTokens.font.copyWith(color: color),
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
