import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// The gold coin: a radial `#FFF3B0 → #F2C230 → #B8860B` face
/// (tokens.json `gradient.coinFace`).
///
/// From 26 px up it adds the pill coins' rim and bottom shade (NestyBoard
/// HUD 28 px, Home 30 px, win 38 px); smaller coins (badges, price chips)
/// are the bare face, as in the frames. [ring] draws the price button's
/// `0 0 0 2px rgba(255,255,255,.6)` halo. [disabled] is the flat grey coin
/// of frame 3.8.
class CoinIcon extends StatelessWidget {
  const CoinIcon({
    this.size = 28,
    this.disabled = false,
    this.ring = false,
    super.key,
  });

  final double size;
  final bool disabled;
  final bool ring;

  static const _rim = NestyShadow(
    color: Color(0x99FFF0B4),
    inset: true,
    spread: 2,
  );
  static const _halo = NestyShadow(color: Color(0x99FFFFFF), spread: 2);

  @override
  Widget build(BuildContext context) {
    final detailed = size >= 26 && !disabled;
    final style = SurfaceStyle(
      color: disabled ? AppColors.disabledCoin : null,
      gradient: disabled ? null : AppGradientTokens.coinFace,
      shadows: [
        if (detailed) ...[
          // `inset 0 -2px 0 rgba(120,70,0,.35)`, 3 px on the big win coin.
          NestyShadow(
            color: const Color(0x59784600),
            inset: true,
            dy: size >= 34 ? -3 : -2,
          ),
          _rim,
        ],
        if (ring) _halo,
      ],
    );
    return ExcludeSemantics(
      child: NestySurface(
        style: style,
        radius: BorderRadius.circular(size / 2),
        width: size,
        height: size,
      ),
    );
  }
}
