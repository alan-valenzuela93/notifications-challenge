import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/usecases/create_notifications.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_responsive_container.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/create_notification_cubit.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/create_notification_state.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/create_notification_form.dart';

class CreateNotificationPage extends StatefulWidget {
  final CreateNotificationCubit? cubit;
  final VoidCallback? onCreated;

  const CreateNotificationPage({super.key, this.cubit, this.onCreated});

  @override
  State<CreateNotificationPage> createState() => _CreateNotificationPageState();
}

class _CreateNotificationPageState extends State<CreateNotificationPage> {
  late final CreateNotificationCubit _cubit;
  late final bool _ownsCubit;

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? CreateNotificationCubit(CreateNotification());
  }

  @override
  void dispose() {
    if (_ownsCubit) {
      unawaited(_cubit.close());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CreateNotificationState>(
      stream: _cubit.stream,
      initialData: _cubit.state,
      builder:
          (
            BuildContext context,
            AsyncSnapshot<CreateNotificationState> snapshot,
          ) {
            final CreateNotificationState state = snapshot.requireData;
            return Scaffold(
              appBar: AppBar(title: const AppText('Crear notificación')),
              body: SafeArea(
                child: AppResponsiveContainer(
                  maxWidth: 720,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(
                      AppResponsive.horizontalPadding(context),
                    ),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: CreateNotificationForm(
                      isSubmitting: state.isSubmitting,
                      errorMessage: state.errorMessage,
                      onSubmit: _submit,
                    ),
                  ),
                ),
              ),
            );
          },
    );
  }

  Future<void> _submit(CreateNotificationDto notification) async {
    final bool created = await _cubit.create(notification);
    if (!mounted || !created) {
      return;
    }

    if (widget.onCreated != null) {
      widget.onCreated!();
      return;
    }
    Navigator.of(context).pop(true);
  }
}
