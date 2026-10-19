import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthNotifier', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    test('estado inicial sem token nao autentica usuario', () async {
      final container = _container();
      addTearDown(container.dispose);

      await _pumpMicrotask();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(state.isLoading, isFalse);
    });

    test('sessao existente autentica usuario com token salvo', () async {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'token-salvo'});
      final container = _container();
      addTearDown(container.dispose);

      container.read(authProvider);
      await _pumpMicrotask();

      final state = container.read(authProvider);
      expect(state.isAuthenticated, isTrue);
      expect(state.token, 'token-salvo');
    });

    test(
      'sessao persiste ao abrir mesmo com acesso seguro habilitado',
      () async {
        FlutterSecureStorage.setMockInitialValues({
          'auth_token': 'token-salvo',
          'biometrics_enabled': 'true',
          'biometric_device_credential': 'BIO1.seletor.segredo',
        });
        final container = _container();
        addTearDown(container.dispose);

        container.read(authProvider);
        await _pumpMicrotask();

        final storage = const FlutterSecureStorage();
        final state = container.read(authProvider);
        expect(state.isAuthenticated, isTrue);
        expect(state.token, 'token-salvo');
        expect(await storage.read(key: 'auth_token'), 'token-salvo');
      },
    );

    test('login valido salva token e usuario atual', () async {
      final dio = _dioResponding(200, {'token': 'token-api'});
      final container = _container(authDio: dio);
      addTearDown(container.dispose);

      final result = await container
          .read(authProvider.notifier)
          .login('usuario.teste', 'senha', offerBiometrics: false);

      final storage = const FlutterSecureStorage();
      expect(result, isTrue);
      expect(container.read(authProvider).isAuthenticated, isTrue);
      expect(container.read(authProvider).token, 'token-api');
      expect(await storage.read(key: 'auth_token'), 'token-api');
      expect(await storage.read(key: 'auth_username'), 'usuario.teste');
    });

    test('credencial invalida retorna erro amigavel e nao autentica', () async {
      final dio = _dioResponding(401, {'message': 'nao autorizado'});
      final container = _container(authDio: dio);
      addTearDown(container.dispose);

      final result = await container
          .read(authProvider.notifier)
          .login('usuario.teste', 'errada');

      final state = container.read(authProvider);
      expect(result, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, 'Usuário ou senha inválidos.');
    });

    test('login com resposta sem token falha sem autenticar', () async {
      final dio = _dioResponding(200, {'semToken': true});
      final container = _container(authDio: dio);
      addTearDown(container.dispose);

      final result = await container
          .read(authProvider.notifier)
          .login('usuario.teste', 'senha');

      final state = container.read(authProvider);
      expect(result, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(
        state.errorMessage,
        'Token não retornado pela API de autenticação.',
      );
    });

    test('erro da API de autenticacao informa status recebido', () async {
      final dio = _dioResponding(503, {'message': 'indisponivel'});
      final container = _container(authDio: dio);
      addTearDown(container.dispose);

      final result = await container
          .read(authProvider.notifier)
          .login('usuario.teste', 'senha');

      final state = container.read(authProvider);
      expect(result, isFalse);
      expect(state.isAuthenticated, isFalse);
      expect(state.errorMessage, 'Erro na API de autenticação (Status: 503)');
    });

    test('logout limpa sessao e caches do usuario', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-salvo',
        'auth_username': 'usuario.teste',
        'biometrics_enabled': 'true',
        'biometric_device_credential': 'BIO1.seletor.segredo',
        'biometric_username': 'usuario.teste',
        'carteira_cache_data': '{}',
        'carteira_cache_username': 'usuario.teste',
        'perfil_cache_data': '{}',
        'perfil_cache_username': 'usuario.teste',
      });
      final container = _container();
      addTearDown(container.dispose);

      container.read(authProvider);
      await _pumpMicrotask();
      await container.read(authProvider.notifier).logout();

      final storage = const FlutterSecureStorage();
      final state = container.read(authProvider);
      expect(state.isAuthenticated, isFalse);
      expect(state.token, isNull);
      expect(await storage.read(key: 'auth_token'), isNull);
      expect(await storage.read(key: 'auth_username'), isNull);
      expect(await storage.read(key: 'carteira_cache_data'), isNull);
      expect(await storage.read(key: 'perfil_cache_data'), isNull);
      expect(await storage.read(key: 'biometrics_enabled'), 'true');
      expect(
        await storage.read(key: 'biometric_device_credential'),
        'BIO1.seletor.segredo',
      );
      expect(await storage.read(key: 'biometric_username'), 'usuario.teste');
      expect(
        await storage.read(key: skipLocalAuthAutoPromptOnceStorageKey),
        'true',
      );
    });
  });
}

ProviderContainer _container({Dio? authDio}) {
  return ProviderContainer(
    overrides: [
      if (authDio != null) authDioProvider.overrideWithValue(authDio),
      devicePlatformResolverProvider.overrideWithValue(
        const _UnsupportedPlatformResolver(),
      ),
    ],
  );
}

Dio _dioResponding(int statusCode, Object body) {
  final dio = Dio();
  dio.httpClientAdapter = _FakeAuthAdapter(statusCode, body);
  return dio;
}

Future<void> _pumpMicrotask() => Future<void>.delayed(Duration.zero);

class _UnsupportedPlatformResolver extends DevicePlatformResolver {
  const _UnsupportedPlatformResolver();

  @override
  String? currentPlatform() => null;
}

class _FakeAuthAdapter implements HttpClientAdapter {
  final int statusCode;
  final Object body;

  _FakeAuthAdapter(this.statusCode, this.body);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
