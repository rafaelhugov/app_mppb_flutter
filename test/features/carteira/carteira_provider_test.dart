import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/features/carteira/providers/carteira_provider.dart';
import '../../helpers/fake_dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CarteiraNotifier', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token',
        'auth_username': 'usuario.atual',
      });
    });

    test('carrega dados da API e grava cache do usuario atual', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/carteiras-funcionais/dados': const FakeDioResponse(200, {
                'nome': 'Pessoa Teste',
                'matricula': 123,
                'cargo': 'Analista',
                'md5': 'abc',
              }),
            }, baseUrl: 'https://api.test'),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(carteiraProvider);
      await _aguardarProvider();

      final state = container.read(carteiraProvider);
      final storage = const FlutterSecureStorage();
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.isOffline, isFalse);
      expect(state.data?.nome, 'Pessoa Teste');
      expect(state.data?.matricula, '123');
      expect(
        state.data?.foto,
        startsWith('https://api.test/carteiras-funcionais/foto?v='),
      );
      expect(
        await storage.read(key: 'carteira_cache_username'),
        'usuario.atual',
      );
      expect(
        await storage.read(key: 'carteira_cache_data'),
        contains('Pessoa Teste'),
      );
    });

    test('usa cache offline quando API falha para o mesmo usuario', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token',
        'auth_username': 'usuario.atual',
        'carteira_cache_username': 'usuario.atual',
        'carteira_cache_data': '{"nome":"Cache Local","matricula":"321"}',
      });
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/carteiras-funcionais/dados': const FakeDioResponse(500, {
                'erro': true,
              }),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(carteiraProvider);
      await _aguardarProvider();

      final state = container.read(carteiraProvider);
      expect(state.isOffline, isTrue);
      expect(state.data?.nome, 'Cache Local');
      expect(state.errorMessage, isNull);
    });

    test('descarta cache quando pertence a outro usuario', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token',
        'auth_username': 'usuario.novo',
        'carteira_cache_username': 'usuario.antigo',
        'carteira_cache_data': '{"nome":"Cache Antigo"}',
      });
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/carteiras-funcionais/dados': const FakeDioResponse(404, {
                'erro': true,
              }),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(carteiraProvider);
      await _aguardarProvider();

      final state = container.read(carteiraProvider);
      final storage = const FlutterSecureStorage();
      expect(state.data, isNull);
      expect(state.errorMessage, 'Carteira funcional não encontrada.');
      expect(await storage.read(key: 'carteira_cache_data'), isNull);
    });
  });
}

Future<void> _aguardarProvider() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
}
