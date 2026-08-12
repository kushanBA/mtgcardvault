import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.accessToken,
    required super.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
      id: map['user']['id'],
      name: map['user']['name'],
      email: map['user']['email'],
      role: map['user']['role'] == "CUSTOMER" ? Role.customer : Role.merchant,
      accessToken: map['accessToken'],
      refreshToken: map['refreshToken'],
    );
  }

  Map<String, dynamic> toJson() => {
    'user': {
      'id': id,
      'name': name,
      'email': email,
      'role': role == Role.customer ? 'CUSTOMER' : 'MERCHANT',
    },
    'accessToken': accessToken,
    'refreshToken': refreshToken,
  };
}
