import 'package:app_mppb_flutter/core/notifications/notification_center_provider.dart';
import 'package:app_mppb_flutter/features/designacoes/models/designacao_ativa.dart';
import 'package:app_mppb_flutter/features/noticias/models/noticia.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monta notificacoes separadas e filtra as ja lidas', () {
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

    expect(items, hasLength(2));
    expect(items.map((item) => item.key), [
      'noticia:https://mppb.mp.br/segunda',
      'designacao:42',
    ]);
    expect(items.first.title, 'Segunda noticia');
    expect(items.first.subtitle, 'Cidadania - 08/09/2026');
    expect(items.first.targetUrl, 'https://mppb.mp.br/segunda');
    expect(items.first.imageUrl, 'https://mppb.mp.br/segunda.jpg');
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
}
