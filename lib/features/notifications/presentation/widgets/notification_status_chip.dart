import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class NotificationStatusChip extends StatelessWidget {
  final NotificationStatus status;

  const NotificationStatusChip({required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(_icon, size: 16),
      label: AppText(_label),
    );
  }

  String get _label {
    return switch (status) {
      NotificationStatus.unread => 'No leída',
      NotificationStatus.read => 'Leída',
      NotificationStatus.scheduled => 'Programada',
    };
  }

  IconData get _icon {
    return switch (status) {
      NotificationStatus.unread => Icons.mark_email_unread_outlined,
      NotificationStatus.read => Icons.drafts_outlined,
      NotificationStatus.scheduled => Icons.schedule,
    };
  }
}
