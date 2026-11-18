import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/repositories/admin_repositories.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../data/services/geo_services.dart';
import '../data/services/launcher_service.dart';
import '../data/services/local_cache.dart';

/// Overridden in main() once Supabase is initialised.
final supabaseClientProvider = Provider<SupabaseClient>((ref) => throw UnimplementedError('Supabase not initialised'));

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError('SharedPreferences not loaded'));

final authRepositoryProvider = Provider((ref) => AuthRepository(ref.watch(supabaseClientProvider)));
final customerRepositoryProvider = Provider((ref) => CustomerRepository(ref.watch(supabaseClientProvider)));
final employeeRepositoryProvider = Provider((ref) => EmployeeRepository(ref.watch(supabaseClientProvider)));
final activityRepositoryProvider = Provider((ref) => ActivityRepository(ref.watch(supabaseClientProvider)));
final settingsRepositoryProvider = Provider((ref) => SettingsRepository(ref.watch(supabaseClientProvider)));

final localCacheProvider = Provider((ref) => LocalCacheService());
final launcherProvider = Provider((ref) => const LauncherService());
final geocodingProvider = Provider((ref) => GeocodingService());
final locationServiceProvider = Provider((ref) => const LocationService());

/// Network interface availability. `true` does not guarantee the server is
/// reachable; requests still handle failures and report them.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();
  bool online(List<ConnectivityResult> r) => r.any((c) => c != ConnectivityResult.none);
  try {
    yield online(await connectivity.checkConnectivity());
  } catch (_) {
    yield true;
  }
  yield* connectivity.onConnectivityChanged.map(online).distinct();
});
