import 'package:equatable/equatable.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/presentation/state/view_status.dart';

class CreateNotificationState extends Equatable {
  final ViewStatus status;
  final List<Notification> createdNotifications;
  final String? errorMessage;

  const CreateNotificationState({
    required this.status,
    required this.createdNotifications,
    this.errorMessage,
  });

  const CreateNotificationState.initial()
    : status = ViewStatus.initial,
      createdNotifications = const [],
      errorMessage = null;

  bool get isSubmitting => status == ViewStatus.loading;

  @override
  List<Object?> get props => <Object?>[
    status,
    createdNotifications,
    errorMessage,
  ];
}
