import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

enum ApiErrorType {
  badResponse,
  invalidResponse,
  connection,
  timeout,
  cancelled,
  unknown,
}

class ApiError extends Equatable implements Exception {
  final String message;
  final int? statusCode;
  final ApiErrorType type;
  final Object? details;

  const ApiError({
    required this.message,
    required this.type,
    this.statusCode,
    this.details,
  });

  bool get isUnauthorized => statusCode == 401;

  factory ApiError.fromDioException(DioException exception) {
    final Object? responseData = exception.response?.data;

    return ApiError(
      message: _resolveMessage(exception, responseData),
      statusCode: exception.response?.statusCode,
      type: _resolveType(exception.type),
      details: responseData,
    );
  }

  factory ApiError.invalidResponse(Object exception, {int? statusCode}) {
    return ApiError(
      message: 'La API devolvió una respuesta con un formato inesperado.',
      statusCode: statusCode,
      type: ApiErrorType.invalidResponse,
      details: exception,
    );
  }

  static String _resolveMessage(DioException exception, Object? responseData) {
    if (responseData is Map<String, dynamic>) {
      final Object? apiMessage = responseData['message'];

      if (apiMessage is String && apiMessage.isNotEmpty) {
        return apiMessage;
      }
      if (apiMessage is List<dynamic> && apiMessage.isNotEmpty) {
        return apiMessage
            .map((dynamic message) => message.toString())
            .join(', ');
      }
    }

    return switch (exception.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        'La solicitud superó el tiempo de espera.',
      DioExceptionType.connectionError =>
        'No se pudo establecer conexión con la API.',
      DioExceptionType.cancel => 'La solicitud fue cancelada.',
      DioExceptionType.badCertificate =>
        'No se pudo validar el certificado de la API.',
      DioExceptionType.badResponse =>
        'La API respondió con un error${exception.response?.statusCode == null ? '' : ' (${exception.response!.statusCode})'}.',
      DioExceptionType.unknown =>
        exception.message ?? 'Ocurrió un error inesperado al consultar la API.',
    };
  }

  static ApiErrorType _resolveType(DioExceptionType type) {
    return switch (type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout => ApiErrorType.timeout,
      DioExceptionType.connectionError ||
      DioExceptionType.badCertificate => ApiErrorType.connection,
      DioExceptionType.badResponse => ApiErrorType.badResponse,
      DioExceptionType.cancel => ApiErrorType.cancelled,
      DioExceptionType.unknown => ApiErrorType.unknown,
    };
  }

  @override
  List<Object?> get props => <Object?>[message, statusCode, type, details];

  @override
  String toString() {
    return 'ApiError(type: $type, statusCode: $statusCode, message: $message)';
  }
}
