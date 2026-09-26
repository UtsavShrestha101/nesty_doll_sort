import 'dart:math' as math;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';

/// Coins for winning a level of [tier] (spec §7.3, §9.4): Remote Config's
/// `reward_*`. Medium pays `reward_easy`, because §9.4 has no
/// `reward_medium` key and §7.3 pays "easy/medium" the same (PROGRESS Q5).
/// A negative tuned value pays nothing.
int winRewardFor(Tier tier, RemoteConfigService config) =>
    math.max(0, switch (tier) {
      Tier.easy || Tier.medium => config.value(RemoteConfigKeys.rewardEasy),
      Tier.hard => config.value(RemoteConfigKeys.rewardHard),
      Tier.superhard => config.value(RemoteConfigKeys.rewardSuperhard),
    });
