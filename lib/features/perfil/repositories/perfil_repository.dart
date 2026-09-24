import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/perfil_usuario.dart';

class PerfilRepository {
  final Dio dio;

  const PerfilRepository(this.dio);

  Future<PerfilUsuario> buscarPerfil({required String token}) async {
    final response = await dio.get(
      '/api/perfil/dados',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
        extra: {'skipAuthLogout': true},
      ),
    );

    final data = response.data as Map<String, dynamic>? ?? {};
    return PerfilUsuario.fromJson(
      data,
    ).copyWith(fotoUrl: '${dio.options.baseUrl}/carteiras-funcionais/foto');
  }
}

final perfilRepositoryProvider = Provider<PerfilRepository>((ref) {
  return PerfilRepository(ref.read(dioProvider));
});
