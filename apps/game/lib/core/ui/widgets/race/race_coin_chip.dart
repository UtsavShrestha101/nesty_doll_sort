import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/coins/coin_icon.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// The race win card's coin chip (frame 9.4; ui-spec-game §1 "ResultChips",
/// coin only): a 38 dp coin and "+20 coins" in Fredoka 700 30, counting up
/// from 0 with [countUp], on the surface gradient with a 5 dp edge. Read as
/// one "+20 coins" to a screen reader. `fx_coin_burst` is anchored on the
/// coin by the caller through [burst], at (80, 100) above-left of its centre
/// as the win card's pill does.
class RaceCoinChip extends StatelessWidget {
  const RaceCoinChip({
    required this.reward,
    required this.countUp,
    required this.burst,
    super.key,
  });

  final int reward;
  final Animation<double> countUp;
  final Widget burst;

  static const _style = SurfaceStyle(
    gradient: AppGradientTokens.surface,
    shadows: [
      NestyShadow(color: Color(0xFFFFFFFF), inset: true, dy: 2),
      NestyShadow(color: AppColorTokens.surfaceEdge, dy: 5),
    ],
  );

  /// The coin's centre in the chip: 10 padding + a 38 dp coin.
  static const Offset _coin = Offset(29, 29);

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Semantics(
      label: l10n.raceWinCoins(reward),
      excludeSemantics: true,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NestySurface(
            style: _style,
            radius: const BorderRadius.all(Radius.circular(26)),
            padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 20, 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CoinIcon(size: 38),
                const SizedBox(width: 10),
                AnimatedBuilder(
                  animation: countUp,
                  builder: (context, _) => Text(
                    l10n.raceWinCoins((reward * countUp.value).round()),
                    style: AppTextStyleTokens.number.copyWith(
                      fontSize: 30,
                      height: 1,
                      color: AppColorTokens.coinText,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: _coin.dx - 80,
            top: _coin.dy - 100,
            width: 160,
            height: 140,
            child: IgnorePointer(child: burst),
          ),
        ],
      ),
    );
  }
}
