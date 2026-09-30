import 'package:flutter/widgets.dart';

/// A wrapping grid of equal-width cells (docs/plans/m7-design.md §15's
/// shared rule: "a 4-column grid of 20 cells (6 at ≥ 600 dp)" for Chapters'
/// level grid and Records' badge grid).
///
/// Each cell is [Expanded], so a long label or 1.3× text scales down inside
/// the cell's own `FittedBox` instead of overflowing the row; nothing here
/// measures text itself. Rows are built eagerly (a `Column` of `Row`s), which
/// is fine for the small, fixed-length lists this app shows (20 levels, 12
/// badges).
class NestyGrid extends StatelessWidget {
  const NestyGrid({
    required this.children,
    this.columns = 4,
    this.wideColumns = 6,
    this.wideBreakpoint = 600,
    this.spacing = 12,
    this.runSpacing = 12,
    super.key,
  });

  /// The grid's cells, in order.
  final List<Widget> children;

  /// Columns per row below [wideBreakpoint].
  final int columns;

  /// Columns per row at [wideBreakpoint] dp or more (m7-design §15: "grids
  /// gain columns" at 768×1024).
  final int wideColumns;
  final double wideBreakpoint;

  /// The horizontal gap between cells.
  final double spacing;

  /// The vertical gap between rows.
  final double runSpacing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final perRow = constraints.maxWidth >= wideBreakpoint
          ? wideColumns
          : columns;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i += perRow) ...[
            if (i > 0) SizedBox(height: runSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = i; j < i + perRow; j++) ...[
                  if (j > i) SizedBox(width: spacing),
                  Expanded(
                    child: j < children.length
                        ? children[j]
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
        ],
      );
    },
  );
}
