import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/notifications_api/dio_client.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/get_notifications_params.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notifications_list.dart';
import 'package:notifications_challenge/core/notifications_api/services/notifications_service.dart';

void main() {
  test('GET transforma una respuesta inválida en ApiError', () async {
    final NotificationsService service = NotificationsService(
      dioClient: _FakeDioClient(
        getData: <String, dynamic>{
          'data': 'invalid-list',
          'meta': <String, dynamic>{},
        },
      ),
    );

    final Either<ApiError, NotificationsList> result = await service
        .getNotifications(const GetNotificationsParams());

    expect(result.isLeft, isTrue);
    expect(result.left.type, ApiErrorType.invalidResponse);
    expect(result.left.statusCode, 200);
    expect(
      result.left.message,
      'La API devolvió una respuesta con un formato inesperado.',
    );
    expect(result.left.details, isA<TypeError>());
  });

  test('POST transforma una respuesta inválida en ApiError', () async {
    final NotificationsService service = NotificationsService(
      dioClient: _FakeDioClient(postData: <String, dynamic>{'id': 'invalid'}),
    );
    const CreateNotificationDto notification = CreateNotificationDto(
      title: 'Título',
      body: 'Cuerpo',
      recipientIds: <String>['usr_1'],
      priority: PriorityEnum.normal,
    );

    final Either<ApiError, List<Notification>> result = await service
        .createNotification(notification);

    expect(result.isLeft, isTrue);
    expect(result.left.type, ApiErrorType.invalidResponse);
    expect(result.left.statusCode, 201);
    expect(result.left.details, isA<TypeError>());
  });
}

class _FakeDioClient implements DioClient {
  final Object? getData;
  final Object? postData;

  const _FakeDioClient({this.getData, this.postData});

  @override
  Future<Response<dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: endpoint),
      statusCode: 200,
      data: getData,
    );
  }

  @override
  Future<Response<dynamic>> post(
    String endpoint,
    Object body, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return Response<dynamic>(
      requestOptions: RequestOptions(path: endpoint),
      statusCode: 201,
      data: postData,
    );
  }

  @override
  void setBearerToken(String token) {}
}
