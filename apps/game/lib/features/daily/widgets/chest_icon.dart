import 'dart:math' as math;

import 'package:nesty_game/core/common_imports.dart';
import 'package:nesty_game/core/ui/nesty_ui.dart';

/// The wooden chest (NestyMenus "chest row", frame 5.1's small 62×50 icon;
/// [ChestIcon.open] is the 5.6 modal's 200×170 open one): a lid, a body and
/// a gold lock, drawn in code (no art asset for this one, `PlankStrip`'s
/// precedent).
class ChestIcon extends StatelessWidget {
  /// Closed, [size] wide (frame 5.1's chest row).
  const ChestIcon({this.size = 62, super.key}) : open = false;

  /// Open, [size] wide (frame 5.6, NestyMenus `isChest`): the lid tilted
  /// back, a gold glow and seven coins spilling out.
  const ChestIcon.open({this.size = _OpenChest.width, super.key}) : open = true;

  final double size;
  final bool open;

  @override
  Widget build(BuildContext context) {
    if (open) {
      return SizedBox(
        width: size,
        height: size * _OpenChest.height / _OpenChest.width,
        child: const FittedBox(child: _OpenChest()),
      );
    }
    final height = size * 50 / 62;
    return SizedBox(
      width: size,
      height: height,
      child: Stack(
        children: [
          Positioned(
            left: size * 0.03,
            right: size * 0.03,
            top: height * 0.36,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.1),
                gradient: _bodyGradient,
                border: Border.all(
                  color: AppColors.chestRing,
                  width: size * 0.048,
                ),
              ),
            ),
          ),
          Positioned(
            left: size * 0.02,
            right: size * 0.02,
            top: height * 0.08,
            height: height * 0.4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.22),
                gradient: _lidGradient,
                border: Border.all(
                  color: AppColors.chestRing,
                  width: size * 0.048,
                ),
              ),
            ),
          ),
          Positioned(
            left: size / 2 - size * 0.097,
            top: height * 0.32,
            width: size * 0.194,
            height: height * 0.28,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.chestLock,
                borderRadius: BorderRadius.circular(size * 0.048),
                border: Border.all(
                  color: AppColors.chestLockRing,
                  width: size * 0.032,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const _bodyGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.chestBodyTop, AppColors.chestBodyBottom],
);

const _lidGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [AppColors.chestLidTop, AppColors.chestLidBottom],
);

/// NestyMenus `isChest`'s 200×170 box at 1:1 (the caller scales it): in
/// paint order the glow, the coins, the lid (tilted back), the body and the
/// lock.
class _OpenChest extends StatelessWidget {
  const _OpenChest();

  static const double width = 200;
  static const double height = 170;

  /// `chestCoins`: (x, y, size) of each spilled coin.
  static const _coins = [
    (52.0, 20.0, 26.0),
    (86.0, 6.0, 30.0),
    (124.0, 18.0, 24.0),
    (70.0, 44.0, 22.0),
    (110.0, 40.0, 28.0),
    (36.0, 50.0, 18.0),
    (146.0, 46.0, 20.0),
  ];

  /// The frame's `perspective(200px) rotateX(38deg) translateY(-18px)`.
  /// Flutter's z points into the screen (CSS's out of it), so the same
  /// "top edge away" tilt is a negative angle here.
  static final Matrix4 _lidTilt = Matrix4.identity()
    ..setEntry(3, 2, 1 / 200)
    ..rotateX(-38 * math.pi / 180)
    ..translateByDouble(0, -18, 0, 1);

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        // `radial-gradient(closest-side, …)` on a 180×120 box: an ellipse,
        // so a circle stretched 1.5× wide.
        Positioned(
          left: 10,
          top: 0,
          width: 180,
          height: 120,
          child: Transform.scale(
            scaleX: 1.5,
            scaleY: 1,
            child: const Center(
              child: SizedBox.square(
                dimension: 120,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [AppColors.chestGlow, AppColors.chestGlowClear],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        for (final (x, y, size) in _coins)
          Positioned(
            left: x,
            top: y,
            width: size,
            height: size,
            child: CoinIcon(size: size),
          ),
        Positioned(
          left: 30,
          right: 30,
          top: 40,
          height: 34,
          child: Transform(
            alignment: Alignment.center,
            transform: _lidTilt,
            child: const NestySurface(
              style: SurfaceStyle(
                gradient: _lidGradient,
                shadows: [
                  NestyShadow(
                    color: AppColors.chestRing,
                    inset: true,
                    spread: 4,
                  ),
                ],
              ),
              radius: BorderRadius.vertical(
                top: Radius.circular(18),
                bottom: Radius.circular(6),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 24,
          right: 24,
          top: 86,
          height: 76,
          child: NestySurface(
            style: SurfaceStyle(
              gradient: _bodyGradient,
              shadows: [
                NestyShadow(color: AppColors.chestRing, inset: true, spread: 4),
                NestyShadow(color: AppColors.chestShadow, dy: 8, blur: 14),
              ],
            ),
            radius: BorderRadius.vertical(
              top: Radius.circular(8),
              bottom: Radius.circular(14),
            ),
          ),
        ),
        const Positioned(
          left: width / 2 - 11,
          top: 92,
          width: 22,
          height: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.chestLock,
              borderRadius: BorderRadius.all(Radius.circular(5)),
              boxShadow: [
                BoxShadow(color: AppColors.chestLockRing, spreadRadius: 3),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
