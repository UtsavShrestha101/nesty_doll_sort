import 'package:flutter/widgets.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_render/nesty_render.dart';

/// A bottom-aligned, centered row of shelf dolls (frames 7.3's 3-doll
/// preview, 7.4's 6+5 color shelves and its 4-doll size lineup): one
/// [LottieDoll] per `colors[i]` at `heights[i]`, laid out with [gap]
/// between their true (aspect-correct) widths, filling the parent's box
/// (wrap this in a `SizedBox` of the wanted size).
///
/// The art comes from [skin] (`SkinService.prepareShowcase`), rasterized
/// once by the caller and reused across rebuilds; null draws the
/// placeholder doll (rule 3, the fake env).
class SkinDollRow extends StatelessWidget {
  const SkinDollRow({
    required this.colors,
    required this.heights,
    this.skin,
    this.gap = 4,
    this.symbols = DollSymbols.subtle,
    this.library,
    super.key,
  }) : assert(colors.length == heights.length, 'one height per doll');

  final List<DollColor> colors;
  final List<double> heights;
  final LevelSkin? skin;
  final double gap;
  final DollSymbols symbols;
  final FxLibrary? library;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widths = [
          for (final h in heights) h * DollArt.width / DollArt.height,
        ];
        final total =
            widths.fold<double>(0, (sum, w) => sum + w) +
            gap * (colors.length - 1);
        final baseY = constraints.maxHeight;
        var left = (constraints.maxWidth - total) / 2;
        final children = <Widget>[];
        for (var i = 0; i < colors.length; i++) {
          final width = widths[i];
          children.add(
            LottieDoll.positioned(
              centerX: left + width / 2,
              baseY: baseY,
              doll: LottieDoll(
                id: FxId.dollIdle,
                color: colors[i],
                height: heights[i],
                images: skin?.images,
                renderer: skin?.restRenderer,
                symbols: symbols,
                library: library,
              ),
            ),
          );
          left += width + gap;
        }
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }
}
