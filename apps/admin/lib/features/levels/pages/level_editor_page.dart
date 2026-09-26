import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #3 Level editor, pushed inside the Levels tab at
/// `/levels/:levelId`.
///
/// TODO(M5): shelf/slot builder, doll palette, live validation (§5.3), Solve,
/// Simulate, Playtest, Save Draft (bumps `version`) and Publish. Every rule,
/// validation, solve and simulation comes from nesty_core (CLAUDE.md rule 2),
/// and the board is a `CustomPainter` on nesty_render, not Flame (spec §13.1).
@RoutePage()
class LevelEditorPage extends StatelessWidget {
  const LevelEditorPage({
    @PathParam('levelId') required this.levelId,
    super.key,
  });

  /// The `levels/{levelId}` document id (spec §5.2, §14.1).
  final String levelId;

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.levelEditorTitle(levelId));
}
