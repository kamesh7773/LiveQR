import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/services/dialog_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/aurora_background.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/hero_scene.dart';
import '../../../core/widgets/live_qr_logo.dart';
import '../../home/views/widgets/prompt_composer.dart';
import '../models/page_spec.dart';
import '../view_models/page_draft_view_model.dart';
import 'widgets/spec_page_preview.dart';

// ponytail: placeholder until publishing gives each page its real address.
const _draftQrData = 'https://liveqr.example/p/draft';

/// Generates a page from [request] and shows it in the phone scene.
class PageDraftScreen extends HookConsumerWidget {
  const PageDraftScreen({super.key, required this.request});

  final PageRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = pageDraftProvider(request);
    final draft = ref.watch(provider);
    final ready = draft.hasValue && !draft.isLoading;
    final dialog = ref.read(dialogServiceProvider.notifier);

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final pulse = useAnimationController(
      duration: const Duration(milliseconds: 900),
    );
    useEffect(() {
      reduceMotion ? pulse.stop() : pulse.repeat(reverse: true);
      return null;
    }, [reduceMotion]);

    void regenerate() => ref.invalidate(provider);
    void edit() => Navigator.of(context).pop();

    final scene = HeroScene(
      screen: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        // Fill the phone screen even when the page is short.
        layoutBuilder: (current, previous) =>
            Stack(fit: StackFit.expand, children: [...previous, ?current]),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween(begin: .96, end: 1.0).animate(animation),
            child: child,
          ),
        ),
        child: ready
            ? SpecPagePreview(key: ObjectKey(draft.value), spec: draft.value!)
            : SpecPageSkeleton(pulse: pulse),
      ),
      qrData: _draftQrData,
      qrLabel: 'Live after publishing',
      toasts: ready
          ? const [
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
                    Text('Draft ready'),
                  ],
                ),
              ),
            ]
          : const [],
    );

    final panel = AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: draft.isLoading
          ? _Generating(description: request.description)
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
              spec: draft.value!,
              onPublish: () => dialog.showInfo('Publishing is coming soon.'),
              onRegenerate: regenerate,
              onEdit: edit,
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
                              Expanded(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxHeight: 760,
                                  ),
                                  child: Center(child: scene),
                                ),
                              ),
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
                        SizedBox(height: 480, child: scene),
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
    'Reading your description',
    'Writing the copy',
    'Choosing colours',
    'Laying out sections',
    'Checking nothing is made up',
  ];

  @override
  Widget build(BuildContext context) {
    final step = useState(0);
    useEffect(() {
      final timer = Timer.periodic(
        const Duration(milliseconds: 2400),
        (_) => step.value = (step.value + 1) % _steps.length,
      );
      return timer.cancel;
    }, const []);

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
            '${_steps[step.value]}…',
            key: ValueKey(step.value),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.violet,
            ),
          ),
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
    required this.spec,
    required this.onPublish,
    required this.onRegenerate,
    required this.onEdit,
  });

  final PageSpec spec;
  final VoidCallback onPublish;
  final VoidCallback onRegenerate;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('ready'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Chip(label: 'DRAFT · NOT PUBLISHED'),
        const SizedBox(height: 22),
        Text(spec.title, style: _title(44)),
        const SizedBox(height: 10),
        Text(
          spec.tagline,
          style: const TextStyle(
            fontSize: 17,
            height: 1.5,
            color: AppColors.textSecondary,
          ),
        ),
        if (spec.questions.isNotEmpty) ...[
          const SizedBox(height: 24),
          GlassPanel(
            radius: 20,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Add these so nothing is guessed',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                for (final q in spec.questions)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.help_outline_rounded,
                            size: 18,
                            color: AppColors.violet,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            q,
                            style: const TextStyle(
                              fontSize: 14.5,
                              height: 1.45,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 26),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            GradientButton(label: 'Publish', onPressed: onPublish),
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Edit description'),
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
