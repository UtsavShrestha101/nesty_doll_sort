# Prompt: start M7 in a fresh Claude Code session

Paste everything inside the block into a new Claude Code session in this repo.
It points at the docs rather than repeating them, so keep those docs current.
They are [PROGRESS.md](../PROGRESS.md) D90–D93, [BACKLOG.md](../BACKLOG.md)
"M7" and the plans linked below.

```
/milestone M7 --start, then run it.

Read first: docs/PROGRESS.md D90–D93, docs/BACKLOG.md "M7", and in docs/plans/: offline-game-brainstorm.md, mode-vs-computer.md, spec-proposals-m7.md and claude-design-request-m7.md. This milestone is 100% offline: no Firebase, ads, purchases or any other backend.

Owner decisions (2026-09-28):
- Audience: 13+ with an all-ages feel (spec §1 unchanged). Design engagement as if children may play: non-essential notifications off until opted in, value-framed copy only, no nudges, and the respect rules (spec-proposals-m7.md §1.1). Every feature passes the brainstorm doc's six-question ethics checklist before it's merged; record the answers in its lane report.
- Approved in principle (D92): the gentle streak, the daily share card, the opt-in daily reminder, the milestone chest, relaxed mode, replay + best moves, Records & badges, first launch opens L1, plus E11–E14 (chapter plan, bundle-check gates, time-to-first-win, reduce-motion row). Approved in principle (D93): the vs Computer race, three rivals built from spec §6.4's two bots plus pace. No new bot policy.
- Rules: until I paste spec-proposals-m7.md into GAME_SPEC.md, its text as approved in D92/D93 is the spec for these features. Never edit GAME_SPEC.md. Keep CLAUDE.md's facts current in the same change (its "Keeping this file current" section), but never change its rules. If something is still ambiguous, stop and ask.
- Numbers are defaults behind Remote Config keys with hard-coded defaults (rule 6). The open ones are Q76–Q87: use their defaults and don't wait.
- Levels 31–200: follow the chapter plan (brainstorm §4). Make candidates with nesty_levels (seeded), grade them with the existing solver and simulator through bundle check, add the E12 gates, and hand-tune L31, L51, L71, L130 and the ten finales. L101 is ordinary (the golden doll is v1.1). The confirmed curve needs no more than 3 shelves or 4 slots per row, so levels don't wait on Claude Design; maxSize 5–6 uses the D36 scaling stand-in until design B.3–B.6 lands.
- I haven't sent claude-design-request-m7.md to Claude Design yet; I'll send it later. Remind me to send it when you reach phase 2, and add anything you find missing from it to that file first. Until each delivery lands in design/: chapters 7–10 reuse ch01–ch04, copy keeps placeholders, and each new screen is built in the design system from the tokens with a TODO(design) and a BACKLOG item. When a delivery lands, sync it (sync_design_assets) and wire it; tokens.json wins over a frame.
- New packages (share_plus, flutter_local_notifications, and the time-zone packages its daily schedule needs) get their rule-9 reasons in PROGRESS when added. Every new save field is a schema step with a migration; never reuse a Hive box name, typeId or field index.
- The M2/M3 device checks stay with me; don't wait for them. Local pass-and-play: a short proposal at the end only. Online PvP stays in "Later".

How: plan first (/plan), then run it as a workflow like M3 (parallel background agents with checkpoint files if the Workflow tool is off; Opus if Sonnet hits its limit). Phases:
1. No-wait work: levels 31–200 + a playthrough segment per new mechanic (L31, L51, L71, L130); the M7 fix items already in BACKLOG; overflow tests on the 5 sizes at 1.0× and 1.3×; E9 first launch → L1; E6 relaxed mode; E2 gentle streak; E5 milestone chest; E7 replay + best moves; E8 Records & badges; E12–E14.
2. vs Computer: the core rival API and race rules (nesty_core, deterministic, tests), the race bloc with its pace clock (fake-clock tests), the screens (stand-ins until frames 09.x), "Computer" on every rival surface, and a playthrough segment that wins against rival 1.
3. E3 share card and E4 opt-in reminder: NotificationService interface + real + fake, the permission flow after the player says yes, the Settings rows.
4. Claude Design deliveries as they land: themes 7–10, board presets, frames 09.x and 10.x, intro loops, states, tokens, copy (Q73 and G.6–G.9).
5. Close: fidelity pass against every frame with ui-designer, the accessibility audit (including the reduce-motion row), translations (es, pt-BR, id, hi, de, fr, tr, ja), animation polish, the /milestone M7 gates, nesty-test on iOS and Android, and a review with a fix pass.

Don't commit until I say. Conventional commits, no attribution.
```
