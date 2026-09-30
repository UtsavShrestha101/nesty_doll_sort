// VM/web parity for the star rating (spec-prop §7.10, D125; m7-design
// P3.3). The game rates a win on the phone and the admin will show stars in
// the browser (M5), so `StarRating` must give the same answer on the VM, in
// dart2js (JS numbers) and in wasm. The rule is pure integer arithmetic
// (`par + (par × slack + 99) ~/ 100`), and these cases pin it:
//
// - every threshold over par 1–60 × slack {0, 20, 60, 100, 1000};
// - every `starsFor` over par 1–60 × star3 × star2 slack in that set ×
//   moves 0–120 × assisted (363,000 values), as one digest;
// - large pars, where `par × slack` nears 2^53 (the web's exact limit);
// - `starsForWin` on the L1 tutorial board.
//
// The expected values come from an independent Python reference written
// from the rule text (test/rules/reference/starref.py), never from this
// package: rerun it after an intended change.
@Tags(['parity'])
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'parity.dart';

const List<int> _slacks = [0, 20, 60, 100, 1000];

void main() {
  parityTest(
    'thresholds over par 1–60 × slack {0, 20, 60, 100, 1000}',
    () {
      final words = [
        for (var par = 1; par <= 60; par++)
          for (final slack in _slacks) StarRating.threshold(par, slack),
      ];
      return {
        'digest': parityDigestU32s(words),
        'count': words.length,
        'sum': words.fold<int>(0, (a, b) => a + b),
      };
    },
    expected: {'digest': 'f2e68832d11b0f92', 'count': 300, 'sum': 30792},
  );

  parityTest(
    'starsFor over par 1–60 × star3 × star2 slack × moves 0–120 × assisted',
    () {
      final words = <int>[];
      final counts = [0, 0, 0];
      for (var par = 1; par <= 60; par++) {
        for (final star3 in _slacks) {
          for (final star2 in _slacks) {
            for (var moves = 0; moves <= 120; moves++) {
              for (final assisted in const [false, true]) {
                final stars = StarRating.starsFor(
                  moves: moves,
                  par: par,
                  assisted: assisted,
                  star3SlackPct: star3,
                  star2SlackPct: star2,
                );
                words.add(stars);
                counts[stars - 1]++;
              }
            }
          }
        }
      }
      return {
        'digest': parityDigestU32s(words),
        'count': words.length,
        'counts': counts,
      };
    },
    expected: {
      'digest': '6a47ec2a10635065',
      'count': 363000,
      'counts': [143370, 131795, 87835],
    },
  );

  parityTest(
    // Literals, not shifts: dart2js shifts in 32 bits.
    'large pars stay exact on JS numbers',
    () => [
      StarRating.threshold(9007199254740, StarRating.maxSlackPct),
      StarRating.threshold(2147483648, 20),
      StarRating.threshold(4294967297, 60),
      StarRating.threshold(1099511627775, 100),
      StarRating.threshold(9007199254740, 1),
    ],
    expected: [
      99079191802140,
      2576980378,
      6871947676,
      2199023255550,
      9097271247288,
    ],
  );

  parityTest('starsForWin on the L1 tutorial board', () {
    // L1 (design TUT1), par 2, won in 2 moves.
    Level l1() => Level(
      id: 'L1',
      maxSize: 3,
      shelves: [
        [
          OpenSlot(nest: Nest.tryFromDolls(const [Doll(DollColor.red, 3)])),
          OpenSlot(),
          OpenSlot(nest: Nest.tryFromDolls(const [Doll(DollColor.red, 2)])),
        ],
        [
          OpenSlot(),
          OpenSlot(nest: Nest.tryFromDolls(const [Doll(DollColor.red, 1)])),
          OpenSlot(),
        ],
      ],
    );
    int rate(GameSession session, {bool hint = false, int slack = 20}) =>
        StarRating.starsForWin(
          session.state,
          par: 2,
          hintUsed: hint,
          star3SlackPct: slack,
          star2SlackPct: slack,
        );
    GameSession won({bool extra = false, bool detour = false}) {
      final session = GameSession(l1());
      if (extra) session.addExtraSlot();
      if (detour) {
        session
          ..move('r1c1', 'r1c0')
          ..move('r0c2', 'r0c0')
          ..move('r1c0', 'r0c0');
      } else {
        session
          ..move('r0c2', 'r0c0')
          ..move('r1c1', 'r0c0');
      }
      return session;
    }

    return [
      rate(won()),
      rate(won(), hint: true),
      rate(won(extra: true)),
      rate(won(detour: true), slack: 0),
      rate(won(detour: true)),
    ];
  }, expected: [3, 2, 2, 1, 3]);
}
