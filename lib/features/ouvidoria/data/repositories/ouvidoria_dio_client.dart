import 'package:dio/dio.dart';

class OuvidoriaDioClient {
  // Use a singleton Dio instance for the Ouvidoria feature to maintain the session
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://ouvidoria-api.mppb.mp.br',
    ),
  )..interceptors.add(_SessionInterceptor());
  
  static Dio get instance => _dio;
}

class _SessionInterceptor extends Interceptor {
  String? sessionCookie;

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final cookies = response.headers['set-cookie'];
    if (cookies != null && cookies.isNotEmpty) {
      for (var cookie in cookies) {
        if (cookie.contains('JSESSIONID')) {
          sessionCookie = cookie.split(';').first;
        }
      }
      if (sessionCookie == null && cookies.isNotEmpty) {
        sessionCookie = cookies.first.split(';').first;
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (sessionCookie != null) {
      options.headers['Cookie'] = sessionCookie;
    }
    super.onRequest(options, handler);
  }
}
