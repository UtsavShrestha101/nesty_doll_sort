import 'dart:math' as math;

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_service.dart';

/// Coins for winning a level of [tier] (spec §7.3, §9.4): Remote Config's
/// `reward_easy`, `reward_medium` (Q5, D64), `reward_hard` or
/// `reward_superhard`. A negative tuned value pays nothing.
int winRewardFor(Tier tier, RemoteConfigService config) =>
    math.max(0, switch (tier) {
      Tier.easy => config.value(RemoteConfigKeys.rewardEasy),
      Tier.medium => config.value(RemoteConfigKeys.rewardMedium),
      Tier.hard => config.value(RemoteConfigKeys.rewardHard),
      Tier.superhard => config.value(RemoteConfigKeys.rewardSuperhard),
    });
