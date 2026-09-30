"""Independent reference for the vs Computer rival (spec-prop §7.7).

Written from the documented definitions only, never from the Dart code:
- the rules, the PRNG, derive and the two bot policies of simref.py (itself
  written from spec §4, §6.4 and the documented draw order);
- the rival as documented on RivalBot (lib/src/simulator/rival_bot.dart):
  run i of bot b (casual 0, smart 1) in the race seeded s draws from
  Prng(derive(s, 0x52564C30 + b, i)); a step first checks the win, then
  restarts when the run has made `cap` moves or its board has no useful move
  (no legal move, or only pointless ones), and otherwise plays the bot's move;
  a restart puts the board back at the level's start and plays no move.

It reproduces the expectations of test/parity/rival_parity_test.dart and the
rival digests of test/parity/vectors/race_vectors.dart. Use it (or another
independent implementation) to recompute them after an intended change,
never by copying Dart output. Python 3.9+, no packages:

    python3 packages/nesty_core/test/simulator/reference/rivalref.py

Each step is one u32 word, `code << 16 | from << 8 | to`, with code 1 for a
move, 2 for the move that finishes and 3 for a restart (from = to = 0), and a
case's digest is Hash64 of its words, little-endian (as simref.py's run
digests and the Dart `parityDigestU32s`).
"""
import json, os, re, sys

sys.dont_write_bytecode = True  # no __pycache__ in the source tree
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from simref import (Board, Level, Prng, casual, derive, hash64_hex,  # noqa: E402
                    load_levels, pointless, smart)

RUN_STREAM = 0x52564C30  # 'RVL0'
MOVED, FINISHED, RESTARTED = 1, 2, 3


def run_seed(race_seed, bot, run):
    return derive(race_seed, RUN_STREAM + bot, run)


class Rival:
    def __init__(self, level, bot, race_seed, cap=250):
        self.level, self.bot, self.seed, self.cap = level, bot, race_seed, cap
        self.run = 0
        self.board = Board(level)
        self.prng = Prng(run_seed(race_seed, bot, 0))
        self.finished = False

    def step(self):
        assert not self.finished, 'no step after the finish'
        b = self.board
        assert not b.won(), 'a run is never won before a move'
        legal = b.legal()
        if b.moves >= self.cap or not any(not pointless(b, mv) for mv in legal):
            self.run += 1
            self.board = Board(self.level)
            self.prng = Prng(run_seed(self.seed, self.bot, self.run))
            return (RESTARTED, 0, 0)
        mv = (casual if self.bot == 0 else smart)(b, legal, self.prng)
        b.apply(mv[0], mv[1])
        if b.won():
            self.finished = True
            return (FINISHED, mv[0], mv[1])
        return (MOVED, mv[0], mv[1])


def race(level, bot, race_seed, max_steps, cap=250):
    """The rival's steps until it finishes or has taken max_steps steps."""
    rival = Rival(level, bot, race_seed, cap)
    words, restarts = [], 0
    while len(words) < max_steps and not rival.finished:
        code, f, t = rival.step()
        if code == RESTARTED:
            restarts += 1
        words.append(code << 16 | f << 8 | t)
    return {
        'digest': hash64_hex(b''.join(w.to_bytes(4, 'little') for w in words)),
        'steps': len(words),
        'restarts': restarts,
        'finished': rival.finished,
        'runMoves': rival.board.moves,
    }


def load_race_boards(path):
    """The {name: json} map of the `json:` entries of race_vectors.dart:
    each is a name, then adjacent single-quoted literals after `'json':`."""
    text = open(path, encoding='utf-8').read()
    body = text[text.index('raceGoldens'):]
    boards = {}
    for m in re.finditer(r"'(race-\d+-\d+@\d+)':\s*\{(.*?)\n  \},", body, re.S):
        literal = re.search(r"'json':\s*((?:'[^']*'\s*)+),", m.group(2))
        boards[m.group(1)] = ''.join(re.findall(r"'([^']*)'", literal.group(1)))
    return boards


BOARDS = ['spec', 'hard2', 'expertOnly']
SEEDS = [3100001, 3200001, 3300001]
STEPS = 600
BOTS = ((0, 'casual'), (1, 'smart'))

if __name__ == '__main__':
    here = os.path.dirname(os.path.abspath(__file__))
    levels = load_levels(os.path.join(here, '..', 'support', 'sim_levels.dart'))
    out = {'runSeeds': {}, 'steps': {}, 'dead': {}, 'capped': {}, 'races': {}}
    for seed in SEEDS + [0, (1 << 53) - 1]:
        out['runSeeds'][str(seed)] = {
            name: [run_seed(seed, bot, run) for run in (0, 1, 2, 0xFFFFFFFF)]
            for bot, name in BOTS
        }
    for name in BOARDS:
        lv = Level(levels[name])
        out['steps'][name] = {
            str(seed): {bname: race(lv, bot, seed, STEPS) for bot, bname in BOTS}
            for seed in SEEDS
        }
    # Every run dies on a dead board: restarts that never finish.
    no_space = Level(levels['noSpace'])
    out['dead'] = {bname: race(no_space, bot, SEEDS[0], STEPS) for bot, bname in BOTS}
    # A cap of 5 moves: restarts at the cap.
    expert = Level(levels['expertOnly'])
    out['capped'] = {bname: race(expert, bot, SEEDS[2], STEPS, cap=5)
                     for bot, bname in BOTS}
    vectors = os.path.join(here, '..', '..', 'parity', 'vectors', 'race_vectors.dart')
    if os.path.exists(vectors):
        for key, src in load_race_boards(vectors).items():
            rival, race_no = map(int, re.match(r'race-(\d+)-(\d+)@', key).groups())
            bot = 0 if rival == 1 else 1
            seed = 3000000 + rival * 100000 + race_no
            out['races'][key] = race(Level(src), bot, seed, 100000)
    print(json.dumps(out, indent=2))
