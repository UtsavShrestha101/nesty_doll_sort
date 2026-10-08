/// Build flavors. Each has its own entry point (`lib/main_<flavor>.dart`) and
/// native flavor (Android productFlavors / iOS schemes).
enum Flavor {
  dev,
  stg,
  prod;

  /// Whether the audio engine runs SoLoud's low-latency output profile
  /// (owner, audio plan Q41): prod only. On Android that profile takes
  /// AAudio's MMAP path, which screen recorders can't capture, so dev and
  /// stg use the conservative profile and store or ad videos recorded on
  /// them have sound. `SoLoudEngineHost` reads it when it starts the engine.
  bool get audioLowLatency => switch (this) {
    Flavor.prod => true,
    Flavor.dev || Flavor.stg => false,
  };

  /// The flavor's URL scheme, so three installs on one phone never collide
  /// (plan-local-habits §4): the home-screen widget opens
  /// `<urlScheme>://daily`. Matches the native `APP_URL_SCHEME` /
  /// `appUrlScheme` build settings.
  String get urlScheme => switch (this) {
    Flavor.dev => 'nesty-dev',
    Flavor.stg => 'nesty-stg',
    Flavor.prod => 'nesty',
  };
}
