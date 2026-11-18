import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../data/models/customer.dart';
import '../../domain/directory_controller.dart';
import '../../shared/widgets/common.dart';
import '../auth/auth_controller.dart';
import '../customers/customer_actions.dart';
import '../settings/app_settings_controller.dart';
import 'customer_location_screen.dart';
import 'map_widgets.dart';

/// All customers with a GPS point, clustered. Customers without coordinates
/// are counted, never placed at a guessed position.
class MapOverviewScreen extends ConsumerStatefulWidget {
  const MapOverviewScreen({super.key});

  @override
  ConsumerState<MapOverviewScreen> createState() => _MapOverviewScreenState();
}

class _MapOverviewScreenState extends ConsumerState<MapOverviewScreen> {
  final _map = MapController();
  Customer? _selected;
  LatLng? _me;
  bool _locating = false;
  bool _fitted = false;

  void _fitAll(List<Customer> located) {
    if (located.isEmpty) return;
    if (located.length == 1) {
      _map.move(located.first.point!, 15);
      return;
    }
    _map.fitCamera(
      CameraFit.coordinates(
        coordinates: located.map((c) => c.point!).toList(),
        padding: const EdgeInsets.all(56),
        maxZoom: 15,
      ),
    );
  }

  Future<void> _locateMe() async {
    setState(() => _locating = true);
    final result = await ref.read(locationServiceProvider).currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (result.point == null) {
      showLocationFailure(context, ref, result.failure!);
      return;
    }
    setState(() => _me = result.point);
    _map.move(result.point!, 14);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAdmin = ref.watch(authControllerProvider.select((s) => s.isAdmin));
    final customers = ref.watch(directoryProvider.select((s) => s.customers));
    final settings = ref.watch(appSettingsProvider).value;
    final active = customers.where((c) => !c.isArchived).toList();
    final located = active.where((c) => c.hasLocation).toList();
    final missing = active.length - located.length;
    final selected = _selected == null ? null : ref.watch(customerByIdProvider(_selected!.id));

    final center = settings == null
        ? const LatLng(36.7538, 3.0588)
        : LatLng(settings.defaultLatitude, settings.defaultLongitude);

    // Height of the floating navigation bar (extendBody shell).
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: center,
              initialZoom: settings?.defaultZoom ?? 11,
              minZoom: 4,
              maxZoom: 19,
              onTap: (_, _) => setState(() => _selected = null),
              onMapReady: () {
                if (!_fitted && located.isNotEmpty) {
                  _fitted = true;
                  _fitAll(located);
                }
              },
            ),
            children: [
              const BaseTiles(),
              MarkerClusterLayerWidget(
                options: MarkerClusterLayerOptions(
                  maxClusterRadius: 60,
                  size: const Size(46, 46),
                  padding: const EdgeInsets.all(60),
                  markers: [
                    for (final c in located)
                      customerMarker(c.point!, key: ValueKey(c.id), selected: c.id == selected?.id),
                  ],
                  onMarkerTap: (marker) {
                    final id = (marker.key as ValueKey<String>?)?.value;
                    final c = id == null ? null : ref.read(customerByIdProvider(id));
                    if (c != null) setState(() => _selected = c);
                  },
                  builder: (context, markers) => Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.navy,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: Shadows.card,
                    ),
                    child: Text(
                      '${markers.length}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              if (_me != null)
                MarkerLayer(
                  markers: [Marker(point: _me!, width: 26, height: 26, child: const MyLocationDot())],
                ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 0),
              child: Column(
                children: [
                  SearchField(
                    controller: null,
                    readOnly: true,
                    hint: l10n.searchHint,
                    onTap: () => context.push(Routes.search),
                  ),
                  const SizedBox(height: Space.xs),
                  Row(
                    children: [
                      _Pill(
                        icon: Icons.location_on_rounded,
                        color: AppColors.success,
                        label: l10n.mapLocatedCount(located.length),
                      ),
                      const SizedBox(width: Space.xs),
                      if (missing > 0)
                        _Pill(
                          icon: Icons.location_off_rounded,
                          color: AppColors.warning,
                          label: l10n.mapMissingCount(missing),
                          onTap: isAdmin ? () => context.go(Routes.customers) : null,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            end: Space.md,
            bottom: (selected != null ? 190 : Space.md) + bottomInset,
            child: Column(
              children: [
                MapControlButton(
                  icon: Icons.my_location_rounded,
                  tooltip: l10n.mapMyLocation,
                  busy: _locating,
                  onPressed: _locateMe,
                ),
                const SizedBox(height: Space.xs),
                MapControlButton(
                  icon: Icons.zoom_out_map_rounded,
                  tooltip: l10n.mapShowAll,
                  onPressed: located.isEmpty ? null : () => _fitAll(located),
                ),
              ],
            ),
          ),
          if (located.isEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.all(Space.xxl),
                padding: const EdgeInsets.all(Space.lg),
                decoration: BoxDecoration(color: Colors.white, borderRadius: Radii.card, boxShadow: Shadows.floating),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_outlined, size: 36, color: AppColors.blue),
                    const SizedBox(height: Space.xs),
                    Text(
                      l10n.mapEmptyTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAdmin ? l10n.mapEmptyAdmin : l10n.mapEmptyEmployee,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          Positioned(bottom: bottomInset, left: 0, child: const MapAttribution()),
          AnimatedPositioned(
            duration: Motion.normal,
            curve: Motion.curve,
            left: Space.md,
            right: Space.md,
            bottom: selected != null ? Space.md + bottomInset : -220,
            child: selected == null ? const SizedBox.shrink() : _SelectedCard(customer: selected),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.color, required this.label, this.onTap});
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: Radii.chip,
      elevation: 2,
      shadowColor: const Color(0x22123B70),
      child: InkWell(
        borderRadius: Radii.chip,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedCard extends ConsumerWidget {
  const _SelectedCard({required this.customer});
  final Customer customer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final actions = CustomerActions(ref, context);
    return Container(
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(color: Colors.white, borderRadius: Radii.card, boxShadow: Shadows.floating),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(initials: customer.initials, seed: customer.id, size: 40),
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
                    Text(
                      '${customer.address}, ${customer.commune}',
                      style: text.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Space.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46)),
                  onPressed: () {
                    ref.read(recentCustomersProvider.notifier).touch(customer.id);
                    context.push(Routes.customer(customer.id));
                  },
                  child: Text(l10n.actionViewProfile),
                ),
              ),
              const SizedBox(width: Space.xs),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 46)),
                  onPressed: () => actions.navigate(customer),
                  icon: const Icon(Icons.navigation_rounded, size: 18),
                  label: Text(l10n.actionNavigate),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
