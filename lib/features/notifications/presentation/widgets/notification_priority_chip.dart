import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class NotificationPriorityChip extends StatelessWidget {
  final PriorityEnum priority;

  const NotificationPriorityChip({required this.priority, super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(
        _icon,
        size: AppResponsive.iconSize(context, 16),
        color: _color(theme),
      ),
      label: AppText(_label),
    );
  }

  String get _label {
    return switch (priority) {
      PriorityEnum.high => 'Alta',
      PriorityEnum.normal => 'Normal',
      PriorityEnum.low => 'Baja',
    };
  }

  IconData get _icon {
    return switch (priority) {
      PriorityEnum.high => Icons.keyboard_double_arrow_up,
      PriorityEnum.normal => Icons.remove,
      PriorityEnum.low => Icons.keyboard_arrow_down,
    };
  }

  Color _color(ThemeData theme) {
    return switch (priority) {
      PriorityEnum.high => theme.colorScheme.error,
      PriorityEnum.normal => theme.colorScheme.tertiary,
      PriorityEnum.low => theme.colorScheme.secondary,
    };
  }
}
