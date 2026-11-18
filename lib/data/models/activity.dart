class ActivityLog {
  const ActivityLog({
    required this.id,
    required this.action,
    required this.createdAt,
    this.actorId,
    this.actorName,
    this.customerId,
    this.targetProfileId,
    this.targetName,
    this.details = const {},
  });

  final int id;
  final String action;
  final DateTime createdAt;
  final String? actorId;
  final String? actorName;
  final String? customerId;
  final String? targetProfileId;
  final String? targetName;
  final Map<String, dynamic> details;

  /// Customer name recorded at the time of the action (kept after deletion).
  String? get customerName => details['name'] as String?;
  String? get customerReference => details['reference'] as String?;

  static const selectColumns =
      'id, action, created_at, actor_id, customer_id, target_profile_id, details, '
      'actor:profiles!activity_logs_actor_id_fkey(full_name), '
      'target:profiles!activity_logs_target_profile_id_fkey(full_name)';

  factory ActivityLog.fromJson(Map<String, dynamic> json) => ActivityLog(
        id: (json['id'] as num).toInt(),
        action: json['action'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        actorId: json['actor_id'] as String?,
        actorName: (json['actor'] as Map?)?['full_name'] as String?,
        customerId: json['customer_id'] as String?,
        targetProfileId: json['target_profile_id'] as String?,
        targetName: (json['target'] as Map?)?['full_name'] as String?,
        details: Map<String, dynamic>.from((json['details'] as Map?) ?? const {}),
      );
}

class DashboardStats {
  const DashboardStats({
    required this.customersTotal,
    required this.customersActive,
    required this.customersArchived,
    required this.customersLast7d,
    required this.customersLast30d,
    required this.customersNoLocation,
    required this.employeesTotal,
    required this.employeesActive,
  });

  final int customersTotal;
  final int customersActive;
  final int customersArchived;
  final int customersLast7d;
  final int customersLast30d;
  final int customersNoLocation;
  final int employeesTotal;
  final int employeesActive;

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    int v(String k) => (json[k] as num?)?.toInt() ?? 0;
    return DashboardStats(
      customersTotal: v('customers_total'),
      customersActive: v('customers_active'),
      customersArchived: v('customers_archived'),
      customersLast7d: v('customers_last_7d'),
      customersLast30d: v('customers_last_30d'),
      customersNoLocation: v('customers_no_location'),
      employeesTotal: v('employees_total'),
      employeesActive: v('employees_active'),
    );
  }
}

class AppSettings {
  const AppSettings({
    required this.companyName,
    required this.defaultLatitude,
    required this.defaultLongitude,
    required this.defaultZoom,
  });

  /// Used until the server row is loaded (Algiers).
  static const fallback = AppSettings(
    companyName: 'OUTIFOR',
    defaultLatitude: 36.7538,
    defaultLongitude: 3.0588,
    defaultZoom: 11,
  );

  final String companyName;
  final double defaultLatitude;
  final double defaultLongitude;
  final double defaultZoom;

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        companyName: json['company_name'] as String,
        defaultLatitude: (json['default_latitude'] as num).toDouble(),
        defaultLongitude: (json['default_longitude'] as num).toDouble(),
        defaultZoom: (json['default_zoom'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'company_name': companyName,
        'default_latitude': defaultLatitude,
        'default_longitude': defaultLongitude,
        'default_zoom': defaultZoom,
      };
}
