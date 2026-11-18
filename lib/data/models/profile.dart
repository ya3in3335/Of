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
    final letters = initialLetters(fullName);
    if (letters.isEmpty) return '?';
    return (letters.first + (letters.length > 1 ? letters.last : '')).toUpperCase();
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

final _letter = RegExp(r'\p{L}', unicode: true);

/// First letter of each word that contains a letter, so "(démo)", "&" or
/// numbers never end up in an avatar.
List<String> initialLetters(String text) => [
  for (final word in text.trim().split(RegExp(r'\s+')))
    if (_letter.firstMatch(word) case final m?) m.group(0)!,
];
