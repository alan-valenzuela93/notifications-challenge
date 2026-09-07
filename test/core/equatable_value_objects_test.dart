import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/navigation/notification_link_failure.dart';
import 'package:notifications_challenge/core/navigation/order_link_destination.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/get_notifications_params.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/presentation/state/view_status.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notification_filter.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_state.dart';

void main() {
  test('notification states compare nested models by value', () {
    final NotificationsState first = NotificationsState(
      status: ViewStatus.success,
      notifications: <Notification>[_notification()],
      unreadCount: 1,
      hasMore: false,
      isLoadingMore: false,
      selectedFilter: NotificationFilter.all,
    );
    final NotificationsState second = NotificationsState(
      status: ViewStatus.success,
      notifications: <Notification>[_notification()],
      unreadCount: 1,
      hasMore: false,
      isLoadingMore: false,
      selectedFilter: NotificationFilter.all,
    );

    expect(first, second);
    expect(first.hashCode, second.hashCode);
  });

  test('request objects compare their collections by value', () {
    const CreateNotificationDto first = CreateNotificationDto(
      title: 'Título',
      body: 'Cuerpo',
      recipientIds: <String>['usr_1'],
      priority: PriorityEnum.high,
      data: <String, dynamic>{'orderId': '1234'},
    );
    const CreateNotificationDto second = CreateNotificationDto(
      title: 'Título',
      body: 'Cuerpo',
      recipientIds: <String>['usr_1'],
      priority: PriorityEnum.high,
      data: <String, dynamic>{'orderId': '1234'},
    );

    expect(first, second);
    expect(
      const GetNotificationsParams(limit: 4, offset: 0),
      const GetNotificationsParams(limit: 4, offset: 0),
    );
  });

  test('errors and deep-link results compare by value', () {
    const ApiError firstError = ApiError(
      message: 'No autorizado',
      type: ApiErrorType.badResponse,
      statusCode: 401,
    );
    const ApiError secondError = ApiError(
      message: 'No autorizado',
      type: ApiErrorType.badResponse,
      statusCode: 401,
    );
    final OrderLinkDestination firstDestination = OrderLinkDestination(
      uri: Uri.parse('app://orders/1234'),
      path: '/orders/1234',
      orderId: '1234',
    );
    final OrderLinkDestination secondDestination = OrderLinkDestination(
      uri: Uri.parse('app://orders/1234'),
      path: '/orders/1234',
      orderId: '1234',
    );

    expect(firstError, secondError);
    expect(
      const NotificationLinkFailure(NotificationLinkFailureType.malformed),
      const NotificationLinkFailure(NotificationLinkFailureType.malformed),
    );
    expect(firstDestination, secondDestination);
  });
}

Notification _notification() {
  return Notification(
    id: 'notification-1',
    groupId: 'group-1',
    title: 'Título',
    body: 'Cuerpo',
    recipientId: 'usr_1',
    priority: PriorityEnum.high,
    status: NotificationStatus.unread,
    notificationAdditionalData: <String, dynamic>{'orderId': '1234'},
    createdAt: DateTime.utc(2026, 9, 6, 12),
  );
}
