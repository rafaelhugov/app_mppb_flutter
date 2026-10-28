import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/designacoes/models/designacao_ativa.dart';
import '../../features/noticias/models/noticia.dart';
import '../storage/secure_storage.dart';

const _readKeysStorageKey = 'notification_center_read_keys_v1';
const _inboxStorageKey = 'notification_center_inbox_v1';
const _maxInboxItems = 100;

enum NotificationCenterItemType {
  noticia,
  designacao,
  contracheque,
  pagamento,
  afastamento,
  live,
}

class NotificationCenterItem {
  final String key;
  final NotificationCenterItemType type;
  final String title;
  final String subtitle;
  final String? targetUrl;
  final String? targetRoute;
  final String? imageUrl;
  final Noticia? noticia;
  final DateTime? receivedAt;
  final bool isRead;

  const NotificationCenterItem({
    required this.key,
    required this.type,
    required this.title,
    required this.subtitle,
    this.targetUrl,
    this.targetRoute,
    this.imageUrl,
    this.noticia,
    this.receivedAt,
    this.isRead = false,
  });

  NotificationCenterItem copyWith({
    String? key,
    NotificationCenterItemType? type,
    String? title,
    String? subtitle,
    String? targetUrl,
    String? targetRoute,
    String? imageUrl,
    Noticia? noticia,
    DateTime? receivedAt,
    bool? isRead,
  }) {
    return NotificationCenterItem(
      key: key ?? this.key,
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      targetUrl: targetUrl ?? this.targetUrl,
      targetRoute: targetRoute ?? this.targetRoute,
      imageUrl: imageUrl ?? this.imageUrl,
      noticia: noticia ?? this.noticia,
      receivedAt: receivedAt ?? this.receivedAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toInboxJson() => {
    'key': key,
    'type': type.name,
    'title': title,
    'subtitle': subtitle,
    'targetRoute': targetRoute,
    'receivedAt': receivedAt?.toIso8601String(),
  };

  static NotificationCenterItem? fromInboxJson(Map<String, dynamic> json) {
    final key = json['key']?.toString().trim() ?? '';
    final title = json['title']?.toString().trim() ?? '';
    final typeName = json['type']?.toString();
    final type = NotificationCenterItemType.values
        .where((value) => value.name == typeName)
        .firstOrNull;
    if (key.isEmpty || title.isEmpty || type == null) return null;

    return NotificationCenterItem(
      key: key,
      type: type,
      title: title,
      subtitle: json['subtitle']?.toString().trim() ?? '',
      targetRoute: json['targetRoute']?.toString().trim(),
      receivedAt: DateTime.tryParse(json['receivedAt']?.toString() ?? ''),
    );
  }
}

class NotificationCenterState {
  final bool isLoading;
  final Set<String> readKeys;
  final List<NotificationCenterItem> inboxItems;

  const NotificationCenterState({
    this.isLoading = true,
    this.readKeys = const {},
    this.inboxItems = const [],
  });

  NotificationCenterState copyWith({
    bool? isLoading,
    Set<String>? readKeys,
    List<NotificationCenterItem>? inboxItems,
  }) {
    return NotificationCenterState(
      isLoading: isLoading ?? this.isLoading,
      readKeys: readKeys ?? this.readKeys,
      inboxItems: inboxItems ?? this.inboxItems,
    );
  }
}

class NotificationCenterNotifier extends Notifier<NotificationCenterState> {
  Future<void>? _initialLoad;

  @override
  NotificationCenterState build() {
    _initialLoad = Future.microtask(_reloadFromStorage);
    return const NotificationCenterState();
  }

  Future<void> reload() => _reloadFromStorage();

  Future<void> _reloadFromStorage() async {
    final storage = ref.read(secureStorageProvider);
    final results = await Future.wait([
      storage.read(key: _readKeysStorageKey),
      storage.read(key: _inboxStorageKey),
      storage.read(key: 'auth_username'),
    ]);
    if (!ref.mounted) return;
    final username = _normalizedUsername(results[2]);

    state = state.copyWith(
      isLoading: false,
      readKeys: _decodeReadKeys(results[0], username),
      inboxItems: username == null ? [] : _decodeInbox(results[1], username),
    );
  }

  Future<void> recordRemoteMessage(RemoteMessage message) async {
    await _initialLoad;
    final item = notificationCenterItemFromRemoteMessage(message);
    if (item == null) return;

    final storage = ref.read(secureStorageProvider);
    final username = _normalizedUsername(
      await storage.read(key: 'auth_username'),
    );
    if (username == null) return;
    final updated = _mergeInboxItem(state.inboxItems, item);
    state = state.copyWith(inboxItems: updated);
    await _persistInbox(storage, updated, username);
  }

  Future<void> markAsRead(String key) async {
    await _initialLoad;
    if (key.trim().isEmpty || state.readKeys.contains(key)) {
      return;
    }

    final updated = {...state.readKeys, key};
    state = state.copyWith(readKeys: updated);
    await _persist(updated);
  }

  Future<void> markAllAsRead(Iterable<String> keys) async {
    await _initialLoad;
    final sanitizedKeys = keys
        .map((key) => key.trim())
        .where((key) => key.isNotEmpty)
        .toSet();
    if (sanitizedKeys.isEmpty) {
      return;
    }

    final updated = {...state.readKeys, ...sanitizedKeys};
    state = state.copyWith(readKeys: updated);
    await _persist(updated);
  }

  Future<void> _persist(Set<String> keys) async {
    final storage = ref.read(secureStorageProvider);
    final username = _normalizedUsername(
      await storage.read(key: 'auth_username'),
    );
    await storage.write(
      key: _readKeysStorageKey,
      value: jsonEncode({'username': username, 'keys': keys.toList()..sort()}),
    );
  }
}

final notificationCenterProvider =
    NotifierProvider<NotificationCenterNotifier, NotificationCenterState>(() {
      return NotificationCenterNotifier();
    });

List<NotificationCenterItem> buildNotificationCenterItems({
  required List<Noticia> noticias,
  required List<DesignacaoAtiva> designacoes,
  required Set<String> readKeys,
  required bool includeDesignacoes,
  List<NotificationCenterItem> inboxItems = const [],
  bool includeNoticias = true,
  bool includeContracheques = true,
  bool includePagamentos = true,
  bool includeAfastamentos = true,
  bool includeLives = true,
}) {
  final items = <NotificationCenterItem>[
    if (includeNoticias) ...noticias.map(_noticiaItem),
    if (includeDesignacoes) ...designacoes.map(_designacaoItem),
    ...inboxItems.where(
      (item) => switch (item.type) {
        NotificationCenterItemType.noticia => includeNoticias,
        NotificationCenterItemType.designacao => includeDesignacoes,
        NotificationCenterItemType.contracheque => includeContracheques,
        NotificationCenterItemType.pagamento => includePagamentos,
        NotificationCenterItemType.afastamento => includeAfastamentos,
        NotificationCenterItemType.live => includeLives,
      },
    ),
  ];
  final uniqueItems = <String, NotificationCenterItem>{};
  for (final item in items) {
    uniqueItems.putIfAbsent(item.key, () => item);
  }
  return uniqueItems.values
      .map((item) => item.copyWith(isRead: readKeys.contains(item.key)))
      .toList();
}

NotificationCenterItem? notificationCenterItemFromRemoteMessage(
  RemoteMessage message,
) {
  final type = _functionalType(message.data['tipo_evento']?.toString());
  if (type == null) return null;

  final route = message.data['rota']?.toString().trim();
  if (route != _routeForType(type)) return null;

  final eventId = message.data['id_evento_notificacao']?.toString().trim();
  final messageId = message.messageId?.trim();
  final fallbackId =
      '${type.name}:${message.sentTime?.millisecondsSinceEpoch ?? DateTime.now().millisecondsSinceEpoch}';
  final keyPart = eventId?.isNotEmpty == true
      ? eventId!
      : messageId?.isNotEmpty == true
      ? messageId!
      : fallbackId;

  return NotificationCenterItem(
    key: 'push:$keyPart',
    type: type,
    title: _requiredText(message.notification?.title, _defaultTitle(type)),
    subtitle: _requiredText(
      message.notification?.body,
      'Nova atualização disponível',
    ),
    targetRoute: route,
    receivedAt: message.sentTime ?? DateTime.now(),
  );
}

Future<void> persistNotificationCenterRemoteMessage(
  RemoteMessage message,
) async {
  final item = notificationCenterItemFromRemoteMessage(message);
  if (item == null) return;

  const storage = FlutterSecureStorage();
  final username = _normalizedUsername(
    await storage.read(key: 'auth_username'),
  );
  if (username == null) return;
  final current = _decodeInbox(
    await storage.read(key: _inboxStorageKey),
    username,
  );
  await _persistInbox(storage, _mergeInboxItem(current, item), username);
}

NotificationCenterItemType? _functionalType(String? eventType) {
  return switch (eventType) {
    'NOVO_CONTRACHEQUE' => NotificationCenterItemType.contracheque,
    'NOVO_PAGAMENTO' => NotificationCenterItemType.pagamento,
    'AFASTAMENTO_STATUS_ALTERADO' ||
    'AFASTAMENTO_MOVIMENTACAO' => NotificationCenterItemType.afastamento,
    'NOVA_LIVE' => NotificationCenterItemType.live,
    _ => null,
  };
}

String _routeForType(NotificationCenterItemType type) {
  return switch (type) {
    NotificationCenterItemType.contracheque => '/contracheque',
    NotificationCenterItemType.pagamento => '/pagamentos',
    NotificationCenterItemType.afastamento => '/concessao-afastamento',
    NotificationCenterItemType.noticia => '/noticias',
    NotificationCenterItemType.designacao => '/designacoes',
    NotificationCenterItemType.live => '/videos',
  };
}

String _defaultTitle(NotificationCenterItemType type) {
  return switch (type) {
    NotificationCenterItemType.contracheque => 'Contracheque disponível',
    NotificationCenterItemType.pagamento => 'Novo pagamento disponível',
    NotificationCenterItemType.afastamento => 'Afastamento atualizado',
    NotificationCenterItemType.noticia => 'Nova notícia',
    NotificationCenterItemType.designacao => 'Nova designação',
    NotificationCenterItemType.live => 'Transmissão ao vivo',
  };
}

Set<String> _decodeReadKeys(String? text, String? username) {
  if (text == null || text.trim().isEmpty) return {};
  try {
    final decoded = jsonDecode(text);
    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      if (_normalizedUsername(map['username']?.toString()) != username) {
        return {};
      }
      final keys = map['keys'];
      if (keys is List) {
        return keys.map((item) => item.toString()).toSet();
      }
    }
    // Migração do formato anterior, que continha somente a lista.
    if (decoded is List) {
      return decoded.map((item) => item.toString()).toSet();
    }
  } catch (_) {
    // Dados locais inválidos são ignorados e substituídos no próximo uso.
  }
  return {};
}

List<NotificationCenterItem> _decodeInbox(String? text, String username) {
  if (text == null || text.trim().isEmpty) return [];
  try {
    final decoded = jsonDecode(text);
    if (decoded is Map) {
      final map = Map<String, dynamic>.from(decoded);
      if (_normalizedUsername(map['username']?.toString()) != username) {
        return [];
      }
      final items = map['items'];
      if (items is! List) return [];
      return items
          .whereType<Map>()
          .map(
            (json) => NotificationCenterItem.fromInboxJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .whereType<NotificationCenterItem>()
          .toList();
    }
  } catch (_) {
    // Dados locais inválidos são ignorados e substituídos no próximo uso.
  }
  return [];
}

List<NotificationCenterItem> _mergeInboxItem(
  List<NotificationCenterItem> current,
  NotificationCenterItem item,
) {
  return [
    item,
    ...current.where((existing) => existing.key != item.key),
  ].take(_maxInboxItems).toList();
}

Future<void> _persistInbox(
  FlutterSecureStorage storage,
  List<NotificationCenterItem> items,
  String username,
) {
  return storage.write(
    key: _inboxStorageKey,
    value: jsonEncode({
      'username': username,
      'items': items.map((item) => item.toInboxJson()).toList(),
    }),
  );
}

String? _normalizedUsername(String? value) {
  final username = value?.trim().toLowerCase();
  return username == null || username.isEmpty ? null : username;
}

NotificationCenterItem _noticiaItem(Noticia noticia) {
  final title = _requiredText(noticia.titulo, 'Nova notícia');
  final subtitle = _subtitleFrom([noticia.categoria, noticia.dataPublicacao]);

  return NotificationCenterItem(
    key:
        'noticia:${_requiredText(noticia.link, '$title|${noticia.dataPublicacao ?? ''}')}',
    type: NotificationCenterItemType.noticia,
    title: title,
    subtitle: subtitle.isEmpty ? 'Notícia disponível' : subtitle,
    targetUrl: noticia.link,
    imageUrl: noticia.imagemUrl,
    noticia: noticia,
  );
}

NotificationCenterItem _designacaoItem(DesignacaoAtiva designacao) {
  final subtitle = _subtitleFrom([designacao.tipoDescricao, designacao.orgao]);

  return NotificationCenterItem(
    key: 'designacao:${designacao.id}',
    type: NotificationCenterItemType.designacao,
    title: _requiredText(designacao.titulo, 'Nova designação'),
    subtitle: subtitle.isEmpty ? 'Designação ativa' : subtitle,
  );
}

String _subtitleFrom(List<String?> values) {
  return values
      .whereType<String>()
      .map((value) => value.trim())
      .where((value) => value.isNotEmpty)
      .join(' - ');
}

String _requiredText(String? value, String fallback) {
  final text = value?.trim();
  return text == null || text.isEmpty ? fallback : text;
}
