import 'dart:async';

import 'package:flutter/scheduler.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/dependency_injection/app_env.dart';
import 'package:nesty_game/core/services/ticker/frame_ticker.dart';

/// The real [FrameTicker]: a raw Flutter [Ticker] on the scheduler's frame
/// callbacks (docs/plans/m7-design.md P2.5). A factory, one per race, in
/// both environments: the fake env's app and the widget tests still pump
/// real frames.
///
/// A raw ticker ignores `TickerMode`; frames stop by themselves while the
/// app is in the background, and the race stops it on every hold anyway
/// (spec-prop §7.7 "Pause").
@Injectable(as: FrameTicker, env: [AppEnv.real, AppEnv.fake])
class SchedulerFrameTicker implements FrameTicker {
  Ticker? _ticker;
  void Function(Duration elapsed)? _onTick;
  bool _disposed = false;

  @override
  void start(void Function(Duration elapsed) onTick) {
    if (_disposed) throw StateError('A disposed FrameTicker cannot start');
    _onTick = onTick;
    final ticker = _ticker ??= Ticker(_tick, debugLabel: 'FrameTicker');
    if (ticker.isActive) ticker.stop();
    unawaited(ticker.start());
  }

  void _tick(Duration elapsed) => _onTick?.call(elapsed);

  @override
  void stop() => _ticker?.stop();

  @override
  bool get isTicking => _ticker?.isActive ?? false;

  @override
  void dispose() {
    _disposed = true;
    _ticker?.dispose();
    _ticker = null;
    _onTick = null;
  }
}
