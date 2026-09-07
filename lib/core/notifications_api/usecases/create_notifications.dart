import 'package:either_dart/either.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/notifications_api/services/notifications_service.dart';

class CreateNotification {
  final NotificationsService _notificationsService;

  CreateNotification({NotificationsService? notificationsService})
    : _notificationsService = notificationsService ?? NotificationsService();

  Future<Either<ApiError, List<Notification>>> call(
    CreateNotificationDto notification,
  ) async {
    return await _notificationsService.createNotification(notification);
  }
}
