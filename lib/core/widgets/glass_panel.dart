import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted white panel used over the aurora background.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = 20,
    this.padding = EdgeInsets.zero,
    this.opacity = .62,
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: shape,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: .1),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -18,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: shape,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: opacity),
              borderRadius: shape,
              border: Border.all(color: Colors.white.withValues(alpha: .85)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
