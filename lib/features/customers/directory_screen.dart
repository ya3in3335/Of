import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/customer.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_controller.dart';
import 'widgets/customer_tile.dart';

enum StatusFilter { active, archived, all }

enum SortOrder { name, newest, updated }

class DirectoryScreen extends ConsumerStatefulWidget {
  const DirectoryScreen({super.key});

  @override
  ConsumerState<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends ConsumerState<DirectoryScreen> {
  final _search = TextEditingController();
  String _query = '';
  StatusFilter _status = StatusFilter.active;
  bool _missingLocationOnly = false;
  String? _wilaya;
  SortOrder _sort = SortOrder.name;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<Customer> _apply(DirectoryState d) {
    Iterable<Customer> list;
    if (_query.trim().isNotEmpty) {
      list = d.engine.search(_query, includeArchived: true, limit: 500).map((h) => h.customer);
    } else {
      list = d.customers;
    }
    list = list.where(
      (c) => switch (_status) {
        StatusFilter.active => !c.isArchived,
        StatusFilter.archived => c.isArchived,
        StatusFilter.all => true,
      },
    );
    if (_missingLocationOnly) list = list.where((c) => !c.hasLocation);
    if (_wilaya != null) list = list.where((c) => c.wilaya == _wilaya);
    final result = list.toList();
    if (_query.trim().isEmpty) {
      switch (_sort) {
        case SortOrder.name:
          break; // already sorted by name
        case SortOrder.newest:
          result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        case SortOrder.updated:
          result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
    }
    return result;
  }

  Future<void> _pickWilaya(List<String> wilayas) async {
    final l10n = context.l10n;
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scroll) => ListView(
          controller: scroll,
          children: [
            ListTile(
              leading: const Icon(Icons.public_rounded),
              title: Text(l10n.filterAllWilayas),
              trailing: _wilaya == null ? const Icon(Icons.check_rounded, color: AppColors.blue) : null,
              onTap: () => Navigator.pop(context, ''),
            ),
            for (final w in wilayas)
              ListTile(
                title: Text(w),
                trailing: _wilaya == w ? const Icon(Icons.check_rounded, color: AppColors.blue) : null,
                onTap: () => Navigator.pop(context, w),
              ),
          ],
        ),
      ),
    );
    if (picked != null) setState(() => _wilaya = picked.isEmpty ? null : picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAdmin = ref.watch(authControllerProvider.select((s) => s.isAdmin));
    final directory = ref.watch(directoryProvider);
    final customers = _apply(directory);
    final wilayas = directory.customers.map((c) => c.wilaya).toSet().toList()..sort();
    final filtersActive = _missingLocationOnly || _wilaya != null || _status != StatusFilter.active;

    Widget body;
    if (!directory.loaded) {
      body = directory.error != null && directory.status != SyncStatus.syncing
          ? ErrorState(error: directory.error!, onRetry: () => ref.read(directoryProvider.notifier).sync())
          : const ListSkeleton();
    } else if (directory.customers.isEmpty) {
      body = EmptyState(
        icon: Icons.people_alt_outlined,
        title: l10n.directoryEmptyTitle,
        message: isAdmin ? l10n.directoryEmptyAdmin : l10n.directoryEmptyEmployee,
        actionLabel: isAdmin ? l10n.customerNew : null,
        onAction: isAdmin ? () => context.push(Routes.newCustomer) : null,
      );
    } else if (customers.isEmpty) {
      body = EmptyState(
        icon: Icons.filter_alt_off_rounded,
        title: l10n.directoryNoMatchTitle,
        message: l10n.directoryNoMatchBody,
        actionLabel: l10n.filterReset,
        onAction: () => setState(() {
          _search.clear();
          _query = '';
          _status = StatusFilter.active;
          _missingLocationOnly = false;
          _wilaya = null;
        }),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: () => ref.read(directoryProvider.notifier).sync(),
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, 110),
          itemCount: customers.length,
          separatorBuilder: (_, _) => const SizedBox(height: Space.xs),
          itemBuilder: (context, i) => CustomerTile(
            customer: customers[i],
            onTap: () {
              ref.read(recentCustomersProvider.notifier).touch(customers[i].id);
              context.push(Routes.customer(customers[i].id));
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navCustomers),
        actions: [
          if (isAdmin)
            IconButton(
              tooltip: l10n.duplicatesTitle,
              icon: const Icon(Icons.content_copy_rounded),
              onPressed: () => context.push(Routes.duplicates),
            ),
          const Padding(
            padding: EdgeInsetsDirectional.only(end: Space.md),
            child: SyncStatusBadge(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.sm),
            child: SearchField(
              controller: _search,
              hint: l10n.directoryFilterHint,
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Space.page),
              children: [
                if (isAdmin) ...[
                  for (final s in StatusFilter.values) ...[
                    ChoiceChip(
                      label: Text(switch (s) {
                        StatusFilter.active => l10n.statusActive,
                        StatusFilter.archived => l10n.statusArchivedPlural,
                        StatusFilter.all => l10n.filterAll,
                      }),
                      selected: _status == s,
                      onSelected: (_) => setState(() => _status = s),
                    ),
                    const SizedBox(width: Space.xs),
                  ],
                ],
                FilterChip(
                  avatar: Icon(
                    Icons.location_off_rounded,
                    size: 16,
                    color: _missingLocationOnly ? Colors.white : AppColors.warning,
                  ),
                  label: Text(l10n.filterNoLocation),
                  selected: _missingLocationOnly,
                  showCheckmark: false,
                  onSelected: (v) => setState(() => _missingLocationOnly = v),
                ),
                const SizedBox(width: Space.xs),
                ActionChip(
                  avatar: Icon(
                    Icons.place_outlined,
                    size: 16,
                    color: _wilaya != null ? AppColors.blue : AppColors.textSecondary,
                  ),
                  label: Text(_wilaya ?? l10n.filterWilaya),
                  onPressed: () => _pickWilaya(wilayas),
                ),
                const SizedBox(width: Space.xs),
                PopupMenuButton<SortOrder>(
                  tooltip: l10n.sortTitle,
                  initialValue: _sort,
                  onSelected: (s) => setState(() => _sort = s),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: SortOrder.name, child: Text(l10n.sortName)),
                    PopupMenuItem(value: SortOrder.newest, child: Text(l10n.sortNewest)),
                    PopupMenuItem(value: SortOrder.updated, child: Text(l10n.sortUpdated)),
                  ],
                  child: Chip(
                    avatar: const Icon(Icons.sort_rounded, size: 16, color: AppColors.textSecondary),
                    label: Text(switch (_sort) {
                      SortOrder.name => l10n.sortName,
                      SortOrder.newest => l10n.sortNewest,
                      SortOrder.updated => l10n.sortUpdated,
                    }),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, Space.xs),
            child: Row(
              children: [
                Text(l10n.directoryCount(customers.length), style: Theme.of(context).textTheme.labelMedium),
                const Spacer(),
                if (filtersActive)
                  TextButton(
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    onPressed: () => setState(() {
                      _status = StatusFilter.active;
                      _missingLocationOnly = false;
                      _wilaya = null;
                    }),
                    child: Text(l10n.filterReset),
                  ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(duration: Motion.normal, child: body),
          ),
        ],
      ),
    );
  }
}
