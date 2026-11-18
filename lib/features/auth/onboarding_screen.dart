import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/common.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => ref.read(preferencesProvider.notifier).completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pages = [
      _Page(icon: Icons.receipt_long_rounded, accent: Icons.search_rounded, title: l10n.onboarding1Title, body: l10n.onboarding1Body),
      _Page(icon: Icons.place_rounded, accent: Icons.navigation_rounded, title: l10n.onboarding2Title, body: l10n.onboarding2Body),
      _Page(icon: Icons.verified_user_rounded, accent: Icons.sync_rounded, title: l10n.onboarding3Title, body: l10n.onboarding3Body),
    ];
    final last = _page == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.xs, 0),
            child: Row(children: [
              const BrandLogo(size: 40),
              const SizedBox(width: Space.sm),
              Text('OUTIFOR', style: Theme.of(context).textTheme.titleMedium?.copyWith(letterSpacing: 1.2)),
              const Spacer(),
              _LanguageMenu(),
              if (!last) TextButton(onPressed: _finish, child: Text(l10n.actionSkip)),
            ]),
          ),
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              children: pages,
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            for (var i = 0; i < pages.length; i++)
              AnimatedContainer(
                duration: Motion.normal,
                curve: Motion.curve,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: i == _page ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.navy : AppColors.border,
                  borderRadius: Radii.chip,
                ),
              ),
          ]),
          Padding(
            padding: const EdgeInsets.all(Space.page),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: last
                    ? _finish
                    : () => _controller.nextPage(duration: Motion.slow, curve: Motion.curve),
                child: Text(last ? l10n.onboardingStart : l10n.actionNext),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({required this.icon, required this.accent, required this.title, required this.body});
  final IconData icon;
  final IconData accent;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.xxl),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        SizedBox(
          width: 220,
          height: 220,
          child: Stack(alignment: Alignment.center, children: [
            Container(
              decoration: const BoxDecoration(color: AppColors.infoSoft, shape: BoxShape.circle),
            ),
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                boxShadow: Shadows.floating,
              ),
              child: Icon(icon, size: 68, color: AppColors.navy),
            ),
            PositionedDirectional(
              end: 22,
              bottom: 30,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.surface, width: 4),
                ),
                child: Icon(accent, color: Colors.white, size: 26),
              ),
            ),
          ]),
        ),
        const SizedBox(height: Space.xxl),
        Text(title, style: text.headlineSmall, textAlign: TextAlign.center),
        const SizedBox(height: Space.sm),
        Text(body, style: text.bodyLarge?.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _LanguageMenu extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      tooltip: context.l10n.settingsLanguage,
      icon: const Icon(Icons.translate_rounded, color: AppColors.navy),
      onSelected: (code) => ref.read(preferencesProvider.notifier).setLocale(code),
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'ar', child: Text('العربية')),
        PopupMenuItem(value: 'fr', child: Text('Français')),
        PopupMenuItem(value: 'en', child: Text('English')),
      ],
    );
  }
}
