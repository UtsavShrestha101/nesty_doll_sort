# The home-screen widget: Apple Developer setup (owner)

The app and its widget share a store through an App Group (PROGRESS D312).
Before a build can be signed for a real iPhone or uploaded, each flavor's app id
and its widget id need the App Groups capability. Simulators need none of this.
Team `Z674BG8G6U`.

1. Sign in at https://developer.apple.com/account and open Certificates,
   Identifiers & Profiles, then Identifiers.
2. Register the three App Groups. Choose "+", then App Groups, then Continue,
   one group at a time:
   - Description "Nesty widget", Identifier `group.com.futrix.nesty`
   - Description "Nesty widget dev", Identifier `group.com.futrix.nesty.dev`
   - Description "Nesty widget stg", Identifier `group.com.futrix.nesty.stg`
3. Turn on App Groups for the three existing app ids. Open each identifier,
   tick "App Groups" and choose "Configure" (or "Edit"). Pick its group, then
   choose Continue and Save, and confirm the "modify app capabilities" prompt:
   - `com.futrix.nesty` → `group.com.futrix.nesty`
   - `com.futrix.nesty.dev` → `group.com.futrix.nesty.dev`
   - `com.futrix.nesty.stg` → `group.com.futrix.nesty.stg`
4. Register the three widget ids. Choose "+", then App IDs, then App, then
   Continue. Set Bundle ID to "Explicit", tick "App Groups" and configure it
   with the same group as its app:
   - Description "Nesty widget", Bundle ID `com.futrix.nesty.widget` →
     `group.com.futrix.nesty`
   - Description "Nesty widget dev", Bundle ID `com.futrix.nesty.dev.widget` →
     `group.com.futrix.nesty.dev`
   - Description "Nesty widget stg", Bundle ID `com.futrix.nesty.stg.widget` →
     `group.com.futrix.nesty.stg`
5. Let automatic signing refresh the profiles. Open
   `apps/game/ios/Runner.xcworkspace` in Xcode, with the team's Apple ID signed
   in under Settings, then Accounts. Select the Runner target, then NestyWidget.
   Signing & Capabilities should show "Automatically manage signing", team
   `Z674BG8G6U` and the App Groups capability with the flavor's group ticked.
   If Xcode shows a signing error, choose "Try Again" to download profiles that
   include the group. Running
   `flutter run --flavor dev -t lib/main_dev.dart` on a plugged-in iPhone also
   refreshes them. The old profiles stop matching once the entitlement is
   added, and Xcode replaces them on its own.
6. Archives (`flutter build ipa --flavor prod -t lib/main_prod.dart`) now
   contain `NestyWidget.appex`, signed with the `com.futrix.nesty.widget`
   profile. With automatic signing there is nothing else to do. Manual or CI
   signing would need a profile for each widget id.
