import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'token_refresher.dart';

Dio createDio() {
  final dio = Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl));
  final tokenRefresher = TokenRefresher(dio);

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final session = await tokenRefresher.readSession();
        final token = session?['accessToken'] as String?;
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isAuthEndpoint = {
          ApiEndpoints.refreshToken,
          ApiEndpoints.logIn,
          ApiEndpoints.register,
        }.contains(error.requestOptions.path);

        if (error.response?.statusCode != 401 || isAuthEndpoint) {
          return handler.next(error);
        }

        final newAccessToken = await tokenRefresher.refresh();
        if (newAccessToken == null) {
          return handler.next(error);
        }

        try {
          final retryResponse = await dio.fetch(error.requestOptions);
          return handler.resolve(retryResponse);
        } catch (_) {
          return handler.next(error);
        }
      },
    ),
  );
  return dio;
}
