import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n_ext.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';

/// Base tile layer (OpenStreetMap by default, configurable at build time).
class BaseTiles extends StatelessWidget {
  const BaseTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return TileLayer(
      urlTemplate: AppConfig.tileUrlTemplate,
      userAgentPackageName: AppConfig.userAgentPackage,
      maxNativeZoom: 19,
      tileDimension: 256,
    );
  }
}

/// Required map data attribution.
class MapAttribution extends StatelessWidget {
  const MapAttribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomStart,
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(color: const Color(0xCCFFFFFF), borderRadius: BorderRadius.circular(4)),
        child: const Text(
          AppConfig.tileAttribution,
          textDirection: TextDirection.ltr,
          style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}

/// Teardrop pin for a customer location.
class CustomerPin extends StatelessWidget {
  const CustomerPin({super.key, this.color = AppColors.navy, this.selected = false, this.label});
  final Color color;
  final bool selected;
  final String? label;

  static const size = Size(44, 52);

  @override
  Widget build(BuildContext context) {
    final scale = selected ? 1.15 : 1.0;
    return AnimatedScale(
      scale: scale,
      duration: Motion.fast,
      alignment: Alignment.bottomCenter,
      child: Stack(alignment: Alignment.topCenter, children: [
        Icon(Icons.location_on_rounded, size: 52, color: selected ? AppColors.blue : color, shadows: const [
          Shadow(color: Color(0x40000000), blurRadius: 6, offset: Offset(0, 2)),
        ]),
        Positioned(
          top: 11,
          child: Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: label == null
                ? Icon(Icons.storefront_rounded, size: 12, color: selected ? AppColors.blue : color)
                : Text(label!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
          ),
        ),
      ]),
    );
  }
}

Marker customerMarker(LatLng point, {Key? key, bool selected = false, Color color = AppColors.navy}) => Marker(
      key: key,
      point: point,
      width: CustomerPin.size.width,
      height: CustomerPin.size.height,
      alignment: Alignment.topCenter,
      child: CustomerPin(selected: selected, color: color),
    );

/// Pulsing blue dot for the user's position.
class MyLocationDot extends StatelessWidget {
  const MyLocationDot({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: AppColors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [BoxShadow(color: Color(0x552478E5), blurRadius: 12, spreadRadius: 4)],
      ),
    );
  }
}

/// Small static map used on the customer profile and in the form.
class MiniMapPreview extends StatelessWidget {
  const MiniMapPreview({super.key, required this.point, this.onTap, this.height = 170});
  final LatLng point;
  final VoidCallback? onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: Radii.field,
      child: SizedBox(
        height: height,
        child: Stack(children: [
          FlutterMap(
            key: ValueKey(point),
            options: MapOptions(
              initialCenter: point,
              initialZoom: 16,
              interactionOptions: const InteractionOptions(flags: InteractiveFlag.none),
            ),
            children: [
              const BaseTiles(),
              MarkerLayer(markers: [customerMarker(point)]),
            ],
          ),
          const MapAttribution(),
          if (onTap != null)
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap),
              ),
            ),
          if (onTap != null)
            PositionedDirectional(
              end: Space.xs,
              top: Space.xs,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: Radii.chip, boxShadow: Shadows.card),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.open_in_full_rounded, size: 14, color: AppColors.navy),
                  const SizedBox(width: 4),
                  Text(context.l10n.mapOpenFull,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.navy)),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Round floating map control button.
class MapControlButton extends StatelessWidget {
  const MapControlButton({super.key, required this.icon, required this.onPressed, required this.tooltip, this.busy = false});
  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 3,
      shadowColor: const Color(0x33123B70),
      child: IconButton(
        tooltip: tooltip,
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : Icon(icon, color: AppColors.navy),
      ),
    );
  }
}
