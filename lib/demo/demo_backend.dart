// DEMO MODE ONLY (--dart-define=DEMO_MODE=true).
//
// An in-memory stand-in for Supabase so the app can be tried without a
// server. It applies the same rules as the real backend (admin-only writes,
// deactivation, server-generated references, duplicate checks), but data is
// sample data and is reset when the app restarts. Production builds never
// include this backend in the provider graph.
import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' show AuthState, Session, User;

import '../core/errors/app_exception.dart';
import '../core/utils/text_normalizer.dart';
import '../data/models/activity.dart';
import '../data/models/customer.dart';
import '../data/models/profile.dart';
import '../data/repositories/admin_repositories.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/customer_repository.dart';
import '../domain/customer_search.dart';

class DemoBackend {
  DemoBackend() {
    _seed();
  }

  final _passwords = <String, String>{}; // username -> password (demo only)
  final profiles = <String, Profile>{};
  final customers = <String, Customer>{};
  final notes = <String, String>{};
  final deletions = <CustomerDeletion>[];
  final logs = <ActivityLog>[];
  final dismissed = <String>{};
  final _listeners = <void Function()>{};
  AppSettings settings = const AppSettings(
    companyName: 'OutiFor — DÉMO',
    defaultLatitude: 36.7538,
    defaultLongitude: 3.0588,
    defaultZoom: 11,
  );

  String? currentUserId;
  int _seq = 0;
  int _logId = 0;
  int _idSeq = 0;

  Profile? get me => currentUserId == null ? null : profiles[currentUserId];

  String _newId(String prefix) => '$prefix-${++_idSeq}';

  void _requireActive() {
    final p = me;
    if (p == null) throw const AppException(AppErrorKind.sessionExpired);
    if (!p.isActive) throw const AppException(AppErrorKind.accountDisabled);
  }

  void _requireAdmin() {
    _requireActive();
    if (!me!.isAdmin) throw const AppException(AppErrorKind.forbidden);
  }

  void _notify() {
    for (final l in _listeners.toList()) {
      l();
    }
  }

  void _log(String action, {String? customerId, String? targetId, Map<String, dynamic> details = const {}}) {
    logs.insert(
      0,
      ActivityLog(
        id: ++_logId,
        action: action,
        createdAt: DateTime.now().toUtc(),
        actorId: currentUserId,
        actorName: me?.fullName,
        customerId: customerId,
        targetProfileId: targetId,
        targetName: targetId == null ? null : profiles[targetId]?.fullName,
        details: details,
      ),
    );
  }

  Profile _addProfile(String username, String name, UserRole role, String password, {DateTime? lastLogin}) {
    final p = Profile(
      id: _newId('u'),
      fullName: name,
      username: username,
      role: role,
      isActive: true,
      createdAt: DateTime.now().toUtc().subtract(const Duration(days: 40)),
      lastLoginAt: lastLogin,
    );
    profiles[p.id] = p;
    _passwords[username] = password;
    return p;
  }

  Customer _build(
    String id,
    CustomerDraft d, {
    required String reference,
    required DateTime createdAt,
    String? createdBy,
  }) => Customer(
    id: id,
    reference: reference,
    firstName: d.firstName.trim(),
    lastName: d.lastName.trim(),
    businessName: d.businessName,
    primaryPhone: TextNormalizer.normalizePhone(d.primaryPhone)!,
    secondaryPhone: TextNormalizer.normalizePhone(d.secondaryPhone),
    whatsappPhone: TextNormalizer.normalizePhone(d.whatsappPhone),
    wilaya: d.wilaya,
    commune: d.commune,
    address: d.address,
    latitude: d.latitude,
    longitude: d.longitude,
    status: d.status,
    createdAt: createdAt,
    updatedAt: DateTime.now().toUtc(),
    createdBy: createdBy,
    addresses: [
      for (final a in d.addresses)
        CustomerAddress(
          id: a.id ?? _newId('addr'),
          label: a.label,
          address: a.address,
          wilaya: a.wilaya,
          commune: a.commune,
          latitude: a.latitude,
          longitude: a.longitude,
        ),
    ],
  );

  void _seed() {
    final admin = _addProfile(
      'admin',
      'Directeur (démo)',
      UserRole.admin,
      'demo1234',
      lastLogin: DateTime.now().toUtc().subtract(const Duration(hours: 2)),
    );
    _addProfile(
      'livreur',
      'Livreur (démo)',
      UserRole.employee,
      'demo1234',
      lastLogin: DateTime.now().toUtc().subtract(const Duration(minutes: 30)),
    );
    final inactive = _addProfile('ancien', 'Ancien employé (démo)', UserRole.employee, 'demo1234');
    profiles[inactive.id] = Profile(
      id: inactive.id,
      fullName: inactive.fullName,
      username: inactive.username,
      role: inactive.role,
      isActive: false,
      createdAt: inactive.createdAt,
    );

    final now = DateTime.now().toUtc();
    final samples = <(String, String, String?, String, String?, String, String, String, double?, double?, int)>[
      (
        'Mohamed',
        'Benali',
        'Quincaillerie Benali',
        '0555123456',
        '0555123456',
        'Alger',
        'Bab Ezzouar',
        'Cité 1200 logements, bloc 5',
        36.7213,
        3.1834,
        1,
      ),
      (
        'Mohammed',
        'Benali',
        null,
        '0661987654',
        null,
        'Blida',
        'Boufarik',
        'Rue des frères Abed, n°12',
        36.5747,
        2.9117,
        3,
      ),
      (
        'Amina',
        'Kaci',
        'Droguerie El Amel',
        '0770112233',
        '0770112233',
        'Oran',
        'Bir El Djir',
        'Hai Khemisti, local 4',
        35.7203,
        -0.5468,
        5,
      ),
      (
        'Karim',
        'Haddad',
        'Matériaux Haddad',
        '0550998877',
        null,
        'Sétif',
        'El Eulma',
        'Route de Batna',
        36.1528,
        5.6906,
        8,
      ),
      (
        'Yacine',
        'Bouzid',
        null,
        '0699112244',
        '0699112244',
        'Alger',
        'Kouba',
        'Rue Garidi 2, n°7',
        36.7264,
        3.0856,
        12,
      ),
      (
        'Nadia',
        'Cherif',
        'Peinture & Déco Cherif',
        '0541223344',
        null,
        'Tizi Ouzou',
        'Tizi Ouzou',
        'Nouvelle ville, lot 210',
        36.7118,
        4.0459,
        15,
      ),
      (
        'Sofiane',
        'Meziane',
        'Outillage Meziane',
        '0662334455',
        '0662334455',
        'Béjaïa',
        'Akbou',
        'Zone d\'activité, hangar 3',
        36.4611,
        4.5340,
        20,
      ),
      (
        'محمد',
        'بن علي',
        'مواد البناء بن علي',
        '0771445566',
        '0771445566',
        'Constantine',
        'El Khroub',
        'حي 1000 مسكن',
        36.2638,
        6.6937,
        25,
      ),
      ('Rachid', 'Saidi', null, '0558556677', null, 'Alger', 'Rouiba', 'Zone industrielle, lot 12', null, null, 2),
      (
        'Fatima',
        'Zerrouki',
        'Sanitaire Zerrouki',
        '0663667788',
        '0663667788',
        'Boumerdès',
        'Boudouaou',
        'Centre-ville, à côté de la poste',
        36.7290,
        3.4098,
        30,
      ),
      (
        'Omar',
        'Larbi',
        'Électricité Larbi',
        '0772778899',
        null,
        'Tipaza',
        'Koléa',
        'Rue principale n°45',
        null,
        null,
        6,
      ),
    ];
    for (final s in samples) {
      final id = _newId('c');
      customers[id] = _build(
        id,
        CustomerDraft(
          firstName: s.$1,
          lastName: s.$2,
          businessName: s.$3,
          primaryPhone: s.$4,
          whatsappPhone: s.$5,
          wilaya: s.$6,
          commune: s.$7,
          address: s.$8,
          latitude: s.$9,
          longitude: s.$10,
        ),
        reference: 'OUT-${(++_seq).toString().padLeft(6, '0')}',
        createdAt: now.subtract(Duration(days: s.$11)),
        createdBy: admin.id,
      );
    }
    final archivedId = _newId('c');
    customers[archivedId] = _build(
      archivedId,
      const CustomerDraft(
        firstName: 'Hocine',
        lastName: 'Ait Ali',
        primaryPhone: '0559001122',
        wilaya: 'Bouira',
        commune: 'Lakhdaria',
        address: 'Ancien magasin fermé',
        status: CustomerStatus.archived,
      ),
      reference: 'OUT-${(++_seq).toString().padLeft(6, '0')}',
      createdAt: now.subtract(const Duration(days: 90)),
    );
    notes[customers.keys.first] = 'Paie à la livraison. Fermé le vendredi.';
    currentUserId = admin.id;
    _log(
      'customer_created',
      customerId: customers.keys.first,
      details: {'name': 'Mohamed Benali', 'reference': 'OUT-000001'},
    );
    _log('customer_location_updated', customerId: customers.keys.elementAt(2), details: {'name': 'Amina Kaci'});
    currentUserId = null;
  }
}

// ---------------------------------------------------------------------------

class DemoAuthRepository implements AuthRepository {
  DemoAuthRepository(this.b);
  final DemoBackend b;

  @override
  Session? get currentSession => null; // the demo always starts at the login screen

  @override
  User? get currentUser => null;

  @override
  Stream<AuthState> get authStateChanges => const Stream.empty();

  @override
  Future<void> signIn({required String identifier, required String password}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final username = identifier.trim().toLowerCase().split('@').first;
    if (b._passwords[username] != password) throw const AppException(AppErrorKind.invalidCredentials);
    final p = b.profiles.values.firstWhere((p) => p.username == username);
    b.currentUserId = p.id;
    b.profiles[p.id] = Profile(
      id: p.id,
      fullName: p.fullName,
      username: p.username,
      role: p.role,
      isActive: p.isActive,
      phone: p.phone,
      createdAt: p.createdAt,
      lastLoginAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> signOut() async => b.currentUserId = null;

  @override
  Future<Profile?> fetchActiveProfile() async {
    final p = b.me;
    return (p != null && p.isActive) ? p : null;
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    final p = b.me;
    if (p == null) throw const AppException(AppErrorKind.sessionExpired);
    if (b._passwords[p.username] != currentPassword) throw const AppException(AppErrorKind.invalidCredentials);
    b._passwords[p.username] = newPassword;
  }

  @override
  Future<void> updateOwnProfile({required String fullName, String? phone}) async {
    b._requireActive();
    final p = b.me!;
    b.profiles[p.id] = Profile(
      id: p.id,
      fullName: fullName,
      username: p.username,
      role: p.role,
      isActive: p.isActive,
      phone: TextNormalizer.normalizePhone(phone),
      createdAt: p.createdAt,
      lastLoginAt: p.lastLoginAt,
    );
  }
}

class DemoCustomerRepository implements CustomerRepository {
  DemoCustomerRepository(this.b);
  final DemoBackend b;

  Future<void> _latency() => Future<void>.delayed(const Duration(milliseconds: 250));

  @override
  Future<List<Customer>> fetchChangedSince(DateTime? since) async {
    await _latency();
    b._requireActive();
    return b.customers.values.where((c) => since == null || !c.updatedAt.isBefore(since)).toList();
  }

  @override
  Future<List<CustomerDeletion>> fetchDeletionsSince(DateTime? since) async {
    b._requireActive();
    return b.deletions.where((d) => since == null || !d.deletedAt.isBefore(since)).toList();
  }

  @override
  Future<Customer?> fetchOne(String id) async {
    b._requireActive();
    return b.customers[id];
  }

  @override
  Future<Customer> save({String? id, required CustomerDraft draft, DateTime? expectedUpdatedAt}) async {
    await _latency();
    b._requireAdmin();
    final Customer saved;
    if (id == null) {
      final newId = b._newId('c');
      saved = b._build(
        newId,
        draft,
        reference: 'OUT-${(++b._seq).toString().padLeft(6, '0')}',
        createdAt: DateTime.now().toUtc(),
        createdBy: b.currentUserId,
      );
      b._log('customer_created', customerId: newId, details: {'name': saved.fullName, 'reference': saved.reference});
    } else {
      final old = b.customers[id];
      if (old == null) throw const AppException(AppErrorKind.notFound);
      if (expectedUpdatedAt != null && old.updatedAt != expectedUpdatedAt) {
        throw const AppException(AppErrorKind.conflict);
      }
      saved = b._build(id, draft, reference: old.reference, createdAt: old.createdAt, createdBy: old.createdBy);
      final locationOnly =
          (old.latitude != saved.latitude || old.longitude != saved.longitude) &&
          old.fullName == saved.fullName &&
          old.primaryPhone == saved.primaryPhone &&
          old.address == saved.address;
      b._log(
        locationOnly ? 'customer_location_updated' : 'customer_updated',
        customerId: id,
        details: {'name': saved.fullName, 'reference': saved.reference},
      );
    }
    b.customers[saved.id] = saved;
    final n = draft.adminNotes;
    if (n != null) {
      if (n.trim().isEmpty) {
        b.notes.remove(saved.id);
      } else {
        b.notes[saved.id] = n.trim();
      }
    }
    b._notify();
    return saved;
  }

  @override
  Future<Customer> setStatus(String id, CustomerStatus status) async {
    await _latency();
    b._requireAdmin();
    final c = b.customers[id];
    if (c == null) throw const AppException(AppErrorKind.notFound);
    final updated = Customer.fromJson({
      ...c.toJson(),
      'status': status.name,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    b.customers[id] = updated;
    b._log(
      status == CustomerStatus.archived ? 'customer_archived' : 'customer_restored',
      customerId: id,
      details: {'name': c.fullName, 'reference': c.reference},
    );
    b._notify();
    return updated;
  }

  @override
  Future<void> delete(String id) async {
    await _latency();
    b._requireAdmin();
    final c = b.customers.remove(id);
    if (c == null) throw const AppException(AppErrorKind.notFound);
    b.notes.remove(id);
    b.deletions.add(CustomerDeletion(id, c.reference, DateTime.now().toUtc()));
    b._log('customer_deleted', details: {'name': c.fullName, 'reference': c.reference});
    b._notify();
  }

  @override
  Future<String?> fetchAdminNotes(String customerId) async {
    b._requireActive();
    if (!b.me!.isAdmin) return null; // same as RLS: employees get no rows
    return b.notes[customerId];
  }

  @override
  Future<List<DuplicateCandidate>> findDuplicates(CustomerDraft draft, {String? excludeId}) async {
    b._requireAdmin();
    final engine = CustomerSearchEngine(b.customers.values);
    final phones = draft.phones.map(TextNormalizer.normalizePhone).whereType<String>().toSet();
    return engine
        .possibleDuplicates(
          firstName: draft.firstName,
          lastName: draft.lastName,
          phones: draft.phones,
          excludeId: excludeId,
        )
        .map(
          (c) => DuplicateCandidate(
            id: c.id,
            reference: c.reference,
            fullName: c.fullName,
            primaryPhone: c.primaryPhone,
            cityLine: '${c.commune}, ${c.wilaya}',
            reason: [c.primaryPhone, c.secondaryPhone, c.whatsappPhone].any(phones.contains) ? 'phone' : 'name',
            archived: c.isArchived,
          ),
        )
        .toList();
  }

  @override
  Future<List<DuplicatePair>> listDuplicatePairs() async {
    b._requireAdmin();
    final list = b.customers.values.toList();
    final pairs = <DuplicatePair>[];
    for (var i = 0; i < list.length; i++) {
      final others = CustomerSearchEngine(list.sublist(i + 1));
      final a = list[i];
      for (final c in others.possibleDuplicates(
        firstName: a.firstName,
        lastName: a.lastName,
        phones: [a.primaryPhone, ?a.secondaryPhone, ?a.whatsappPhone],
      )) {
        final key = ([a.id, c.id]..sort()).join('|');
        if (b.dismissed.contains(key)) continue;
        final samePhone = {
          a.primaryPhone,
          a.secondaryPhone,
          a.whatsappPhone,
        }.intersection({c.primaryPhone, c.secondaryPhone, c.whatsappPhone}).whereType<String>().isNotEmpty;
        pairs.add(
          DuplicatePair(
            customerA: a.id,
            customerB: c.id,
            reason: samePhone ? 'phone' : 'name',
            score: samePhone ? 1 : 0.8,
          ),
        );
      }
    }
    return pairs;
  }

  @override
  Future<void> dismissDuplicatePair(String a, String c) async {
    b._requireAdmin();
    b.dismissed.add(([a, c]..sort()).join('|'));
    b._log('duplicate_dismissed', customerId: a);
  }

  @override
  Future<void> logAction(CustomerAction action, String customerId) async {
    if (b.me == null || !b.me!.isActive) return;
    b._log(action.code, customerId: customerId);
  }

  @override
  void Function() subscribe(void Function() onChange) {
    b._listeners.add(onChange);
    return () => b._listeners.remove(onChange);
  }
}

class DemoEmployeeRepository implements EmployeeRepository {
  DemoEmployeeRepository(this.b);
  final DemoBackend b;

  Profile _copy(Profile p, {String? fullName, UserRole? role, bool? active}) => Profile(
    id: p.id,
    fullName: fullName ?? p.fullName,
    username: p.username,
    role: role ?? p.role,
    isActive: active ?? p.isActive,
    phone: p.phone,
    createdAt: p.createdAt,
    lastLoginAt: p.lastLoginAt,
  );

  @override
  Future<List<Profile>> list() async {
    b._requireAdmin();
    return b.profiles.values.toList()..sort((a, c) => a.fullName.compareTo(c.fullName));
  }

  @override
  Future<Profile> get(String id) async {
    b._requireAdmin();
    final p = b.profiles[id];
    if (p == null) throw const AppException(AppErrorKind.notFound);
    return p;
  }

  @override
  Future<Profile> create({
    required String fullName,
    required String username,
    required String password,
    required UserRole role,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    b._requireAdmin();
    if (b._passwords.containsKey(username)) throw const AppException(AppErrorKind.usernameTaken);
    final p = b._addProfile(username, fullName, role, password);
    b.profiles[p.id] = Profile(
      id: p.id,
      fullName: fullName,
      username: username,
      role: role,
      isActive: true,
      createdAt: DateTime.now().toUtc(),
    );
    b._log('employee_created', targetId: p.id, details: {'username': username});
    return b.profiles[p.id]!;
  }

  @override
  Future<Profile> setActive(String id, bool active) async {
    b._requireAdmin();
    if (id == b.currentUserId) throw const AppException(AppErrorKind.validation);
    final p = await get(id);
    b.profiles[id] = _copy(p, active: active);
    b._log(active ? 'employee_activated' : 'employee_deactivated', targetId: id);
    return b.profiles[id]!;
  }

  @override
  Future<Profile> resetPassword(String id, String password) async {
    b._requireAdmin();
    final p = await get(id);
    b._passwords[p.username] = password;
    b._log('employee_password_reset', targetId: id);
    return p;
  }

  @override
  Future<Profile> update(String id, {required String fullName, required UserRole role}) async {
    b._requireAdmin();
    final p = await get(id);
    if (id == b.currentUserId && role != p.role) throw const AppException(AppErrorKind.validation);
    b.profiles[id] = _copy(p, fullName: fullName, role: role);
    b._log('employee_updated', targetId: id);
    return b.profiles[id]!;
  }
}

class DemoActivityRepository implements ActivityRepository {
  DemoActivityRepository(this.b);
  final DemoBackend b;

  @override
  Future<List<ActivityLog>> recent({int limit = 50, int offset = 0, String? actorId, List<String>? actions}) async {
    b._requireAdmin();
    final list = b.logs
        .where((l) => actorId == null || l.actorId == actorId)
        .where((l) => actions == null || actions.contains(l.action))
        .toList();
    return list.skip(offset).take(limit).toList();
  }

  @override
  Future<DashboardStats> dashboardStats() async {
    b._requireAdmin();
    final now = DateTime.now().toUtc();
    final c = b.customers.values;
    final emps = b.profiles.values.where((p) => p.role == UserRole.employee);
    return DashboardStats(
      customersTotal: c.length,
      customersActive: c.where((x) => !x.isArchived).length,
      customersArchived: c.where((x) => x.isArchived).length,
      customersLast7d: c.where((x) => now.difference(x.createdAt).inDays < 7).length,
      customersLast30d: c.where((x) => now.difference(x.createdAt).inDays < 30).length,
      customersNoLocation: c.where((x) => !x.isArchived && !x.hasLocation).length,
      employeesTotal: emps.length,
      employeesActive: emps.where((p) => p.isActive).length,
    );
  }
}

class DemoSettingsRepository implements SettingsRepository {
  DemoSettingsRepository(this.b);
  final DemoBackend b;

  @override
  Future<AppSettings> fetch() async {
    b._requireActive();
    return b.settings;
  }

  @override
  Future<AppSettings> update(AppSettings settings) async {
    b._requireAdmin();
    b.settings = settings;
    b._log('settings_updated');
    return settings;
  }
}
