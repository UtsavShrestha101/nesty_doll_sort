import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/ui/icons/nesty_icons.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/tactile_button.dart';

/// Minimal "something went wrong — try again" body for a failed local load.
///
/// The text comes from [exception]'s kind (`AppExceptionL10n`), never from
/// its message.
///
/// TODO(design): no frame shows a load failure; this uses the body style
/// and a secondary button until one does.
class RetryView extends StatelessWidget {
  const RetryView({required this.exception, required this.onRetry, super.key});

  final AppException exception;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            exception.localizedMessage(context.localizations),
            style: context.bodyText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TactileButton(
            label: context.localizations.retry,
            icon: NestyIcons.restartAlt,
            variant: TactileButtonVariant.secondary,
            size: TactileButtonSize.small,
            expand: false,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}
