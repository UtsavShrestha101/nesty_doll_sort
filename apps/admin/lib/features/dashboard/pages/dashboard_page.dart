import 'package:nesty_admin/core/common_imports.dart';
import 'package:nesty_admin/core/ui/widgets/placeholder_view.dart';

/// Spec §15 #1 Dashboard.
///
/// TODO(M5): counts by status, `config/manifest` version, last publish, and
/// the "levels remaining ahead of players" estimate.
@RoutePage()
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) =>
      PlaceholderView(title: context.localizations.dashboardTitle);
}
