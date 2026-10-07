import 'package:nesty_game/core/services/remote_config/remote_config_keys.dart';

/// Tunable values (spec §9.4). Every read returns a usable value — the key's
/// hard-coded default when nothing better is available (CLAUDE.md rule 6).
///
/// TODO(M4): add `FirebaseRemoteConfigService` (firebase_remote_config) for
/// the real env; it sets `RemoteConfigKeys.defaults` as in-app defaults and
/// falls back to them on any fetch error. Keys are `int`, `bool` and, since
/// the daily gift's `login_gift_track`, `String` (`getString`); a string
/// key's reader validates the value itself and falls back to the default.
abstract interface class RemoteConfigService {
  /// Fetches and activates new values in the background. Must never throw and
  /// never block the UI; offline it is a silent no-op (CLAUDE.md rule 3).
  Future<void> refresh();

  /// The current value of [key], or its default.
  T value<T extends Object>(RemoteConfigKey<T> key);
}
