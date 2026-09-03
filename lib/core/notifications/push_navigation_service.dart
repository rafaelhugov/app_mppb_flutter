import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/designacoes/providers/designacoes_provider.dart';
import '../router/app_router.dart';
import 'push_notification_service.dart';

const String _designacoesEventType = 'NOVAS_DESIGNACOES';
const String _designacoesRoute = '/designacoes';

abstract class PushMessageGateway {
  Stream<RemoteMessage> get foregroundMessages;

  Stream<RemoteMessage> get openedMessages;

  RemoteMessage? consumeInitialMessage();

  PushTechnicalPayload technicalPayload(RemoteMessage message);
}

class FirebasePushMessageGateway implements PushMessageGateway {
  final PushNotificationService service;

  const FirebasePushMessageGateway(this.service);

  @override
  Stream<RemoteMessage> get foregroundMessages => service.foregroundMessages;

  @override
  Stream<RemoteMessage> get openedMessages => service.openedMessages;

  @override
  RemoteMessage? consumeInitialMessage() => service.consumeInitialMessage();

  @override
  PushTechnicalPayload technicalPayload(RemoteMessage message) {
    return service.technicalPayload(message);
  }
}

class DisabledPushMessageGateway implements PushMessageGateway {
  const DisabledPushMessageGateway();

  @override
  Stream<RemoteMessage> get foregroundMessages => const Stream.empty();

  @override
  Stream<RemoteMessage> get openedMessages => const Stream.empty();

  @override
  RemoteMessage? consumeInitialMessage() => null;

  @override
  PushTechnicalPayload technicalPayload(RemoteMessage message) {
    return const PushTechnicalPayload();
  }
}

abstract class PushNavigationDelegate {
  String get currentLocation;

  void go(String route);
}

class GoRouterPushNavigationDelegate implements PushNavigationDelegate {
  final GoRouter router;

  const GoRouterPushNavigationDelegate(this.router);

  @override
  String get currentLocation {
    return router.routeInformationProvider.value.uri.path;
  }

  @override
  void go(String route) {
    router.go(route);
  }
}

class PushNavigationService {
  final PushMessageGateway gateway;
  final PushNavigationDelegate navigator;
  final bool Function() isAuthenticated;
  final Future<void> Function({required bool forceRefresh}) refreshDesignacoes;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  final Set<String> _processedOpenedMessages = <String>{};
  String? _pendingRoute;

  PushNavigationService({
    required this.gateway,
    required this.navigator,
    required this.isAuthenticated,
    required this.refreshDesignacoes,
  });

  void start() {
    _foregroundSubscription ??= gateway.foregroundMessages.listen((message) {
      unawaited(handleForegroundMessage(message));
    });
    _openedSubscription ??= gateway.openedMessages.listen((message) {
      unawaited(handleOpenedMessage(message));
    });

    final initialMessage = gateway.consumeInitialMessage();
    if (initialMessage != null) {
      unawaited(handleOpenedMessage(initialMessage));
    }
  }

  Future<void> handleForegroundMessage(RemoteMessage message) {
    return handleForegroundPayload(
      gateway.technicalPayload(message),
      messageKey: _messageKey(message),
    );
  }

  Future<void> handleOpenedMessage(RemoteMessage message) {
    return handleOpenedPayload(
      gateway.technicalPayload(message),
      messageKey: _messageKey(message),
    );
  }

  @visibleForTesting
  Future<void> handleForegroundPayload(
    PushTechnicalPayload payload, {
    String? messageKey,
  }) async {
    if (!_isAllowedDesignacoesPayload(payload) || !isAuthenticated()) {
      return;
    }
    await refreshDesignacoes(forceRefresh: true);
  }

  @visibleForTesting
  Future<void> handleOpenedPayload(
    PushTechnicalPayload payload, {
    String? messageKey,
  }) async {
    if (!_isAllowedDesignacoesPayload(payload) ||
        !_markOpenedMessageAsPending(messageKey)) {
      return;
    }

    if (!isAuthenticated()) {
      _pendingRoute = _designacoesRoute;
      _goToDesignacoesIfNeeded();
      return;
    }

    await _openDesignacoesAndRefresh();
  }

  Future<void> handleAuthenticated() async {
    if (_pendingRoute != _designacoesRoute || !isAuthenticated()) {
      return;
    }
    _pendingRoute = null;
    await _openDesignacoesAndRefresh();
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    _foregroundSubscription = null;
    _openedSubscription = null;
  }

  Future<void> _openDesignacoesAndRefresh() async {
    _goToDesignacoesIfNeeded();
    await refreshDesignacoes(forceRefresh: true);
  }

  void _goToDesignacoesIfNeeded() {
    if (navigator.currentLocation != _designacoesRoute) {
      navigator.go(_designacoesRoute);
    }
  }

  bool _isAllowedDesignacoesPayload(PushTechnicalPayload payload) {
    return payload.tipoEvento == _designacoesEventType &&
        payload.rota == _designacoesRoute;
  }

  bool _markOpenedMessageAsPending(String? key) {
    if (key == null || key.trim().isEmpty) {
      return true;
    }
    return _processedOpenedMessages.add(key.trim());
  }

  static String? _messageKey(RemoteMessage message) {
    final idEvento = message.data['id_evento_notificacao']?.toString().trim();
    if (idEvento != null && idEvento.isNotEmpty) {
      return idEvento;
    }

    final messageId = message.messageId?.trim();
    if (messageId != null && messageId.isNotEmpty) {
      return messageId;
    }

    return null;
  }
}

final pushMessageGatewayProvider = Provider<PushMessageGateway>((ref) {
  if (!PushNotificationService.isSupportedPlatform) {
    return const DisabledPushMessageGateway();
  }
  return FirebasePushMessageGateway(PushNotificationService.instance);
});

final pushNavigationDelegateProvider = Provider<PushNavigationDelegate>((ref) {
  return GoRouterPushNavigationDelegate(ref.read(appRouterProvider));
});

final pushNavigationServiceProvider = Provider<PushNavigationService>((ref) {
  final service = PushNavigationService(
    gateway: ref.read(pushMessageGatewayProvider),
    navigator: ref.read(pushNavigationDelegateProvider),
    isAuthenticated: () => ref.read(authProvider).isAuthenticated,
    refreshDesignacoes: ({required bool forceRefresh}) {
      return ref
          .read(designacoesProvider.notifier)
          .carregar(forceRefresh: forceRefresh);
    },
  );

  service.start();
  ref.listen(authProvider, (previous, next) {
    if (next.isAuthenticated && previous?.isAuthenticated != true) {
      unawaited(service.handleAuthenticated());
    }
  });
  ref.onDispose(() {
    unawaited(service.dispose());
  });
  return service;
});
