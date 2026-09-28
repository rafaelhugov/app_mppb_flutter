import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

Dio dioComRotas(
  Map<String, FakeDioResponse> rotas, {
  String baseUrl = '',
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.httpClientAdapter = FakeDioAdapter(rotas);
  return dio;
}

class FakeDioResponse {
  final int statusCode;
  final Object? body;

  const FakeDioResponse(this.statusCode, this.body);
}

class FakeDioAdapter implements HttpClientAdapter {
  final Map<String, FakeDioResponse> rotas;

  const FakeDioAdapter(this.rotas);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final response = rotas[options.path];
    if (response == null) {
      return ResponseBody.fromString(
        'Rota fake nao configurada: ${options.path}',
        404,
      );
    }

    final body = response.body;
    if (body == null) {
      return ResponseBody.fromString('', response.statusCode);
    }
    if (body is String) {
      return ResponseBody.fromString(body, response.statusCode);
    }
    if (body is Uint8List) {
      return ResponseBody.fromBytes(body, response.statusCode);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      response.statusCode,
      headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
    );
  }

  @override
  void close({bool force = false}) {}
}
