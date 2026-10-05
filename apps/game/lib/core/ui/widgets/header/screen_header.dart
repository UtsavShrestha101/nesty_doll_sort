import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/theme/app_text_styles.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/icon_tactile_button.dart';
import 'package:nesty_game/core/ui/widgets/coins/coin_pill.dart';

/// Where a [ScreenHeader] puts its title.
enum ScreenHeaderTitleAlignment {
  /// Left-aligned, 12 dp after the 48 dp leading box, with no trailing
  /// spacer: the one alignment of every screen (m7-4 10.2, `screenHeader`;
  /// Daily, the Shop and the skin detail included). A tab screen with no
  /// button starts its title at `tabScreenTitleLeft` (20).
  start,

  /// Centred between the leading action and the trailing widget (the m7-3
  /// look; no screen uses it now).
  center,
}

/// A screen's top row (design/README.md "Components"; tokens `screenHeader`,
/// frames 8.1, 5.1): a 46 px back/close button (in a 48 dp target), the 26/700
/// title beside it on the left, which scales down rather than cut, and an
/// optional coin pill at the right. Settings closes (pops); Daily goes back;
/// the shell's Shop tab has neither button and shows the title and coins.
class ScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  const ScreenHeader({
    required this.title,
    this.onBack,
    this.onClose,
    this.coins,
    this.coinPillKey,
    this.titleAlignment = ScreenHeaderTitleAlignment.start,
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

  /// Keys the [CoinPill], so a reward can fly its coins to it (the day-7
  /// chest on Daily, as `GameplayHud.coinPillKey` does for the milestone
  /// chest). Ignored without [coins].
  final GlobalKey? coinPillKey;

  /// [ScreenHeaderTitleAlignment.start] (the default) puts the title's box 12 dp
  /// after the 48 dp leading box and drops the balancing spacer.
  final ScreenHeaderTitleAlignment titleAlignment;

  /// The gap between the leading box and a start-aligned title.
  static const double startGap = 12;

  static const double height = 48;
  static const double _leadingSize = 46;

  /// The leading button's box: its 46 px face in a 48 dp target (spec
  /// §10.3, review R17), which the trailing spacer matches.
  static const double _leadingBox = 48;

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
    final start = titleAlignment == ScreenHeaderTitleAlignment.start;
    final Widget trailing;
    if (coins != null) {
      trailing = _CountingCoinPill(pillKey: coinPillKey, coins: coins);
    } else if (hasLeading && !start) {
      trailing = const SizedBox(width: _leadingBox);
    } else {
      trailing = const SizedBox.shrink();
    }
    return SizedBox(
      height: height,
      child: Row(
        children: [
          if (start)
            SizedBox(
              // No button: the tab screen's title starts at 20, 4 dp inside
              // the 16 dp side margin the page already gives.
              width: hasLeading
                  ? _leadingBox
                  : ScreenHeaderTokens.tabScreenTitleLeft -
                        ScreenHeaderTokens.side,
              child: hasLeading ? Center(child: leading) : null,
            )
          else
            leading,
          if (start && hasLeading) const SizedBox(width: startGap),
          Expanded(
            // One line that scales down instead of cutting (m7-design §15's
            // shared rule; "Chapters" at 1.3× on 360 dp, review R29).
            child: Semantics(
              header: true,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: start ? Alignment.centerLeft : Alignment.center,
                child: Text(
                  title,
                  style: AppTextStyles.screenTitle,
                  textAlign: start ? TextAlign.start : TextAlign.center,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// The header's coin pill. When the balance drops (a skin or theme bought,
/// `motion.purchaseItem.balance`, m7-4 4.11) the number counts down over
/// 400 ms; a rise, the first build and reduce motion show the value at once.
class _CountingCoinPill extends StatefulWidget {
  const _CountingCoinPill({required this.coins, this.pillKey});

  final int coins;
  final GlobalKey? pillKey;

  @override
  State<_CountingCoinPill> createState() => _CountingCoinPillState();
}

class _CountingCoinPillState extends State<_CountingCoinPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(
      milliseconds: PurchaseItemTokens.balanceCountDownMs,
    ),
  );
  late int _from = widget.coins;

  @override
  void didUpdateWidget(_CountingCoinPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.coins == oldWidget.coins) return;
    if (widget.coins < oldWidget.coins && !context.reduceMotion) {
      // From what is showing now, so a second spend mid-count carries on.
      _from = _display(oldWidget.coins);
      unawaited(_controller.forward(from: 0));
    } else {
      _controller.value = 1;
    }
  }

  /// What the pill shows now on its way to [to]: [to] itself at rest, else
  /// the count between [_from] and it.
  int _display(int to) {
    if (_controller.isDismissed || _controller.isCompleted) return to;
    final t = Curves.easeOut.transform(_controller.value);
    return (_from + (to - _from) * t).round();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) =>
        CoinPill(key: widget.pillKey, coins: _display(widget.coins)),
  );
}
