import 'dart:async';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/l10n_ext.dart';
import '../../core/providers.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/validators.dart';
import '../../data/services/geo_services.dart';
import '../../shared/widgets/feedback.dart';
import '../settings/app_settings_controller.dart';
import 'customer_location_screen.dart';
import 'map_widgets.dart';

/// Result of the picker: the chosen point and, when it came from an address
/// search, the commune/wilaya suggested by the geocoder.
class PickedLocation {
  const PickedLocation(this.point, {this.commune, this.wilaya});
  final LatLng point;
  final String? commune;
  final String? wilaya;
}

/// Admin tool to place a customer exactly: the map moves under a fixed pin.
/// Tap the map, search an address, use the phone's GPS or type coordinates.
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key, this.initial, this.addressHint});
  final LatLng? initial;
  final String? addressHint;

  static Future<PickedLocation?> open(BuildContext context, {LatLng? initial, String? addressHint}) =>
      Navigator.of(context).push<PickedLocation>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => LocationPickerScreen(initial: initial, addressHint: addressHint),
      ));

  @override
  ConsumerState<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _map = MapController();
  final _search = TextEditingController();
  Timer? _debounce;
  late LatLng _center;
  bool _moved = false;
  bool _locating = false;
  bool _searching = false;
  List<GeocodingResult> _results = const [];
  String? _searchError;
  GeocodingResult? _fromSearch;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(appSettingsProvider).value;
    _center = widget.initial ??
        (settings == null ? const LatLng(36.7538, 3.0588) : LatLng(settings.defaultLatitude, settings.defaultLongitude));
    _moved = widget.initial != null;
    if (widget.addressHint != null && widget.initial == null) _search.text = widget.addressHint!;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _onQuery(String q) {
    _debounce?.cancel();
    if (q.trim().length < 3) {
      setState(() {
        _results = const [];
        _searchError = null;
      });
      return;
    }
    // Nominatim usage policy: at most one request per second.
    _debounce = Timer(const Duration(milliseconds: 900), () => _runSearch(q));
  }

  Future<void> _runSearch(String q) async {
    setState(() {
      _searching = true;
      _searchError = null;
    });
    try {
      final results = await ref.read(geocodingProvider).search(q, language: context.languageCode);
      if (!mounted) return;
      setState(() {
        _results = results;
        _searchError = results.isEmpty ? context.l10n.pickerNoAddressFound : null;
      });
    } catch (_) {
      if (mounted) setState(() => _searchError = context.l10n.pickerSearchFailed);
    } finally {
      if (mounted) setState(() => _searching = false);
    }
  }

  void _goTo(LatLng p, {double zoom = 17}) {
    _map.move(p, zoom);
    setState(() {
      _center = p;
      _moved = true;
    });
  }

  Future<void> _useMyLocation() async {
    setState(() => _locating = true);
    final result = await ref.read(locationServiceProvider).currentPosition();
    if (!mounted) return;
    setState(() => _locating = false);
    if (result.point == null) {
      showLocationFailure(context, ref, result.failure!);
      return;
    }
    _fromSearch = null;
    _goTo(result.point!, zoom: 18);
  }

  Future<void> _manualEntry() async {
    final l10n = context.l10n;
    final lat = TextEditingController(text: _moved ? _center.latitude.toStringAsFixed(6) : '');
    final lng = TextEditingController(text: _moved ? _center.longitude.toStringAsFixed(6) : '');
    final formKey = GlobalKey<FormState>();
    final point = await showDialog<LatLng>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pickerManualTitle),
        content: Form(
          key: formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(l10n.pickerManualHint, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: Space.md),
            TextFormField(
              controller: lat,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.fieldLatitude, hintText: '36.753800'),
              validator: (v) => fieldErrorText(context, Validators.coordinate(v, min: -90, max: 90)),
            ),
            const SizedBox(height: Space.sm),
            TextFormField(
              controller: lng,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              textDirection: TextDirection.ltr,
              decoration: InputDecoration(labelText: l10n.fieldLongitude, hintText: '3.058800'),
              validator: (v) => fieldErrorText(context, Validators.coordinate(v, min: -180, max: 180)),
            ),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.actionCancel)),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                context,
                LatLng(double.parse(lat.text.trim().replaceAll(',', '.')),
                    double.parse(lng.text.trim().replaceAll(',', '.'))),
              );
            },
            child: Text(l10n.actionApply),
          ),
        ],
      ),
    );
    lat.dispose();
    lng.dispose();
    if (point != null) {
      _fromSearch = null;
      _goTo(point);
    }
  }

  Future<void> _confirm() async {
    final l10n = context.l10n;
    if (!_moved) {
      showToast(context, l10n.pickerMoveFirst, kind: ToastKind.info);
      return;
    }
    // Preview before saving: zoom in on the exact point and ask for confirmation.
    _map.move(_center, 18);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.page),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(l10n.pickerConfirmTitle, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Space.xs),
            Text(l10n.pickerConfirmBody, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: Space.md),
            MiniMapPreview(point: _center, height: 180),
            const SizedBox(height: Space.xs),
            Text(Formatters.coordinates(_center.latitude, _center.longitude),
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: Space.md),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.pickerUseThisLocation)),
            const SizedBox(height: Space.xs),
            OutlinedButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.pickerAdjust)),
          ]),
        ),
      ),
    );
    if (ok == true && mounted) {
      Navigator.of(context).pop(PickedLocation(_center, commune: _fromSearch?.commune, wilaya: _fromSearch?.wilaya));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final settings = ref.watch(appSettingsProvider).value;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.pickerTitle)),
      body: Stack(children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: _center,
            initialZoom: widget.initial != null ? 17 : (settings?.defaultZoom ?? 12),
            minZoom: 4,
            maxZoom: 19,
            onPositionChanged: (camera, hasGesture) {
              if (hasGesture) {
                setState(() {
                  _center = camera.center;
                  _moved = true;
                  _fromSearch = null;
                });
              }
            },
            onTap: (_, p) {
              FocusScope.of(context).unfocus();
              _fromSearch = null;
              _goTo(p, zoom: _map.camera.zoom < 16 ? 17 : _map.camera.zoom);
            },
          ),
          children: const [BaseTiles()],
        ),
        // Fixed pin at the centre of the map.
        IgnorePointer(
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, -24),
              child: CustomerPin(selected: _moved),
            ),
          ),
        ),
        IgnorePointer(
          child: Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
            ),
          ),
        ),
        Positioned(
          top: Space.sm,
          left: Space.md,
          right: Space.md,
          child: Column(children: [
            Material(
              elevation: 3,
              shadowColor: const Color(0x33123B70),
              borderRadius: Radii.field,
              child: TextField(
                controller: _search,
                onChanged: _onQuery,
                textInputAction: TextInputAction.search,
                onSubmitted: _runSearch,
                decoration: InputDecoration(
                  hintText: l10n.pickerSearchHint,
                  prefixIcon: const Icon(Icons.travel_explore_rounded),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(14),
                          child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                        )
                      : null,
                  enabledBorder: const OutlineInputBorder(borderRadius: Radii.field, borderSide: BorderSide.none),
                ),
              ),
            ),
            if (_results.isNotEmpty || _searchError != null)
              Container(
                margin: const EdgeInsets.only(top: Space.xs),
                constraints: const BoxConstraints(maxHeight: 260),
                decoration: BoxDecoration(color: Colors.white, borderRadius: Radii.field, boxShadow: Shadows.floating),
                child: _searchError != null
                    ? Padding(
                        padding: const EdgeInsets.all(Space.md),
                        child: Text(_searchError!, style: text.bodySmall),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.zero,
                        itemCount: _results.length,
                        separatorBuilder: (_, _) => const Divider(),
                        itemBuilder: (context, i) => ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text(_results[i].label, maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            final r = _results[i];
                            setState(() => _results = const []);
                            _goTo(r.point);
                            _fromSearch = r;
                          },
                        ),
                      ),
              ),
          ]),
        ),
        PositionedDirectional(
          end: Space.md,
          bottom: 190,
          child: Column(children: [
            MapControlButton(
              icon: Icons.my_location_rounded,
              tooltip: l10n.pickerUseMyLocation,
              busy: _locating,
              onPressed: _useMyLocation,
            ),
            const SizedBox(height: Space.xs),
            MapControlButton(icon: Icons.pin_outlined, tooltip: l10n.pickerManualTitle, onPressed: _manualEntry),
          ]),
        ),
        const Positioned(bottom: 170, left: 0, child: MapAttribution()),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(Space.page, Space.md, Space.page, Space.md),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.xl)),
              boxShadow: Shadows.floating,
            ),
            child: SafeArea(
              top: false,
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Icon(_moved ? Icons.gps_fixed_rounded : Icons.pan_tool_alt_outlined,
                      color: _moved ? AppColors.success : AppColors.textTertiary, size: 20),
                  const SizedBox(width: Space.xs),
                  Expanded(
                    child: Text(
                      _moved ? Formatters.coordinates(_center.latitude, _center.longitude) : l10n.pickerInstructions,
                      textDirection: _moved ? TextDirection.ltr : null,
                      style: _moved ? text.titleSmall : text.bodySmall,
                    ),
                  ),
                ]),
                const SizedBox(height: Space.md),
                FilledButton.icon(
                  onPressed: _confirm,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(l10n.pickerConfirm),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}
