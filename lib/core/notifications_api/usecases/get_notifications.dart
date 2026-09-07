import 'package:either_dart/either.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/get_notifications_params.dart';
import 'package:notifications_challenge/core/notifications_api/models/notifications_list.dart';
import 'package:notifications_challenge/core/notifications_api/services/notifications_service.dart';

class GetNotifications {
  final NotificationsService _notificationsService;

  GetNotifications({NotificationsService? notificationsService})
    : _notificationsService = notificationsService ?? NotificationsService();

  Future<Either<ApiError, NotificationsList>> call([
    GetNotificationsParams params = const GetNotificationsParams(),
  ]) async {
    return await _notificationsService.getNotifications(params);
  }
}
