import 'package:equatable/equatable.dart';

enum PriorityEnum { low, normal, high }

class CreateNotificationDto extends Equatable {
  final String title;
  final String body;
  final List<String> recipientIds;
  final PriorityEnum priority;
  final DateTime? scheduledAt;
  final Map<String, dynamic>? data;

  const CreateNotificationDto({
    required this.title,
    required this.body,
    required this.recipientIds,
    required this.priority,
    this.scheduledAt,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'recipientIds': recipientIds,
      'priority': priority.name,
      'scheduledAt': scheduledAt?.toUtc().toIso8601String(),
      'data': data,
    };
  }

  @override
  List<Object?> get props => <Object?>[
    title,
    body,
    recipientIds,
    priority,
    scheduledAt,
    data,
  ];
}
