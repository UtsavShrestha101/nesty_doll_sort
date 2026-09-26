import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

/// The icon tile's colours: brown on cream, or green for the recommended
/// action (NestyOverlay OOM +1 Slot).
enum SheetRowTone {
  neutral(face: AppColors.closeFill, glyph: AppColors.iconBrown),
  success(face: AppColors.iconTileGreen, glyph: AppColorTokens.successEdge);

  const SheetRowTone({required this.face, required this.glyph});

  final Color face;
  final Color glyph;
}

/// A bottom-sheet row: "20-radius white cards with a 44px icon tile, title
/// 18/700, subtitle 13/600, and a trailing action" (design/README.md
/// "Bottom sheet"; NestyOverlay 3.5).
///
/// With [onTap] the whole row is a tactile button (Restart, with a
/// [SheetRow.chevron]); otherwise [trailing] holds the actions (the ▶ and
/// coin price of +1 Slot, or a [SheetRowTag]). [highlighted] adds the
/// frame's 3 px green ring.
class SheetRow extends StatelessWidget {
  const SheetRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.tone = SheetRowTone.neutral,
    this.highlighted = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final SheetRowTone tone;
  final bool highlighted;

  /// The Restart row's trailing chevron.
  static const Widget chevron = Icon(
    NestyIcons.chevronRight,
    size: 26,
    color: AppColors.chevron,
  );

  static const BorderRadius radius = BorderRadius.all(Radius.circular(20));
  static const EdgeInsets padding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    final content = Row(
      children: [
        _IconTile(icon: icon, tone: tone),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: AppTextStyleTokens.cardTitle.copyWith(
                  fontSize: 18,
                  color: AppColorTokens.textPrimary,
                ),
              ),
              if (subtitle != null)
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 13,
                    height: 1.3,
                    color: AppColorTokens.textSecondary,
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) ...[const SizedBox(width: 8), trailing],
      ],
    );
    final style = highlighted
        ? SurfaceStyles.rowHighlighted
        : SurfaceStyles.row;
    final onTap = this.onTap;
    if (onTap == null) {
      return MergeSemantics(
        child: NestySurface(
          style: style,
          radius: radius,
          padding: padding,
          child: content,
        ),
      );
    }
    return TactileSurface(
      style: style,
      radius: radius,
      onPressed: onTap,
      padding: padding,
      width: double.infinity,
      alignment: AlignmentDirectional.centerStart,
      child: content,
    );
  }
}

class _IconTile extends StatelessWidget {
  const _IconTile({required this.icon, required this.tone});

  final IconData icon;
  final SheetRowTone tone;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 44,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: tone.face,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.md)),
      ),
      child: Icon(icon, size: 26, color: tone.glyph),
    ),
  );
}

/// A row's status tag, such as the Undo row's "Free · 1 left": green on
/// mint with a 2 px inner ring (NestyOverlay 3.5).
class SheetRowTag extends StatelessWidget {
  const SheetRowTag(this.label, {super.key});

  final String label;

  static const _style = SurfaceStyle(
    color: AppColorTokens.successTint,
    shadows: [
      NestyShadow(color: AppColorTokens.successRing, inset: true, spread: 2),
    ],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _style,
    radius: const BorderRadius.all(Radius.circular(AppRadii.md)),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    child: Text(
      label,
      style: AppTextStyleTokens.buttonSmall.copyWith(
        fontSize: 14,
        color: AppColorTokens.successEdge,
      ),
      maxLines: 1,
      softWrap: false,
    ),
  );
}
