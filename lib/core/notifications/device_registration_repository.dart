import 'package:dio/dio.dart';

class DeviceRegistrationResponse {
  final String identificador;
  final String plataforma;
  final bool ativo;

  const DeviceRegistrationResponse({
    required this.identificador,
    required this.plataforma,
    required this.ativo,
  });

  factory DeviceRegistrationResponse.fromJson(Map<String, dynamic> json) {
    return DeviceRegistrationResponse(
      identificador: json['identificador']?.toString() ?? '',
      plataforma: json['plataforma']?.toString() ?? '',
      ativo: json['ativo'] == true,
    );
  }
}

class DeviceRegistrationRepository {
  final Dio dio;

  const DeviceRegistrationRepository(this.dio);

  Future<DeviceRegistrationResponse> registrar({
    required String identificador,
    required String tokenFcm,
    required String plataforma,
  }) async {
    final response = await dio.post(
      '/api/notificacoes/dispositivos',
      data: {
        'identificador': identificador,
        'tokenFcm': tokenFcm,
        'plataforma': plataforma,
      },
      options: Options(extra: {'skipAuthLogout': true}),
    );
    return DeviceRegistrationResponse.fromJson(
      response.data as Map<String, dynamic>? ?? {},
    );
  }

  Future<void> desativar({required String identificador}) async {
    await dio.delete<void>(
      '/api/notificacoes/dispositivos/${Uri.encodeComponent(identificador)}',
      options: Options(extra: {'skipAuthLogout': true}),
    );
  }
}
