import 'package:dio/dio.dart';
import '../features/ouvidoria/data/models/manifestacao_request_model.dart';
import '../features/ouvidoria/data/repositories/ouvidoria_dio_client.dart';

class UploadService {
  final Dio _dio = OuvidoriaDioClient.instance;

  Future<String?> enviarManifestacao({
    required ManifestacaoRequestModel requestModel,
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final formDataMap = requestModel.toFormDataMap();
      
      final List<MultipartFile> multipartFiles = [];
      for (final anexo in requestModel.anexos) {
        multipartFiles.add(
          await MultipartFile.fromFile(anexo.path, filename: anexo.name),
        );
      }
      
      if (multipartFiles.isNotEmpty) {
        formDataMap['files'] = multipartFiles;
      }

      final formData = FormData.fromMap(formDataMap, ListFormat.multiCompatible);

      final response = await _dio.post(
        '/manifestacoes',
        data: formData,
        onSendProgress: onProgress,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Retorna o protocolo
        final data = response.data;
        if (data is Map && data.containsKey('protocolo')) {
          return data['protocolo'].toString();
        }
        return 'Sucesso'; 
      } else {
        throw Exception('Erro ao enviar manifestação: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Falha no serviço de upload: $e');
    }
  }
}
