// Self-test of the parity harness (parity.dart): it must refuse values that
// print or compare differently between the VM and the web, so a parity case
// can't pass on one platform for a reason that doesn't hold on another.
@Tags(['parity'])
library;

import 'package:test/test.dart';

import 'parity.dart';

void main() {
  group('checkParityValue', () {
    test('accepts JSON-shaped values with web-exact ints', () {
      for (final value in <Object?>[
        null,
        true,
        'text',
        0,
        -1,
        maxParityInt,
        -maxParityInt,
        [1, 'two', null],
        {
          'a': [
            {'b': 2},
          ],
        },
      ]) {
        expect(
          () => checkParityValue(value),
          returnsNormally,
          reason: '$value',
        );
      }
    });

    test('refuses fractional doubles', () {
      expect(() => checkParityValue(1.5), throwsA(isA<ParityValueError>()));
      expect(
        () => checkParityValue({
          'rate': [0.25],
        }),
        throwsA(
          isA<ParityValueError>().having((e) => e.path, 'path', r'$.rate[0]'),
        ),
      );
    });

    test('refuses integral doubles where they are distinct from ints', () {
      // On the web 1.0 is the int 1, so only the VM and wasm can tell
      // them apart; there the harness must refuse it.
      expect(
        () => checkParityValue(1.0),
        parityOnJsNumbers ? returnsNormally : throwsA(isA<ParityValueError>()),
      );
    });

    test('refuses ints beyond 2^53 − 1', () {
      expect(
        () => checkParityValue(maxParityInt + 1),
        throwsA(isA<ParityValueError>()),
      );
    });

    test('refuses sets, non-String keys and other objects', () {
      expect(() => checkParityValue({1, 2}), throwsA(isA<ParityValueError>()));
      expect(
        () => checkParityValue({1: 'one'}),
        throwsA(isA<ParityValueError>()),
      );
      expect(
        () => checkParityValue(Duration.zero),
        throwsA(isA<ParityValueError>()),
      );
    });
  });

  test('parityJson sorts keys at every level', () {
    expect(
      parityJson({
        'b': 1,
        'a': [
          {'z': 0, 'y': null},
        ],
      }),
      '{"a":[{"y":null,"z":0}],"b":1}',
    );
  });

  test('parityPlatform names the number model', () {
    expect(parityPlatform, parityOnJsNumbers ? contains('JS') : contains('64'));
  });
}
