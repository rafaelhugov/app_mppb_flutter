import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/features/certidao_extrajudicial/providers/certidao_extrajudicial_provider.dart';
import 'package:app_mppb_flutter/features/pagamentos/providers/pagamentos_provider.dart';
import 'package:app_mppb_flutter/features/processos/providers/processos_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio.dart';

void main() {
  group('Q4 integracao controlada Flutter', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({'auth_token': 'token-q4'});
    });

    test(
      'Pagamentos atravessa provider, storage, Dio e modelo tratando 503',
      () async {
        final requests = <FakeDioRequest>[];
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(
              dioComRotas({
                '/pagamentos/exercicios': const FakeDioResponse(200, [2026]),
                '/pagamentos/2026': const FakeDioResponse(503, {
                  'message': 'servico indisponivel',
                }),
              }, requests: requests),
            ),
          ],
        );
        addTearDown(container.dispose);

        container.read(pagamentosProvider);
        await _aguardarProvider();

        final state = container.read(pagamentosProvider);
        expect(
          requests.map((r) => '${r.method} ${r.path}'),
          containsAll(['GET /pagamentos/exercicios', 'GET /pagamentos/2026']),
        );
        expect(
          requests.every((r) => r.headers['Authorization'] == 'Bearer token-q4'),
          isTrue,
        );
        expect(state.anosDisponiveis, [2026]);
        expect(state.dados, isNull);
        expect(state.errorMessage, 'Erro no servidor: 503');
      },
    );

    test(
      'Processos diferencia timeout de tipo de atividade de erro generico',
      () async {
        final container = ProviderContainer(
          overrides: [
            dioProvider.overrideWithValue(
              dioComRotas({
                '/api/public/v1/processos/consulta':
                    const FakeDioResponse.exception(
                      DioExceptionType.receiveTimeout,
                    ),
              }),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container
            .read(consultaProcessosProvider.notifier)
            .buscarProcessos({'idTipoAtividade': 'T'});

        final state = container.read(consultaProcessosProvider);
        expect(state.resultados, isEmpty);
        expect(
          state.errorMessage,
          'A consulta por tipo de atividade demorou mais que o esperado. Combine com outro filtro ou tente novamente.',
        );
      },
    );

    test('Certidao propaga erro textual remoto sem bytes sensiveis', () async {
      final requests = <FakeDioRequest>[];
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/public/certidoes-extrajudiciais/pdf':
                  const FakeDioResponse(400, 'Nome obrigatorio'),
            }, requests: requests),
          ),
        ],
      );
      addTearDown(container.dispose);

      final bytes = await container
          .read(certidaoExtrajudicialProvider.notifier)
          .emitirPdf(
            tipoDocumento: 'F',
            documento: '123.456.789-00',
            nome: 'Pessoa Q4',
          );

      final state = container.read(certidaoExtrajudicialProvider);
      expect(bytes, isNull);
      expect(state.pdfBytes, isNull);
      expect(state.errorMessage, 'Nome obrigatorio');
      expect(requests.single.data, {
        'tipoDocumento': 'F',
        'documento': '12345678900',
        'nome': 'Pessoa Q4',
      });
      expect(requests.single.responseType, ResponseType.bytes);
    });
  });
}

Future<void> _aguardarProvider() async {
  await Future<void>.delayed(const Duration(milliseconds: 120));
}
