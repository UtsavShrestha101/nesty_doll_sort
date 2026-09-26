import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #6 Skins.
///
/// TODO(M5): upload an SVG (or PNG layer set) with its sidecar JSON; check
/// group ids, artboard size and disallowed features (spec §12.2); live
/// preview of all colors × sizes including the lid-lift, drawn through
/// nesty_render; set price and status.
@RoutePage()
class SkinsPage extends StatelessWidget {
  const SkinsPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.skinsTitle);
}
