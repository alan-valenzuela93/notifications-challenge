import 'package:equatable/equatable.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';

enum NotificationStatus { scheduled, unread, read }

class Notification extends Equatable {
  final String id;
  final String groupId;
  final String title;
  final String body;
  final String recipientId;
  final PriorityEnum priority;
  final NotificationStatus status;
  final DateTime? scheduledAt;
  final DateTime? readAt;
  final Map<String, dynamic>? notificationAdditionalData;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.groupId,
    required this.title,
    required this.body,
    required this.recipientId,
    required this.priority,
    required this.status,
    required this.createdAt,
    this.scheduledAt,
    this.readAt,
    this.notificationAdditionalData,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      id: map['id'] as String,
      groupId: map['groupId'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      recipientId: map['recipientId'] as String,
      priority: PriorityEnum.values.byName(map['priority'] as String),
      status: NotificationStatus.values.byName(map['status'] as String),
      scheduledAt: DateTime.tryParse(map['scheduledAt'] as String? ?? ''),
      readAt: DateTime.tryParse(map['readAt'] as String? ?? ''),
      notificationAdditionalData: map['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'body': body,
      'recipientId': recipientId,
      'priority': priority.name,
      'status': status.name,
      'scheduledAt': scheduledAt?.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'data': notificationAdditionalData,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => <Object?>[
    id,
    groupId,
    title,
    body,
    recipientId,
    priority,
    status,
    scheduledAt,
    readAt,
    notificationAdditionalData,
    createdAt,
  ];
}
