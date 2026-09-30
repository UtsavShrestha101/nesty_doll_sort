# Pass-and-play: a proposal (M7 close, D90)

Date: 2026-09-29. Status: **a proposal for the owner. Nothing is decided and
no code exists.** It answers BACKLOG M7's item "Local player vs player
(pass-and-play on one device)", D90's "a proposal after vs Computer", and
brainstorm §6's "Hot-seat duel". Every rule below is an option for the owner
to pick, change or drop. Whatever is picked becomes spec-prop text first
(rule 2: the rules then go into `nesty_core`).

## What it would be

Two people share one phone, offline, with no accounts and no network. They
play the same puzzle and hand the phone back and forth. It sits beside
vs Computer as the second offline mode. It's for a couple, a parent and a
child, or friends on a sofa.

## Rule options

| | A. Shared board, alternating moves | B. Same board, one after the other | C. Together (co-op) |
|---|---|---|---|
| **Play** | One board. The players take turns, one move each (brainstorm §6's basis) | Player 1 solves the board, then passes the phone. Player 2 solves an identical copy | One board, alternating moves as in A, with no opponent |
| **Win** | A family scores for whoever makes the move that completes it (core's `Completed` event). Most families wins; equal is a draw | Fewer moves wins; equal is a draw. Restart resets to 0 moves, as for stars (spec-prop §7.10) | No winner: "Solved together in N moves", with par shown after |
| **Undo** | Options: none; only your own move, before you pass; or free for both | Free, as in normal play | Free |
| **A stuck board** | Options: the match ends and the score stands; or Restart as a draw | Can't happen: each player can undo or restart | Undo or Restart |
| **Feel** | Most game-like. Blocking is possible: that is why brainstorm §7 rejects it against the computer | The quietest. No interaction, no blocking. Also works with one phone and turns taken across an evening | The coziest. No loser at all |

## The respect rules (spec-prop §1.1) and the offline game

- **Rules 1 and 3.** Every option uses a solvable board (§5.3 rule 8), with no timer or turn clock. Hint and +1 Slot stay off, as in a race, so nothing can be bought mid-match.
- **Rules 2 and 4.** A match pays nothing, or a fixed amount shown before it starts (see the questions). No offer is ever shown after a loss.
- **Rule 5.** No computer is involved. The players are "Player 1" and "Player 2", or names typed on the device, never online identities.
- **Rules 6 and 7.** Nothing depends on days, and no notification is added.
- **The ethics checklist (brainstorm §5).** Question 5, "nothing shames a loss", is the one to watch. A's "blocking" and any loss copy need warm lines from Claude Design, as 9.5's do. B and C have the least risk.
- **Offline.** All three work on one device with no network. A match in progress is never resumed: leaving it ends it with no reward, like a race (spec-prop §7.7).

## What it reuses

- **`GameSession` (core).** A and C run one session, and B runs two in turn, so no rule is duplicated. A needs one new pure piece in core (rule 2): turn order, who completed each family, the end rule and the undo policy, on core's `MoveEvent`s. B needs only a moves comparison. C needs nothing new.
- **The race page's shape (phase 2).** Its parts carry over:
  - `GameplayView` with a mode gate in the bloc, as race mode has;
  - a strip in place of the rival strip ("Player 2's turn", the score);
  - the Start, Undo and Restart bar (`RaceActionBar`);
  - result cards like 9.4 and 9.5, with Rematch, New match and Back;
  - a new "Pass to Player 2" card between turns, which B needs and A might.
- **The board source.** Like the race (`3_000_000 + …`), the generator can make it at the player's stage with a seeded, deterministic new seed range. Or a replay of a won campaign level can be used.

## Rough effort

Measured against phase 2 (vs Computer). Pass-and-play has no rival clock, no bot and no pace.

| Option | Core | App | Design and copy | Overall |
|---|---|---|---|---|
| A | a turn-and-score session and its tests | the mode, the strip, the result cards | new frames, about 15 strings | about half of phase 2 |
| B | a moves comparison only | the mode, the pass card, the result cards | fewer frames, about 10 strings | about a third |
| C | none | the mode and one result card | about 5 strings | the smallest |

Each option also needs spec-prop text, a device run, translations for the 9 languages, and an ethics-checklist row.

## Open questions for the owner

1. Build it at all, and when: in M7, or v1.1 as brainstorm §6 lists it?
2. Which option, A, B or C, or more than one?
3. For A: the undo option and the stuck-board option.
4. Reward: none, which leaves nothing to farm on one device, or a fixed amount shown up front? And do matches count toward Records and badges?
5. Board: generated at the player's stage, or a won level the players choose? Which tier or size?
6. Unlock and entry: after level 20 with vs Computer, a tile on Home, or a second choice on rival select?
7. Names: "Player 1" and "Player 2", or typed names kept only on the device?
8. Frames and copy: Claude Design would need the pass card, the strip and the result lines, sent as a follow-up request.
