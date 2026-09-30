import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/modal_placement.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';

/// A board that couldn't be set up (frames 12.6 and 9.3f; phase 4
/// architecture §6.6): Continue's next level (a Bonus Endless level whose
/// generation failed, rule 3) or a race's board. [title] and [body] say so
/// in the design's words ("The shelves need a moment"), [retryLabel] asks
/// for the same board again and [secondaryLabel], a text link, leaves
/// ("Back to Home", "Back to races"). It replaces the win or Chapter
/// complete overlay whose Continue it was, so the player is never left on a
/// dead Continue.
///
/// While a retry is in flight the caller passes a no-op [onRetry]. [versus]
/// takes section 09's indigo tone for a race (9.3f). Lane O draws frame
/// 12.6's look (the icon disc, the tones) through `ErrorCard`.
class NextLevelFailedCard extends StatelessWidget {
  const NextLevelFailedCard({
    required this.title,
    required this.body,
    required this.retryLabel,
    required this.secondaryLabel,
    required this.onRetry,
    required this.onSecondary,
    this.versus = false,
    super.key,
  });

  final String title;
  final String body;
  final String retryLabel;
  final String secondaryLabel;
  final VoidCallback onRetry;
  final VoidCallback onSecondary;

  /// A race's card (9.3f): the versus button and disc.
  final bool versus;

  /// Frame 12.6: the card 28 from each side, its top at y 250 (191 below
  /// a 59 safe area).
  static const double side = 28;
  static const double cardTop = 250 - 59;

  @override
  Widget build(BuildContext context) => OverlayEntrance(
    kind: OverlayEntranceKind.modal,
    builder: (context, progress, content) => Stack(
      fit: StackFit.expand,
      children: [
        Scrim(opacity: progress),
        ModalPlacement(cardTop: cardTop, side: side, child: content),
      ],
    ),
    child: ErrorCard(
      icon: IconUses.retry,
      tone: versus ? ErrorCardTone.versus : ErrorCardTone.warm,
      title: title,
      body: body,
      primaryLabel: retryLabel,
      onPrimary: onRetry,
      secondaryLabel: secondaryLabel,
      onSecondary: onSecondary,
      namesRoute: true,
    ),
  );
}
