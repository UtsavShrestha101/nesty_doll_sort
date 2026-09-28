import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// The orange title pill that sits on a modal card's top edge: "Orange
/// ribbon title pill at top −18 (padding 9/22, radius 16, 18/700 white)"
/// (design/README.md "Modal card"; NestyOverlay "Paused", buy popups).
///
/// One line; a title longer than the space it's given scales down.
class RibbonTitle extends StatelessWidget {
  const RibbonTitle(
    this.title, {
    this.gradient = AppGradientTokens.primary,
    this.edgeColor = AppColorTokens.primaryEdge,
    super.key,
  });

  /// The 7-day chest's streak ribbon (NestyMenus 5.6; `ModalCard.ribbon`).
  const RibbonTitle.streak(this.title, {super.key})
    : gradient = AppGradientTokens.streak,
      edgeColor = AppColorTokens.streakEdge;

  final String title;
  final Gradient gradient;
  final Color edgeColor;

  /// How far the ribbon rises above the card's top edge.
  static const double overhang = 18;

  @override
  Widget build(BuildContext context) {
    final style = SurfaceStyle(
      gradient: gradient,
      shadows: [
        const NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2),
        NestyShadow(color: edgeColor, dy: 4),
      ],
    );
    return Semantics(
      header: true,
      child: NestySurface(
        style: style,
        radius: const BorderRadius.all(Radius.circular(16)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            style: AppTextStyleTokens.button.copyWith(
              fontSize: 18,
              color: const Color(0xFFFFFFFF),
            ),
            maxLines: 1,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
