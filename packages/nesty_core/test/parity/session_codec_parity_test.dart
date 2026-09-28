// VM/web parity for GameSessionCodec (docs/plans/m3-design.md §4, spec
// §13.3, D11). The game saves the in-progress level on the VM, and the
// same core runs in the web admin, so a saved session must read the same
// everywhere: the same board, the same re-derived events and, for a bad
// save, the same issues in the same order. The inputs are JSON strings, so
// each platform parses them with its own decoder: on the web `jsonDecode`
// wraps `JSON.parse`, whose objects list integer-like keys first.
@Tags(['parity'])
library;

import 'dart:convert';

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'parity.dart';
import 'vectors/session_vectors.dart';

final Level _level = LevelCodec.decodeString(specExampleLevelJson).level!;

// Stray keys (integer-like ones too) in the root, a board and a history
// entry; two bad tokens; an empty `before`; the slots out of order.
const String _badSession =
    '{"format":1,"9":0,"levelId":"L0042","undosUsed":0,"zz":1,'
    '"state":{"moves":0,"sets":0,"extra":0,"opened":[],"2":true,"slots":{'
    '"r1c2":[["blue1"]],"r0c0":[["red4","Red3"]],"r0c1":[],'
    '"r0c2":[["blue2"],["green4"],["red2","red1"]],'
    '"r1c0":[["green3","green2","green1"]],"r1c1":[["blue4","blue9"]]},'
    '"a":0},"history":[{"move":["r0c0","r0c1"],"10":[],"before":{}}],"1":2}';

String _event(MoveEvent event) => switch (event) {
  Picked(:final slotId, :final nest, :final fromTower, :final leftEmptyTower) =>
    'Picked $slotId $nest tower:$fromTower emptied:$leftEmptyTower',
  Placed(:final fromId, :final slotId, :final nest) =>
    'Placed $fromId>$slotId $nest',
  NestedInto(:final fromId, :final slotId, :final direction, :final merged) =>
    'NestedInto $fromId>$slotId ${direction.name} $merged',
  Revealed(:final slotId, :final nest, :final hiddenBelow) =>
    'Revealed $slotId $nest below:$hiddenBelow',
  _ => 'other',
};

void main() {
  parityTest(
    'hand-written sessions read back and encode byte for byte',
    () => {
      for (final (name, json) in [
        ('start', startJson),
        ('after A8', afterA8Json),
        ('after restart', afterRestartJson),
        ('after B3', afterB3Json),
        ('won', wonJson),
      ])
        name: switch (GameSessionCodec.decode(jsonDecode(json), _level)) {
          GameSessionDecodeResult(:final session?) => jsonEncode(
            GameSessionCodec.encode(session),
          ),
          final result => '${result.issues}',
        },
    },
    expected: {
      'start': startJson,
      'after A8': afterA8Json,
      'after restart': afterRestartJson,
      'after B3': afterB3Json,
      'won': wonJson,
    },
  );

  parityTest(
    'the history\'s events are re-derived alike (spec §4 event order)',
    () {
      final session = GameSessionCodec.decode(
        jsonDecode(afterA8Json),
        _level,
      ).session!;
      return [
        for (final entry in session.history)
          [for (final event in entry.events) _event(event)],
      ];
    },
    expected: [
      [
        'Picked r0c2 [green4] tower:true emptied:false',
        'Placed r0c2>r0c0 [green4]',
        'Revealed r0c2 [blue2] below:0',
      ],
      [
        'Picked r0c1 [blue1] tower:false emptied:false',
        'Placed r0c1>x1 [blue1]',
      ],
    ],
  );

  parityTest(
    'a bad session gives the same issues in the same order',
    () => [
      for (final issue in GameSessionCodec.decode(
        jsonDecode(_badSession),
        _level,
      ).issues)
        {
          'code': issue.code,
          'path': issue.path,
          'slotId': issue.slotId,
          'args': issue.args,
        },
    ],
    expected: [
      {
        'code': 'doll.badToken',
        'path': '/state/slots/r0c0/0/1',
        'slotId': 'r0c0',
        'args': {'token': 'Red3'},
      },
      {
        'code': 'doll.badToken',
        'path': '/state/slots/r1c1/0/1',
        'slotId': 'r1c1',
        'args': {'token': 'blue9'},
      },
      for (final field in ['2', 'a'])
        {
          'code': 'schema.unknownField',
          'path': '/state/$field',
          'slotId': null,
          'args': {'field': field},
        },
      for (final field in ['moves', 'sets', 'extra', 'opened', 'slots'])
        {
          'code': 'schema.missingField',
          'path': '/history/0/before',
          'slotId': null,
          'args': {'field': field},
        },
      {
        'code': 'schema.unknownField',
        'path': '/history/0/10',
        'slotId': null,
        'args': {'field': '10'},
      },
      for (final field in ['1', '9', 'zz'])
        {
          'code': 'schema.unknownField',
          'path': '/$field',
          'slotId': null,
          'args': {'field': field},
        },
    ],
  );
}
