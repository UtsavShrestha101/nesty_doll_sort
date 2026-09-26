import 'package:nesty_admin/core/common_imports.dart';

/// Stand-in body for a screen whose real UI lands in a later milestone
/// (spec §18). Every placeholder admin page uses this one widget, so they
/// can all be swapped out without hunting for copies.
///
/// TODO(design): replace each use with the real screen (design/admin/*.png).
class PlaceholderView extends StatelessWidget {
  const PlaceholderView({
    required this.title,
    this.milestone = 'M5',
    super.key,
  });

  /// The screen's localized title.
  final String title;

  /// The spec §18 milestone that builds the screen. An internal code, so it
  /// is passed into the ARB string rather than translated.
  final String milestone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Semantics(
              header: true,
              child: Text(title, style: context.headlineMedium),
            ),
            const SizedBox(height: 8),
            Text(
              context.localizations.comingInMilestone(milestone),
              style: context.bodyMedium.copyWith(
                color: context.theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
