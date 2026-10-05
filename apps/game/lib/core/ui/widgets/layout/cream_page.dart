import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The menu pages' backdrop (frames 2.1, 6.x, 8.1): `gradient.canvas`, a
/// vertical `canvasCream` to `canvasCreamLow` gradient over the full screen
/// height, that fills the Scaffold body (m7-4 8.2).
///
/// Put it as the Scaffold's `body`, with the page's `SafeArea` inside it, so
/// the gradient runs under the system bars. The Scaffold keeps its own
/// opaque `canvasCream` background: during a route transition the page below
/// must never show through.
class CreamPage extends StatelessWidget {
  const CreamPage({required this.child, super.key});

  final Widget child;

  /// The gradient (`gradient.canvas`; read by the test).
  static const gradient = AppGradientTokens.canvas;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(gradient: gradient),
    child: SizedBox.expand(child: child),
  );
}
