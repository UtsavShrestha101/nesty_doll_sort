import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/repository/fake_level_repository.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/features/splash/cubit/splash_cubit.dart';

class _MockSaveService extends Mock implements SaveService {}

void main() {
  blocTest<SplashCubit, AsyncValue<SplashState>>(
    'loads save and levels, then reports ready',
    build: () =>
        SplashCubit(FakeSaveService(), FakeLevelRepository()..levelCount = 30),
    act: (cubit) => cubit.load(),
    expect: () => const [
      AsyncValue<SplashState>.loading(),
      AsyncValue<SplashState>.data(data: SplashState(levelCount: 30)),
    ],
  );

  blocTest<SplashCubit, AsyncValue<SplashState>>(
    'a failed save load surfaces as an error the page can retry',
    build: () {
      final save = _MockSaveService();
      when(save.load).thenThrow(
        const AppException(AppExceptionKind.storage, message: 'corrupt'),
      );
      return SplashCubit(save, FakeLevelRepository());
    },
    act: (cubit) => cubit.load(),
    expect: () => [
      const AsyncValue<SplashState>.loading(),
      isA<AsyncValueError<SplashState>>().having(
        (s) => s.exception.kind,
        'kind',
        AppExceptionKind.storage,
      ),
    ],
  );
}
