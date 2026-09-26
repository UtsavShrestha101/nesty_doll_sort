# iOS Firebase config: `stg` flavor

`GoogleService-Info.plist` for the **stg** (staging) Firebase project goes in this folder
(`ios/config/stg/GoogleService-Info.plist`). It arrives in milestone M4 (spec §18).

- iOS bundle ID to register in Firebase: `com.futrix.nesty.stg`
- Xcode build configurations for this flavor: `Debug-stg`, `Profile-stg`, `Release-stg`
  (scheme `stg`)

**Never write this file by hand.** The owner generates it with `flutterfire configure`,
using its per-build-configuration mode (`--ios-build-config` + `--ios-out`), so the build
phase FlutterFire adds copies this file into the app for the `stg` configurations. Run
`flutterfire configure --help` to check the exact flags of the installed CLI version.

Until M4, the game makes no Firebase calls, so this folder only holds this README.
CLAUDE.md hard rule 3 (offline-first) applies: the game must stay fully playable when
Firebase is missing or offline (spec §0, §13.4).
