import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class NotificationInfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const NotificationInfoItem({
    required this.icon,
    required this.label,
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon),
      title: AppText(label, style: theme.textTheme.labelLarge),
      subtitle: AppText(value, style: theme.textTheme.bodyLarge),
      contentPadding: EdgeInsets.zero,
    );
  }
}
