import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/repository/bundled_catalog_repository.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// One museum figurine's art (design/museum, frames 6.1–6.3): the earned
/// PNG, or its `-locked` silhouette while [locked]. Shared by the Museum
/// cabinet (76 px), its detail modal (272 px) and the win/chapter-complete
/// overlays (gameplay-screens lane), so the asset path and the fallback are
/// written once.
///
/// The synced file is `assets/museum/NN-<id>[-locked].png`
/// (`BundledCatalogRepository.figurineArt`); the number comes from
/// [BundledCatalogRepository.figurineIds]' position, so this widget needs
/// only the id, not a [ChapterInfo]. An id the catalog doesn't know, or a
/// PNG that fails to load, draws a neutral placeholder instead of a broken
/// image (rule 3).
class FigurineImage extends StatelessWidget {
  const FigurineImage({
    super.key,
    required this.figurineId,
    this.locked = false,
    this.size = 76,
  });

  final String figurineId;
  final bool locked;
  final double size;

  @override
  Widget build(BuildContext context) {
    final index = BundledCatalogRepository.figurineIds.indexOf(figurineId);
    final asset = index < 0
        ? null
        : BundledCatalogRepository.figurineArt(
            index + 1,
            figurineId,
            locked: locked,
          );
    return Semantics(
      label: context.localizations.figurineName(figurineId),
      image: true,
      excludeSemantics: true,
      child: SizedBox(
        width: size,
        height: size,
        child: asset == null
            ? const _PlaceholderFigurine()
            : Image.asset(
                asset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const _PlaceholderFigurine(),
              ),
      ),
    );
  }
}

/// Drawn when the figurine's PNG is missing or fails to decode: a plain
/// museum glyph rather than a broken-image icon or blank space.
class _PlaceholderFigurine extends StatelessWidget {
  const _PlaceholderFigurine();

  @override
  Widget build(BuildContext context) => const ColoredBox(
    color: AppColors.disabledFace,
    child: Center(
      child: Icon(NestyIcons.museum, color: AppColors.disabledText),
    ),
  );
}
