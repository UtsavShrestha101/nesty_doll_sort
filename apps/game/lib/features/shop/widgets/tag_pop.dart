import 'package:flutter/widgets.dart';
import 'package:nesty_game/core/extensions/context_extension.dart';
import 'package:nesty_render/nesty_render.dart' show MotionTokens;

/// A bought card's new footer: the price chip has just become Equip or Use
/// (tokens `motion.purchaseItem.swap`, m7-4 4.11), and it comes in with
/// `motion.tagPop`, 240 ms from 60 % with `easeOutBack`.
///
/// Only a footer built with [animate] set pops, once, when it is first built;
/// a footer that later rebuilds with [animate] cleared keeps its place. Under
/// reduce motion it just appears.
class TagPop extends StatelessWidget {
  const TagPop({required this.animate, required this.child, super.key});

  final bool animate;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!animate || context.reduceMotion) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: MotionTokens.tagPopFrom, end: 1),
      duration: const Duration(milliseconds: MotionTokens.tagPopMs),
      curve: MotionTokens.tagPopCurve,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
