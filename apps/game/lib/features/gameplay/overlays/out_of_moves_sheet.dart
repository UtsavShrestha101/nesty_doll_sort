import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';

/// Frame 3.5, Out of moves (spec §2.3, §10.2 #5): "No moves left! / Pick a
/// way to keep sorting." over the board, with Undo first, +1 Slot (the
/// recommended row, hidden once the level has its 2 extra slots; its coin
/// price once none are held) and Restart (always free).
///
/// The Undo row has three states (ui-spec-game §2.5, §2.6):
/// - free undos left: "Take back your last move" with "Free · 1 left"
///   (frame 3.5);
/// - spent (frame 12.8): "Your 2 free undos are used" and its coin price
///   chip (the ▶ ad option joins it in M6; offline it is the price alone);
/// - relaxed (frame 10.9b): a green ring round the row, "Free, as often as
///   you like" and a "Free" chip with the infinity glyph, never a price.
///
/// Tapping the scrim dismisses it: the booster bar still offers the same
/// three actions.
///
/// TODO(M6): the ▶ ad option beside the price chips and its offline variant
/// (frames 3.7, 12.8).
class OutOfMovesSheet extends StatelessWidget {
  const OutOfMovesSheet({
    required this.freeUndosLeft,
    required this.showFreeUndos,
    required this.onUndo,
    required this.onExtraSlot,
    required this.onRestart,
    required this.onDismiss,
    this.undoPrice = 0,
    this.slotPrice = 0,
    this.extraSlotsLeft = 0,
    this.unlimitedBoosters = false,
    this.relaxed = false,
    this.freeUndosTotal = 2,
    super.key,
  });

  /// The "Free · n left" tag's count.
  final int freeUndosLeft;

  /// How many free undos a level starts with (`freeUndosPerLevel`): "Your 2
  /// free undos are used" once they are spent (frame 12.8).
  final int freeUndosTotal;

  /// Whether undos are counted (false in the dev flavor, where they never
  /// run out).
  final bool showFreeUndos;

  /// Relaxed mode (E6; m7-design §10, §15.6): the Undo row is always free
  /// (`oomUndoFreeUnlimited`, frame 10.9b), with no count, price or ad row.
  /// Takes priority over [showFreeUndos]/[freeUndosLeft].
  final bool relaxed;

  /// Null when undo isn't possible (nothing to undo). Not null but the
  /// free undos are spent: the row shows [undoPrice] instead of the tag.
  final VoidCallback? onUndo;

  /// Null hides the +1 Slot row (2 already added). Not null with none held:
  /// the row shows [slotPrice] instead of the chevron.
  final VoidCallback? onExtraSlot;
  final VoidCallback onRestart;
  final VoidCallback onDismiss;

  /// `price_undo`/`price_slot` (Remote Config, m3-design §7.3).
  final int undoPrice;
  final int slotPrice;

  /// +1 Slot boosters held: a coin price shows only once this hits 0.
  final int extraSlotsLeft;

  /// The dev flavor: never a coin price (boosters don't run out).
  final bool unlimitedBoosters;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final onExtraSlot = this.onExtraSlot;
    final undoPriced =
        !unlimitedBoosters && (!showFreeUndos || freeUndosLeft <= 0);
    return OverlayEntrance(
      kind: OverlayEntranceKind.sheet,
      builder: (context, progress, content) => Stack(
        fit: StackFit.expand,
        children: [
          Scrim(
            opacity: progress,
            onDismiss: onDismiss,
            dismissLabel: l10n.closeSemantics,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              // A short screen at 1.3× text scrolls the rows (NestySheet).
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.9,
              ),
              child: content,
            ),
          ),
        ],
      ),
      child: NestySheet(
        title: l10n.oomTitle,
        subtitle: l10n.oomSubtitle,
        children: [
          SheetRow(
            icon: NestyIcons.undo,
            title: l10n.boosterUndo,
            subtitle: relaxed
                ? l10n.oomUndoFreeUnlimited
                : undoPriced
                ? l10n.oomUndoSpent(freeUndosTotal)
                : l10n.oomUndoSubtitle,
            highlighted: relaxed,
            trailing: relaxed
                ? const _FreeChip()
                : showFreeUndos && freeUndosLeft > 0
                ? SheetRowTag(l10n.oomUndoFree(freeUndosLeft))
                : undoPriced
                ? _CoinChip(price: undoPrice)
                : null,
            onTap: onUndo,
          ),
          if (onExtraSlot != null)
            SheetRow(
              icon: NestyIcons.addBox,
              title: l10n.oomSlotTitle,
              subtitle: l10n.oomSlotSubtitle,
              tone: SheetRowTone.success,
              highlighted: true,
              trailing: unlimitedBoosters || extraSlotsLeft > 0
                  ? SheetRow.chevron
                  : _CoinChip(price: slotPrice),
              onTap: onExtraSlot,
            ),
          SheetRow(
            icon: NestyIcons.restartAlt,
            title: l10n.restart,
            subtitle: l10n.oomRestartSubtitle,
            trailing: SheetRow.chevron,
            onTap: onRestart,
          ),
        ],
      ),
    );
  }
}

/// The +1 Slot row's price chip, reused for Undo's (NestyOverlay `isOom`'s
/// coin pill: height 40, padding 0/10/0/6, radius 14, `#FFF1C9→#F9DC8A`,
/// a 20 px coin and the number).
class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.price});

  final int price;

  static const _style = SurfaceStyle(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFF1C9), Color(0xFFF9DC8A)],
    ),
    shadows: [NestyShadow(color: Color(0xFFD4A93A), dy: 4)],
  );

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: NestySurface(
      style: _style,
      radius: const BorderRadius.all(Radius.circular(14)),
      height: 40,
      padding: const EdgeInsetsDirectional.only(start: 6, end: 10),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CoinIcon(size: 20),
          const SizedBox(width: 4),
          Text(
            '$price',
            style: AppTextStyleTokens.number.copyWith(
              fontSize: 15,
              color: AppColorTokens.coinText,
            ),
          ),
        ],
      ),
    ),
  );
}

/// The relaxed Undo row's chip (frame 10.9b): 34 tall, radius 14,
/// `successTint` with a 2 dp `successRing`, the `all_inclusive` glyph 20 and
/// "Free" in Fredoka 700 14 `#2F7A3E`.
class _FreeChip extends StatelessWidget {
  const _FreeChip();

  static const _style = SurfaceStyle(
    color: AppColorTokens.successTint,
    shadows: [
      NestyShadow(color: AppColorTokens.successRing, inset: true, spread: 2),
    ],
  );

  @override
  Widget build(BuildContext context) => NestySurface(
    style: _style,
    radius: const BorderRadius.all(Radius.circular(14)),
    height: 34,
    padding: const EdgeInsets.symmetric(horizontal: 10),
    alignment: Alignment.center,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(IconUses.undoUnlimited, size: 20, color: Color(0xFF2F7A3E)),
        const SizedBox(width: 4),
        Text(
          context.localizations.oomUndoFreeChip,
          style: AppTextStyleTokens.buttonSmall.copyWith(
            fontSize: 14,
            height: 1,
            color: const Color(0xFF2F7A3E),
          ),
        ),
      ],
    ),
  );
}
