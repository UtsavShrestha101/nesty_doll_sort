---
name: firebase
description: Firebase rules, indexes, emulators and config-file ownership (spec §14).
paths:
  - "firebase/**"
  - "apps/*/lib/**/firebase*"
---

# Firebase rules

- **Config files are the owner's.** `firebase_options*.dart`, `google-services.json`
  and `GoogleService-Info.plist` come from `flutterfire configure`, which only
  the owner runs (CLAUDE.md). Never write, invent or edit them. The
  block-generated hook and the settings deny-list both refuse, and
  `flutterfire configure` itself is denied for Claude.
- `firebase/firestore.rules` is the spec §14.3 **sketch** with its semantics
  unchanged. It is finalised in M5 together with emulator-backed rules tests.
  Never loosen it. Any change must match the spec, or go to the owner as a
  question first. There is a known overlap (the catch-all `/{col}/{id}` also
  matches `admins/{uid}`), documented in the file header and `firebase/README.md`.
- `firebase/storage.rules`: public read of `skins/`, `themes/`, `museum/`;
  writes only for admins through `firestore.exists(.../admins/$(uid))`.
  Everything else is denied.
- Every new compound Firestore query (an equality or range on one field plus
  `orderBy` on another) gets its composite index in `firebase/firestore.indexes.json`
  in the same change. The level sync query `levels where status == published orderBy order`
  (§13.4) is already there.
- Collections and document shapes are spec §14.1 and §5.2, and the Storage
  layout is §14.2. Publishing, unpublishing or reordering levels is **one
  batched write** that also bumps `config/manifest.levelsVersion` and
  `publishedCount`, and keeps `order` unique and continuous (§15 Publishing).
- Develop against the emulators: `cd firebase && firebase emulators:start`
  (Auth 9099, Firestore 8080, Storage 9199, UI 4000). `firebase deploy` is
  owner-only and is on the settings `ask` list.
- Firebase packages arrive in M4 (game) and M5 (admin), each with a reason in
  `docs/PROGRESS.md` (rule 9). In the game, Firebase init must fail silently
  offline: the game keeps its own `levels_cache.json` (§13.4) and never
  depends on Firestore's cache.
