import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/l10n_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';

/// Illustrated empty state: icon badge, title, explanation, optional action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: Space.xxl, vertical: compact ? Space.lg : Space.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 64 : 84,
              height: compact ? 64 : 84,
              decoration: const BoxDecoration(color: AppColors.infoSoft, shape: BoxShape.circle),
              child: Icon(icon, size: compact ? 30 : 38, color: AppColors.blue),
            ),
            const SizedBox(height: Space.lg),
            Text(title, style: text.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: Space.xs),
              Text(
                message!,
                style: text.bodyMedium?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Space.lg),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry action and a message matching the error type.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.error, this.onRetry, this.compact = false});

  final Object error;
  final VoidCallback? onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final e = AppException.from(error);
    final offline = e.kind == AppErrorKind.offline || e.kind == AppErrorKind.timeout;
    return EmptyState(
      compact: compact,
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: offline ? context.l10n.stateOfflineTitle : context.l10n.stateErrorTitle,
      message: errorMessage(context, error),
      actionLabel: onRetry == null ? null : context.l10n.actionRetry,
      onAction: onRetry,
    );
  }
}

/// Animated placeholder shown while content loads.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 14, this.radius = 8});
  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(color: const Color(0xFFE6ECF4), borderRadius: BorderRadius.circular(widget.radius)),
      ),
    );
  }
}

/// Skeleton list matching the customer/employee list rows.
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key, this.rows = 7});
  final int rows;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.sm),
      itemCount: rows,
      separatorBuilder: (_, _) => const SizedBox(height: Space.sm),
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(Space.md),
        decoration: AppDecorations.card(),
        child: Row(
          children: [
            const Skeleton(width: 44, height: 44, radius: 22),
            const SizedBox(width: Space.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 120.0 + (i % 3) * 40, height: 14),
                  const SizedBox(height: Space.xs),
                  const Skeleton(width: 160, height: 11),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin banner shown at the top of screens while the device is offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.warningSoft,
      padding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.xs),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_rounded, size: 18, color: AppColors.warning),
          const SizedBox(width: Space.xs),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF8A5A0C)),
            ),
          ),
        ],
      ),
    );
  }
}
