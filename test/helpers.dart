import 'package:outifor/data/models/customer.dart';

int _seq = 0;

/// Builds a customer for tests. Not real data.
Customer testCustomer({
  String? id,
  String? reference,
  String firstName = 'Mohamed',
  String lastName = 'Benali',
  String? businessName,
  String phone = '0555123456',
  String? secondaryPhone,
  String? whatsapp,
  String wilaya = 'Alger',
  String commune = 'Bab Ezzouar',
  String address = 'Cité 1200 logements',
  double? lat,
  double? lng,
  CustomerStatus status = CustomerStatus.active,
  DateTime? createdAt,
  DateTime? updatedAt,
  List<CustomerAddress> addresses = const [],
}) {
  _seq++;
  final now = DateTime.utc(2026, 11, 1, 10);
  return Customer(
    id: id ?? 'c$_seq',
    reference: reference ?? 'OUT-${_seq.toString().padLeft(6, '0')}',
    firstName: firstName,
    lastName: lastName,
    businessName: businessName,
    primaryPhone: phone,
    secondaryPhone: secondaryPhone,
    whatsappPhone: whatsapp,
    wilaya: wilaya,
    commune: commune,
    address: address,
    latitude: lat,
    longitude: lng,
    status: status,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    addresses: addresses,
  );
}
