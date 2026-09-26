import 'package:flutter/material.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';

/// Frame 3.5, Out of moves (spec §2.3, §10.2 #5): "No moves left! / Pick a
/// way to keep sorting." over the board, with Undo first ("Free · 1 left"
/// while free undos remain), +1 Slot (the recommended row, hidden once the
/// level has its 2 extra slots) and Restart (always free).
///
/// Tapping the scrim dismisses it: the booster bar still offers the same
/// three actions.
///
/// TODO(M3): the coin price on +1 Slot and on Undo after the free ones
/// (frames 3.3, 3.5). TODO(M6): the ▶ ad option and its offline variant
/// (frame 3.7).
class OutOfMovesSheet extends StatelessWidget {
  const OutOfMovesSheet({
    required this.freeUndosLeft,
    required this.showFreeUndos,
    required this.onUndo,
    required this.onExtraSlot,
    required this.onRestart,
    required this.onDismiss,
    super.key,
  });

  /// The "Free · n left" tag's count.
  final int freeUndosLeft;

  /// Whether undos are counted (false in the dev flavor, where they never
  /// run out).
  final bool showFreeUndos;

  /// Null when undo isn't possible (no free undo left until M3's coins).
  final VoidCallback? onUndo;

  /// Null hides the +1 Slot row (2 already added, or none to use).
  final VoidCallback? onExtraSlot;
  final VoidCallback onRestart;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    final onExtraSlot = this.onExtraSlot;
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
            subtitle: l10n.oomUndoSubtitle,
            trailing: showFreeUndos && freeUndosLeft > 0
                ? SheetRowTag(l10n.oomUndoFree(freeUndosLeft))
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
              trailing: SheetRow.chevron,
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
