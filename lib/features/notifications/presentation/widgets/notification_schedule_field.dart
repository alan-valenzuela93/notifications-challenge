import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text_form_field.dart';

typedef _ScheduleSelection = ({bool enabled, DateTime? scheduledAt});

class NotificationScheduleField extends StatefulWidget {
  final bool enabled;
  final ValueChanged<DateTime?> onChanged;

  const NotificationScheduleField({
    required this.enabled,
    required this.onChanged,
    super.key,
  });

  @override
  State<NotificationScheduleField> createState() =>
      _NotificationScheduleFieldState();
}

class _NotificationScheduleFieldState extends State<NotificationScheduleField> {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy · HH:mm');

  final GlobalKey<FormFieldState<String>> _fieldKey =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<_ScheduleSelection> _selection =
      ValueNotifier<_ScheduleSelection>((enabled: false, scheduledAt: null));

  @override
  void dispose() {
    _controller.dispose();
    _selection.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double spacing = AppResponsive.spacing(context, 16);

    return ValueListenableBuilder<_ScheduleSelection>(
      valueListenable: _selection,
      builder:
          (BuildContext context, _ScheduleSelection selection, Widget? child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  margin: EdgeInsets.zero,
                  clipBehavior: Clip.antiAlias,
                  child: SwitchListTile(
                    key: const Key('create-notification-schedule'),
                    value: selection.enabled,
                    onChanged: widget.enabled ? _toggleSchedule : null,
                    secondary: const Icon(Icons.schedule_outlined),
                    title: const AppText('Programar envío'),
                    subtitle: const AppText('Elegí una fecha y hora futura'),
                  ),
                ),
                if (selection.enabled) ...[
                  SizedBox(height: spacing),
                  AppTextFormField(
                    key: const Key('create-notification-scheduled-at'),
                    formFieldKey: _fieldKey,
                    controller: _controller,
                    labelText: 'Fecha de programación',
                    hintText: 'Seleccionar fecha y hora',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: selection.scheduledAt == null
                        ? const Icon(Icons.arrow_drop_down)
                        : IconButton(
                            tooltip: 'Quitar fecha programada',
                            onPressed: widget.enabled
                                ? _clearScheduledAt
                                : null,
                            icon: const Icon(Icons.clear),
                          ),
                    readOnly: true,
                    enabled: widget.enabled,
                    validator: _validateScheduledAt,
                    onTap: () => unawaited(_selectScheduledAt()),
                  ),
                ],
              ],
            );
          },
    );
  }

  String? _validateScheduledAt(String? _) {
    final _ScheduleSelection selection = _selection.value;
    if (!selection.enabled) {
      return null;
    }
    if (selection.scheduledAt == null) {
      return 'Seleccioná una fecha y hora.';
    }
    if (!selection.scheduledAt!.isAfter(DateTime.now())) {
      return 'La fecha de programación debe ser futura.';
    }
    return null;
  }

  void _toggleSchedule(bool enabled) {
    _selection.value = (enabled: enabled, scheduledAt: null);

    if (!enabled) {
      _controller.clear();
      widget.onChanged(null);
      return;
    }
    unawaited(_selectScheduledAt());
  }

  void _clearScheduledAt() {
    _controller.clear();
    _selection.value = (enabled: true, scheduledAt: null);
    widget.onChanged(null);
  }

  Future<void> _selectScheduledAt() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate =
        _selection.value.scheduledAt ?? now.add(const Duration(hours: 1));
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 5, 12, 31),
      helpText: 'Seleccionar fecha de programación',
    );

    if (!mounted || selectedDate == null) {
      return;
    }

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      helpText: 'Seleccionar hora de programación',
    );

    if (!mounted || selectedTime == null) {
      return;
    }

    final DateTime scheduledAt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    _controller.text = _dateFormat.format(scheduledAt.toLocal());
    _selection.value = (enabled: true, scheduledAt: scheduledAt);
    widget.onChanged(scheduledAt);
    _fieldKey.currentState?.validate();
  }
}
