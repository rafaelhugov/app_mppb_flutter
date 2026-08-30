import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage.dart';
import '../../features/auth/providers/auth_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_URL',
        defaultValue: 'https://aplicativo-api.mppb.mp.br',
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
        if (token != null) {
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

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path.contains('recursos-humanos')) {
          print('--- [DIO REQ] ---');
          print('URL: ${options.uri}');
          print('METHOD: ${options.method}');
          print('QUERY: ${options.queryParameters}');
          final h = Map<String, dynamic>.from(options.headers);
          h.remove('Authorization');
          print('HEADERS (sem auth): $h');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.requestOptions.path.contains('recursos-humanos')) {
          print('--- [DIO RES] ---');
          print('URL: ${response.requestOptions.uri}');
          print('STATUS CODE: ${response.statusCode}');
          print('DATA: ${response.data}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (e.requestOptions.path.contains('recursos-humanos')) {
          print('--- [DIO ERR] ---');
          print('URL: ${e.requestOptions.uri}');
          print('STATUS CODE: ${e.response?.statusCode}');
          print('ERROR: ${e.message}');
          print('DATA: ${e.response?.data}');
        }
        return handler.next(e);
      },
    ),
  );

  return dio;
});
