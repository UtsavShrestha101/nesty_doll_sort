import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

/// "Icon button: 46–48 square, radius 17, surface gradient, 5px edge, 26–28px
/// glyph `#6E4526`" (design/README.md "Components"): the HUD pause (48/28),
/// the Home gear (46/27), a header back button (46/26).
///
/// Icon-only, so [semanticLabel] is required.
class IconTactileButton extends StatelessWidget {
  const IconTactileButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
    this.size = 48,
    this.iconSize = 28,
    this.iconColor = AppColors.iconBrown,
    this.minTouchSize = const Size.square(48),
    super.key,
  });

  /// A `NestyIcons.*` glyph.
  final IconData icon;
  final String semanticLabel;
  final VoidCallback? onPressed;
  final double size;
  final double iconSize;
  final Color iconColor;

  /// The touch area and screen-reader node around a smaller face: 48 dp by
  /// default (spec §10.3), so the 46 px header back and Home gear still
  /// take a full target (review R17, R18). Null keeps the face's own size.
  final Size? minTouchSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return TactileSurface(
      style: SurfaceStyles.raised,
      disabledStyle: SurfaceStyles.disabled,
      radius: const BorderRadius.all(Radius.circular(AppRadii.iconButton)),
      onPressed: onPressed,
      width: size,
      height: size,
      semanticLabel: semanticLabel,
      excludeChildSemantics: true,
      minTouchSize: minTouchSize,
      child: Icon(
        icon,
        size: iconSize,
        color: enabled ? iconColor : AppColors.disabledText,
      ),
    );
  }
}
