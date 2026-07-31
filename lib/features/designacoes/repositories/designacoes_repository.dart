import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/designacao_ativa.dart';

class DesignacoesRepository {
  final Dio dio;

  const DesignacoesRepository(this.dio);

  Future<DesignacoesAtivasResponse> buscarAtivas({required String token}) async {
    final response = await dio.get(
      '/api/designacoes/ativas',
      queryParameters: {'token': token},
      options: Options(
        headers: {'Authorization': 'Token $token'},
        extra: {'skipAuthLogout': true},
      ),
    );
    return DesignacoesAtivasResponse.fromJson(
      response.data as Map<String, dynamic>? ?? {},
    );
  }
}

final designacoesRepositoryProvider = Provider<DesignacoesRepository>((ref) {
  return DesignacoesRepository(ref.read(dioProvider));
});
