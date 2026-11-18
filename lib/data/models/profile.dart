enum UserRole {
  admin,
  employee;

  static UserRole parse(String? value) => value == 'admin' ? admin : employee;
}

class Profile {
  const Profile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.role,
    required this.isActive,
    this.phone,
    required this.createdAt,
    this.lastLoginAt,
  });

  final String id;
  final String fullName;
  final String username;
  final UserRole role;
  final bool isActive;
  final String? phone;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  bool get isAdmin => role == UserRole.admin;

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = String.fromCharCode(parts.first.runes.first);
    final last = parts.length > 1 ? String.fromCharCode(parts.last.runes.first) : '';
    return (first + last).toUpperCase();
  }

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
    id: json['id'] as String,
    fullName: json['full_name'] as String,
    username: json['username'] as String,
    role: UserRole.parse(json['role'] as String?),
    isActive: json['is_active'] as bool? ?? false,
    phone: json['phone'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    lastLoginAt: json['last_login_at'] == null ? null : DateTime.parse(json['last_login_at'] as String),
  );
}
