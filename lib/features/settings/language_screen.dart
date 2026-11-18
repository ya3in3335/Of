import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/preferences.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../shared/widgets/common.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final current = ref.watch(preferencesProvider.select((p) => p.localeCode));
    final options = <(String?, String, String)>[
      (null, l10n.languageSystem, l10n.languageSystemHint),
      ('ar', 'العربية', 'Arabic'),
      ('fr', 'Français', 'French'),
      ('en', 'English', 'English'),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsLanguage)),
      body: ListView(
        padding: const EdgeInsets.all(Space.page),
        children: [
          SectionCard(
            padding: const EdgeInsets.symmetric(vertical: Space.xs, horizontal: Space.xs),
            child: Column(children: [
              for (final (code, label, hint) in options)
                ListTile(
                  title: Text(label),
                  subtitle: Text(hint),
                  trailing: current == code
                      ? const Icon(Icons.check_circle_rounded, color: AppColors.blue)
                      : const Icon(Icons.circle_outlined, color: AppColors.border),
                  onTap: () => ref.read(preferencesProvider.notifier).setLocale(code),
                ),
            ]),
          ),
          const SizedBox(height: Space.sm),
          Text(l10n.languageNote, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
