import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class NotificationBodyCard extends StatelessWidget {
  final String body;

  const NotificationBodyCard({required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: EdgeInsets.all(AppResponsive.spacing(context, 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText('Mensaje', style: theme.textTheme.titleMedium),
            SizedBox(height: AppResponsive.spacing(context, 12)),
            AppText(body, style: theme.textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
