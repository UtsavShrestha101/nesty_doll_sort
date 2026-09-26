import 'dart:async';

import 'package:flame/game.dart';
import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/features/gameplay/game/nesty_game.dart';
import 'package:nesty_game/features/gameplay/widgets/booster_bar.dart';
import 'package:nesty_game/features/gameplay/widgets/gameplay_top_bar.dart';

/// Spec §10.2 #3: top bar, centered board, booster bar.
///
/// TODO(M2): a gameplay controller (cubit or `BaseAsyncBloc`) that owns the
/// nesty_core `GameSession` for [levelNumber]; the Flame game only renders
/// it. Win / Out of Moves / soft-stuck overlays (spec §2.3, §10.2).
@RoutePage()
class GameplayPage extends StatefulWidget {
  const GameplayPage({required this.levelNumber, super.key});

  /// 1-based global play order (spec §7.1).
  final int levelNumber;

  @override
  State<GameplayPage> createState() => _GameplayPageState();
}

class _GameplayPageState extends State<GameplayPage> {
  // Created once per page, never in build(), so rebuilds don't recreate the
  // game (and its loaded components).
  final NestyGame _game = NestyGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            GameplayTopBar(
              levelNumber: widget.levelNumber,
              // TODO(M2): open the pause menu (spec §10.2 #14, frame 3.9).
              onPause: () => unawaited(context.router.maybePop()),
            ),
            Expanded(child: GameWidget<NestyGame>(game: _game)),
            const BoosterBar(),
          ],
        ),
      ),
    );
  }
}
