import 'package:app_mppb_flutter/core/notifications/push_notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('mantem somente payload tecnico permitido', () {
    final payload = PushTechnicalPayload.fromData({
      'tipo_evento': 'NOVAS_DESIGNACOES',
      'rota': '/designacoes',
      'nome': 'Pessoa',
      'matricula': '12345',
      'processo': '0000000',
      'jwt': 'token',
    });

    expect(payload.isSupportedDesignacaoSignal, isTrue);
    expect(payload.isSupportedNoticiasSignal, isFalse);
    expect(payload.toAllowedData(), {
      'tipo_evento': 'NOVAS_DESIGNACOES',
      'rota': '/designacoes',
    });
  });

  test('reconhece payload tecnico publico de noticias', () {
    final payload = PushTechnicalPayload.fromData({
      'tipo_evento': 'NOVAS_NOTICIAS',
      'rota': '/noticias',
      'noticia_chave': 'chave-1',
      'noticia_link': 'https://www.mppb.mp.br/noticia/1',
      'noticia_titulo': 'Titulo publico',
      'jwt': 'token',
      'matricula': '12345',
    });

    expect(payload.isSupportedNoticiasSignal, isTrue);
    expect(payload.isSupportedDesignacaoSignal, isFalse);
    expect(payload.toAllowedData(), {
      'tipo_evento': 'NOVAS_NOTICIAS',
      'rota': '/noticias',
      'noticia_chave': 'chave-1',
      'noticia_link': 'https://www.mppb.mp.br/noticia/1',
      'noticia_titulo': 'Titulo publico',
    });
    expect(payload.toAllowedData().containsKey('jwt'), isFalse);
    expect(payload.toAllowedData().containsKey('matricula'), isFalse);
  });

  test('reconhece payload tecnico publico de lives', () {
    final payload = PushTechnicalPayload.fromData({
      'tipo_evento': 'NOVA_LIVE',
      'rota': '/videos',
      'live_id': 'live_xyz',
      'live_titulo': 'Sessão Solene de Posse',
      'live_url': 'https://youtube.com/watch?v=live_xyz',
      'jwt': 'token_ignorado',
    });

    expect(payload.isSupportedLivesSignal, isTrue);
    expect(payload.isSupportedNoticiasSignal, isFalse);
    expect(payload.isSupportedDesignacaoSignal, isFalse);
    expect(payload.toAllowedData(), {
      'tipo_evento': 'NOVA_LIVE',
      'rota': '/videos',
      'live_id': 'live_xyz',
      'live_titulo': 'Sessão Solene de Posse',
      'live_url': 'https://youtube.com/watch?v=live_xyz',
    });
    expect(payload.toAllowedData().containsKey('jwt'), isFalse);
  });

  test('normaliza valores vazios do payload tecnico', () {
    final payload = PushTechnicalPayload.fromData({
      'tipo_evento': ' ',
      'rota': null,
    });

    expect(payload.tipoEvento, isNull);
    expect(payload.rota, isNull);
    expect(payload.toAllowedData(), isEmpty);
  });
}
