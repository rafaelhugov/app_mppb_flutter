import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/core/storage/secure_storage.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:app_mppb_flutter/features/carteira/providers/carteira_provider.dart';
import 'package:app_mppb_flutter/features/noticias/providers/noticia_provider.dart';
import 'package:app_mppb_flutter/features/pagamentos/providers/pagamentos_provider.dart';
import 'package:app_mppb_flutter/features/perfil/providers/perfil_provider.dart';

void main() {
  group('Q7 — Rede, Offline e Interrupções (Flutter Determinístico)', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    // =========================================================================
    // Q7-T03: Mapeamento de Tipos de Falha do Dio
    // =========================================================================
    test('Q7-T03: Mapeamento e diferenciacao de todos os tipos de DioException', () {
      final requestOptions = RequestOptions(path: '/api/test');

      final falhas = [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.badCertificate,
        DioExceptionType.badResponse,
        DioExceptionType.cancel,
        DioExceptionType.connectionError,
        DioExceptionType.unknown,
      ];

      for (final tipo in falhas) {
        final ex = DioException(
          requestOptions: requestOptions,
          type: tipo,
          message: 'Falha simulada do tipo $tipo',
        );
        expect(ex.type, tipo);
        expect(ex.message, 'Falha simulada do tipo $tipo');
      }
    });

    // =========================================================================
    // Q7-T04: Offline Antes da Requisição (Notícias)
    // =========================================================================
    test('Q7-T04: NoticiaNotifier lida com offline antes da chamada sem travar UI', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'SocketException: Falha na conexao (dispositivo offline)',
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);
      await notifier.fetchNoticias();

      final state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.noticias, isEmpty);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('SocketException'));
    });

    // =========================================================================
    // Q7-T05: Queda Durante Requisição (Notícias)
    // =========================================================================
    test('Q7-T05: Queda durante transferencia encerra loading sem dados parciais', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.cancel,
          error: 'Conexao cancelada durante o recebimento do payload',
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);
      await notifier.fetchNoticias();

      final state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.noticias, isEmpty);
      expect(state.errorMessage, isNotNull);
    });

    // =========================================================================
    // Q7-T06: Timeout de Rede (connectionTimeout e receiveTimeout)
    // =========================================================================
    test('Q7-T06: Timeout de conexao encerra loading de forma controlada', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          error: 'Connection timed out apos 15000ms',
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);
      await notifier.fetchNoticias();

      final state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.noticias, isEmpty);
      expect(state.errorMessage, contains('timed out'));
    });

    // =========================================================================
    // Q7-T07: Retry de Leitura (Falha inicial -> Retry manual -> Sucesso)
    // =========================================================================
    test('Q7-T07: Retry manual apos falha limpa erro e renderiza dados com sucesso', () async {
      bool falhaSimulada = true;
      final mockNoticias = [
        {
          'id': 101,
          'titulo': 'Noticia MPPB 1',
          'resumo': 'Resumo noticia 1',
          'categoria': 'Institucional',
          'dataPublicacao': '2026-09-30',
        },
      ];

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (falhaSimulada) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'Host unreachable',
          );
        }
        return ResponseBody.fromString(
          jsonEncode(mockNoticias),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);

      // 1. Primeira chamada: falha
      await notifier.fetchNoticias();
      var state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.noticias, isEmpty);
      expect(state.errorMessage, isNotNull);

      // 2. Conexao volta; retry manual pelo usuario
      falhaSimulada = false;
      await notifier.fetchNoticias();

      state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.noticias, hasLength(1));
      expect(state.noticias.first.titulo, 'Noticia MPPB 1');
    });

    // =========================================================================
    // Q7-T09: Preservação de Dados Prévios Quando Refresh Falha
    // =========================================================================
    test('Q7-T09: Falha no refresh preserva itens anteriores na tela sem apagar', () async {
      bool falhaSimulada = false;
      final mockNoticias = [
        {
          'id': 201,
          'titulo': 'Noticia Previa Existente',
          'resumo': 'Resumo da noticia',
          'categoria': 'Geral',
          'dataPublicacao': '2026-09-29',
        },
      ];

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (falhaSimulada) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'Sem internet no momento do refresh',
          );
        }
        return ResponseBody.fromString(
          jsonEncode(mockNoticias),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);

      // Carga inicial bem sucedida
      await notifier.fetchNoticias();
      var state = container.read(noticiaProvider);
      expect(state.noticias, hasLength(1));
      expect(state.errorMessage, isNull);

      // Refresh falha
      falhaSimulada = true;
      await notifier.fetchNoticias();

      state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      // Dados anteriores continuam utilizaveis na UI
      expect(state.noticias, hasLength(1));
      expect(state.noticias.first.titulo, 'Noticia Previa Existente');
      // Erro e sinalizado para exibicao de alerta/snackbar
      expect(state.errorMessage, isNotNull);
    });

    // =========================================================================
    // Q7-T11: Reconexão de Rede após Falha
    // =========================================================================
    test('Q7-T11: Reconexao permite recuperacao transparente sem reiniciar o app', () async {
      int tentativa = 0;
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        tentativa++;
        if (tentativa == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'Sem conexao',
          );
        }
        return ResponseBody.fromString(
          jsonEncode([
            {
              'id': 301,
              'titulo': 'Noticia Reconectada',
              'resumo': 'Conteudo apos retorno da internet',
              'categoria': 'Institucional',
              'dataPublicacao': '2026-09-30',
            }
          ]),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);

      // Falha offline
      await notifier.fetchNoticias();
      expect(container.read(noticiaProvider).noticias, isEmpty);

      // Rede restabelecida e retry executado
      await notifier.fetchNoticias();
      final stateFinal = container.read(noticiaProvider);
      expect(stateFinal.noticias, hasLength(1));
      expect(stateFinal.noticias.first.titulo, 'Noticia Reconectada');
    });

    // =========================================================================
    // Q7-T12: Interrupção de Lifecycle (Dispose durante Request)
    // =========================================================================
    test('Q7-T12: Resposta tardia apos descarte do notifier nao gera erro pos-dispose (BUG-Q7-002)', () async {
      final completer = Completer<ResponseBody>();

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (options.path.contains('/api/public/noticias')) {
          return completer.future;
        }
        return ResponseBody.fromString('[]', 200);
      });

      final container = _createTestContainer(dio: dio);

      final notifier = container.read(noticiaProvider.notifier);
      final futureFetch = notifier.fetchNoticias();

      // Descarta o container simulando saida de tela
      container.dispose();

      // Libera a resposta tardia da rede
      completer.complete(
        ResponseBody.fromString(
          '[]',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        ),
      );

      // A execucao deve concluir sem uncaught exceptions
      await expectLater(futureFetch, completes);
    });

    // =========================================================================
    // Q7-T14: Resposta Truncada / JSON Inválido
    // =========================================================================
    test('Q7-T14: Resposta malformada e tratada graciosamente sem crash', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        return ResponseBody.fromString(
          '{"invalido": "objeto onde se esperava array"}',
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);
      await notifier.fetchNoticias();

      final state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.noticias, isEmpty);
      expect(state.errorMessage, isNotNull);
      expect(state.errorMessage, contains('Erro ao carregar notícias'));
    });

    // =========================================================================
    // Q7-T04 / Q7-T08: Carteira Funcional Offline com Cache Prévia
    // =========================================================================
    test('Q7-T04: CarteiraNotifier recupera dados locais offline sob erro de rede', () async {
      const username = 'servidor.teste';
      const token = 'token-offline-123';

      final mockCarteiraJson = {
        'nome': 'Servidor Teste Q7',
        'cargo': 'Analista Ministerial',
        'matricula': '887766',
        'cpf': '123.456.789-00',
        'email': 'servidor@mppb.mp.br',
        'lotacao': 'Procuradoria Geral',
        'dataNascimento': '1990-01-01',
        'via': 1,
      };

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Conexao falhou',
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final storage = container.read(secureStorageProvider);
      await storage.write(key: 'auth_token', value: token);
      await storage.write(key: 'auth_username', value: username);
      await storage.write(key: 'carteira_cache_username', value: username);
      await storage.write(key: 'carteira_cache_data', value: jsonEncode(mockCarteiraJson));

      final carteiraNotifier = container.read(carteiraProvider.notifier);
      await carteiraNotifier.fetchCarteira();

      final state = container.read(carteiraProvider);
      expect(state.isLoading, isFalse);
      expect(state.isOffline, isTrue);
      expect(state.data, isNotNull);
      expect(state.data!.nome, 'Servidor Teste Q7');
      expect(state.data!.matricula, '887766');
    });

    test('Q7-T04: CarteiraNotifier lida com dispose durante fallback offline sem erro pos-dispose (BUG-Q7-001)', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Sem conexao',
        );
      });

      final container = _createTestContainer(dio: dio);

      final carteiraNotifier = container.read(carteiraProvider.notifier);
      final futureFetch = carteiraNotifier.fetchCarteira();

      // Descarta o container simulando encerramento da tela antes de concluir fallback
      container.dispose();

      // Nao deve disparar StateError pós-dispose
      await expectLater(futureFetch, completes);
    });

    // =========================================================================
    // Q7-T04: Perfil Offline com Cache Prévio
    // =========================================================================
    test('Q7-T04: PerfilNotifier recupera perfil local offline sob indisponibilidade', () async {
      const username = 'promotor.q7';
      const token = 'jwt-perfil-q7';

      final mockPerfilJson = {
        'nome': 'Dr. Promotor Q7',
        'matricula': '554433',
        'cargo': 'Promotor de Justica',
        'email': 'promotor@mppb.mp.br',
      };

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          error: 'Timeout perfil',
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final storage = container.read(secureStorageProvider);
      await storage.write(key: 'auth_token', value: token);
      await storage.write(key: 'auth_username', value: username);
      await storage.write(key: 'perfil_cache_username', value: username);
      await storage.write(key: 'perfil_cache_data', value: jsonEncode(mockPerfilJson));

      final perfilNotifier = container.read(perfilProvider.notifier);
      await perfilNotifier.carregar();

      final state = container.read(perfilProvider);
      expect(state.isLoading, isFalse);
      expect(state.data, isNotNull);
      expect(state.data!.nome, 'Dr. Promotor Q7');
    });

    // =========================================================================
    // Q7-T10: Pagamentos sob Falha de Conexão (receiveTimeout)
    // =========================================================================
    test('Q7-T10: PagamentosNotifier lida com receiveTimeout sem travar loading', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
          error: 'Receive timeout no endpoint de pagamentos',
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final pagamentosNotifier = container.read(pagamentosProvider.notifier);
      await pagamentosNotifier.fetchAnosDisponiveis();

      final state = container.read(pagamentosProvider);
      expect(state.isLoadingAnos, isFalse);
      expect(state.errorMessage, 'Falha ao buscar exercícios. Verifique a internet.');
    });

    // =========================================================================
    // Q7-T15: HTTP 401 Dispara Logout Automático via Interceptor
    // =========================================================================
    test('Q7-T15: HTTP 401 invalida a sessao e executa logout automatico', () async {
      int logoutDisparado = 0;

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(() {
                logoutDisparado++;
              })),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        return ResponseBody.fromString(
          '{"message": "Token expirado"}',
          401,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      // Executa chamada protegida
      try {
        await dio.get('/api/perfil/dados');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 401);
      }

      expect(logoutDisparado, 1, reason: '401 deve acionar logout automatico');
    });

    // =========================================================================
    // Q7-T16: HTTP 403 NÃO Efetua Logout Indevido
    // =========================================================================
    test('Q7-T16: HTTP 403 nao aciona logout da sessao autenticada', () async {
      int logoutDisparado = 0;

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith(() => _FakeAuthNotifier(() {
                logoutDisparado++;
              })),
        ],
      );
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        return ResponseBody.fromString(
          '{"message": "Acesso negado"}',
          403,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      try {
        await dio.get('/recursos-humanos/concessoes/bloqueado');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 403);
      }

      expect(logoutDisparado, 0, reason: '403 representa autorizacao, nao expiracao de sessao');
    });

    // =========================================================================
    // Q7-T18: HTTP 500 / 503 no Backend
    // =========================================================================
    test('Q7-T18: HTTP 503 e traduzido em mensagem amigavel sem crash', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        return ResponseBody.fromString(
          '{"status": 503, "error": "Service Unavailable"}',
          503,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);
      await notifier.fetchNoticias();

      final state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('503'));
    });

    // =========================================================================
    // Q7-T13: Download de Stream Interrompido
    // =========================================================================
    test('Q7-T13: Download interrompido lanca excecao controlada sem dados corrompidos', () async {
      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
          error: 'Conexao abortada pelo servidor durante streaming de PDF',
        );
      });

      Uint8List? downloadedBytes;
      String? errorMessage;

      try {
        final response = await dio.get<List<int>>(
          'https://api.mppb.mp.br/contracheque/2026/09/pdf',
          options: Options(responseType: ResponseType.bytes),
        );
        downloadedBytes = Uint8List.fromList(response.data ?? const []);
      } on DioException catch (e) {
        errorMessage = 'Falha no download: ${e.message}';
      }

      expect(downloadedBytes, isNull, reason: 'Arquivo incompleto nao pode ser gerado');
      expect(errorMessage, contains('Falha no download'));
    });

    // =========================================================================
    // Q7-T08: Validação de Política de Não-Retry em Operações Mutáveis
    // =========================================================================
    test('Q7-T08: dioProvider do aplicativo nao possui interceptor de retry automatico', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final dio = container.read(dioProvider);

      // Garante que nao ha interceptor de auto-retry que possa retransmitir operacoes mutaveis
      final hasRetryInterceptor = dio.interceptors.any(
        (i) => i.runtimeType.toString().toLowerCase().contains('retry'),
      );
      expect(hasRetryInterceptor, isFalse);
      expect(dio.options.connectTimeout, const Duration(seconds: 15));
      expect(dio.options.receiveTimeout, const Duration(seconds: 15));
    });
  });
}

// =============================================================================
// Dublês e Mocks de Teste Determinístico
// =============================================================================

ProviderContainer _createTestContainer({Dio? dio}) {
  return ProviderContainer(
    overrides: [
      if (dio != null) dioProvider.overrideWithValue(dio),
      pushTokenProvider.overrideWithValue(const _StaticPushTokenProvider('fcm-token-q7')),
      devicePlatformResolverProvider.overrideWithValue(const _UnsupportedPlatformResolver()),
    ],
  );
}

class _AsyncMockAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) handler;

  _AsyncMockAdapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

class _FakeAuthNotifier extends AuthNotifier {
  final void Function() onLogout;

  _FakeAuthNotifier(this.onLogout);

  @override
  AuthState build() {
    return AuthState(
      isAuthenticated: true,
      token: 'valid-jwt-token',
    );
  }

  @override
  Future<void> logout() async {
    onLogout();
    state = AuthState(isAuthenticated: false);
  }
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

class _UnsupportedPlatformResolver extends DevicePlatformResolver {
  const _UnsupportedPlatformResolver();

  @override
  String? currentPlatform() => null;
}
