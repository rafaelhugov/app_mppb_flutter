import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import '../version/app_version_info.dart';
import '../version/force_update_provider.dart';
import '../../features/auth/providers/auth_provider.dart';

const String defaultApiUrl = 'https://aplicativo-api.mppb.mp.br';
const String defaultAuthBaseUrl = defaultApiUrl;

const String apiBaseUrl = String.fromEnvironment(
  'API_URL',
  defaultValue: defaultApiUrl,
);

const String authBaseUrl = String.fromEnvironment(
  'AUTH_BASE_URL',
  defaultValue: apiBaseUrl,
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
      baseUrl: apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        options.headers['X-App-Build'] = AppVersionInfo.appBuildNumber.toString();
        options.headers['X-App-Version'] = AppVersionInfo.appVersion;
        options.headers['X-App-Platform'] = AppVersionInfo.platformName;

        final secureStorage = ref.read(secureStorageProvider);
        final token = await secureStorage.read(key: 'auth_token');
        if (token != null && !options.headers.containsKey('Authorization')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 426) {
          final data = e.response?.data;
          int minBuild = 0;
          String? storeUrl;
          String? message;
          if (data is Map<String, dynamic>) {
            minBuild = data['minBuild'] is int
                ? data['minBuild'] as int
                : int.tryParse('${data['minBuild']}') ?? 0;
            storeUrl = data['storeUrl']?.toString();
            message = data['message']?.toString();
          }
          ref.read(forceUpdateProvider.notifier).triggerForceUpdate(
                minBuild: minBuild,
                currentBuild: AppVersionInfo.appBuildNumber,
                storeUrl: storeUrl,
                message: message,
              );
        }

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
