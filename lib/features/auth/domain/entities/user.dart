class User {
  final String id;
  final String name;
  final String email;
  final Role role;
  final String accessToken;
  final String refreshToken;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.accessToken,
    required this.refreshToken,
  });
}

enum Role { customer, merchant }
