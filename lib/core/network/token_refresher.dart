import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import '../storage/local_storage.dart' as storage;

const sessionKey = 'auth_user';

/// Uses the cached refresh token to get a new access token from
/// [ApiEndpoints.refreshToken], persisting it back over the cached session.
/// Concurrent callers share a single in-flight refresh instead of each
/// firing their own request.
class TokenRefresher {
  final Dio _dio;
  Future<String?>? _refreshing;

  TokenRefresher(this._dio);

  Future<Map<String, dynamic>?> readSession() =>
      storage.load<Map<String, dynamic>>(sessionKey, (j) => j as Map<String, dynamic>);

  /// Returns the new access token, or null if there's no refresh token to
  /// use or the refresh call itself failed — in which case the cached
  /// session is cleared.
  Future<String?> refresh() {
    return _refreshing ??= _doRefresh().whenComplete(() => _refreshing = null);
  }

  Future<String?> _doRefresh() async {
    final session = await readSession();
    final refreshToken = session?['refreshToken'] as String?;
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );
      final newAccessToken = response.data['accessToken'] as String?;
      if (newAccessToken == null) return null;
      final newRefreshToken = response.data['refreshToken'] as String? ?? refreshToken;

      await storage.save(sessionKey, {
        ...session!,
        'accessToken': newAccessToken,
        'refreshToken': newRefreshToken,
      });
      return newAccessToken;
    } catch (_) {
      await storage.remove(sessionKey);
      return null;
    }
  }
}
