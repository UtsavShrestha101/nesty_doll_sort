import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_game/core/services/records/badge.dart';
import 'package:nesty_game/core/ui/art/ui_art.dart';
import 'package:nesty_game/core/ui/art/ui_art_image.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/widgets/feedback/nesty_toast.dart';

/// The "badge earned" toast (E8; docs/plans/m7-design.md §12, §15.2): the
/// existing [NestyToast] in its success tone, "Badge earned!" and the
/// badge's name. The win overlay shows one per `GameplayState.newBadges`
/// (the gameplay-ui lane), and the race's result in phase 2; badges granted
/// on load stay silent.
///
/// A queued toast shows the badge's own art (`UiArt.badge`, m7-3's I.6).
/// The glyphs below serve only the fallback with no [ToastHost] above (a
/// bare test page), which draws a plain `NestyToast`.
abstract final class BadgeToast {
  /// [badge]'s glyph for the no-host fallback.
  static IconData iconOf(BadgeId badge) => switch (badge) {
    BadgeId.firstFamily => NestyIcons.checkCircle,
    BadgeId.glassBreaker => NestyIcons.lock,
    BadgeId.iceMelter => NestyIcons.acUnit,
    BadgeId.tallOrder => NestyIcons.autoAwesome,
    BadgeId.grandNest => NestyIcons.redeem,
    BadgeId.level100 => NestyIcons.thumbUp,
    BadgeId.level200 => NestyIcons.star,
    BadgeId.dailies7 => NestyIcons.calendarToday,
    BadgeId.dailies30 => NestyIcons.localFireDepartment,
    BadgeId.firstRace => NestyIcons.smartDisplay,
    BadgeId.allRivals => NestyIcons.shield,
    BadgeId.museumFull => NestyIcons.museum,
  };

  /// Queues [badge]'s toast on the nearest [ToastHost] (the result card's
  /// own, at top 60: Q122, Q136): "Badge earned · {name}", its earned line
  /// and the badge's 38 dp art (copy.md G.8). With no host (a bare test
  /// page) it falls back to `NestyToast.show`'s overlay entry.
  static void show(BuildContext context, BadgeId badge) {
    final l10n = context.localizations;
    final title = l10n.badgeEarnedToastTitle(l10n.badgeName(badge.id));
    final message = l10n.badgeLine(badge.id);
    final queue = ToastHost.maybeOf(context);
    if (queue == null) {
      NestyToast.show(
        context,
        tone: NestyBannerTone.success,
        icon: iconOf(badge),
        title: title,
        message: message,
      );
      return;
    }
    queue.enqueue(
      ToastSpec(
        tone: ToastTone.badge,
        title: title,
        message: message,
        leading: UiArtImage.square(
          UiArt.badge(badge, earned: true),
          extent: ToastCard.leadingSize,
        ),
      ),
    );
  }
}
