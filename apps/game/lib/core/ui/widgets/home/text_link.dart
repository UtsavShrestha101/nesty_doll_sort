import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_feedback.dart';
import 'package:nesty_game/core/ui/widgets/tactile/touch_target.dart';

/// A text-only action under a card's primary button ("Not now", "No thanks";
/// tokens `textLink`, menus spec 0.5): Fredoka 700 16 in `textSecondary`,
/// `#6E4526` while pressed, no underline. The face is 36 tall and the touch
/// target 48 dp wide and tall (lead note 3: the 48 dp rule wins over the
/// spec's 44). It plays the `button` sound and haptic like every control;
/// under reduce motion nothing else changes (the colour swap is all).
///
/// [accent] is the orange sibling ("Change time" in the reminder offer,
/// frame 10.2): `primaryEdge` instead of `textSecondary`.
///
/// `TODO(design)`: `textLink.pressed` has no colour token name (`#6E4526` is
/// `color.computerTagText`), and the orange sibling is frame-only
/// (menus spec §11 gaps 1).
class TextLink extends StatefulWidget {
  const TextLink({
    required this.label,
    required this.onPressed,
    this.accent = false,
    this.semanticLabel,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool accent;

  /// Overrides the screen-reader label ([label] by default).
  final String? semanticLabel;

  /// The face's height (`textLink` visual 36).
  static const double faceHeight = 36;

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
        ? AppColorTokens.primaryEdge
        : _pressed
        ? TextLinkTokens.pressed
        : AppColorTokens.textSecondary;
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
            height: TextLink.faceHeight,
            child: Center(
              widthFactor: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
