import 'dart:math' as math;

import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/tactile_button.dart';
import 'package:nesty_game/core/ui/widgets/coins/coin_icon.dart';
import 'package:nesty_game/core/ui/widgets/home/text_link.dart';
import 'package:nesty_game/core/ui/widgets/modal/modal_card.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';

/// D112 (owner 2026-09-28 simulator review, replaces D86): a tap on a price
/// the balance can't cover opens this instead of jumping straight to the
/// Shop's Coins tab (frames 7.3b, 7.4c; menus spec 8.4, J.3). A card with the
/// item chip (its name and its price), "You need N more coins", where coins
/// come from, "Go to Shop" (its Coins tab) and a "Not now" text link that
/// closes and changes nothing. It only ever opens on the player's own tap on
/// a price, never automatically, so it is not a fail-triggered offer
/// (docs/plans/offline-game-brainstorm.md §5 rule 3).
///
/// Used on the Shop's skin cards (`SkinGridCard`), theme cards
/// (`ThemeGridCard`), the skin detail (`SkinDetailPage`) and, until M6's
/// ads, the gameplay booster popup (`BuyPopupBody`; D195). Sound `button`, no
/// jingle; it fades in over 240 ms (120 under reduce motion).
class NotEnoughCoinsDialog extends StatelessWidget {
  const NotEnoughCoinsDialog({
    required this.price,
    required this.balance,
    required this.onGoToShop,
    required this.onNotNow,
    this.itemName,
    super.key,
  });

  /// The coin price of the skin, theme or booster the player tapped.
  final int price;

  /// The player's balance right now ([balance] < [price], or the dialog
  /// wouldn't have opened; clamped defensively all the same).
  final int balance;

  /// The item's name for the chip ("Forest Bear", "Undo"); the chip shows
  /// only the price without it.
  final String? itemName;

  /// Closes the dialog, then opens the Shop's Coins tab.
  final VoidCallback onGoToShop;

  /// Closes the dialog and changes nothing (the close button does the
  /// same).
  final VoidCallback onNotNow;

  /// Opens the dialog over [context]. [onGoToShop] runs after it closes;
  /// "Not now", the close button and a tap on the scrim all just close it.
  static Future<void> show(
    BuildContext context, {
    required int price,
    required int balance,
    required VoidCallback onGoToShop,
    String? itemName,
  }) {
    final reduce = context.reduceMotion;
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.localizations.closeSemantics,
      barrierColor: AppColorTokens.scrim,
      transitionDuration: Duration(milliseconds: reduce ? 120 : 240),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: reduce
            ? child
            : ScaleTransition(
                scale: Tween(begin: 0.96, end: 1.0).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
                child: child,
              ),
      ),
      // A general dialog's page has no Material above it, so its text wore
      // the no-Material yellow double underline on a device (the phase-4
      // device run, 2026-09-30). A transparent Material gives it the app's
      // text defaults and paints nothing itself.
      pageBuilder: (BuildContext dialogContext, _, _) => Material(
        type: MaterialType.transparency,
        child: NotEnoughCoinsDialog(
          price: price,
          balance: balance,
          itemName: itemName,
          onGoToShop: () {
            Navigator.of(dialogContext).pop();
            onGoToShop();
          },
          onNotNow: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final needed = math.max(0, price - balance);
    final itemName = this.itemName;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Semantics(
          scopesRoute: true,
          explicitChildNodes: true,
          child: ModalCard(
            title: l10n.notEnoughCoinsTitle,
            onClose: onNotNow,
            closeSemanticLabel: l10n.closeSemantics,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ItemChip(name: itemName, price: price),
                const SizedBox(height: 16),
                Text(
                  l10n.notEnoughCoinsNeeded(needed),
                  textAlign: TextAlign.center,
                  style: AppTextStyleTokens.sheetTitle.copyWith(
                    fontSize: 30,
                    color: AppColorTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.notEnoughCoinsSource,
                  textAlign: TextAlign.center,
                  style: AppTextStyleTokens.body.copyWith(
                    fontSize: 17,
                    height: 24 / 17,
                    color: AppColorTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                TactileButton(
                  label: l10n.notEnoughCoinsGoToShop,
                  size: TactileButtonSize.medium,
                  onPressed: onGoToShop,
                ),
                const SizedBox(height: 2),
                TextLink(label: l10n.notNow, onPressed: onNotNow),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The dialog's item chip (frame 7.3b): the item's name and its price in a
/// `daily`-gradient coin pill, on a 52 tall white pill.
class _ItemChip extends StatelessWidget {
  const _ItemChip({required this.name, required this.price});

  final String? name;
  final int price;

  static const _chip = SurfaceStyle(
    color: AppColorTokens.surfaceWhite,
    shadows: [NestyShadow(color: AppColorTokens.surfaceEdge, dy: 4)],
  );

  static const _pill = SurfaceStyle(
    gradient: AppGradientTokens.daily,
    shadows: [NestyShadow(color: AppColorTokens.dailyEdge, dy: 3)],
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final name = this.name;
    return Semantics(
      container: true,
      label: name == null
          ? l10n.coinPrice(price)
          : '$name, ${l10n.coinPrice(price)}',
      excludeSemantics: true,
      child: NestySurface(
        style: _chip,
        radius: BorderRadius.circular(26),
        height: 52,
        padding: const EdgeInsetsDirectional.only(start: 18, end: 6),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (name != null) ...[
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    style: AppTextStyleTokens.cardTitle.copyWith(
                      fontSize: 22,
                      color: AppColorTokens.textPrimary,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            NestySurface(
              style: _pill,
              radius: BorderRadius.circular(20),
              height: 40,
              padding: const EdgeInsetsDirectional.only(start: 6, end: 12),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CoinIcon(size: 26),
                  const SizedBox(width: 6),
                  Text(
                    l10n.coinPrice(price),
                    style: AppTextStyleTokens.number.copyWith(
                      fontSize: 20,
                      color: AppColorTokens.coinText,
                    ),
                    maxLines: 1,
                    softWrap: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
