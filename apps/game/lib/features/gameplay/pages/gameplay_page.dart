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
import 'package:nesty_game/core/services/share/share_service.dart';
import 'package:nesty_game/core/services/skin/skin_service.dart';
import 'package:nesty_game/core/ui/art/ui_art_library.dart';
import 'package:nesty_game/features/fx/fx_library.dart';
import 'package:nesty_game/features/gameplay/bloc/gameplay_bloc.dart';
import 'package:nesty_game/features/gameplay/game/timeline/feedback_sink.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_entrance.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_services.dart';
import 'package:nesty_game/features/gameplay/pages/gameplay_view.dart';
import 'package:nesty_game/features/race/cubit/race_cubit.dart';
import 'package:nesty_game/features/shop/model/shop_tab.dart';

export 'package:nesty_game/features/gameplay/pages/gameplay_entrance.dart'
    show GameplayEntrance;

/// The gameplay route (spec §10.2 #3): what [request] asks for, a
/// published level, a bonus level, the daily puzzle
/// (docs/plans/m3-design.md §6), a replay (m7-design §6) or a vs Computer
/// race (spec-prop §7.7, m7-design P2.8).
///
/// Its boundary creates the level's [GameplayBloc] (which loads the level
/// at once) and resolves the services the screen reads; [GameplayView] is
/// the screen. For a race it also creates the [RaceCubit] beside the bloc
/// and hands it to the view ([GameplayView.race]): one page, one board,
/// the same overlays (plan-m7 "Rejected: a separate race page and bloc").
@RoutePage()
class GameplayPage extends StatelessWidget implements AutoRouteWrapper {
  const GameplayPage({
    required this.request,
    this.entrance = GameplayEntrance.push,
    super.key,
  });

  /// What to play (`LevelResolver` makes it playable).
  final PlayRequest request;

  /// How the route comes on screen (`GameplayTransitions`; frame 10.8's
  /// first-launch fade is [GameplayEntrance.fromSplash]).
  final GameplayEntrance entrance;

  @override
  Widget wrappedRoute(BuildContext context) {
    final Widget gameplay = BlocProvider(
      create: (_) => get<GameplayBloc>()..add(GameplayStarted(request)),
      child: this,
    );
    final race = request;
    return RepositoryProvider(
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
        share: get<ShareService>(),
        uiArt: get<UiArtLibrary>(),
      ),
      child: race is RacePlay
          ? BlocProvider(
              create: (_) => get<RaceCubit>(param1: race),
              child: gameplay,
            )
          : gameplay,
    );
  }

  @override
  Widget build(BuildContext context) => GameplayView(
    request: request,
    services: context.read<GameplayServices>(),
    race: request is RacePlay ? context.read<RaceCubit>() : null,
    // Home is under the level (Home → Play); navigate pops back to it, or
    // opens it if the level was reached some other way.
    onHome: () => unawaited(
      context.router.navigate(const MainShellRoute(children: [HomeRoute()])),
    ),
    // Over the level, so back returns to its pause dialog (frame 3.9).
    onSettings: () => context.router.push<void>(const SettingsRoute()),
    // The booster popup's Not enough coins → Go to Shop: leaves the paused
    // level for the Shop's Coins tab, as Pause → Home leaves for Home.
    onShop: () => unawaited(
      context.router.navigate(
        MainShellRoute(children: [ShopRoute(initialTab: ShopTab.coins)]),
      ),
    ),
  );
}
