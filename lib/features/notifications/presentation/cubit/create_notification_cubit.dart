import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/notifications_api/usecases/create_notifications.dart';
import 'package:notifications_challenge/core/presentation/state/view_status.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/create_notification_state.dart';

class CreateNotificationCubit extends Cubit<CreateNotificationState> {
  final CreateNotification _createNotification;

  CreateNotificationCubit(this._createNotification)
    : super(const CreateNotificationState.initial());

  Future<bool> create(CreateNotificationDto notification) async {
    if (state.isSubmitting) {
      return false;
    }

    emit(
      const CreateNotificationState(
        status: ViewStatus.loading,
        createdNotifications: <Notification>[],
      ),
    );

    final Either<ApiError, List<Notification>> result =
        await _createNotification(notification);

    if (isClosed) {
      return false;
    }

    return result.fold(
      (ApiError error) {
        emit(
          CreateNotificationState(
            status: ViewStatus.error,
            createdNotifications: const <Notification>[],
            errorMessage: error.message,
          ),
        );
        return false;
      },
      (List<Notification> notifications) {
        emit(
          CreateNotificationState(
            status: ViewStatus.success,
            createdNotifications: List<Notification>.unmodifiable(
              notifications,
            ),
          ),
        );
        return true;
      },
    );
  }
}
