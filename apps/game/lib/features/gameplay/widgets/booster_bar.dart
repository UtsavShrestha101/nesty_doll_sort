import 'package:nesty_game/core/common_imports.dart';

/// Bottom booster bar (spec §10.2 #3, §8): Undo, Hint, +Slot, Restart.
///
/// All disabled until the board is playable.
/// TODO(M2): wire to the gameplay controller (undo, solver hint, extra slot,
/// restart). TODO(M3): inventory count bubbles and the booster purchase
/// popup. TODO(design): booster buttons from the design system.
class BoosterBar extends StatelessWidget {
  const BoosterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    // Each button gets an equal share of the width, so four of them fit a
    // 320 dp phone at 1.3x text (spec §16, M7 "no layout overflows").
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _BoosterButton(
              icon: Icons.undo_rounded,
              label: l10n.boosterUndo,
            ),
          ),
          Expanded(
            child: _BoosterButton(
              icon: Icons.lightbulb_outline_rounded,
              label: l10n.boosterHint,
            ),
          ),
          Expanded(
            child: _BoosterButton(
              icon: Icons.add_box_outlined,
              label: l10n.boosterExtraSlot,
            ),
          ),
          Expanded(
            child: _BoosterButton(
              icon: Icons.refresh_rounded,
              label: l10n.restart,
            ),
          ),
        ],
      ),
    );
  }
}

class _BoosterButton extends StatelessWidget {
  const _BoosterButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Min 48 dp tap target (spec §10.3) comes from TextButton's defaults.
    // Icon over label rather than TextButton.icon: side by side, the label
    // is squeezed to nothing on narrow phones.
    return TextButton(
      onPressed: null,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
