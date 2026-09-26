import 'dart:async';

import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/features/fx/fx_cue.dart';

/// Where the board timeline sends its sounds and haptics, at the exact
/// times of LOTTIE.md "When each one plays" (docs/plans/m2-lottie-design.md
/// §7). Tests use a recording fake.
abstract interface class FeedbackSink {
  /// Plays [cue] now. Must not throw or block.
  void play(FxCue cue);
}

/// The app's [FeedbackSink]: [AudioService] for the sound, [HapticsService]
/// for the haptic. Both respect the player's settings, so this just fires
/// and forgets. Failures are swallowed (CLAUDE.md rule 3).
final class ServiceFeedbackSink implements FeedbackSink {
  ServiceFeedbackSink({
    required AudioService audio,
    required HapticsService haptics,
  }) : _audio = audio,
       _haptics = haptics;

  final AudioService _audio;
  final HapticsService _haptics;

  @override
  void play(FxCue cue) {
    final sound = cue.sound;
    if (sound != null) {
      try {
        _audio.play(sound, dollSize: cue.dollSize, comboStep: cue.comboStep);
      } on Object {
        // Rule 3: a sound that fails is silence.
      }
    }
    final haptic = cue.haptic;
    if (haptic != null) {
      try {
        unawaited(_haptics.play(haptic).catchError(_ignore));
      } on Object {
        // Rule 3: a haptic that fails is nothing.
      }
    }
  }

  static void _ignore(Object _) {}
}
