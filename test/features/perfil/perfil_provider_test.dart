import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/features/perfil/providers/perfil_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio.dart';

void main() {
  group('PerfilNotifier', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token',
        'auth_username': 'usuario.atual',
      });
    });

    test('carrega perfil da API e grava cache do usuario atual', () async {
      final container = ProviderContainer(
        overrides: [
          devicePlatformResolverProvider.overrideWithValue(
            const _UnsupportedPlatformResolver(),
          ),
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/perfil/dados': const FakeDioResponse(200, {
                'login': 'usuario.atual',
                'nome': 'Pessoa Teste',
                'matricula': 123,
                'cargo': 'Analista',
                'setorSigla': 'DTI',
              }),
            }, baseUrl: 'https://api.test'),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(perfilProvider);
      await _aguardarProvider();

      final state = container.read(perfilProvider);
      final storage = const FlutterSecureStorage();
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.data?.nome, 'Pessoa Teste');
      expect(state.data?.matricula, '123');
      expect(
        state.data?.fotoUrl,
        startsWith('https://api.test/carteiras-funcionais/foto?v='),
      );
      expect(await storage.read(key: 'perfil_cache_username'), 'usuario.atual');
      expect(
        await storage.read(key: 'perfil_cache_data'),
        contains('Pessoa Teste'),
      );
    });

    test('usa cache quando a API falha para o mesmo usuario', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token',
        'auth_username': 'usuario.atual',
        'perfil_cache_username': 'usuario.atual',
        'perfil_cache_data': '{"nome":"Perfil Cache","matricula":"321"}',
      });
      final container = ProviderContainer(
        overrides: [
          devicePlatformResolverProvider.overrideWithValue(
            const _UnsupportedPlatformResolver(),
          ),
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/perfil/dados': const FakeDioResponse(500, {'erro': true}),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(perfilProvider);
      await _aguardarProvider();

      final state = container.read(perfilProvider);
      expect(state.isLoading, isFalse);
      expect(state.data?.nome, 'Perfil Cache');
      expect(state.errorMessage, 'Não foi possível atualizar seu perfil.');
    });

    test('descarta cache quando pertence a outro usuario', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token',
        'auth_username': 'usuario.novo',
        'perfil_cache_username': 'usuario.antigo',
        'perfil_cache_data': '{"nome":"Perfil Antigo"}',
      });
      final container = ProviderContainer(
        overrides: [
          devicePlatformResolverProvider.overrideWithValue(
            const _UnsupportedPlatformResolver(),
          ),
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/perfil/dados': const FakeDioResponse(404, {'erro': true}),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(perfilProvider);
      await _aguardarProvider();

      final state = container.read(perfilProvider);
      final storage = const FlutterSecureStorage();
      expect(state.data, isNull);
      expect(state.errorMessage, 'Não foi possível atualizar seu perfil.');
      expect(await storage.read(key: 'perfil_cache_data'), isNull);
    });
  });
}

Future<void> _aguardarProvider() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
}

class _UnsupportedPlatformResolver extends DevicePlatformResolver {
  const _UnsupportedPlatformResolver();

  @override
  String? currentPlatform() => null;
}
