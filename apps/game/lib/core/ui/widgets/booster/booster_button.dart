import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/booster/booster_badge.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

export 'package:nesty_game/core/ui/widgets/booster/booster_badge.dart';

/// "Booster button: 80×58, radius 18, surface gradient, 5px edge `#CFA36A`,
/// 25px glyph plus 13/600 label. Badges sit at top-right" (design/README.md
/// "Components"; NestyBoard booster bar). The bar sizes it
/// `min(80, (W − 56) / 4)` wide ([width]).
///
/// [glow] is the soft-stuck suggestion (frame 3.4: `ui_booster_glow`, a
/// Lottie the screens lane passes in). It is drawn behind the button in a
/// 130×110 box centred on it, as LOTTIE.md anchors it.
///
/// Disabled ([onPressed] null, e.g. nothing to undo) it can't be pressed and
/// its glyph and label fade; the badge stays readable.
/// TODO(design): no frame shows a disabled booster.
class BoosterButton extends StatelessWidget {
  const BoosterButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.badge,
    this.glow,
    this.width = 80,
    this.color = AppColors.iconBrown,
    super.key,
  });

  /// A `NestyIcons.*` glyph (undo, lightbulb, add_box, restart_alt).
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final BoosterBadge? badge;

  /// Drawn behind the button (the `ui_booster_glow` Lottie).
  final Widget? glow;
  final double width;

  /// Glyph and label colour: brown, or `#2F7A3E` for +Slot (NestyBoard
  /// `BST`).
  final Color color;

  static const double height = 58;

  /// The glow's box (LOTTIE.md `ui_booster_glow`, 130×110).
  static const Size glowSize = Size(130, 110);

  static const double _disabledOpacity = 0.45;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final button = TactileSurface(
      style: SurfaceStyles.booster,
      radius: const BorderRadius.all(Radius.circular(AppRadii.booster)),
      onPressed: onPressed,
      width: width,
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      semanticLabel: _semantics(context),
      excludeChildSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : _disabledOpacity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 25, color: color),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: AppTextStyleTokens.boosterLabel.copyWith(color: color),
                maxLines: 1,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
    final badge = this.badge;
    final glow = this.glow;
    if (badge == null && glow == null) return button;
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (glow != null)
            Positioned(
              left: (width - glowSize.width) / 2,
              top: (height - glowSize.height) / 2,
              width: glowSize.width,
              height: glowSize.height,
              child: IgnorePointer(child: glow),
            ),
          Positioned.fill(child: button),
          if (badge != null)
            PositionedDirectional(
              end: -badge.cornerOffset.dx,
              top: badge.cornerOffset.dy,
              child: IgnorePointer(child: BoosterBadgeView(badge: badge)),
            ),
        ],
      ),
    );
  }

  String _semantics(BuildContext context) {
    final l10n = context.localizations;
    return switch (badge) {
      null => label,
      BoosterCountBadge(:final count) => l10n.boosterCountSemantics(
        label,
        count,
      ),
      BoosterAdBadge() => l10n.boosterAdSemantics(label),
      BoosterCoinBadge(:final price) => l10n.boosterCoinSemantics(label, price),
    };
  }
}
