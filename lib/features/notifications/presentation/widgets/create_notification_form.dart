import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_loading_view.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text_form_field.dart';
import 'package:notifications_challenge/features/notifications/presentation/validation/create_notification_form_validators.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/additional_data_fields.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_priority_field.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_schedule_field.dart';

class CreateNotificationForm extends StatefulWidget {
  final bool isSubmitting;
  final String? errorMessage;
  final Future<void> Function(CreateNotificationDto notification) onSubmit;

  const CreateNotificationForm({
    required this.isSubmitting,
    required this.onSubmit,
    super.key,
    this.errorMessage,
  });

  @override
  State<CreateNotificationForm> createState() => _CreateNotificationFormState();
}

class _CreateNotificationFormState extends State<CreateNotificationForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  PriorityEnum _priority = PriorityEnum.normal;
  DateTime? _scheduledAt;
  Map<String, dynamic>? _additionalData;

  @override
  void dispose() {
    _recipientController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double spacing = AppResponsive.spacing(context, 16);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppText(
            'Completá los datos para enviar una nueva notificación in-app.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: spacing),
          AppTextFormField(
            key: const Key('create-notification-recipient'),
            controller: _recipientController,
            labelText: 'Destinatario',
            hintText: 'usr_9a1f2c',
            helperText: 'Identificador del usuario destinatario',
            prefixIcon: const Icon(Icons.person_outline),
            textInputAction: TextInputAction.next,
            enabled: !widget.isSubmitting,
            validator: CreateNotificationFormValidators.recipientId,
          ),
          SizedBox(height: spacing),
          AppTextFormField(
            key: const Key('create-notification-title'),
            controller: _titleController,
            labelText: 'Título',
            hintText: 'Tu pedido fue enviado',
            prefixIcon: const Icon(Icons.title),
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            maxLength: CreateNotificationFormValidators.titleMaxLength,
            enabled: !widget.isSubmitting,
            validator: CreateNotificationFormValidators.title,
          ),
          SizedBox(height: spacing),
          AppTextFormField(
            key: const Key('create-notification-body'),
            controller: _bodyController,
            labelText: 'Cuerpo',
            hintText: 'Escribí el mensaje de la notificación',
            prefixIcon: const Icon(Icons.notes),
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            textCapitalization: TextCapitalization.sentences,
            minLines: 3,
            maxLines: 6,
            maxLength: CreateNotificationFormValidators.bodyMaxLength,
            enabled: !widget.isSubmitting,
            validator: CreateNotificationFormValidators.body,
          ),
          SizedBox(height: spacing),
          NotificationPriorityField(
            key: const Key('create-notification-priority'),
            value: _priority,
            enabled: !widget.isSubmitting,
            onChanged: (PriorityEnum priority) {
              _priority = priority;
            },
          ),
          SizedBox(height: spacing),
          NotificationScheduleField(
            enabled: !widget.isSubmitting,
            onChanged: (DateTime? scheduledAt) {
              _scheduledAt = scheduledAt;
            },
          ),
          SizedBox(height: spacing),
          AdditionalDataFields(
            enabled: !widget.isSubmitting,
            onChanged: (Map<String, dynamic>? data) {
              _additionalData = data;
            },
          ),
          if (widget.errorMessage != null) ...[
            SizedBox(height: spacing),
            Semantics(
              liveRegion: true,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(AppResponsive.spacing(context, 12)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      SizedBox(width: AppResponsive.spacing(context, 12)),
                      Expanded(
                        child: AppText(
                          widget.errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          SizedBox(height: AppResponsive.spacing(context, 24)),
          FilledButton.icon(
            key: const Key('create-notification-submit'),
            onPressed: widget.isSubmitting ? null : () => unawaited(_submit()),
            icon: widget.isSubmitting
                ? SizedBox.square(
                    dimension: AppResponsive.iconSize(context, 18),
                    child: const AppLoadingView(),
                  )
                : const Icon(Icons.send_outlined),
            label: AppText(
              widget.isSubmitting
                  ? 'Creando notificación...'
                  : 'Crear notificación',
            ),
          ),
          SizedBox(height: spacing),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    await widget.onSubmit(
      CreateNotificationDto(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
        recipientIds: <String>[_recipientController.text.trim()],
        priority: _priority,
        scheduledAt: _scheduledAt,
        data: _additionalData == null
            ? null
            : Map<String, dynamic>.unmodifiable(_additionalData!),
      ),
    );
  }
}
