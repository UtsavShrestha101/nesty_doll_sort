import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/models/booster.dart' show BoosterType;
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/modal_placement.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/l10n/app_localizations.dart';

/// The buy-a-booster popup (frames 3.2 Undo, 3.3 Hint, and +1 Slot's;
/// docs/plans/m3-design.md §7.3, §10.8): a [ModalCard] titled by the
/// booster with [BuyPopupBody] inside. The coin button fires
/// [onBuy] (`BoosterPurchaseConfirmed`); closing it (the scrim, the close
/// button) fires [onDismiss] (`BoosterPurchaseDismissed`).
///
/// M3 has no ads (D73): the ▶ "Watch ad" option and the offline "Connect to
/// watch an ad" copy are `TODO(M6)`, so this always shows the coin button
/// only, enabled when the price is affordable.
class BoosterBuyPopup extends StatelessWidget {
  const BoosterBuyPopup({
    required this.type,
    required this.price,
    required this.coins,
    required this.freeUndosPerLevel,
    required this.onBuy,
    required this.onDismiss,
    super.key,
  });

  final BoosterType type;
  final int price;

  /// The player's current balance ("You have N coins").
  final int coins;

  /// `free_undos_per_level` (Remote Config), for the Undo popup's "Your N
  /// free undos are used." Unused by the Hint and +1 Slot popups.
  final int freeUndosPerLevel;

  /// Null while it can't be afforded: the coin button shows disabled.
  final VoidCallback? onBuy;
  final VoidCallback onDismiss;

  /// NestyOverlay `isBuy`: the card sits 32 from each side, its top at 226
  /// on a 59 safe area.
  static const double side = 32;
  static const double cardTop = 226 - 59;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final spec = _BoosterSpec.of(type, l10n, freeUndosPerLevel);
    return OverlayEntrance(
      kind: OverlayEntranceKind.modal,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(
            opacity: progress,
            onDismiss: onDismiss,
            dismissLabel: l10n.closeSemantics,
          ),
          ModalPlacement(cardTop: cardTop, side: side, child: content),
        ],
      ),
      child: ModalCard(
        title: spec.title,
        onClose: onDismiss,
        closeSemanticLabel: l10n.closeSemantics,
        child: BuyPopupBody(
          icon: spec.icon,
          iconBackground: spec.iconBackground,
          iconColor: spec.iconColor,
          haloColor: spec.haloColor,
          benefitText: spec.benefitText,
          price: price,
          balanceLabel: l10n.balanceLine(coins),
          onBuy: onBuy,
        ),
      ),
    );
  }
}

/// Each booster's icon, colours and copy (NestyOverlay `BUY`: `buyHint`,
/// `buyUndo`, and +1 Slot's own values following the same radial-gradient
/// disc shape, since the frames don't show a +1 Slot buy popup directly but
/// m3-design §10.8 asks for one alongside 3.2/3.3).
final class _BoosterSpec {
  const _BoosterSpec({
    required this.title,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.haloColor,
    required this.benefitText,
  });

  final String title;
  final IconData icon;
  final Gradient iconBackground;
  final Color iconColor;
  final Color haloColor;
  final String benefitText;

  factory _BoosterSpec.of(
    BoosterType type,
    AppLocalizations l10n,
    int freeUndosPerLevel,
  ) => switch (type) {
    BoosterType.undo => _BoosterSpec(
      title: l10n.boosterUndo,
      icon: NestyIcons.undo,
      // "radial-gradient(circle at 40% 35%,#FFFBF2,#F6E2C2 60%,#E3C394)"
      iconBackground: const RadialGradient(
        center: Alignment(-0.2, -0.3),
        radius: 0.85,
        colors: [Color(0xFFFFFBF2), Color(0xFFF6E2C2), Color(0xFFE3C394)],
        stops: [0, 0.6, 1],
      ),
      iconColor: const Color(0xFF6E4526),
      haloColor: const Color(0x59E3C394),
      benefitText: l10n.buyUndoText(freeUndosPerLevel),
    ),
    BoosterType.hint => _BoosterSpec(
      title: l10n.boosterHint,
      icon: NestyIcons.lightbulb,
      // "radial-gradient(circle at 40% 35%,#FFF6C8,#FFE08A 60%,#F5C518)"
      iconBackground: const RadialGradient(
        center: Alignment(-0.2, -0.3),
        radius: 0.85,
        colors: [Color(0xFFFFF6C8), Color(0xFFFFE08A), Color(0xFFF5C518)],
        stops: [0, 0.6, 1],
      ),
      iconColor: const Color(0xFF8C5E12),
      haloColor: const Color(0x59FFE08A),
      benefitText: l10n.buyHintText,
    ),
    BoosterType.slot => _BoosterSpec(
      title: l10n.boosterExtraSlot,
      icon: NestyIcons.addBox,
      // "radial-gradient(circle at 40% 35%,#EFFCF2,#BDECC8 60%,#7FD08D)"
      iconBackground: const RadialGradient(
        center: Alignment(-0.2, -0.3),
        radius: 0.85,
        colors: [Color(0xFFEFFCF2), Color(0xFFBDECC8), Color(0xFF7FD08D)],
        stops: [0, 0.6, 1],
      ),
      iconColor: const Color(0xFF2F7A3E),
      haloColor: const Color(0x4D7FD08D),
      benefitText: l10n.buySlotText,
    ),
  };
}
