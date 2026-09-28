import 'dart:typed_data';

import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/features/certidao_extrajudicial/providers/certidao_extrajudicial_provider.dart';
import '../../helpers/fake_dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CertidaoExtrajudicialNotifier', () {
    test('estado inicial nao possui carregamento nem dados', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(certidaoExtrajudicialProvider);
      expect(state.isLoading, isFalse);
      expect(state.isPdfLoading, isFalse);
      expect(state.certidao, isNull);
      expect(state.pdfBytes, isNull);
      expect(state.errorMessage, isNull);
    });

    test('consulta por codigo popula certidao com campos opcionais', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/public/certidoes-extrajudiciais/codigo/ABC123':
                  const FakeDioResponse(200, {
                    'id': '42',
                    'codigoVerificador': 'ABC123',
                    'nome': 'Pessoa Teste',
                    'negativa': true,
                    'protocolos': [
                      {'numero': 123, 'classe': 'Classe'},
                    ],
                  }),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(certidaoExtrajudicialProvider.notifier)
          .consultarCodigo(' ABC123 ');

      final state = container.read(certidaoExtrajudicialProvider);
      expect(state.isLoading, isFalse);
      expect(state.certidao?.id, 42);
      expect(state.certidao?.protocolos.single.numero, '123');
      expect(state.errorMessage, isNull);
    });

    test('erro textual da API vira mensagem local', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/public/certidoes-extrajudiciais/codigo/XYZ':
                  const FakeDioResponse(400, 'Codigo invalido'),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(certidaoExtrajudicialProvider.notifier)
          .consultarCodigo('XYZ');

      final state = container.read(certidaoExtrajudicialProvider);
      expect(state.certidao, isNull);
      expect(state.errorMessage, 'Codigo invalido');
    });

    test('emissao de PDF retorna bytes', () async {
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(
            dioComRotas({
              '/api/public/certidoes-extrajudiciais/pdf': FakeDioResponse(
                200,
                Uint8List.fromList([1, 2, 3]),
              ),
            }),
          ),
        ],
      );
      addTearDown(container.dispose);

      final bytes = await container
          .read(certidaoExtrajudicialProvider.notifier)
          .emitirPdf(
            tipoDocumento: 'CPF',
            documento: '123.456.789-00',
            nome: 'A',
          );

      expect(bytes, [1, 2, 3]);
      expect(container.read(certidaoExtrajudicialProvider).pdfBytes, [1, 2, 3]);
    });
  });
}
