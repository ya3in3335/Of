import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../core/config/app_config.dart';

class GeocodingResult {
  const GeocodingResult({required this.label, required this.point, this.commune, this.wilaya});
  final String label;
  final LatLng point;
  final String? commune;
  final String? wilaya;
}

/// Address search through a Nominatim-compatible API. Only the text typed by
/// the admin is sent; no customer identity leaves the app.
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<GeocodingResult>> search(String query, {String language = 'fr'}) async {
    final text = query.trim();
    if (text.length < 3) return const [];
    final uri = Uri.parse('${AppConfig.geocodingUrl}/search').replace(
      queryParameters: {
        'q': text,
        'format': 'jsonv2',
        'addressdetails': '1',
        'limit': '8',
        'countrycodes': AppConfig.geocodingCountries,
        'accept-language': language,
      },
    );
    final response = await _client
        .get(uri, headers: {'User-Agent': '${AppConfig.userAgentPackage} (customer directory)'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) {
      throw GeocodingException('HTTP ${response.statusCode}');
    }
    final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
    return list.map((raw) {
      final m = raw as Map<String, dynamic>;
      final address = (m['address'] as Map?)?.cast<String, dynamic>() ?? const {};
      return GeocodingResult(
        label: m['display_name'] as String? ?? text,
        point: LatLng(double.parse(m['lat'] as String), double.parse(m['lon'] as String)),
        commune: (address['town'] ?? address['city'] ?? address['village'] ?? address['municipality']) as String?,
        wilaya: (address['state'] ?? address['province']) as String?,
      );
    }).toList();
  }
}

class GeocodingException implements Exception {
  GeocodingException(this.message);
  final String message;
  @override
  String toString() => 'GeocodingException: $message';
}

enum LocationFailure { serviceDisabled, denied, deniedForever, timeout }

class LocationResult {
  const LocationResult.success(this.point) : failure = null;
  const LocationResult.failed(this.failure) : point = null;
  final LatLng? point;
  final LocationFailure? failure;
}

/// The device position. Permission is requested only when the user taps a
/// "my location" control, never at start-up.
class LocationService {
  const LocationService();

  Future<LocationResult> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationResult.failed(LocationFailure.serviceDisabled);
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) return const LocationResult.failed(LocationFailure.denied);
    if (permission == LocationPermission.deniedForever) {
      return const LocationResult.failed(LocationFailure.deniedForever);
    }
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
      );
      return LocationResult.success(LatLng(pos.latitude, pos.longitude));
    } on Exception {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return LocationResult.success(LatLng(last.latitude, last.longitude));
      return const LocationResult.failed(LocationFailure.timeout);
    }
  }

  Future<void> openSettings() => Geolocator.openAppSettings();

  static double distanceMeters(LatLng a, LatLng b) => const Distance().as(LengthUnit.Meter, a, b);
}
