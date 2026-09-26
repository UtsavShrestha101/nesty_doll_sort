import 'package:flutter/widgets.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';

/// The tier badge inside the level pill (spec §6.6: red "HARD", purple
/// "SUPER HARD"; NestyBoard HUD).
///
/// * Hard: `#FFF1EE` chip, `#C33338` flame + "HARD", 11/700 +0.06 em.
/// * Super hard: `#F4ECFF` chip, `#6A31A6` "SUPER HARD", 10/700 +0.02 em,
///   no glyph (the frame drops it to fit).
///
/// Easy and medium levels have no badge: [shows] is false and the widget is
/// empty.
class TierChip extends StatelessWidget {
  const TierChip({required this.tier, super.key});

  final Tier tier;

  /// Whether [tier] has a badge at all.
  static bool shows(Tier tier) => tier == Tier.hard || tier == Tier.superhard;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return switch (tier) {
      Tier.easy || Tier.medium => const SizedBox.shrink(),
      Tier.hard => _Chip(
        label: l10n.tierHard,
        face: AppColorTokens.hardTint,
        ink: AppColorTokens.hardText,
        icon: NestyIcons.localFireDepartment,
        padding: const EdgeInsetsDirectional.fromSTEB(4, 4, 7, 4),
        style: AppTextStyleTokens.tierChip,
      ),
      Tier.superhard => _Chip(
        label: l10n.tierSuperHard,
        face: AppColorTokens.superHardTint,
        ink: AppColors.superHardChipText,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        style: AppTextStyleTokens.tierChip.copyWith(
          fontSize: 10,
          letterSpacing: 0.2,
        ),
      ),
    };
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.face,
    required this.ink,
    required this.padding,
    required this.style,
    this.icon,
  });

  final String label;
  final Color face;
  final Color ink;
  final EdgeInsetsGeometry padding;
  final TextStyle style;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: face,
        borderRadius: const BorderRadius.all(Radius.circular(9)),
      ),
      child: Padding(
        padding: padding,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: ink),
              const SizedBox(width: 2),
            ],
            Text(
              label,
              style: style.copyWith(color: ink),
              maxLines: 1,
              softWrap: false,
            ),
          ],
        ),
      ),
    );
  }
}
