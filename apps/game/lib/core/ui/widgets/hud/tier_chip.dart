import 'package:flutter/widgets.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
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
  const TierChip({required this.tier, this.compact = false, super.key});

  final Tier tier;

  /// textFit hudPills: when the pill can't hold the chip at its
  /// `minScale` 0.85, HARD drops to its flame glyph and SUPER HARD to its
  /// short form (`tierSuperShort`). A screen reader hears the full name
  /// either way (the pill's own label).
  final bool compact;

  /// Whether [tier] has a badge at all.
  static bool shows(Tier tier) => tier == Tier.hard || tier == Tier.superhard;

  /// The chip's width at its natural size, in the text scaler's units, for
  /// the pill that decides whether to go [compact].
  static double widthOf(
    BuildContext context,
    Tier tier, {
    required bool compact,
  }) {
    final spec = _specOf(context, tier, compact: compact);
    if (spec == null) return 0;
    final painter = TextPainter(
      text: TextSpan(text: spec.label, style: spec.style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final textWidth = spec.label.isEmpty ? 0.0 : painter.width;
    painter.dispose();
    final icon = spec.icon == null ? 0.0 : (spec.label.isEmpty ? 14.0 : 16.0);
    return spec.padding.resolve(Directionality.of(context)).horizontal +
        icon +
        textWidth;
  }

  static _ChipSpec? _specOf(
    BuildContext context,
    Tier tier, {
    required bool compact,
  }) {
    final l10n = context.localizations;
    return switch (tier) {
      Tier.easy || Tier.medium => null,
      Tier.hard => _ChipSpec(
        label: compact ? '' : l10n.tierHard,
        face: AppColorTokens.hardTint,
        ink: AppColorTokens.hardText,
        icon: NestyIcons.localFireDepartment,
        padding: compact
            ? const EdgeInsets.all(4)
            : const EdgeInsetsDirectional.fromSTEB(4, 4, 7, 4),
        style: AppTextStyleTokens.tierChip.copyWith(
          color: AppColorTokens.hardText,
        ),
      ),
      Tier.superhard => _ChipSpec(
        label: compact ? l10n.tierSuperShort : l10n.tierSuperHard,
        face: AppColorTokens.superHardTint,
        ink: AppColors.superHardChipText,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        style: AppTextStyleTokens.tierChip.copyWith(
          fontSize: 10,
          letterSpacing: context.script.tracking(0.2),
          color: AppColors.superHardChipText,
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final spec = _specOf(context, tier, compact: compact);
    if (spec == null) return const SizedBox.shrink();
    return _Chip(
      label: spec.label,
      face: spec.face,
      ink: spec.ink,
      icon: spec.icon,
      padding: spec.padding,
      style: spec.style,
    );
  }
}

final class _ChipSpec {
  const _ChipSpec({
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
              if (label.isNotEmpty) const SizedBox(width: 2),
            ],
            if (label.isNotEmpty)
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
