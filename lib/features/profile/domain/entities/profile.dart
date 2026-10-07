import '../../../auth/domain/entities/user.dart';

class Profile {
  final String id;
  final String name;
  final String email;
  final Role role;
  final DateTime createdAt;
  final int salesCount;
  final bool priceAlertsEnabled;
  final bool isPremium;
  final int scansUsed;
  final int scanLimit;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.createdAt,
    required this.salesCount,
    required this.priceAlertsEnabled,
    required this.isPremium,
    required this.scansUsed,
    required this.scanLimit,
  });

  /// Free accounts are capped at [scanLimit] scans, ever — Premium removes
  /// the cap entirely.
  bool get hasReachedScanLimit => !isPremium && scansUsed >= scanLimit;

  int get scansRemaining => (scanLimit - scansUsed).clamp(0, scanLimit);

  Profile copyWith({bool? priceAlertsEnabled, bool? isPremium}) => Profile(
    id: id,
    name: name,
    email: email,
    role: role,
    createdAt: createdAt,
    salesCount: salesCount,
    priceAlertsEnabled: priceAlertsEnabled ?? this.priceAlertsEnabled,
    isPremium: isPremium ?? this.isPremium,
    scansUsed: scansUsed,
    scanLimit: scanLimit,
  );
}
