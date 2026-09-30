// Spec-prop §7.10 (D125; docs/plans/star-rating.md "Rules"; m7-design P3.3):
// the star rating's thresholds, the three bands and the assisted cap.
//
// The rule text implemented here (spec-prop §7.10, the spec until Q85):
//   "Every win of a campaign level (§7.1), first play or replay, earns 1, 2
//    or 3 stars. 3 is the most."
//   "**Moves** are the winning attempt's moves as the game counts them: undo
//    takes a move back, and restart starts again from 0 (§2.4)."
//   "**3 stars:** moves ≤ par + ⌈par × `star3_slack_pct` ÷ 100⌉ (20).
//    **2 stars:** moves ≤ par + ⌈par × `star2_slack_pct` ÷ 100⌉ (60). Any
//    other win earns **1 star**. For par 12: 3 stars at 15 moves or fewer,
//    2 stars at 20 or fewer."
//   "A win that used a hint, or has an extra slot on the board, earns at
//    most 2 stars, so stars can't be bought. Undo, restart and relaxed mode
//    never lower stars."
// star-rating.md's table: par 8 → 10 / 13, 12 → 15 / 20, 20 → 24 / 32,
// 30 → 36 / 48. Q116 (default): a hint since the last restart, or an extra
// slot on the board at the win, caps the win.
//
// Every expected number below is worked by hand from those lines
// (t = par + ⌈par × slack ÷ 100⌉), never read off the implementation.
// Platform-neutral: no dart:io, so it also runs on node and chrome.
import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'support/boards.dart';

void main() {
  group('StarRating.threshold (par + ⌈par × slack ÷ 100⌉)', () {
    test("star-rating.md's table at the default slack 20 / 60", () {
      for (final (par, three, two) in const [
        (8, 10, 13),
        (12, 15, 20),
        (20, 24, 32),
        (30, 36, 48),
      ]) {
        expect(StarRating.threshold(par, 20), three, reason: 'par $par');
        expect(StarRating.threshold(par, 60), two, reason: 'par $par');
      }
    });

    test('par 1, 8, 12, 20, 30 and 60 at 0 %, 20 %, 60 % and 100 %', () {
      // (par, t at 0 %, 20 %, 60 %, 100 %), by hand:
      // par 1: 1 + ⌈0⌉, 1 + ⌈0.2⌉, 1 + ⌈0.6⌉, 1 + ⌈1⌉.
      // par 8: 8 + ⌈1.6⌉ = 10, 8 + ⌈4.8⌉ = 13, 8 + 8.
      // par 60: 60 + 12, 60 + 36, 60 + 60.
      for (final (par, at0, at20, at60, at100) in const [
        (1, 1, 2, 2, 2),
        (8, 8, 10, 13, 16),
        (12, 12, 15, 20, 24),
        (20, 20, 24, 32, 40),
        (30, 30, 36, 48, 60),
        (60, 60, 72, 96, 120),
      ]) {
        expect(StarRating.threshold(par, 0), at0, reason: 'par $par at 0 %');
        expect(StarRating.threshold(par, 20), at20, reason: 'par $par at 20');
        expect(StarRating.threshold(par, 60), at60, reason: 'par $par at 60');
        expect(StarRating.threshold(par, 100), at100, reason: 'par $par 100');
      }
    });

    test('rounds up, and 0 % is par itself', () {
      expect(StarRating.threshold(1, 20), 2);
      expect(StarRating.threshold(1, 0), 1);
      expect(StarRating.threshold(12, 100), 24);
      expect(StarRating.threshold(7, StarRating.maxSlackPct), 77);
    });

    test('⌈⌉ adds nothing on an exact multiple and 1 just past one', () {
      expect(StarRating.threshold(20, 20), 24, reason: '20 × 0.2 = 4 exactly');
      expect(StarRating.threshold(99, 1), 100, reason: '⌈0.99⌉ = 1');
      expect(StarRating.threshold(100, 1), 101, reason: '⌈1⌉ = 1');
      expect(StarRating.threshold(101, 1), 103, reason: '⌈1.01⌉ = 2');
    });

    test('exact for large pars up to the technical bound', () {
      // 9 007 199 254 740 × 1000 + 99 < 2^53, so it is exact on the web
      // too (test/parity/star_rating_parity_test.dart repeats it there).
      expect(
        StarRating.threshold(9007199254740, StarRating.maxSlackPct),
        99079191802140,
      );
      expect(StarRating.threshold(2147483648, 20), 2576980378);
    });

    test('rejects a par below 1 and a slack outside 0..maxSlackPct', () {
      expect(() => StarRating.threshold(0, 20), throwsRangeError);
      expect(() => StarRating.threshold(-5, 20), throwsRangeError);
      expect(() => StarRating.threshold(8, -1), throwsRangeError);
      expect(
        () => StarRating.threshold(8, StarRating.maxSlackPct + 1),
        throwsRangeError,
      );
      expect(StarRating.threshold(8, StarRating.maxSlackPct), 88);
    });
  });

  group('StarRating.starsFor', () {
    int stars(
      int moves, {
      int par = 12,
      bool assisted = false,
      int s3 = 20,
      int s2 = 60,
    }) => StarRating.starsFor(
      moves: moves,
      par: par,
      assisted: assisted,
      star3SlackPct: s3,
      star2SlackPct: s2,
    );

    test('the bands at par 12: 3★ ≤ 15, 2★ ≤ 20, else 1★', () {
      expect(stars(12), 3);
      expect(stars(15), 3);
      expect(stars(16), 2);
      expect(stars(20), 2);
      expect(stars(21), 1);
      expect(stars(400), StarRating.minStars);
    });

    test('at t3, t3 + 1, t2 and t2 + 1 for par 8, 12, 20, 30 and 60', () {
      // (par, t3, t2) at 20 / 60, from the threshold table above.
      for (final (par, t3, t2) in const [
        (8, 10, 13),
        (12, 15, 20),
        (20, 24, 32),
        (30, 36, 48),
        (60, 72, 96),
      ]) {
        expect(stars(t3, par: par), 3, reason: 'par $par at t3');
        expect(stars(t3 + 1, par: par), 2, reason: 'par $par at t3 + 1');
        expect(stars(t2, par: par), 2, reason: 'par $par at t2');
        expect(stars(t2 + 1, par: par), 1, reason: 'par $par at t2 + 1');
        expect(stars(par, par: par), 3, reason: 'par $par at par');
      }
    });

    test('par 1 at 20 / 60: t3 = t2 = 2, so 2★ is out of reach', () {
      // ⌈0.2⌉ = ⌈0.6⌉ = 1: both thresholds are 2 moves.
      expect(stars(1, par: 1), 3);
      expect(stars(2, par: 1), 3);
      expect(stars(3, par: 1), 1);
    });

    test('at 0 %: only par itself earns 3★', () {
      for (final par in const [1, 8, 12, 20, 30, 60]) {
        expect(stars(par, par: par, s3: 0, s2: 0), 3, reason: 'par $par');
        expect(stars(par + 1, par: par, s3: 0, s2: 0), 1, reason: 'par $par');
        // 3★ at par, 2★ up to twice par (100 %).
        expect(stars(par + 1, par: par, s3: 0, s2: 100), 2, reason: '$par');
        expect(stars(2 * par, par: par, s3: 0, s2: 100), 2, reason: '$par');
        expect(stars(2 * par + 1, par: par, s3: 0, s2: 100), 1, reason: '$par');
      }
    });

    test('at 100 %: 3★ up to twice par', () {
      for (final par in const [1, 8, 12, 20, 30, 60]) {
        expect(stars(2 * par, par: par, s3: 100, s2: 100), 3, reason: '$par');
        expect(
          stars(2 * par + 1, par: par, s3: 100, s2: 100),
          1,
          reason: 'par $par',
        );
      }
    });

    test('fewer moves than par still earn 3★ (the rule is literal)', () {
      // Only an extra slot can beat par, and it caps the win anyway.
      expect(stars(0), 3);
      expect(stars(11), 3);
      expect(stars(11, assisted: true), 2);
    });

    test('an assisted win earns at most 2★; 2★ and 1★ are unchanged', () {
      expect(stars(12, assisted: true), StarRating.assistedMaxStars);
      expect(stars(15, assisted: true), 2);
      expect(stars(16, assisted: true), 2);
      expect(stars(18, assisted: true), 2);
      expect(stars(20, assisted: true), 2);
      expect(stars(21, assisted: true), 1);
      for (final par in const [1, 8, 12, 20, 30, 60]) {
        expect(stars(par, par: par, assisted: true), 2, reason: 'par $par');
        expect(stars(10 * par, par: par, assisted: true), 1, reason: '$par');
      }
    });

    test('literal: a star2 slack below star3 only makes 2★ unreachable', () {
      expect(stars(15, s3: 20, s2: 10), 3);
      expect(stars(16, s3: 20, s2: 10), 1);
      expect(stars(16, s3: 20, s2: 10, assisted: true), 1);
      expect(stars(15, s3: 20, s2: 10, assisted: true), 2);
    });

    test('never outside 1..3', () {
      for (var moves = 0; moves <= 100; moves++) {
        for (final assisted in const [false, true]) {
          final value = stars(moves, par: 8, assisted: assisted);
          expect(value, inInclusiveRange(1, 3), reason: '$moves');
        }
      }
    });

    test('rejects negative moves, a par below 1 and either slack out of '
        'range', () {
      expect(() => stars(-1), throwsRangeError);
      expect(() => stars(5, par: 0), throwsRangeError);
      expect(() => stars(5, s3: -1), throwsRangeError);
      expect(() => stars(5, s2: StarRating.maxSlackPct + 1), throwsRangeError);
    });
  });

  group('StarRating.starsForWin', () {
    // Tutorial board L1 (design TUT1), par 2: red2 into red3, then red1
    // into [red3, red2].
    Level l1() => board(3, [
      [open('red3'), open(), open('red2')],
      [open(), open('red1'), open()],
    ]);

    int starsOf(
      GameState state, {
      bool hintUsed = false,
      int par = 2,
      int s3 = 20,
      int s2 = 60,
    }) => StarRating.starsForWin(
      state,
      par: par,
      hintUsed: hintUsed,
      star3SlackPct: s3,
      star2SlackPct: s2,
    );

    void winL1(GameSession session) => session
      ..move('r0c2', 'r0c0')
      ..move('r1c1', 'r0c0');

    test('reads the move count, the hint and the extra slots', () {
      final won = play(GameState.initial(l1()), ['r0c2>r0c0', 'r1c1>r0c0']);
      expect(starsOf(won), 3);
      expect(starsOf(won, hintUsed: true), 2);

      final session = GameSession(l1())..addExtraSlot();
      winL1(session);
      expect(session.state.isWon, isTrue);
      expect(session.state.extraSlotCount, 1);
      expect(starsOf(session.state), 2);
    });

    test('the moves are the board\'s moveCount: a detour counts', () {
      // At 0 % both thresholds are par (2), so the detour's third move
      // drops the win to 1★.
      final detour = play(GameState.initial(l1()), [
        'r1c1>r1c0',
        'r0c2>r0c0',
        'r1c0>r0c0',
      ]);
      expect(detour.moveCount, 3);
      expect(starsOf(detour, s3: 0, s2: 0), 1);
      expect(starsOf(detour), 3, reason: 't3 at par 2 and 20 % is 3');
    });

    test('undo takes a move back, so it never lowers stars (§2.4)', () {
      final session = GameSession(l1())..move('r1c1', 'r1c0');
      expect(session.state.moveCount, 1);
      session.undo();
      expect(session.state.moveCount, 0);
      winL1(session);
      expect(session.state.moveCount, 2);
      expect(starsOf(session.state, s3: 0, s2: 0), 3);
    });

    test('restart starts again from 0, so earlier moves never count', () {
      final session = GameSession(l1())
        ..move('r1c1', 'r1c0')
        ..move('r0c2', 'r1c2')
        ..restart();
      expect(session.state.moveCount, 0);
      winL1(session);
      expect(starsOf(session.state, s3: 0, s2: 0), 3);
    });

    test('an extra slot survives restart (D22), so the win still caps', () {
      final session = GameSession(l1())
        ..addExtraSlot()
        ..restart();
      winL1(session);
      expect(session.state.extraSlotCount, 1);
      expect(starsOf(session.state), 2);
      expect(starsOf(session.state, s3: 0, s2: 0), 2);
    });

    test('an assisted 2★ or 1★ win keeps its stars', () {
      final detour = play(GameState.initial(l1()), [
        'r1c1>r1c0',
        'r0c2>r0c0',
        'r1c0>r0c0',
      ]);
      // At 0 / 50: t3 = 2, t2 = 3, so the 3-move detour is 2★ either way.
      expect(starsOf(detour, s3: 0, s2: 50), 2);
      expect(starsOf(detour, s3: 0, s2: 50, hintUsed: true), 2);
      expect(starsOf(detour, s3: 0, s2: 0, hintUsed: true), 1);
    });

    test('rejects a board that is not won', () {
      expect(
        () => starsOf(GameState.initial(l1())),
        throwsA(isA<ArgumentError>()),
      );
      final halfway = play(GameState.initial(l1()), ['r0c2>r0c0']);
      expect(() => starsOf(halfway), throwsA(isA<ArgumentError>()));
    });

    test('passes on starsFor\'s range errors', () {
      final won = play(GameState.initial(l1()), ['r0c2>r0c0', 'r1c1>r0c0']);
      expect(() => starsOf(won, par: 0), throwsRangeError);
      expect(() => starsOf(won, s3: -1), throwsRangeError);
      expect(
        () => starsOf(won, s2: StarRating.maxSlackPct + 1),
        throwsRangeError,
      );
    });
  });
}
