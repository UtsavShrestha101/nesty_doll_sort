import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// One Records stat (frame 10.6; tokens `layout.records.statsGrid`; menus
/// spec 5): a white cell, radius 18, a 4 dp `surfaceEdge` lip, a 36 dp
/// icon tile in the stat's tint, the value in Fredoka 700 24 over its label
/// in Nunito 700 14. Read-only and never dimmed.
///
/// One semantics node: "Levels won, 55". The value scales down before it
/// would cut, and the label wraps to two lines ("Daily puzzles solved").
class RecordStatCell extends StatelessWidget {
  const RecordStatCell({
    required this.icon,
    required this.tint,
    required this.value,
    required this.label,
    this.glyphColor,
    this.art,
    super.key,
  });

  /// The glyph in the tile (unless [art] is set).
  final IconData icon;

  /// The tile's fill.
  final Color tint;
  final Color? glyphColor;

  /// UI art drawn in the tile instead of [icon] (the Stars stat's star).
  final UiArt? art;
  final String value;
  final String label;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4)],
  );

  @override
  Widget build(BuildContext context) {
    final art = this.art;
    return Semantics(
      container: true,
      label: context.localizations.recordsStatSemantics(label, value),
      excludeSemantics: true,
      child: NestySurface(
        style: _style,
        radius: BorderRadius.circular(RecordsTokens.statsGridCellRadius),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            NestySurface(
              style: SurfaceStyle(color: tint, shadows: const []),
              radius: BorderRadius.circular(12),
              width: RecordsTokens.statsGridCellIcon,
              height: RecordsTokens.statsGridCellIcon,
              alignment: Alignment.center,
              child: art != null
                  ? UiArtImage.square(art, extent: 24)
                  : Icon(icon, size: 22, color: glyphColor),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      value,
                      style: AppTextStyleTokens.number.copyWith(
                        fontSize: 24,
                        height: 1.1,
                        color: AppColorTokens.textPrimary,
                      ),
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  Text(
                    label,
                    style: AppTextStyleTokens.row.copyWith(
                      fontSize: 14,
                      height: 1.15,
                      color: AppColorTokens.textSecondary,
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
