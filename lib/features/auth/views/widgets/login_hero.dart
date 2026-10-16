import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_panel.dart';
import '../../../../core/widgets/hero_scene.dart';
import '../../../../core/widgets/phone_preview.dart';

// ponytail: placeholder address until pages are published by the backend.
const _sampleQrData = 'https://liveqr.example/p/daily-brew';

/// Left side of the wide login page: the pitch, then the live QR → page scene.
/// Needs a bounded height: the scene takes whatever room the pitch leaves.
class LoginShowcase extends StatelessWidget {
  const LoginShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final size = (MediaQuery.sizeOf(context).width * .046).clamp(52.0, 76.0);
    final headline = TextStyle(
      fontFamily: AppTheme.displayFont,
      fontSize: size,
      height: .98,
      fontWeight: FontWeight.w700,
      letterSpacing: -.045 * size,
      color: AppColors.textPrimary,
    );

    // Only as tall as its text, so it centres vertically beside the scene.
    final pitch = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GlassPanel(
          radius: 99,
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            'AI-POWERED QR PAGES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.4,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Semantics(
          header: true,
          label: 'Create. Share. Grow with QR.',
          excludeSemantics: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create. Share.', style: headline),
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: AppColors.brandGradient.createShader,
                child: Text('Grow with QR.', style: headline),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            'Describe your business. Get a live page and a QR code you never have to reprint.',
            style: TextStyle(
              fontSize: 18,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );

    const scene = HeroScene(
      screen: MenuPagePreview(),
      qrData: _sampleQrData,
      qrLabel: 'Scan to open',
      toasts: [
        SceneToast(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PulseDot(),
              SizedBox(width: 10),
              Text('Someone just scanned'),
            ],
          ),
        ),
        SceneToast(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 18,
                color: Color(0xFF16A34A),
              ),
              SizedBox(width: 8),
              Text('Menu updated · same QR'),
            ],
          ),
        ),
      ],
    );

    // Wide column: scene beside the pitch and larger; otherwise stacked below it.
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 860
          ? Row(
              children: [
                SizedBox(width: 470, child: pitch),
                const SizedBox(width: 16),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 700),
                    child: const Center(child: scene),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                pitch,
                const Expanded(child: Center(child: scene)),
              ],
            ),
    );
  }
}
