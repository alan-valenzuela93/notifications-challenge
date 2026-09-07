import 'package:either_dart/either.dart';
import 'package:notifications_challenge/core/notifications_api/_notifications_api.dart';

class FakeNotificationsService extends NotificationsService {
  final NotificationsList listResult;
  final List<Notification> createResult;
  GetNotificationsParams? receivedGetParams;
  CreateNotificationDto? receivedCreateDto;

  FakeNotificationsService({
    required this.listResult,
    required this.createResult,
  });

  @override
  Future<Either<ApiError, NotificationsList>> getNotifications(
    GetNotificationsParams params,
  ) async {
    receivedGetParams = params;
    return Right<ApiError, NotificationsList>(listResult);
  }

  @override
  Future<Either<ApiError, List<Notification>>> createNotification(
    CreateNotificationDto notification,
  ) async {
    receivedCreateDto = notification;
    return Right<ApiError, List<Notification>>(createResult);
  }
}
