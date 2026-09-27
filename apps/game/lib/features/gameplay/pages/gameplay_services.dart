import 'package:flutter/foundation.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';

/// The app services the gameplay screen reads, resolved once at its route
/// boundary (`GameplayPage.wrappedRoute`) and handed down, so the widgets
/// never reach into DI and tests pass fakes directly.
@immutable
final class GameplayServices {
  const GameplayServices({
    required this.skins,
    required this.levels,
    required this.database,
    required this.fx,
    required this.feedback,
    required this.music,
    required this.jingles,
  });

  /// The level's art and the chapter background (lottie §4).
  final SkinService skins;

  /// Chapter lengths for the win card and the new-chapter ribbon.
  final LevelRepository levels;

  /// The pause dialog's switches and the symbols mode.
  final DatabaseService database;

  /// The loaded compositions of every widget-hosted Lottie.
  final FxLibrary fx;

  /// The win overlay's `win` and `coins` cues.
  final FeedbackSink feedback;

  /// Ducked under the win overlay, the out-of-moves sheet and the pause
  /// dialog (AUDIO.md "Music rules"); the route observer picks the loop.
  final MusicService music;

  /// `jingle_oom` when the out-of-moves sheet opens.
  final JinglePlayer jingles;
}
