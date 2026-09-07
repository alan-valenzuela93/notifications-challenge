import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';

class NotificationPriorityField extends StatelessWidget {
  final PriorityEnum value;
  final ValueChanged<PriorityEnum> onChanged;
  final bool enabled;

  const NotificationPriorityField({
    required this.value,
    required this.onChanged,
    super.key,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<PriorityEnum>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Prioridad',
        prefixIcon: Icon(Icons.flag_outlined),
        border: OutlineInputBorder(),
      ),
      items: PriorityEnum.values.map((PriorityEnum priority) {
        return DropdownMenuItem<PriorityEnum>(
          value: priority,
          child: AppText(_label(priority)),
        );
      }).toList(),
      onChanged: enabled
          ? (PriorityEnum? priority) {
              if (priority != null) {
                onChanged(priority);
              }
            }
          : null,
    );
  }

  String _label(PriorityEnum priority) {
    return switch (priority) {
      PriorityEnum.low => 'Baja',
      PriorityEnum.normal => 'Normal',
      PriorityEnum.high => 'Alta',
    };
  }
}
