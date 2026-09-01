import 'package:flutter_test/flutter_test.dart';
import 'package:app_mppb_flutter/features/contatos/dados/dados_institucionais.dart';
import 'package:app_mppb_flutter/features/contatos/servicos/servico_links_externos.dart';

void main() {
  group('DadosInstitucionais', () {
    test('garantir formato de telefone correto para URIs', () {
      expect(DadosInstitucionais.telefoneSede, '8321076000');
      expect(DadosInstitucionais.telefoneOuvidoria, '8321076150');
      expect(DadosInstitucionais.whatsappOuvidoria, '+5583991817355');
    });

    test('garantir URIs e links oficiais das redes sociais', () {
      expect(DadosInstitucionais.urlInstagram, 'https://www.instagram.com/mppboficial/');
      expect(DadosInstitucionais.urlYoutube, 'https://www.youtube.com/channel/UCuJdx9nS7yyth_Cu0Kd8lMw');
      expect(DadosInstitucionais.urlX, 'https://x.com/mppboficial');
      expect(DadosInstitucionais.urlFacebook, 'https://www.facebook.com/mppboficial');
    });
  });

  group('ServicoLinksExternos', () {
    test('garantir geração correta da URI do WhatsApp', () {
      final uri = ServicoLinksExternos.uriWhatsApp('83991817355', mensagem: 'Olá MPPB');
      expect(uri.scheme, 'https');
      expect(uri.host, 'api.whatsapp.com');
      expect(uri.path, '/send');
      expect(uri.queryParameters['phone'], '83991817355');
      expect(uri.queryParameters['text'], 'Olá MPPB');
    });

    test('garantir geração correta da URI do Telefone', () {
      final uri = ServicoLinksExternos.uriTelefone('8321076000');
      expect(uri.scheme, 'tel');
      expect(uri.path, '8321076000');
    });

    test('garantir geração correta da URI do E-mail', () {
      final uri = ServicoLinksExternos.uriEmail('ouvidoria@mppb.mp.br');
      expect(uri.scheme, 'mailto');
      expect(uri.path, 'ouvidoria@mppb.mp.br');
    });

    test('garantir geração correta da URI do Google Maps', () {
      final uri = ServicoLinksExternos.uriMapa('Ministério Público da Paraíba');
      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/search/');
      expect(uri.queryParameters['api'], '1');
      expect(uri.queryParameters['query'], 'Ministério Público da Paraíba');
    });

    test('métodos de serviço existem e podem ser referenciados', () {
      expect(ServicoLinksExternos.abrirTelefone, isNotNull);
      expect(ServicoLinksExternos.abrirWhatsApp, isNotNull);
      expect(ServicoLinksExternos.abrirEmail, isNotNull);
      expect(ServicoLinksExternos.abrirMapa, isNotNull);
      expect(ServicoLinksExternos.abrirUrlExterna, isNotNull);
    });
  });
}
