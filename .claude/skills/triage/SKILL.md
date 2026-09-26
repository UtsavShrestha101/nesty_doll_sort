---
name: triage
description: |
  First pass on a GitHub issue (or a pasted bug report): read it, find the code and
  spec sections involved, form a light root-cause hypothesis and draft a reply with
  labels and a next action. Never posts without approval. Triggered by "/triage
  <issue-number-or-url>", "triage this bug report".
argument-hint: "<issue number, issue URL, or pasted report>"
---

# /triage: first pass on an issue

## When to use
- A new issue or player report arrived and the user wants an assessment.
- Backlog grooming.

## Steps
1. **Read the issue.**
   ```bash
   gh issue view <number-or-url> --json title,body,labels,comments,author,state
   ```
   If there is no GitHub remote yet, or `gh` isn't set up, work from the text
   the user pastes (or WebFetch a public URL).
2. **Place it.** Which part is involved:
   - `nesty_core` rules or solver (spec §2–§6)
   - the game: Flame board, overlays, save, ads, IAP
   - the admin panel (§15)
   - content: a level or a skin
   - Firebase rules or sync (§13.4, §14)

   Spawn `code-explorer` with the keywords, symbols and paths from the report.
3. **Check the facts you need**: app version and flavor, platform and device
   (RAM), level id, online or offline, and steps. List whatever is missing.
4. **Rule reports are spec questions first.** For "this move should be
   allowed" or "the level is impossible", compare with spec §4 and run the
   level through the solver (via `nesty-core-engineer` or `tools/` once it
   exists). If the code follows the spec, the reply is "working as designed",
   or a spec question for the owner. Never promise a rule change.
5. **Hypothesize** the root cause, as a light version of `/debug` (you are not fixing it here).
6. **Draft** one reply:
   - **Needs info**: 2–3 specific questions.
   - **Confirmed bug, obvious fix**: `path:line`, the fix in one line, and the test to add.
   - **Confirmed bug, non-trivial**: suggest `/plan`.
   - **Working as designed**: cite the spec section in player-friendly words.
   - **Spec question**: for the owner; add it to the open questions in `docs/PROGRESS.md` only if the user agrees.
   - **Duplicate**: link the existing issue.
7. **Show the draft.** Post it (`gh issue comment`) or change labels only after
   the user approves, and only with labels that exist (`gh label list`).

## Output
```
## Issue
#<n>: <title>

## Assessment
<one paragraph: area, spec sections, likely cause, confidence>

## Suggested reply
<draft>

## Suggested labels
<existing labels>

## Next action
<needs-info / fix via /debug / /plan / spec question / duplicate / close>
```

## Anti-patterns
- Posting or labeling without the user's approval.
- "Can you reproduce and let us know?" Say what you checked and exactly what you need.
- Treating a player's rule suggestion as a bug, or promising rule changes.
- Triaging without reading the code or the spec section involved.
