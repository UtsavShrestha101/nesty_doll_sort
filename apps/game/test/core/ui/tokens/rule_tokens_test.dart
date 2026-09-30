// Tokens v3 repeats a few owner rules (tokens.json `versus`, `chest`,
// `layout.extraSlot.limitPerLevel`, `settings.reduceMotion.default`). Rules
// never come from tokens (phase 4 architecture §1.1 policy 2; CLAUDE.md
// "Never invent a game rule"): the codegen documents these leaves and emits
// nothing, and this test pins each to the rule's own source, so a design
// that disagrees with a rule is noticed here instead of silently shipping.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/reduce_motion_mode.dart';
import 'package:nesty_game/core/services/chest/milestone_chest.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';

/// `flutter test` runs with apps/game as the working directory.
final Map<String, Object?> _tokens =
    jsonDecode(File('../../design/tokens.json').readAsStringSync())
        as Map<String, Object?>;

Object? _at(String path) {
  Object? node = _tokens;
  for (final key in path.split('.')) {
    node = (node! as Map<String, Object?>)[key];
  }
  return node;
}

void main() {
  test('vs Computer: the unlock level and the rewards are the Remote Config '
      'defaults (spec-prop §7.7)', () {
    expect(
      _at('versus.unlockAfterLevel'),
      RemoteConfigKeys.raceUnlockLevel.defaultValue,
    );
    expect(_at('versus.rewards'), {
      'rival_1': RemoteConfigKeys.raceReward1.defaultValue,
      'rival_2': RemoteConfigKeys.raceReward2.defaultValue,
      'rival_3': RemoteConfigKeys.raceReward3.defaultValue,
    });
  });

  test('the milestone chest: level 10 of each chapter, every 10th bonus '
      'level, 100 coins and a hint (spec-prop §7.3)', () {
    expect(
      _at('chest.milestone.levelInChapter'),
      MilestoneChest.chapterPosition,
    );
    expect(_at('chest.milestone.bonusEvery'), MilestoneChest.bonusEvery);
    expect(
      _at('chest.milestone.default.coins'),
      RemoteConfigKeys.chestCoins.defaultValue,
    );
    expect(
      _at('chest.milestone.default.hints'),
      RemoteConfigKeys.chestHints.defaultValue,
    );
  });

  test('the day-7 chest pays the streak reward (spec §7.5)', () {
    expect(
      _at('chest.streakDay7.coins'),
      RemoteConfigKeys.streak7Reward.defaultValue,
    );
  });

  test('two +1 Slots per level at most (spec §3.6, LayoutLimits)', () {
    expect(_at('layout.extraSlot.limitPerLevel'), LayoutLimits.maxExtraSlots);
  });

  test('Reduce motion follows the system by default (spec-prop §16)', () {
    expect(SettingsDefaults.reduceMotion, ReduceMotionMode.system);
    expect(
      _at('settings.reduceMotion.default'),
      'System',
      reason: 'the design\'s label for ReduceMotionMode.system',
    );
  });
}
