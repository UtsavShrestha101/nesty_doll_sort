import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/services/generator/fake_level_generator_service.dart';

/// The synchronous generator (docs/plans/m3-design.md §6.3): the same
/// deterministic output as nesty_core, with the retries.
void main() {
  test('generates bonus level 1 as core does, deterministically', () async {
    final service = FakeLevelGeneratorService();
    final params = DifficultyCurve.bonusParams(1);
    final first = await service.generate(params);
    final again = await service.generate(params);
    final direct = Generator.generateWithRetries(params) as GeneratorSuccess;
    expect(first, isNotNull);
    expect(first, again);
    expect(first!.level, direct.level);
    expect(first.tier, direct.simulation.tier);
    expect(service.calls, 2);
  });

  test('params core rejects give null, never a throw', () async {
    const params = GeneratorParams(
      colors: 0,
      maxSize: 4,
      shelves: 3,
      slotsPerShelf: 3,
      emptySlots: 1,
      targetTier: Tier.easy,
      seed: 1,
    );
    expect(await FakeLevelGeneratorService().generate(params), isNull);
  });
}
