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
}
