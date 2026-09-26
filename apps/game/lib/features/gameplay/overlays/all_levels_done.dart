import 'package:flutter/material.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_image_source.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/overlays/modal_placement.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/features/gameplay/widgets/lottie_doll.dart';
import 'package:nesty_render/nesty_render.dart';

/// Frame 4.9, All levels finished (spec §10.2 #15): the families hopping in
/// a warm spotlight, "You've finished all levels!", "New chapters are coming
/// — play bonus levels meanwhile." over a scrim, after the last bundled
/// level (the gameplay page) or from Home once every level is won.
///
/// TODO(M3): Bonus Endless (spec §7.1): the design's teal "Play Bonus
/// Level 1" button above a "Back to Home" link. Until bonus levels exist,
/// Back to Home is the card's button.
class AllLevelsDone extends StatelessWidget {
  const AllLevelsDone({
    required this.families,
    required this.onHome,
    this.images,
    this.renderer,
    this.symbols = DollSymbols.subtle,
    this.library,
    super.key,
  });

  /// Up to five dolls hop in the illustration.
  final List<DollColor> families;
  final VoidCallback onHome;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;
  final FxLibrary? library;

  /// NestyOverlay: the card sits 24 from each side, its top at 150 on a
  /// 59 safe area.
  static const double side = 24;
  static const double cardTop = 150 - 59;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return OverlayEntrance(
      kind: OverlayEntranceKind.modal,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(opacity: progress),
          ModalPlacement(cardTop: cardTop, side: side, child: content),
        ],
      ),
      child: ModalCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Spotlight(
              families: families,
              images: images,
              renderer: renderer,
              symbols: symbols,
              library: library,
            ),
            const SizedBox(height: 18),
            Semantics(
              header: true,
              child: Text(
                l10n.allLevelsTitle,
                textAlign: TextAlign.center,
                style: AppTextStyles.h2.copyWith(height: 1.15),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.allLevelsBody,
              textAlign: TextAlign.center,
              style: AppTextStyles.body.copyWith(
                height: 1.45,
                color: AppColors.iconBrown,
              ),
            ),
            const SizedBox(height: 20),
            TactileButton(label: l10n.allLevelsBackHome, onPressed: onHome),
          ],
        ),
      ),
    );
  }
}

/// The 190-tall spotlight box (NestyOverlay `isBonus`): a radial warm
/// glow, a plank near the bottom and up to five hopping dolls (0.14 s
/// apart) with twinkles.
class _Spotlight extends StatelessWidget {
  const _Spotlight({
    required this.families,
    required this.images,
    required this.renderer,
    required this.symbols,
    required this.library,
  });

  final List<DollColor> families;
  final FxImageSource? images;
  final DollRenderer? renderer;
  final DollSymbols symbols;
  final FxLibrary? library;

  static const double height = 190;
  static const _heights = [96.0, 80.0, 108.0, 84.0, 70.0];
  static const _twinkles = [
    (x: 40.0, y: 34.0, size: 20.0, phaseMs: 0.0),
    (x: 158.0, y: 22.0, size: 16.0, phaseMs: 600.0),
    (x: 301.0, y: 41.0, size: 22.0, phaseMs: 1200.0),
  ];

  @override
  Widget build(BuildContext context) {
    final shown = families.take(_heights.length).toList();
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(22)),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.4),
              radius: 0.9,
              colors: [Color(0xFFFFF6DC), Color(0xFFF7DDA8), Color(0xFFEFC98A)],
              stops: [0, 0.7, 1],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final n = shown.length;
              // NestyOverlay: x = 58 + 57·i across a 302-wide box.
              final pitch = width * 57 / 302;
              final first = width / 2 - (n - 1) / 2 * pitch;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 10,
                    child: PlankStrip(height: 28),
                  ),
                  for (final t in _twinkles)
                    Positioned(
                      left: t.x * width / 302 - t.size / 2,
                      top: t.y - t.size / 2,
                      child: LottieTwinkle(
                        size: t.size,
                        color: const Color(0xFFF5B418),
                        periodMs: 2200,
                        phaseMs: t.phaseMs,
                        library: library,
                      ),
                    ),
                  for (var i = 0; i < n; i++)
                    LottieDoll.positioned(
                      centerX: first + i * pitch,
                      baseY: 170,
                      doll: LottieDoll(
                        id: FxId.dollWinHop,
                        color: shown[i],
                        height: _heights[i],
                        images: images,
                        renderer: renderer,
                        symbols: symbols,
                        library: library,
                        startDelay: Duration(milliseconds: 140 * i),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
