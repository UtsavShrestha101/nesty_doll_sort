"""Independent reference for the star rating (spec-prop §7.10, D125).

Written from the rule text only, never from the Dart code:
  "3 stars: moves <= par + ceil(par x star3_slack_pct / 100) (20).
   2 stars: moves <= par + ceil(par x star2_slack_pct / 100) (60). Any other
   win earns 1 star." "A win that used a hint, or has an extra slot on the
   board, earns at most 2 stars."
The ceiling is Python's exact integer -(-a // b), not the Dart
(a + 99) ~/ 100, so a match also checks that rewrite.

It reproduces the expectations of test/parity/star_rating_parity_test.dart.
Use it (or another independent implementation) to recompute them after an
intended change, never by copying Dart output. Python 3.9+, no packages:

    python3 packages/nesty_core/test/rules/reference/starref.py

Each value is one u32 word, and a case's digest is Hash64 of its words,
little-endian (simref.py's hash64_hex, as the Dart `parityDigestU32s`).
"""
import json, os, sys

sys.dont_write_bytecode = True  # no __pycache__ in the source tree
sys.path.insert(
    0,
    os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', '..',
                 'simulator', 'reference'))
from simref import hash64_hex  # noqa: E402

PARS = range(1, 61)
SLACKS = (0, 20, 60, 100, 1000)
MOVES = range(0, 121)


def threshold(par, slack):
    return par + -(-(par * slack) // 100)


def stars(moves, par, assisted, s3, s2):
    if moves <= threshold(par, s3):
        n = 3
    elif moves <= threshold(par, s2):
        n = 2
    else:
        n = 1
    return min(n, 2) if assisted else n


def digest(words):
    return hash64_hex(b''.join(w.to_bytes(4, 'little') for w in words))


def main():
    thresholds = [threshold(p, s) for p in PARS for s in SLACKS]
    words = []
    counts = [0, 0, 0]
    for p in PARS:
        for s3 in SLACKS:
            for s2 in SLACKS:
                for m in MOVES:
                    for assisted in (False, True):
                        n = stars(m, p, assisted, s3, s2)
                        words.append(n)
                        counts[n - 1] += 1
    large = [
        threshold(9007199254740, 1000),
        threshold(1 << 31, 20),
        threshold((1 << 32) + 1, 60),
        threshold((1 << 40) - 1, 100),
        threshold(9007199254740, 1),
    ]
    print(json.dumps({
        'thresholds': {'digest': digest(thresholds), 'count': len(thresholds),
                       'sum': sum(thresholds)},
        'stars': {'digest': digest(words), 'count': len(words),
                  'counts': counts},
        'large': large,
    }, indent=2))


if __name__ == '__main__':
    main()
