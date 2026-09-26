import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/error/app_exception.dart';

/// Minimal "something went wrong — try again" body for a failed local load.
///
/// The text comes from [exception]'s kind (`AppExceptionL10n`), never from
/// its message.
///
/// TODO(M2): replace with the design's modal card style (design/README.md
/// "Components").
class RetryView extends StatelessWidget {
  const RetryView({required this.exception, required this.onRetry, super.key});

  final AppException exception;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          exception.localizedMessage(context.localizations),
          style: context.bodyLarge,
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: onRetry,
          child: Text(context.localizations.retry),
        ),
      ],
    );
  }
}
