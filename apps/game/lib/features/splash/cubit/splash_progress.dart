import 'dart:math' as math;

/// What the splash waits for (spec §10.2 #1, frame 1.1: "Logo and a quick
/// loading bar while the save file, bundled levels and Classic skin load"),
/// each weighted by how long it takes on a phone.
enum SplashTask {
  /// The 29 Lottie files (`FxLibrary.load`, about 300 ms on a phone, lottie
  /// §2; it reports per file).
  lottie(0.45),

  /// The skin, the belly symbols and the board art (`SkinService.load`)
  /// and then the shelf dolls' rasters (`ShowcaseDolls`).
  skin(0.35),

  /// The save and the bundled levels (milliseconds).
  content(0.15),

  /// The 17 sound effects.
  audio(0.05);

  const SplashTask(this.weight);

  final double weight;
}

/// The splash loader's value (`ui_splash_loader`: frame = progress %):
/// the weighted sum of every [SplashTask]'s own 0–1 progress. It only ever
/// grows, so the bar never jumps back.
final class SplashProgress {
  SplashProgress({this.onChanged});

  /// Called with the new total whenever it grows.
  final void Function(double progress)? onChanged;

  final List<double> _parts = List.filled(SplashTask.values.length, 0);
  double _value = 0;

  /// 0–1.
  double get value => _value;

  /// Records [task]'s own progress (0–1).
  void report(SplashTask task, double progress) {
    final clamped = progress.isNaN ? 0.0 : progress.clamp(0.0, 1.0);
    if (clamped <= _parts[task.index]) return;
    _parts[task.index] = clamped;
    var total = 0.0;
    for (final t in SplashTask.values) {
      total += t.weight * _parts[t.index];
    }
    final next = math.min(1, total).toDouble();
    if (next <= _value) return;
    _value = next;
    onChanged?.call(_value);
  }

  /// [task] is done.
  void complete(SplashTask task) => report(task, 1);
}
