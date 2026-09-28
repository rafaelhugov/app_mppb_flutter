import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/features/pagamentos/providers/pagamentos_provider.dart';
import '../../helpers/fake_dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PagamentosNotifier', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'token'});
    });

    test('carrega exercicios e dados do exercicio mais recente', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/pagamentos/exercicios': const FakeDioResponse(200, [
                2026,
                2025,
              ]),
              '/pagamentos/2026': const FakeDioResponse(200, {
                'totalBruto': 1000.5,
                'totalLiquido': 900.25,
                'totalPagamentos': 1,
                'pagamentos': [
                  {
                    'nuProcesso': 123,
                    'dtPagamento': '2026-09-01',
                    'dsModalidadePag': 'PIX',
                    'vlBruto': 1000.5,
                    'vlLiquido': 900.25,
                  },
                ],
              }),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(pagamentosProvider);
      await _aguardarProvider();

      final state = container.read(pagamentosProvider);
      expect(state.isLoadingAnos, isFalse);
      expect(state.anosDisponiveis, [2026, 2025]);
      expect(state.exercicioAtual, 2026);
      expect(state.dados?.totalPagamentos, 1);
      expect(state.dados?.pagamentos.single.nuProcesso, '123');
      expect(state.errorMessage, isNull);
    });

    test('lista vazia de exercicios limpa dados sem erro', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/pagamentos/exercicios': const FakeDioResponse(200, []),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(pagamentosProvider);
      await _aguardarProvider();

      final state = container.read(pagamentosProvider);
      expect(state.isLoadingAnos, isFalse);
      expect(state.anosDisponiveis, isEmpty);
      expect(state.dados, isNull);
      expect(state.errorMessage, isNull);
    });

    test('404 em pagamentos do exercicio vira estado vazio', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/pagamentos/exercicios': const FakeDioResponse(200, [2026]),
              '/pagamentos/2026': const FakeDioResponse(404, {'erro': true}),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(pagamentosProvider);
      await _aguardarProvider();

      final state = container.read(pagamentosProvider);
      expect(state.exercicioAtual, 2026);
      expect(state.dados, isNull);
      expect(state.errorMessage, isNull);
    });
  });
}

Future<void> _aguardarProvider() async {
  await Future<void>.delayed(const Duration(milliseconds: 100));
}
