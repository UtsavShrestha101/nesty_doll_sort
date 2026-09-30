import 'package:flutter/widgets.dart';

/// Makes an overlay drawn inside its page (a `Stack` child, not a route of
/// its own: pause, out of moves, the win card, the Daily chest, the
/// figurine card) modal to a screen reader, as a real dialog route is:
///
/// - `BlockSemantics` drops every node painted before it, so the HUD, the
///   booster bar or the screen behind the card can't be reached or
///   activated while it is up;
/// - `scopesRoute` makes it a route of its own, so VoiceOver and TalkBack
///   announce it as it opens and move their focus into it (both engines
///   announce only a new route: iOS `accessibility_bridge.mm`, Android
///   `AccessibilityBridge.java`);
/// - its title names it: `RibbonTitle`, `NestySheet`'s title and the
///   overlays' own headings set `namesRoute` (review R11).
class ModalSemanticsScope extends StatelessWidget {
  const ModalSemanticsScope({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) => BlockSemantics(
    child: Semantics(
      container: true,
      scopesRoute: true,
      explicitChildNodes: true,
      child: child,
    ),
  );
}
