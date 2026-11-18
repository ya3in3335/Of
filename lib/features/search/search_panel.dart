import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/customer.dart';
import '../../domain/customer_search.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/states.dart';
import '../customers/widgets/customer_tile.dart';
import '../../shared/widgets/glass_nav_bar.dart';

/// Search-as-you-type over the device copy of the directory. Results update on
/// every keystroke without a network round trip. When several customers
/// match, all are listed with their reference, phone and city; nothing is
/// opened automatically.
class SearchPanel extends ConsumerStatefulWidget {
  const SearchPanel({
    super.key,
    required this.header,
    required this.idle,
    this.autofocus = false,
    this.includeArchived = false,
  });

  /// Content above the search field (title, greeting).
  final Widget header;

  /// Content shown while the query is empty.
  final Widget idle;
  final bool autofocus;
  final bool includeArchived;

  @override
  ConsumerState<SearchPanel> createState() => _SearchPanelState();
}

class _SearchPanelState extends ConsumerState<SearchPanel> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _open(String id) {
    _focus.unfocus();
    ref.read(recentCustomersProvider.notifier).touch(id);
    context.push(Routes.customer(id));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final directory = ref.watch(directoryProvider);
    final hits = _query.trim().isEmpty
        ? const <SearchHit>[]
        : directory.engine.search(_query, includeArchived: widget.includeArchived);

    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [
        SliverToBoxAdapter(child: widget.header),
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedField(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.sm),
              child: SearchField(
                controller: _controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                hint: l10n.searchHint,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
          ),
        ),
        if (_query.trim().isEmpty)
          SliverToBoxAdapter(child: widget.idle)
        else if (!directory.loaded)
          const SliverFillRemaining(hasScrollBody: false, child: ListSkeleton(rows: 4))
        else if (hits.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.person_search_rounded,
              title: l10n.searchNoResultsTitle,
              message: directory.status == SyncStatus.offline
                  ? '${l10n.searchNoResultsBody}\n${l10n.searchOfflineNote}'
                  : l10n.searchNoResultsBody,
            ),
          )
        else ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.xs),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.searchResultsCount(hits.length), style: Theme.of(context).textTheme.labelMedium),
                  if (hits.length > 1) ...[
                    const SizedBox(height: Space.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: Space.sm, vertical: Space.xs),
                      decoration: BoxDecoration(color: AppColors.infoSoft, borderRadius: Radii.field),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.blue),
                          const SizedBox(width: Space.xs),
                          Expanded(
                            child: Text(
                              l10n.searchMultipleHint,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.navy),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, navBarClearance(context)),
            sliver: SliverList.separated(
              itemCount: hits.length,
              separatorBuilder: (_, _) => const SizedBox(height: Space.xs),
              itemBuilder: (context, i) => CustomerTile(
                customer: hits[i].customer,
                matchKind: hits[i].kind,
                onTap: () => _open(hits[i].customer.id),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PinnedField extends SliverPersistentHeaderDelegate {
  _PinnedField({required this.child});
  final Widget child;

  @override
  double get minExtent => 78;
  @override
  double get maxExtent => 78;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(
    child: ColoredBox(
      color: AppColors.background,
      child: Align(alignment: Alignment.topCenter, child: child),
    ),
  );

  @override
  bool shouldRebuild(_PinnedField oldDelegate) => oldDelegate.child != child;
}

/// Short list of recently opened customers (from this device).
class RecentCustomers extends ConsumerWidget {
  const RecentCustomers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(recentCustomersProvider);
    final byId = ref.watch(directoryProvider.select((s) => s.byId));
    final customers = ids.map((id) => byId[id]).whereType<Customer>().take(6).toList();
    if (customers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(context.l10n.searchRecent, style: Theme.of(context).textTheme.titleSmall)),
              TextButton(
                onPressed: () => ref.read(recentCustomersProvider.notifier).clear(),
                child: Text(context.l10n.actionClear),
              ),
            ],
          ),
          for (final c in customers) ...[
            CustomerTile(
              customer: c,
              onTap: () {
                ref.read(recentCustomersProvider.notifier).touch(c.id);
                context.push(Routes.customer(c.id));
              },
            ),
            const SizedBox(height: Space.xs),
          ],
        ],
      ),
    );
  }
}

/// Search tips shown before the user types.
class SearchTips extends StatelessWidget {
  const SearchTips({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    Widget tip(IconData icon, String title, String example) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.blue),
          const SizedBox(width: Space.sm),
          Expanded(child: Text(title, style: text.bodyMedium)),
          Text(
            example,
            textDirection: TextDirection.ltr,
            style: text.bodySmall?.copyWith(color: AppColors.textTertiary),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, 0),
      child: SectionCard(
        title: l10n.searchTipsTitle,
        child: Column(
          children: [
            tip(Icons.receipt_long_rounded, l10n.searchTipName, 'Benali M'),
            tip(Icons.tag_rounded, l10n.searchTipReference, 'OUT-000125'),
            tip(Icons.phone_rounded, l10n.searchTipPhone, '0555 12'),
          ],
        ),
      ),
    );
  }
}
