import 'package:app_mppb_flutter/core/notifications/notification_center_provider.dart';
import 'package:app_mppb_flutter/features/designacoes/models/designacao_ativa.dart';
import 'package:app_mppb_flutter/features/noticias/models/noticia.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('ao visualizar o sino marca todos os avisos como lidos', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await Future<void>.delayed(Duration.zero);
    await container.read(notificationCenterProvider.notifier).markAllAsRead([
      'noticia:1',
      'designacao:2',
    ]);

    expect(container.read(notificationCenterProvider).readKeys, {
      'noticia:1',
      'designacao:2',
    });
  });

  test('monta notificacoes preservando historico e sinalizando lidas', () {
    final noticias = [
      Noticia(
        titulo: 'Primeira noticia',
        link: 'https://mppb.mp.br/primeira',
        categoria: 'Institucional',
        dataPublicacao: '08/09/2026',
      ),
      Noticia(
        titulo: 'Segunda noticia',
        link: 'https://mppb.mp.br/segunda',
        imagemUrl: 'https://mppb.mp.br/segunda.jpg',
        categoria: 'Cidadania',
        dataPublicacao: '08/09/2026',
      ),
    ];
    const designacoes = [
      DesignacaoAtiva(
        id: 42,
        tipoCodigo: 'DES',
        tipoDescricao: 'Designação',
        titulo: 'Promotoria de Justiça',
        orgao: 'Promotoria A',
      ),
    ];

    final items = buildNotificationCenterItems(
      noticias: noticias,
      designacoes: designacoes,
      readKeys: const {'noticia:https://mppb.mp.br/primeira'},
      includeDesignacoes: true,
    );

    expect(items, hasLength(3));
    final primeira = items.firstWhere(
      (item) => item.key == 'noticia:https://mppb.mp.br/primeira',
    );
    final segunda = items.firstWhere(
      (item) => item.key == 'noticia:https://mppb.mp.br/segunda',
    );
    final designacao = items.firstWhere((item) => item.key == 'designacao:42');

    expect(primeira.isRead, isTrue);
    expect(segunda.isRead, isFalse);
    expect(designacao.isRead, isFalse);
    expect(segunda.title, 'Segunda noticia');
    expect(segunda.subtitle, 'Cidadania - 08/09/2026');
    expect(segunda.targetUrl, 'https://mppb.mp.br/segunda');
    expect(segunda.imageUrl, 'https://mppb.mp.br/segunda.jpg');
  });

  test('na area publica mostra apenas notificacoes de noticias', () {
    final items = buildNotificationCenterItems(
      noticias: [
        Noticia(titulo: 'Noticia publica', link: 'https://mppb.mp.br/publica'),
      ],
      designacoes: const [
        DesignacaoAtiva(
          id: 7,
          tipoCodigo: 'DES',
          tipoDescricao: 'Designação',
          titulo: 'Designação restrita',
        ),
      ],
      readKeys: const {},
      includeDesignacoes: false,
    );

    expect(items, hasLength(1));
    expect(items.single.type, NotificationCenterItemType.noticia);
    expect(items.single.title, 'Noticia publica');
  });

  test('converte push funcional em item persistivel da central', () {
    const message = RemoteMessage(
      messageId: 'mensagem-1',
      data: {
        'tipo_evento': 'NOVO_PAGAMENTO',
        'rota': '/pagamentos',
        'id_evento_notificacao': 'NOVO_PAGAMENTO_42',
      },
      notification: RemoteNotification(
        title: 'Novo pagamento disponível',
        body: 'Há um novo pagamento disponível no MPPB+.',
      ),
    );

    final item = notificationCenterItemFromRemoteMessage(message);

    expect(item?.key, 'push:NOVO_PAGAMENTO_42');
    expect(item?.type, NotificationCenterItemType.pagamento);
    expect(item?.targetRoute, '/pagamentos');
    expect(item?.title, 'Novo pagamento disponível');
  });

  test('preferencias ocultam categorias desabilitadas da central', () {
    final items = buildNotificationCenterItems(
      noticias: [
        Noticia(titulo: 'Noticia', link: 'https://mppb.mp.br/noticia'),
      ],
      designacoes: const [],
      readKeys: const {},
      includeNoticias: false,
      includeDesignacoes: false,
      includePagamentos: false,
      inboxItems: const [
        NotificationCenterItem(
          key: 'push:pagamento-1',
          type: NotificationCenterItemType.pagamento,
          title: 'Pagamento',
          subtitle: 'Disponível',
        ),
        NotificationCenterItem(
          key: 'push:contracheque-1',
          type: NotificationCenterItemType.contracheque,
          title: 'Contracheque',
          subtitle: 'Disponível',
        ),
      ],
    );

    expect(items, hasLength(1));
    expect(items.single.type, NotificationCenterItemType.contracheque);
  });

  test('historico funcional fica isolado por usuario do aparelho', () async {
    FlutterSecureStorage.setMockInitialValues({'auth_username': 'usuario-a'});
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await Future<void>.delayed(Duration.zero);

    await container
        .read(notificationCenterProvider.notifier)
        .recordRemoteMessage(
          const RemoteMessage(
            messageId: 'contracheque-1',
            data: {'tipo_evento': 'NOVO_CONTRACHEQUE', 'rota': '/contracheque'},
          ),
        );
    expect(container.read(notificationCenterProvider).inboxItems, hasLength(1));

    const storage = FlutterSecureStorage();
    await storage.write(key: 'auth_username', value: 'usuario-b');
    await container.read(notificationCenterProvider.notifier).reload();

    expect(container.read(notificationCenterProvider).inboxItems, isEmpty);
  });
}
