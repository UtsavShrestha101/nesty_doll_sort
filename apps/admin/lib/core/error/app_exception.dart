/// What went wrong, coarsely. The UI maps a kind to an ARB string
/// (`AppExceptionL10n.localizedMessage`); it never shows
/// [AppException.message] to users.
///
/// Same shape as the game's `AppException`; only the kinds differ, because
/// the admin talks to Firebase and has no local persistence.
enum AppExceptionKind {
  /// Sign-in was rejected: wrong email or password, a malformed email, or a
  /// disabled account (spec §15 "email/password sign-in").
  invalidCredentials,

  /// Firebase could not be reached (offline, timeout), or no backend is
  /// configured yet (before M5).
  network,

  /// A level, skin or other document was missing or failed validation
  /// (spec §5.3, §15 Skins checks).
  content,

  /// The work was superseded, e.g. a solve or simulate run the next edit made
  /// stale. Never surfaced as an error state.
  cancelled,

  /// Anything unexpected.
  unknown,
}

/// The one exception type `runGuarded` understands. Anything else thrown
/// inside a guarded body is wrapped as [AppExceptionKind.unknown].
class AppException implements Exception {
  const AppException(
    this.kind, {
    this.message = '',
    this.cause,
    this.stackTrace,
  });

  /// Returns [error] unchanged if it already is an [AppException], otherwise
  /// wraps it so the original error and stack survive for logging.
  factory AppException.wrap(Object error, [StackTrace? stackTrace]) =>
      error is AppException
      ? error
      : AppException(
          AppExceptionKind.unknown,
          message: error.toString(),
          cause: error,
          stackTrace: stackTrace,
        );

  final AppExceptionKind kind;

  /// Developer-facing detail for logs only.
  final String message;

  /// The underlying error, if this wraps one.
  final Object? cause;

  final StackTrace? stackTrace;

  bool get isCancellation => kind == AppExceptionKind.cancelled;

  @override
  String toString() => 'AppException(${kind.name}): $message';
}
