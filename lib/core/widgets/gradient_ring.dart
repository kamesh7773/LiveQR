import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../theme/app_colors.dart';

/// Rings [child] with a thin brand-gradient edge that slowly turns, plus a soft violet glow.
/// The edge holds still when the platform asks for reduced motion.
class GradientRing extends HookWidget {
  const GradientRing({super.key, required this.child, this.radius = 26});

  final Widget child;

  /// Outer corner radius; give [child] a radius about 1px smaller.
  final double radius;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final spin = useAnimationController(duration: const Duration(seconds: 8));
    useEffect(() {
      reduceMotion ? spin.stop() : spin.repeat();
      return null;
    }, [reduceMotion]);

    return AnimatedBuilder(
      animation: spin,
      child: child,
      builder: (context, child) => Container(
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: SweepGradient(
            transform: GradientRotation(spin.value * 2 * math.pi),
            colors: [
              AppColors.primary.withValues(alpha: .9),
              AppColors.violet.withValues(alpha: .15),
              AppColors.magenta.withValues(alpha: .85),
              AppColors.primary.withValues(alpha: .15),
              AppColors.primary.withValues(alpha: .9),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.violet.withValues(alpha: .4),
              blurRadius: 70,
              offset: const Offset(0, 30),
              spreadRadius: -34,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}
