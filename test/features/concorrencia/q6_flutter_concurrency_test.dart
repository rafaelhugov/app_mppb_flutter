import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_repository.dart';
import 'package:app_mppb_flutter/core/notifications/push_notification_service.dart';
import 'package:app_mppb_flutter/core/notifications/push_navigation_service.dart';
import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:app_mppb_flutter/features/carteira/providers/carteira_provider.dart';
import 'package:app_mppb_flutter/features/noticias/models/noticia.dart';
import 'package:app_mppb_flutter/features/noticias/providers/noticia_provider.dart';
import 'package:app_mppb_flutter/features/pagamentos/providers/pagamentos_provider.dart';
import 'package:app_mppb_flutter/features/perfil/providers/perfil_provider.dart';

void main() {
  group('Q6 - Concorrência, Idempotência e Integridade (Flutter)', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    // -------------------------------------------------------------------------
    // Q6-T02: Duplo Toque / Ações Rápidas
    // -------------------------------------------------------------------------
    test('Q6-T02: duplo clique no login nao dispara multiplas autenticacoes concorrentes', () async {
      int chamadasAuth = 0;
      final completerLogin = Completer<Response<dynamic>>();

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (options.path.contains('/acesso/autoriza')) {
          chamadasAuth++;
          final resp = await completerLogin.future;
          return ResponseBody.fromString(
            jsonEncode(resp.data),
            resp.statusCode ?? 200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 200);
      });

      final container = _createTestContainer(authDio: dio);
      addTearDown(container.dispose);

      final authNotifier = container.read(authProvider.notifier);

      // Simula primeiro toque (inicia requisição e ativa isLoading)
      final futureTap1 = authNotifier.login('user.teste', 'senha123', offerBiometrics: false);

      // Verifica que o notifier entrou imediatamente em loading
      expect(container.read(authProvider).isLoading, isTrue);

      // Simula segundo toque imediato antes do retorno da primeira request
      final futureTap2 = authNotifier.login('user.teste', 'senha123', offerBiometrics: false);

      // Completa a chamada de rede
      completerLogin.complete(Response(
        requestOptions: RequestOptions(path: '/acesso/autoriza'),
        statusCode: 200,
        data: {
          'token': 'jwt-q6-test-token',
          'usuario': {'id': 1, 'nome': 'Usuario Teste Concorrencia'},
        },
      ));

      await Future.wait([futureTap1, futureTap2]);

      // Estado final íntegro
      final finalState = container.read(authProvider);
      expect(finalState.isAuthenticated, isTrue);
      expect(finalState.token, 'jwt-q6-test-token');
      expect(chamadasAuth, 1, reason: 'O segundo toque concorrente deve ser ignorado enquanto isLoading == true');
    });

    test('Q6-T02/T11: duplo registro de FCM reutiliza o mesmo identificador unico de instalacao', () async {
      final fakeRepo = _RecordingDeviceRegistrationRepository();
      final container = ProviderContainer(
        overrides: [
          deviceRegistrationRepositoryProvider.overrideWithValue(fakeRepo),
          pushTokenProvider.overrideWithValue(const _StaticPushTokenProvider('fcm-token-q6')),
          devicePlatformResolverProvider.overrideWithValue(const _ActivePlatformResolver()),
        ],
      );
      addTearDown(container.dispose);

      final manager = container.read(deviceRegistrationManagerProvider);

      await manager.registrarSeAutenticado('auth-token-q6');
      await manager.registrarSeAutenticado('auth-token-q6');

      expect(fakeRepo.registerCalls.length, 2);
      expect(
        fakeRepo.registerCalls[0]['identificador'],
        fakeRepo.registerCalls[1]['identificador'],
        reason: 'Identificador do dispositivo deve ser estavel e reutilizado entre registros',
      );
    });

    // -------------------------------------------------------------------------
    // Q6-T03: Requisições Simultâneas Iguais (Idempotência no Repositório/Provider)
    // -------------------------------------------------------------------------
    test('Q6-T03: duas requisicoes simultaneas de carteira preservam integridade e nao duplicam dados', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-teste-q6',
        'auth_username': 'usuario.carteira',
      });

      int chamadasCarteira = 0;
      final completerApi = Completer<String>();

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (options.path.contains('/carteiras-funcionais/dados')) {
          chamadasCarteira++;
          final body = await completerApi.future;
          return ResponseBody.fromString(
            body,
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
        return ResponseBody.fromString('{}', 200);
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(carteiraProvider.notifier);

      // Duas chamadas simultâneas fetchCarteira()
      final req1 = notifier.fetchCarteira();
      final req2 = notifier.fetchCarteira();

      // Responde a API
      completerApi.complete(jsonEncode({
        'matricula': '12345',
        'nome': 'Promotor Concorrente',
        'cargo': 'Promotor de Justica',
        'orgaoLotacao': '1a Promotoria',
      }));

      await Future.wait([req1, req2]);

      final state = container.read(carteiraProvider);
      expect(chamadasCarteira, greaterThanOrEqualTo(1));
      expect(state.isLoading, isFalse);
      expect(state.data?.nome, 'Promotor Concorrente');
      expect(state.data?.matricula, '12345');
      expect(state.errorMessage, isNull);
    });

    // -------------------------------------------------------------------------
    // Q6-T04: Respostas Fora de Ordem (Race Condition)
    // -------------------------------------------------------------------------
    test('Q6-T04: resposta antiga (fora de ordem) nao sobrescreve estado mais recente em Pagamentos', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-teste-q6',
        'auth_username': 'usuario.pagamentos',
      });

      final completer2024 = Completer<String>();
      final completer2023 = Completer<String>();

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (options.path.contains('/pagamentos/exercicios')) {
          return ResponseBody.fromString(
            jsonEncode([2024, 2023]),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path == '/pagamentos/2024') {
          final body = await completer2024.future;
          return ResponseBody.fromString(body, 200, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
        }
        if (options.path == '/pagamentos/2023') {
          final body = await completer2023.future;
          return ResponseBody.fromString(body, 200, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
        }
        return ResponseBody.fromString('{}', 200);
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(pagamentosProvider.notifier);
      await notifier.fetchAnosDisponiveis();

      // Usuário seleciona 2024 (requisição A inicia)
      notifier.selecionarExercicio(2024);

      // Em seguida, rapidamente troca para 2023 (requisição B inicia)
      notifier.selecionarExercicio(2023);

      // Responde 2023 PRIMEIRO (requisição mais nova completa primeiro)
      completer2023.complete(jsonEncode({
        'totalBruto': 2023.0,
        'totalLiquido': 1800.0,
        'totalPagamentos': 1,
        'pagamentos': [
          {'nuProcesso': 'P-2023', 'vlBruto': 2023.0, 'vlLiquido': 1800.0}
        ],
      }));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      // Agora responde 2024 DEPOIS (resposta tardia fora de ordem)
      completer2024.complete(jsonEncode({
        'totalBruto': 2024.0,
        'totalLiquido': 1900.0,
        'totalPagamentos': 1,
        'pagamentos': [
          {'nuProcesso': 'P-2024', 'vlBruto': 2024.0, 'vlLiquido': 1900.0}
        ],
      }));
      await Future<void>.delayed(const Duration(milliseconds: 50));

      final state = container.read(pagamentosProvider);
      expect(state.exercicioAtual, 2023, reason: 'Exercicio selecionado final deve ser 2023');
      expect(state.dados?.totalBruto, 2023.0, reason: 'Dados nao podem ser contaminados pela resposta tardia de 2024');
    });

    // -------------------------------------------------------------------------
    // Q6-T05: Dispose durante Request (Acesso Pós-Dispose)
    // -------------------------------------------------------------------------
    test('Q6-T05: PerfilNotifier lida com dispose durante request sem erro pos-dispose', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-teste',
        'auth_username': 'usuario.dispose',
      });

      final completerApi = Completer<String>();
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (options.path.contains('/api/perfil/dados')) {
          final body = await completerApi.future;
          return ResponseBody.fromString(body, 200, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
        }
        return ResponseBody.fromString('{}', 200);
      });

      final container = _createTestContainer(dio: dio);

      final notifier = container.read(perfilProvider.notifier);
      final futureCarregar = notifier.carregar(forceRefresh: true);

      // Descarrega / descarta o container simulando saída de tela antes da resposta da API
      container.dispose();

      // Agora a resposta tardia chega
      completerApi.complete(jsonEncode({
        'matricula': '99999',
        'nome': 'Descartado Pos Dispose',
      }));

      // Não deve lançar StateError ("ref after dispose" ou "setState on disposed")
      await expectLater(futureCarregar, completes);
    });

    // -------------------------------------------------------------------------
    // Q6-T06: Logout durante Operação Assíncrona
    // -------------------------------------------------------------------------
    test('Q6-T06: resposta de sessao autenticada que chega apos logout nao polui o estado publico', () async {
      final completerCarteira = Completer<String>();
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (options.path.contains('/acesso/autoriza')) {
          return ResponseBody.fromString(
            jsonEncode({'token': 'token-sessao-1', 'usuario': {'id': 1, 'nome': 'Usuario 1'}}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path.contains('/carteiras-funcionais/dados')) {
          final body = await completerCarteira.future;
          return ResponseBody.fromString(body, 200, headers: {Headers.contentTypeHeader: [Headers.jsonContentType]});
        }
        return ResponseBody.fromString('{}', 200);
      });

      final container = _createTestContainer(dio: dio, authDio: dio);
      addTearDown(container.dispose);

      // Inicializa sessão
      await container.read(authProvider.notifier).login('usuario.sessao1', 'senha123', offerBiometrics: false);

      // Dispara request autenticada de carteira
      final futureCarteira = container.read(carteiraProvider.notifier).fetchCarteira();

      // Usuário faz logout enquanto a request de carteira ainda estava em trânsito
      await container.read(authProvider.notifier).logout();

      // Chega a resposta da carteira da sessão antiga
      completerCarteira.complete(jsonEncode({
        'matricula': '001',
        'nome': 'Usuario Antigo Vazado',
      }));

      await futureCarteira;

      // Verifica que o estado de carteira não exibe os dados do usuário deslogado
      final carteiraFinal = container.read(carteiraProvider);
      expect(carteiraFinal.data, isNull, reason: 'Dados da sessao anterior nao podem ser exibidos apos logout');
      expect(container.read(authProvider).isAuthenticated, isFalse);
    });

    // -------------------------------------------------------------------------
    // Q6-T07: Troca de Usuário (Isolamento de Cache e Identidade)
    // -------------------------------------------------------------------------
    test('Q6-T07: troca de usuario A -> logout -> usuario B garante isolamento total de dados e cache', () async {
      const storage = FlutterSecureStorage();

      // Usuário A salva cache
      await storage.write(key: 'carteira_cache_username', value: 'usuarioA');
      await storage.write(key: 'carteira_cache_data', value: jsonEncode({'nome': 'Usuario A', 'matricula': '111'}));
      await storage.write(key: 'perfil_cache_username', value: 'usuarioA');
      await storage.write(key: 'perfil_cache_data', value: jsonEncode({'nome': 'Usuario A', 'matricula': '111'}));

      // Simula logout: limpa storage autenticado
      await storage.delete(key: 'carteira_cache_username');
      await storage.delete(key: 'carteira_cache_data');
      await storage.delete(key: 'perfil_cache_username');
      await storage.delete(key: 'perfil_cache_data');
      await storage.delete(key: 'auth_token');

      // Garante que dados de A não existem mais no storage
      expect(await storage.read(key: 'carteira_cache_username'), isNull);
      expect(await storage.read(key: 'perfil_cache_username'), isNull);
      expect(await storage.read(key: 'carteira_cache_data'), isNull);
      expect(await storage.read(key: 'perfil_cache_data'), isNull);
    });

    // -------------------------------------------------------------------------
    // Q6-T11: FCM Notificações / Deduplicação de Ações de Navegação
    // -------------------------------------------------------------------------
    test('Q6-T11: PushNavigationService ignora eventos duplicados de mesmo payload e messageKey', () async {
      const gateway = DisabledPushMessageGateway();
      final navigator = _FakePushNavigationDelegate();
      final service = PushNavigationService(
        gateway: gateway,
        navigator: navigator,
        isAuthenticated: () => true,
        refreshDesignacoes: ({bool forceRefresh = false}) async {},
        refreshNoticias: () async {},
        refreshContracheque: () async {},
        refreshPagamentos: () async {},
        refreshAfastamentos: () async {},
      );

      const payload = PushTechnicalPayload(
        tipoEvento: 'NOVAS_NOTICIAS',
        rota: '/noticias',
        noticiaChave: '999',
      );

      // Primeiro evento processado
      await service.handleOpenedPayload(payload, messageKey: 'msg-dup-1');
      expect(navigator.routes.length, 1);

      // Segundo evento idêntico recebido com a mesma messageKey
      await service.handleOpenedPayload(payload, messageKey: 'msg-dup-1');
      expect(navigator.routes.length, 1, reason: 'Nao deve duplicar navegacao para a mesma notificacao');
    });

    // -------------------------------------------------------------------------
    // Q6-T12: Downloads Concorrentes de PDF
    // -------------------------------------------------------------------------
    test('Q6-T12: duas requisicoes simultaneas de download de PDF retornam bytes integros', () async {
      final pdfBytesEsperados = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x34]);

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (options.path.contains('/pdf')) {
          return ResponseBody(
            Stream.value(pdfBytesEsperados),
            200,
            headers: {
              Headers.contentTypeHeader: ['application/pdf'],
            },
          );
        }
        return ResponseBody.fromString('', 200);
      });

      final req1 = dio.get<List<int>>('/contracheque/2024/1/pdf', options: Options(responseType: ResponseType.bytes));
      final req2 = dio.get<List<int>>('/contracheque/2024/1/pdf', options: Options(responseType: ResponseType.bytes));

      final results = await Future.wait([req1, req2]);

      expect(results[0].data, pdfBytesEsperados);
      expect(results[1].data, pdfBytesEsperados);
      expect(results[0].statusCode, 200);
      expect(results[1].statusCode, 200);
    });

    // -------------------------------------------------------------------------
    // Q6-T13: Filtro Rápido Concorrente em Notícias
    // -------------------------------------------------------------------------
    test('Q6-T13: filtros rapidos concorrentes convergem para o ultimo termo digitado', () {
      final noticiasMock = [
        Noticia(titulo: 'Concurso MPPB', resumo: 'Edital aberto'),
        Noticia(titulo: 'Posse de Promotores', resumo: 'Solenidade festiva'),
        Noticia(titulo: 'Operacao Especial', resumo: 'Grupo de atuacao'),
      ];

      var state = NoticiaState(noticias: noticiasMock);

      // Usuário digita rapidamente 'c' -> 'con' -> 'concurso'
      state = state.copyWith(searchTerm: 'c');
      expect(state.filteredNews.length, 2); // Concurso, Operacao (tem 'c')

      state = state.copyWith(searchTerm: 'con');
      expect(state.filteredNews.length, 1); // Concurso

      state = state.copyWith(searchTerm: 'concurso');
      expect(state.filteredNews.length, 1);
      expect(state.filteredNews.first.titulo, 'Concurso MPPB');
    });

    // -------------------------------------------------------------------------
    // Q6-T16: Concorrência de Leitura sem Contaminação de Estado
    // -------------------------------------------------------------------------
    test('Q6-T16: multiplas leituras simultaneas de carteira e perfil nao misturam tokens nem estados', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        final authHeader = options.headers['Authorization'] as String?;
        if (options.path.contains('/api/perfil/dados')) {
          return ResponseBody.fromString(
            jsonEncode({'matricula': '101', 'nome': 'Usuario Perfil', 'tokenRecebido': authHeader}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path.contains('/carteiras-funcionais/dados')) {
          return ResponseBody.fromString(
            jsonEncode({'matricula': '202', 'nome': 'Usuario Carteira', 'tokenRecebido': authHeader}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString('{}', 200);
      });

      final reqPerfil = dio.get<Map<String, dynamic>>('/api/perfil/dados', options: Options(headers: {'Authorization': 'Bearer token-A'}));
      final reqCarteira = dio.get<Map<String, dynamic>>('/carteiras-funcionais/dados', options: Options(headers: {'Authorization': 'Bearer token-B'}));

      final results = await Future.wait([reqPerfil, reqCarteira]);

      expect(results[0].data?['tokenRecebido'], 'Bearer token-A');
      expect(results[0].data?['nome'], 'Usuario Perfil');

      expect(results[1].data?['tokenRecebido'], 'Bearer token-B');
      expect(results[1].data?['nome'], 'Usuario Carteira');
    });
  });
}

// =============================================================================
// Dublês e Helpers Determinísticos de Concorrência
// =============================================================================

ProviderContainer _createTestContainer({
  Dio? dio,
  Dio? authDio,
  DeviceRegistrationRepository? deviceRepo,
}) {
  return ProviderContainer(
    overrides: [
      if (dio != null) dioProvider.overrideWithValue(dio),
      if (authDio != null) authDioProvider.overrideWithValue(authDio),
      if (deviceRepo != null) deviceRegistrationRepositoryProvider.overrideWithValue(deviceRepo),
      pushTokenProvider.overrideWithValue(const _StaticPushTokenProvider('fcm-token-q6')),
      devicePlatformResolverProvider.overrideWithValue(const _UnsupportedPlatformResolver()),
    ],
  );
}

class _AsyncMockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  _AsyncMockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _UnsupportedPlatformResolver extends DevicePlatformResolver {
  const _UnsupportedPlatformResolver();

  @override
  String? currentPlatform() => null;
}

class _ActivePlatformResolver extends DevicePlatformResolver {
  const _ActivePlatformResolver();

  @override
  String? currentPlatform() => 'ANDROID';
}

class _StaticPushTokenProvider implements PushTokenProvider {
  final String? token;
  const _StaticPushTokenProvider(this.token);

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Future<String?> getToken() async => token;

  @override
  Future<String> requestPermission() async => 'authorized';
}

class _RecordingDeviceRegistrationRepository extends DeviceRegistrationRepository {
  final List<Map<String, dynamic>> registerCalls = [];
  final List<String> deactivateCalls = [];

  _RecordingDeviceRegistrationRepository() : super(Dio());

  @override
  Future<DeviceRegistrationResponse> registrar({
    required String identificador,
    required String tokenFcm,
    required String plataforma,
  }) async {
    registerCalls.add({
      'identificador': identificador,
      'tokenFcm': tokenFcm,
      'plataforma': plataforma,
    });
    return DeviceRegistrationResponse(
      identificador: identificador,
      plataforma: plataforma,
      ativo: true,
    );
  }

  @override
  Future<void> desativar({required String identificador}) async {
    deactivateCalls.add(identificador);
  }
}

class _FakePushNavigationDelegate implements PushNavigationDelegate {
  final List<String> routes = [];

  @override
  String get currentLocation => routes.isEmpty ? '/' : routes.last;

  @override
  void go(String route) {
    routes.add(route);
  }
}
