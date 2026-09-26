---
name: commit
description: |
  Generate a conventional-commit message from the staged diff and create the commit,
  with NO Claude attribution (no Co-Authored-By, per the owner). Triggered by "/commit"
  or "commit these changes". Only when the user asks to commit.
---

# /commit: conventional commit from the staged diff

## When to use
- The user asked to commit, ideally after `/review`.
- Something is staged.

## When NOT to use
- The workspace is not a git repository yet. Tell the user; never run `git init` on your own.
- Nothing is staged (`git diff --cached` is empty). Ask the user to stage first.
- The working tree is dirty in unexpected places. Ask first.

## Steps
1. **Snapshot** (in parallel):
   ```bash
   git status
   git diff --cached --stat
   git log -5 --oneline
   ```
2. **Refuse to commit** (tell the user why) if the staged diff contains:
   - `.env*`, `*.jks`, `*.keystore`, `*.p12`, `*.pem`, `key.properties` or a service-account JSON;
   - a secret or a real AdMob ID (any `ca-app-pub-` publisher other than Google's test `3940256099942544`).
     An `AIza…` apiKey inside owner-generated `firebase_options*.dart`,
     `google-services.json` or `GoogleService-Info.plist` is expected, not a secret;
   - a hand-edited generated file: a `*.g.dart`, `*.freezed.dart`, `*.gr.dart`,
     `di.config.dart` or `app_localizations*.dart` change with no matching source change;
   - any change under `design/`.
   Warn and ask before continuing if the diff adds `print(` calls, or source
   annotations changed without the regenerated files staged.
3. **Draft** the message:
   ```
   <type>(<scope>): <subject>

   <body: 1–3 sentences on WHY; cite spec sections or the milestone>
   ```
   - `type`: feat / fix / refactor / perf / test / docs / chore / build / ci
   - `scope`: `core`, `render`, `game`, `admin`, `firebase`, `tools`, `ci`, or a feature (`gameplay`, `daily`)
   - `subject`: imperative, under 72 characters, no trailing period ("add swallow move to tryMove")
4. **Show the message** and wait for confirmation, unless the user said "commit without asking".
5. **Commit** through a heredoc:
   ```bash
   git commit -m "$(cat <<'EOF'
   feat(core): add swallow move to tryMove

   Spec §2.2 rule 3 / §4: T goes inside M when T.outer == M.inner - 1.
   Covered by rule and invalid-move tests.
   EOF
   )"
   ```
6. **Never add `Co-Authored-By:` or any Claude attribution line.**
   `.claude/settings.json` sets `attribution.commit` to `""`. Don't add it by hand either.
7. **Report** the hash and subject.

## Anti-patterns
- `git add -A` or `git commit -a` sweeping in unrelated files.
- Vague messages ("fix: bug").
- `--no-verify`, amending pushed commits, or pushing without being asked.
