import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/text_normalizer.dart';
import '../../data/models/profile.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/states.dart';
import '../../shared/widgets/glass_nav_bar.dart';

final employeesProvider = FutureProvider.autoDispose<List<Profile>>(
  (ref) => ref.read(employeeRepositoryProvider).list(),
);

class EmployeesScreen extends ConsumerStatefulWidget {
  const EmployeesScreen({super.key});

  @override
  ConsumerState<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends ConsumerState<EmployeesScreen> {
  final _search = TextEditingController();
  String _query = '';
  bool? _activeFilter;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final employees = ref.watch(employeesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navEmployees)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.sm),
            child: SearchField(
              controller: _search,
              hint: l10n.employeesSearchHint,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Space.page),
              children: [
                for (final (value, label) in [
                  (null, l10n.filterAll),
                  (true, l10n.statusActive),
                  (false, l10n.statusInactive),
                ])
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: Space.xs),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _activeFilter == value,
                      onSelected: (_) => setState(() => _activeFilter = value),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: Space.xs),
          Expanded(
            child: employees.when(
              loading: () => const ListSkeleton(),
              error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(employeesProvider)),
              data: (list) {
                final q = TextNormalizer.normalize(_query);
                final filtered = list.where((p) {
                  if (_activeFilter != null && p.isActive != _activeFilter) return false;
                  if (q.isEmpty) return true;
                  return TextNormalizer.normalize('${p.fullName} ${p.username}').contains(q);
                }).toList();
                if (list.isEmpty || filtered.isEmpty) {
                  return EmptyState(
                    icon: Icons.badge_outlined,
                    title: list.isEmpty ? l10n.employeesEmptyTitle : l10n.directoryNoMatchTitle,
                    message: list.isEmpty ? l10n.employeesEmptyBody : null,
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(employeesProvider),
                  child: ListView.separated(
                    padding: EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, navBarClearance(context, fab: true)),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: Space.xs),
                    itemBuilder: (context, i) => _EmployeeTile(
                      profile: filtered[i],
                      onTap: () async {
                        await context.push(Routes.employee(filtered[i].id));
                        ref.invalidate(employeesProvider);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EmployeeTile extends StatelessWidget {
  const _EmployeeTile({required this.profile, required this.onTap});
  final Profile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    return Material(
      color: AppColors.surface,
      borderRadius: Radii.card,
      child: InkWell(
        borderRadius: Radii.card,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: Radii.card,
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              InitialsAvatar(initials: profile.initials, seed: profile.id, muted: !profile.isActive),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(profile.fullName, style: text.titleSmall, overflow: TextOverflow.ellipsis),
                        ),
                        if (profile.isAdmin) ...[
                          const SizedBox(width: 6),
                          StatusChip(label: l10n.roleAdmin, tone: ChipTone.info),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('@${profile.username}', textDirection: TextDirection.ltr, style: text.bodySmall),
                    const SizedBox(height: 2),
                    Text(
                      profile.lastLoginAt == null
                          ? l10n.employeeNeverLoggedIn
                          : l10n.employeeLastLogin(Formatters.relative(context, profile.lastLoginAt!)),
                      style: text.bodySmall?.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: profile.isActive ? l10n.statusActive : l10n.statusInactive,
                tone: profile.isActive ? ChipTone.success : ChipTone.danger,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
