import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/symbols_mode.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_render/nesty_render.dart';

import '../support/controlled_skin_service.dart';

/// The splash and Home shelf dolls' art (frames 1.1, 2.1), through the one
/// door to the skin's part rasters (m2-lottie-design §4).
void main() {
  late ControlledSkinService skins;
  late FakeDatabaseService database;
  late ShowcaseDolls showcase;

  setUp(() {
    skins = ControlledSkinService();
    database = FakeDatabaseService();
    showcase = ShowcaseDolls(skins, database);
  });

  test('one board holding every shelf colour, prepared tall enough', () {
    final colors = <DollColor>{
      for (final shelf in ShowcaseDolls.level.shelves)
        for (final slot in shelf)
          for (final nest in slot.nests) nest.color,
    };
    expect(colors, ShowcaseDolls.colors.toSet());
    // Home's tallest shelf doll is 128 dp: never upscaled.
    expect(ShowcaseDolls.artHeight, greaterThanOrEqualTo(128));
  });

  test('prepares once per pixel ratio in the player\'s symbols mode', () async {
    await database.setSymbolsMode(SymbolsMode.large);
    final first = showcase.prepare(devicePixelRatio: 2);
    final again = showcase.prepare(devicePixelRatio: 2);
    expect(
      skins.showcaseRequests,
      hasLength(1),
      reason: 'the request in flight',
    );
    expect(skins.showcaseRequests.single.devicePixelRatio, 2);
    expect(skins.showcaseRequests.single.symbols, DollSymbols.large);
    final skin = skins.completeShowcase(0);
    await Future.wait([first, again]);
    expect(showcase.current.value, skin);

    await showcase.prepare(devicePixelRatio: 2);
    expect(skins.showcaseRequests, hasLength(1), reason: 'already here');
  });

  // D91: Settings opens over Home, which keeps this art.
  test('a Color symbols change prepares the shelf again at the same pixel '
      'ratio, and the old art stays up until the new lands', () async {
    final first = showcase.prepare(devicePixelRatio: 3);
    final large = skins.completeShowcase(0);
    await first;
    expect(skins.showcaseRequests.single.symbols, DollSymbols.large);

    await database.setSymbolsMode(SymbolsMode.subtle);
    await pumpEventQueue();
    expect(skins.showcaseRequests, hasLength(2));
    expect(skins.showcaseRequests.last.symbols, DollSymbols.subtle);
    expect(skins.showcaseRequests.last.devicePixelRatio, 3);
    expect(showcase.current.value, same(large), reason: 'no placeholder');

    final subtle = skins.completeShowcase(1);
    await pumpEventQueue();
    expect(showcase.current.value, same(subtle));
    expect(large.disposed, isTrue);

    // The same mode again, or Home asking once more, prepares nothing.
    await database.setSymbolsMode(SymbolsMode.subtle);
    await showcase.prepare(devicePixelRatio: 3);
    await pumpEventQueue();
    expect(skins.showcaseRequests, hasLength(2));
  });

  test('a Color symbols change supersedes a prepare in flight', () async {
    final first = showcase.prepare(devicePixelRatio: 2);
    await database.setSymbolsMode(SymbolsMode.subtle);
    await pumpEventQueue();
    expect(skins.showcaseRequests, hasLength(2));

    final stale = skins.completeShowcase(0);
    await first;
    expect(stale.disposed, isTrue);
    expect(showcase.current.value, isNull);

    final fresh = skins.completeShowcase(1);
    await pumpEventQueue();
    expect(showcase.current.value, same(fresh));
  });

  test('a Color symbols change before the first prepare, after release or '
      'after dispose prepares nothing', () async {
    await database.setSymbolsMode(SymbolsMode.subtle);
    await pumpEventQueue();
    expect(skins.showcaseRequests, isEmpty);

    final first = showcase.prepare(devicePixelRatio: 1);
    expect(skins.showcaseRequests.single.symbols, DollSymbols.subtle);
    skins.completeShowcase(0);
    await first;
    showcase.release();
    await database.setSymbolsMode(SymbolsMode.large);
    await pumpEventQueue();
    expect(skins.showcaseRequests, hasLength(1));

    showcase.dispose();
    await database.setSymbolsMode(SymbolsMode.subtle);
    await pumpEventQueue();
    expect(skins.showcaseRequests, hasLength(1));
  });

  test('release frees the rasters; prepare brings them back', () async {
    final first = showcase.prepare(devicePixelRatio: 1);
    final a = skins.completeShowcase(0);
    await first;
    showcase.release();
    expect(showcase.current.value, isNull);
    expect(a.disposed, isTrue);

    final second = showcase.prepare(devicePixelRatio: 1);
    final b = skins.completeShowcase(1);
    await second;
    expect(showcase.current.value, b);
  });

  test('a result released before it lands is disposed unseen', () async {
    final first = showcase.prepare(devicePixelRatio: 1);
    showcase.release();
    final a = skins.completeShowcase(0);
    await first;
    expect(a.disposed, isTrue);
    expect(showcase.current.value, isNull);
  });

  test('a failure leaves the placeholder shelves and can retry', () async {
    final first = showcase.prepare(devicePixelRatio: 1);
    skins.failShowcase(0);
    await first;
    expect(showcase.current.value, isNull);

    final retry = showcase.prepare(devicePixelRatio: 1);
    final b = skins.completeShowcase(1);
    await retry;
    expect(showcase.current.value, b);
  });

  test('dispose frees everything and stops preparing', () async {
    final first = showcase.prepare(devicePixelRatio: 1);
    final a = skins.completeShowcase(0);
    await first;
    showcase.dispose();
    expect(a.disposed, isTrue);
    await showcase.prepare(devicePixelRatio: 1);
    expect(skins.showcaseRequests, hasLength(1));
  });
}
