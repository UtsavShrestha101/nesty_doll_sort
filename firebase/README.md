# firebase/

Firebase project config for Nesty: Firestore + Storage security rules, the
Firestore index the game's level sync needs, and local emulator settings.
Spec: §14 (Firebase), §13.4 (level sync), §15 (admin panel).

| File | What it is |
|---|---|
| `firebase.json` | Points the CLI at the rules/index files; emulator ports |
| `firestore.rules` | Spec §14.3 sketch, semantics unchanged. Finalised in M5 |
| `storage.rules` | Public read of `skins/`, `themes/`, `museum/`; writes only for admins (`firestore.exists` on `admins/{uid}`) |
| `firestore.indexes.json` | Composite index `levels(status ASC, order ASC)` for `where status == published orderBy order` (spec §13.4 step 3) |
| `.firebaserc.example` | Template for the project aliases. Copy to `.firebaserc` and fill in the real ids |

## Local development (emulators)

Run everything from this directory, because `firebase.json` lives here:

```bash
cd firebase
cp .firebaserc.example .firebaserc   # once, then edit the project ids
firebase emulators:start             # Auth :9099, Firestore :8080, Storage :9199, UI :4000
```

Firebase is wired into the apps in M4 (game) and M5 (admin); until then nothing
talks to these emulators. Once it is, dev builds can point at them, and every
network call must still fail silently when they are not running (CLAUDE.md rule 3).

## Rules of engagement

- The owner deploys: `firebase deploy --only firestore:rules,firestore:indexes,storage`.
  Claude asks before any `firebase deploy` (it is on the `ask` list in
  `.claude/settings.json`).
- Firebase app config (`firebase_options*.dart`, `google-services.json`,
  `GoogleService-Info.plist`) comes from `flutterfire configure`, which only the
  owner runs. Never hand-write it.
- `admins/{uid}` documents are created by hand in the Firebase console (spec §14.1).

## Open items for M5

- The catch-all `match /{col}/{id}` in `firestore.rules` also matches
  `admins/{uid}`, so an existing admin can write `admins/*` despite
  `allow write: if false` (Firestore ORs overlapping matches). The spec sketch is
  kept as-is until the owner decides.
- The catch-all read has no `status` check, so draft `chapters`, `skins` and
  `themes` (they have a `status` field, spec §14.1) are publicly readable and
  listable, unlike draft levels. `dailyOverrides` for future dates are
  readable too, so a player could see upcoming daily puzzles. Both follow the
  spec sketch.
- Storage's `firestore.exists()` is a cross-service rule: on the first
  `firebase deploy --only storage` the CLI asks to grant the Storage service
  agent read access to Firestore, and admin uploads fail until that is granted.
- Add emulator-backed rules tests (for example with `@firebase/rules-unit-testing`) —
  that needs a Node toolchain, which the repo does not have yet. A one-off
  check on 2026-09-26 (firebase-tools 13.35.1 emulators, not committed) found
  both rules files compile and pass 34 allow/deny cases that follow spec §14.3,
  including the `admins/*` overlap above and the cross-service admin check.
- The admin's levels table filters (chapter, tier, status) may need more
  composite indexes. Add them when the M5 queries exist; the emulator prints the
  index definition it is missing.
