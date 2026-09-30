import 'dart:io';
import 'dart:ui' as ui;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/repository/fixture_levels.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/audio/fake_audio_service.dart';
import 'package:nesty_game/core/services/database/fake_database_service.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/fake_skin_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fake_fx_library.dart';
import 'package:nesty_game/features/fx/fx_id.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/splash/cubit/splash_cubit.dart';

class _MockSaveService extends Mock implements SaveService {}

/// Reports its load in quarters, like `AssetFxLibrary` does per file.
final class _SteppedFx extends FakeFxLibrary {
  @override
  Future<void> load({void Function(double progress)? onProgress}) async {
    for (final step in [0.25, 0.5, 0.75]) {
      await Future<void>.delayed(Duration.zero);
      onProgress?.call(step);
    }
    await super.load(onProgress: onProgress);
  }
}

/// A library whose load throws (it never should: rule 3 is checked anyway).
final class _BrokenFx implements FxLibrary {
  @override
  Future<void> load({void Function(double progress)? onProgress}) =>
      Future.error(StateError('no lottie'));

  @override
  bool get isLoaded => false;

  @override
  LottieComposition? operator [](FxId id) => null;

  @override
  Set<FxId> get failed => const {};

  @override
  ui.Image? get blank => null;
}

final class _BrokenSkin extends FakeSkinService {
  @override
  Future<void> load() => Future.error(StateError('no skin'));
}

final class _BrokenAudio extends FakeAudioService {
  @override
  Future<void> preload() => Future.error(StateError('no audio'));
}

/// A bundle that can't be read the first time (spec §13.4: the splash
/// offers a retry), then loads.
final class _FlakyLevels extends FakeLevelRepository {
  _FlakyLevels() : super(entries: FixtureLevels.entries());

  int loads = 0;

  @override
  Future<void> load() async {
    if (loads++ == 0) {
      throw const AppException(AppExceptionKind.content, message: 'no bundle');
    }
  }
}

ShowcaseDolls _showcase([SkinService? skins]) =>
    ShowcaseDolls(skins ?? FakeSkinService(), FakeDatabaseService());

SplashCubit _cubit({
  SaveService? save,
  LevelRepository? levels,
  FxLibrary? fx,
  SkinService? skin,
  FakeAudioService? audio,
  ShowcaseDolls? showcase,
}) {
  final skins = skin ?? FakeSkinService();
  return SplashCubit(
    save ?? FakeSaveService(),
    levels ?? FakeLevelRepository(entries: FixtureLevels.entries()),
    fx ?? FakeFxLibrary(),
    skins,
    audio ?? FakeAudioService(),
    showcase ?? _showcase(skins),
  );
}

void main() {
  setUpAll(() {
    // `_MockSaveService`'s `backfillLevelStars(LevelRepository)` (Q120;
    // m7-design P3.6) needs a fallback to be stubbed with `any()`.
    registerFallbackValue(FakeLevelRepository());
  });

  test('loads everything; the loader only grows, then it is ready', () async {
    final fx = _SteppedFx();
    final audio = FakeAudioService();
    final showcase = _showcase();
    final cubit = _cubit(fx: fx, audio: audio, showcase: showcase);
    addTearDown(cubit.close);
    final states = <AsyncValue<SplashState>>[];
    final sub = cubit.stream.listen(states.add);
    addTearDown(sub.cancel);

    await cubit.load();
    await Future<void>.delayed(Duration.zero);

    expect(states.first, isA<AsyncValueLoading<SplashState>>());
    expect(states.first.data?.progress, 0);
    final loading = states.whereType<AsyncValueLoading<SplashState>>();
    final values = [for (final s in loading) s.data!.progress];
    expect(values.length, greaterThan(3), reason: 'reports as it goes');
    for (var i = 1; i < values.length; i++) {
      expect(values[i], greaterThanOrEqualTo(values[i - 1]));
    }
    expect(
      states.last,
      const AsyncValue<SplashState>.data(
        // A fresh `FakeSaveService` has won nothing (E9): `opensFirstLevel`
        // defaults true, same as a real fresh install.
        data: SplashState(progress: 1, levelCount: 3, opensFirstLevel: true),
      ),
    );
    expect(fx.isLoaded, isTrue);
    expect(audio.preloaded, isTrue);
    // Home opens with its shelf dolls already rasterized.
    expect(showcase.current.value, isNotNull);
    showcase.dispose();
  });

  test('a Lottie, skin or audio failure still finishes (rule 3)', () async {
    final skin = _BrokenSkin();
    final cubit = _cubit(fx: _BrokenFx(), skin: skin, audio: _BrokenAudio());
    addTearDown(cubit.close);

    await cubit.load();

    expect(
      cubit.state,
      const AsyncValue<SplashState>.data(
        // A fresh `FakeSaveService` has won nothing (E9): `opensFirstLevel`
        // defaults true, same as a real fresh install.
        data: SplashState(progress: 1, levelCount: 3, opensFirstLevel: true),
      ),
    );
  });

  blocTest<SplashCubit, AsyncValue<SplashState>>(
    'a failed save load surfaces as an error the page can retry',
    build: () {
      final save = _MockSaveService();
      when(save.load).thenThrow(
        const AppException(AppExceptionKind.storage, message: 'corrupt'),
      );
      when(() => save.backfillLevelStars(any())).thenReturn(0);
      return _cubit(save: save);
    },
    act: (cubit) => cubit.load(),
    skip: 1,
    verify: (cubit) => expect(
      cubit.state,
      isA<AsyncValueError<SplashState>>().having(
        (s) => s.exception.kind,
        'kind',
        AppExceptionKind.storage,
      ),
    ),
  );

  group('naming what failed (frames 12.10, 12.11)', () {
    test('a full disk (ENOSPC, errno 28) is a storage failure; anything '
        'else is content', () {
      expect(
        SplashCubit.kindOf(
          const FileSystemException(
            'write failed',
            '/data/save.hive',
            OSError('No space left on device', 28),
          ),
        ),
        AppExceptionKind.storage,
      );
      expect(
        SplashCubit.kindOf(
          const FileSystemException('gone', 'x', OSError('No such file', 2)),
        ),
        AppExceptionKind.content,
      );
      expect(
        SplashCubit.kindOf(StateError('bad bundle')),
        AppExceptionKind.content,
      );
    });

    test('a raw disk-full error thrown by the save load reaches the page as '
        'a storage error', () async {
      final save = _MockSaveService();
      when(save.load).thenThrow(
        const FileSystemException('w', 'p', OSError('No space left', 28)),
      );
      when(() => save.backfillLevelStars(any())).thenReturn(0);
      final cubit = _cubit(save: save);
      addTearDown(cubit.close);
      await cubit.load();
      expect(
        cubit.state,
        isA<AsyncValueError<SplashState>>().having(
          (s) => s.exception.kind,
          'kind',
          AppExceptionKind.storage,
        ),
      );
    });

    test('any other raw error is content, not unknown', () async {
      final save = _MockSaveService();
      when(save.load).thenThrow(StateError('corrupt'));
      when(() => save.backfillLevelStars(any())).thenReturn(0);
      final cubit = _cubit(save: save);
      addTearDown(cubit.close);
      await cubit.load();
      expect(
        cubit.state,
        isA<AsyncValueError<SplashState>>().having(
          (s) => s.exception.kind,
          'kind',
          AppExceptionKind.content,
        ),
      );
    });
  });

  test('an unreadable bundle is a content error; a retry recovers', () async {
    final levels = _FlakyLevels();
    final cubit = _cubit(levels: levels, fx: _SteppedFx());
    addTearDown(cubit.close);

    await cubit.load();
    // Let the optional parts finish: their late progress must not hide
    // the retry.
    await Future<void>.delayed(const Duration(milliseconds: 10));
    expect(
      cubit.state,
      isA<AsyncValueError<SplashState>>().having(
        (s) => s.exception.kind,
        'kind',
        AppExceptionKind.content,
      ),
    );

    await cubit.load();
    expect(
      cubit.state,
      const AsyncValue<SplashState>.data(
        // A fresh `FakeSaveService` has won nothing (E9): `opensFirstLevel`
        // defaults true, same as a real fresh install.
        data: SplashState(progress: 1, levelCount: 3, opensFirstLevel: true),
      ),
    );
    expect(levels.loads, 2);
  });

  test('ShowcaseDolls prepares one tower of the five shelf colours', () {
    final level = ShowcaseDolls.level;
    expect(level.shelves.single.single, isA<TowerSlot>());
    expect({
      for (final nest in level.shelves.single.single.nests) nest.color,
    }, ShowcaseDolls.colors.toSet());
    // Above Home's tallest shelf doll (128 dp), so rasters never upscale.
    expect(ShowcaseDolls.artHeight, greaterThanOrEqualTo(128));
    expect(ShowcaseDolls.geometry.slots, hasLength(1));
  });

  group('opensFirstLevel (E9, spec-prop §10.1; m7-design §13)', () {
    blocTest<SplashCubit, AsyncValue<SplashState>>(
      'is true while no level has been won: a fresh install, or a kill '
      'during L1, both leave highestLevel at 1',
      build: () => _cubit(
        save: FakeSaveService(
          initial: const SaveDocument(currentLevel: 1, highestLevel: 1),
        ),
      ),
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.data?.opensFirstLevel, isTrue),
    );

    blocTest<SplashCubit, AsyncValue<SplashState>>(
      'is false once a level has been won, so Continue after the first '
      'win goes to Home instead of reopening L1',
      build: () => _cubit(
        save: FakeSaveService(
          initial: const SaveDocument(currentLevel: 2, highestLevel: 2),
        ),
      ),
      act: (cubit) => cubit.load(),
      verify: (cubit) => expect(cubit.state.data?.opensFirstLevel, isFalse),
    );
  });

  group('the star backfill (Q120, m7-design P3.6)', () {
    test(
      'runs once the save and the bundle have loaded, silent and idempotent',
      () async {
        final save = FakeSaveService(
          initial: const SaveDocument(currentLevel: 3, highestLevel: 3),
        );
        final cubit = _cubit(
          save: save,
          levels: FakeLevelRepository(entries: FixtureLevels.entries()),
        );
        addTearDown(cubit.close);

        await cubit.load();

        // Orders 1 and 2 are won (below highestLevel 3); no best moves are
        // kept, so each gets 1 star (Q120's default without a best) —
        // nothing shows for it (rule: cosmetic, silent).
        expect(save.document.levelStars, {
          FixtureLevels.entries()[0].level.id: 1,
          FixtureLevels.entries()[1].level.id: 1,
        });
        expect(cubit.state, isA<AsyncValueData<SplashState>>());

        final before = save.document.levelStars;
        await cubit.load();
        expect(save.document.levelStars, before);
      },
    );

    test('never runs when the bundle fails to load', () async {
      final save = FakeSaveService(
        initial: const SaveDocument(currentLevel: 3, highestLevel: 3),
      );
      final cubit = _cubit(save: save, levels: _FlakyLevels());
      addTearDown(cubit.close);

      await cubit.load();
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(save.document.levelStars, isEmpty);
    });
  });
}
