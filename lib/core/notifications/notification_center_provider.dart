import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/designacoes/models/designacao_ativa.dart';
import '../../features/noticias/models/noticia.dart';
import '../storage/secure_storage.dart';

const _readKeysStorageKey = 'notification_center_read_keys_v1';

enum NotificationCenterItemType { noticia, designacao }

class NotificationCenterItem {
  final String key;
  final NotificationCenterItemType type;
  final String title;
  final String subtitle;
  final String? targetUrl;
  final String? imageUrl;
  final Noticia? noticia;

  const NotificationCenterItem({
    required this.key,
    required this.type,
    required this.title,
    required this.subtitle,
    this.targetUrl,
    this.imageUrl,
    this.noticia,
  });
}

class NotificationCenterState {
  final bool isLoading;
  final Set<String> readKeys;

  const NotificationCenterState({
    this.isLoading = true,
    this.readKeys = const {},
  });

  NotificationCenterState copyWith({bool? isLoading, Set<String>? readKeys}) {
    return NotificationCenterState(
      isLoading: isLoading ?? this.isLoading,
      readKeys: readKeys ?? this.readKeys,
    );
  }
}

class NotificationCenterNotifier extends Notifier<NotificationCenterState> {
  @override
  NotificationCenterState build() {
    Future.microtask(_loadReadKeys);
    return const NotificationCenterState();
  }

  Future<void> markAsRead(String key) async {
    if (key.trim().isEmpty || state.readKeys.contains(key)) {
      return;
    }

    final updated = {...state.readKeys, key};
    state = state.copyWith(readKeys: updated);
    await _persist(updated);
  }

  Future<void> markAllAsRead(Iterable<String> keys) async {
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

  Future<void> _loadReadKeys() async {
    final storage = ref.read(secureStorageProvider);
    final text = await storage.read(key: _readKeysStorageKey);
    if (!ref.mounted) return;
    if (text == null || text.trim().isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is List) {
        state = state.copyWith(
          isLoading: false,
          readKeys: decoded.map((item) => item.toString()).toSet(),
        );
        return;
      }
    } catch (_) {
      await storage.delete(key: _readKeysStorageKey);
    }

    state = state.copyWith(isLoading: false);
  }

  Future<void> _persist(Set<String> keys) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(
      key: _readKeysStorageKey,
      value: jsonEncode(keys.toList()..sort()),
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
}) {
  final items = <NotificationCenterItem>[
    ...noticias.map(_noticiaItem),
    if (includeDesignacoes) ...designacoes.map(_designacaoItem),
  ];
  return items.where((item) => !readKeys.contains(item.key)).toList();
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
