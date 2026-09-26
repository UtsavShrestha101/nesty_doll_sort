---
name: research
description: |
  Current, sourced answers about Flutter stable, Dart, Flame, flutter_bloc, auto_route,
  injectable, freezed 3, hive_ce, Firebase and AdMob: API changes, package alternatives,
  official guidance. Spawns web-researcher and returns a TL;DR with sources, never a
  wall of quotes. Triggered by "/research <question>", "what's the current way to...".
argument-hint: "<question>"
---

# /research: short, current, sourced answers

## When to use
- "What changed in auto_route 11 / freezed 3 / injectable 3?"
- "What's the current way to do X in Flame 1.38?"
- "Is package A or package B better for X?" (spec §13.2 lists the preferred ones)
- "What is the official guidance on X?" (AdMob test ids, UMP consent, Firestore rules, iOS ATT)

## When NOT to use
- "Where is X in our code?": `code-explorer`.
- "How should we structure X?": `/plan` (with `architect`).
- "Run X": just run it.

## Steps
1. **Frame the question** with this workspace's context: the resolved version
   from the root `pubspec.lock` (for example auto_route is pinned to 11.1.0,
   see `docs/PROGRESS.md` B1), the Flutter/Dart versions (Flutter 3.41.2
   stable with Dart 3.11, the `FLUTTER_VERSION` pin in `.github/workflows/ci.yaml`.
   The local `flutter --version` prints `3.43.0-1.0.pre-35`, which is not a
   real release; see PROGRESS.md D15), and "stable channel only" (CLAUDE.md
   rule 1).
2. **Spawn `web-researcher`** with the question and that context. It checks the
   local package sources in `~/.pub-cache/hosted/pub.dev/<package>-<version>/`
   first, then the official docs.
3. **Relay** its TL;DR, Specifics, Sources and Uncertain sections.
4. **If the answer implies action**, ask before acting:
   - A new package or a version change: CLAUDE.md rule 9 needs a reason in
     `docs/PROGRESS.md`, and dependency versions are locked. Offer `/plan`.
   - Something that needs the master or beta channel, `flutter_scene` or
     Flutter GPU is ruled out by rule 1. Say so.

## Output
What `web-researcher` returned, verbatim, plus at most one follow-up suggestion.

## Anti-patterns
- Doing the searching yourself and filling the main context with whole pages.
- Answering "current" or "latest" questions from memory.
- Burying the TL;DR under background.
- Recommending an upgrade or a new package without flagging rule 9 and the locked versions.
