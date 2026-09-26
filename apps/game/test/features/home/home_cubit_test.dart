import 'package:bloc_test/bloc_test.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/services/save/fake_save_service.dart';
import 'package:nesty_game/features/home/cubit/home_cubit.dart';

void main() {
  blocTest<HomeCubit, AsyncValue<HomeState>>(
    'reads the current level from the save',
    build: () => HomeCubit(FakeSaveService()..currentLevel = 24),
    act: (cubit) => cubit.load(),
    expect: () => const [
      AsyncValue<HomeState>.loading(),
      AsyncValue<HomeState>.data(data: HomeState(currentLevel: 24)),
    ],
  );
}
