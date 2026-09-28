import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fake_level_resolver.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/services/remote_config/fake_remote_config_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';

/// The scriptable resolver the bloc tests use (docs/plans/m3-design.md
/// §6.2).
void main() {
  final levels = FakeLevelRepository.fixtures();
  final save = FakeSaveService();
  final resolver = FakeLevelResolver(levels, save, FakeRemoteConfigService());

  test('a campaign request is the bundle entry, paid by its tier', () async {
    final play = await resolver.resolve(const PlayRequest.campaign(2));
    final entry = FixtureLevels.entries()[1];
    expect(play?.level, entry.level);
    expect(play?.bundleEntry, entry);
    expect(play?.chapterId, entry.chapterId);
    expect(play?.levelVersion, entry.version);
    expect(play?.rewardCoins, 10);
    expect(await resolver.resolve(const PlayRequest.campaign(99)), isNull);
  });

  test('generated requests come from the script', () async {
    expect(await resolver.resolve(const PlayRequest.bonus(1)), isNull);
    final base = (await resolver.resolve(const PlayRequest.campaign(1)))!;
    final bonus = base.copyWith(request: const PlayRequest.bonus(1));
    resolver.generated[const PlayRequest.bonus(1)] = bonus;
    expect(await resolver.resolve(const PlayRequest.bonus(1)), bonus);
    expect(bonus.tier, Tier.easy);
  });

  test('next and Home follow the published levels into Bonus Endless', () {
    expect(
      resolver.next(const PlayRequest.campaign(1)),
      const PlayRequest.campaign(2),
    );
    expect(
      resolver.next(const PlayRequest.campaign(3)),
      const PlayRequest.bonus(1),
    );
    expect(
      resolver.next(const PlayRequest.bonus(4)),
      const PlayRequest.bonus(5),
    );
    expect(resolver.next(const PlayRequest.daily(20260926)), isNull);
    expect(resolver.homeRequest, const PlayRequest.campaign(1));
    save.currentLevel = 4;
    expect(resolver.homeRequest, const PlayRequest.bonus(1));
  });
}
