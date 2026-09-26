import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #7 Museum items.
///
/// TODO(M5): upload with preview; writes `museumItems/{itemId}` and
/// `museum/{itemId}.png` (spec §14.1-2).
@RoutePage()
class MuseumItemsPage extends StatelessWidget {
  const MuseumItemsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.museumItemsTitle);
}
