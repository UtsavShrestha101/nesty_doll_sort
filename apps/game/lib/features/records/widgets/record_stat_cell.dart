import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/records/widgets/doll_mark.dart';

/// One Records stat (frame 10.6; tokens `layout.records.statsGrid`; menus
/// spec 5): a white cell, radius 18, a 4 dp `surfaceEdge` lip, a 36 dp
/// icon tile in the stat's tint, the value in Fredoka 700 20 over its label
/// in Nunito 700 11.5. Read-only and never dimmed.
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
    this.dollMark = false,
    super.key,
  });

  /// The glyph in the tile (unless [art] is set).
  final IconData icon;

  /// The tile's fill.
  final Color tint;
  final Color? glyphColor;

  /// UI art drawn in the tile instead of [icon] (the Stars stat's star).
  final UiArt? art;

  /// Draw the family counter's doll mark in the tile (16×24, in
  /// [glyphColor]) instead of [icon]: "Families completed".
  final bool dollMark;
  final String value;
  final String label;

  static const _style = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4),
    ],
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
        padding: RecordsTokens.statsGridCellPadding,
        child: Row(
          children: [
            NestySurface(
              style: SurfaceStyle(color: tint, shadows: const []),
              radius: BorderRadius.circular(
                RecordsTokens.statsGridCellIconTileRadius,
              ),
              width: RecordsTokens.statsGridCellIconTileSize,
              height: RecordsTokens.statsGridCellIconTileSize,
              alignment: Alignment.center,
              child: dollMark
                  ? DollMark(color: glyphColor ?? AppColorTokens.primaryEdge)
                  : art != null
                  ? UiArtImage.square(
                      art,
                      extent: RecordsTokens.statsGridCellTintsStarsArtSize,
                    )
                  : Icon(
                      icon,
                      size: RecordsTokens.statsGridCellIconTileGlyph,
                      color: glyphColor,
                    ),
            ),
            const SizedBox(width: RecordsTokens.statsGridCellGap),
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
                      style: RecordsTypeTokens.cellValue,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(label, style: RecordsTypeTokens.cellLabel, maxLines: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
