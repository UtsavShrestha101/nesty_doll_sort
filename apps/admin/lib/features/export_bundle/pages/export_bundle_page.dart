import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #9 Export bundle.
///
/// TODO(M5): download `bundle.json` of the first N published levels, encoded
/// with nesty_core's `LevelCodec`, for `apps/game/assets/levels/` (spec
/// §13.4).
@RoutePage()
class ExportBundlePage extends StatelessWidget {
  const ExportBundlePage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.exportBundleTitle);
}
