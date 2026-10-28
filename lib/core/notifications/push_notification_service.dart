import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../firebase_options.dart';
import 'notification_center_provider.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!PushNotificationService.isSupportedPlatform) {
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await persistNotificationCenterRemoteMessage(message);
}

class PushTechnicalPayload {
  final String? tipoEvento;
  final String? rota;
  final String? noticiaChave;
  final String? noticiaLink;
  final String? noticiaTitulo;
  final String? liveId;
  final String? liveTitulo;
  final String? liveUrl;

  const PushTechnicalPayload({
    this.tipoEvento,
    this.rota,
    this.noticiaChave,
    this.noticiaLink,
    this.noticiaTitulo,
    this.liveId,
    this.liveTitulo,
    this.liveUrl,
  });

  factory PushTechnicalPayload.fromData(Map<String, dynamic> data) {
    return PushTechnicalPayload(
      tipoEvento: _stringValue(data['tipo_evento']),
      rota: _stringValue(data['rota']),
      noticiaChave: _stringValue(data['noticia_chave']),
      noticiaLink: _stringValue(data['noticia_link']),
      noticiaTitulo: _stringValue(data['noticia_titulo']),
      liveId: _stringValue(data['live_id']),
      liveTitulo: _stringValue(data['live_titulo']),
      liveUrl: _stringValue(data['live_url']),
    );
  }

  bool get isSupportedDesignacaoSignal {
    return tipoEvento == 'NOVAS_DESIGNACOES' && rota == '/designacoes';
  }

  bool get isSupportedNoticiasSignal {
    return tipoEvento == 'NOVAS_NOTICIAS' && rota == '/noticias';
  }

  bool get isSupportedLivesSignal {
    return tipoEvento == 'NOVA_LIVE' && rota == '/videos';
  }

  Map<String, String> toAllowedData() {
    final data = <String, String>{};
    final tipoEvento = this.tipoEvento;
    final rota = this.rota;
    if (tipoEvento != null) {
      data['tipo_evento'] = tipoEvento;
    }
    if (rota != null) {
      data['rota'] = rota;
    }
    if (noticiaChave != null) {
      data['noticia_chave'] = noticiaChave!;
    }
    if (noticiaLink != null) {
      data['noticia_link'] = noticiaLink!;
    }
    if (noticiaTitulo != null) {
      data['noticia_titulo'] = noticiaTitulo!;
    }
    if (liveId != null) {
      data['live_id'] = liveId!;
    }
    if (liveTitulo != null) {
      data['live_titulo'] = liveTitulo!;
    }
    if (liveUrl != null) {
      data['live_url'] = liveUrl!;
    }
    return data;
  }

  static String? _stringValue(Object? value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();
  static const String publicNewsTopic = 'mppb_noticias';
  static const String publicLivesTopic = 'mppb_lives';

  static bool get isSupportedPlatform {
    return !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
  }

  static bool get isFirebaseReady => Firebase.apps.isNotEmpty;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StreamController<RemoteMessage> _foregroundMessages =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _openedMessages =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _tokenRefreshes =
      StreamController<String>.broadcast();
  RemoteMessage? _initialMessage;
  Future<void>? _initialization;

  Stream<RemoteMessage> get foregroundMessages => _foregroundMessages.stream;
  Stream<RemoteMessage> get openedMessages => _openedMessages.stream;
  Stream<String> get tokenRefreshes => _tokenRefreshes.stream;

  RemoteMessage? consumeInitialMessage() {
    final message = _initialMessage;
    _initialMessage = null;
    return message;
  }

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_foregroundMessages.add);
    FirebaseMessaging.onMessageOpenedApp.listen(_openedMessages.add);
    _messaging.onTokenRefresh.listen(_tokenRefreshes.add);

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Falha ao configurar opções de apresentação iOS: $e');
        }
      }
    }

    await _preparePublicTopics();

    try {
      final initialMessage = await _messaging.getInitialMessage().timeout(
        const Duration(seconds: 3),
      );
      if (initialMessage != null) {
        _initialMessage = initialMessage;
        _openedMessages.add(initialMessage);
      }
    } on TimeoutException {
      if (kDebugMode) {
        debugPrint('FCM initial message timeout.');
      }
    }
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<String?> getToken() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      try {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          await Future<void>.delayed(const Duration(milliseconds: 600));
        }
      } catch (_) {}
    }
    return _messaging.getToken();
  }

  Future<void> subscribeToPublicNewsTopic() {
    return _messaging.subscribeToTopic(publicNewsTopic);
  }

  Future<void> setPublicNewsSubscription(bool enabled) {
    return enabled
        ? _messaging.subscribeToTopic(publicNewsTopic)
        : _messaging.unsubscribeFromTopic(publicNewsTopic);
  }

  Future<void> subscribeToPublicLivesTopic() {
    return _messaging.subscribeToTopic(publicLivesTopic);
  }

  Future<void> setPublicLivesSubscription(bool enabled) {
    return enabled
        ? _messaging.subscribeToTopic(publicLivesTopic)
        : _messaging.unsubscribeFromTopic(publicLivesTopic);
  }

  Future<void> _preparePublicTopics() async {
    try {
      await requestPermission().timeout(const Duration(seconds: 5));
      await subscribeToPublicNewsTopic().timeout(const Duration(seconds: 5));
      await subscribeToPublicLivesTopic().timeout(const Duration(seconds: 5));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM public topics unavailable: $e');
      }
    }
  }

  PushTechnicalPayload technicalPayload(RemoteMessage message) {
    return PushTechnicalPayload.fromData(message.data);
  }
}
