import 'package:equatable/equatable.dart';
import 'package:notifications_challenge/core/extensions/extensions.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';

class GetNotificationsParams extends Equatable {
  final String? recipientId;
  final NotificationStatus? status;
  final PriorityEnum? priority;
  final bool? includeScheduled;
  final int? limit;
  final int? offset;

  const GetNotificationsParams({
    this.recipientId,
    this.status,
    this.priority,
    this.includeScheduled,
    this.limit,
    this.offset,
  });

  Map<String, dynamic> toQueryParameters() => {
    'recipientId': recipientId,
    'status': status?.name,
    'priority': priority?.name,
    'includeScheduled': includeScheduled,
    'limit': limit,
    'offset': offset,
  }.cleanNulls;

  @override
  List<Object?> get props => [
    recipientId,
    status,
    priority,
    includeScheduled,
    limit,
    offset,
  ];
}
