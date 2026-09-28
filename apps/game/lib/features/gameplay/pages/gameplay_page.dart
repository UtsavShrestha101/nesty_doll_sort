import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/repository/level_resolver.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/audio/jingle_player.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/music/jingle_cues.dart';
import 'package:nesty_game/core/services/music/music_service.dart';
import 'package:nesty_game/core/services/save/save_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';

/// The gameplay route (spec §10.2 #3): what [request] asks for, a
/// published level, a bonus level or the daily puzzle
/// (docs/plans/m3-design.md §6).
///
/// Its boundary creates the level's [GameplayBloc] (which loads the level
/// at once) and resolves the services the screen reads; [GameplayView] is
/// the screen.
@RoutePage()
class GameplayPage extends StatelessWidget implements AutoRouteWrapper {
  const GameplayPage({required this.request, super.key});

  /// What to play (`LevelResolver` makes it playable).
  final PlayRequest request;

  @override
  Widget wrappedRoute(BuildContext context) => RepositoryProvider(
    create: (_) => GameplayServices(
      skins: get<SkinService>(),
      levels: get<LevelRepository>(),
      resolver: get<LevelResolver>(),
      save: get<SaveService>(),
      database: get<DatabaseService>(),
      fx: get<FxLibrary>(),
      feedback: ServiceFeedbackSink(
        audio: get<AudioService>(),
        haptics: get<HapticsService>(),
      ),
      music: get<MusicService>(),
      jingles: get<JinglePlayer>(),
      jingleCues: get<JingleCues>(),
    ),
    child: BlocProvider(
      create: (_) => get<GameplayBloc>()..add(GameplayStarted(request)),
      child: this,
    ),
  );

  @override
  Widget build(BuildContext context) => GameplayView(
    request: request,
    services: context.read<GameplayServices>(),
    // Home is under the level (Home → Play); navigate pops back to it, or
    // opens it if the level was reached some other way.
    onHome: () => unawaited(
      context.router.navigate(const MainShellRoute(children: [HomeRoute()])),
    ),
    // Over the level, so back returns to its pause dialog (frame 3.9).
    onSettings: () => context.router.push<void>(const SettingsRoute()),
  );
}
