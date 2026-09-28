import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/widgets/buttons/icon_tactile_button.dart';
import 'package:nesty_game/core/ui/widgets/coins/coin_pill.dart';

/// A screen's top row (design/README.md "08 Settings & system", "05 Daily";
/// frames 8.1, 5.1): a 46 px back/close button, a centred 26/700 heading,
/// and an optional coin pill. Settings closes (pops); Daily goes back; the
/// shell's Shop/Museum tabs have neither and just show the heading and
/// coins.
///
/// With one leading action and no [coins], a same-width spacer balances it
/// so the heading stays centred (frame 8.1's `noCoins` spacer).
class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const ScreenHeader({
    required this.title,
    this.onBack,
    this.onClose,
    this.coins,
    super.key,
  }) : assert(
         onBack == null || onClose == null,
         'a header has at most one leading action',
       );

  final String title;

  /// Shows a back arrow that pops (Daily).
  final VoidCallback? onBack;

  /// Shows a close glyph that pops (Settings).
  final VoidCallback? onClose;

  /// Shows a read-only [CoinPill] (Daily, Shop, Museum).
  final int? coins;

  static const double height = 48;
  static const double _leadingSize = 46;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final onClose = this.onClose;
    final onBack = this.onBack;
    final Widget leading;
    if (onClose != null) {
      leading = IconTactileButton(
        icon: NestyIcons.close,
        semanticLabel: l10n.closeSemantics,
        onPressed: onClose,
        size: _leadingSize,
        iconSize: 26,
      );
    } else if (onBack != null) {
      leading = IconTactileButton(
        icon: NestyIcons.arrowBack,
        semanticLabel: l10n.backSemantics,
        onPressed: onBack,
        size: _leadingSize,
        iconSize: 26,
      );
    } else {
      leading = const SizedBox.shrink();
    }
    final hasLeading = onClose != null || onBack != null;
    final coins = this.coins;
    final Widget trailing;
    if (coins != null) {
      trailing = CoinPill(coins: coins);
    } else if (hasLeading) {
      trailing = const SizedBox(width: _leadingSize);
    } else {
      trailing = const SizedBox.shrink();
    }
    return SizedBox(
      height: height,
      child: Row(
        children: [
          leading,
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                style: AppTextStyles.screenTitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
