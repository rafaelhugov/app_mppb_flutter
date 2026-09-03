import 'package:app_mppb_flutter/core/notifications/device_registration_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'registrar envia Bearer no header e corpo minimo sem matricula ou JWT',
    () async {
      RequestOptions? capturedOptions;
      final dio = Dio(BaseOptions(baseUrl: 'https://mobile.local'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer jwt-autenticacao';
            handler.next(options);
          },
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            handler.resolve(
              Response<Map<String, dynamic>>(
                requestOptions: options,
                statusCode: 200,
                data: {
                  'identificador': 'installation-uuid',
                  'plataforma': 'ANDROID',
                  'ativo': true,
                },
              ),
            );
          },
        ),
      );
      final repository = DeviceRegistrationRepository(dio);

      final response = await repository.registrar(
        identificador: 'installation-uuid',
        tokenFcm: 'fcm-token-secreto',
        plataforma: 'ANDROID',
      );

      expect(response.identificador, 'installation-uuid');
      expect(capturedOptions?.path, '/api/notificacoes/dispositivos');
      expect(capturedOptions?.queryParameters, isEmpty);
      expect(
        capturedOptions?.headers['Authorization'],
        'Bearer jwt-autenticacao',
      );
      expect(capturedOptions?.data, {
        'identificador': 'installation-uuid',
        'tokenFcm': 'fcm-token-secreto',
        'plataforma': 'ANDROID',
      });
      expect(
        (capturedOptions?.data as Map<String, dynamic>).containsKey(
          'matricula',
        ),
        isFalse,
      );
      expect(
        (capturedOptions?.data as Map<String, dynamic>).containsKey('jwt'),
        isFalse,
      );
      expect(
        (capturedOptions?.data as Map<String, dynamic>).containsKey('token'),
        isFalse,
      );
    },
  );

  test(
    'desativar usa identificador na rota e token autenticado no header',
    () async {
      RequestOptions? capturedOptions;
      final dio = Dio(BaseOptions(baseUrl: 'https://mobile.local'));
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            options.headers['Authorization'] = 'Bearer jwt-autenticacao';
            handler.next(options);
          },
        ),
      );
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            capturedOptions = options;
            handler.resolve(
              Response<void>(requestOptions: options, statusCode: 204),
            );
          },
        ),
      );
      final repository = DeviceRegistrationRepository(dio);

      await repository.desativar(identificador: 'installation uuid');

      expect(
        capturedOptions?.path,
        '/api/notificacoes/dispositivos/installation%20uuid',
      );
      expect(capturedOptions?.queryParameters, isEmpty);
      expect(
        capturedOptions?.headers['Authorization'],
        'Bearer jwt-autenticacao',
      );
      expect(capturedOptions?.data, isNull);
    },
  );
}
