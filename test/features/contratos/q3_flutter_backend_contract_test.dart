import 'dart:typed_data';

import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_diagnostics_provider.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_repository.dart';
import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:app_mppb_flutter/features/carteira/providers/carteira_provider.dart';
import 'package:app_mppb_flutter/features/certidao_extrajudicial/providers/certidao_extrajudicial_provider.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/models/operacao_solicitacao_concessao.dart';
import 'package:app_mppb_flutter/features/concessao_afastamento/repositories/concessao_afastamento_repository.dart';
import 'package:app_mppb_flutter/features/contra_cheque/providers/contra_cheque_provider.dart';
import 'package:app_mppb_flutter/features/designacoes/repositories/designacoes_repository.dart';
import 'package:app_mppb_flutter/features/diario_oficial/providers/diario_oficial_provider.dart';
import 'package:app_mppb_flutter/features/noticias/providers/noticia_provider.dart';
import 'package:app_mppb_flutter/features/pagamentos/providers/pagamentos_provider.dart';
import 'package:app_mppb_flutter/features/perfil/repositories/perfil_repository.dart';
import 'package:app_mppb_flutter/features/processos/providers/processos_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_dio.dart';

void main() {
  group('Q3 contratos Flutter -> Backend', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-q3',
        'auth_username': 'usuario.q3',
      });
    });

    test(
      'Auth envia POST JSON para o gateway mobile e interpreta token',
      () async {
        final requests = <FakeDioRequest>[];
        final dio = dioComRotas({
          '$defaultApiUrl/acesso/autoriza': const FakeDioResponse(200, {
            'token': 'jwt-q3',
          }),
        }, requests: requests);
        final container = _container(authDio: dio);
        addTearDown(container.dispose);

        final result = await container
            .read(authProvider.notifier)
            .login('usuario.q3', 'senha', offerBiometrics: false);

        expect(result, isTrue);
        expect(requests.single.method, 'POST');
        expect(requests.single.path, '$defaultApiUrl/acesso/autoriza');
        expect(
          requests.single.headers['Content-Type'],
          contains('application/json'),
        );
        expect(requests.single.data, {
          'login': 'usuario.q3',
          'senha': 'senha',
          'siglaSistema': 'ANDROID',
        });
        expect(container.read(authProvider).token, 'jwt-q3');
      },
    );

    test(
      'Perfil envia Bearer para /api/perfil/dados e interpreta foto',
      () async {
        final requests = <FakeDioRequest>[];
        final dio = dioComRotas(
          {
            '/api/perfil/dados': const FakeDioResponse(200, {
              'login': 'usuario.q3',
              'nome': 'Pessoa Q3',
              'matricula': 123,
            }),
          },
          baseUrl: 'https://api.test',
          requests: requests,
        );

        final perfil = await PerfilRepository(
          dio,
        ).buscarPerfil(token: 'token-q3');

        expect(requests.single.method, 'GET');
        expect(requests.single.path, '/api/perfil/dados');
        expect(requests.single.headers['Authorization'], 'Bearer token-q3');
        expect(requests.single.extra['skipAuthLogout'], isTrue);
        expect(perfil.matricula, '123');
        expect(
          perfil.fotoUrl,
          startsWith('https://api.test/carteiras-funcionais/foto?v='),
        );
      },
    );

    test('Carteira busca dados com Bearer e monta URL de foto', () async {
      final requests = <FakeDioRequest>[];
      final container = _container(
        dio: dioComRotas(
          {
            '/carteiras-funcionais/dados': const FakeDioResponse(200, {
              'nome': 'Pessoa Q3',
              'matricula': 456,
            }),
          },
          baseUrl: 'https://api.test',
          requests: requests,
        ),
      );
      addTearDown(container.dispose);

      container.read(carteiraProvider);
      await _aguardarProvider();

      final state = container.read(carteiraProvider);
      expect(requests.single.method, 'GET');
      expect(requests.single.path, '/carteiras-funcionais/dados');
      expect(requests.single.headers['Authorization'], 'Bearer token-q3');
      expect(state.data?.matricula, '456');
      expect(
        state.data?.foto,
        startsWith('https://api.test/carteiras-funcionais/foto?v='),
      );
    });

    test('Contracheque usa competencias, mes/ano e PDF compatíveis', () async {
      final requests = <FakeDioRequest>[];
      final container = _container(
        dio: dioComRotas(
          {
            '/contracheques/competencias': const FakeDioResponse(200, [
              {'mes': 9, 'ano': 2026},
            ]),
            '/contracheques/9/2026': const FakeDioResponse(200, {
              'totalVantagens': 1000,
              'totalDescontos': 100,
              'salarioLiquido': 900,
              'lancamentos': [
                {
                  'codigo': 1,
                  'descricao': 'Vencimento',
                  'valor': 1000,
                  'tipo': 'V',
                },
              ],
            }),
          },
          baseUrl: 'https://api.test',
          requests: requests,
        ),
      );
      addTearDown(container.dispose);

      container.read(authProvider);
      await _aguardarProvider();
      container.read(contraChequeProvider);
      await _aguardarProvider();

      expect(
        requests.map((r) => '${r.method} ${r.path}'),
        containsAll([
          'GET /contracheques/competencias',
          'GET /contracheques/9/2026',
        ]),
      );
      expect(
        requests
            .firstWhere((r) => r.path == '/contracheques/competencias')
            .headers['Authorization'],
        'Bearer token-q3',
      );
      expect(
        container.read(contraChequeProvider).contrachequeAtual?.linkPdf,
        'https://api.test/contracheques/9/2026/pdf',
      );
    });

    test('Concessoes validam query, body, datas e operacoes', () async {
      final requests = <FakeDioRequest>[];
      final repo = ConcessaoAfastamentoRepository(
        dioComRotas({
          '/api/recursos-humanos/minhas-ausencias': const FakeDioResponse(
            200,
            [],
          ),
          '/api/recursos-humanos/concessoes/77/sugestoes-datas-finais':
              const FakeDioResponse(200, []),
          '/api/recursos-humanos/concessoes/77/solicitacoes':
              const FakeDioResponse(200, '{"id":88,"status":"P"}'),
          '/api/recursos-humanos/solicitacoes/88/suspensoes-parciais':
              const FakeDioResponse(200, '{}'),
        }, requests: requests),
      );

      await repo.buscarAusenciasCalendario(
        token: 'token-q3',
        mes: 9,
        ano: 2026,
      );
      await repo.buscarSugestoesDatasFinais(
        token: 'token-q3',
        concessaoId: 77,
        dataInicial: DateTime(2026, 9, 14),
      );
      await repo.solicitarGozo(
        token: 'token-q3',
        concessaoId: 77,
        dataInicial: DateTime(2026, 9, 14),
        numeroDias: 15,
      );
      await repo.executarOperacaoSolicitacao(
        token: 'token-q3',
        solicitacaoId: 88,
        operacao: OperacaoSolicitacaoConcessao.suspenderParcialmente,
        data: DateTime(2026, 9, 20),
        dataFim: DateTime(2026, 9, 21),
      );

      expect(requests[0].queryParameters, {'mes': 9, 'ano': 2026});
      expect(requests[1].queryParameters, {'dataInicial': '14/09/2026'});
      expect(requests[2].method, 'POST');
      expect(requests[2].data, {'dataInicial': '14/09/2026', 'numeroDias': 15});
      expect(requests[3].data, {
        'datasSuspensoes': [
          {
            'dataSuspensaoInicial': '20/09/2026',
            'dataSuspensaoFinal': '21/09/2026',
          },
        ],
      });
      expect(
        requests.every((r) => r.headers['Authorization'] == 'Bearer token-q3'),
        isTrue,
      );
    });

    test(
      'Pagamentos consulta exercicios e pagamentos por ano com Bearer',
      () async {
        final requests = <FakeDioRequest>[];
        final container = _container(
          dio: dioComRotas({
            '/pagamentos/exercicios': const FakeDioResponse(200, [2026]),
            '/pagamentos/2026': const FakeDioResponse(200, {
              'exercicio': 2026,
              'pagamentos': [],
            }),
          }, requests: requests),
        );
        addTearDown(container.dispose);

        container.read(pagamentosProvider);
        await _aguardarProvider();

        expect(
          requests.map((r) => '${r.method} ${r.path}'),
          containsAll(['GET /pagamentos/exercicios', 'GET /pagamentos/2026']),
        );
        expect(
          requests.every(
            (r) => r.headers['Authorization'] == 'Bearer token-q3',
          ),
          isTrue,
        );
        expect(container.read(pagamentosProvider).anosDisponiveis, [2026]);
      },
    );

    test(
      'Designacoes usa endpoint autenticado e interpreta resposta vazia',
      () async {
        final requests = <FakeDioRequest>[];
        final repo = DesignacoesRepository(
          dioComRotas({
            '/api/designacoes/ativas': const FakeDioResponse(200, {
              'tipoUsuario': 'MEMBRO',
              'designacoes': [],
            }),
          }, requests: requests),
        );

        final response = await repo.buscarAtivas(token: 'token-q3');

        expect(requests.single.method, 'GET');
        expect(requests.single.path, '/api/designacoes/ativas');
        expect(requests.single.headers['Authorization'], 'Bearer token-q3');
        expect(response.designacoes, isEmpty);
      },
    );

    test(
      'Notificacoes/FCM usa registro, diagnostico e desativacao esperados',
      () async {
        final requests = <FakeDioRequest>[];
        final repo = DeviceRegistrationRepository(
          dioComRotas({
            '/api/notificacoes/dispositivos': const FakeDioResponse(200, {
              'identificador': 'device-1',
              'plataforma': 'ANDROID',
              'ativo': true,
            }),
            '/api/notificacoes/dispositivos/diagnostico': const FakeDioResponse(
              202,
              null,
            ),
            '/api/notificacoes/dispositivos/device-1': const FakeDioResponse(
              204,
              null,
            ),
          }, requests: requests),
        );

        final registered = await repo.registrar(
          identificador: 'device-1',
          tokenFcm: 'fcm-token',
          plataforma: 'ANDROID',
        );
        await repo.diagnosticar(
          const DeviceRegistrationDiagnosticsState(
            step: DeviceRegistrationStep.registered,
            message: 'ok',
            permissionStatus: 'authorized',
            hasToken: true,
            tokenLength: 9,
            backendStatus: 200,
          ),
        );
        await repo.desativar(identificador: 'device-1');

        expect(registered.ativo, isTrue);
        expect(requests[0].method, 'POST');
        expect(requests[0].data, {
          'identificador': 'device-1',
          'tokenFcm': 'fcm-token',
          'plataforma': 'ANDROID',
        });
        expect(requests[1].path, '/api/notificacoes/dispositivos/diagnostico');
        expect(requests[1].data, containsPair('etapa', 'registered'));
        expect(requests[2].method, 'DELETE');
        expect(requests[2].path, '/api/notificacoes/dispositivos/device-1');
        expect(
          requests.every((r) => r.extra['skipAuthLogout'] == true),
          isTrue,
        );
      },
    );

    test(
      'Processos e captcha usam filtros, consulta e detalhes com query',
      () async {
        final requests = <FakeDioRequest>[];
        final container = _container(
          dio: dioComRotas({
            '/api/public/v1/processos/filtros': const FakeDioResponse(200, {
              'comarcas': [],
              'classes': [],
              'tiposAtividade': [],
              'status': [],
            }),
            '/api/public/v1/processos/consulta': const FakeDioResponse(200, []),
            '/api/public/v1/captcha': const FakeDioResponse(200, {
              'imageBase64': 'data:image/png;base64,AAAA',
              'token': 'captcha-token',
            }),
            '/api/public/v1/processos/123/detalhes':
                const FakeDioResponse(200, {
                  'id': 123,
                  'numeroProcesso': '001',
                  'movimentos': [],
                  'interessados': [],
                }),
          }, requests: requests),
        );
        addTearDown(container.dispose);

        await container
            .read(consultaProcessosProvider.notifier)
            .carregarFiltros();
        await container
            .read(consultaProcessosProvider.notifier)
            .buscarProcessos({'idComarca': 1, 'numeroProcesso': '001'});
        final captcha = await container.read(captchaProvider.future);
        final detalhe = await container.read(
          processoDetalhesProvider(
            ProcessoDetalheParams(
              idProcesso: '123',
              captchaToken: 'captcha-token',
              captchaValue: 'abc123',
            ),
          ).future,
        );

        expect(captcha['token'], 'captcha-token');
        expect(detalhe.id, 123);
        expect(requests[0].path, '/api/public/v1/processos/filtros');
        expect(requests[1].method, 'POST');
        expect(requests[1].data, {'idComarca': 1, 'numeroProcesso': '001'});
        expect(requests[2].path, '/api/public/v1/captcha');
        expect(requests[3].queryParameters, {
          'captchaToken': 'captcha-token',
          'captchaValue': 'abc123',
        });
      },
    );

    test('Noticias e Diario Oficial consomem listas publicas', () async {
      final requests = <FakeDioRequest>[];
      final container = _container(
        dio: dioComRotas({
          '/api/public/noticias': const FakeDioResponse(200, [
            {'titulo': 'Noticia Q3', 'link': 'https://mppb.test/noticia'},
          ]),
          '/api/public/diarios-oficiais/recentes': const FakeDioResponse(200, [
            {
              'id': 1,
              'numeroEdicao': '100',
              'dataPublicacao': '2026-09-28',
              'idArquivo': 'abc',
            },
          ]),
        }, requests: requests),
      );
      addTearDown(container.dispose);

      container.read(noticiaProvider);
      container.read(diarioOficialProvider);
      await _aguardarProvider();

      expect(
        requests.map((r) => r.path),
        containsAll([
          '/api/public/noticias',
          '/api/public/diarios-oficiais/recentes',
        ]),
      );
      expect(
        container.read(noticiaProvider).noticias.single.titulo,
        'Noticia Q3',
      );
      expect(container.read(diarioOficialProvider).diarios.single.id, '1');
    });

    test(
      'Certidao valida JSON de emissao, consulta por codigo e PDF bytes',
      () async {
        final requests = <FakeDioRequest>[];
        final container = _container(
          dio: dioComRotas({
            '/api/public/certidoes-extrajudiciais/pdf': FakeDioResponse(
              200,
              Uint8List.fromList([37, 80, 68, 70]),
              headers: {
                Headers.contentTypeHeader: ['application/pdf'],
              },
            ),
            '/api/public/certidoes-extrajudiciais/codigo/ABC-123':
                const FakeDioResponse(200, {
                  'codigo': 'ABC-123',
                  'nome': 'Pessoa Q3',
                  'protocolo': 123,
                }),
            '/api/public/certidoes-extrajudiciais/codigo/ABC-123/pdf':
                FakeDioResponse(200, Uint8List.fromList([37, 80, 68, 70])),
          }, requests: requests),
        );
        addTearDown(container.dispose);

        final notifier = container.read(certidaoExtrajudicialProvider.notifier);
        final emitted = await notifier.emitirPdf(
          tipoDocumento: 'F',
          documento: '123.456.789-00',
          nome: ' Pessoa Q3 ',
        );
        await notifier.consultarCodigo('ABC-123');
        final downloaded = await notifier.baixarPdfPorCodigo('ABC-123');

        expect(emitted, [37, 80, 68, 70]);
        expect(downloaded, [37, 80, 68, 70]);
        expect(requests[0].method, 'POST');
        expect(requests[0].data, {
          'tipoDocumento': 'F',
          'documento': '12345678900',
          'nome': 'Pessoa Q3',
        });
        expect(requests[0].responseType, ResponseType.bytes);
        expect(
          requests[1].path,
          '/api/public/certidoes-extrajudiciais/codigo/ABC-123',
        );
        expect(requests[2].responseType, ResponseType.bytes);
      },
    );
  });
}

ProviderContainer _container({Dio? dio, Dio? authDio}) {
  return ProviderContainer(
    overrides: [
      if (dio != null) dioProvider.overrideWithValue(dio),
      if (authDio != null) authDioProvider.overrideWithValue(authDio),
      devicePlatformResolverProvider.overrideWithValue(
        const _UnsupportedPlatformResolver(),
      ),
    ],
  );
}

Future<void> _aguardarProvider() async {
  await Future<void>.delayed(const Duration(milliseconds: 150));
}

class _UnsupportedPlatformResolver extends DevicePlatformResolver {
  const _UnsupportedPlatformResolver();

  @override
  String? currentPlatform() => null;
}
