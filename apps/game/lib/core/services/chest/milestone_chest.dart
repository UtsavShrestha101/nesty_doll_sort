import 'dart:math' as math;

import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/catalog_models.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';

/// The milestone chest (E5; spec-prop §7.3; docs/plans/m7-design.md §9):
/// a fixed chest at level 10 of every chapter (campaign orders 10, 30 …
/// 190, and on past the launch chapters) and at every 10th Bonus Endless
/// level. Its contents are `chest_coins` and `chest_hints`, shown before it
/// opens; nothing is random (spec-prop §1.1 rules 2, 3). A replay, a daily
/// or a race never opens one.
///
/// Pure: the bloc asks [forWin] at a win and hands the grant to
/// `SaveService.recordLevelWin`, which pays it in the win's one update
/// unless `chests` already has it (once per level number).
abstract final class MilestoneChest {
  /// Chapters are 20 levels (spec §7.1).
  static const int chapterLength = ChapterInfo.levelsPerChapter;

  /// The chest's level within its chapter.
  static const int chapterPosition = 10;

  /// Every this many Bonus Endless levels.
  static const int bonusEvery = 10;

  /// The chest opens on campaign level [order]'s win.
  static bool opensAtCampaign(int order) =>
      order >= 1 && positionInChapter(order) == chapterPosition;

  /// The chest opens on Bonus Level [number]'s win.
  static bool opensAtBonus(int number) =>
      number >= 1 && number % bonusEvery == 0;

  /// Campaign [order]'s level within its chapter, 1–20.
  static int positionInChapter(int order) => (order - 1) % chapterLength + 1;

  /// The chest winning [request] opens, with its contents from [config]
  /// (never negative), or null: none at that level, or a kind that never
  /// opens one.
  static ChestGrant? forWin(PlayRequest request, RemoteConfigService config) {
    final (source, number) = switch (request) {
      CampaignPlay(:final order) when opensAtCampaign(order) => (
        ChestSource.campaign,
        order,
      ),
      BonusPlay(:final number) when opensAtBonus(number) => (
        ChestSource.bonus,
        number,
      ),
      _ => (null, 0),
    };
    if (source == null) return null;
    return ChestGrant(
      source: source,
      number: number,
      coins: math.max(0, config.value(RemoteConfigKeys.chestCoins)),
      hints: math.max(0, config.value(RemoteConfigKeys.chestHints)),
    );
  }

  /// After winning [request], the levels left to the next chest when it is
  /// the nearer goal, for the win card's countdown (m7-design §9): the
  /// figurine sits at position 20, the chest at 10, so on positions 1–9
  /// the chest is nearer (`10 − position`) and from 10 on the figurine is
  /// (null). Bonus Endless has no figurine, so it always counts down (10
  /// right after a chest). Null for daily, replay and race boards.
  static int? levelsToNext(PlayRequest request) => switch (request) {
    CampaignPlay(:final order) when order >= 1 =>
      positionInChapter(order) < chapterPosition
          ? chapterPosition - positionInChapter(order)
          : null,
    BonusPlay(:final number) when number >= 1 =>
      bonusEvery - number % bonusEvery,
    _ => null,
  };
}
