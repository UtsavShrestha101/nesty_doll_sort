---
name: pr
description: |
  Open a GitHub pull request for the current branch with `gh pr create`: a summary,
  the spec sections and milestone, and a test plan with Nesty's real commands. NO
  Claude attribution (no "Generated with Claude Code" footer, no Co-Authored-By).
  Triggered by "/pr", "open a PR", "raise a PR". Only when the user asks.
---

# /pr: open a pull request

## When to use
- The branch is committed (ideally after `/review` and `/commit`) and the user asked for a PR.

## When NOT to use
- The workspace is not a git repository yet, or has no GitHub remote. Tell
  the user. Never run `git init` or add a remote on your own.
- The current branch is `main`. Refuse and ask for a feature branch.
- The working tree has uncommitted changes. Ask the user to commit or stash first.

## Steps
1. **Snapshot** (in parallel):
   ```bash
   git status
   git branch --show-current
   git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null || echo "no upstream"
   git log origin/main..HEAD --oneline
   git diff origin/main...HEAD --stat
   ```
2. **Refuse** on `main`, or with a dirty tree.
3. **Push if needed**, after telling the user:
   `git push -u origin "$(git branch --show-current)"`. Never force-push.
4. **Draft** the title and body.
   - Title: conventional-commit style, under 72 characters, taken from the
     most representative commit (`feat(core): add swallow move to tryMove`).
   - Body:
     ```markdown
     ## Summary
     - <what changed and why, 1–3 bullets>

     ## Spec / milestone
     - Spec §<x.y> · M<N> (docs/PROGRESS.md updated: yes/no)

     ## Test plan
     - [ ] `flutter analyze` at the root: No issues found
     - [ ] `cd packages/nesty_core && dart test`
     - [ ] `cd packages/nesty_render && flutter test`
     - [ ] `cd apps/game && flutter test` · `cd apps/admin && flutter test`
     - [ ] Codegen fresh: `flutter gen-l10n` + `dart run build_runner build` in each touched app, no diff
     - [ ] Manual: `cd apps/game && flutter run --flavor dev -t lib/main_dev.dart` on <device>: <specific flows>
     - [ ] Offline (airplane mode) still fully playable, if a service changed (rule 3)

     ## Notes
     - Packages added: <name — reason in docs/PROGRESS.md> / none
     - New ARB keys: <keys> / none · TODO(design) left: <list> / none
     ```
   Keep only the lines that apply, and list real flows ("play level 3 to a win,
   undo twice"), not "tested".
5. **Show the user** the title and body, and wait for confirmation.
6. **Open** it through a heredoc so the formatting survives:
   ```bash
   gh pr create --base main --title "<title>" --body "$(cat <<'EOF'
   ## Summary
   ...
   EOF
   )"
   ```
7. **Report** the PR URL.

## No attribution
`.claude/settings.json` sets `attribution.pr` to `""`. Don't add a
"Generated with Claude Code" footer, a `Co-Authored-By:` line or any other
Claude mention to the title, the body or the commits.

## Output
- The PR URL
- The title and body used

## Anti-patterns
- Opening a PR with uncommitted changes, or without the user's go-ahead.
- Force-pushing to update a PR.
- Vague test plans ("tests pass").
- Listing commands that were not run as checked.
