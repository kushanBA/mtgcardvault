import '../../../auth/domain/entities/user.dart';

class Profile {
  final String id;
  final String name;
  final String email;
  final Role role;
  final DateTime createdAt;
  final int salesCount;
  final bool priceAlertsEnabled;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.salesCount,
    required this.priceAlertsEnabled,
  });

  Profile copyWith({bool? priceAlertsEnabled}) => Profile(
    id: id,
    name: name,
    email: email,
    role: role,
    createdAt: createdAt,
    salesCount: salesCount,
    priceAlertsEnabled: priceAlertsEnabled ?? this.priceAlertsEnabled,
  );
}
