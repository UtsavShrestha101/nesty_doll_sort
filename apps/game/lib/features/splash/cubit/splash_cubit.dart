import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/home/showcase/showcase_dolls.dart';
import 'package:nesty_game/features/splash/cubit/splash_progress.dart';

part 'splash_cubit.freezed.dart';
part 'splash_state.dart';

/// Loads everything the game needs offline before Home (spec §10.2 #1,
/// frame 1.1; m2-lottie-design §2 "Loading", §16 lane "Screens"):
/// - the save and the bundled levels (a failure is the only error: the
///   page offers a retry);
/// - the 29 Lottie files (`FxLibrary.load`, never throws);
/// - the skin, symbols and board art (`SkinService.load`), then the shelf
///   dolls' rasters for this screen and Home (`ShowcaseDolls`);
/// - the sound effects.
///
/// While loading it emits `loading` with the weighted progress, which
/// drives `ui_splash_loader` (frame = progress %).
///
/// TODO(M4): kick off level sync and Remote Config refresh in the background
/// here — unawaited, so the splash never waits on the network (rule 3).
/// TODO(M6): first-launch consent (UMP) sits between splash and Home (§10.1).
@injectable
class SplashCubit extends BaseAsyncCubit<SplashState> {
  SplashCubit(
    this._save,
    this._levels,
    this._fx,
    this._skin,
    this._audio,
    this._showcase,
  );

  final SaveService _save;
  final LevelRepository _levels;
  final FxLibrary _fx;
  final SkinService _skin;
  final AudioService _audio;
  final ShowcaseDolls _showcase;

  /// The latest [load]: an older attempt's late reports are dropped.
  int _attempt = 0;

  /// Loads everything; [devicePixelRatio] sizes the shelf dolls' rasters.
  /// A retry after an error runs it again (every part is memoized by its
  /// service, so only what failed is redone).
  Future<void> load({double devicePixelRatio = 1}) async {
    final attempt = ++_attempt;
    final progress = SplashProgress(
      onChanged: (value) {
        // Only while this attempt is still loading: a part that reports
        // after the content failed must not hide the retry, nor come after
        // the ready state.
        if (isClosed || attempt != _attempt || !state.isLoading) return;
        emit(AsyncValue.loading(data: SplashState(progress: value)));
      },
    );
    // Every attempt counts from 0, so the bar never runs backwards.
    emit(const AsyncValue.loading(data: SplashState()));
    // The optional parts never throw (rule 3): a failure is logged and
    // counted as done, so the splash always finishes.
    final optional = Future.wait([
      _quietly(
        () => _fx.load(
          onProgress: (value) => progress.report(SplashTask.lottie, value),
        ),
        () => progress.complete(SplashTask.lottie),
      ),
      _quietly(() async {
        await _skin.load();
        await _showcase.prepare(devicePixelRatio: devicePixelRatio);
      }, () => progress.complete(SplashTask.skin)),
      _quietly(_audio.preload, () => progress.complete(SplashTask.audio)),
    ]);
    await runGuarded(() async {
      // Independent local reads; run them side by side.
      await Future.wait([_save.load(), _levels.load()]);
      progress.complete(SplashTask.content);
      await optional;
      return SplashState(progress: 1, levelCount: _levels.levelCount);
    });
  }

  static Future<void> _quietly(
    Future<void> Function() work,
    VoidCallback done,
  ) async {
    try {
      await work();
    } on Object catch (error, stack) {
      developer.log(
        'an optional part failed to load',
        name: 'nesty.splash',
        error: error,
        stackTrace: stack,
      );
      // developer.log never reaches the `flutter run` terminal.
      if (kDebugMode) debugPrint('[nesty.splash] load failed: $error');
    }
    done();
  }
}
