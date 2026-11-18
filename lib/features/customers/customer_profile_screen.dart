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
import '../../data/repositories/customer_repository.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/buttons.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/states.dart';
import '../auth/auth_controller.dart';
import '../maps/map_widgets.dart';
import 'customer_actions.dart';

/// Admin-only notes, fetched on demand (RLS returns nothing to employees).
final adminNotesProvider = FutureProvider.autoDispose.family<String?, String>(
  (ref, id) => ref.read(customerRepositoryProvider).fetchAdminNotes(id),
);

class CustomerProfileScreen extends ConsumerStatefulWidget {
  const CustomerProfileScreen({super.key, required this.customerId});
  final String customerId;

  @override
  ConsumerState<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends ConsumerState<CustomerProfileScreen> {
  @override
  void initState() {
    super.initState();
    if (!ref.read(authControllerProvider).isAdmin) {
      ref.read(customerRepositoryProvider).logAction(CustomerAction.viewed, widget.customerId);
    }
  }

  Future<void> _toggleArchive(Customer c) async {
    final l10n = context.l10n;
    final archiving = !c.isArchived;
    final ok = await showConfirmDialog(
      context,
      icon: archiving ? Icons.archive_outlined : Icons.unarchive_outlined,
      title: archiving ? l10n.customerArchiveTitle : l10n.customerRestoreTitle,
      message: archiving ? l10n.customerArchiveBody(c.fullName) : l10n.customerRestoreBody(c.fullName),
      confirmLabel: archiving ? l10n.actionArchive : l10n.actionRestore,
    );
    if (!ok || !mounted) return;
    try {
      final updated = await ref
          .read(customerRepositoryProvider)
          .setStatus(c.id, archiving ? CustomerStatus.archived : CustomerStatus.active);
      ref.read(directoryProvider.notifier).applyServerRow(updated);
      if (mounted) {
        showToast(context, archiving ? l10n.customerArchived : l10n.customerRestored, kind: ToastKind.success);
      }
    } catch (e) {
      if (mounted) showErrorToast(context, e);
    }
  }

  Future<void> _delete(Customer c) async {
    final l10n = context.l10n;
    final ok = await showConfirmDialog(
      context,
      icon: Icons.delete_forever_rounded,
      destructive: true,
      title: l10n.customerDeleteTitle,
      message: l10n.customerDeleteBody(c.fullName, c.reference),
      confirmLabel: l10n.actionDelete,
    );
    if (!ok || !mounted) return;
    try {
      await ref.read(customerRepositoryProvider).delete(c.id);
      ref.read(directoryProvider.notifier).applyServerDeletion(c.id);
      if (mounted) {
        showToast(context, l10n.customerDeleted, kind: ToastKind.success);
        context.pop();
      }
    } catch (e) {
      if (mounted) showErrorToast(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final customer = ref.watch(customerByIdProvider(widget.customerId));
    final loaded = ref.watch(directoryProvider.select((s) => s.loaded));
    final isAdmin = ref.watch(authControllerProvider.select((s) => s.isAdmin));

    if (customer == null) {
      return Scaffold(
        appBar: AppBar(),
        body: loaded
            ? EmptyState(
                icon: Icons.person_off_outlined,
                title: l10n.customerNotFoundTitle,
                message: l10n.customerNotFoundBody,
                actionLabel: l10n.actionBack,
                onAction: () => context.pop(),
              )
            : const ListSkeleton(rows: 3),
      );
    }

    final actions = CustomerActions(ref, context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customerProfileTitle),
        actions: [
          if (isAdmin) ...[
            IconButton(
              tooltip: l10n.actionEdit,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => context.push(Routes.editCustomer(customer.id)),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'archive') _toggleArchive(customer);
                if (v == 'delete') _delete(customer);
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'archive',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(customer.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined),
                    title: Text(customer.isArchived ? l10n.actionRestore : l10n.actionArchive),
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    title: Text(l10n.actionDelete, style: const TextStyle(color: AppColors.error)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(Space.page, Space.xs, Space.page, Space.xxl),
        children: [
          // Identity
          Container(
            padding: const EdgeInsets.all(Space.lg),
            decoration: AppDecorations.card(),
            child: Column(
              children: [
                InitialsAvatar(initials: customer.initials, seed: customer.id, size: 68, muted: customer.isArchived),
                const SizedBox(height: Space.sm),
                Text(customer.fullName, style: text.headlineSmall, textAlign: TextAlign.center),
                if (customer.businessName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    customer.businessName!,
                    style: text.bodyMedium?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: Space.sm),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: Space.xs,
                  runSpacing: Space.xs,
                  children: [
                    ReferencePill(customer.reference),
                    if (customer.isArchived)
                      StatusChip(label: l10n.statusArchived, tone: ChipTone.neutral, icon: Icons.archive_outlined)
                    else
                      StatusChip(label: l10n.statusActive, tone: ChipTone.success),
                    StatusChip(label: customer.cityLine, tone: ChipTone.info, icon: Icons.place_rounded),
                  ],
                ),
                const SizedBox(height: Space.lg),
                Row(
                  children: [
                    Expanded(
                      child: ActionTile(
                        icon: Icons.call_rounded,
                        label: l10n.actionCall,
                        color: AppColors.navy,
                        filled: true,
                        onTap: () => actions.call(customer),
                      ),
                    ),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: ActionTile(
                        icon: Icons.chat_rounded,
                        label: l10n.actionWhatsapp,
                        color: AppColors.whatsapp,
                        onTap: customer.whatsappPhone == null ? null : () => actions.whatsapp(customer),
                      ),
                    ),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: ActionTile(
                        icon: Icons.navigation_rounded,
                        label: l10n.actionNavigate,
                        color: AppColors.blue,
                        onTap: customer.hasLocation ? () => actions.navigate(customer) : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Space.xs),
                Row(
                  children: [
                    Expanded(
                      child: _SmallAction(
                        icon: Icons.copy_rounded,
                        label: l10n.actionCopyPhone,
                        onTap: () => actions.copy(customer.primaryPhone, l10n.copiedPhone),
                      ),
                    ),
                    const SizedBox(width: Space.xs),
                    Expanded(
                      child: _SmallAction(
                        icon: Icons.tag_rounded,
                        label: l10n.actionCopyReference,
                        onTap: () => actions.copy(customer.reference, l10n.copiedReference),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Space.md),

          // Location
          SectionCard(
            title: l10n.customerLocation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InfoRow(
                  icon: Icons.location_city_rounded,
                  label: l10n.fieldWilayaCommune,
                  value: '${customer.commune} — ${customer.wilaya}',
                ),
                InfoRow(
                  icon: Icons.signpost_outlined,
                  label: l10n.fieldAddress,
                  value: customer.address,
                  trailing: IconButton(
                    tooltip: l10n.actionCopy,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    onPressed: () => actions.copy(
                      '${customer.address}, ${customer.commune}, ${customer.wilaya}',
                      l10n.copiedAddress,
                    ),
                  ),
                ),
                const SizedBox(height: Space.sm),
                if (customer.hasLocation) ...[
                  MiniMapPreview(
                    point: customer.point!,
                    onTap: () => context.push(Routes.customerLocation(customer.id)),
                  ),
                  const SizedBox(height: Space.sm),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.coordinates(customer.latitude!, customer.longitude!),
                          textDirection: TextDirection.ltr,
                          style: text.bodySmall,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            ref.read(launcherProvider).showLocation(customer.latitude!, customer.longitude!),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: Text(l10n.actionOpenInMaps),
                      ),
                    ],
                  ),
                ] else
                  _NoLocation(customer: customer, isAdmin: isAdmin, actions: actions),
              ],
            ),
          ),
          const SizedBox(height: Space.md),

          // Contact
          SectionCard(
            title: l10n.customerContact,
            child: Column(
              children: [
                _PhoneRow(
                  label: l10n.fieldPrimaryPhone,
                  phone: customer.primaryPhone,
                  onCall: () => actions.call(customer),
                  onCopy: () => actions.copy(customer.primaryPhone, l10n.copiedPhone),
                ),
                if (customer.secondaryPhone != null)
                  _PhoneRow(
                    label: l10n.fieldSecondaryPhone,
                    phone: customer.secondaryPhone!,
                    onCall: () => actions.call(customer, customer.secondaryPhone),
                    onCopy: () => actions.copy(customer.secondaryPhone!, l10n.copiedPhone),
                  ),
                if (customer.whatsappPhone != null)
                  _PhoneRow(
                    label: l10n.fieldWhatsappPhone,
                    phone: customer.whatsappPhone!,
                    icon: Icons.chat_rounded,
                    iconColor: AppColors.whatsapp,
                    onCall: () => actions.whatsapp(customer),
                    onCopy: () => actions.copy(customer.whatsappPhone!, l10n.copiedPhone),
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(top: Space.xs),
                    child: Text(l10n.customerNoWhatsapp, style: text.bodySmall),
                  ),
              ],
            ),
          ),

          if (customer.addresses.isNotEmpty) ...[
            const SizedBox(height: Space.md),
            SectionCard(
              title: l10n.customerOtherAddresses,
              child: Column(
                children: [
                  for (final a in customer.addresses)
                    InfoRow(
                      icon: Icons.storefront_outlined,
                      label: a.label,
                      value: [a.address, a.commune, a.wilaya].whereType<String>().where((s) => s.isNotEmpty).join(', '),
                      trailing: IconButton(
                        tooltip: l10n.actionNavigate,
                        icon: Icon(
                          Icons.navigation_rounded,
                          color: a.hasLocation ? AppColors.blue : AppColors.textTertiary,
                          size: 20,
                        ),
                        onPressed: () => actions.navigate(customer, address: a),
                      ),
                    ),
                ],
              ),
            ),
          ],

          if (isAdmin) ...[const SizedBox(height: Space.md), _AdminNotes(customerId: customer.id)],

          const SizedBox(height: Space.md),
          SectionCard(
            title: l10n.customerRecord,
            child: Column(
              children: [
                InfoRow(
                  icon: Icons.event_available_outlined,
                  label: l10n.fieldCreatedAt,
                  value: Formatters.dateTime(context, customer.createdAt),
                ),
                InfoRow(
                  icon: Icons.update_rounded,
                  label: l10n.fieldUpdatedAt,
                  value: Formatters.relative(context, customer.updatedAt),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallAction extends StatelessWidget {
  const _SmallAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 42),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 17),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _PhoneRow extends StatelessWidget {
  const _PhoneRow({
    required this.label,
    required this.phone,
    required this.onCall,
    required this.onCopy,
    this.icon = Icons.call_rounded,
    this.iconColor = AppColors.navy,
  });
  final String label;
  final String phone;
  final VoidCallback onCall;
  final VoidCallback onCopy;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InfoRow(
      icon: icon,
      label: label,
      value: Formatters.phone(phone),
      valueDirection: TextDirection.ltr,
      onTap: onCall,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: context.l10n.actionCopy,
            icon: const Icon(Icons.copy_rounded, size: 18),
            onPressed: onCopy,
          ),
          IconButton(
            tooltip: label,
            icon: Icon(icon, size: 20, color: iconColor),
            onPressed: onCall,
          ),
        ],
      ),
    );
  }
}

class _NoLocation extends StatelessWidget {
  const _NoLocation({required this.customer, required this.isAdmin, required this.actions});
  final Customer customer;
  final bool isAdmin;
  final CustomerActions actions;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(color: AppColors.warningSoft, borderRadius: Radii.field),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_off_rounded, color: AppColors.warning),
              const SizedBox(width: Space.xs),
              Expanded(child: Text(l10n.customerNoLocationTitle, style: Theme.of(context).textTheme.titleSmall)),
            ],
          ),
          const SizedBox(height: Space.xxs),
          Text(
            isAdmin ? l10n.customerNoLocationAdmin : l10n.customerNoLocationEmployee,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Space.sm),
          Wrap(
            spacing: Space.xs,
            runSpacing: Space.xs,
            children: [
              OutlinedButton.icon(
                onPressed: () => actions.navigate(customer),
                icon: const Icon(Icons.search_rounded, size: 18),
                label: Text(l10n.actionSearchAddressInMaps),
              ),
              if (isAdmin)
                FilledButton.icon(
                  onPressed: () => context.push(Routes.editCustomer(customer.id)),
                  icon: const Icon(Icons.add_location_alt_rounded, size: 18),
                  label: Text(l10n.actionSetLocation),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminNotes extends ConsumerWidget {
  const _AdminNotes({required this.customerId});
  final String customerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final notes = ref.watch(adminNotesProvider(customerId));
    return SectionCard(
      title: l10n.fieldAdminNotes,
      trailing: Tooltip(
        message: l10n.adminNotesHint,
        child: const Icon(Icons.lock_outline_rounded, size: 16, color: AppColors.textTertiary),
      ),
      child: notes.when(
        loading: () => const Skeleton(height: 14, width: 180),
        error: (e, _) => Row(
          children: [
            Expanded(child: Text(errorMessage(context, e), style: Theme.of(context).textTheme.bodySmall)),
            TextButton(onPressed: () => ref.invalidate(adminNotesProvider(customerId)), child: Text(l10n.actionRetry)),
          ],
        ),
        data: (value) => Text(
          value ?? l10n.adminNotesEmpty,
          style: value == null ? Theme.of(context).textTheme.bodySmall : Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
