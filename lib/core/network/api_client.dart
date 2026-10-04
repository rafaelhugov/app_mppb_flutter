import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/providers/auth_provider.dart';

const String defaultApiUrl = 'https://aplicativo-api.mppb.mp.br';
const String defaultAuthBaseUrl = 'https://auth-api.mppb.mp.br';

const String authBaseUrl = String.fromEnvironment(
  'AUTH_BASE_URL',
  defaultValue: defaultAuthBaseUrl,
);

String get authLoginUrl {
  final base = authBaseUrl.endsWith('/')
      ? authBaseUrl.substring(0, authBaseUrl.length - 1)
      : authBaseUrl;
  return '$base/acesso/autoriza';
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_URL',
        defaultValue: defaultApiUrl,
      ),
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final secureStorage = ref.read(secureStorageProvider);
        final token = await secureStorage.read(key: 'auth_token');
        if (token != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        final skipAuthLogout = e.requestOptions.extra['skipAuthLogout'] == true;
        if (e.response?.statusCode == 401 && !skipAuthLogout) {
          // Trigger logout using the provider
          ref.read(authProvider.notifier).logout();
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
