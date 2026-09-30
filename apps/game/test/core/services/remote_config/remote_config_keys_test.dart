import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/remote_config/defaults_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';

/// Spec §9.4, transcribed by hand from the spec text so a drifted default in
/// code fails here, plus the owner's `reward_medium` (Q5, D64), M3's
/// `reward_chapter` (docs/plans/m3-design.md §7.1) and spec-prop §9.4's M7
/// keys (docs/plans/m7-design.md §5).
const _spec94 = <String, Object>{
  'interstitial_first_level': 8,
  'interstitial_every_n_levels': 3,
  'interstitial_min_seconds': 90,
  'interstitial_session_grace_sec': 300,
  'home_banner_enabled': false,
  'rewarded_coin_multiplier': 3,
  'free_undos_per_level': 2,
  'price_undo': 20,
  'price_hint': 60,
  'price_slot': 150,
  'reward_easy': 10,
  'reward_medium': 10,
  'reward_hard': 25,
  'reward_superhard': 50,
  'reward_chapter': 150,
  'daily_reward': 50,
  'streak7_reward': 300,
  'remove_ads_offer_after_interstitials': 3,
  'rate_prompt_level': 15,
  'chest_coins': 100,
  'chest_hints': 1,
  'race_unlock_level': 20,
  'race_pace_ms_1': 3000,
  'race_pace_ms_2': 2400,
  'race_pace_ms_3': 1600,
  'race_pace_jitter_pct': 20,
  'race_reward_1': 20,
  'race_reward_2': 30,
  'race_reward_3': 40,
  'star3_slack_pct': 20,
  'star2_slack_pct': 60,
};

void main() {
  group('RemoteConfigKeys', () {
    test('holds exactly the spec §9.4 keys with exactly their defaults', () {
      expect(RemoteConfigKeys.defaults, equals(_spec94));
    });

    test('every default has the exact runtime type of the spec value', () {
      for (final key in RemoteConfigKeys.all) {
        expect(
          key.defaultValue.runtimeType,
          _spec94[key.name].runtimeType,
          reason: key.name,
        );
      }
    });

    test('names are unique, so no key shadows another', () {
      final names = RemoteConfigKeys.all.map((key) => key.name).toList();
      expect(names.toSet(), hasLength(names.length));
      expect(names, hasLength(31));
    });

    test('typed accessors point at the right parameters', () {
      expect(RemoteConfigKeys.interstitialFirstLevel.defaultValue, 8);
      expect(RemoteConfigKeys.homeBannerEnabled.defaultValue, isFalse);
      expect(RemoteConfigKeys.priceSlot.name, 'price_slot');
      expect(RemoteConfigKeys.priceSlot.defaultValue, 150);
      expect(RemoteConfigKeys.streak7Reward.defaultValue, 300);
      expect(RemoteConfigKeys.rewardMedium.name, 'reward_medium');
      expect(RemoteConfigKeys.rewardMedium.defaultValue, 10);
      expect(RemoteConfigKeys.rewardChapter.name, 'reward_chapter');
      expect(RemoteConfigKeys.rewardChapter.defaultValue, 150);
      expect(RemoteConfigKeys.chestCoins.name, 'chest_coins');
      expect(RemoteConfigKeys.chestHints.defaultValue, 1);
      expect(RemoteConfigKeys.raceUnlockLevel.defaultValue, 20);
      expect(RemoteConfigKeys.racePaceMs3.name, 'race_pace_ms_3');
      expect(RemoteConfigKeys.raceReward2.defaultValue, 30);
      expect(RemoteConfigKeys.star3SlackPct.name, 'star3_slack_pct');
      expect(RemoteConfigKeys.star2SlackPct.defaultValue, 60);
    });
  });

  group('DefaultsRemoteConfigService', () {
    test('returns the hard-coded default for every key', () async {
      final service = DefaultsRemoteConfigService();
      await service.refresh();
      for (final key in RemoteConfigKeys.all) {
        expect(service.value(key), key.defaultValue, reason: key.name);
      }
    });
  });

  group('FakeRemoteConfigService', () {
    test('returns an override, else the default', () {
      final service = FakeRemoteConfigService()
        ..setOverride(RemoteConfigKeys.priceHint, 99);

      expect(service.value(RemoteConfigKeys.priceHint), 99);
      expect(service.value(RemoteConfigKeys.priceUndo), 20);

      service.clearOverrides();
      expect(service.value(RemoteConfigKeys.priceHint), 60);
    });
  });
}
