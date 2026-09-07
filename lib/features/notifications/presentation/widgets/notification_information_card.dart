import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_info_item.dart';

class NotificationInformationCard extends StatelessWidget {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy · HH:mm');

  final api.Notification notification;

  const NotificationInformationCard({required this.notification, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppResponsive.spacing(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Información', style: theme.textTheme.titleMedium),
            const Divider(),
            NotificationInfoItem(
              icon: Icons.calendar_today_outlined,
              label: 'Fecha de creación',
              value: _dateFormat.format(notification.createdAt.toLocal()),
            ),
            NotificationInfoItem(
              icon: Icons.person_outline,
              label: 'Destinatario',
              value: notification.recipientId,
            ),
            if (notification.scheduledAt != null)
              NotificationInfoItem(
                icon: Icons.schedule,
                label: 'Programada para',
                value: _dateFormat.format(notification.scheduledAt!.toLocal()),
              ),
          ],
        ),
      ),
    );
  }
}
