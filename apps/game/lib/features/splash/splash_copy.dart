/// The numbers the splash's error copy carries (copy.md E; phase 4
/// architecture §4): `splashStorageBody` takes [storageMegabytes] as its
/// `{megabytes}`, so the figure lives in code, not in the translations.
abstract final class SplashCopy {
  /// "Nesty needs about 60 MB to set up the shelves" (frame 12.10): copy.md's
  /// number. The save needs far less; the figure is the room the app wants
  /// to set up in. Q157 asks the owner to confirm it (the default ships).
  static const int storageMegabytes = 60;
}
