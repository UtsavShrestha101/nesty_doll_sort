import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/services/login_gift/login_gift_reward.dart';

/// A gift's contents as one phrase ("50 coins", "1 hint", "100 coins + 1
/// extra slot"), for the claimed line and the Tomorrow / Next lines. Built
/// from the ARB's plurals and `giftRewardPair`, never joined by hand. With
/// [shortSlots] the slot phrase is `gift_slots_short` ("1 slot"), copy.md's
/// fallback when "Tomorrow: …" would wrap past two lines.
String giftRewardLabel(
  AppLocalizations l10n,
  LoginGiftReward reward, {
  bool shortSlots = false,
}) {
  final parts = _parts(l10n, reward, shortSlots: shortSlots);
  if (parts.isEmpty) return '';
  return parts.reduce(l10n.giftRewardPair);
}

/// The same contents for a screen reader: two phrases joined by
/// `gift_a11y_chest_contents` ("100 coins, 1 extra slot"), as the Day 7
/// tile and the chest read them (copy.md "Daily gift"); three (a tuned
/// track) by the list separator.
String giftRewardSemantics(AppLocalizations l10n, LoginGiftReward reward) {
  final parts = _parts(l10n, reward);
  return switch (parts.length) {
    0 => '',
    1 => parts.single,
    2 => l10n.giftA11yChestContents(parts.first, parts.last),
    _ => l10n.joinList(parts),
  };
}

List<String> _parts(
  AppLocalizations l10n,
  LoginGiftReward reward, {
  bool shortSlots = false,
}) => [
  if (reward.coins > 0) l10n.giftCoins(reward.coins),
  if (reward.hints > 0) l10n.giftHints(reward.hints),
  if (reward.slots > 0)
    shortSlots
        ? l10n.giftSlotsShort(reward.slots)
        : l10n.giftSlots(reward.slots),
];
