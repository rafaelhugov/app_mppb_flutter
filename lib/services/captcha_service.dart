import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html_parser;
import '../features/ouvidoria/data/repositories/ouvidoria_dio_client.dart';

class CaptchaData {
  final String captchaId;
  final Uint8List imageBytes;

  CaptchaData({required this.captchaId, required this.imageBytes});
}

class CaptchaService {
  final Dio _dio = OuvidoriaDioClient.instance;
  static const String _captchaEndpoint = '/captcha-endpoint?get=html&c=defaultCaptchaStyle';

  Future<CaptchaData> fetchCaptcha() async {
    try {
      // 1. Obter o HTML do captcha, que seta o cookie na resposta via interceptor
      final response = await _dio.get(_captchaEndpoint);
      
      if (response.statusCode == 200) {
        final htmlContent = response.data.toString();
        final document = html_parser.parse(htmlContent);

        // 2. Extrair URL da imagem e o Captcha ID
        final imageElement = document.getElementById('defaultCaptchaStyle_CaptchaImage');
        final idElement = document.getElementById('BDC_VCID_defaultCaptchaStyle');

        if (imageElement == null || idElement == null) {
          throw Exception('Não foi possível encontrar os elementos do Captcha no HTML.');
        }

        final imageSrc = imageElement.attributes['src'];
        final captchaId = idElement.attributes['value'];

        if (imageSrc == null || captchaId == null) {
          throw Exception('Atributos do Captcha estão vazios no HTML.');
        }

        // 3. Baixar a imagem usando o mesmo Dio (o cookie será enviado automaticamente)
        final imageResponse = await _dio.get<List<int>>(
          imageSrc, // já é um caminho relativo, o dio resolve com baseUrl
          options: Options(responseType: ResponseType.bytes),
        );

        if (imageResponse.statusCode == 200 && imageResponse.data != null) {
          return CaptchaData(
            captchaId: captchaId,
            imageBytes: Uint8List.fromList(imageResponse.data!),
          );
        } else {
          throw Exception('Falha ao baixar imagem do Captcha.');
        }
      } else {
        throw Exception('Falha ao carregar HTML do Captcha.');
      }
    } catch (e) {
      throw Exception('Erro ao processar Captcha: $e');
    }
  }
}
