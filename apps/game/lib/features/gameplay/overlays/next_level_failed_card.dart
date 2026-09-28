import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';
import 'package:nesty_game/features/gameplay/overlays/modal_placement.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_entrance.dart';
import 'package:nesty_game/features/gameplay/overlays/overlay_text_link.dart';

/// Continue's next level couldn't be made (review CORRECTNESS-3): a Bonus
/// Endless level whose generation failed after its retries, or whose
/// isolate died (the resolver answers null, rule 3). The page's
/// [RetryView] (the failure's message and "Try again", which asks for the
/// same level again) and a "Back to Home" link, on a card over the scrim,
/// replace the win or Chapter-complete overlay whose Continue it was, so
/// the player is never left on a dead Continue.
///
/// [onRetry] is null while a retry is in flight.
// TODO(design): no App Flow frame shows a next-level failure; this is the
// page's RetryView on the all-levels card's placement (NestyOverlay).
class NextLevelFailedCard extends StatelessWidget {
  const NextLevelFailedCard({
    required this.exception,
    required this.onRetry,
    required this.onHome,
    super.key,
  });

  final AppException exception;
  final VoidCallback? onRetry;
  final VoidCallback onHome;

  /// NestyOverlay's modal cards: 24 from each side, the all-levels card's
  /// top (150 on a 59 safe area).
  static const double side = 24;
  static const double cardTop = 150 - 59;

  /// The link's text 16 below Try again, as under 4.9's teal button.
  static const double _linkGap = 16;

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
    child: ModalCard(
      padding: ModalCard.plainPadding.copyWith(
        bottom: ModalCard.plainPadding.bottom - OverlayTextLink.slack,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RetryView(exception: exception, onRetry: onRetry ?? () {}),
          const SizedBox(height: _linkGap - OverlayTextLink.slack),
          OverlayTextLink(
            label: context.localizations.nextLevelFailedHome,
            onPressed: onHome,
          ),
        ],
      ),
    ),
  );
}
