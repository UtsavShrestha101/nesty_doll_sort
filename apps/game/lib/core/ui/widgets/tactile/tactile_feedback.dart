import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';

/// What a tactile control does when it activates: the `button` sound and the
/// selection haptic (tokens.json `sound.events.button`, `haptics.button`;
/// LOTTIE.md "Settings / Pause toggle").
///
/// Both services respect the player's settings and never throw (rule 3), so
/// this is fire-and-forget.
abstract interface class TactileFeedback {
  void activate();

  /// The feedback for controls under [context]: the nearest
  /// [TactileFeedbackScope], else the app's registered [AudioService] and
  /// [HapticsService], else none (widget tests without DI stay silent).
  static TactileFeedback? of(BuildContext context) =>
      TactileFeedbackScope.maybeOf(context) ?? _fromLocator();

  static TactileFeedback? _fromLocator() {
    final locator = GetIt.instance;
    if (!locator.isRegistered<AudioService>() ||
        !locator.isRegistered<HapticsService>()) {
      return null;
    }
    return ServiceTactileFeedback(
      audio: locator<AudioService>(),
      haptics: locator<HapticsService>(),
    );
  }
}

/// [TactileFeedback] through the app's services.
final class ServiceTactileFeedback implements TactileFeedback {
  const ServiceTactileFeedback({required this.audio, required this.haptics});

  final AudioService audio;
  final HapticsService haptics;

  @override
  void activate() {
    audio.play(SoundEffect.button);
    unawaited(haptics.play(HapticPattern.button));
  }
}

/// Overrides the [TactileFeedback] of every tactile control below it (tests,
/// or a screen that wants its own sounds).
class TactileFeedbackScope extends InheritedWidget {
  const TactileFeedbackScope({
    required this.feedback,
    required super.child,
    super.key,
  });

  final TactileFeedback feedback;

  static TactileFeedback? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<TactileFeedbackScope>()?.feedback;

  @override
  bool updateShouldNotify(TactileFeedbackScope oldWidget) =>
      !identical(oldWidget.feedback, feedback);
}
