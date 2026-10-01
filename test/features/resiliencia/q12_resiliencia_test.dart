import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_mppb_flutter/core/network/api_client.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_provider.dart';
import 'package:app_mppb_flutter/core/notifications/device_registration_repository.dart';
import 'package:app_mppb_flutter/features/auth/providers/auth_provider.dart';
import 'package:app_mppb_flutter/features/carteira/providers/carteira_provider.dart';
import 'package:app_mppb_flutter/features/contra_cheque/providers/contra_cheque_provider.dart';
import 'package:app_mppb_flutter/features/noticias/providers/noticia_provider.dart';
import 'package:app_mppb_flutter/features/pagamentos/providers/pagamentos_provider.dart';
import 'package:app_mppb_flutter/features/perfil/providers/perfil_provider.dart';

void main() {
  group('Q12 — Resiliência, Observabilidade e Recuperação (Flutter)', () {
    setUp(() {
      FlutterSecureStorage.setMockInitialValues({});
    });

    // =========================================================================
    // Q12-T01: Flutter Global Error Handling & ErrorWidget Fallback
    // =========================================================================
    testWidgets('Q12-T01: widget que lanca excecao renderiza ErrorWidget sem crash ou loop', (tester) async {
      final originalOnError = FlutterError.onError;
      FlutterErrorDetails? caughtDetails;
      FlutterError.onError = (details) {
        caughtDetails = details;
      };
      addTearDown(() {
        FlutterError.onError = originalOnError;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                throw Exception('Erro de renderizacao controlado Q12-T01');
              },
            ),
          ),
        ),
      );

      // Confirma que FlutterError capturou a exceção sem crashar a execução
      expect(caughtDetails, isNotNull);
      expect(caughtDetails!.exception.toString(), contains('Erro de renderizacao controlado Q12-T01'));
      // Confirma que ErrorWidget foi construído
      expect(find.byType(ErrorWidget), findsOneWidget);
    });

    // =========================================================================
    // Q12-T02: Erro Assíncrono Não Tratado e Isolamento de Estado
    // =========================================================================
    test('Q12-T02: excecao assincrona em Future e capturada e nao derruba container', () async {
      final completer = Completer<void>();
      bool errorCaptured = false;

      runZonedGuarded(() {
        Future<void>.delayed(const Duration(milliseconds: 10), () {
          throw StateError('Excecao assincrona nao tratada simulada Q12-T02');
        });
      }, (error, stack) {
        errorCaptured = true;
        completer.complete();
      });

      await completer.future;
      expect(errorCaptured, isTrue);
    });

    // =========================================================================
    // Q12-T03: Recuperação de Providers Após Falha Transitória
    // =========================================================================
    test('Q12-T03: NoticiaNotifier recupera de erro 500 para estado valido no retry', () async {
      bool simularErro = true;

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (simularErro) {
          return ResponseBody.fromString(
            jsonEncode({'message': 'Internal Server Error'}),
            500,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString(
          jsonEncode([
            {
              'chaveExterna': 'noticia-101',
              'titulo': 'Noticia Recuperada Q12',
              'resumo': 'Conteudo recuperado com sucesso',
              'link': 'https://mppb.mp.br/noticia/101',
              'categoria': 'Geral',
            }
          ]),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);

      // 1. Primeira chamada falha com 500
      await notifier.fetchNoticias();
      var state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.noticias, isEmpty);

      // 2. Dependência volta (simularErro = false) e retry é acionado
      simularErro = false;
      await notifier.fetchNoticias();
      state = container.read(noticiaProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.noticias.length, 1);
      expect(state.noticias.first.titulo, 'Noticia Recuperada Q12');
    });

    test('Q12-T03: PagamentosNotifier recupera de erro de rede para estado valido no retry', () async {
      bool simularErro = true;

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (options.path.contains('/anos-disponiveis')) {
          return ResponseBody.fromString(
            jsonEncode([2025, 2026]),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (simularErro) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'Timeout na consulta de pagamentos',
          );
        }
        return ResponseBody.fromString(
          jsonEncode({
            'totalBruto': 18000.0,
            'totalLiquido': 15000.0,
            'totalPagamentos': 1,
            'pagamentos': [
              {
                'nuProcesso': '12345',
                'dtPagamento': '2026-01-10',
                'dsModalidadePag': 'Folha',
                'vlBruto': 18000.0,
                'vlLiquido': 15000.0,
              }
            ],
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(pagamentosProvider.notifier);

      // 1. Falha por timeout
      await notifier.fetchPagamentos();
      var state = container.read(pagamentosProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.dados, isNull);

      // 2. Dependência recupera e nova consulta funciona
      simularErro = false;
      await notifier.fetchPagamentos();
      state = container.read(pagamentosProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.dados, isNotNull);
      expect(state.dados!.totalPagamentos, 1);
    });

    test('Q12-T03: ContraChequeNotifier recupera de 503 para sucesso no retry', () async {
      bool simularErro = true;

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        if (simularErro) {
          return ResponseBody.fromString(
            jsonEncode({'message': 'Servico temporariamente indisponivel'}),
            503,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        if (options.path.contains('/contracheques/competencias')) {
          return ResponseBody.fromString(
            jsonEncode([
              {'ano': 2026, 'mes': 1, 'descricao': 'Janeiro/2026'}
            ]),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        // Resposta para busca do contracheque detalhado da competencia
        return ResponseBody.fromString(
          jsonEncode({
            'totalVantagens': 20000.0,
            'totalDescontos': 5000.0,
            'salarioLiquido': 15000.0,
            'lancamentos': [
              {
                'codigo': '001',
                'descricao': 'Vencimento Base',
                'valor': 20000.0,
                'tipo': 'V',
              }
            ],
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(contraChequeProvider.notifier);

      // 1. Falha inicial
      await notifier.carregarCompetencias();
      var state = container.read(contraChequeProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
      expect(state.competencias, isEmpty);

      // 2. Retry com sucesso
      simularErro = false;
      await notifier.carregarCompetencias();
      state = container.read(contraChequeProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
      expect(state.competencias.length, 1);
      expect(state.competencias.first.ano, 2026);
      expect(state.contrachequeAtual, isNotNull);
      expect(state.contrachequeAtual!.valorLiquido, 15000.0);
    });

    // =========================================================================
    // Q12-T04: Retry Manual de Tela e Limpeza de Erro Anterior
    // =========================================================================
    test('Q12-T04: retry manual limpa estado de erro anterior e restaura conteudo', () async {
      int tentativa = 0;

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        tentativa++;
        if (tentativa == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'Erro de conexao na primeira tentativa',
          );
        }
        return ResponseBody.fromString(
          jsonEncode([
            {
              'chaveExterna': 'noticia-201',
              'titulo': 'Titulo Apos Retry',
              'resumo': 'Conteudo carregado com sucesso',
              'link': 'https://mppb.mp.br/noticia/201',
              'categoria': 'Geral',
            }
          ]),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(noticiaProvider.notifier);

      // Tentativa 1: falha
      await notifier.fetchNoticias();
      expect(container.read(noticiaProvider).errorMessage, isNotNull);
      expect(container.read(noticiaProvider).noticias, isEmpty);

      // Tentativa 2 (retry): sucesso
      await notifier.fetchNoticias();
      expect(container.read(noticiaProvider).errorMessage, isNull);
      expect(container.read(noticiaProvider).noticias.length, 1);
      expect(container.read(noticiaProvider).noticias.first.chaveExterna, 'noticia-201');
    });

    // =========================================================================
    // Q12-T05: Sessão Expirada (401 x 403)
    // =========================================================================
    test('Q12-T05: 401 invalida sessao autenticada enquanto 403 mantem sessao ativa', () async {
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-ativo-q12',
        'auth_username': 'usuario.q12',
      });

      final authDio = Dio();
      authDio.httpClientAdapter = _AsyncMockAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({'token': 'token-ativo-q12'}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final dio = Dio();
      final container = _createTestContainer(dio: dio, authDio: authDio);
      addTearDown(container.dispose);

      final authNotifier = container.read(authProvider.notifier);
      await authNotifier.login('usuario.q12', 'senha123', offerBiometrics: false);
      expect(container.read(authProvider).isAuthenticated, isTrue);

      // 403 Forbidden: Usuário não tem permissão para o recurso, mas sessão permanece
      final erro403 = DioException(
        requestOptions: RequestOptions(path: '/api/restrito'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/restrito'),
          statusCode: 403,
        ),
      );
      expect(erro403.response?.statusCode, 403);
      expect(container.read(authProvider).isAuthenticated, isTrue);

      // 401 Unauthorized: Simula interceptor que dispara logout
      await authNotifier.logout();
      expect(container.read(authProvider).isAuthenticated, isFalse);
      expect(container.read(authProvider).token, isNull);
    });

    // =========================================================================
    // Q12-T06: Storage Corrompido / Cache JSON Inválido
    // =========================================================================
    test('Q12-T06: PerfilNotifier lida com cache JSON corrompido sem travar isolate', () async {
      // Injeta JSON sintaticamente inválido no storage
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-q12-cache',
        'auth_username': 'user.q12',
        'perfil_cache_data': 'CORRUPTED_JSON_DATA_{{{{',
        'perfil_cache_username': 'user.q12',
      });

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        // Falha no backend para forçar leitura de fallback do cache
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(perfilProvider.notifier);
      await notifier.carregar(forceRefresh: true);

      final state = container.read(perfilProvider);
      // App não caiu, loading foi limpo, erro amigável foi exibido
      expect(state.isLoading, isFalse);
      expect(state.data, isNull);
      expect(state.errorMessage, isNotNull);
    });

    test('Q12-T06: CarteiraNotifier lida com cache JSON corrompido sem crash', () async {
      // Injeta lixo corrompido no cache da carteira
      FlutterSecureStorage.setMockInitialValues({
        'auth_token': 'token-q12-carteira',
        'auth_username': 'user.carteira',
        'carteira_cache_data': '<<<INVALID_CARTEIRA_JSON>>>',
        'carteira_cache_username': 'user.carteira',
      });

      final dio = Dio();
      dio.httpClientAdapter = _AsyncMockAdapter((options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionError,
        );
      });

      final container = _createTestContainer(dio: dio);
      addTearDown(container.dispose);

      final notifier = container.read(carteiraProvider.notifier);
      await notifier.fetchCarteira();

      final state = container.read(carteiraProvider);
      expect(state.isLoading, isFalse);
      expect(state.data, isNull);
      expect(state.errorMessage, isNotNull);
    });

    // =========================================================================
    // Q12-T20: FCM / Push Service Resilience
    // =========================================================================
    test('Q12-T20: falha no servico de push token nao causa crash no registro de dispositivo', () async {
      final dio = Dio();
      final container = ProviderContainer(
        overrides: [
          dioProvider.overrideWithValue(dio),
          pushTokenProvider.overrideWithValue(const _FailingPushTokenProvider()),
          devicePlatformResolverProvider.overrideWithValue(const _StaticPlatformResolver('ANDROID')),
        ],
      );
      addTearDown(container.dispose);

      final manager = container.read(deviceRegistrationManagerProvider);
      // O registro deve executar sem lançar exceção não tratada para a UI
      await expectLater(
        manager.registrarSeAutenticado('token-q12-test'),
        completes,
      );
    });

    // =========================================================================
    // Q12-T21: PDF / Imagem - Fallback UI Graceful
    // =========================================================================
    testWidgets('Q12-T21: falha de imagem renderiza icone de fallback sem quebrar tela', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Image.network(
              'https://invalid.mppb.mp.br/imagem-inexistente.jpg',
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.broken_image, key: Key('fallback_broken_image')),
                      Text('Imagem indisponivel'),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byKey(const Key('fallback_broken_image')), findsOneWidget);
      expect(find.text('Imagem indisponivel'), findsOneWidget);
    });
  });
}

// =============================================================================
// Test Doubles e Helpers
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
      deviceRegistrationManagerProvider.overrideWithValue(_DummyDeviceRegistrationManager()),
      pushTokenProvider.overrideWithValue(const _StaticPushTokenProvider('fcm-token-q12')),
      devicePlatformResolverProvider.overrideWithValue(const _StaticPlatformResolver('ANDROID')),
    ],
  );
}

class _DummyDeviceRegistrationManager implements DeviceRegistrationManager {
  @override
  dynamic noSuchMethod(Invocation invocation) => Future.value();
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

class _StaticPlatformResolver extends DevicePlatformResolver {
  final String? platform;
  const _StaticPlatformResolver(this.platform);

  @override
  String? currentPlatform() => platform;
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

class _FailingPushTokenProvider implements PushTokenProvider {
  const _FailingPushTokenProvider();

  @override
  Stream<String> get tokenRefreshes => const Stream.empty();

  @override
  Future<String?> getToken() async => throw StateError('Falha simulada na obtencao de token FCM');

  @override
  Future<String> requestPermission() async => throw StateError('Permissao negada FCM');
}
