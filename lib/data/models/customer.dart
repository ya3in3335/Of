import 'package:latlong2/latlong.dart';

enum CustomerStatus {
  active,
  archived;

  static CustomerStatus parse(String? value) => value == 'archived' ? archived : active;
}

class CustomerAddress {
  const CustomerAddress({
    this.id,
    required this.label,
    required this.address,
    this.wilaya,
    this.commune,
    this.latitude,
    this.longitude,
  });

  /// Null for an address that has not been saved yet.
  final String? id;
  final String label;
  final String address;
  final String? wilaya;
  final String? commune;
  final double? latitude;
  final double? longitude;

  bool get hasLocation => latitude != null && longitude != null;
  LatLng? get point => hasLocation ? LatLng(latitude!, longitude!) : null;

  factory CustomerAddress.fromJson(Map<String, dynamic> json) => CustomerAddress(
        id: json['id'] as String?,
        label: json['label'] as String? ?? '',
        address: json['address'] as String? ?? '',
        wilaya: json['wilaya'] as String?,
        commune: json['commune'] as String?,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'label': label,
        'address': address,
        'wilaya': wilaya,
        'commune': commune,
        'latitude': latitude,
        'longitude': longitude,
      };

  CustomerAddress copyWith({
    String? label,
    String? address,
    String? wilaya,
    String? commune,
    double? latitude,
    double? longitude,
    bool clearLocation = false,
  }) =>
      CustomerAddress(
        id: id,
        label: label ?? this.label,
        address: address ?? this.address,
        wilaya: wilaya ?? this.wilaya,
        commune: commune ?? this.commune,
        latitude: clearLocation ? null : (latitude ?? this.latitude),
        longitude: clearLocation ? null : (longitude ?? this.longitude),
      );
}

class Customer {
  const Customer({
    required this.id,
    required this.reference,
    required this.firstName,
    required this.lastName,
    this.businessName,
    required this.primaryPhone,
    this.secondaryPhone,
    this.whatsappPhone,
    required this.wilaya,
    required this.commune,
    required this.address,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.addresses = const [],
  });

  final String id;
  final String reference;
  final String firstName;
  final String lastName;
  final String? businessName;
  final String primaryPhone;
  final String? secondaryPhone;
  final String? whatsappPhone;
  final String wilaya;
  final String commune;
  final String address;
  final double? latitude;
  final double? longitude;
  final CustomerStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final List<CustomerAddress> addresses;

  String get fullName => '$firstName $lastName'.trim();
  bool get isArchived => status == CustomerStatus.archived;
  bool get hasLocation => latitude != null && longitude != null;
  LatLng? get point => hasLocation ? LatLng(latitude!, longitude!) : null;
  String get cityLine => commune == wilaya ? commune : '$commune, $wilaya';

  String get initials {
    String first(String s) => s.trim().isEmpty ? '' : String.fromCharCode(s.trim().runes.first);
    return (first(firstName) + first(lastName)).toUpperCase();
  }

  /// Columns the app reads (search_text and name_key stay on the server).
  static const selectColumns =
      'id, reference, first_name, last_name, business_name, primary_phone, secondary_phone, '
      'whatsapp_phone, wilaya, commune, address, latitude, longitude, status, created_at, '
      'updated_at, created_by, customer_addresses(id, label, address, wilaya, commune, latitude, longitude, created_at)';

  factory Customer.fromJson(Map<String, dynamic> json) {
    final rawAddresses = json['customer_addresses'] ?? json['addresses'];
    return Customer(
      id: json['id'] as String,
      reference: json['reference'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      businessName: json['business_name'] as String?,
      primaryPhone: json['primary_phone'] as String,
      secondaryPhone: json['secondary_phone'] as String?,
      whatsappPhone: json['whatsapp_phone'] as String?,
      wilaya: json['wilaya'] as String,
      commune: json['commune'] as String,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: CustomerStatus.parse(json['status'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdBy: json['created_by'] as String?,
      addresses: rawAddresses is List
          ? rawAddresses.map((e) => CustomerAddress.fromJson(Map<String, dynamic>.from(e as Map))).toList()
          : const [],
    );
  }

  /// Full representation, used for the device cache.
  Map<String, dynamic> toJson() => {
        'id': id,
        'reference': reference,
        'first_name': firstName,
        'last_name': lastName,
        'business_name': businessName,
        'primary_phone': primaryPhone,
        'secondary_phone': secondaryPhone,
        'whatsapp_phone': whatsappPhone,
        'wilaya': wilaya,
        'commune': commune,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'status': status.name,
        'created_at': createdAt.toUtc().toIso8601String(),
        'updated_at': updatedAt.toUtc().toIso8601String(),
        'created_by': createdBy,
        'customer_addresses': addresses.map((a) => a.toJson()).toList(),
      };
}

/// Values entered in the add/edit form, sent to the `save_customer` RPC.
class CustomerDraft {
  const CustomerDraft({
    required this.firstName,
    required this.lastName,
    this.businessName,
    required this.primaryPhone,
    this.secondaryPhone,
    this.whatsappPhone,
    required this.wilaya,
    required this.commune,
    required this.address,
    this.latitude,
    this.longitude,
    this.status = CustomerStatus.active,
    this.addresses = const [],
    this.adminNotes,
  });

  final String firstName;
  final String lastName;
  final String? businessName;
  final String primaryPhone;
  final String? secondaryPhone;
  final String? whatsappPhone;
  final String wilaya;
  final String commune;
  final String address;
  final double? latitude;
  final double? longitude;
  final CustomerStatus status;
  final List<CustomerAddress> addresses;
  final String? adminNotes;

  List<String> get phones => [primaryPhone, secondaryPhone, whatsappPhone].whereType<String>().toList();

  Map<String, dynamic> toPayload() => {
        'first_name': firstName,
        'last_name': lastName,
        'business_name': businessName,
        'primary_phone': primaryPhone,
        'secondary_phone': secondaryPhone,
        'whatsapp_phone': whatsappPhone,
        'wilaya': wilaya,
        'commune': commune,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'status': status.name,
      };
}

/// A possible duplicate returned by `find_customer_duplicates`.
class DuplicateCandidate {
  const DuplicateCandidate({
    required this.id,
    required this.reference,
    required this.fullName,
    required this.primaryPhone,
    required this.cityLine,
    required this.reason,
    required this.archived,
  });

  final String id;
  final String reference;
  final String fullName;
  final String primaryPhone;
  final String cityLine;
  final String reason; // 'phone' | 'name'
  final bool archived;

  factory DuplicateCandidate.fromJson(Map<String, dynamic> json) => DuplicateCandidate(
        id: json['id'] as String,
        reference: json['reference'] as String,
        fullName: '${json['first_name']} ${json['last_name']}',
        primaryPhone: json['primary_phone'] as String,
        cityLine: '${json['commune']}, ${json['wilaya']}',
        reason: json['reason'] as String,
        archived: json['status'] == 'archived',
      );
}

/// A pair listed on the duplicate review screen.
class DuplicatePair {
  const DuplicatePair({required this.customerA, required this.customerB, required this.reason, required this.score});
  final String customerA;
  final String customerB;
  final String reason;
  final double score;

  factory DuplicatePair.fromJson(Map<String, dynamic> json) => DuplicatePair(
        customerA: json['customer_a'] as String,
        customerB: json['customer_b'] as String,
        reason: json['reason'] as String,
        score: (json['score'] as num).toDouble(),
      );
}
