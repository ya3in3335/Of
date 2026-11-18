import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/customer.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/states.dart';

final duplicatePairsProvider = FutureProvider.autoDispose<List<DuplicatePair>>(
  (ref) => ref.read(customerRepositoryProvider).listDuplicatePairs(),
);

/// Potential duplicates found by the server (same phone or very similar
/// name). Records are never merged automatically: the admin opens both,
/// then archives/deletes one, or marks the pair as "not a duplicate".
class DuplicatesScreen extends ConsumerWidget {
  const DuplicatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final pairs = ref.watch(duplicatePairsProvider);
    final byId = ref.watch(directoryProvider.select((s) => s.byId));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.duplicatesTitle)),
      body: pairs.when(
        loading: () => const ListSkeleton(rows: 4),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(duplicatePairsProvider)),
        data: (list) {
          final visible = list.where((p) => byId[p.customerA] != null && byId[p.customerB] != null).toList();
          if (visible.isEmpty) {
            return EmptyState(
              icon: Icons.verified_rounded,
              title: l10n.duplicatesNoneTitle,
              message: l10n.duplicatesNoneBody,
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(duplicatePairsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.all(Space.page),
              itemCount: visible.length + 1,
              separatorBuilder: (_, _) => const SizedBox(height: Space.md),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Text(l10n.duplicatesIntro, style: Theme.of(context).textTheme.bodySmall);
                }
                final p = visible[i - 1];
                return _PairCard(pair: p, a: byId[p.customerA]!, b: byId[p.customerB]!);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PairCard extends ConsumerWidget {
  const _PairCard({required this.pair, required this.a, required this.b});
  final DuplicatePair pair;
  final Customer a;
  final Customer b;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: AppDecorations.card(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              StatusChip(
                label: pair.reason == 'phone' ? l10n.duplicateSamePhone : l10n.duplicateSimilarName,
                tone: pair.reason == 'phone' ? ChipTone.danger : ChipTone.warning,
                icon: pair.reason == 'phone' ? Icons.phone_rounded : Icons.badge_outlined,
              ),
              const Spacer(),
              Text(l10n.duplicateScore((pair.score * 100).round()), style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
          const SizedBox(height: Space.sm),
          _Side(customer: a),
          const Divider(height: Space.lg),
          _Side(customer: b),
          const SizedBox(height: Space.sm),
          AsyncButton(
            style: AsyncButtonStyle.outlined,
            icon: Icons.do_not_disturb_on_outlined,
            label: l10n.duplicatesDismiss,
            onPressed: () async {
              try {
                await ref.read(customerRepositoryProvider).dismissDuplicatePair(a.id, b.id);
                ref.invalidate(duplicatePairsProvider);
                if (context.mounted) showToast(context, l10n.duplicatesDismissed, kind: ToastKind.success);
              } catch (e) {
                if (context.mounted) showErrorToast(context, e);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _Side extends StatelessWidget {
  const _Side({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: Radii.field,
      onTap: () => context.push(Routes.customer(customer.id)),
      child: Row(
        children: [
          InitialsAvatar(initials: customer.initials, seed: customer.id, size: 38, muted: customer.isArchived),
          const SizedBox(width: Space.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(customer.fullName, style: text.titleSmall, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    ReferencePill(customer.reference),
                  ],
                ),
                Text('${Formatters.phone(customer.primaryPhone)} · ${customer.cityLine}', style: text.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
