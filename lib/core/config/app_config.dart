/// Build-time configuration, passed with `--dart-define-from-file=env/prod.json`.
///
/// Only the public anon key is ever shipped in the app. The service-role key
/// lives in the `admin-users` Edge Function and must never be put here.
class AppConfig {
  const AppConfig._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Usernames are mapped to `username@<loginDomain>` Supabase Auth emails.
  /// Must match OUTIFOR_LOGIN_DOMAIN in the Edge Function.
  static const loginDomain = String.fromEnvironment('LOGIN_DOMAIN', defaultValue: 'outifor.local');

  /// Raster tile server. OpenStreetMap by default; for heavy use, point this
  /// at a commercial provider (MapTiler, Stadia, Mapbox) with its key.
  static const tileUrlTemplate = String.fromEnvironment(
    'MAP_TILE_URL',
    defaultValue: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  );

  static const tileAttribution = String.fromEnvironment(
    'MAP_TILE_ATTRIBUTION',
    defaultValue: '© OpenStreetMap contributors',
  );

  /// Address search (Nominatim-compatible API).
  static const geocodingUrl = String.fromEnvironment(
    'GEOCODING_URL',
    defaultValue: 'https://nominatim.openstreetmap.org',
  );

  /// Country filter for address search (ISO 3166-1 alpha-2, comma separated).
  static const geocodingCountries = String.fromEnvironment('GEOCODING_COUNTRIES', defaultValue: 'dz');

  static const userAgentPackage = 'dz.outifor.outifor';

  static bool get isConfigured =>
      supabaseUrl.startsWith('https://') && supabaseAnonKey.length > 20;
}
