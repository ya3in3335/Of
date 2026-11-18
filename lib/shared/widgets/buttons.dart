import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Primary button that runs an async action and stays disabled until it
/// finishes, so a slow network can never cause a double submission.
class AsyncButton extends StatefulWidget {
  const AsyncButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = AsyncButtonStyle.filled,
    this.expand = true,
    this.color,
  });

  final String label;
  final Future<void> Function()? onPressed;
  final IconData? icon;
  final AsyncButtonStyle style;
  final bool expand;
  final Color? color;

  @override
  State<AsyncButton> createState() => _AsyncButtonState();
}

enum AsyncButtonStyle { filled, outlined, tonal }

class _AsyncButtonState extends State<AsyncButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy || widget.onPressed == null) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed!();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !_busy;
    final fg = widget.style == AsyncButtonStyle.filled ? Colors.white : (widget.color ?? AppColors.navy);
    final child = AnimatedSwitcher(
      duration: Motion.fast,
      child: _busy
          ? SizedBox(
              key: const ValueKey('busy'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[Icon(widget.icon, size: 20), const SizedBox(width: Space.xs)],
                Flexible(child: Text(widget.label, overflow: TextOverflow.ellipsis)),
              ],
            ),
    );

    final Widget button = switch (widget.style) {
      AsyncButtonStyle.filled => FilledButton(
          style: widget.color == null ? null : FilledButton.styleFrom(backgroundColor: widget.color),
          onPressed: enabled ? _run : (_busy ? () {} : null),
          child: child,
        ),
      AsyncButtonStyle.outlined => OutlinedButton(
          style: widget.color == null ? null : OutlinedButton.styleFrom(foregroundColor: widget.color),
          onPressed: enabled ? _run : (_busy ? () {} : null),
          child: child,
        ),
      AsyncButtonStyle.tonal => FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: (widget.color ?? AppColors.blue).withValues(alpha: 0.10),
            foregroundColor: widget.color ?? AppColors.blue,
            elevation: 0,
          ),
          onPressed: enabled ? _run : (_busy ? () {} : null),
          child: child,
        ),
    };
    return widget.expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Large square action used on the customer profile (Call, WhatsApp, Route).
class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final bg = filled ? color : color.withValues(alpha: 0.09);
    final fg = filled ? Colors.white : color;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: bg,
        borderRadius: Radii.field,
        child: InkWell(
          borderRadius: Radii.field,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.md, horizontal: Space.xs),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: fg, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
