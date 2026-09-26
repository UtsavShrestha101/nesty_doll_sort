import 'package:flutter/widgets.dart';
import 'package:nesty_core/nesty_core.dart' show Tier;
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/hud/tier_chip.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';

/// The HUD level pill, "height 46, radius 18. Always centered at x = 195,
/// top 62" (design/README.md "Components"; NestyBoard HUD):
/// * **normal** (easy, medium): surface, "Level 14" 18/700;
/// * **hard**: red gradient, white text, [TierChip] "HARD";
/// * **super hard**: purple gradient, 17/700, "SUPER HARD";
/// * **daily** and **bonus** are stubs for M5/M3 ([LevelPill.daily],
///   [LevelPill.bonus]).
///
/// Not pressable. It never overflows: given less width than it needs (a
/// long translation at 1.3× text between the pause button and the coins),
/// its content scales down.
class LevelPill extends StatelessWidget {
  /// The pill for level [level] of [tier].
  const LevelPill({required int this.level, required Tier this.tier, super.key})
    : _kind = null,
      dateLabel = null;

  /// Daily puzzle: calendar glyph, "Daily" and a date chip ("Sep 26").
  const LevelPill.daily({required String this.dateLabel, super.key})
    : _kind = _Kind.daily,
      level = null,
      tier = null;

  /// Bonus Endless: "Bonus Level N" on teal (spec §7.1).
  const LevelPill.bonus({required int this.level, super.key})
    : _kind = _Kind.bonus,
      tier = null,
      dateLabel = null;

  final int? level;
  final Tier? tier;
  final String? dateLabel;
  final _Kind? _kind;

  _Kind get _resolvedKind =>
      _kind ??
      switch (tier!) {
        Tier.easy || Tier.medium => _Kind.normal,
        Tier.hard => _Kind.hard,
        Tier.superhard => _Kind.superHard,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final kind = _resolvedKind;
    final String label;
    final String semantics;
    switch (kind) {
      case _Kind.normal:
        label = l10n.levelTitle(level!);
        semantics = label;
      case _Kind.hard || _Kind.superHard:
        label = l10n.levelTitle(level!);
        semantics = l10n.levelWithTier(level!, l10n.tierName(tier!.id));
      case _Kind.daily:
        label = l10n.levelDaily;
        semantics = l10n.levelDailySemantics(dateLabel!);
      case _Kind.bonus:
        label = l10n.bonusLevelTitle(level!);
        semantics = label;
    }
    final text = Text(
      label,
      style: kind.textStyle,
      maxLines: 1,
      softWrap: false,
    );
    final Widget content = switch (kind) {
      _Kind.normal || _Kind.bonus => text,
      _Kind.hard || _Kind.superHard => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          text,
          SizedBox(width: kind.gap),
          TierChip(tier: tier!),
        ],
      ),
      _Kind.daily => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            NestyIcons.calendarToday,
            size: 22,
            color: AppColors.dailyText,
          ),
          SizedBox(width: kind.gap),
          text,
          SizedBox(width: kind.gap),
          _DateChip(label: dateLabel!),
        ],
      ),
    };
    return Semantics(
      label: semantics,
      excludeSemantics: true,
      child: NestySurface(
        style: kind.surface,
        radius: const BorderRadius.all(Radius.circular(AppRadii.hudPill)),
        height: HudTokens.levelPillHeight,
        padding: kind.padding,
        alignment: Alignment.center,
        child: FittedBox(fit: BoxFit.scaleDown, child: content),
      ),
    );
  }
}

enum _Kind {
  normal(
    surface: SurfaceStyles.raised,
    padding: EdgeInsets.symmetric(horizontal: 20),
    gap: 0,
    textColor: AppColorTokens.textPrimary,
  ),
  hard(
    surface: SurfaceStyle(
      gradient: AppGradientTokens.hard,
      shadows: [
        NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2),
        NestyShadow(color: AppColorTokens.dangerEdge, dy: 5),
        NestyShadow(color: Color(0x40961E1E), dy: 9, blur: 14),
      ],
    ),
    padding: EdgeInsetsDirectional.only(start: 16, end: 10),
    gap: 8,
    textColor: Color(0xFFFFFFFF),
    textShadow: Color(0x4D781419),
  ),
  superHard(
    surface: SurfaceStyle(
      gradient: AppGradientTokens.superHard,
      shadows: [
        NestyShadow(color: Color(0x4DFFFFFF), inset: true, dy: 2),
        NestyShadow(color: AppColorTokens.superHardEdge, dy: 5),
        NestyShadow(color: Color(0x47501E82), dy: 9, blur: 14),
      ],
    ),
    padding: EdgeInsetsDirectional.only(start: 13, end: 7),
    gap: 6,
    fontSize: 17,
    textColor: Color(0xFFFFFFFF),
    textShadow: Color(0x59320F5A),
  ),
  daily(
    surface: SurfaceStyle(
      gradient: AppGradientTokens.daily,
      shadows: [
        NestyShadow(color: Color(0x8CFFFFFF), inset: true, dy: 2),
        NestyShadow(color: AppColorTokens.dailyEdge, dy: 5),
        NestyShadow(color: Color(0x4096640A), dy: 9, blur: 14),
      ],
    ),
    padding: EdgeInsetsDirectional.only(start: 12, end: 10),
    gap: 7,
    textColor: AppColors.dailyText,
  ),
  bonus(
    surface: SurfaceStyle(
      gradient: AppGradientTokens.bonus,
      shadows: [
        NestyShadow(color: Color(0x59FFFFFF), inset: true, dy: 2),
        NestyShadow(color: AppColorTokens.bonusEdge, dy: 5),
        NestyShadow(color: Color(0x400A5A50), dy: 9, blur: 14),
      ],
    ),
    padding: EdgeInsetsDirectional.only(start: 10, end: 14),
    gap: 0,
    fontSize: 17,
    textColor: Color(0xFFFFFFFF),
    textShadow: Color(0x4D05463C),
  );

  const _Kind({
    required this.surface,
    required this.padding,
    required this.gap,
    required this.textColor,
    this.fontSize = 18,
    this.textShadow,
  });

  final SurfaceStyle surface;
  final EdgeInsetsGeometry padding;
  final double gap;
  final double fontSize;
  final Color textColor;
  final Color? textShadow;

  TextStyle get textStyle => AppTextStyleTokens.hudLevel.copyWith(
    fontSize: fontSize,
    color: textColor,
    shadows: textShadow == null
        ? null
        : [Shadow(color: textShadow!, offset: const Offset(0, 2))],
  );
}

class _DateChip extends StatelessWidget {
  const _DateChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: AppColors.dailyChipFace,
      borderRadius: BorderRadius.all(Radius.circular(9)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: Text(
        label,
        style: AppTextStyleTokens.tierChip.copyWith(
          fontSize: 12,
          letterSpacing: 0,
          color: AppColorTokens.coinText,
        ),
        maxLines: 1,
        softWrap: false,
      ),
    ),
  );
}
