import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/gradient_ring.dart';
import '../../../../core/widgets/live_qr_logo.dart';
import 'prompt_composer.dart';

/// Asks a guest to sign in before creating, showing what will be kept for them.
/// Completes with true if they chose to sign in.
Future<bool> showSignInPrompt(
  BuildContext context, {
  required int photos,
  required int links,
}) async {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: const Color(0xFF1E1B4B).withValues(alpha: .28),
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 260),
    pageBuilder: (context, _, _) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: _SignInPrompt(photos: photos, links: links),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: .94, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
  return result ?? false;
}

class _SignInPrompt extends StatelessWidget {
  const _SignInPrompt({required this.photos, required this.links});

  final int photos;
  final int links;

  @override
  Widget build(BuildContext context) {
    Widget kept(IconData icon, String label) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: AppColors.violet.withValues(alpha: .14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.violet),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: 'Sign in to create your page',
              child: GradientRing(
                radius: 30,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 22),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .96),
                    borderRadius: BorderRadius.circular(28.5),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.violet.withValues(alpha: .12),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.violet.withValues(alpha: .25),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                              spreadRadius: -10,
                            ),
                          ],
                        ),
                        child: const AssetIcon(
                          'glossy-pastel-magic-sparkles-icon',
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Sign in to create your page',
                        style: TextStyle(
                          fontFamily: AppTheme.displayFont,
                          fontSize: 28,
                          height: 1.08,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -1,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Your page is one step away. We'll keep everything you've added and start creating the moment you're signed in.",
                        style: TextStyle(
                          fontSize: 15.5,
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          kept(Icons.notes_rounded, 'Your description'),
                          if (photos > 0)
                            kept(
                              Icons.image_outlined,
                              photos == 1 ? '1 photo' : '$photos photos',
                            ),
                          if (links > 0)
                            kept(
                              Icons.link_rounded,
                              links == 1 ? '1 link' : '$links links',
                            ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.textSecondary,
                              minimumSize: const Size(44, 48),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            child: const Text('Not now'),
                          ),
                          const SizedBox(width: 8),
                          GradientButton(
                            label: 'Sign in to continue',
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
