# Android flavor source set: `prod`

This folder is the Gradle source set for the **prod** product flavor
(`applicationId` `com.futrix.nesty`, label "Nesty"). Play Store builds use this flavor.

`google-services.json` for the **production** Firebase project goes here
(`android/app/src/prod/google-services.json`). It arrives in milestone M4 (spec §18).
The Google Services Gradle plugin checks the variant and flavor source set folders
(such as this one) before `android/app/`, so each flavor picks up its own file.

**Never write this file by hand.** The owner generates it with `flutterfire configure`
(its `--android-out` option points at this path). The same run adds the Google Services
plugin to the Gradle files. Run `flutterfire configure --help` to check the exact flags
of the installed CLI version.

Until M4, the game makes no Firebase calls and no plugin reads this folder.
CLAUDE.md hard rule 3 (offline-first) applies: the game must stay fully playable when
Firebase is missing or offline (spec §0, §13.4).
