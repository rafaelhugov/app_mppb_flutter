import 'dart:convert';
import 'dart:typed_data';

import 'package:app_mppb_flutter/features/auth/repositories/biometric_auth_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ativa credencial revogavel sem enviar senha', () async {
    final adapter = _CaptureAdapter({
      'credencial': 'BIO1.seletor.segredo',
      'expiraEm': '2026-11-13T12:00:00',
    });
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = BiometricAuthRepository(
      dio: dio,
      baseUrl: 'https://api.test/',
    );

    final response = await repository.activate(
      token: 'token-institucional',
      deviceId: 'device-1',
      platform: 'ANDROID',
    );

    expect(adapter.options.path, 'https://api.test/api/biometria/credenciais');
    expect(
      adapter.options.headers['Authorization'],
      'Bearer token-institucional',
    );
    expect(adapter.decodedBody, {
      'dispositivoId': 'device-1',
      'plataforma': 'ANDROID',
    });
    expect(adapter.decodedBody.containsKey('senha'), isFalse);
    expect(response.credential, 'BIO1.seletor.segredo');
  });

  test('troca credencial biometrica por token no gateway mobile', () async {
    final adapter = _CaptureAdapter({'token': 'token-validado'});
    final dio = Dio()..httpClientAdapter = adapter;
    final repository = BiometricAuthRepository(
      dio: dio,
      baseUrl: 'https://api.test',
    );

    final response = await repository.authenticate(
      credential: 'BIO1.seletor.segredo',
    );

    expect(
      adapter.options.path,
      'https://api.test/api/public/biometria/autenticar',
    );
    expect(adapter.decodedBody, {'credencial': 'BIO1.seletor.segredo'});
    expect(response.token, 'token-validado');
  });
}

class _CaptureAdapter implements HttpClientAdapter {
  final Object responseBody;
  late RequestOptions options;
  Map<String, dynamic> decodedBody = const {};

  _CaptureAdapter(this.responseBody);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    this.options = options;
    decodedBody = Map<String, dynamic>.from(options.data as Map);
    return ResponseBody.fromString(
      jsonEncode(responseBody),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
