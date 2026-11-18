import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the phone dialer, WhatsApp and Google Maps.
class LauncherService {
  const LauncherService();

  /// International form for wa.me links: 0555123456 -> 213555123456.
  static String whatsappNumber(String phone) {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.startsWith('0') && digits.length == 10) return '213${digits.substring(1)}';
    if (digits.startsWith('0') && digits.length == 9) return '213${digits.substring(1)}';
    return digits;
  }

  static Uri callUri(String phone) => Uri(scheme: 'tel', path: phone);

  static Uri whatsappUri(String phone) => Uri.https('wa.me', '/${whatsappNumber(phone)}');

  /// Turn-by-turn directions from the phone's current position (Google Maps
  /// uses the device location as origin when none is given).
  static Uri directionsUri(double lat, double lng) => Uri.https('www.google.com', '/maps/dir/', {
        'api': '1',
        'destination': '$lat,$lng',
        'travelmode': 'driving',
      });

  static Uri locationUri(double lat, double lng) => Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': '$lat,$lng',
      });

  /// Used only when a customer has no GPS point: searches the written address.
  static Uri addressSearchUri(String address) => Uri.https('www.google.com', '/maps/search/', {
        'api': '1',
        'query': address,
      });

  Future<bool> call(String phone) => _open(callUri(phone));
  Future<bool> whatsapp(String phone) => _open(whatsappUri(phone));
  Future<bool> directions(double lat, double lng) => _open(directionsUri(lat, lng));
  Future<bool> showLocation(double lat, double lng) => _open(locationUri(lat, lng));
  Future<bool> searchAddress(String address) => _open(addressSearchUri(address));

  Future<void> copy(String text) => Clipboard.setData(ClipboardData(text: text));

  Future<bool> _open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } on PlatformException {
      return false;
    }
  }
}
