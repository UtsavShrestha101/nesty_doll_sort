---
name: l10n
description: |
  Add, rename or update localization keys (or add a new locale) in apps/game or
  apps/admin ARB files with real translations, then regenerate AppLocalizations.
  Triggered by "add string X", "rename key Y", "/l10n <app> key:'English'".
argument-hint: "<game|admin> keyName:\"English value\" | old -> new | key=updated:\"New\" | --locale <code>"
---

# /l10n: manage ARB strings

## File layout (per app)
- Source of truth: `apps/<app>/lib/l10n/app_en.arb`, configured by `apps/<app>/l10n.yaml`
- Other locales: `apps/<app>/lib/l10n/app_<code>.arb`. The game has es, pt
  (Brazilian; `app_pt_BR.arb` is `@@locale` only), id, hi, de, fr, tr and ja;
  the admin has none. Each locale's respect and allow lists are in
  `apps/game/test/l10n/locales/<code>.dart`.
- Generated (never edit): `apps/<app>/lib/l10n/app_localizations*.dart`

## Inputs
- `keyName:"English value"`: add
- `oldKey -> newKey`: rename
- `keyName=updated:"New English"`: update the English text and re-translate every other locale
- `--locale <code>`: add a whole locale (for example `es`)

## ADD
1. Validate that the key is camelCase and absent:
   `grep -n '"<keyName>"' apps/<app>/lib/l10n/app_en.arb` must print nothing.
2. Add it to `app_en.arb` with an `@<keyName>` block containing a `description`
   (where it shows, with the spec section) and typed `placeholders`. Use ICU
   `plural`/`select` for counts and choices.
3. Add a **real translation** to every other `app_*.arb` in that app. Never use
   `TODO_TRANSLATE:` and never copy the English. For several locales, spawn
   `l10n-specialist`.
4. Run `cd apps/<app> && flutter gen-l10n`.
5. Verify: `grep -l '"<keyName>"' apps/<app>/lib/l10n/app_*.arb | wc -l` equals the number of `.arb` files.

## RENAME
1. Confirm `<old>` exists and `<new>` does not.
2. Rename it in every `.arb` (both the key and its `@` block) and every
   `context.localizations.<old>` in `apps/<app>/lib` and `test`.
3. Run `flutter gen-l10n`, then `flutter analyze`. There must be no undefined-getter errors.

## UPDATE
Change the English text and re-translate every other locale in the same
change. Leave no "retranslate later" marker. Run `flutter gen-l10n`.

## NEW LOCALE
Spawn `l10n-specialist`. It creates `app_<code>.arb` with every key translated
(a regional locale such as pt_BR also needs `app_pt.arb`) and checks fit at 1.3× text scale.

## Output
- Action, keys, and files touched (with the locale list)
- Verification grep count, gen-l10n and analyze results

## Anti-patterns
- Hand-editing `app_localizations*.dart`. The block-generated hook refuses it.
- Keys without descriptions, or string concatenation instead of placeholders.
- Localizing data ids (color ids, level ids, analytics names, product IDs).
