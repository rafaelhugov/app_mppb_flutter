import 'dart:async';

import 'package:app_mppb_flutter/core/notifications/push_navigation_service.dart';
import 'package:app_mppb_flutter/core/notifications/push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PushNavigationService', () {
    late FakePushMessageGateway gateway;
    late FakePushNavigationDelegate navigator;
    late FakeDesignacoesRefresher refresher;
    late bool authenticated;
    late PushNavigationService service;

    setUp(() {
      gateway = FakePushMessageGateway();
      navigator = FakePushNavigationDelegate();
      refresher = FakeDesignacoesRefresher();
      authenticated = true;
      service = PushNavigationService(
        gateway: gateway,
        navigator: navigator,
        isAuthenticated: () => authenticated,
        refreshDesignacoes: refresher.refresh,
      );
    });

    tearDown(() async {
      await service.dispose();
      await gateway.dispose();
    });

    test('foreground atualiza provider sem navegar', () async {
      await service.handleForegroundPayload(_designacoesPayload());

      expect(refresher.forceRefreshes, [true]);
      expect(navigator.routes, isEmpty);
    });

    test('background com toque abre designacoes e atualiza provider', () async {
      await service.handleOpenedPayload(
        _designacoesPayload(),
        messageKey: 'mensagem-1',
      );

      expect(navigator.routes, ['/designacoes']);
      expect(refresher.forceRefreshes, [true]);
    });

    test(
      'app encerrado com toque abre designacoes ao iniciar servico',
      () async {
        gateway.initialMessage = const RemoteMessage(
          messageId: 'mensagem-inicial',
          data: {'tipo_evento': 'NOVAS_DESIGNACOES', 'rota': '/designacoes'},
        );

        service.start();
        await Future<void>.delayed(Duration.zero);

        expect(navigator.routes, ['/designacoes']);
        expect(refresher.forceRefreshes, [true]);
      },
    );

    test(
      'usuario nao autenticado respeita login e aguarda autenticacao',
      () async {
        authenticated = false;

        await service.handleOpenedPayload(
          _designacoesPayload(),
          messageKey: 'mensagem-2',
        );

        expect(navigator.routes, ['/designacoes']);
        expect(refresher.forceRefreshes, isEmpty);
      },
    );

    test('apos login direciona para designacoes e atualiza provider', () async {
      authenticated = false;
      await service.handleOpenedPayload(
        _designacoesPayload(),
        messageKey: 'mensagem-3',
      );
      navigator.routes.clear();
      navigator.current = '/login';
      authenticated = true;

      await service.handleAuthenticated();

      expect(navigator.routes, ['/designacoes']);
      expect(refresher.forceRefreshes, [true]);
    });

    test('payload desconhecido e ignorado', () async {
      await service.handleOpenedPayload(
        const PushTechnicalPayload(
          tipoEvento: 'OUTRO_EVENTO',
          rota: '/designacoes',
        ),
        messageKey: 'mensagem-4',
      );

      expect(navigator.routes, isEmpty);
      expect(refresher.forceRefreshes, isEmpty);
    });

    test('rota arbitraria e ignorada', () async {
      await service.handleOpenedPayload(
        const PushTechnicalPayload(
          tipoEvento: 'NOVAS_DESIGNACOES',
          rota: 'https://example.com',
        ),
        messageKey: 'mensagem-5',
      );

      expect(navigator.routes, isEmpty);
      expect(refresher.forceRefreshes, isEmpty);
    });

    test('navegacao duplicada e evitada para mesmo evento', () async {
      await service.handleOpenedPayload(
        _designacoesPayload(),
        messageKey: 'mensagem-6',
      );
      await service.handleOpenedPayload(
        _designacoesPayload(),
        messageKey: 'mensagem-6',
      );

      expect(navigator.routes, ['/designacoes']);
      expect(refresher.forceRefreshes, [true]);
    });

    test('nao empilha rota quando ja esta em designacoes', () async {
      navigator.current = '/designacoes';

      await service.handleOpenedPayload(
        _designacoesPayload(),
        messageKey: 'mensagem-7',
      );

      expect(navigator.routes, isEmpty);
      expect(refresher.forceRefreshes, [true]);
    });
  });
}

PushTechnicalPayload _designacoesPayload() {
  return const PushTechnicalPayload(
    tipoEvento: 'NOVAS_DESIGNACOES',
    rota: '/designacoes',
  );
}

class FakePushMessageGateway implements PushMessageGateway {
  final StreamController<RemoteMessage> _foregroundController =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _openedController =
      StreamController<RemoteMessage>.broadcast();
  RemoteMessage? initialMessage;

  @override
  Stream<RemoteMessage> get foregroundMessages => _foregroundController.stream;

  @override
  Stream<RemoteMessage> get openedMessages => _openedController.stream;

  @override
  RemoteMessage? consumeInitialMessage() {
    final message = initialMessage;
    initialMessage = null;
    return message;
  }

  @override
  PushTechnicalPayload technicalPayload(RemoteMessage message) {
    return PushTechnicalPayload.fromData(message.data);
  }

  Future<void> dispose() async {
    await _foregroundController.close();
    await _openedController.close();
  }
}

class FakePushNavigationDelegate implements PushNavigationDelegate {
  final List<String> routes = [];
  String current = '/restrito';

  @override
  String get currentLocation => current;

  @override
  void go(String route) {
    routes.add(route);
    current = route;
  }
}

class FakeDesignacoesRefresher {
  final List<bool> forceRefreshes = [];

  Future<void> refresh({required bool forceRefresh}) async {
    forceRefreshes.add(forceRefresh);
  }
}
