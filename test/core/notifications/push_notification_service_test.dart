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
      'jwt': 'token',
      'matricula': '12345',
    });

    expect(payload.isSupportedNoticiasSignal, isTrue);
    expect(payload.isSupportedDesignacaoSignal, isFalse);
    expect(payload.toAllowedData(), {
      'tipo_evento': 'NOVAS_NOTICIAS',
      'rota': '/noticias',
    });
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
