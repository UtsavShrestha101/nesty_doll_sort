import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/coins/coin_icon.dart';
import 'package:nesty_game/core/ui/widgets/number/nesty_number_text.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/tactile/tactile_surface.dart';

/// "Coin pill: height 40, radius 20, padding 0 14 0 6, 28px coin plus a
/// tabular number. On Home it adds a 24px green '+' circle (opens Shop)"
/// (design/README.md "Components").
///
/// The HUD pill (NestyBoard) isn't pressable. With [onAdd] it is the Home
/// pill (NestyMenus: 42 tall, a 30 px coin, the "+"), and the whole pill is
/// the button, which gives the "+" a full touch target.
class CoinPill extends StatelessWidget {
  const CoinPill({
    required this.coins,
    this.onAdd,
    this.coinKey,
    this.compact = false,
    super.key,
  });

  /// The count in the locale's compact form: [homeNeedsCompact].
  final bool compact;

  /// Whether the Home pill would have to shrink its full count below
  /// [_readableScale] to fit [maxWidth] (a huge balance on a 360 dp phone,
  /// worst in Turkish, whose Baloo 2 digits are wider than Fredoka's):
  /// then it shows the compact count. Its screen-reader label keeps the
  /// exact one.
  static bool homeNeedsCompact(
    BuildContext context,
    int coins,
    double maxWidth,
  ) {
    if (!maxWidth.isFinite) return false;
    final painter = TextPainter(
      text: TextSpan(
        text: NestyNumberText.formatCount(context, coins),
        style: AppTextStyles.number,
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final width = painter.width + _homeChrome;
    painter.dispose();
    return width * _readableScale > maxWidth;
  }

  /// The Home pill around its count: padding 6 and 8, the 30 dp coin, its
  /// 7 dp gap, the 9 dp gap and the 24 dp "+".
  static const double _homeChrome = 6 + 30 + 7 + 9 + 24 + 8;

  /// The smallest scale a count may be drawn at before it turns compact.
  static const double _readableScale = 0.8;

  final int coins;

  /// A key on the coin disc, so a reward flight can land on it (the daily
  /// gift's coins, `gift.claim.coins.to`).
  final Key? coinKey;

  /// Opens the Shop (M3). Null is the HUD pill.
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final home = onAdd != null;
    final coinsLabel = l10n.coinsSemantics(coins);
    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        KeyedSubtree(
          key: coinKey,
          child: CoinIcon(size: home ? 30 : 28),
        ),
        const SizedBox(width: 7),
        NestyNumberText(coins, style: AppTextStyles.number, compact: compact),
        if (home) ...[const SizedBox(width: 9), const _PlusCircle()],
      ],
    );
    final radius = BorderRadius.circular(home ? 21 : AppRadii.pill);
    final padding = EdgeInsetsDirectional.only(start: 6, end: home ? 8 : 14);
    final height = home ? 42.0 : HudTokens.coinPillHeight;
    if (!home) {
      return Semantics(
        label: coinsLabel,
        excludeSemantics: true,
        child: NestySurface(
          style: SurfaceStyles.coinPill,
          radius: radius,
          height: height,
          padding: padding,
          alignment: Alignment.center,
          child: row,
        ),
      );
    }
    return TactileSurface(
      style: SurfaceStyles.coinPill,
      radius: radius,
      onPressed: onAdd,
      height: height,
      padding: padding,
      semanticLabel: l10n.coinPillShopSemantics(coins),
      excludeChildSemantics: true,
      child: row,
    );
  }
}

/// The 24 px green "+" (NestyMenus Home coin pill).
class _PlusCircle extends StatelessWidget {
  const _PlusCircle();

  static const _style = SurfaceStyle(
    color: AppColorTokens.success,
    shadows: [
      NestyShadow(color: AppColorTokens.successEdge, inset: true, dy: -2),
    ],
  );

  @override
  Widget build(BuildContext context) => const NestySurface(
    style: _style,
    radius: BorderRadius.all(Radius.circular(12)),
    width: 24,
    height: 24,
    alignment: Alignment.center,
    child: Icon(NestyIcons.add, size: 19, color: Color(0xFFFFFFFF)),
  );
}
