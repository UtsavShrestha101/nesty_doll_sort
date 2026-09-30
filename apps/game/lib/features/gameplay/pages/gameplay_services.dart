import 'package:flutter/foundation.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/share/share_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';
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
    required this.resolver,
    required this.save,
    required this.database,
    required this.fx,
    required this.feedback,
    required this.music,
    required this.jingles,
    required this.jingleCues,
    required this.share,
    required this.uiArt,
  });

  /// The level's art and the chapter background (lottie §4).
  final SkinService skins;

  /// Chapter lengths for the win card and the new-chapter ribbon.
  final LevelRepository levels;

  /// Resolves `GameplayState.nextRequest` to a playable entry, so the win
  /// overlay can prefetch its art for whatever it is (a campaign level, a
  /// generated bonus level or nothing after a daily, m3-design §10.8).
  final LevelResolver resolver;

  /// `SaveDocument.selectedTheme` for the board's background
  /// (`selectedTheme ?? play.themeId`, m3-design §10.8).
  final SaveService save;

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

  /// The Chapter complete overlay's music/jingle sequence (AUDIO.md
  /// "Jingles", m3-design §9.3).
  final JingleCues jingleCues;

  /// The daily win card's Share (frame 10.1; phase 4 architecture §3.10):
  /// the OS share sheet with `DailyShareText.of`'s text.
  final ShareService share;

  /// The UI art's rasters for the win card's `ui_stars` and the chest's
  /// `ui_chest` (`UiArtImageSource`; §3.4).
  final UiArtLibrary uiArt;
}
