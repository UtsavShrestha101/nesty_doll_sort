import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The dev flavor's level picker (BACKLOG M2 "Dev-flavor level picker",
/// plan P4): every bundled level (1–30 in M2) as a numbered tile, tinted by
/// tier, to jump straight to any board. Never shown in stg or prod.
class LevelPickerSheet extends StatelessWidget {
  const LevelPickerSheet({
    required this.levels,
    required this.onPick,
    super.key,
  });

  final LevelRepository levels;

  /// Called with the chosen level's play order.
  final ValueChanged<int> onPick;

  /// Only the dev flavor has the picker (the flavor is fixed at startup;
  /// false when none is set, as in unit tests without one).
  static bool get isAvailable {
    try {
      return FlavorConfig.flavor == Flavor.dev;
    } on Object {
      return false;
    }
  }

  /// Opens the picker over [context]; [onPick] runs after it has closed.
  static Future<void> show(
    BuildContext context, {
    required LevelRepository levels,
    required ValueChanged<int> onPick,
  }) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      barrierColor: AppColorTokens.scrim,
      builder: (sheetContext) => LevelPickerSheet(
        levels: levels,
        onPick: (order) => Navigator.of(sheetContext).pop(order),
      ),
    );
    if (picked != null) onPick(picked);
  }

  @override
  Widget build(BuildContext context) {
    final count = levels.levelCount;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: NestySheet(
        title: context.localizations.devLevelPickerTitle,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              for (var order = 1; order <= count; order++)
                _LevelTile(
                  order: order,
                  tier: levels.entryAt(order)?.tier ?? Tier.easy,
                  onPressed: () => onPick(order),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One level: its number on a tactile tile in its tier's colour.
class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.order,
    required this.tier,
    required this.onPressed,
  });

  final int order;
  final Tier tier;
  final VoidCallback onPressed;

  static const _hard = SurfaceStyle(
    gradient: AppGradientTokens.hard,
    shadows: [NestyShadow(color: AppColorTokens.dangerEdge, dy: 4)],
  );
  static const _superHard = SurfaceStyle(
    gradient: AppGradientTokens.superHard,
    shadows: [NestyShadow(color: AppColorTokens.superHardEdge, dy: 4)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final (style, ink) = switch (tier) {
      Tier.easy || Tier.medium => (SurfaceStyles.row, AppColors.iconBrown),
      Tier.hard => (_hard, const Color(0xFFFFFFFF)),
      Tier.superhard => (_superHard, const Color(0xFFFFFFFF)),
    };
    return TactileSurface(
      style: style,
      radius: const BorderRadius.all(Radius.circular(16)),
      onPressed: onPressed,
      width: 52,
      height: 48,
      semanticLabel: l10n.levelWithTier(order, l10n.tierName(tier.id)),
      excludeChildSemantics: true,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$order',
          style: AppTextStyleTokens.number.copyWith(color: ink),
        ),
      ),
    );
  }
}
