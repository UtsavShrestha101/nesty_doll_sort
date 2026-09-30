import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/tactile_button_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

export 'package:nesty_game/core/ui/widgets/buttons/tactile_button_style.dart';

/// A labelled tactile button (design/README.md "Components": primary,
/// secondary, rewarded ad; plus success, danger and teal).
///
/// Full width by default ([expand]), as buttons sit inside cards. A long
/// label (German, 1.3× text) shrinks to fit rather than overflow. With
/// [onPressed] null the button is disabled: flat and sunk, like the frame
/// 3.8 coin button, with muted text.
class TactileButton extends StatelessWidget {
  const TactileButton({
    required this.label,
    required this.onPressed,
    this.variant = TactileButtonVariant.primary,
    this.size = TactileButtonSize.large,
    this.icon,
    this.leading,
    this.expand = true,
    this.semanticLabel,
    this.minTouchSize,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final TactileButtonVariant variant;
  final TactileButtonSize size;

  /// A glyph before the label (`NestyIcons.*`).
  final IconData? icon;

  /// A custom leading widget (the coin, the ▶ box), used instead of [icon].
  final Widget? leading;

  /// True fills the width it's given; false hugs the label.
  final bool expand;

  /// Overrides the label read by screen readers.
  final String? semanticLabel;

  /// Grows the touch area and screen-reader node around a shorter face
  /// ([TactileSurface.minTouchSize]): a compact (38) button standing alone
  /// passes 48 dp (spec §10.3).
  final Size? minTouchSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final foreground = enabled ? variant.foreground : AppColors.disabledText;
    final textShadow = enabled ? variant.textShadow : null;
    final isSecondary = variant == TactileButtonVariant.secondary;
    final style = AppTextStyleTokens.button.copyWith(
      fontSize: isSecondary ? size.secondaryFontSize : size.fontSize,
      fontWeight: variant.fontWeight,
      color: foreground,
      shadows: textShadow == null
          ? null
          : [Shadow(color: textShadow, offset: const Offset(0, 2))],
    );
    final lead =
        leading ??
        (icon == null
            ? null
            : Icon(icon, size: size.iconSize, color: foreground));
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (lead != null) ...[lead, SizedBox(width: size.gap)],
        Text(label, style: style, maxLines: 1, softWrap: false),
      ],
    );
    return TactileSurface(
      style: variant.surface(size.edge),
      disabledStyle: SurfaceStyles.disabled,
      radius: BorderRadius.circular(size.radius),
      onPressed: onPressed,
      width: expand ? double.infinity : null,
      height: size.height,
      padding: EdgeInsets.symmetric(horizontal: size.padding),
      semanticLabel: semanticLabel ?? label,
      excludeChildSemantics: true,
      minTouchSize: minTouchSize,
      child: FittedBox(fit: BoxFit.scaleDown, child: content),
    );
  }
}
