import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/gradient_ring.dart';
import '../../../core/widgets/live_qr_logo.dart';
import '../../home/views/widgets/prompt_composer.dart';
import '../models/onboarding_questions.dart';

/// What the guided questions produced. [prompt] is '' if nothing was answered.
class OnboardingResult {
  const OnboardingResult(this.prompt, {required this.generate});

  final String prompt;

  /// true: "Generate my page" was pressed. false: skipped, so the owner writes or edits the prompt.
  final bool generate;
}

/// Asks what the owner wants to build, a few questions at a time, with Skip always available.
/// Photos are added through [onAddPhotos] into the same list the composer shows ([photos]).
Future<OnboardingResult?> showOnboarding(
  BuildContext context, {
  required ValueNotifier<List<ComposerPhoto>> photos,
  required VoidCallback onAddPhotos,
}) {
  final reduceMotion = MediaQuery.disableAnimationsOf(context);
  return showGeneralDialog<OnboardingResult>(
    context: context,
    barrierLabel: 'Guided setup',
    barrierColor: const Color(0xFF1E1B4B).withValues(alpha: .28),
    transitionDuration: reduceMotion
        ? Duration.zero
        : const Duration(milliseconds: 280),
    pageBuilder: (context, _, _) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: _Onboarding(photos: photos, onAddPhotos: onAddPhotos),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween(begin: .95, end: 1.0).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _Onboarding extends HookWidget {
  const _Onboarding({required this.photos, required this.onAddPhotos});

  final ValueNotifier<List<ComposerPhoto>> photos;
  final VoidCallback onAddPhotos;

  @override
  Widget build(BuildContext context) {
    final answers = useMemoized(Answers.new);
    final purpose = useState<Purpose?>(null);
    // 0: purpose cards · 1..n: the purpose's steps, then extras · n + 1: review.
    final page = useState(0);
    final forward = useState(true);
    // Answers live in a plain object; bump this to rebuild after a change.
    final version = useState(0);
    void changed() => version.value++;

    final steps = [...?purpose.value?.steps, extrasStep];
    final reviewPage = steps.length + 1;
    final onReview = purpose.value != null && page.value == reviewPage;
    final step = page.value > 0 && !onReview ? steps[page.value - 1] : null;

    void go(int to) {
      forward.value = to > page.value;
      page.value = to;
    }

    void skip() => Navigator.pop(
      context,
      OnboardingResult(
        purpose.value == null || answers.isEmpty
            ? ''
            : describe(purpose.value!, answers),
        generate: false,
      ),
    );

    final valid = step == null || _stepValid(step, answers);
    final answeredHere =
        step != null &&
        step.questions.any((q) => answerText(q, answers).isNotEmpty);

    final Widget body;
    if (page.value == 0) {
      body = _PurposePicker(
        selected: purpose.value,
        onPick: (p) {
          purpose.value = p;
          go(1);
        },
      );
    } else if (onReview) {
      body = _Review(
        purpose: purpose.value!,
        steps: steps,
        answers: answers,
        photos: photos,
        onEdit: (i) => go(i + 1),
      );
    } else {
      body = _StepView(
        step: step!,
        answers: answers,
        onChanged: changed,
        extras: identical(step, extrasStep)
            ? _PhotosRow(photos: photos, onAdd: onAddPhotos)
            : null,
      );
    }

    final size = MediaQuery.sizeOf(context);
    final total = reviewPage + 1;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 700,
            maxHeight: math.min(760, size.height - 24),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: Semantics(
              scopesRoute: true,
              namesRoute: true,
              explicitChildNodes: true,
              label: 'Guided setup',
              child: GradientRing(
                radius: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .97),
                    borderRadius: BorderRadius.circular(28.5),
                  ),
                  child: Column(
                    children: [
                      _Header(
                        progress: purpose.value == null
                            ? .08
                            : (page.value + 1) / total,
                        label: purpose.value?.label,
                        onSkip: skip,
                      ),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 260),
                          // Pages start at the top, not centred.
                          layoutBuilder: (current, previous) => Stack(
                            alignment: Alignment.topCenter,
                            children: [...previous, ?current],
                          ),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: Offset(
                                      forward.value ? .06 : -.06,
                                      0,
                                    ),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              ),
                          child: SingleChildScrollView(
                            key: ValueKey(page.value),
                            padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
                            child: body,
                          ),
                        ),
                      ),
                      if (page.value > 0)
                        _Footer(
                          onBack: page.value == 0
                              ? null
                              : () => go(page.value - 1),
                          primary: page.value == 0
                              ? null
                              : onReview
                              ? 'Generate my page'
                              : answeredHere ||
                                    step!.questions.any((q) => q.required)
                              ? 'Continue'
                              : 'Skip for now',
                          enabled: valid,
                          onPrimary: onReview
                              ? () => Navigator.pop(
                                  context,
                                  OnboardingResult(
                                    describe(purpose.value!, answers),
                                    generate: true,
                                  ),
                                )
                              : () => go(page.value + 1),
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

/// Every visible required question answered, and no badly formatted phone/email/link.
bool _stepValid(OnboardingStep step, Answers a) => step.questions.every((q) {
  if (!q.visible(a)) return true;
  final value = answerText(q, a);
  if (q.required && value.isEmpty) return false;
  return q is! TextQuestion || invalidReason(q.kind, value) == null;
});

TextStyle _display(double size) => TextStyle(
  fontFamily: AppTheme.displayFont,
  fontSize: size,
  height: 1.08,
  fontWeight: FontWeight.w700,
  letterSpacing: -.035 * size,
  color: AppColors.textPrimary,
);

class _Header extends StatelessWidget {
  const _Header({required this.progress, required this.onSkip, this.label});

  final double progress;
  final String? label;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 20, 16, 12),
      child: Column(
        children: [
          Row(
            children: [
              const LiveQrLogo(size: 30),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    label ?? '',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.violet,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: onSkip,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  minimumSize: const Size(64, 44),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Skip'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: Stack(
                children: [
                  Container(height: 5, color: const Color(0xFFEDEAF7)),
                  AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 300),
                    widthFactor: progress.clamp(0, 1),
                    child: Container(
                      height: 5,
                      decoration: const BoxDecoration(
                        gradient: AppColors.brandGradient,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({
    required this.onBack,
    required this.primary,
    required this.enabled,
    required this.onPrimary,
  });

  final VoidCallback? onBack;

  /// Label of the main button; null hides it (the purpose cards move on by themselves).
  final String? primary;
  final bool enabled;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFEDEAF7))),
      ),
      child: Row(
        children: [
          if (onBack != null)
            TextButton.icon(
              onPressed: onBack,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size(44, 48),
              ),
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: const Text('Back'),
            ),
          const Spacer(),
          if (primary != null)
            AnimatedOpacity(
              opacity: enabled ? 1 : .45,
              duration: const Duration(milliseconds: 200),
              child: GradientButton(
                label: primary!,
                onPressed: enabled ? onPrimary : () {},
              ),
            ),
        ],
      ),
    );
  }
}

class _PurposePicker extends StatelessWidget {
  const _PurposePicker({required this.selected, required this.onPick});

  final Purpose? selected;
  final ValueChanged<Purpose> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What would you like to create?', style: _display(30)),
        const SizedBox(height: 8),
        const Text(
          'Tell us what people should see when they scan your QR code.',
          style: TextStyle(fontSize: 15.5, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 22),
        LayoutBuilder(
          builder: (context, c) {
            final columns = c.maxWidth >= 560 ? 4 : 2;
            final width = (c.maxWidth - 12 * (columns - 1)) / columns;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final p in purposes)
                  SizedBox(
                    width: width,
                    child: _PurposeCard(
                      purpose: p,
                      selected: identical(p, selected),
                      onTap: () => onPick(p),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _PurposeCard extends StatelessWidget {
  const _PurposeCard({
    required this.purpose,
    required this.selected,
    required this.onTap,
  });

  final Purpose purpose;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? AppColors.violet.withValues(alpha: .07)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected
                ? AppColors.violet
                : AppColors.violet.withValues(alpha: .14),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AssetIcon(purpose.icon, size: 40),
                const SizedBox(height: 12),
                Text(
                  purpose.label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  purpose.note,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepView extends StatelessWidget {
  const _StepView({
    required this.step,
    required this.answers,
    required this.onChanged,
    this.extras,
  });

  final OnboardingStep step;
  final Answers answers;
  final VoidCallback onChanged;

  /// Shown after the questions (the photo picker on the extras step).
  final Widget? extras;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(step.title, style: _display(28)),
        if (step.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            step.subtitle!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ],
        for (final q in step.questions)
          if (q.visible(answers)) ...[
            const SizedBox(height: 22),
            switch (q) {
              ChipQuestion() => _Chips(
                question: q,
                answers: answers,
                // The step title already asks a lone chip question.
                showLabel: step.questions.length > 1,
                onChanged: onChanged,
              ),
              TextQuestion() => _TextAnswer(
                question: q,
                answers: answers,
                onChanged: onChanged,
              ),
            },
          ],
        if (extras != null) ...[const SizedBox(height: 24), extras!],
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {required this.required});

  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (!required)
              const TextSpan(
                text: '  Optional',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8590AA),
                ),
              ),
          ],
        ),
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _Chips extends StatelessWidget {
  const _Chips({
    required this.question,
    required this.answers,
    required this.showLabel,
    required this.onChanged,
  });

  final ChipQuestion question;
  final Answers answers;
  final bool showLabel;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final q = question;
    final picked = answers.picked(q.id);
    void toggle(String option) {
      final next = [...picked];
      if (next.contains(option)) {
        next.remove(option);
      } else if (q.multi) {
        next.add(option);
      } else {
        next
          ..clear()
          ..add(option);
      }
      answers.picks[q.id] = next;
      onChanged();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) _FieldLabel(q.label, required: q.required),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in [...q.options, if (q.other) otherChip])
              _Pill(
                label: option,
                selected: picked.contains(option),
                onTap: () => toggle(option),
              ),
          ],
        ),
        if (picked.contains(otherChip)) ...[
          const SizedBox(height: 12),
          TextFormField(
            key: ValueKey('${q.id}.other'),
            initialValue: answers.texts['${q.id}.other'],
            autofocus: true,
            maxLength: 120,
            decoration: const InputDecoration(
              hintText: 'Tell us in your own words',
              counterText: '',
              isDense: true,
            ),
            onChanged: (v) {
              answers.texts['${q.id}.other'] = v;
              onChanged();
            },
          ),
        ],
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(99);
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.violet : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(
            color: selected
                ? AppColors.violet
                : AppColors.violet.withValues(alpha: .2),
          ),
        ),
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected) ...[
                  const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TextAnswer extends StatelessWidget {
  const _TextAnswer({
    required this.question,
    required this.answers,
    required this.onChanged,
  });

  final TextQuestion question;
  final Answers answers;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final q = question;
    final multiline = q.kind == InputKind.multiline;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(q.label, required: q.required),
        TextFormField(
          key: ValueKey(q.id),
          initialValue: answers.texts[q.id],
          minLines: multiline ? 3 : 1,
          maxLines: multiline ? 8 : 1,
          maxLength: multiline ? 3000 : 300,
          keyboardType: switch (q.kind) {
            InputKind.phone => TextInputType.phone,
            InputKind.email => TextInputType.emailAddress,
            InputKind.url => TextInputType.url,
            InputKind.multiline => TextInputType.multiline,
            InputKind.text => TextInputType.text,
          },
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (v) => invalidReason(q.kind, v ?? ''),
          decoration: InputDecoration(
            hintText: q.hint.isEmpty ? null : q.hint,
            counterText: '',
            isDense: true,
          ),
          onChanged: (v) {
            answers.texts[q.id] = v;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _PhotosRow extends StatelessWidget {
  const _PhotosRow({required this.photos, required this.onAdd});

  final ValueNotifier<List<ComposerPhoto>> photos;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: photos,
      builder: (context, list, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _FieldLabel('Logo and photos', required: false),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final photo in list)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    photo.bytes,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                  ),
                ),
              OutlinedButton.icon(
                onPressed: onAdd,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(44, 48),
                ),
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
                label: Text(list.isEmpty ? 'Add logo or photos' : 'Add more'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Review extends StatelessWidget {
  const _Review({
    required this.purpose,
    required this.steps,
    required this.answers,
    required this.photos,
    required this.onEdit,
  });

  final Purpose purpose;
  final List<OnboardingStep> steps;
  final Answers answers;
  final ValueNotifier<List<ComposerPhoto>> photos;

  /// Jumps back to step [index] of [steps].
  final ValueChanged<int> onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ready to build your page', style: _display(28)),
        const SizedBox(height: 8),
        const Text(
          "Here's what your page will use. Nothing else gets added, so check it's all right.",
          style: TextStyle(
            fontSize: 15,
            height: 1.45,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 18),
        for (final (i, step) in steps.indexed)
          if (step.questions.any((q) => answerText(q, answers).isNotEmpty))
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 14),
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: .04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.violet.withValues(alpha: .12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.violet,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => onEdit(i),
                        child: Text(
                          'Edit',
                          semanticsLabel: 'Edit ${step.title}',
                        ),
                      ),
                    ],
                  ),
                  for (final q in step.questions)
                    if (answerText(q, answers) case final value
                        when value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text.rich(
                          TextSpan(
                            text: '${q.label}  ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          style: const TextStyle(fontSize: 14, height: 1.45),
                        ),
                      ),
                ],
              ),
            ),
        ValueListenableBuilder(
          valueListenable: photos,
          builder: (context, list, _) => list.isEmpty
              ? const SizedBox.shrink()
              : Text(
                  list.length == 1 ? '+ 1 photo' : '+ ${list.length} photos',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
      ],
    );
  }
}
