import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/gradient_ring.dart';

/// The "describe your business" box, ringed by a slowly turning gradient edge.
class PromptComposer extends StatelessWidget {
  const PromptComposer({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onSubmit,
    required this.onAttach,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onSubmit;

  /// Called with "Photos" or "Link" when an attachment tool is pressed.
  final ValueChanged<String> onAttach;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 720;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: GradientRing(child: _inner(narrow)),
    );
  }

  Widget _inner(bool narrow) {
    Widget tool(IconData icon, String label) => TextButton.icon(
      onPressed: () => onAttach(label),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        minimumSize: const Size(44, 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, size: 20),
      label: narrow ? const SizedBox.shrink() : Text(label),
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .96),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          TextField(
            controller: controller,
            focusNode: focusNode,
            minLines: 2,
            maxLines: 5,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            style: const TextStyle(
              fontSize: 17,
              height: 1.5,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Color(0xFF8590AA)),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(22, 20, 22, 4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              children: [
                tool(Icons.image_outlined, 'Photos'),
                tool(Icons.link_rounded, 'Link'),
                const Spacer(),
                GradientButton(label: 'Create', onPressed: onSubmit),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Brand-gradient pill button with a trailing arrow chip.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.brandGradient,
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: AppColors.violet.withValues(alpha: .55),
                blurRadius: 28,
                offset: const Offset(0, 12),
                spreadRadius: -10,
              ),
            ],
          ),
          child: InkWell(
            borderRadius: radius,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .2),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
