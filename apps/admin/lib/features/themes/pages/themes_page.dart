import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #7 Themes.
///
/// TODO(M5): upload a board theme (spec §12.4) with preview; writes
/// `themes/{themeId}` and `themes/{themeId}/v{version}/...` (spec §14.1-2).
@RoutePage()
class ThemesPage extends StatelessWidget {
  const ThemesPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.themesTitle);
}
