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
    required super.isPremium,
    required super.scansUsed,
    required super.scanLimit,
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
      isPremium: map['isPremium'] as bool? ?? false,
      scansUsed: (map['scansUsed'] as num?)?.toInt() ?? 0,
      scanLimit: (map['scanLimit'] as num?)?.toInt() ?? 10,
    );
  }
}
