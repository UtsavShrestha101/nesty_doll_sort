import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #4 Generator.
///
/// TODO(M5): form with the §6.5 params plus count and seed; the batch runs
/// nesty_core's deterministic `Generator` off the UI thread and shows
/// preview cards with metrics; Accept adds them to drafts in the chosen
/// chapter, Reject discards them.
@RoutePage()
class GeneratorPage extends StatelessWidget {
  const GeneratorPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.generatorTitle);
}
