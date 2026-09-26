import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/colors/app_colors.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/ad_play_glyph.dart';
import 'package:nesty_game/core/ui/widgets/coins/coin_icon.dart';
import 'package:nesty_game/core/ui/widgets/number/nesty_number_text.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// What a booster's top-right badge says (design/README.md "Booster
/// button"; NestyBoard `bst`):
/// * [BoosterBadge.count]: how many are left, a 22 px pink bubble;
/// * [BoosterBadge.ad]: none left, a ▶ box (a rewarded ad gets one);
/// * [BoosterBadge.coin]: none left, the coin price ("20").
@immutable
sealed class BoosterBadge {
  const BoosterBadge();

  const factory BoosterBadge.count(int count) = BoosterCountBadge;
  const factory BoosterBadge.ad() = BoosterAdBadge;
  const factory BoosterBadge.coin(int price) = BoosterCoinBadge;

  /// Where the badge's top-right corner sits relative to the button's
  /// (NestyBoard: count `right:-6; top:-7`, ad `-7, -8`, coin `-9, -9`).
  /// Positive x is outside the right edge; negative y is above the top.
  Offset get cornerOffset;
}

final class BoosterCountBadge extends BoosterBadge {
  const BoosterCountBadge(this.count);

  final int count;

  @override
  Offset get cornerOffset => const Offset(6, -7);

  @override
  bool operator ==(Object other) =>
      other is BoosterCountBadge && other.count == count;

  @override
  int get hashCode => count.hashCode;
}

final class BoosterAdBadge extends BoosterBadge {
  const BoosterAdBadge();

  @override
  Offset get cornerOffset => const Offset(7, -8);

  @override
  bool operator ==(Object other) => other is BoosterAdBadge;

  @override
  int get hashCode => (BoosterAdBadge).hashCode;
}

final class BoosterCoinBadge extends BoosterBadge {
  const BoosterCoinBadge(this.price);

  final int price;

  @override
  Offset get cornerOffset => const Offset(9, -9);

  @override
  bool operator ==(Object other) =>
      other is BoosterCoinBadge && other.price == price;

  @override
  int get hashCode => price.hashCode;
}

/// Draws a [BoosterBadge]. Every badge has a 2 px `#FFF4E0` ring and a
/// 2 px solid bottom edge.
class BoosterBadgeView extends StatelessWidget {
  const BoosterBadgeView({required this.badge, super.key});

  final BoosterBadge badge;

  static const _ring = NestyShadow(color: AppColorTokens.textOnWood, spread: 2);

  static const _countStyle = SurfaceStyle(
    color: AppColorTokens.badge,
    shadows: [
      NestyShadow(color: AppColorTokens.badgeEdge, dy: 2),
      _ring,
    ],
  );

  static const _adStyle = SurfaceStyle(
    gradient: AppGradientTokens.ad,
    shadows: [
      NestyShadow(color: AppColorTokens.adEdge, dy: 2),
      _ring,
    ],
  );

  static const _coinStyle = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [AppColors.coinChipTop, AppColors.coinChipBottom],
    ),
    shadows: [
      NestyShadow(color: AppColors.coinChipEdge, dy: 2),
      _ring,
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: switch (badge) {
        BoosterCountBadge(:final count) => ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 22),
          child: NestySurface(
            style: _countStyle,
            radius: const BorderRadius.all(Radius.circular(11)),
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            alignment: Alignment.center,
            child: NestyNumberText(
              count,
              style: AppTextStyleTokens.number.copyWith(
                fontSize: 13,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
        BoosterAdBadge() => const NestySurface(
          style: _adStyle,
          radius: BorderRadius.all(Radius.circular(8)),
          width: 26,
          height: 22,
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsetsDirectional.only(start: 2),
            child: AdPlayGlyph.bare(boxWidth: 8),
          ),
        ),
        BoosterCoinBadge(:final price) => NestySurface(
          style: _coinStyle,
          radius: const BorderRadius.all(Radius.circular(11)),
          height: 22,
          padding: const EdgeInsetsDirectional.only(start: 3, end: 6),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CoinIcon(size: 15),
              const SizedBox(width: 3),
              NestyNumberText(
                price,
                style: AppTextStyleTokens.number.copyWith(
                  fontSize: 12,
                  color: AppColorTokens.coinText,
                ),
              ),
            ],
          ),
        ),
      },
    );
  }
}
