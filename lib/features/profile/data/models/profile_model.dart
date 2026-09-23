import '../../../auth/domain/entities/user.dart';
import '../../domain/entities/profile.dart';

class ProfileModel extends Profile {
  ProfileModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.createdAt,
    required super.salesCount,
    required super.priceAlertsEnabled,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      role: map['role'] == 'CUSTOMER' ? Role.customer : Role.merchant,
      createdAt: DateTime.parse(map['createdAt']),
      salesCount: (map['salesCount'] as num).toInt(),
      priceAlertsEnabled: map['priceAlertsEnabled'] as bool,
    );
  }
}
