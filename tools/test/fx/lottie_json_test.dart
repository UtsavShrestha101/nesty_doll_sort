import 'package:nesty_tools/src/fx/lottie_contract.dart';
import 'package:nesty_tools/src/fx/lottie_json.dart';
import 'package:test/test.dart';

Map<String, Object?> _position(List<Map<String, Object?>> keyframes) => {
  'a': 1,
  'k': keyframes,
};

void main() {
  group('lottieHolds (lottie skips a position callback there)', () {
    test('a hold keyframe (h: 1) holds, and adjacent holds merge', () {
      expect(
        lottieHolds(
          _position([
            {
              't': 0,
              's': [1, 2, 0],
              'h': 1,
            },
            {
              't': 5,
              's': [1, 2, 0],
            },
            {
              't': 9,
              's': [1, 2, 0],
            },
            {
              't': 12,
              's': [4, 2, 0],
            },
            {
              't': 20,
              's': [6, 2, 0],
            },
          ]),
        ),
        // 0–5 (h: 1) and 5–9 (equal values) merge; 9 → 12 moves.
        const [LottieHold(0, 9, LottiePoint(1, 2))],
      );
    });

    test('an old-style end value (e) decides, and the tail never holds', () {
      expect(
        lottieHolds(
          _position([
            {
              't': 0,
              's': [1, 2, 0],
              'e': [1, 2, 0],
            },
            {
              't': 5,
              's': [9, 2, 0],
              'e': [3, 2, 0],
            },
            {'t': 9},
          ]),
        ),
        const [LottieHold(0, 5, LottiePoint(1, 2))],
      );
    });

    test('a moving or static property has none', () {
      expect(
        lottieHolds(
          _position([
            {
              't': 42,
              's': [100, 650, 0],
            },
            {
              't': 75,
              's': [195, 144, 0],
            },
          ]),
        ),
        isEmpty,
      );
      expect(
        lottieHolds({
          'a': 0,
          'k': [0, 0, 0],
        }),
        isEmpty,
      );
      expect(lottieHolds(null), isEmpty);
    });
  });

  test('lottiePoint reads the first two numbers, else null', () {
    expect(lottiePoint([3, 4, 0]), const LottiePoint(3, 4));
    expect(lottiePoint([3]), isNull);
    expect(lottiePoint(['x', 4]), isNull);
    expect(lottiePoint(null), isNull);
  });
}
