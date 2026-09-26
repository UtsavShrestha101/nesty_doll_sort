# iOS Firebase config: `dev` flavor

`GoogleService-Info.plist` for the **dev** Firebase project goes in this folder
(`ios/config/dev/GoogleService-Info.plist`). It arrives in milestone M4 (spec §18).

- iOS bundle ID to register in Firebase: `com.futrix.nesty.dev`
- Xcode build configurations for this flavor: `Debug-dev`, `Profile-dev`, `Release-dev`
  (scheme `dev`)

**Never write this file by hand.** The owner generates it with `flutterfire configure`,
using its per-build-configuration mode (`--ios-build-config` + `--ios-out`), so the build
phase FlutterFire adds copies this file into the app for the `dev` configurations. Run
`flutterfire configure --help` to check the exact flags of the installed CLI version.

Until M4, the game makes no Firebase calls, so this folder only holds this README.
CLAUDE.md hard rule 3 (offline-first) applies: the game must stay fully playable when
Firebase is missing or offline (spec §0, §13.4).
