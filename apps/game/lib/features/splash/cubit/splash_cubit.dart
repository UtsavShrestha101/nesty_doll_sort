import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/save/save_service.dart';

part 'splash_cubit.freezed.dart';
part 'splash_state.dart';

/// Loads everything the game needs offline before Home (spec §10.2 #1):
/// the save and the bundled levels.
///
/// TODO(M2): also load and rasterize the bundled Classic skin (spec §13.5).
/// TODO(M4): kick off level sync and Remote Config refresh in the background
/// here — unawaited, so the splash never waits on the network (rule 3).
/// TODO(M6): first-launch consent (UMP) sits between splash and Home (§10.1).
@injectable
class SplashCubit extends BaseAsyncCubit<SplashState> {
  SplashCubit(this._save, this._levels);

  final SaveService _save;
  final LevelRepository _levels;

  Future<void> load() async {
    emit(AsyncValue.loading(data: state.data));
    await runGuarded(() async {
      // Independent local reads; run them side by side.
      await Future.wait([_save.load(), _levels.load()]);
      return SplashState(levelCount: _levels.levelCount);
    });
  }
}
