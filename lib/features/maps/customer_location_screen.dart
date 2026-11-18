import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/services/geo_services.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/feedback.dart';
import '../../shared/widgets/states.dart';
import '../customers/customer_actions.dart';
import 'map_widgets.dart';

/// Full-screen map of one customer, with the employee's own position (on
/// request) and the distance to the customer.
class CustomerLocationScreen extends ConsumerStatefulWidget {
  const CustomerLocationScreen({super.key, required this.customerId});
  final String customerId;

  @override
  ConsumerState<CustomerLocationScreen> createState() => _CustomerLocationScreenState();
}

class _CustomerLocationScreenState extends ConsumerState<CustomerLocationScreen> {
  final _map = MapController();
  LatLng? _me;
  bool _locating = false;

  Future<void> _locateMe(LatLng customer) async {
    setState(() => _locating = true);
    final result = await ref.read(locationServiceProvider).currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (result.point == null) {
      showLocationFailure(context, ref, result.failure!);
      return;
    }
    setState(() => _me = result.point);
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: [customer, result.point!],
        padding: const EdgeInsets.fromLTRB(60, 120, 60, 260),
        maxZoom: 17,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final customer = ref.watch(customerByIdProvider(widget.customerId));
    if (customer == null || !customer.hasLocation) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.location_off_rounded,
          title: l10n.customerNoLocationTitle,
          message: l10n.customerNoLocationEmployee,
          actionLabel: l10n.actionBack,
          onAction: () => context.pop(),
        ),
      );
    }
    final point = customer.point!;
    final actions = CustomerActions(ref, context);
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(initialCenter: point, initialZoom: 16, minZoom: 4, maxZoom: 19),
            children: [
              const BaseTiles(),
              MarkerLayer(
                markers: [
                  customerMarker(point, selected: true),
                  if (_me != null) Marker(point: _me!, width: 26, height: 26, child: const MyLocationDot()),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Row(
                children: [
                  MapControlButton(
                    icon: Directionality.of(context) == TextDirection.rtl
                        ? Icons.arrow_forward_rounded
                        : Icons.arrow_back_rounded,
                    tooltip: l10n.actionBack,
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                  MapControlButton(
                    icon: Icons.my_location_rounded,
                    tooltip: l10n.mapMyLocation,
                    busy: _locating,
                    onPressed: () => _locateMe(point),
                  ),
                  const SizedBox(width: Space.xs),
                  MapControlButton(
                    icon: Icons.center_focus_strong_rounded,
                    tooltip: l10n.mapRecenter,
                    onPressed: () => _map.move(point, 16),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: Space.md,
            right: Space.md,
            bottom: Space.md,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(Space.md),
                decoration: BoxDecoration(color: Colors.white, borderRadius: Radii.card, boxShadow: Shadows.floating),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(customer.fullName, style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      '${customer.address}, ${customer.commune}, ${customer.wilaya}',
                      style: text.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_me != null) ...[
                      const SizedBox(height: Space.xs),
                      Row(
                        children: [
                          const Icon(Icons.straighten_rounded, size: 16, color: AppColors.blue),
                          const SizedBox(width: 4),
                          Text(
                            l10n.mapDistanceAway(
                              Formatters.distance(context, LocationService.distanceMeters(_me!, point)),
                            ),
                            style: text.labelMedium?.copyWith(color: AppColors.blue),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: Space.sm),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () => actions.navigate(customer),
                            icon: const Icon(Icons.navigation_rounded),
                            label: Text(l10n.actionStartNavigation),
                          ),
                        ),
                        const SizedBox(width: Space.xs),
                        IconButton.outlined(
                          tooltip: l10n.actionCall,
                          style: IconButton.styleFrom(minimumSize: const Size(52, 52)),
                          onPressed: () => actions.call(customer),
                          icon: const Icon(Icons.call_rounded, color: AppColors.navy),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Positioned(bottom: 0, left: 0, child: SafeArea(child: MapAttribution())),
        ],
      ),
    );
  }
}

/// Explains why the position could not be read, with a shortcut to settings.
void showLocationFailure(BuildContext context, WidgetRef ref, LocationFailure failure) {
  final l10n = context.l10n;
  final message = switch (failure) {
    LocationFailure.serviceDisabled => l10n.locationServiceDisabled,
    LocationFailure.denied => l10n.locationDenied,
    LocationFailure.deniedForever => l10n.locationDeniedForever,
    LocationFailure.timeout => l10n.locationTimeout,
  };
  if (failure == LocationFailure.deniedForever) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          action: SnackBarAction(
            label: l10n.actionOpenSettings,
            onPressed: () => ref.read(locationServiceProvider).openSettings(),
          ),
        ),
      );
  } else {
    showToast(context, message, kind: ToastKind.error);
  }
}
