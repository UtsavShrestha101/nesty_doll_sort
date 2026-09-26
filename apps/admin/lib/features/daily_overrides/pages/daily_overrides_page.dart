import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #8 Daily overrides.
///
/// TODO(M5): calendar view to pick or generate a level for a date; writes
/// `dailyOverrides/{yyyymmdd}` (spec §14.1).
@RoutePage()
class DailyOverridesPage extends StatelessWidget {
  const DailyOverridesPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.dailyOverridesTitle);
}
