import 'package:material_ui/material_ui.dart';

import '../../../core/l10n_ext.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/customer.dart';
import '../../../domain/customer_search.dart';
import '../../../shared/widgets/common.dart';

/// Customer row used by the directory and search results. It always shows
/// the details that tell similar names apart: reference, phone and city.
class CustomerTile extends StatelessWidget {
  const CustomerTile({super.key, required this.customer, required this.onTap, this.matchKind});

  final Customer customer;
  final VoidCallback onTap;
  final MatchKind? matchKind;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
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
              InitialsAvatar(initials: customer.initials, seed: customer.id, muted: customer.isArchived),
              const SizedBox(width: Space.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            customer.fullName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.titleSmall?.copyWith(fontSize: 15),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ReferencePill(customer.reference),
                      ],
                    ),
                    if (customer.businessName != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        customer.businessName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall?.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                    const SizedBox(height: 5),
                    Wrap(
                      spacing: Space.sm,
                      runSpacing: 2,
                      children: [
                        _Meta(
                          icon: Icons.phone_rounded,
                          label: Formatters.phone(customer.primaryPhone),
                          ltr: true,
                          highlight: matchKind == MatchKind.phone,
                        ),
                        _Meta(icon: Icons.place_rounded, label: customer.cityLine),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Space.xs),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (customer.isArchived)
                    StatusChip(label: l10n.statusArchived, tone: ChipTone.neutral)
                  else if (!customer.hasLocation)
                    Tooltip(
                      message: l10n.customerNoLocationShort,
                      child: const Icon(Icons.location_off_rounded, size: 18, color: AppColors.warning),
                    )
                  else
                    const Icon(Icons.location_on_rounded, size: 18, color: AppColors.success),
                  const SizedBox(height: Space.xs),
                  Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label, this.ltr = false, this.highlight = false});
  final IconData icon;
  final String label;
  final bool ltr;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.blue : AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: highlight ? AppColors.blue : AppColors.textTertiary),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textDirection: ltr ? TextDirection.ltr : null,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: color, fontWeight: highlight ? FontWeight.w700 : FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
