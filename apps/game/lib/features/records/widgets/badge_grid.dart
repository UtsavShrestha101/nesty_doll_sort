import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The Records screen's badge grid (frame 10.6; tokens `layout.records.
/// badgeGrid`): every [BadgeId], in its declared order, 3 columns, each a
/// white card with the badge's art (`UiArt.badge`, 56), its name and one
/// line. An earned badge shows its own line ("You nested your first
/// family."); a locked one its greyed art and "Not earned yet", with the
/// how-to line in the screen-reader label only.
///
/// A row's cells share the tallest one's height.
class BadgeGrid extends StatelessWidget {
  const BadgeGrid({required this.earned, super.key});

  /// The badges the save has earned (`RecordsSummary.badges`).
  final List<BadgeId> earned;

  static const int columns = RecordsTokens.badgeGridColumns;

  @override
  Widget build(BuildContext context) {
    final badges = BadgeId.values;
    return Column(
      children: [
        for (var i = 0; i < badges.length; i += columns) ...[
          if (i > 0) const SizedBox(height: RecordsTokens.badgeGridGap),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = i; j < i + columns; j++) ...[
                  if (j > i) const SizedBox(width: RecordsTokens.badgeGridGap),
                  Expanded(
                    child: j < badges.length
                        ? _BadgeCell(
                            badge: badges[j],
                            earned: earned.contains(badges[j]),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _BadgeCell extends StatelessWidget {
  const _BadgeCell({required this.badge, required this.earned});

  final BadgeId badge;
  final bool earned;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = l10n.badgeName(badge.id);
    final semanticLabel = earned
        ? l10n.badgeSemanticsEarned(name)
        : l10n.badgeSemanticsLocked(name, l10n.badgeHint(badge.id));
    return Semantics(
      container: true,
      label: semanticLabel,
      hint: earned ? l10n.badgeLine(badge.id) : null,
      excludeSemantics: true,
      child: NestySurface(
        style: _style,
        radius: BorderRadius.circular(RecordsTokens.badgeGridRadius),
        padding: const EdgeInsets.fromLTRB(8, 12, 8, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiArtImage.square(
              UiArt.badge(badge, earned: earned),
              extent: RecordsTokens.badgeGridArt,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              style: AppTextStyleTokens.cardTitle.copyWith(
                fontSize: 14,
                height: 1.15,
                color: earned
                    ? AppColorTokens.textPrimary
                    : AppColorTokens.textMuted,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              earned ? l10n.badgeLine(badge.id) : l10n.badgeLockedLine,
              textAlign: TextAlign.center,
              style: AppTextStyleTokens.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: AppColorTokens.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
