import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #2 Levels list. The root of the Levels tab's own stack.
///
/// TODO(M5): table of order, id, chapter, tier, casual/smart win rates,
/// solver moves and status; filters and search; drag-to-reorder within
/// drafts/published; bulk publish/unpublish/archive as one batched write that
/// bumps `config/manifest` (spec §15 Publishing). A row opens the editor with
/// `context.router.push(LevelEditorRoute(levelId: id))`.
@RoutePage()
class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.levelsTitle);
}
