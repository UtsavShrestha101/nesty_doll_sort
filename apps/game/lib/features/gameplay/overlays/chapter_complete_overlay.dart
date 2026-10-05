import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/core/ui/theme/locale_script.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart'
    show LottieTwinkle;
import 'package:nesty_game/features/museum/widgets/figurine_image.dart';

/// Frame 4.6, Chapter complete (spec §7.2, §10.2 #10; docs/plans/m3-design.md
/// §9.3): after the win overlay's Continue on a level that completes a
/// chapter, over `Scrim.strong` (`rgba(25,12,4,.86)`) and a warm spotlight
/// cone: "CHAPTER N COMPLETE", the name of the figurine just earned ("The
/// Baker Family", NestyOverlay `isChapter`; review FIDELITY-1), its earned
/// art (310 px), "Added to your Museum!", "+150 coins", "Next: Chapter N+1 ·
/// Name" (hidden past the last chapter), then Continue.
///
/// The page opens this from the win overlay's Continue instead of loading
/// the next level directly, calls `JingleCues.chapterComplete()` when it
/// opens, and this overlay's own Continue sends `NextLevelPressed` and
/// `MusicService.playGame()` (m3-design §9.3, §10.1).
class ChapterCompleteOverlay extends StatelessWidget {
  const ChapterCompleteOverlay({
    required this.chapterNumber,
    required this.chapterName,
    required this.figurineId,
    required this.coins,
    required this.onContinue,
    this.nextLine,
    this.library,
    super.key,
  });

  final int chapterNumber;

  /// The just-completed chapter's name: `chapterName` (ARB) when it has
  /// one, else the caller's own "Chapter N" fallback (m3-design §9.1: names
  /// exist for ch01–ch06 only). The title only while the figurine has no
  /// name (`figurineName` is empty for an id without one, Q73).
  final String chapterName;

  /// The `figurineName` ARB select key just earned: drawn unlocked
  /// (`FigurineImage`, `features/museum/widgets/figurine_image.dart`),
  /// since this overlay is the moment it is earned.
  final String figurineId;

  /// `reward_chapter` (spec §7.3).
  final int coins;
  final VoidCallback onContinue;

  /// "Next: Chapter N+1 · Name" (`chapterCompleteNext`), already resolved
  /// by the caller; null past the last catalog chapter hides the line.
  final String? nextLine;

  final FxLibrary? library;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final nextLine = this.nextLine;
    final figurineName = l10n.figurineName(figurineId);
    final title = figurineName.isEmpty ? chapterName : figurineName;
    return OverlayEntrance(
      kind: OverlayEntranceKind.fade,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim.strong(opacity: progress),
          const _SpotlightCone(),
          content,
        ],
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 37, 28, 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Semantics(
                        header: true,
                        namesRoute: true,
                        child: Text(
                          l10n.chapterCompleteTitle(chapterNumber),
                          textAlign: TextAlign.center,
                          style: AppTextStyleTokens.tierChip.copyWith(
                            fontSize: 14,
                            letterSpacing: context.script.tracking(1.96),
                            color: const Color(0xFFFFE3B8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyleTokens.h1.copyWith(
                          fontSize: 34,
                          height: 1.1,
                          color: const Color(0xFFFFF6E6),
                          shadows: const [
                            Shadow(
                              color: Color(0x80281405),
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _FigurineSpotlight(
                        figurineId: figurineId,
                        library: library,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.chapterCompleteAdded,
                        textAlign: TextAlign.center,
                        style: AppTextStyleTokens.h2.copyWith(
                          fontSize: 22,
                          height: 1.2,
                          color: const Color(0xFFFFF6E6),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _CoinsPill(text: l10n.chapterCompleteCoins(coins)),
                      if (nextLine != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          nextLine,
                          textAlign: TextAlign.center,
                          style: AppTextStyleTokens.caption.copyWith(
                            fontSize: 14,
                            height: 1.3,
                            color: const Color(0xFFFFE3B8),
                          ),
                        ),
                      ],
                      const SizedBox(height: 40),
                      TactileButton(
                        label: l10n.winContinue,
                        onPressed: onContinue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The soft golden cone from the top and a glow behind the figurine
/// (NestyOverlay `isChapter`: a 360-wide clipped trapezoid fading from
/// `rgba(255,244,210,.55)`, and a 340×110 radial glow at y 430).
class _SpotlightCone extends StatelessWidget {
  const _SpotlightCone();

  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: CustomPaint(painter: _SpotlightPainter(), size: Size.infinite),
  );
}

final class _SpotlightPainter extends CustomPainter {
  const _SpotlightPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.width / 2;
    final cone = Path()
      ..moveTo(center - size.width * 0.1, 0)
      ..lineTo(center + size.width * 0.1, 0)
      ..lineTo(center + size.width * 0.5, size.height * 0.71)
      ..lineTo(center - size.width * 0.5, size.height * 0.71)
      ..close();
    final conePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0x8CFFF4D2), Color(0x1AFFECBE)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.71));
    canvas.drawPath(cone, conePaint);
    final glowCenter = Offset(center, size.height * 0.51);
    final glowPaint = Paint()
      ..shader =
          const RadialGradient(
            colors: [Color(0xBFFFF0C8), Color(0x00FFF0C8)],
          ).createShader(
            Rect.fromCenter(
              center: glowCenter,
              width: size.width * 0.87,
              height: 130,
            ),
          );
    canvas.drawOval(
      Rect.fromCenter(
        center: glowCenter,
        width: size.width * 0.87,
        height: 130,
      ),
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) => false;
}

/// The 310 px earned figurine over its glow, with a few twinkles
/// (NestyOverlay `sparks`).
class _FigurineSpotlight extends StatelessWidget {
  const _FigurineSpotlight({required this.figurineId, this.library});

  final String figurineId;
  final FxLibrary? library;

  static const _twinkles = [
    (dx: -125.0, dy: -60.0, size: 22.0, phaseMs: 0.0),
    (dx: 105.0, dy: -76.0, size: 26.0, phaseMs: 700.0),
    (dx: -143.0, dy: 40.0, size: 16.0, phaseMs: 1300.0),
    (dx: 125.0, dy: 60.0, size: 18.0, phaseMs: 1800.0),
    (dx: 0.0, dy: -100.0, size: 14.0, phaseMs: 1000.0),
  ];

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 310,
    height: 310,
    child: Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        for (final t in _twinkles)
          Positioned(
            left: 155 + t.dx - t.size / 2,
            top: 155 + t.dy - t.size / 2,
            child: LottieTwinkle(
              size: t.size,
              color: const Color(0xFFFFF3B0),
              periodMs: 2200,
              phaseMs: t.phaseMs,
              library: library,
            ),
          ),
        FigurineImage(figurineId: figurineId, size: 310),
      ],
    ),
  );
}

/// "+150 coins" (NestyOverlay: 9/20/9/9 padding, radius 24, surface
/// gradient, 24/700 `#8C5E12`).
class _CoinsPill extends StatelessWidget {
  const _CoinsPill({required this.text});

  final String text;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5)],
  );

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: NestySurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(24)),
      padding: const EdgeInsetsDirectional.fromSTEB(9, 9, 20, 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoinIcon(size: 32),
          const SizedBox(width: 10),
          Text(
            text,
            style: AppTextStyleTokens.number.copyWith(
              fontSize: 24,
              height: 1,
              color: AppColorTokens.coinText,
            ),
          ),
        ],
      ),
    ),
  );
}
