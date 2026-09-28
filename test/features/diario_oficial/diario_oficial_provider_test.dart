import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/features/diario_oficial/providers/diario_oficial_provider.dart';
import '../../helpers/fake_dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DiarioOficialNotifier', () {
    test('carrega diarios recentes e pagina a primeira pagina', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/public/diarios-oficiais/recentes': FakeDioResponse(
                200,
                List.generate(
                  10,
                  (index) => {
                    'id': index + 1,
                    'numeroEdicao': 100 + index,
                    'dataPublicacao':
                        '2026-09-${((index % 9) + 1).toString().padLeft(2, '0')}T00:00:00',
                    'idArquivo': 'arquivo-$index',
                  },
                ),
              ),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(diarioOficialProvider);
      await _aguardarProvider();

      final state = container.read(diarioOficialProvider);
      expect(state.isLoading, isFalse);
      expect(state.diarios, hasLength(10));
      expect(state.totalPages, 2);
      expect(state.paginatedDiarios, hasLength(9));
      expect(state.errorMessage, isNull);
    });

    test('retorno vazio mantem lista vazia sem erro', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/public/diarios-oficiais/recentes': const FakeDioResponse(
                200,
                [],
              ),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(diarioOficialProvider);
      await _aguardarProvider();

      final state = container.read(diarioOficialProvider);
      expect(state.diarios, isEmpty);
      expect(state.totalPages, 0);
      expect(state.errorMessage, isNull);
    });

    test('erro de carregamento popula mensagem local', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/public/diarios-oficiais/recentes': const FakeDioResponse(
                500,
                {'erro': true},
              ),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(diarioOficialProvider);
      await _aguardarProvider();

      final state = container.read(diarioOficialProvider);
      expect(state.isLoading, isFalse);
      expect(state.diarios, isEmpty);
      expect(
        state.errorMessage,
        'Não foi possível carregar os diários oficiais. Verifique sua conexão.',
      );
    });
  });
}

Future<void> _aguardarProvider() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
}
