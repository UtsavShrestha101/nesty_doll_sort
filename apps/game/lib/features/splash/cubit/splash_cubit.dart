import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io' show FileSystemException;

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/base/base_async_cubit.dart';
import 'package:nesty_game/core/base/base_async_state.dart';
import 'package:nesty_game/core/error/app_exception.dart';
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
///   page offers a retry), then the star rating's load-time backfill
///   (`SaveService.backfillLevelStars`, Q120; m7-design P3.6): silent and
///   idempotent, so a retry or a later launch never repeats or undoes it;
/// - the 29 Lottie files (`FxLibrary.load`, never throws);
/// - the skin, symbols and board art (`SkinService.load`), then the shelf
///   dolls' rasters for this screen and Home (`ShowcaseDolls`);
/// - the sound effects.
///
/// While loading it emits `loading` with the weighted progress, which
/// drives `ui_splash_loader` (frame = progress %).
///
/// E9 (spec-prop §10.1; docs/plans/m7-design.md §13): once the save has
/// loaded, `SplashState.opensFirstLevel` is set for the page to act on —
/// true while no level has been won (`SaveService.highestLevel <= 1`), so a
/// fresh install (or a kill during L1) opens Level 1 instead of Home.
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
    await runGuarded(
      () => _guard(() async {
        // Independent local reads; run them side by side.
        await Future.wait([_save.load(), _levels.load()]);
        // Q120 (m7-design P3.6), once both have loaded: silent and
        // idempotent, so it never shows anything and costs nothing on a
        // later launch.
        _save.backfillLevelStars(_levels);
        progress.complete(SplashTask.content);
        await optional;
        return SplashState(
          progress: 1,
          levelCount: _levels.levelCount,
          // E9: no level won yet (a fresh install, or a kill during L1, whose
          // `highestLevel` is still 1) opens L1 instead of Home.
          opensFirstLevel: _save.highestLevel <= 1,
        );
      }),
    );
  }

  /// Runs [body], naming what failed for the error card (frames 12.10,
  /// 12.11): a full disk is [AppExceptionKind.storage], everything else in
  /// the bundled content or the save is [AppExceptionKind.content].
  Future<SplashState> _guard(Future<SplashState> Function() body) async {
    try {
      return await body();
    } on AppException {
      rethrow;
    } on Object catch (error, stack) {
      throw AppException(
        kindOf(error),
        message: error.toString(),
        cause: error,
        stackTrace: stack,
      );
    }
  }

  /// `ENOSPC` (errno 28 on Linux, macOS and Android) from the file system,
  /// which is what the save's writer and the level bundle's cache raise when
  /// the phone is full, is a storage failure; anything else is content.
  @visibleForTesting
  static AppExceptionKind kindOf(Object error) {
    if (error is FileSystemException && error.osError?.errorCode == _enospc) {
      return AppExceptionKind.storage;
    }
    return AppExceptionKind.content;
  }

  static const int _enospc = 28;

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
