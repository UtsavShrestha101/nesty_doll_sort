import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'home_cubit.freezed.dart';
part 'home_state.dart';

/// Home screen state (spec §10.2 #2).
///
/// TODO(M2): coins, the tier badge of the current level, and refresh when
/// returning from a won level. TODO(M3): Daily/Museum/Remove Ads tiles.
@injectable
class HomeCubit extends BaseAsyncCubit<HomeState> {
  HomeCubit(this._save);

  final SaveService _save;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async => HomeState(currentLevel: _save.currentLevel));
  }
}
