// VM/web parity for the level and bundle codecs (spec §5.1, §5.3, design
// §5). The admin (dart2js or wasm) and the game and level tools (VM) must
// report the same issues in the same order for the same file. The inputs
// are JSON strings, so each platform parses them with its own decoder: on
// the web `jsonDecode` wraps `JSON.parse`, whose objects list integer-like
// keys first, and whose error text differs from the VM's.
@Tags(['parity'])
library;

import 'package:nesty_core/nesty_core.dart';
import 'package:test/test.dart';

import 'parity.dart';

// Stray keys, numeric ones included, at the top level and in a slot.
const String _strayKeys =
    '{"schemaVersion":1,"id":"P","zeta":1,"10":2,"maxSize":3,'
    '"shelves":[[{"type":"open","b":1,"7":2,"nest":["red3"],"a":3},'
    '{"type":"open","nest":["red2","red1"]}],'
    '[{"type":"open","nest":null},{"type":"open","nest":null}]],"2":3}';

// The same stray keys in a bundle and in one of its entries.
const String _strayBundleKeys =
    '{"format":"nesty.levels","bundleVersion":1,"levelsVersion":0,'
    '"z":0,"3":0,"levels":[{"order":1,"chapterId":"ch01","tier":"easy",'
    '"version":1,"rewardCoins":10,"9":1,"note":"x","data":'
    '{"schemaVersion":1,"id":"P","maxSize":3,"shelves":'
    '[[{"type":"open","nest":["red3"]},{"type":"open","nest":["red2","red1"]}]]}'
    '}],"1":0}';

List<Map<String, Object?>> _issues(List<LevelIssue> issues) => [
  for (final issue in issues)
    {
      'code': issue.code,
      'path': issue.path,
      'slotId': issue.slotId,
      'args': issue.args,
    },
];

void main() {
  parityTest(
    'unknown level keys come back sorted, whatever the parser order',
    () => _issues(LevelCodec.decodeString(_strayKeys).issues),
    expected: [
      {
        'code': 'schema.unknownField',
        'path': '/shelves/0/0/7',
        'slotId': 'r0c0',
        'args': {'field': '7'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/shelves/0/0/a',
        'slotId': 'r0c0',
        'args': {'field': 'a'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/shelves/0/0/b',
        'slotId': 'r0c0',
        'args': {'field': 'b'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/10',
        'slotId': null,
        'args': {'field': '10'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/2',
        'slotId': null,
        'args': {'field': '2'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/zeta',
        'slotId': null,
        'args': {'field': 'zeta'},
      },
    ],
  );

  parityTest(
    'unknown bundle and entry keys come back sorted',
    () => _issues(LevelBundleCodec.decodeString(_strayBundleKeys).issues),
    expected: [
      {
        'code': 'schema.unknownField',
        'path': '/levels/0/9',
        'slotId': null,
        'args': {'field': '9'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/levels/0/note',
        'slotId': null,
        'args': {'field': 'note'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/1',
        'slotId': null,
        'args': {'field': '1'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/3',
        'slotId': null,
        'args': {'field': '3'},
      },
      {
        'code': 'schema.unknownField',
        'path': '/z',
        'slotId': null,
        'args': {'field': 'z'},
      },
    ],
  );

  // The parser's own message differs by platform, so only the code and the
  // (empty) args are part of the result.
  parityTest(
    'malformed JSON gives the same issue on every platform',
    () => [
      for (final source in ['{"schemaVersion": 1,', '{"a" 1}', '[', ''])
        for (final issue in [
          ...LevelCodec.decodeString(source).issues,
          ...LevelBundleCodec.decodeString(source).issues,
        ])
          {'code': issue.code, 'path': issue.path, 'args': issue.args},
    ],
    expected: [
      for (var i = 0; i < 8; i++)
        {'code': 'schema.invalidJson', 'path': '', 'args': <String, Object?>{}},
    ],
  );
}
