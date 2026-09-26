import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #5 Chapters.
///
/// TODO(M5): CRUD on `chapters/{chapterId}` (spec §14.1), with theme and
/// museum item assignment.
@RoutePage()
class ChaptersPage extends StatelessWidget {
  const ChaptersPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.chaptersTitle);
}
