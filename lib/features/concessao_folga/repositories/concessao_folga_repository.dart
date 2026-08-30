import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/ausencia_calendario.dart';
import '../models/concessao_folga.dart';

class ConcessaoFolgaRepository {
  final Dio dio;

  const ConcessaoFolgaRepository(this.dio);

  Future<List<ConcessaoFolga>> buscarConcessoesVigentes({
    required String token,
  }) async {
    final response = await dio.get(
      '/api/recursos-humanos/minhas-concessoes-folga',
      queryParameters: {'token': token},
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    if (response.data is! List) {
      throw Exception('Formato inesperado (Concessoes): ${response.data}');
    }
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map((json) => ConcessaoFolga.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AusenciaCalendario>> buscarAusenciasCalendario({
    required String token,
    int? mes,
    int? ano,
  }) async {
    final query = <String, dynamic>{'token': token};
    if (mes != null) query['mes'] = mes;
    if (ano != null) query['ano'] = ano;
    
    final response = await dio.get(
      '/api/recursos-humanos/minhas-ausencias',
      queryParameters: query,
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    if (response.data is! List) {
      throw Exception('Formato inesperado (Ausencias): ${response.data}');
    }
    final data = response.data as List<dynamic>? ?? [];
    return data
        .map(
          (json) => AusenciaCalendario.fromJson(json as Map<String, dynamic>),
        )
        .toList();
  }
}

final concessaoFolgaRepositoryProvider = Provider<ConcessaoFolgaRepository>((
  ref,
) {
  return ConcessaoFolgaRepository(ref.read(dioProvider));
});
