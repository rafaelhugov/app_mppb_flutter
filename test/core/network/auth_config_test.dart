import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Configuração de Autenticação Segura (Q14-R03-R02)', () {
    test(
      'resolucao correta de authBaseUrl e authLoginUrl conforme ambiente',
      () {
        expect(defaultAuthBaseUrl, defaultApiUrl);

        const isOverride = bool.hasEnvironment('AUTH_BASE_URL');
        if (isOverride) {
          const expected = String.fromEnvironment('AUTH_BASE_URL');
          expect(authBaseUrl, expected);
          expect(authLoginUrl, '$expected/acesso/autoriza');
        } else {
          expect(authBaseUrl, apiBaseUrl);
          expect(authLoginUrl, '$apiBaseUrl/acesso/autoriza');
        }
      },
    );

    test(
      'login utiliza exatamente a rota parametrizada authLoginUrl',
      () async {
        FlutterSecureStorage.setMockInitialValues({});
        String? requestedPath;

        final adapter = _CapturingAuthAdapter((path) {
          requestedPath = path;
        });

        final dio = Dio();
        dio.httpClientAdapter = adapter;

        final container = ProviderContainer(
          overrides: [
            authDioProvider.overrideWithValue(dio),
            devicePlatformResolverProvider.overrideWithValue(
              const _UnsupportedPlatformResolver(),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(authProvider.notifier)
            .login('test.user', 'test.pass', offerBiometrics: false);

        expect(requestedPath, equals(authLoginUrl));
        expect(requestedPath, contains('/acesso/autoriza'));
      },
    );
  });
}

class _CapturingAuthAdapter implements HttpClientAdapter {
  final void Function(String path) onRequested;

  _CapturingAuthAdapter(this.onRequested);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    onRequested(options.path);
    return ResponseBody.fromString(
      jsonEncode({'token': 'fake-test-token'}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _UnsupportedPlatformResolver extends DevicePlatformResolver {
  const _UnsupportedPlatformResolver();

  @override
  String? currentPlatform() => null;
}
