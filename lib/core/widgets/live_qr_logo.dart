import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class LiveQrLogo extends StatelessWidget {
  const LiveQrLogo({super.key, this.size = 44});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AssetIcon('gradient-qr-app-icon', size: size),
        SizedBox(width: size * 0.25),
        Text(
          'Live QR',
          style: TextStyle(
            fontFamily: AppTheme.displayFont,
            fontSize: size * 0.64,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// Web-sized, transparent copy of an assets/images icon (see assets/images/optimized).
class AssetIcon extends StatelessWidget {
  const AssetIcon(this.name, {super.key, required this.size});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/optimized/$name.png',
      width: size,
      height: size,
      excludeFromSemantics: true,
    );
  }
}
