import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/error/app_exception.dart';
import 'package:nesty_game/core/ui/tokens/ui_token_types.dart';
import 'package:nesty_game/core/ui/tokens/ui_tokens.gen.dart';
import 'package:nesty_game/core/ui/widgets/buttons/tactile_button.dart';
import 'package:nesty_game/core/ui/widgets/surface/nesty_surface.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_style.dart';
import 'package:nesty_game/core/ui/widgets/surface/surface_styles.dart';
import 'package:nesty_game/core/ui/widgets/text/balanced_text.dart';

/// The tone of an [ErrorCard]'s icon disc (ui-spec-game §1 "ErrorCard"):
/// the warm orange of the game's own failures, or section 09's indigo for a
/// race's.
enum ErrorCardTone {
  /// Disc `#FFE9D2`, ring `0 0 0 8 rgba(242,137,59,.16)`, inset
  /// `0 -4 0 #F2CFA4`, glyph `#C4631E`.
  warm(
    disc: Color(0xFFFFE9D2),
    ring: Color(0x29F2893B),
    inset: Color(0xFFF2CFA4),
    glyph: Color(0xFFC4631E),
  ),

  /// Disc `color.versusTint`, ring `0 0 0 8 rgba(78,95,217,.14)`, inset
  /// `0 -4 0 #C9CFF5`, glyph `color.versusEdge`.
  versus(
    disc: AppColorTokens.versusTint,
    ring: Color(0x244E5FD9),
    inset: Color(0xFFC9CFF5),
    glyph: AppColorTokens.versusEdge,
  );

  const ErrorCardTone({
    required this.disc,
    required this.ring,
    required this.inset,
    required this.glyph,
  });

  final Color disc;
  final Color ring;
  final Color inset;
  final Color glyph;
}

/// The design's error card (frames 12.6, 12.10, 12.11, 9.3f; ui-spec-game §1
/// "ErrorCard"): an icon disc (96 with a 52 glyph, or [compact]'s 56 with a
/// 30 glyph), a head in Fredoka 700 24, a body in Nunito 600 16/23, one
/// primary button and an optional text link. It never shows a number or a
/// blame: it says what happened and what to do.
///
/// The card names its route to a screen reader ([namesRoute]) when it is a
/// whole screen's message (the splash's), and announces its head as a live
/// region.
class ErrorCard extends StatelessWidget {
  const ErrorCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.tone = ErrorCardTone.warm,
    this.compact = false,
    this.namesRoute = false,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String primaryLabel;

  /// Null disables the primary (a retry in flight).
  final VoidCallback? onPrimary;

  /// The text link under the button ("Back to Home").
  final String? secondaryLabel;
  final VoidCallback? onSecondary;
  final ErrorCardTone tone;

  /// The splash's smaller disc and padding (frames 12.10, 12.11).
  final bool compact;
  final bool namesRoute;

  /// The primary button, for tests.
  @visibleForTesting
  static const Key primaryKey = Key('error-card-primary');

  /// The head's 24 dp Fredoka, line 1.15 (`balance` wraps it in two).
  static TextStyle get headStyle => DisplayFace.of(
    const TextStyle(
      fontFamily: 'Fredoka',
      fontFamilyFallback: AppFontTokens.displayFallback,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.15,
      color: Color(0xFF5B3A21),
    ),
  );

  /// Nunito 600 16/23 `#7A5234`.
  static const TextStyle bodyStyle = TextStyle(
    fontFamily: 'Nunito',
    fontFamilyFallback: AppFontTokens.bodyFallback,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 23 / 16,
    color: AppColors.textBrown,
  );

  @override
  Widget build(BuildContext context) {
    final size = compact ? 56.0 : 96.0;
    final glyph = compact ? 30.0 : 52.0;
    return Semantics(
      scopesRoute: namesRoute,
      namesRoute: namesRoute,
      explicitChildNodes: namesRoute,
      child: NestySurface(
        style: SurfaceStyles.card,
        radius: BorderRadius.circular(AppRadii.card),
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(22, compact ? 24 : 28, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: NestySurface(
                style: SurfaceStyle(
                  color: tone.disc,
                  shadows: [
                    NestyShadow(color: tone.ring, spread: 8),
                    NestyShadow(color: tone.inset, inset: true, dy: -4),
                  ],
                ),
                radius: BorderRadius.circular(size / 2),
                width: size,
                height: size,
                alignment: Alignment.center,
                child: Icon(icon, size: glyph, color: tone.glyph),
              ),
            ),
            SizedBox(height: compact ? 22 : 24),
            Semantics(
              header: true,
              liveRegion: true,
              child: BalancedText(title, style: headStyle),
            ),
            const SizedBox(height: 8),
            Text(
              bindLastWord(body),
              textAlign: TextAlign.center,
              style: bodyStyle,
            ),
            const SizedBox(height: 18),
            TactileButton(
              key: primaryKey,
              label: primaryLabel,
              variant: tone == ErrorCardTone.versus
                  ? TactileButtonVariant.versus
                  : TactileButtonVariant.primary,
              onPressed: onPrimary,
            ),
            if (secondaryLabel != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: _ErrorTextLink(
                  label: secondaryLabel!,
                  onPressed: onSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The text link under an [ErrorCard]'s button: `textLink` (Fredoka 700 16
/// `#8A5B3A`), with a 48 dp hit box around its 36 dp look (lead note 3).
class _ErrorTextLink extends StatelessWidget {
  const _ErrorTextLink({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    enabled: onPressed != null,
    onTap: onPressed,
    child: ExcludeSemantics(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextLinkTokens.font.copyWith(color: TextLinkTokens.color),
            ),
          ),
        ),
      ),
    ),
  );
}

/// "Something went wrong, try again" for a failed local load (frames 12.10,
/// 12.11): an [ErrorCard] whose head, body and glyph come from [exception]'s
/// kind (`AppExceptionL10n`), never from its message. Storage says what to
/// do about the phone's space; everything else is the shelves that didn't
/// unpack.
class RetryView extends StatelessWidget {
  const RetryView({
    required this.exception,
    required this.onRetry,
    this.compact = true,
    super.key,
  });

  final AppException exception;
  final VoidCallback onRetry;

  /// The splash's 56 dp disc; a screen's own retry may use the larger one.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localizations;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ErrorCard(
        icon: exception.errorIcon,
        title: exception.errorTitle(l10n),
        body: exception.errorBody(l10n),
        primaryLabel: l10n.retry,
        onPrimary: onRetry,
        compact: compact,
        namesRoute: true,
      ),
    );
  }
}
