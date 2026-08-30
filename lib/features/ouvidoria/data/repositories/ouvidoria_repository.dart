import 'package:dio/dio.dart';
import 'ouvidoria_dio_client.dart';
import '../models/combo_models.dart';

class OuvidoriaRepository {
  final Dio _dio = OuvidoriaDioClient.instance;

  Future<List<ComboItem>> fetchTipos() async {
    return _fetchCombo('/tipos');
  }

  Future<List<ComboItem>> fetchAssuntos(int materiaId) async {
    return _fetchCombo('/assuntos/$materiaId');
  }

  Future<List<ComboItem>> fetchMunicipios() async {
    return _fetchCombo('/municipios');
  }

  Future<List<ComboItem>> fetchBairros(int municipioId) async {
    return _fetchCombo('/bairros', queryParameters: {'municipio': municipioId});
  }

  Future<List<ComboItem>> _fetchCombo(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is List) {
          return data.map((json) => ComboItem.fromJson(json)).toList();
        } else if (data is Map && data.containsKey('content')) {
          // Spring Data REST Paged resources
          final content = data['content'] as List;
          return content.map((json) => ComboItem.fromJson(json)).toList();
        }
        return [];
      } else {
        throw Exception('Erro ao buscar dados de $path');
      }
    } catch (e) {
      throw Exception('Falha em _fetchCombo $path: $e');
    }
  }
}
