/// What went wrong, coarsely. The UI maps a kind to an ARB string — it never
/// shows [AppException.message] to players.
enum AppExceptionKind {
  /// Local persistence failed (Hive box, save file).
  storage,

  /// Bundled or cached content was missing or invalid (levels, skins).
  /// Spec §5.3: invalid levels are skipped with a log entry in the game.
  content,

  /// A network-backed service failed. Callers treat this as "offline" and
  /// carry on silently (CLAUDE.md rule 3).
  network,

  /// The work was superseded, e.g. a background hint/soft-stuck search that
  /// the next move made stale (spec §2.3). Never surfaced as an error state.
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
