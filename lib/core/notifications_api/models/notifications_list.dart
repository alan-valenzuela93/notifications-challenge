import 'package:equatable/equatable.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/pagination_meta.dart';

class NotificationsList extends Equatable {
  final List<Notification> notifications;
  final PaginationMeta meta;

  const NotificationsList({required this.notifications, required this.meta});

  factory NotificationsList.fromMap(Map<String, dynamic> map) {
    final List<dynamic> data = map['data'] as List<dynamic>;

    return NotificationsList(
      notifications: data
          .map(
            (dynamic item) =>
                Notification.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
      meta: PaginationMeta.fromMap(map['meta'] as Map<String, dynamic>),
    );
  }

  @override
  List<Object?> get props => <Object?>[notifications, meta];
}
