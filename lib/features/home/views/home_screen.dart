import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/dialog_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/aurora_background.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/hero_scene.dart';
import '../../../core/widgets/phone_preview.dart';
import '../../../core/widgets/live_qr_logo.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../../pages/repositories/pages_repository.dart';
import '../../pages/view_models/page_draft_view_model.dart';
import '../../pages/views/page_draft_screen.dart';
import '../models/live_page.dart';
import '../view_models/home_view_model.dart';
import 'widgets/pages_shelf.dart';
import 'widgets/prompt_composer.dart';

/// Starter text a page-type shortcut puts in the composer.
const _starters = {
  PageType.business: 'A business page for ',
  PageType.menu: 'A restaurant menu for ',
  PageType.card: 'A digital business card for ',
  PageType.event: 'An event page for ',
};

// Same limits as the backend (src/routes/ai.js).
const _maxPhotos = 6;
const _maxLinks = 5;

// ponytail: placeholder address until pages are published by the backend.
const _sampleQrData = 'https://liveqr.example/p/daily-brew';

class HomeScreen extends HookConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the backend user record in sync (GET /v1/me upserts it).
    ref.watch(backendProfileProvider);
    final user = ref.watch(authUserProvider).value;
    final pages = ref.watch(myPagesProvider);
    final firstVisit = pages.isEmpty;

    final prompt = useTextEditingController();
    final promptFocus = useFocusNode();
    final scroll = useScrollController();
    final pagesKey = useMemoized(GlobalKey.new);
    final dialog = ref.read(dialogServiceProvider.notifier);

    final name = _firstName(user?.displayName, user?.email);
    void comingSoon(String what) => dialog.showInfo('$what is coming soon.');
    void start(PageType type) {
      prompt.text = _starters[type]!;
      prompt.selection = TextSelection.collapsed(offset: prompt.text.length);
      promptFocus.requestFocus();
    }

    final photos = useState<List<ComposerPhoto>>(const []);
    final links = useState<List<String>>(const []);

    Future<void> addPhotos() async {
      final room = _maxPhotos - photos.value.length;
      if (room <= 0) {
        dialog.showInfo('You can add up to $_maxPhotos photos.');
        return;
      }
      final picked = (await ImagePicker().pickMultiImage(
        limit: room,
      )).take(room).toList();
      if (picked.isEmpty || !context.mounted) return;

      final added = [
        for (final file in picked) ComposerPhoto(await file.readAsBytes()),
      ];
      photos.value = [...photos.value, ...added];

      final repo = ref.read(pagesRepositoryProvider);
      await Future.wait([
        for (final (i, photo) in added.indexed)
          repo
              .uploadPhoto(picked[i])
              .then((id) => photo.id = id)
              .catchError((Object e) {
                photos.value = [...photos.value]..remove(photo);
                dialog.showError(
                  e is DioException
                      ? (e.message ?? 'Upload failed')
                      : 'Upload failed',
                );
                return '';
              })
              // Repaint so the thumbnail drops its spinner.
              .whenComplete(() => photos.value = [...photos.value]),
      ]);
    }

    Future<void> addLink() async {
      if (links.value.length >= _maxLinks) {
        dialog.showInfo('You can add up to $_maxLinks links.');
        return;
      }
      final link = await askForLink(context);
      if (link != null && !links.value.contains(link)) {
        links.value = [...links.value, link];
      }
    }

    void create() {
      if (prompt.text.trim().isEmpty) {
        promptFocus.requestFocus();
        return;
      }
      if (prompt.text.trim().length > PromptComposer.maxLength) {
        dialog.showInfo(
          'Please shorten your description to ${PromptComposer.maxLength} characters.',
        );
        return;
      }
      if (photos.value.any((p) => p.id == null)) {
        dialog.showInfo('Wait a moment, your photos are still uploading.');
        return;
      }
      final request = PageRequest(
        prompt.text.trim(),
        photoIds: [for (final p in photos.value) p.id!],
        links: links.value,
      );
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => PageDraftScreen(request: request),
        ),
      );
    }

    void showPages() {
      final target = pagesKey.currentContext;
      if (target == null) return;
      Scrollable.ensureVisible(
        target,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }

    final featured = pages.where((p) => p.isLive).firstOrNull;
    final scene = HeroScene(
      screen: featured != null ? previewFor(featured) : const MenuPagePreview(),
      qrData: _sampleQrData,
      qrLabel: featured != null ? '${featured.title} · Live' : 'Scan to open',
      badge: featured == null ? 'EXAMPLE' : null,
      toasts: featured == null
          ? const []
          : [
              const SceneToast(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PulseDot(),
                    SizedBox(width: 10),
                    Text('Someone just scanned'),
                  ],
                ),
              ),
              SceneToast(child: ScanFigure(count: featured.scansThisWeek)),
            ],
    );

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Hello(text: firstVisit ? 'Welcome, $name' : '${_greeting()}, $name'),
        const SizedBox(height: 26),
        _Headline(
          firstVisit ? 'One sentence.' : 'What will people',
          firstVisit ? 'One live page.' : 'scan next?',
        ),
        const SizedBox(height: 26),
        PromptComposer(
          controller: prompt,
          focusNode: promptFocus,
          hint: firstVisit
              ? 'e.g. A bakery in Jodhpur with cakes, timings and a call button'
              : 'Describe a business, a menu, an event…',
          onSubmit: create,
          photos: photos.value,
          links: links.value,
          onAddPhotos: addPhotos,
          onAddLink: addLink,
          onRemovePhoto: (photo) =>
              photos.value = [...photos.value]..remove(photo),
          onRemoveLink: (link) => links.value = [...links.value]..remove(link),
        ),
        const SizedBox(height: 26),
        if (firstVisit) const _Steps() else _TypeChips(onPick: start),
      ],
    );

    return Scaffold(
      backgroundColor: AppColors.sky,
      body: AuroraBackground(
        child: SingleChildScrollView(
          controller: scroll,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(context).width < 720 ? 16 : 48,
            vertical: 20,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NavBar(
                    email: user?.email,
                    initials: _initials(user?.displayName, user?.email),
                    onPages: showPages,
                    onAnalytics: () => comingSoon('Analytics'),
                  ),
                  LayoutBuilder(
                    builder: (context, c) => c.maxWidth >= 1000
                        ? Row(
                            children: [
                              Expanded(flex: 21, child: copy),
                              const SizedBox(width: 24),
                              Expanded(flex: 20, child: scene),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 40),
                              copy,
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight: 560,
                                ),
                                child: Center(child: scene),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 32),
                  KeyedSubtree(
                    key: pagesKey,
                    child: firstVisit
                        ? _TypeTiles(onPick: start)
                        : _PagesSection(
                            pages: pages,
                            onOpen: (_) => comingSoon('The page editor'),
                            onNew: () => promptFocus.requestFocus(),
                          ),
                  ),
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _firstName(String? displayName, String? email) {
  final name = displayName?.trim();
  if (name != null && name.isNotEmpty) return name.split(RegExp(r'\s+')).first;
  final local = email?.split('@').first ?? '';
  return local.isEmpty ? 'there' : local[0].toUpperCase() + local.substring(1);
}

String _initials(String? displayName, String? email) {
  final source = (displayName?.trim().isNotEmpty ?? false)
      ? displayName!.trim()
      : (email ?? '?');
  final parts = source
      .split(RegExp(r'[\s@._-]+'))
      .where((p) => p.isNotEmpty)
      .toList();
  return parts.take(2).map((p) => p[0].toUpperCase()).join();
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class _NavBar extends HookConsumerWidget {
  const _NavBar({
    required this.email,
    required this.initials,
    required this.onPages,
    required this.onAnalytics,
  });

  final String? email;
  final String initials;
  final VoidCallback onPages;
  final VoidCallback onAnalytics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 720;

    Future<void> signOut() async {
      final confirmed = await ref
          .read(dialogServiceProvider.notifier)
          .showConfirmation(
            title: 'Sign out?',
            message: 'You will need to sign in again.',
            confirmText: 'Sign out',
          );
      if (confirmed) await ref.read(authViewModelProvider.notifier).signOut();
    }

    Widget tab(String label, VoidCallback? onTap, {bool current = false}) =>
        Semantics(
          selected: current,
          child: TextButton(
            onPressed: onTap ?? () {},
            style: TextButton.styleFrom(
              foregroundColor: current
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
              backgroundColor: current ? Colors.white : Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: TextStyle(
                fontSize: 14,
                fontWeight: current ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            child: Text(label),
          ),
        );

    return GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
      child: Row(
        children: [
          const LiveQrLogo(size: 36),
          if (wide) ...[
            const SizedBox(width: 20),
            tab('Home', null, current: true),
            tab('My pages', onPages),
            tab('Analytics', onAnalytics),
          ],
          const Spacer(),
          PopupMenuButton<void>(
            tooltip: 'Account menu',
            offset: const Offset(0, 54),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            itemBuilder: (_) => [
              if (email != null)
                PopupMenuItem(
                  enabled: false,
                  child: Text(
                    email!,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                ),
              PopupMenuItem(
                onTap: signOut,
                child: const Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Sign out'),
                  ],
                ),
              ),
            ],
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const SweepGradient(
                  colors: [
                    Color(0xFF3B82F6),
                    AppColors.violet,
                    AppColors.magenta,
                    Color(0xFF3B82F6),
                  ],
                ),
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: .5),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                    spreadRadius: -6,
                  ),
                ],
              ),
              child: Text(
                initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Hello extends StatelessWidget {
  const _Hello({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: 99,
      padding: const EdgeInsets.fromLTRB(10, 8, 14, 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF22C55E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22C55E).withValues(alpha: .2),
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline(this.first, this.second);

  final String first;
  final String second;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final style = TextStyle(
      fontFamily: AppTheme.displayFont,
      fontWeight: FontWeight.w700,
      fontSize: (width * .064).clamp(40.0, 92.0),
      height: .95,
      letterSpacing: -.045 * (width * .064).clamp(40.0, 92.0),
      color: AppColors.textPrimary,
    );
    return Semantics(
      header: true,
      label: '$first $second',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(first, style: style),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: AppColors.brandGradient.createShader,
            child: Text(second, style: style),
          ),
        ],
      ),
    );
  }
}

class _TypeChips extends StatelessWidget {
  const _TypeChips({required this.onPick});

  final ValueChanged<PageType> onPick;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final t in _types)
          Semantics(
            button: true,
            label: 'Start a ${t.title}',
            excludeSemantics: true,
            child: GestureDetector(
              onTap: () => onPick(t.type),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GlassPanel(
                  radius: 99,
                  padding: const EdgeInsets.fromLTRB(5, 5, 16, 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/optimized/${t.icon}.png',
                        width: 34,
                        height: 34,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        t.short,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

const _types = [
  (
    type: PageType.business,
    title: 'Business page',
    short: 'Business',
    note: 'Shop, salon, studio',
    icon: 'Blue-Storefront-App-Icon',
    tint: Color(0xFF3B82F6),
  ),
  (
    type: PageType.menu,
    title: 'Restaurant menu',
    short: 'Menu',
    note: 'Café, kitchen, bakery',
    icon: 'Minimal-Coral-Cutlery-Icon',
    tint: Color(0xFFF43F5E),
  ),
  (
    type: PageType.card,
    title: 'Business card',
    short: 'Card',
    note: 'You, in one scan',
    icon: 'Pastel-Purple-Profile-Card-Icon',
    tint: Color(0xFFA855F7),
  ),
  (
    type: PageType.event,
    title: 'Event',
    short: 'Event',
    note: 'Invites and RSVPs',
    icon: 'Minimalist-Pink-Calendar-App-Icon',
    tint: Color(0xFFEC4899),
  ),
];

class _Steps extends StatelessWidget {
  const _Steps();

  @override
  Widget build(BuildContext context) {
    Widget step(String icon, String label) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/optimized/$icon.png', width: 30, height: 30),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
    final link = Container(
      width: 26,
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.violet.withValues(alpha: .35),
    );
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      runSpacing: 10,
      children: [
        step('glossy-pastel-magic-sparkles-icon', 'Describe'),
        link,
        step('glossy-blue-qr-code-app-icon', 'Get your QR'),
        link,
        step('glossy-orange-analytics-app-icon', 'Watch the scans'),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
    header: true,
    child: Text(
      text,
      style: TextStyle(
        fontFamily: AppTheme.displayFont,
        fontSize: (MediaQuery.sizeOf(context).width * .036).clamp(30.0, 48.0),
        fontWeight: FontWeight.w700,
        letterSpacing: -1.6,
        height: 1,
      ),
    ),
  );
}

class _PagesSection extends StatelessWidget {
  const _PagesSection({
    required this.pages,
    required this.onOpen,
    required this.onNew,
  });

  final List<LivePage> pages;
  final ValueChanged<LivePage> onOpen;
  final VoidCallback onNew;

  @override
  Widget build(BuildContext context) {
    final scans = pages.fold(0, (sum, p) => sum + p.scansThisWeek);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.end,
          runSpacing: 16,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle('Your pages'),
                SizedBox(height: 8),
                Text(
                  'Tap a page to edit it. Your QR codes never change.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            GlassPanel(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$scans',
                    style: const TextStyle(
                      fontFamily: AppTheme.displayFont,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'scans\nlast 7 days',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 56),
        PagesShelf(pages: pages, onOpen: onOpen, onNew: onNew),
      ],
    );
  }
}

class _TypeTiles extends StatelessWidget {
  const _TypeTiles({required this.onPick});

  final ValueChanged<PageType> onPick;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1000 ? 4 : 2;
    final compact = width < 720;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle('Or pick a starting point'),
        const SizedBox(height: 40),
        GridView.count(
          crossAxisCount: columns,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: compact ? 12 : 20,
          crossAxisSpacing: compact ? 12 : 20,
          childAspectRatio: compact ? 1 : 1.17,
          children: [
            for (final t in _types)
              _TypeTile(type: t, compact: compact, onTap: () => onPick(t.type)),
          ],
        ),
      ],
    );
  }
}

class _TypeTile extends StatefulWidget {
  const _TypeTile({
    required this.type,
    required this.compact,
    required this.onTap,
  });

  final ({
    PageType type,
    String title,
    String short,
    String note,
    String icon,
    Color tint,
  })
  type;
  final bool compact;
  final VoidCallback onTap;

  @override
  State<_TypeTile> createState() => _TypeTileState();
}

class _TypeTileState extends State<_TypeTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.type;
    return Semantics(
      button: true,
      label: 'Start a ${t.title}',
      excludeSemantics: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedSlide(
            offset: Offset(0, _hover ? -.03 : 0),
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: GlassPanel(
              radius: 30,
              opacity: .7,
              child: Stack(
                children: [
                  Positioned(
                    right: -80,
                    top: -80,
                    child: Container(
                      width: 240,
                      height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            t.tint.withValues(alpha: .28),
                            t.tint.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(widget.compact ? 18 : 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/images/optimized/${t.icon}.png',
                          width: widget.compact ? 60 : 84,
                          height: widget.compact ? 60 : 84,
                        ),
                        const Spacer(),
                        Text(
                          t.title,
                          style: TextStyle(
                            fontFamily: AppTheme.displayFont,
                            fontSize: widget.compact ? 18 : 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -.6,
                          ),
                        ),
                        if (!widget.compact) ...[
                          const SizedBox(height: 6),
                          Text(
                            t.note,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!widget.compact)
                    Positioned(
                      right: 22,
                      bottom: 22,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
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
