import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

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

  Future<void> solicitarMarcacaoFerias({
    required String token,
    required int concessaoId,
    required DateTime dataInicial,
    required int numeroDias,
  }) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    await dio.post(
      '/api/recursos-humanos/concessoes/$concessaoId/solicitacoes',
      queryParameters: {'token': token},
      data: {
        'dataInicial': dateFormat.format(dataInicial),
        'numeroDias': numeroDias,
      },
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
  }

  Future<List<String>> buscarSugestoesDatasFinais({
    required String token,
    required int concessaoId,
    required DateTime dataInicial,
  }) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final response = await dio.get(
      '/api/recursos-humanos/concessoes/$concessaoId/sugestoes-datas-finais',
      queryParameters: {
        'token': token,
        'dataInicial': dateFormat.format(dataInicial),
      },
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    return _parseSugestoes(response.data);
  }

  List<String> _parseSugestoes(dynamic data) {
    if (data is List) {
      return data.map(_sugestaoText).whereType<String>().toList();
    }
    if (data is Map<String, dynamic>) {
      for (final key in [
        'intervalos',
        'sugestoes',
        'datasFinais',
        'datas',
        'resultados',
      ]) {
        final value = data[key];
        if (value is List) {
          return value.map(_sugestaoText).whereType<String>().toList();
        }
      }
      final single = _sugestaoText(data);
      return single == null ? [] : [single];
    }
    final text = _sugestaoText(data);
    return text == null ? [] : [text];
  }

  String? _sugestaoText(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    if (value is Map<String, dynamic>) {
      final inicio =
          value['dataInicial'] ?? value['inicio'] ?? value['dataInicio'];
      final fim = value['dataFinal'] ?? value['fim'] ?? value['dataFim'];
      final dias = value['numeroDias'] ?? value['dias'];
      if (inicio != null && fim != null) {
        return dias == null ? '$inicio a $fim' : '$inicio a $fim ($dias dias)';
      }
      if (fim != null) return 'Até $fim';
      return value.values.map((item) => item.toString()).join(' - ');
    }
    return value.toString();
  }
}

final concessaoFolgaRepositoryProvider = Provider<ConcessaoFolgaRepository>((
  ref,
) {
  return ConcessaoFolgaRepository(ref.read(dioProvider));
});
