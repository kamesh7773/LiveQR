import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/dialog_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/browser.dart';
import '../../../core/widgets/aurora_background.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/gradient_ring.dart';
import '../../../core/widgets/hero_scene.dart';
import '../../../core/widgets/live_qr_logo.dart';
import '../../../core/widgets/living_qr.dart';
import '../../../core/widgets/web_page_frame.dart';
import '../../home/views/widgets/prompt_composer.dart';
import '../models/generated_page.dart';
import '../repositories/pages_repository.dart';
import '../view_models/page_draft_view_model.dart';

// Shown in the waiting scene until the page has a real public link.
const _draftQrData = 'https://liveqr.example/p/draft';

/// Has the AI write a page from [request], then shows the live page on a phone or desktop.
class PageDraftScreen extends HookConsumerWidget {
  const PageDraftScreen({super.key, required this.request});

  final PageRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Try again swaps in a request that writes into the same page, keeping its public link.
    final current = useState(request);
    final provider = pageDraftProvider(current.value);
    final draft = ref.watch(provider);
    final page = draft.isLoading ? null : draft.value;
    final dialog = ref.read(dialogServiceProvider.notifier);
    final desktop = useState(false);

    final liveUrl = useState<String?>(null);
    // The draft that went live from this screen; any newer draft has unpublished changes.
    final livePage = useState<GeneratedPage?>(null);
    final publishing = useState(false);
    final url = liveUrl.value ?? page?.publicUrl;
    final isLive = page != null && identical(livePage.value, page);

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final pulse = useAnimationController(
      duration: const Duration(milliseconds: 900),
    );
    useEffect(() {
      reduceMotion ? pulse.stop() : pulse.repeat(reverse: true);
      return null;
    }, [reduceMotion]);

    void regenerate() {
      final id = draft.value?.id;
      id == null
          ? ref.invalidate(provider)
          : current.value = current.value.retryInto(id);
    }

    void edit() => Navigator.of(context).pop();

    // Editing the prompt rebuilds this same page, so its link and QR code stay the same.
    final editing = useState(false);
    void rebuild(String description) {
      editing.value = false;
      current.value = current.value.retryInto(
        draft.value!.id,
        description: description,
      );
    }

    Future<void> publish() async {
      final target = page!;
      publishing.value = true;
      try {
        final link = await ref.read(pagesRepositoryProvider).publish(target.id);
        if (!context.mounted) return;
        liveUrl.value = link;
        livePage.value = target;
        dialog.showSuccess(
          'Anyone who scans the QR code now sees this page.',
          title: 'Your page is live',
        );
      } on DioException catch (e) {
        dialog.showError(e.message ?? 'Could not publish. Please try again.');
      } finally {
        if (context.mounted) publishing.value = false;
      }
    }

    Future<void> downloadQr(String link) async {
      final slug = Uri.parse(link).pathSegments.last;
      downloadBytes(await qrPng(link), '$slug-qr-code.png', 'image/png');
    }

    void copyLink(String link) {
      Clipboard.setData(ClipboardData(text: link));
      dialog.showSuccess(link, title: 'Link copied');
    }

    final stage = page == null
        ? HeroScene(
            screen: _Skeleton(pulse: pulse),
            qrData: url ?? _draftQrData,
            qrLabel: url == null
                ? 'Live after publishing'
                : 'Same QR, new design',
          )
        : _Stage(
            url: page.previewUrl,
            desktop: desktop.value,
            onDesktop: (value) => desktop.value = value,
          );

    final panel = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: draft.isLoading
          ? _Generating(description: current.value.description)
          : editing.value && page != null
          ? _PromptEditor(
              description: current.value.description,
              onRebuild: rebuild,
              onCancel: () => editing.value = false,
            )
          : draft.hasError
          ? _Failed(
              message: switch (draft.error) {
                DioException(:final message?) => message,
                _ => 'Something went wrong. Please try again.',
              },
              onRetry: regenerate,
              onEdit: edit,
            )
          : _Ready(
              page: page!,
              liveUrl: url,
              isLive: isLive,
              publishing: publishing.value,
              onPublish: publish,
              onOpenPreview: () => openInNewTab(page.previewUrl),
              onCopy: copyLink,
              onDownloadQr: downloadQr,
              onRegenerate: regenerate,
              onEditPrompt: () => editing.value = true,
            ),
    );

    final topBar = Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: edit,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 8),
        const LiveQrLogo(size: 36),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.sky,
      body: AuroraBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 1000
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(48, 20, 48, 24),
                    child: Column(
                      children: [
                        topBar,
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: Center(child: stage)),
                              const SizedBox(width: 32),
                              SizedBox(
                                width: 460,
                                child: Center(
                                  child: SingleChildScrollView(child: panel),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        topBar,
                        SizedBox(height: 620, child: stage),
                        panel,
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

TextStyle _title(double size) => TextStyle(
  fontFamily: AppTheme.displayFont,
  fontSize: size,
  fontWeight: FontWeight.w700,
  height: 1.02,
  letterSpacing: -.04 * size,
  color: AppColors.textPrimary,
);

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.live = false});

  final String label;
  final bool live;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GlassPanel(
        radius: 99,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (live) ...[const PulseDot(), const SizedBox(width: 10)],
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 2.4,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shown while the AI works: a rotating status line and the owner's own words.
class _Generating extends HookWidget {
  const _Generating({required this.description});

  final String description;

  static const _steps = [
    'Studying your brand',
    'Choosing type and colour',
    'Composing the layout',
    'Writing the HTML',
    'Adding motion',
    'Polishing it for phones',
  ];

  @override
  Widget build(BuildContext context) {
    final seconds = useState(0);
    useEffect(() {
      final timer = Timer.periodic(
        const Duration(seconds: 1),
        (_) => seconds.value++,
      );
      return timer.cancel;
    }, const []);
    final step = (seconds.value ~/ 12) % _steps.length;
    final elapsed =
        '${seconds.value ~/ 60}:${(seconds.value % 60).toString().padLeft(2, '0')}';

    return Column(
      key: const ValueKey('generating'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Chip(label: 'GENERATING', live: true),
        const SizedBox(height: 22),
        Text('Designing\nyour page…', style: _title(48)),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            '${_steps[step]}…',
            key: ValueKey(step),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.violet,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$elapsed · a unique page usually takes 1–3 minutes',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 28),
        GlassPanel(
          radius: 20,
          padding: const EdgeInsets.all(18),
          child: Text(
            '“$description”',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Ready extends StatelessWidget {
  const _Ready({
    required this.page,
    required this.liveUrl,
    required this.isLive,
    required this.publishing,
    required this.onPublish,
    required this.onOpenPreview,
    required this.onCopy,
    required this.onDownloadQr,
    required this.onRegenerate,
    required this.onEditPrompt,
  });

  final GeneratedPage page;

  /// The public link, once the page has ever been published.
  final String? liveUrl;

  /// Whether this exact draft is what the public link shows.
  final bool isLive;
  final bool publishing;
  final VoidCallback onPublish;
  final VoidCallback onOpenPreview;
  final ValueChanged<String> onCopy;
  final ValueChanged<String> onDownloadQr;
  final VoidCallback onRegenerate;
  final VoidCallback onEditPrompt;

  @override
  Widget build(BuildContext context) {
    final link = liveUrl;
    return Column(
      key: const ValueKey('ready'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        isLive
            ? const _Chip(label: 'LIVE', live: true)
            : _Chip(
                label: link == null
                    ? 'DRAFT · NOT PUBLISHED'
                    : 'DRAFT · CHANGES NOT PUBLISHED',
              ),
        const SizedBox(height: 22),
        Text(page.title, style: _title(44)),
        const SizedBox(height: 10),
        Text(
          isLive
              ? 'Anyone who scans this QR code sees this page. New versions stay private until you publish them.'
              : link == null
              ? 'Written by AI just for you. Scroll and tap around in the preview: it works like the real page.'
              : 'This new version is private. Your QR code still shows the last published one until you publish this.',
          style: const TextStyle(
            fontSize: 17,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        if (link != null) ...[
          const SizedBox(height: 24),
          _LiveCard(
            url: link,
            onCopy: () => onCopy(link),
            onDownload: () => onDownloadQr(link),
            onOpen: () => openInNewTab(link),
          ),
        ],
        const SizedBox(height: 26),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            if (!isLive)
              GradientButton(
                label: publishing
                    ? 'Publishing…'
                    : link == null
                    ? 'Publish'
                    : 'Publish changes',
                onPressed: publishing ? () {} : onPublish,
              ),
            OutlinedButton.icon(
              onPressed: onOpenPreview,
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text('Open full page'),
            ),
            OutlinedButton.icon(
              onPressed: onEditPrompt,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit prompt'),
            ),
            TextButton.icon(
              onPressed: onRegenerate,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ],
        ),
      ],
    );
  }
}

/// The page's prompt, editable. Rebuilding writes into the same page (same link and QR code).
class _PromptEditor extends HookWidget {
  const _PromptEditor({
    required this.description,
    required this.onRebuild,
    required this.onCancel,
  });

  final String description;
  final ValueChanged<String> onRebuild;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController(text: description);
    useListenable(controller);
    final text = controller.text.trim();
    final canRebuild =
        text.isNotEmpty &&
        text != description.trim() &&
        text.length <= PromptComposer.maxLength;

    return Column(
      key: const ValueKey('editing'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Chip(label: 'EDIT PROMPT'),
        const SizedBox(height: 22),
        Text('Change\nyour prompt', style: _title(44)),
        const SizedBox(height: 10),
        const Text(
          'Add or change anything, then rebuild. The page uses only what you write here. Your link and QR code stay the same.',
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        GradientRing(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .96),
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: controller,
              autofocus: true,
              minLines: 6,
              maxLines: 14,
              maxLength: PromptComposer.maxLength,
              maxLengthEnforcement: MaxLengthEnforcement.none,
              buildCounter:
                  (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) => currentLength > maxLength! * .9
                  ? Text('$currentLength / $maxLength')
                  : null,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.fromLTRB(20, 18, 20, 18),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: canRebuild ? 1 : .45,
              duration: const Duration(milliseconds: 200),
              child: GradientButton(
                label: 'Rebuild page',
                onPressed: canRebuild ? () => onRebuild(text) : () {},
              ),
            ),
            TextButton(onPressed: onCancel, child: const Text('Cancel')),
          ],
        ),
      ],
    );
  }
}

/// The page's permanent QR code and link, with the ways to share them.
class _LiveCard extends StatelessWidget {
  const _LiveCard({
    required this.url,
    required this.onCopy,
    required this.onDownload,
    required this.onOpen,
  });

  final String url;
  final VoidCallback onCopy;
  final VoidCallback onDownload;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    Widget action(IconData icon, String label, VoidCallback onPressed) =>
        TextButton.icon(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            minimumSize: const Size(44, 40),
          ),
          icon: Icon(icon, size: 18),
          label: Text(label),
        );

    return GlassPanel(
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: LivingQr(data: url, size: 116),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your QR code',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  url,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.violet,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  children: [
                    action(Icons.copy_rounded, 'Copy link', onCopy),
                    action(Icons.download_rounded, 'Download QR', onDownload),
                    action(Icons.open_in_new_rounded, 'Open', onOpen),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({
    required this.message,
    required this.onRetry,
    required this.onEdit,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('failed'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('That didn’t work', style: _title(44)),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(
            fontSize: 17,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 26),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GradientButton(label: 'Try again', onPressed: onRetry),
            OutlinedButton(onPressed: onEdit, child: const Text('Back')),
          ],
        ),
      ],
    );
  }
}

/// The live page in a phone or desktop frame.
/// The iframe gets its real on-screen size: scaling an iframe blurs it, so it's only
/// shrunk when the window is smaller than a small phone (360 px) or desktop (1024 px).
class _Stage extends StatelessWidget {
  const _Stage({
    required this.url,
    required this.desktop,
    required this.onDesktop,
  });

  final String url;
  final bool desktop;
  final ValueChanged<bool> onDesktop;

  @override
  Widget build(BuildContext context) {
    // The backend hides scrollbars for pages shown in these frames, as on a real phone.
    final embedUrl = '$url?embed=1';
    return Column(
      children: [
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: false,
              icon: Icon(Icons.phone_iphone_rounded),
              label: Text('Phone'),
            ),
            ButtonSegment(
              value: true,
              icon: Icon(Icons.desktop_windows_outlined),
              label: Text('Desktop'),
            ),
          ],
          selected: {desktop},
          onSelectionChanged: (s) => onDesktop(s.single),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: LayoutBuilder(
            builder: (context, c) {
              final Size size;
              final Widget frame;
              if (desktop) {
                size = Size(
                  math.max(c.maxWidth, 1024),
                  math.max(c.maxHeight, 640),
                );
                frame = _DesktopFrame(url: embedUrl);
              } else {
                // As tall as fits, up to an iPhone's 844, at the iPhone's 390:844 shape.
                final screenHeight = math.min(
                  844.0,
                  c.maxHeight - 2 * _PhoneFrame.bezel,
                );
                final screenWidth = math.max(360.0, screenHeight * 390 / 844);
                size = Size(
                  screenWidth + 2 * _PhoneFrame.bezel,
                  screenWidth * 844 / 390 + 2 * _PhoneFrame.bezel,
                );
                frame = _PhoneFrame(url: embedUrl);
              }
              final sized = SizedBox.fromSize(size: size, child: frame);
              final fits =
                  size.width <= c.maxWidth && size.height <= c.maxHeight;
              return Center(child: fits ? sized : FittedBox(child: sized));
            },
          ),
        ),
      ],
    );
  }
}

class _PhoneFrame extends StatelessWidget {
  const _PhoneFrame({required this.url});

  static const bezel = 12.0;

  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(bezel),
      decoration: BoxDecoration(
        color: AppColors.phoneFrame,
        borderRadius: BorderRadius.circular(56),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: .35),
            blurRadius: 60,
            offset: const Offset(0, 30),
            spreadRadius: -20,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(44),
        child: WebPageFrame(url: url),
      ),
    );
  }
}

class _DesktopFrame extends StatelessWidget {
  const _DesktopFrame({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    Widget dot(Color color) => Container(
      width: 12,
      height: 12,
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: .3),
            blurRadius: 80,
            offset: const Offset(0, 40),
            spreadRadius: -30,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 44,
            color: const Color(0xFFF1F0F7),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                dot(const Color(0xFFFF5F57)),
                dot(const Color(0xFFFEBC2E)),
                dot(const Color(0xFF28C840)),
              ],
            ),
          ),
          Expanded(child: WebPageFrame(url: url)),
        ],
      ),
    );
  }
}

/// Placeholder phone screen while the page is being written: pulsing grey blocks.
class _Skeleton extends StatelessWidget {
  const _Skeleton({required this.pulse});

  /// 0–1, drives the blocks' brightness.
  final Animation<double> pulse;

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double? width, double radius = 10}) =>
        AnimatedBuilder(
          animation: pulse,
          builder: (context, _) => Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Color.lerp(
                const Color(0xFFECE9F6),
                const Color(0xFFDCD7EE),
                pulse.value,
              ),
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );

    return ColoredBox(
      color: const Color(0xFFFFFCF8),
      child: Column(
        children: [
          block(160, width: double.infinity, radius: 0),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                block(20, width: 150),
                const SizedBox(height: 8),
                block(10, width: 190),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < 3; i++)
                      block(42, width: 42, radius: 14),
                  ],
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < 3; i++) ...[
                  block(46, width: double.infinity, radius: 12),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
