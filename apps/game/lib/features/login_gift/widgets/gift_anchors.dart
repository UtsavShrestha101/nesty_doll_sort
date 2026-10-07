import 'package:flutter/widgets.dart';
import 'package:nesty_game/features/fx/chest/reward_flight.dart';

/// Where the daily gift's claim lands on Home (frames 13.5, 13.5b, 13.6d),
/// read live at each claim rather than cached: the coin pill's face, which
/// the scrim's hole and the ring frame and the tally hangs under, and the
/// coin disc in it, where the coins land (`gift.claim.coins.to`).
@immutable
class GiftAnchors {
  const GiftAnchors({required this.pill, this.coin});

  /// The coin pill's face on screen; null when Home isn't laid out.
  final RewardFlightTarget pill;

  /// The coin disc in the pill; null lands the coins on the pill's centre.
  final RewardFlightTarget? coin;

  /// Where a coin lands.
  Rect? coinDisc() => coin?.call() ?? pill();
}

/// [key]'s widget's rectangle on screen, through every transform above it
/// (Home's pill sits in a `FittedBox` that shrinks a huge balance at 1.3×
/// text), or null when it isn't laid out.
Rect? globalRectOfKey(GlobalKey key) {
  final box = key.currentContext?.findRenderObject();
  if (box is! RenderBox || !box.attached || !box.hasSize) return null;
  return MatrixUtils.transformRect(
    box.getTransformTo(null),
    Offset.zero & box.size,
  );
}
