import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';
import 'package:nesty_game/features/gameplay/bloc/win_reward.dart';

void main() {
  test('the defaults are spec §7.3 (medium pays like easy)', () {
    final config = FakeRemoteConfigService();
    expect(winRewardFor(Tier.easy, config), 10);
    expect(winRewardFor(Tier.medium, config), 10);
    expect(winRewardFor(Tier.hard, config), 25);
    expect(winRewardFor(Tier.superhard, config), 50);
  });

  test('every tier reads its Remote Config key; medium reads reward_easy', () {
    final config = FakeRemoteConfigService()
      ..setOverride(RemoteConfigKeys.rewardEasy, 11)
      ..setOverride(RemoteConfigKeys.rewardHard, 33)
      ..setOverride(RemoteConfigKeys.rewardSuperhard, 77);
    expect(winRewardFor(Tier.easy, config), 11);
    expect(winRewardFor(Tier.medium, config), 11);
    expect(winRewardFor(Tier.hard, config), 33);
    expect(winRewardFor(Tier.superhard, config), 77);
  });

  test('a negative tuned value pays nothing', () {
    final config = FakeRemoteConfigService()
      ..setOverride(RemoteConfigKeys.rewardHard, -5);
    expect(winRewardFor(Tier.hard, config), 0);
  });
}
