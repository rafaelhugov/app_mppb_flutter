import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/concessao_afastamento/providers/concessao_afastamento_provider.dart';
import '../../features/contra_cheque/providers/contra_cheque_provider.dart';
import '../../features/designacoes/providers/designacoes_provider.dart';
import '../../features/noticias/providers/noticia_provider.dart';
import '../../features/pagamentos/providers/pagamentos_provider.dart';
import '../router/app_router.dart';
import 'push_notification_service.dart';

const String _designacoesEventType = 'NOVAS_DESIGNACOES';
const String _designacoesRoute = '/designacoes';
const String _noticiasEventType = 'NOVAS_NOTICIAS';
const String _noticiasRoute = '/noticias';
const String _contrachequeEventType = 'NOVO_CONTRACHEQUE';
const String _contrachequeRoute = '/contracheque';
const String _pagamentosEventType = 'NOVO_PAGAMENTO';
const String _pagamentosRoute = '/pagamentos';
const String _afastamentoStatusEventType = 'AFASTAMENTO_STATUS_ALTERADO';
const String _afastamentoMovimentacaoEventType = 'AFASTAMENTO_MOVIMENTACAO';
const String _afastamentosRoute = '/concessao-afastamento';

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
  final Future<void> Function() refreshContracheque;
  final Future<void> Function() refreshPagamentos;
  final Future<void> Function() refreshAfastamentos;

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
    required this.refreshContracheque,
    required this.refreshPagamentos,
    required this.refreshAfastamentos,
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

    if (_isAllowedAuthenticatedFunctionalPayload(payload) &&
        isAuthenticated()) {
      await _refreshFunctionalPayload(payload);
      return;
    }
  }

  @visibleForTesting
  Future<void> handleOpenedPayload(
    PushTechnicalPayload payload, {
    String? messageKey,
  }) async {
    if (!_isAllowedDesignacoesPayload(payload) &&
        !_isAllowedNoticiasPayload(payload) &&
        !_isAllowedAuthenticatedFunctionalPayload(payload)) {
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
      return;
    }

    final functionalRoute = _functionalRoute(payload);
    if (functionalRoute == null) {
      return;
    }

    if (!isAuthenticated()) {
      _pendingRoute = functionalRoute;
      _goToRouteIfNeeded(functionalRoute);
      return;
    }

    await _openFunctionalAndRefresh(payload, functionalRoute);
  }

  Future<void> handleAuthenticated() async {
    if (_pendingRoute == null || !isAuthenticated()) {
      return;
    }
    final route = _pendingRoute;
    _pendingRoute = null;
    if (route == _designacoesRoute) {
      await _openDesignacoesAndRefresh();
      return;
    }
    if (_isFunctionalRoute(route)) {
      _goToRouteIfNeeded(route!);
      await _refreshFunctionalRoute(route);
    }
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

  Future<void> _openFunctionalAndRefresh(
    PushTechnicalPayload payload,
    String route,
  ) async {
    _goToRouteIfNeeded(route);
    await _refreshFunctionalPayload(payload);
  }

  void _goToDesignacoesIfNeeded() {
    _goToRouteIfNeeded(_designacoesRoute);
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

  void _goToRouteIfNeeded(String route) {
    if (navigator.currentLocation != route) {
      navigator.go(route);
    }
  }

  Future<void> _refreshFunctionalPayload(PushTechnicalPayload payload) async {
    final route = _functionalRoute(payload);
    if (route == null) {
      return;
    }
    await _refreshFunctionalRoute(route);
  }

  Future<void> _refreshFunctionalRoute(String route) {
    switch (route) {
      case _contrachequeRoute:
        return refreshContracheque();
      case _pagamentosRoute:
        return refreshPagamentos();
      case _afastamentosRoute:
        return refreshAfastamentos();
      default:
        return Future<void>.value();
    }
  }

  String? _functionalRoute(PushTechnicalPayload payload) {
    if (_isAllowedContrachequePayload(payload)) {
      return _contrachequeRoute;
    }
    if (_isAllowedPagamentosPayload(payload)) {
      return _pagamentosRoute;
    }
    if (_isAllowedAfastamentosPayload(payload)) {
      return _afastamentosRoute;
    }
    return null;
  }

  bool _isAllowedDesignacoesPayload(PushTechnicalPayload payload) {
    return payload.tipoEvento == _designacoesEventType &&
        payload.rota == _designacoesRoute;
  }

  bool _isAllowedNoticiasPayload(PushTechnicalPayload payload) {
    return payload.tipoEvento == _noticiasEventType &&
        payload.rota == _noticiasRoute;
  }

  bool _isAllowedContrachequePayload(PushTechnicalPayload payload) {
    return payload.tipoEvento == _contrachequeEventType &&
        payload.rota == _contrachequeRoute;
  }

  bool _isAllowedPagamentosPayload(PushTechnicalPayload payload) {
    return payload.tipoEvento == _pagamentosEventType &&
        payload.rota == _pagamentosRoute;
  }

  bool _isAllowedAfastamentosPayload(PushTechnicalPayload payload) {
    return (payload.tipoEvento == _afastamentoStatusEventType ||
            payload.tipoEvento == _afastamentoMovimentacaoEventType) &&
        payload.rota == _afastamentosRoute;
  }

  bool _isAllowedAuthenticatedFunctionalPayload(PushTechnicalPayload payload) {
    return _functionalRoute(payload) != null;
  }

  bool _isFunctionalRoute(String? route) {
    return route == _contrachequeRoute ||
        route == _pagamentosRoute ||
        route == _afastamentosRoute;
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
    refreshContracheque: () {
      return ref.read(contraChequeProvider.notifier).carregarCompetencias();
    },
    refreshPagamentos: () {
      return ref.read(pagamentosProvider.notifier).fetchAnosDisponiveis();
    },
    refreshAfastamentos: () {
      return ref.read(concessaoAfastamentoProvider.notifier).atualizarTudo();
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
