import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/get_notifications_params.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notifications_list.dart';
import 'package:notifications_challenge/core/notifications_api/models/pagination_meta.dart';
import 'package:notifications_challenge/core/notifications_api/usecases/create_notifications.dart';
import 'package:notifications_challenge/core/notifications_api/usecases/get_notifications.dart';

import 'fake_notification_service.dart';

void main() {
  group('GetNotificationsParams', () {
    test('serializes only supplied filters using API enum values', () {
      const GetNotificationsParams params = GetNotificationsParams(
        recipientId: 'user-1',
        status: NotificationStatus.unread,
        priority: PriorityEnum.high,
        includeScheduled: false,
        limit: 10,
        offset: 20,
      );

      expect(params.toQueryParameters(), <String, dynamic>{
        'recipientId': 'user-1',
        'status': 'unread',
        'priority': 'high',
        'includeScheduled': false,
        'limit': 10,
        'offset': 20,
      });
      expect(const GetNotificationsParams().toQueryParameters(), isEmpty);
    });
  });

  test('NotificationsList maps API data and pagination metadata', () {
    final NotificationsList result = NotificationsList.fromMap(
      <String, dynamic>{
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'id': 'notification-1',
            'groupId': 'group-1',
            'title': 'Title',
            'body': 'Body',
            'recipientId': 'user-1',
            'priority': 'normal',
            'status': 'unread',
            'scheduledAt': null,
            'readAt': null,
            'data': <String, dynamic>{'route': '/inbox'},
            'createdAt': '2026-09-05T12:00:00.000Z',
          },
        ],
        'meta': <String, dynamic>{
          'total': 21,
          'limit': 20,
          'offset': 0,
          'hasMore': true,
          'unreadCount': 3,
        },
      },
    );

    expect(result.notifications, hasLength(1));
    expect(result.notifications.single.status, NotificationStatus.unread);
    expect(
      result.notifications.single.notificationAdditionalData,
      <String, dynamic>{'route': '/inbox'},
    );
    expect(result.meta.unreadCount, 3);
    expect(result.meta.hasMore, isTrue);
  });

  test('CreateNotificationDto uses the API payload keys and values', () {
    final CreateNotificationDto dto = CreateNotificationDto(
      title: 'Title',
      body: 'Body',
      recipientIds: <String>['user-1'],
      priority: PriorityEnum.normal,
      scheduledAt: DateTime.utc(2026, 9, 6, 12),
      data: <String, dynamic>{'orderId': '1234'},
    );

    expect(dto.toJson(), <String, dynamic>{
      'title': 'Title',
      'body': 'Body',
      'recipientIds': <String>['user-1'],
      'priority': 'normal',
      'scheduledAt': '2026-09-06T12:00:00.000Z',
      'data': <String, dynamic>{'orderId': '1234'},
    });
  });

  test('CreateNotificationDto serializes scheduledAt in UTC', () {
    final DateTime localScheduledAt = DateTime(2026, 9, 6, 18, 30);
    final CreateNotificationDto dto = CreateNotificationDto(
      title: 'Title',
      body: 'Body',
      recipientIds: <String>['user-1'],
      priority: PriorityEnum.normal,
      scheduledAt: localScheduledAt,
    );

    expect(
      dto.toJson()['scheduledAt'],
      localScheduledAt.toUtc().toIso8601String(),
    );
  });

  test('ApiError maps status, message and details from DioException', () {
    final RequestOptions requestOptions = RequestOptions(
      path: '/notifications',
    );
    final Map<String, dynamic> responseData = <String, dynamic>{
      'statusCode': 401,
      'message': 'Token bearer inválido o ausente',
      'error': 'Unauthorized',
    };
    final DioException exception = DioException(
      requestOptions: requestOptions,
      response: Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: 401,
        data: responseData,
      ),
      type: DioExceptionType.badResponse,
    );

    final ApiError error = ApiError.fromDioException(exception);

    expect(error.type, ApiErrorType.badResponse);
    expect(error.statusCode, 401);
    expect(error.message, 'Token bearer inválido o ausente');
    expect(error.details, same(responseData));
    expect(error.isUnauthorized, isTrue);
  });

  test(
    'use cases delegate typed input and return the service result',
    () async {
      final Notification notification = Notification(
        id: 'notification-1',
        groupId: 'group-1',
        title: 'Title',
        body: 'Body',
        recipientId: 'user-1',
        priority: PriorityEnum.high,
        status: NotificationStatus.unread,
        createdAt: DateTime.utc(2026, 9, 6, 12),
      );
      final NotificationsList listResult = NotificationsList(
        notifications: <Notification>[notification],
        meta: const PaginationMeta(
          total: 1,
          limit: 20,
          offset: 0,
          hasMore: false,
          unreadCount: 1,
        ),
      );
      final FakeNotificationsService service = FakeNotificationsService(
        listResult: listResult,
        createResult: <Notification>[notification],
      );
      final GetNotificationsParams getParams = const GetNotificationsParams(
        recipientId: 'user-1',
      );
      final CreateNotificationDto createDto = CreateNotificationDto(
        title: 'Title',
        body: 'Body',
        recipientIds: <String>['user-1'],
        priority: PriorityEnum.high,
      );

      final Either<ApiError, NotificationsList> getResult =
          await GetNotifications(notificationsService: service)(getParams);

      expect(getResult.isRight, isTrue);
      expect(getResult.right, same(listResult));
      expect(service.receivedGetParams, same(getParams));

      final Either<ApiError, List<Notification>> createResult =
          await CreateNotification(notificationsService: service)(createDto);

      expect(createResult.isRight, isTrue);
      expect(createResult.right, <Notification>[notification]);
      expect(service.receivedCreateDto, same(createDto));
    },
  );
}
