import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/flavor/flavor_config.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The dev flavor's level picker (BACKLOG M2 "Dev-flavor level picker",
/// plan P4): every bundled level (1–30 in M2, 1–200 from M7) as a numbered
/// tile, tinted by tier, to jump straight to any board.
///
/// Grouped by chapter ("Chapter 1 · Levels 1–20" headers, owner 2026-09-28
/// simulator review): with 200 levels the tiles no longer draw as one long
/// [Wrap] that could grow past the sheet and hide the title. The sheet's
/// own height is bounded ([ConstrainedBox]); its title and close button sit
/// outside the scrolling area (`NestySheet`'s `titleAction` slot), so both
/// stay visible, and only the chapter sections scroll (`NestySheet`'s own
/// `Flexible`+`SingleChildScrollView`). Never shown in stg or prod.
class LevelPickerSheet extends StatefulWidget {
  const LevelPickerSheet({
    required this.levels,
    required this.onPick,
    this.currentOrder,
    super.key,
  });

  final LevelRepository levels;

  /// Called with the chosen level's play order.
  final ValueChanged<int> onPick;

  /// The level the player is on now, if known: its tile scrolls into view
  /// once the sheet opens (Home passes its campaign PLAY's level). Null,
  /// as for a bonus PLAY, just opens at the top.
  final int? currentOrder;

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
    int? currentOrder,
  }) async {
    final picked = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0x00000000),
      barrierColor: AppColorTokens.scrim,
      builder: (sheetContext) => LevelPickerSheet(
        levels: levels,
        currentOrder: currentOrder,
        onPick: (order) => Navigator.of(sheetContext).pop(order),
      ),
    );
    if (picked != null) onPick(picked);
  }

  @override
  State<LevelPickerSheet> createState() => _LevelPickerSheetState();
}

class _LevelPickerSheetState extends State<LevelPickerSheet> {
  final GlobalKey _currentTileKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.currentOrder != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    }
  }

  void _scrollToCurrent() {
    final tileContext = _currentTileKey.currentContext;
    if (tileContext == null) return;
    // The default Duration.zero jumps straight there: a fresh sheet has
    // nothing to animate from, so there is no motion to shorten under
    // reduced motion either.
    unawaited(Scrollable.ensureVisible(tileContext, alignment: 0.2));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final groups = _chapterGroups(widget.levels);
    final currentOrder = widget.currentOrder;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: NestySheet(
        title: l10n.devLevelPickerTitle,
        titleAction: NestyCloseButton(
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        children: [
          for (final group in groups)
            _ChapterSection(
              group: group,
              currentOrder: currentOrder,
              currentTileKey: group.orders.contains(currentOrder)
                  ? _currentTileKey
                  : null,
              onPick: widget.onPick,
            ),
        ],
      ),
    );
  }
}

/// One chapter's tiles: [LevelBundleEntry.chapterId] groups levels into
/// runs of (spec §7.1) 20, in bundle order. Grouping by the entries' own
/// chapter id (rather than assuming every chapter is exactly 20 levels)
/// keeps this correct even for a fixture or a future bundle that isn't.
class _ChapterGroup {
  _ChapterGroup(this.number);

  /// 1-based display number ("Chapter 1", "Chapter 2", …), in the order
  /// chapters first appear.
  final int number;

  /// This chapter's play orders and tiers, in order.
  final List<({int order, Tier tier})> items = [];

  List<int> get orders => [for (final item in items) item.order];
}

List<_ChapterGroup> _chapterGroups(LevelRepository levels) {
  final groups = <_ChapterGroup>[];
  String? chapterId;
  for (var order = 1; order <= levels.levelCount; order++) {
    final entry = levels.entryAt(order);
    final entryChapterId = entry?.chapterId;
    if (groups.isEmpty || entryChapterId != chapterId) {
      groups.add(_ChapterGroup(groups.length + 1));
      chapterId = entryChapterId;
    }
    groups.last.items.add((order: order, tier: entry?.tier ?? Tier.easy));
  }
  return groups;
}

/// A chapter's header ("Chapter 1 · Levels 1–20") and its tiles, wrapped so
/// they fill a row before starting the next.
class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
    required this.group,
    required this.currentOrder,
    required this.currentTileKey,
    required this.onPick,
  });

  final _ChapterGroup group;
  final int? currentOrder;
  final GlobalKey? currentTileKey;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.devLevelPickerChapterHeader(
              group.number,
              group.items.first.order,
              group.items.last.order,
            ),
            style: AppTextStyleTokens.cardTitle.copyWith(fontSize: 15),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          children: [
            for (final item in group.items)
              _LevelTile(
                key: item.order == currentOrder ? currentTileKey : null,
                order: item.order,
                tier: item.tier,
                onPressed: () => onPick(item.order),
              ),
          ],
        ),
      ],
    );
  }
}

/// One level: its number on a tactile tile in its tier's colour.
class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.order,
    required this.tier,
    required this.onPressed,
    super.key,
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
