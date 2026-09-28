import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';

Dio dioComRotas(
  Map<String, FakeDioResponse> rotas, {
  String baseUrl = '',
  List<FakeDioRequest>? requests,
}) {
  final dio = Dio(BaseOptions(baseUrl: baseUrl));
  dio.httpClientAdapter = FakeDioAdapter(rotas, requests: requests);
  return dio;
}

class FakeDioResponse {
  final int statusCode;
  final Object? body;
  final Map<String, List<String>> headers;

  const FakeDioResponse(this.statusCode, this.body, {this.headers = const {}});
}

class FakeDioRequest {
  final String method;
  final String path;
  final Map<String, dynamic> queryParameters;
  final Object? data;
  final Map<String, dynamic> headers;
  final Map<String, dynamic> extra;
  final ResponseType? responseType;

  const FakeDioRequest({
    required this.method,
    required this.path,
    required this.queryParameters,
    required this.data,
    required this.headers,
    required this.extra,
    required this.responseType,
  });
}

class FakeDioAdapter implements HttpClientAdapter {
  final Map<String, FakeDioResponse> rotas;
  final List<FakeDioRequest>? requests;

  const FakeDioAdapter(this.rotas, {this.requests});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests?.add(
      FakeDioRequest(
        method: options.method,
        path: options.path,
        queryParameters: Map<String, dynamic>.from(options.queryParameters),
        data: options.data,
        headers: Map<String, dynamic>.from(options.headers),
        extra: Map<String, dynamic>.from(options.extra),
        responseType: options.responseType,
      ),
    );

    final response = rotas[options.path];
    if (response == null) {
      return ResponseBody.fromString(
        'Rota fake nao configurada: ${options.path}',
        404,
      );
    }

    final body = response.body;
    if (body == null) {
      return ResponseBody.fromString(
        '',
        response.statusCode,
        headers: response.headers,
      );
    }
    if (body is String) {
      return ResponseBody.fromString(
        body,
        response.statusCode,
        headers: response.headers,
      );
    }
    if (body is Uint8List) {
      return ResponseBody.fromBytes(
        body,
        response.statusCode,
        headers: response.headers,
      );
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      response.statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
        ...response.headers,
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
