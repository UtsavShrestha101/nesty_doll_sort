import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/generator/fake_level_generator_service.dart';
import 'package:nesty_game/core/services/generator/isolate_level_generator_service.dart';

void main() {
  test('generates the same level, tier and flags as the fake (synchronous) '
      'implementation, off the UI isolate', () async {
    final params = DifficultyCurve.bonusParams(1000001);
    final isolate = IsolateLevelGeneratorService();
    final fake = FakeLevelGeneratorService();

    final fromIsolate = await isolate.generate(params);
    final fromFake = await fake.generate(params);

    expect(fromIsolate, isNotNull);
    expect(fromIsolate!.level, fromFake!.level);
    expect(fromIsolate.tier, fromFake.tier);
    expect(fromIsolate.tierMatched, fromFake.tierMatched);
    expect(fromIsolate.expertOnly, fromFake.expertOnly);
    isolate.dispose();
    fake.dispose();
  });

  test('a daily puzzle generates identically to the fake, across two '
      'separate isolate runs (spec §7.5: two devices agree)', () async {
    final params = DifficultyCurve.dailyParams(20260926);
    final isolate = IsolateLevelGeneratorService();

    final first = await isolate.generate(params);
    final second = await isolate.generate(params);

    expect(first, isNotNull);
    expect(second, isNotNull);
    expect(LevelCodec.encode(first!.level), LevelCodec.encode(second!.level));
    expect(first.tier, second.tier);
    isolate.dispose();
  });

  test(
    'params the generator can never solve resolve to null, never throws',
    () async {
      final isolate = IsolateLevelGeneratorService();
      // shelves × slotsPerShelf way over the doll count: unsolvable.
      const impossible = GeneratorParams(
        colors: 1,
        maxSize: 3,
        shelves: 1,
        slotsPerShelf: 1,
        emptySlots: 1,
        towers: 0,
        locked: 5,
        iceSlots: 5,
        targetTier: Tier.easy,
        seed: 1,
      );

      expect(await isolate.generate(impossible), isNull);
      isolate.dispose();
    },
  );

  test('dispose stops answering new requests', () async {
    final isolate = IsolateLevelGeneratorService()..dispose();
    final params = DifficultyCurve.bonusParams(1000001);

    expect(await isolate.generate(params), isNull);
  });
}
