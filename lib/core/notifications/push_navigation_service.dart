import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/designacoes/providers/designacoes_provider.dart';
import '../../features/noticias/providers/noticia_provider.dart';
import '../router/app_router.dart';
import 'push_notification_service.dart';

const String _designacoesEventType = 'NOVAS_DESIGNACOES';
const String _designacoesRoute = '/designacoes';
const String _noticiasEventType = 'NOVAS_NOTICIAS';
const String _noticiasRoute = '/noticias';

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
  final Future<void> Function() refreshNoticias;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  final Set<String> _processedOpenedMessages = <String>{};
  String? _pendingRoute;

  PushNavigationService({
    required this.gateway,
    required this.navigator,
    required this.isAuthenticated,
    required this.refreshDesignacoes,
    required this.refreshNoticias,
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
    if (_isAllowedDesignacoesPayload(payload) && isAuthenticated()) {
      await refreshDesignacoes(forceRefresh: true);
      return;
    }

    if (_isAllowedNoticiasPayload(payload)) {
      await refreshNoticias();
      return;
    }
  }

  @visibleForTesting
  Future<void> handleOpenedPayload(
    PushTechnicalPayload payload, {
    String? messageKey,
  }) async {
    if (!_isAllowedDesignacoesPayload(payload) &&
        !_isAllowedNoticiasPayload(payload)) {
      return;
    }

    if (!_markOpenedMessageAsPending(messageKey)) {
      return;
    }

    if (_isAllowedDesignacoesPayload(payload) && !isAuthenticated()) {
      _pendingRoute = _designacoesRoute;
      _goToDesignacoesIfNeeded();
      return;
    }

    if (_isAllowedDesignacoesPayload(payload)) {
      await _openDesignacoesAndRefresh();
      return;
    }

    if (_isAllowedNoticiasPayload(payload)) {
      await _openNoticiasAndRefresh(payload);
    }
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

  Future<void> _openNoticiasAndRefresh(PushTechnicalPayload payload) async {
    _goToNoticiasIfNeeded(payload);
    await refreshNoticias();
  }

  void _goToDesignacoesIfNeeded() {
    if (navigator.currentLocation != _designacoesRoute) {
      navigator.go(_designacoesRoute);
    }
  }

  void _goToNoticiasIfNeeded(PushTechnicalPayload payload) {
    final route = _noticiasRouteWithPayload(payload);
    if (navigator.currentLocation != _noticiasRoute) {
      navigator.go(route);
      return;
    }
    if (route != _noticiasRoute) {
      navigator.go(route);
    }
  }

  String _noticiasRouteWithPayload(PushTechnicalPayload payload) {
    final params = <String, String>{};
    final chave = payload.noticiaChave?.trim();
    final link = payload.noticiaLink?.trim();
    final titulo = payload.noticiaTitulo?.trim();
    if (chave != null && chave.isNotEmpty) {
      params['noticia'] = chave;
    }
    if (link != null && link.isNotEmpty) {
      params['link'] = link;
    }
    if (titulo != null && titulo.isNotEmpty) {
      params['titulo'] = titulo;
    }
    if (params.isEmpty) {
      return _noticiasRoute;
    }
    return Uri(path: _noticiasRoute, queryParameters: params).toString();
  }

  bool _isAllowedDesignacoesPayload(PushTechnicalPayload payload) {
    return payload.tipoEvento == _designacoesEventType &&
        payload.rota == _designacoesRoute;
  }

  bool _isAllowedNoticiasPayload(PushTechnicalPayload payload) {
    return payload.tipoEvento == _noticiasEventType &&
        payload.rota == _noticiasRoute;
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
    refreshNoticias: () => ref.read(noticiaProvider.notifier).fetchNoticias(),
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
