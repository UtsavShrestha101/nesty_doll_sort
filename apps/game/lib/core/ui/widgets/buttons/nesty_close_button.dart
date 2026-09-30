import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

/// "Close button: 36–38 circle `#F6E2C2` with a 3px inner bottom shadow"
/// (design/README.md "Components"; NestyOverlay buy and pause cards).
/// Pressed, it moves down 2 px and the shade shrinks to 1 px.
///
/// The 36 px circle sits centred in a 48 dp touch target (spec §10.3), so
/// the widget's box is 48: a card's "inset 12" for the circle is
/// `12 − (48 − 36) / 2 = 6` for the box ([boxInset]).
class NestyCloseButton extends StatelessWidget {
  const NestyCloseButton({
    required this.onPressed,
    this.diameter = 36,
    this.semanticLabel,
    super.key,
  });

  final VoidCallback? onPressed;
  final double diameter;

  /// Defaults to the localized "Close".
  final String? semanticLabel;

  /// The box inset that puts the circle [visualInset] from a corner.
  static double boxInset(double visualInset, {double diameter = 36}) =>
      visualInset - (48 - diameter) / 2;

  @override
  Widget build(BuildContext context) {
    // The target is inside the button's node, so a screen reader's focus
    // box is 48 dp too, not just the circle (review R24).
    return TactileSurface(
      style: SurfaceStyles.closeButton,
      radius: BorderRadius.circular(diameter / 2),
      onPressed: onPressed,
      width: diameter,
      height: diameter,
      semanticLabel: semanticLabel ?? context.localizations.closeSemantics,
      excludeChildSemantics: true,
      minTouchSize: const Size.square(48),
      child: Icon(
        NestyIcons.close,
        size: diameter * 22 / 36,
        color: AppColors.iconBrown,
      ),
    );
  }
}
