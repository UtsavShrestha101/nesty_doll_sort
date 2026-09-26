// The simulator's bots (spec §6.4, design A17).
//
// Spec §6.4: "Casual bot: takes a random merge with 70% chance when one
// exists. Otherwise it makes a random legal move. No undo. Smart bot:
// greedy. It prefers moves that complete a set, then merges, then moves that
// don't fill the last empty slot, with 1-ply lookahead."
// Design A17: legal minus pointless → rank completes > merge > placement
// leaving an empty slot > rest → the lookahead drops moves leading to
// OutOfMoves and prefers the most merges after → PRNG tie-break.
//
// Expected choices are derived from the public rules (Rules, GameState
// views) and the documented draw order, not from the bot code.
import 'dart:typed_data';

import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_core/src/models/game_state.dart';
import 'package:nesty_core/src/rules/engine/board.dart';
import 'package:nesty_core/src/rules/engine/board_layout.dart';
import 'package:nesty_core/src/rules/engine/kernel.dart';
import 'package:nesty_core/src/simulator/bots.dart';
import 'package:test/test.dart';

import '../rules/support/boards.dart';
import 'support/sim_levels.dart';

// Out of play for every lookahead here: ice 9 never thaws in one move.
const _frozen = 9;

/// A player for [state]'s level.
BotPlayer _player(GameState state) => BotPlayer(BoardLayout.of(state.level));

/// What [bot] plays on [state] with [prng], as a move, or null for none.
Move? _choice(BotPlayer player, SimBot bot, GameState state, Prng prng) {
  final entry = player.choose(bot, GameStateBoard.peek(state), prng);
  if (entry < 0) return null;
  final ids = player.layout.ids;
  return Move(ids[LegalMove.from(entry)], ids[LegalMove.to(entry)]);
}

/// The moves [bot] plays on [state] over [seeds], as 'from>to' strings.
Set<String> _choices(SimBot bot, GameState state, {int seeds = 64}) {
  final player = _player(state);
  return {
    for (var seed = 0; seed < seeds; seed++)
      _show(_choice(player, bot, state, Prng(seed))),
  };
}

String _show(Move? move) => move == null ? 'none' : '${move.from}>${move.to}';

/// Spec §4 through the public API: true when [move] merges two nests.
bool _isMerge(GameState state, Move move) =>
    (Rules.tryMove(state, move) as MoveApplied).events.any(
      (event) => event is NestedInto,
    );

/// A lone nest moved from a slot that reads back as open into an empty one
/// (spec §6.3 "pointless").
bool _isPointless(GameState state, Move move) =>
    state.slot(move.from) is OpenSlot &&
    switch (state.slot(move.to)) {
      OpenSlot(nest: null) => true,
      _ => false,
    };

/// Some slot takes a placement now: empty, open and interactable.
bool _hasPlacementTarget(GameState state) => state.slotIds.any(
  (id) =>
      Rules.isInteractable(state, id) &&
      switch (state.slot(id)) {
        OpenSlot(nest: null) => true,
        _ => false,
      },
);

/// Positions reached by random legal play on [level], start included.
List<GameState> _walkPositions(Level level, {int walks = 12, int steps = 40}) {
  final positions = <GameState>[];
  for (var walk = 0; walk < walks; walk++) {
    final prng = Prng(Prng.derive(0xC0FFEE, walk));
    var state = GameState.initial(level);
    for (var step = 0; step < steps && !state.isWon; step++) {
      positions.add(state);
      final legal = Rules.legalMoves(state);
      if (legal.isEmpty) break;
      state = (Rules.tryMove(state, prng.pick(legal)) as MoveApplied).state;
    }
  }
  return positions;
}

/// The smart policy by its definition: score every non-pointless legal
/// move, keep the best, and choose among ties in `Rules.legalMoves` order.
Move? _naiveSmart(BotPlayer player, GameState state, Prng prng) {
  final board = GameStateBoard.peek(state);
  final layout = player.layout;
  var best = -1;
  final ties = <Move>[];
  for (final move in Rules.legalMoves(state)) {
    if (_isPointless(state, move)) continue;
    final score = player.smartScore(
      board,
      layout.indexOf(move.from),
      layout.indexOf(move.to),
    );
    if (score > best) {
      best = score;
      ties
        ..clear()
        ..add(move);
    } else if (score == best) {
      ties.add(move);
    }
  }
  if (ties.isEmpty) return null;
  return ties.length == 1 ? ties.single : ties[prng.nextInt(ties.length)];
}

void main() {
  group('SmartScore', () {
    test('packs and unpacks alive, rank and merges after', () {
      for (final alive in [false, true]) {
        for (var rank = 0; rank <= 3; rank++) {
          for (final merges in [0, 1, 7, 900, 1023]) {
            final score = SmartScore.pack(
              alive: alive,
              rank: rank,
              mergesAfter: merges,
            );
            expect(SmartScore.alive(score), alive);
            expect(SmartScore.rank(score), rank);
            expect(SmartScore.mergesAfter(score), merges);
          }
        }
      }
    });

    test('orders alive first, then rank, then merges after (A17)', () {
      int s(bool alive, int rank, int merges) =>
          SmartScore.pack(alive: alive, rank: rank, mergesAfter: merges);
      expect(s(true, 0, 0), greaterThan(s(false, 3, 1023)));
      expect(s(true, 1, 0), greaterThan(s(true, 0, 1023)));
      expect(s(true, 3, 0), greaterThan(s(true, 2, 1023)));
      expect(s(true, 2, 5), greaterThan(s(true, 2, 4)));
      expect(s(false, 2, 0), greaterThan(s(false, 1, 0)));
    });

    test('rank constants follow spec §6.4', () {
      expect(SmartScore.rankCompletes, 3);
      expect(SmartScore.rankMerge, 2);
      expect(SmartScore.rankKeepsSpace, 1);
      expect(SmartScore.rankFillsLast, 0);
    });

    test('rejects out-of-range parts', () {
      expect(
        () => SmartScore.pack(alive: true, rank: 4, mergesAfter: 0),
        throwsRangeError,
      );
      expect(
        () => SmartScore.pack(alive: true, rank: 0, mergesAfter: 1024),
        throwsRangeError,
      );
    });
  });

  group('smartScore', () {
    test('a winning move is alive, completes and has no merges after', () {
      final state = play(GameState.initial(simLevel('tutorial')), [
        'r0c2>r0c0',
      ]);
      final player = _player(state);
      final board = GameStateBoard.peek(state);
      final layout = player.layout;
      final score = player.smartScore(
        board,
        layout.indexOf('r1c1'),
        layout.indexOf('r0c0'),
      );
      expect(SmartScore.alive(score), isTrue);
      expect(SmartScore.rank(score), SmartScore.rankCompletes);
      expect(SmartScore.mergesAfter(score), 0);
    });

    test('throws for an illegal move and leaves the board alone', () {
      final state = GameState.initial(simLevel('tutorial'));
      final player = _player(state);
      final board = GameStateBoard.peek(state);
      final before = Board.copyOf(board);
      final layout = player.layout;
      expect(
        () => player.smartScore(
          board,
          layout.indexOf('r0c0'),
          layout.indexOf('r1c1'),
        ),
        throwsArgumentError,
      );
      player.smartScore(board, layout.indexOf('r0c2'), layout.indexOf('r0c0'));
      expect(board.sameAs(before), isTrue);
    });

    test('matches its definition on every candidate of many positions', () {
      var checked = 0;
      for (final name in simLevelJson.keys) {
        final level = simLevel(name);
        final player = BotPlayer(BoardLayout.of(level));
        final layout = player.layout;
        for (final state in _walkPositions(level, walks: 4, steps: 30)) {
          final board = GameStateBoard.peek(state);
          for (final move in Rules.legalMoves(state)) {
            if (_isPointless(state, move)) continue;
            final applied = Rules.tryMove(state, move) as MoveApplied;
            final after = applied.state;
            final merge = applied.events.any((e) => e is NestedInto);
            final rank = applied.completedSet
                ? SmartScore.rankCompletes
                : merge
                ? SmartScore.rankMerge
                : _hasPlacementTarget(after)
                ? SmartScore.rankKeepsSpace
                : SmartScore.rankFillsLast;
            final afterMoves = Rules.legalMoves(after);
            final merges = after.isWon
                ? 0
                : afterMoves.where((m) => _isMerge(after, m)).length;
            final alive =
                after.isWon || afterMoves.any((m) => !_isPointless(after, m));
            final score = player.smartScore(
              board,
              layout.indexOf(move.from),
              layout.indexOf(move.to),
            );
            final reason = '$name ${_show(move)} on $state';
            expect(SmartScore.rank(score), rank, reason: reason);
            expect(SmartScore.alive(score), alive, reason: reason);
            expect(SmartScore.mergesAfter(score), merges, reason: reason);
            checked++;
          }
        }
      }
      expect(checked, greaterThan(1000));
    });
  });

  group('isPointless (spec §6.3)', () {
    test(
      'agrees with the slot views on every legal move of many positions',
      () {
        for (final name in simLevelJson.keys) {
          final level = simLevel(name);
          final layout = BoardLayout.of(level);
          final buffer = Int32List(Kernel.legalMoveCapacity(layout));
          for (final state in _walkPositions(level, walks: 4, steps: 30)) {
            final board = GameStateBoard.peek(state);
            final count = Kernel.collectLegalMoves(board, buffer);
            for (var i = 0; i < count; i++) {
              final move = Move(
                layout.ids[LegalMove.from(buffer[i])],
                layout.ids[LegalMove.to(buffer[i])],
              );
              expect(
                BotPlayer.isPointless(board, buffer[i]),
                _isPointless(state, move),
                reason: '$name ${_show(move)}',
              );
            }
          }
        }
      },
    );
  });

  group('smart bot on crafted boards', () {
    test('prefers completing a set over another merge', () {
      final state = GameState.initial(
        board(3, [
          [open('red3 red2'), open('red1'), open('blue3')],
          [open('blue2'), open('blue1', _frozen)],
        ]),
      );
      // Both completions leave the same board, so the PRNG picks either.
      expect(_choices(SimBot.smart, state), {'r0c0>r0c1', 'r0c1>r0c0'});
    });

    test('prefers a merge over a placement', () {
      final state = GameState.initial(
        board(4, [
          [
            tower(['green4', 'blue1']),
            open(),
            open('red4'),
          ],
          [
            open('red3'),
            open('green3 green2 green1', _frozen),
            open('blue4 blue3 blue2', _frozen),
            open('red2 red1', _frozen),
          ],
        ]),
      );
      expect(Rules.legalMoves(state), contains(mv('r0c0>r0c1')));
      expect(_choices(SimBot.smart, state), {'r0c2>r1c0', 'r1c0>r0c2'});
    });

    test('prefers a placement that keeps an empty slot, even with fewer '
        'merges after', () {
      final state = GameState.initial(
        board(3, [
          [
            tower(['red2', 'blue1']),
            tower(['yellow1']),
            open(),
          ],
          [
            open('red3'),
            open('red1', _frozen),
            open('blue3 blue2', _frozen),
            open('yellow3 yellow2', _frozen),
          ],
        ]),
      );
      final player = _player(state);
      final packed = GameStateBoard.peek(state);
      final layout = player.layout;
      final fills = player.smartScore(
        packed,
        layout.indexOf('r0c0'),
        layout.indexOf('r0c2'),
      );
      final keeps = player.smartScore(
        packed,
        layout.indexOf('r0c1'),
        layout.indexOf('r0c2'),
      );
      expect(SmartScore.rank(fills), SmartScore.rankFillsLast);
      expect(SmartScore.mergesAfter(fills), 2);
      expect(SmartScore.rank(keeps), SmartScore.rankKeepsSpace);
      expect(SmartScore.mergesAfter(keeps), 0);
      expect(_choices(SimBot.smart, state), {'r0c1>r0c2'});
    });

    test('drops a move into a board with only pointless moves (lookahead)', () {
      final state = GameState.initial(
        board(4, [
          [
            tower(['red3']),
            open('red4'),
            open(),
          ],
          [
            open('blue4'),
            open('blue1'),
            open('red2 red1', _frozen),
            open('blue3 blue2', _frozen),
          ],
        ]),
      );
      final player = _player(state);
      final packed = GameStateBoard.peek(state);
      final layout = player.layout;
      int score(String move) => player.smartScore(
        packed,
        layout.indexOf(mv(move).from),
        layout.indexOf(mv(move).to),
      );
      // red3 into red4 empties the tower and leaves only pointless moves;
      // red4 swallowing red3 keeps the tower, whose top can still move.
      // Same rank and merges after: only the lookahead tells them apart.
      final dead = score('r0c0>r0c1');
      final alive = score('r0c1>r0c0');
      expect(SmartScore.alive(dead), isFalse);
      expect(SmartScore.alive(alive), isTrue);
      expect(SmartScore.rank(dead), SmartScore.rank(alive));
      expect(SmartScore.mergesAfter(dead), SmartScore.mergesAfter(alive));
      expect(_choices(SimBot.smart, state), {'r0c1>r0c0'});
    });

    test('drops a move that leads to OutOfMoves (spec §2.3)', () {
      // One empty slot. blue1 from the tower fills it and leaves no move;
      // yellow1 from the other tower empties it, leaving room to move on.
      final state = GameState.initial(
        board(3, [
          [
            tower(['red3', 'blue1']),
            tower(['yellow1']),
            open(),
          ],
          [
            open('red1', _frozen),
            open('red2', _frozen),
            open('blue3 blue2', _frozen),
            open('yellow3 yellow2', _frozen),
          ],
        ]),
      );
      final player = _player(state);
      final layout = player.layout;
      final fills = player.smartScore(
        GameStateBoard.peek(state),
        layout.indexOf('r0c0'),
        layout.indexOf('r0c2'),
      );
      expect(SmartScore.alive(fills), isFalse);
      final after = apply(state, 'r0c0>r0c2').state;
      expect(Rules.isOutOfMoves(after), isTrue);
      expect(_choices(SimBot.smart, state), {'r0c1>r0c2'});
    });

    test('prefers the move with the most merges after', () {
      final state = GameState.initial(
        board(4, [
          [
            tower(['blue3', 'red2']),
            open('red3'),
            open('blue4'),
          ],
          [open('green4'), open('green3'), open('red4', _frozen)],
          [
            open('red1', _frozen),
            open('blue2 blue1', _frozen),
            open('green2 green1', _frozen),
          ],
        ]),
      );
      // red2 into red3 reveals blue3, which merges with blue4.
      expect(_choices(SimBot.smart, state), {'r0c0>r0c1'});
    });

    test('never plays a pointless move', () {
      final state = GameState.initial(
        board(3, [
          [open('red3'), open('blue3'), open()],
          [
            tower(['green3', 'yellow1']),
            open('red2 red1', _frozen),
            open('blue2 blue1', _frozen),
            open('yellow3 yellow2', _frozen),
          ],
          [open('green2 green1', _frozen)],
        ]),
      );
      expect(
        Rules.legalMoves(state).where((m) => _isPointless(state, m)),
        isNotEmpty,
      );
      expect(_choices(SimBot.smart, state), {'r1c0>r0c2'});
    });

    test('has no move when every legal move is pointless', () {
      final state = GameState.initial(
        board(3, [
          [open('red3'), open('blue3'), open()],
          [open('red2 red1', _frozen), open('blue2 blue1', _frozen)],
        ]),
      );
      expect(Rules.legalMoves(state), isNotEmpty);
      expect(_choices(SimBot.smart, state), {'none'});
      // The casual bot still moves, pointlessly.
      final casual = _choices(SimBot.casual, state);
      expect(casual, isNot(contains('none')));
      for (final move in casual) {
        expect(_isPointless(state, mv(move)), isTrue);
      }
    });

    test('chooses among tied moves with the PRNG, in legal-move order', () {
      final state = GameState.initial(simLevel('tutorial'));
      final merges = [
        for (final move in Rules.legalMoves(state))
          if (_isMerge(state, move)) move,
      ];
      expect(merges.map(_show), [
        'r0c0>r0c2',
        'r0c2>r0c0',
        'r0c2>r1c1',
        'r1c1>r0c2',
      ]);
      final player = _player(state);
      for (var seed = 0; seed < 200; seed++) {
        expect(
          _choice(player, SimBot.smart, state, Prng(seed)),
          merges[Prng(seed).nextInt(merges.length)],
          reason: 'seed $seed',
        );
      }
      expect(_choices(SimBot.smart, state), merges.map(_show).toSet());
    });

    test('a single best move draws nothing from the PRNG', () {
      final state = GameState.initial(
        board(3, [
          [open('red3'), open('blue3'), open()],
          [
            tower(['green3', 'yellow1']),
            open('red2 red1', _frozen),
            open('blue2 blue1', _frozen),
            open('yellow3 yellow2', _frozen),
          ],
          [open('green2 green1', _frozen)],
        ]),
      );
      final prng = Prng(42);
      _choice(_player(state), SimBot.smart, state, prng);
      expect(prng.nextU32(), Prng(42).nextU32());
    });

    test('scoring shortcuts choose exactly like scoring every move', () {
      var positions = 0;
      for (final name in simLevelJson.keys) {
        final level = simLevel(name);
        final player = BotPlayer(BoardLayout.of(level));
        for (final state in _walkPositions(level)) {
          for (final seed in [1, 2]) {
            final fast = Prng(seed);
            final naive = Prng(seed);
            expect(
              _choice(player, SimBot.smart, state, fast),
              _naiveSmart(player, state, naive),
              reason: '$name seed $seed on $state',
            );
            expect(fast.nextU32(), naive.nextU32(), reason: 'same draws');
          }
          positions++;
        }
      }
      expect(positions, greaterThan(2000));
    });
  });

  group('casual bot', () {
    test('follows the documented draws: nextInt(100) < 70 → a merge', () {
      final state = GameState.initial(simLevel('tutorial'));
      final legal = Rules.legalMoves(state);
      final merges = [
        for (final move in legal)
          if (_isMerge(state, move)) move,
      ];
      expect(merges, hasLength(4));
      expect(legal, hasLength(13));
      final player = _player(state);
      for (var seed = 0; seed < 500; seed++) {
        final draws = Prng(seed);
        final expected = draws.nextInt(100) < BotPlayer.casualMergePercent
            ? merges[draws.nextInt(merges.length)]
            : legal[draws.nextInt(legal.length)];
        final prng = Prng(seed);
        expect(
          _choice(player, SimBot.casual, state, prng),
          expected,
          reason: 'seed $seed',
        );
        expect(prng.nextU32(), draws.nextU32(), reason: 'same draws');
      }
    });

    test('merges about 70% + 30%·(merges/legal) of the time', () {
      final state = GameState.initial(simLevel('tutorial'));
      final player = _player(state);
      var merged = 0;
      for (var seed = 0; seed < 2000; seed++) {
        final move = _choice(player, SimBot.casual, state, Prng(seed))!;
        if (_isMerge(state, move)) merged++;
      }
      // 0.7 + 0.3 × 4/13 ≈ 0.79.
      expect(merged / 2000, closeTo(0.79, 0.04));
    });

    test('without a merge, plays a uniform legal move with no 70% draw', () {
      final state = GameState.initial(
        board(3, [
          [open('red3'), open('blue3'), open()],
          [
            tower(['green3', 'yellow1']),
            open('red2 red1', _frozen),
            open('blue2 blue1', _frozen),
            open('yellow3 yellow2', _frozen),
          ],
          [open('green2 green1', _frozen)],
        ]),
      );
      final legal = Rules.legalMoves(state);
      expect(legal.where((m) => _isMerge(state, m)), isEmpty);
      final player = _player(state);
      for (var seed = 0; seed < 200; seed++) {
        final draws = Prng(seed);
        final prng = Prng(seed);
        expect(
          _choice(player, SimBot.casual, state, prng),
          legal[draws.nextInt(legal.length)],
        );
        expect(prng.nextU32(), draws.nextU32());
      }
    });

    test('a single legal move draws nothing', () {
      final state = GameState.initial(
        board(3, [
          [open('red3'), open()],
          [open('red2 red1', _frozen)],
        ]),
      );
      expect(Rules.legalMoves(state), [mv('r0c0>r0c1')]);
      final prng = Prng(7);
      expect(
        _choice(_player(state), SimBot.casual, state, prng),
        mv('r0c0>r0c1'),
      );
      expect(prng.nextU32(), Prng(7).nextU32());
    });
  });

  group('both bots', () {
    test('have no move when there is no legal move (OutOfMoves)', () {
      final state = GameState.initial(
        board(3, [
          [open('red3'), open('blue3')],
          [open('red2 red1', _frozen), open('blue2 blue1', _frozen)],
        ]),
      );
      expect(Rules.isOutOfMoves(state), isTrue);
      for (final bot in SimBot.values) {
        expect(_choices(bot, state, seeds: 4), {'none'});
      }
    });

    test('only ever choose legal moves', () {
      for (final name in simLevelJson.keys) {
        final level = simLevel(name);
        final player = BotPlayer(BoardLayout.of(level));
        for (final state in _walkPositions(level, walks: 3, steps: 30)) {
          for (final bot in SimBot.values) {
            final move = _choice(player, bot, state, Prng(3));
            if (move == null) continue;
            expect(Rules.tryMove(state, move), isA<MoveApplied>());
          }
        }
      }
    });

    test('choose leaves the board alone and rejects another layout', () {
      final state = GameState.initial(simLevel('spec'));
      final packed = GameStateBoard.peek(state);
      final before = Board.copyOf(packed);
      final player = _player(state);
      for (final bot in SimBot.values) {
        player.choose(bot, packed, Prng(0));
      }
      expect(packed.sameAs(before), isTrue);
      final other = GameStateBoard.peek(GameState.initial(simLevel('spec')));
      expect(
        () => player.choose(SimBot.smart, other, Prng(0)),
        throwsArgumentError,
      );
    });
  });

  group('play', () {
    test('replays through Rules: wins end in Won, losses are stuck or '
        'capped, and no run uses an extra slot', () {
      for (final name in simLevelJson.keys) {
        final level = simLevel(name);
        final player = BotPlayer(BoardLayout.of(level));
        final ids = player.layout.ids;
        final seed = Simulator.defaultSeed(level);
        for (final bot in SimBot.values) {
          for (var run = 0; run < 25; run++) {
            final moves = <Move>[];
            final won = player.play(
              bot,
              Prng(Prng.derive(seed, bot.index, run)),
              SimulatorParams.defaultMoveCap,
              (from, to) => moves.add(Move(ids[from], ids[to])),
            );
            var state = GameState.initial(level);
            MoveApplied? last;
            for (final move in moves) {
              expect(move.from, isNot(startsWith('x')));
              expect(move.to, isNot(startsWith('x')));
              last = Rules.tryMove(state, move) as MoveApplied;
              state = last.state;
            }
            final reason = '$name ${bot.name} run $run';
            expect(state.isWon, won, reason: reason);
            expect(state.extraSlotCount, 0, reason: reason);
            if (won) {
              expect(last!.events.last, isA<Won>(), reason: reason);
            } else {
              expect(
                moves.length == SimulatorParams.defaultMoveCap ||
                    Rules.legalMoves(
                      state,
                    ).every((m) => _isPointless(state, m)),
                isTrue,
                reason: reason,
              );
            }
          }
        }
      }
    });

    test('a board with only pointless moves loses at once', () {
      final level = board(3, [
        [open('red3'), open('blue3'), open()],
        [open('red2 red1', _frozen), open('blue2 blue1', _frozen)],
      ]);
      final player = BotPlayer(BoardLayout.of(level));
      for (final bot in SimBot.values) {
        var moves = 0;
        expect(player.play(bot, Prng(0), 250, (_, _) => moves++), isFalse);
        expect(moves, 0);
      }
    });

    test('each run starts from the level start', () {
      final level = simLevel('spec');
      final player = BotPlayer(BoardLayout.of(level));
      final first = <int>[];
      final again = <int>[];
      player.play(SimBot.casual, Prng(5), 250, (f, t) => first.add(f << 8 | t));
      player.play(SimBot.smart, Prng(6), 250);
      player.play(SimBot.casual, Prng(5), 250, (f, t) => again.add(f << 8 | t));
      expect(again, first);
    });
  });
}
