import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:notifications_challenge/core/config/app_config.dart';
import 'package:notifications_challenge/core/notifications_api/api_constants.dart';

class DioClient {
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        headers: const {
          Headers.acceptHeader: Headers.jsonContentType,
          Headers.contentTypeHeader: Headers.jsonContentType,
          'Authorization': 'Bearer ${AppConfig.apiBearerToken}',
        },
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (RequestOptions options, RequestInterceptorHandler handler) {
          _logger.i(<String, Object?>{
            'event': 'HTTP REQUEST',
            'method': options.method,
            'endpoint': options.uri.toString(),
            'queryParameters': options.queryParameters,
            //'headers': _redactedHeaders(options.headers),
            'body': options.data,
          });
          handler.next(options);
        },
        onResponse:
            (Response<dynamic> response, ResponseInterceptorHandler handler) {
              _logger.d({
                'event': 'HTTP RESPONSE',
                'method': response.requestOptions.method,
                'endpoint': response.requestOptions.uri.toString(),
                'statusCode': response.statusCode,
                // 'headers': _redactedHeaders({
                //   ...response.headers.map,
                // }),
                'response': response.data,
              });
              handler.next(response);
            },
        onError: (DioException error, ErrorInterceptorHandler handler) {
          _logger.e(
            {
              'event': 'HTTP ERROR',
              'method': error.requestOptions.method,
              'endpoint': error.requestOptions.uri.toString(),
              'queryParameters': error.requestOptions.queryParameters,
              'headers': _redactedHeaders(error.requestOptions.headers),
              'statusCode': error.response?.statusCode,
              'response': error.response?.data,
              'message': error.message,
            },
            error: error.error,
            stackTrace: error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );
  }

  static final DioClient instance = DioClient._internal();

  late final Dio _dio;
  final Logger _logger = Logger(
    filter: DevelopmentFilter(),
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 0),
  );

  void setBearerToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer ${token.trim()}';
  }

  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<dynamic> response = await _dio.get<dynamic>(
      '$baseUrl$endpoint',
      queryParameters: queryParameters,
    );
    return response;
  }

  Future<Response<dynamic>> post(
    String endpoint,
    Object body, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final Response<dynamic> response = await _dio.post<dynamic>(
      '$baseUrl$endpoint',
      queryParameters: queryParameters,
      data: body,
    );
    return response;
  }

  Map<String, Object?> _redactedHeaders(Map<String, dynamic> headers) {
    const Set<String> sensitiveHeaders = <String>{
      'authorization'
    };

    return <String, Object?>{
      for (final MapEntry<String, dynamic> header in headers.entries)
        header.key: sensitiveHeaders.contains(header.key.toLowerCase())
            ? _redactedHeaderValue(header.key, header.value)
            : header.value,
    };
  }

  String _redactedHeaderValue(String name, Object? value) {
    if (name.toLowerCase() == 'authorization' &&
        value.toString().toLowerCase().startsWith('bearer ')) {
      return 'Bearer ***';
    }
    return '***';
  }
}
