import 'package:flutter_test/flutter_test.dart';
import 'package:nesty_game/core/flavor/flavor.dart';
import 'package:nesty_game/core/services/clock/fake_clock.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/clock/system_clock.dart';

/// The injected clock (docs/plans/m3-design.md §8.1).
void main() {
  group('SystemClock', () {
    test('NESTY_FAKE_DATE works only in dev debug builds, for a real date', () {
      expect(
        SystemClock.parseFakeDate('20260926', debug: true, flavor: Flavor.dev),
        LocalDate(2026, 9, 26),
      );
      for (final (define, debug, flavor) in [
        ('20260926', false, Flavor.dev),
        ('20260926', true, Flavor.stg),
        ('20260926', true, Flavor.prod),
        ('20260926', true, null),
        ('', true, Flavor.dev),
        ('20260230', true, Flavor.dev),
        ('2026-09-26', true, Flavor.dev),
      ]) {
        expect(
          SystemClock.parseFakeDate(define, debug: debug, flavor: flavor),
          isNull,
          reason: '$define $debug $flavor',
        );
      }
    });

    test('a fake date replaces the date and keeps the time of day', () {
      final clock = SystemClock(fakeDate: LocalDate(2030, 1, 2));
      expect(clock.today(), LocalDate(2030, 1, 2));
      final now = clock.now();
      expect((now.year, now.month, now.day), (2030, 1, 2));
    });

    test('without one it is the device date', () {
      final clock = SystemClock(fakeDate: null);
      expect(clock.today(), LocalDate.fromDateTime(DateTime.now()));
    });
  });

  test('FakeClock starts on the design daily frames\' Saturday and moves', () {
    final clock = FakeClock();
    expect(clock.today(), LocalDate(2026, 9, 26));
    clock.advance(const Duration(hours: 13));
    expect(clock.today(), LocalDate(2026, 9, 27));
    clock.setDate(LocalDate(2026, 10, 5));
    expect(clock.now(), DateTime(2026, 10, 5, 12));
  });
}
