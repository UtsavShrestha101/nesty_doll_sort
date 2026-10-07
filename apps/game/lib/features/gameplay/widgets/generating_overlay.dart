import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/fx/lottie_fx_view.dart';
import 'package:nesty_game/features/fx/spinner_pulse.dart';

/// "Setting up the shelves…" while a generated request (a bonus level, the
/// daily) resolves behind the level just left (frame 12.5; `layout.
/// generating`; m3-design §6.4 item 1, §10.8): the old board dims
/// (`rgba(60,30,10,.28)`) under a cream card, 236 wide (its 18 dp side
/// padding inside) and centred in the safe area (m7-5 Choice 10: the
/// frame's top 360 is that centre on 844), holding the `ui_spinner` at 44
/// and the line in Fredoka 700 17. No progress number. The spinner is drawn
/// in the file's own colours (its orange arc on a cream track, m7-5): no
/// tint or colour filter goes over it.
///
/// It absorbs touches over the board, but not over the Pause button, which
/// stays reachable (the top-left corner). One live, busy node for screen
/// readers. Under reduced motion the spinner rests on frame 0 and pulses its
/// opacity 1 → 0.45 → 1 over 1,600 ms (`motion.spinner`, m7-4 4.17).
class GeneratingOverlay extends StatefulWidget {
  const GeneratingOverlay({this.library, super.key});

  final FxLibrary? library;

  /// The card, for tests.
  @visibleForTesting
  static const Key cardKey = Key('generating-card');

  /// The width that stays free at the top-left for Pause: its 48 dp button
  /// plus the HUD's 16 dp inset and a gap.
  static const double pauseClearance = 76;

  /// The HUD row's height below the safe area (`GameplayHud`: pills 48 at
  /// top 7).
  static const double hudRowHeight = 66;

  @override
  State<GeneratingOverlay> createState() => _GeneratingOverlayState();
}

class _GeneratingOverlayState extends State<GeneratingOverlay> {
  final LottieFxController _spinner = LottieFxController(FxId.uiSpinner);
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (context.reduceMotion) {
      _spinner.seek(0);
    } else {
      _spinner.playWhole();
    }
  }

  @override
  void dispose() {
    _spinner.dispose();
    super.dispose();
  }

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 6),
      NestyShadow(color: Color(0x4D3C1905), dy: 18, blur: 36),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final safe = MediaQuery.paddingOf(context);
    final top = safe.top;
    return Positioned.fill(
      child: Stack(
        children: [
          // Everything but the Pause corner takes the touches.
          // The old board dims under it (frame 12.5).
          const Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: GeneratingTokens.dim),
            ),
          ),
          Positioned(
            left: GeneratingOverlay.pauseClearance,
            right: 0,
            top: 0,
            height: top + GeneratingOverlay.hudRowHeight,
            child: const AbsorbPointer(),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: top + GeneratingOverlay.hudRowHeight,
            bottom: 0,
            child: const AbsorbPointer(),
          ),
          IgnorePointer(
            child: Padding(
              padding: EdgeInsets.only(top: top, bottom: safe.bottom),
              child: Align(
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  label: l10n.gameplayGenerating,
                  child: ExcludeSemantics(
                    child: NestySurface(
                      key: GeneratingOverlay.cardKey,
                      style: _style,
                      radius: BorderRadius.circular(
                        GeneratingTokens.cardRadius,
                      ),
                      width: GeneratingTokens.cardWidth,
                      padding: GeneratingTokens.cardPadding,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox.square(
                            dimension: GeneratingTokens.spinnerSize,
                            child: SpinnerPulse(
                              child: LottieFxView(
                                id: FxId.uiSpinner,
                                controller: _spinner,
                                library: widget.library,
                                fallback: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: AppColorTokens.primary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n.gameplayGenerating,
                            textAlign: TextAlign.center,
                            style: AppTextStyleTokens.cardTitle.copyWith(
                              fontSize: 17,
                              height: 1.2,
                              color: AppColors.textBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
