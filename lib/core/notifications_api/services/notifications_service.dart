import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:notifications_challenge/core/notifications_api/dio_client.dart';
import 'package:notifications_challenge/core/notifications_api/endpoints/notifications_endpoints.dart'
    as endpoints;
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/get_notifications_params.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notifications_list.dart';

class NotificationsService {
  final DioClient _dioClient;

  NotificationsService({DioClient? dioClient})
    : _dioClient = dioClient ?? DioClient.instance;

  Future<Either<ApiError, NotificationsList>> getNotifications(
    GetNotificationsParams params,
  ) async {
    late final Response<dynamic> response;
    try {
      response = await _dioClient.get(
        endpoints.getNotifications,
        queryParameters: params.toQueryParameters(),
      );
    } on DioException catch (exception) {
      return Left<ApiError, NotificationsList>(
        ApiError.fromDioException(exception),
      );
    }

    return _deserializeResponse<NotificationsList>(
      response,
      (Object? data) => NotificationsList.fromMap(data as Map<String, dynamic>),
    );
  }

  Future<Either<ApiError, List<Notification>>> createNotification(
    CreateNotificationDto notification,
  ) async {
    late final Response<dynamic> response;
    try {
      response = await _dioClient.post(
        endpoints.createNotification,
        notification.toJson(),
      );
    } on DioException catch (exception) {
      return Left<ApiError, List<Notification>>(
        ApiError.fromDioException(exception),
      );
    }

    return _deserializeResponse<List<Notification>>(response, (
      Object? responseData,
    ) {
      final List<dynamic> data = responseData as List<dynamic>;
      return data
          .map(
            (dynamic item) =>
                Notification.fromMap(item as Map<String, dynamic>),
          )
          .toList();
    });
  }

  Either<ApiError, T> _deserializeResponse<T>(
    Response<dynamic> response,
    T Function(Object? data) deserialize,
  ) {
    try {
      return Right<ApiError, T>(deserialize(response.data));
    } on Object catch (exception) {
      return Left<ApiError, T>(
        ApiError.invalidResponse(exception, statusCode: response.statusCode),
      );
    }
  }
}
