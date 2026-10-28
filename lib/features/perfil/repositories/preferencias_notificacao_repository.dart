import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/preferencias_notificacao.dart';

class PreferenciasNotificacaoRepository {
  final Dio dio;

  const PreferenciasNotificacaoRepository(this.dio);

  Future<PreferenciasNotificacao> buscar({required String token}) async {
    final response = await dio.get(
      '/api/notificacoes/preferencias',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    return PreferenciasNotificacao.fromJson(
      response.data as Map<String, dynamic>? ?? const {},
    );
  }

  Future<PreferenciasNotificacao> salvar({
    required String token,
    required PreferenciasNotificacao preferencias,
  }) async {
    final response = await dio.put(
      '/api/notificacoes/preferencias',
      data: preferencias.toApiJson(),
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    return PreferenciasNotificacao.fromJson(
      response.data as Map<String, dynamic>? ?? const {},
    );
  }
}

final preferenciasNotificacaoRepositoryProvider =
    Provider<PreferenciasNotificacaoRepository>((ref) {
      return PreferenciasNotificacaoRepository(ref.read(dioProvider));
    });
