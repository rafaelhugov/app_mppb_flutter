import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../../firebase_options.dart';

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
}

class PushTechnicalPayload {
  final String? tipoEvento;
  final String? rota;
  final String? noticiaChave;
  final String? noticiaLink;
  final String? noticiaTitulo;

  const PushTechnicalPayload({
    this.tipoEvento,
    this.rota,
    this.noticiaChave,
    this.noticiaLink,
    this.noticiaTitulo,
  });

  factory PushTechnicalPayload.fromData(Map<String, dynamic> data) {
    return PushTechnicalPayload(
      tipoEvento: _stringValue(data['tipo_evento']),
      rota: _stringValue(data['rota']),
      noticiaChave: _stringValue(data['noticia_chave']),
      noticiaLink: _stringValue(data['noticia_link']),
      noticiaTitulo: _stringValue(data['noticia_titulo']),
    );
  }

  bool get isSupportedDesignacaoSignal {
    return tipoEvento == 'NOVAS_DESIGNACOES' && rota == '/designacoes';
  }

  bool get isSupportedNoticiasSignal {
    return tipoEvento == 'NOVAS_NOTICIAS' && rota == '/noticias';
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

  static bool get isSupportedPlatform {
    return !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
  }

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final StreamController<RemoteMessage> _foregroundMessages =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<RemoteMessage> _openedMessages =
      StreamController<RemoteMessage>.broadcast();
  final StreamController<String> _tokenRefreshes =
      StreamController<String>.broadcast();
  RemoteMessage? _initialMessage;

  Stream<RemoteMessage> get foregroundMessages => _foregroundMessages.stream;
  Stream<RemoteMessage> get openedMessages => _openedMessages.stream;
  Stream<String> get tokenRefreshes => _tokenRefreshes.stream;

  RemoteMessage? consumeInitialMessage() {
    final message = _initialMessage;
    _initialMessage = null;
    return message;
  }

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_foregroundMessages.add);
    FirebaseMessaging.onMessageOpenedApp.listen(_openedMessages.add);
    _messaging.onTokenRefresh.listen(_tokenRefreshes.add);
    await _preparePublicNewsTopic();

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _initialMessage = initialMessage;
      _openedMessages.add(initialMessage);
    }
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<String?> getToken() {
    return _messaging.getToken();
  }

  Future<void> subscribeToPublicNewsTopic() {
    return _messaging.subscribeToTopic(publicNewsTopic);
  }

  Future<void> _preparePublicNewsTopic() async {
    try {
      await requestPermission();
      await subscribeToPublicNewsTopic();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('FCM public topic unavailable.');
      }
    }
  }

  PushTechnicalPayload technicalPayload(RemoteMessage message) {
    return PushTechnicalPayload.fromData(message.data);
  }
}
