import 'package:url_launcher/url_launcher.dart';

class ServicoLinksExternos {
  /// Retorna a URI para o telefone
  static Uri uriTelefone(String numero) => Uri.parse('tel:$numero');

  /// Abre o discador de telefone
  static Future<void> abrirTelefone(String numero) async {
    await _lancar(uriTelefone(numero));
  }

  /// Retorna a URI para o WhatsApp
  static Uri uriWhatsApp(String numero, {String? mensagem}) {
    final queryParameters = <String, String>{};
    if (mensagem != null && mensagem.isNotEmpty) {
      queryParameters['text'] = mensagem;
    }

    return Uri.https('api.whatsapp.com', '/send', {
      'phone': numero.replaceAll('+', ''),
      ...queryParameters,
    });
  }

  /// Abre o WhatsApp com uma mensagem opcional
  static Future<void> abrirWhatsApp(String numero, {String? mensagem}) async {
    await _lancar(
      uriWhatsApp(numero, mensagem: mensagem),
      mode: LaunchMode.externalApplication,
    );
  }

  /// Retorna a URI para e-mail
  static Uri uriEmail(String email) {
    return Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: const {'subject': 'Contato com a Ouvidoria do MPPB'},
    );
  }

  /// Abre o aplicativo de email
  static Future<void> abrirEmail(String email) async {
    final uri = uriEmail(email);
    if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }

    await _lancar(uri);
  }

  /// Retorna a URI para Google Maps
  static Uri uriMapa(String query) {
    return Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });
  }

  /// Abre o Google Maps com a query informada
  static Future<void> abrirMapa(String query) async {
    await _lancar(uriMapa(query), mode: LaunchMode.externalApplication);
  }

  /// Abre uma URL genérica (para redes sociais e notícias)
  static Future<void> abrirUrlExterna(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      await _lancar(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _lancar(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: mode);
    } else {
      throw Exception('Não foi possível abrir o link');
    }
  }
}
