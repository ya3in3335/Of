import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../domain/directory_controller.dart';

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.initials, required this.seed, this.size = 44, this.muted = false});

  final String initials;
  final String seed;
  final double size;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = muted
        ? AppColors.textTertiary
        : AppColors.avatarPalette[seed.codeUnits.fold<int>(0, (a, b) => (a * 31 + b) & 0x7fffffff) %
              AppColors.avatarPalette.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
      child: Text(
        initials.isEmpty ? '?' : initials,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: size * 0.36, height: 1),
      ),
    );
  }
}

enum ChipTone { success, neutral, warning, danger, info }

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.tone, this.icon});
  final String label;
  final ChipTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (tone) {
      ChipTone.success => (AppColors.successSoft, AppColors.success),
      ChipTone.neutral => (AppColors.surfaceMuted, AppColors.textSecondary),
      ChipTone.warning => (AppColors.warningSoft, AppColors.warning),
      ChipTone.danger => (AppColors.errorSoft, AppColors.error),
      ChipTone.info => (AppColors.infoSoft, AppColors.blue),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: Radii.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: 4)],
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Monospaced customer reference pill (OUT-000125).
class ReferencePill extends StatelessWidget {
  const ReferencePill(this.reference, {super.key});
  final String reference;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(6)),
      child: Text(
        reference,
        textDirection: TextDirection.ltr,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: AppColors.navy, fontFeatures: const [FontFeature.tabularFigures()], letterSpacing: 0.3),
      ),
    );
  }
}

/// White rounded card with an optional header.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, this.title, this.trailing, required this.child, this.padding});
  final String? title;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppDecorations.card(),
      padding: padding ?? const EdgeInsets.all(Space.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!.toUpperCase(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: context.isArabic ? 0 : 0.8),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: Space.sm),
          ],
          child,
        ],
      ),
    );
  }
}

/// Icon + label + value row, with an optional trailing action (copy).
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
    this.valueDirection,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;
  final TextDirection? valueDirection;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: Radii.field,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: Space.xs),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(Radii.sm)),
              child: Icon(icon, size: 19, color: AppColors.navy),
            ),
            const SizedBox(width: Space.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: text.bodySmall),
                  const SizedBox(height: 1),
                  Text(value, style: text.titleSmall, textDirection: valueDirection),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Shows the directory sync status: synced at HH:MM, syncing, offline, error.
class SyncStatusBadge extends ConsumerWidget {
  const SyncStatusBadge({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final status = ref.watch(directoryProvider.select((s) => s.status));
    final last = ref.watch(directoryProvider.select((s) => s.lastSyncedAt));
    final (icon, color, label) = switch (status) {
      SyncStatus.syncing => (Icons.sync_rounded, AppColors.blue, l10n.syncSyncing),
      SyncStatus.offline => (
        Icons.cloud_off_rounded,
        AppColors.warning,
        last == null ? l10n.syncOfflineNoData : l10n.syncOffline(Formatters.time(context, last)),
      ),
      SyncStatus.error => (Icons.sync_problem_rounded, AppColors.error, l10n.syncError),
      SyncStatus.idle => (
        Icons.cloud_done_rounded,
        AppColors.success,
        last == null ? l10n.syncNever : l10n.syncDone(Formatters.time(context, last)),
      ),
    };
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: Radii.chip,
        onTap: onTap ?? () => ref.read(directoryProvider.notifier).sync(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: Radii.chip),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              status == SyncStatus.syncing
                  ? SizedBox(width: 13, height: 13, child: CircularProgressIndicator(strokeWidth: 2, color: color))
                  : Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The OutiFor logo image (brand asset).
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 120});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.22),
      child: Image.asset('assets/brand/outifor_logo.png', width: size, height: size, fit: BoxFit.cover),
    );
  }
}

/// A large rounded search field.
class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
    required this.controller,
    required this.hint,
    this.onChanged,
    this.autofocus = false,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
  });

  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: Radii.field, boxShadow: Shadows.card),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        autocorrect: false,
        enableSuggestions: false,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.navy),
          suffixIcon: controller == null
              ? null
              : ListenableBuilder(
                  listenable: controller!,
                  builder: (context, _) => controller!.text.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                          tooltip: context.l10n.actionClear,
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            controller!.clear();
                            onChanged?.call('');
                          },
                        ),
                ),
          enabledBorder: const OutlineInputBorder(borderRadius: Radii.field, borderSide: BorderSide.none),
          border: const OutlineInputBorder(borderRadius: Radii.field, borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: Space.md, vertical: 16),
        ),
      ),
    );
  }
}
