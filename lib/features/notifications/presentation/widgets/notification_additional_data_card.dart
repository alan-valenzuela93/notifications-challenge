import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_data_entry.dart';

class NotificationAdditionalDataCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const NotificationAdditionalDataCard({required this.data, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<MapEntry<String, dynamic>> entries = data.entries.toList();

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppResponsive.spacing(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Datos adicionales', style: theme.textTheme.titleMedium),
            const Divider(),
            for (int index = 0; index < entries.length; index++) ...[
              NotificationDataEntry(
                label: entries[index].key,
                value: entries[index].value,
              ),
              if (index < entries.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}
