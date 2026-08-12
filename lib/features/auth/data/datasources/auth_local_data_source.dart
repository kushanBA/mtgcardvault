import '../../../../core/storage/local_storage.dart' as storage;
import '../models/user_model.dart';

const _sessionKey = 'auth_user';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> cacheUser(UserModel user) => storage.save(_sessionKey, user.toJson());

  @override
  Future<UserModel?> getCachedUser() =>
      storage.load<UserModel>(_sessionKey, (j) => UserModel.fromJson(j as Map<String, dynamic>));

  @override
  Future<void> clearCache() => storage.remove(_sessionKey);
}
