import 'package:dio/dio.dart';

class BiometricCredentialResponse {
  final String credential;
  final DateTime? expiresAt;

  const BiometricCredentialResponse({required this.credential, this.expiresAt});

  factory BiometricCredentialResponse.fromJson(Map<String, dynamic> json) {
    return BiometricCredentialResponse(
      credential: json['credencial']?.toString() ?? '',
      expiresAt: DateTime.tryParse(json['expiraEm']?.toString() ?? ''),
    );
  }
}

class BiometricLoginResponse {
  final String token;

  const BiometricLoginResponse({required this.token});

  factory BiometricLoginResponse.fromJson(Map<String, dynamic> json) {
    return BiometricLoginResponse(token: json['token']?.toString() ?? '');
  }
}

class BiometricAuthRepository {
  final Dio dio;
  final String baseUrl;

  const BiometricAuthRepository({required this.dio, required this.baseUrl});

  Future<BiometricCredentialResponse> activate({
    required String token,
    required String deviceId,
    required String platform,
  }) async {
    final response = await dio.post(
      _url('/api/biometria/credenciais'),
      data: {'dispositivoId': deviceId, 'plataforma': platform},
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
    return BiometricCredentialResponse.fromJson(
      response.data as Map<String, dynamic>? ?? const {},
    );
  }

  Future<BiometricLoginResponse> authenticate({
    required String credential,
  }) async {
    final response = await dio.post(
      _url('/api/public/biometria/autenticar'),
      data: {'credencial': credential},
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    return BiometricLoginResponse.fromJson(
      response.data as Map<String, dynamic>? ?? const {},
    );
  }

  Future<void> revoke({required String token, required String deviceId}) async {
    await dio.delete<void>(
      _url('/api/biometria/credenciais/${Uri.encodeComponent(deviceId)}'),
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
  }

  String _url(String path) {
    final normalized = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    return '$normalized$path';
  }
}
