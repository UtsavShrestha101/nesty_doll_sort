---
name: services
description: Service interfaces with real + fake implementations, offline-first silent failure, ads/Remote Config rules.
paths:
  - "apps/*/lib/core/services/**"
  - "apps/*/lib/core/repository/**"
  - "apps/*/lib/bootstrap.dart"
  - "apps/*/test/core/services/**"
  - "apps/*/test/core/repository/**"
---

# Service rules

## Interface + real + fake (CLAUDE.md rule 4)

`AdsService`, `PurchaseService`, `AnalyticsService`, `RemoteConfigService`,
`LevelRepository`, `SaveService`, `AudioService` and `HapticsService` (plus
`DatabaseService`) each have:

- an `abstract interface class` in `core/services/<name>/<name>_service.dart`
  (repositories: `core/repository/<name>_repository.dart`);
- a real implementation named after its backend (`HiveDatabaseService`,
  `SystemHapticsService`, later `AdMobAdsService`, `FirebaseRemoteConfigService`…);
- a `Fake<Name>` in `fake_<name>_service.dart` that is deterministic,
  in-memory and offline.

They are bound per injectable environment (`AppEnv.real` / `AppEnv.fake`). See
`di-injectable.md`. Callers, cubits and tests only ever see the interface.

## Offline-first, silent failure (CLAUDE.md rule 3)

- The game is fully playable with **no network from first launch**, using
  bundled levels and the bundled Classic skin (spec §13.4, §13.5). No startup
  step may wait on the network.
- Every network call (Firestore, Storage, ads, IAP, Remote Config, Analytics)
  has a timeout, catches **everything**, logs it (and from M4 records a
  Crashlytics non-fatal), and returns a safe fallback. It never throws into a
  cubit, never blocks input and never shows an error dialog.
- Background work (level sync §13.4, Remote Config fetch, ad preload) is
  fire-and-forget from the caller's point of view. Wrap it with `unawaited(...)`
  and swallow errors inside the service.
- Content sync never swaps the level in progress mid-session (§13.4 step 5). A
  failed skin download keeps the current skin (§13.5).

## Ads (spec §9.1, milestone M6)

- Debug builds use **Google's official test IDs** (publisher `3940256099942544`;
  copy them from developers.google.com/admob/android/test-ads and
  developers.google.com/admob/ios/test-ads). Release IDs come from
  `--dart-define` at build time (rule 5). The block-secrets hook refuses any
  other `ca-app-pub-` ID.
- Don't add `google_mobile_ads` before its native App IDs are configured in
  AndroidManifest/Info.plist, because the SDK crashes at launch without them.
  Show UMP consent before initializing ads (§9.3).
- Pacing (§9.1: first level, every N wins, minimum seconds, 5-minute session
  grace, `adsRemoved`) lives in a pure policy class that takes an **injected
  clock**, so M6 can unit-test every rule with a fake clock.
- Ads never appear during play, on restart or right after a fail. Offline, ad
  buttons fall back to their coin price. The game never waits more than 3 s
  for an ad.

## Remote Config (spec §9.4, CLAUDE.md rule 6)

- Every key is declared once in `RemoteConfigKeys` (`remote_config_keys.dart`)
  **with its hard-coded default**. A read always returns a usable value. A
  fetch failure means defaults, silently.
- A new key needs its default and a test in `remote_config_keys_test.dart`.
  Prices and rewards (§7.3) come from here, never from literals in features.

## Analytics (spec §14.4)

Event names and parameters are exactly those in §14.4. Never log PII.

- Until M4 the log-only `FakeAnalyticsService` also serves `AppEnv.real`
  (docs/PROGRESS.md D5), so it keeps **no history**: a list there would grow
  without limit in release builds.
- Bloc and widget tests that assert on events use a mocktail
  `MockAnalyticsService`, e.g.
  `verify(() => analytics.logEvent('level_win', parameters: any(named: 'parameters')))`.
- In M4, when `FirebaseAnalyticsService` takes `AppEnv.real`, the fake becomes
  `env: [AppEnv.fake]` only and records events in memory
  (`List<({String name, Map<String, Object> parameters})> events` plus
  `clear()`) for tests to read.

## Purchases (spec §9.2)

Product IDs are exactly those in §9.2. Restore Purchases is required on iOS.
v1 verifies receipts on the client. Persist `adsRemoved` locally so an offline
player who paid never sees ads.
