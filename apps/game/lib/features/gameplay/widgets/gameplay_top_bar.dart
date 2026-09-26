import 'package:nesty_game/core/common_imports.dart';

/// Gameplay top bar (spec §10.2 #3): pause and the level title.
///
/// TODO(M2): the design HUD (frame 2.2): level pill with its tier, coin pill
/// and family counter.
class GameplayTopBar extends StatelessWidget {
  const GameplayTopBar({
    required this.levelNumber,
    required this.onPause,
    super.key,
  });

  final int levelNumber;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onPause,
            tooltip: context.localizations.pause,
            icon: const Icon(Icons.pause_rounded),
          ),
          Expanded(
            child: Text(
              context.localizations.levelTitle(levelNumber),
              textAlign: TextAlign.center,
              style: context.titleLarge,
            ),
          ),
          // Balances the pause button so the title stays centered.
          // TODO(M2): replace with the coin pill.
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
