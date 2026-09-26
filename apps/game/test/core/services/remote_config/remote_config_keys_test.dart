import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/services/remote_config/defaults_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';

/// Spec §9.4, transcribed by hand from the spec text so a drifted default in
/// code fails here.
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
  'reward_hard': 25,
  'reward_superhard': 50,
  'daily_reward': 50,
  'streak7_reward': 300,
  'remove_ads_offer_after_interstitials': 3,
  'rate_prompt_level': 15,
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
      expect(names, hasLength(17));
    });

    test('typed accessors point at the right parameters', () {
      expect(RemoteConfigKeys.interstitialFirstLevel.defaultValue, 8);
      expect(RemoteConfigKeys.homeBannerEnabled.defaultValue, isFalse);
      expect(RemoteConfigKeys.priceSlot.name, 'price_slot');
      expect(RemoteConfigKeys.priceSlot.defaultValue, 150);
      expect(RemoteConfigKeys.streak7Reward.defaultValue, 300);
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
