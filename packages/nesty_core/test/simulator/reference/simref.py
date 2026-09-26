"""Independent reference for the Nesty simulator (spec §6.4, design A17).

Written from the documented definitions only, never from the Dart code:
- xoshiro128** 1.1 seeded by splitmix32, Prng.derive and nextInt, as
  documented in packages/nesty_core/lib/src/prng/prng.dart;
- MurmurHash3_x86_32 and Hash64 (lib/src/util/hash64.dart);
- the rules of spec §4 (placement, inside, swallow, towers, locks, ice);
- the bot policies and run scoring documented on BotPlayer
  (lib/src/simulator/bots.dart), and Simulator.defaultSeed.
The smart bot scores every candidate one move ahead, with none of the Dart
shortcuts, so a match also checks those.

It reproduces the expectations of test/parity/simulator_parity_test.dart.
Use it (or another independent implementation) to recompute them after an
intended change, never by copying Dart output. Python 3.9+, no packages:

    python3 packages/nesty_core/test/simulator/reference/simref.py

reads the levels from ../support/sim_levels.dart and prints the results as
JSON. Gold (spec §3.5, v1.1) is not modelled.
"""
import json, re

M32 = 0xFFFFFFFF

def rotl(x, r): return ((x << r) | (x >> (32 - r))) & M32

def fmix32(h):
    h ^= h >> 16; h = (h * 0x85EBCA6B) & M32
    h ^= h >> 13; h = (h * 0xC2B2AE35) & M32
    h ^= h >> 16; return h

def murmur3(data: bytes, seed: int) -> int:
    h = seed; n = len(data); nb = n // 4
    c1, c2 = 0xCC9E2D51, 0x1B873593
    for i in range(nb):
        k = int.from_bytes(data[4*i:4*i+4], 'little')
        k = (k * c1) & M32; k = rotl(k, 15); k = (k * c2) & M32
        h ^= k; h = rotl(h, 13); h = (h * 5 + 0xE6546B64) & M32
    tail = data[nb*4:]; k = 0
    if len(tail) >= 3: k ^= tail[2] << 16
    if len(tail) >= 2: k ^= tail[1] << 8
    if len(tail) >= 1:
        k ^= tail[0]; k = (k * c1) & M32; k = rotl(k, 15); k = (k * c2) & M32; h ^= k
    h ^= n; return fmix32(h)

HI_SEED, LO_SEED = 0x6A09E667, 0xBB67AE85

def hash64_hex(data: bytes) -> str:
    return '%08x%08x' % (murmur3(data, HI_SEED), murmur3(data, LO_SEED))

def utf16le(s: str) -> bytes: return s.encode('utf-16-le')

class SplitMix32:
    def __init__(self, x): self.x = x & M32
    def next(self):
        self.x = (self.x + 0x9E3779B9) & M32
        return fmix32(self.x)

class Prng:
    def __init__(self, seed):
        assert 0 <= seed <= (1 << 53) - 1
        a = SplitMix32(seed % (1 << 32)); b = SplitMix32((seed // (1 << 32)) ^ 0x510E527F)
        a1, a2, a3, a4 = a.next(), a.next(), a.next(), a.next()
        b1, b2, b3 = b.next(), b.next(), b.next()
        self.s = [a1, a2 ^ b1, a3 ^ b2, a4 ^ b3]
    def next_u32(self):
        s = self.s
        result = (rotl((s[1] * 5) & M32, 7) * 9) & M32
        t = (s[1] << 9) & M32
        s[2] ^= s[0]; s[3] ^= s[1]; s[1] ^= s[2]; s[0] ^= s[3]; s[2] ^= t
        s[3] = rotl(s[3], 11)
        return result
    def next_int(self, bound):
        threshold = ((1 << 32) - bound) % bound
        while True:
            r = self.next_u32()
            if r >= threshold: return r % bound

def derive(seed, a, b=0):
    data = b''.join(x.to_bytes(4, 'little') for x in [seed % (1 << 32), seed // (1 << 32), a, b])
    return murmur3(data, 0xA54FF53A)

# ---- Levels and the rules of spec §4 ---------------------------------------
TOKEN = re.compile(r'^([a-z]+)([1-6])$')

def parse_nest(tokens):
    dolls = [TOKEN.match(t).groups() for t in tokens]
    color = dolls[0][0]; outer = int(dolls[0][1])
    return (color, outer, len(dolls))  # (color, outer, length)

def inner(n): return n[1] - n[2] + 1

class Level:
    def __init__(self, src):
        doc = json.loads(src)
        self.doc = doc
        self.max_size = doc['maxSize']
        self.kind, self.cells0, self.ice0, self.unlock = [], [], [], []
        for shelf in doc['shelves']:
            for slot in shelf:
                t = slot['type']
                self.ice0.append(slot.get('ice', 0))
                if t == 'tower':
                    self.kind.append('tower'); self.cells0.append([parse_nest(n) for n in slot['stack']]); self.unlock.append(None)
                else:
                    self.kind.append('locked' if t == 'locked' else 'open')
                    self.cells0.append([] if slot['nest'] is None else [parse_nest(slot['nest'])])
                    self.unlock.append(slot.get('unlockColor'))
        dolls = {}
        for cs in self.cells0:
            for n in cs: dolls[n[0]] = dolls.get(n[0], 0) + n[2]
        self.total_sets = sum((d + self.max_size - 1) // self.max_size for d in dolls.values())
        self.n = len(self.kind)
    def default_seed(self):
        board = {'schemaVersion': self.doc['schemaVersion'], 'maxSize': self.doc['maxSize'], 'shelves': self.doc['shelves']}
        s = json.dumps(board, separators=(',', ':'))
        return murmur3(utf16le(s), LO_SEED)

class Board:
    def __init__(self, level):
        self.L = level
        self.cells = [list(c) for c in level.cells0]
        self.completed = 0
        self.opened = [False] * level.n
        self.moves = 0
    def copy(self):
        b = Board.__new__(Board); b.L = self.L; b.cells = [list(c) for c in self.cells]
        b.completed = self.completed; b.opened = list(self.opened); b.moves = self.moves
        return b
    def ice(self, s): return max(0, self.L.ice0[s] - self.completed)
    def locked(self, s): return self.L.kind[s] == 'locked' and not self.opened[s]
    def is_tower(self, s): return self.L.kind[s] == 'tower' and not self.opened[s]
    def open_like(self, s): return self.L.kind[s] == 'open' or self.opened[s]
    def interactable(self, s): return self.ice(s) == 0 and not self.locked(s)
    def top(self, s): return self.cells[s][-1] if self.cells[s] else None
    def won(self): return self.completed == self.L.total_sets
    def outcome(self, f, t):
        """None if illegal, else (kind, completes); kind in placed/inside/swallow."""
        if f == t: return None
        if not self.interactable(f): return None
        m = self.top(f)
        if m is None: return None
        if not self.interactable(t): return None
        tt = self.top(t)
        if tt is None:
            return ('placed', False) if self.open_like(t) else None
        if tt[0] != m[0]: return None
        ms = self.L.max_size
        if m[1] == inner(tt) - 1: return ('inside', tt[1] == ms and inner(m) == 1)
        if tt[1] == inner(m) - 1: return ('swallow', m[1] == ms and inner(tt) == 1)
        return None
    def legal(self):
        out = []
        for f in range(self.L.n):
            for t in range(self.L.n):
                o = self.outcome(f, t)
                if o: out.append((f, t, o))
        return out
    def apply(self, f, t):
        kind, completes = self.outcome(f, t)
        m = self.cells[f].pop()
        if self.L.kind[f] == 'tower' and not self.opened[f] and not self.cells[f]:
            self.opened[f] = True
        if kind == 'placed':
            self.cells[t].append(m)
        else:
            tt = self.cells[t][-1]
            if kind == 'inside': merged = (tt[0], tt[1], tt[2] + m[2])
            else: merged = (m[0], m[1], tt[2] + m[2])
            self.cells[t][-1] = merged
            if completes:
                self.cells[t].pop(); self.completed += 1
                if self.L.kind[t] == 'tower' and not self.opened[t] and not self.cells[t]:
                    self.opened[t] = True
                for s in range(self.L.n):
                    if self.L.kind[s] == 'locked' and self.L.unlock[s] == merged[0]:
                        self.opened[s] = True
        self.moves += 1

def pointless(board, mv): return mv[2][0] == 'placed' and board.open_like(mv[0])
def is_merge(mv): return mv[2][0] != 'placed'

def choose(prng, n): return 0 if n == 1 else prng.next_int(n)

def casual(board, legal, prng):
    merges = [mv for mv in legal if is_merge(mv)]
    if merges and prng.next_int(100) < 70:
        return merges[choose(prng, len(merges))]
    return legal[choose(prng, len(legal))]

def has_target(b):
    return any(b.open_like(s) and b.interactable(s) and b.top(s) is None for s in range(b.L.n))

def smart_score(board, mv):
    nb = board.copy(); nb.apply(mv[0], mv[1])
    kind, completes = mv[2]
    if completes: rank = 3
    elif kind != 'placed': rank = 2
    else: rank = 1 if has_target(nb) else 0
    if nb.won(): return (1, rank, 0)
    after = nb.legal()
    merges = sum(1 for a in after if is_merge(a))
    alive = any(not pointless(nb, a) for a in after)
    return (1 if alive else 0, rank, merges)

def smart(board, legal, prng):
    cands = [(smart_score(board, mv), mv) for mv in legal if not pointless(board, mv)]
    best = max(s for s, _ in cands)
    ties = [mv for s, mv in cands if s == best]
    return ties[choose(prng, len(ties))]

def play(level, bot, prng, cap=250):
    b = Board(level)
    while True:
        if b.won(): return True, b.moves
        if b.moves >= cap: return False, b.moves
        legal = b.legal()
        if not any(not pointless(b, mv) for mv in legal): return False, b.moves
        mv = (casual if bot == 0 else smart)(b, legal, prng)
        b.apply(mv[0], mv[1])

def simulate(level, seed=None, runs=300):
    seed = level.default_seed() if seed is None else seed
    wins = []; per = []
    for bot in (0, 1):
        w = 0; words = []
        for run in range(runs):
            won, moves = play(level, bot, Prng(derive(seed, bot, run)))
            w += won; words.append(moves * 2 + (1 if won else 0))
        wins.append(w); per.append(hash64_hex(b''.join(x.to_bytes(4, 'little') for x in words)))
    return seed, wins, per

def tier(w, runs):
    p = w * 100
    return 'easy' if p >= 65 * runs else 'medium' if p >= 35 * runs else 'hard' if p >= 12 * runs else 'superhard'

def load_levels(path):
    """The {name: json} map of sim_levels.dart: each entry is a name and
    adjacent single-quoted string literals (the JSON has no single quotes)."""
    text = open(path, encoding='utf-8').read()
    body = text[text.index('simLevelJson'):text.index('};')]
    levels = {}
    for m in re.finditer(r"'(\w+)':\s*((?:'[^']*'\s*)+),", body):
        levels[m.group(1)] = ''.join(re.findall(r"'([^']*)'", m.group(2)))
    return levels


if __name__ == '__main__':
    import os
    here = os.path.dirname(os.path.abspath(__file__))
    levels = load_levels(os.path.join(here, '..', 'support', 'sim_levels.dart'))
    out = {'seeds': {}, 'results': {}, 'digests': {}, 'seeded': {}}
    for name, src in levels.items():
        lv = Level(src)
        seed, (cw, sw), (cd, sd) = simulate(lv)
        out['seeds'][name] = seed
        out['results'][name] = {'seed': seed, 'casual': cw, 'smart': sw,
                                'tier': tier(cw, 300), 'expertOnly': 2 * sw < 300}
        out['digests'][name] = {'casual': cd, 'smart': sd}
    hard2 = Level(levels['hard2'])
    for s in [0, 1, 0xFFFFFFFF, 0x100000000, 20260926, (1 << 53) - 1]:
        seed, (cw, sw), _ = simulate(hard2, seed=s, runs=60)
        out['seeded'][str(s)] = {'seed': seed, 'casual': cw, 'smart': sw,
                                 'tier': tier(cw, 60), 'expertOnly': 2 * sw < 60}
    print(json.dumps(out, indent=2))
