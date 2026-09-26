import 'dart:ui';

import 'package:flame/game.dart';
import 'package:nesty_game/features/gameplay/game/components/board_component.dart';

/// Flame host for the board. Menus, the top bar and the booster bar are
/// regular Flutter widgets around the `GameWidget` (spec §13.1).
///
/// TODO(M2): receive the level's `GameSession` state from the gameplay
/// controller and pass it down to [BoardComponent]; add the `FxLayer`.
class NestyGame extends FlameGame {
  /// Transparent so the Flutter scaffold/theme background (and, from M7, the
  /// chapter theme art) shows through behind the shelves.
  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    await world.add(BoardComponent());
  }
}
