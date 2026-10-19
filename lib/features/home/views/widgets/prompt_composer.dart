import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    required this.photos,
    required this.links,
    required this.onAddPhotos,
    required this.onAddLink,
    required this.onRemovePhoto,
    required this.onRemoveLink,
  });

  /// Longest description the backend accepts (MAX_DESCRIPTION in src/routes/ai.js).
  static const maxLength = 20000;

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final VoidCallback onSubmit;

  final List<ComposerPhoto> photos;
  final List<String> links;
  final VoidCallback onAddPhotos;
  final VoidCallback onAddLink;
  final ValueChanged<ComposerPhoto> onRemovePhoto;
  final ValueChanged<String> onRemoveLink;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 720;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: GradientRing(child: _inner(narrow)),
    );
  }

  Widget _inner(bool narrow) {
    Widget tool(IconData icon, String label, VoidCallback onPressed) =>
        TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSecondary,
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
            maxLines: 12,
            // Count but don't cut: a pasted menu stays intact and the owner trims it.
            maxLength: maxLength,
            maxLengthEnforcement: MaxLengthEnforcement.none,
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    currentLength > maxLength! * .9
                    ? Text('$currentLength / $maxLength')
                    : null,
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
          if (photos.isNotEmpty || links.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (final photo in photos)
                      _Thumb(
                        photo: photo,
                        onRemove: () => onRemovePhoto(photo),
                      ),
                    for (final link in links)
                      InputChip(
                        avatar: const Icon(Icons.link_rounded, size: 16),
                        label: Text(
                          Uri.parse(link).host.replaceFirst('www.', ''),
                        ),
                        tooltip: link,
                        onDeleted: () => onRemoveLink(link),
                        deleteButtonTooltipMessage: 'Remove link',
                      ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Row(
              children: [
                tool(Icons.image_outlined, 'Photos', onAddPhotos),
                tool(Icons.link_rounded, 'Link', onAddLink),
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

/// A picked photo: shown from its bytes at once, [id] set once the upload finishes.
class ComposerPhoto {
  ComposerPhoto(this.bytes);

  final Uint8List bytes;
  String? id;
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.photo, required this.onRemove});

  final ComposerPhoto photo;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(photo.bytes, fit: BoxFit.cover),
          ),
          if (photo.id == null)
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ),
            ),
          Positioned(
            top: -6,
            right: -6,
            child: IconButton(
              tooltip: 'Remove photo',
              onPressed: onRemove,
              iconSize: 14,
              constraints: const BoxConstraints.tightFor(width: 28, height: 28),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.textPrimary,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

/// Asks for a web address. Returns it with https:// added when no scheme was typed,
/// or null if cancelled.
Future<String?> askForLink(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _LinkDialog(),
  );
}

class _LinkDialog extends StatefulWidget {
  const _LinkDialog();

  @override
  State<_LinkDialog> createState() => _LinkDialogState();
}

class _LinkDialogState extends State<_LinkDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    final url = text.contains('://') ? text : 'https://$text';
    final uri = Uri.tryParse(url);
    final valid =
        uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.contains('.') &&
        url.length <= 300;
    if (!valid) {
      setState(
        () => _error = 'Enter a web address, e.g. instagram.com/yourcafe',
      );
      return;
    }
    Navigator.pop(context, url);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add a link'),
      content: SizedBox(
        width: 420,
        child: TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.url,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            hintText: 'Website, Instagram, menu, Google Maps…',
            prefixIcon: const Icon(Icons.link_rounded),
            errorText: _error,
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Add')),
      ],
    );
  }
}
