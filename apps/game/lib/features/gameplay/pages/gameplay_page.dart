import 'dart:async';

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/dependency_injection/di.dart';
import 'package:nesty_game/core/repository/level_repository.dart';
import 'package:nesty_game/core/router/app_router.dart';
import 'package:nesty_game/core/services/audio/audio_service.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/haptics/haptics_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';

/// The gameplay route (spec §10.2 #3): level [levelNumber] in play order.
///
/// Its boundary creates the level's [GameplayBloc] (which loads the level
/// at once) and resolves the services the screen reads; [GameplayView] is
/// the screen.
@RoutePage()
class GameplayPage extends StatelessWidget implements AutoRouteWrapper {
  const GameplayPage({required this.levelNumber, super.key});

  /// 1-based global play order (spec §7.1).
  final int levelNumber;

  @override
  Widget wrappedRoute(BuildContext context) => RepositoryProvider(
    create: (_) => GameplayServices(
      skins: get<SkinService>(),
      levels: get<LevelRepository>(),
      database: get<DatabaseService>(),
      fx: get<FxLibrary>(),
      feedback: ServiceFeedbackSink(
        audio: get<AudioService>(),
        haptics: get<HapticsService>(),
      ),
    ),
    child: BlocProvider(
      create: (_) => get<GameplayBloc>()..add(GameplayStarted(levelNumber)),
      child: this,
    ),
  );

  @override
  Widget build(BuildContext context) => GameplayView(
    levelNumber: levelNumber,
    services: context.read<GameplayServices>(),
    // Home is under the level (Home → Play); navigate pops back to it, or
    // opens it if the level was reached some other way.
    onHome: () => unawaited(context.router.navigate(const HomeRoute())),
  );
}
