import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/navigation/notification_link_coordinator.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_responsive_container.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_additional_data_card.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_body_card.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_deep_link_card.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_information_card.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_priority_chip.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_status_chip.dart';

class NotificationDetailPage extends StatelessWidget {
  final api.Notification notification;
  final NotificationLinkCoordinator notificationLinkCoordinator;

  const NotificationDetailPage({
    required this.notification,
    super.key,
    this.notificationLinkCoordinator = const NotificationLinkCoordinator(),
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double spacing = AppResponsive.spacing(context, 16);
    final Map<String, dynamic> additionalData = _additionalData;
    final String? deepLink = _deepLink;

    return Scaffold(
      appBar: AppBar(
        title: const AppText(
          'Detalle de notificación',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(
        child: AppResponsiveContainer(
          maxWidth: 720,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppResponsive.horizontalPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  notification.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppResponsive.spacing(context, 12)),
                Wrap(
                  spacing: AppResponsive.spacing(context, 8),
                  runSpacing: AppResponsive.spacing(context, 8),
                  children: [
                    NotificationPriorityChip(priority: notification.priority),
                    NotificationStatusChip(status: notification.status),
                  ],
                ),
                SizedBox(height: spacing),
                NotificationBodyCard(body: notification.body),
                SizedBox(height: spacing),
                NotificationInformationCard(notification: notification),
                if (additionalData.isNotEmpty) ...[
                  SizedBox(height: spacing),
                  NotificationAdditionalDataCard(data: additionalData),
                ],
                if (deepLink != null) ...[
                  SizedBox(height: spacing),
                  NotificationDeepLinkCard(
                    deepLink: deepLink,
                    onProcess: () => _processDeepLink(context, deepLink),
                  ),
                ],
                SizedBox(height: AppResponsive.spacing(context, 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _processDeepLink(BuildContext context, String deepLink) {
    notificationLinkCoordinator.open(
      context,
      deepLink,
      onUnavailableDestination: () {
        _showMessage(context, 'El destino $deepLink fue reconocido');
      },
      onInvalidLink: () {
        _showMessage(context, 'El deep link no es válido.');
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: AppText(message)));
  }

  String? get _deepLink {
    final Object? value = notification.notificationAdditionalData?['deepLink'];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  Map<String, dynamic> get _additionalData {
    final Map<String, dynamic>? data = notification.notificationAdditionalData;
    if (data == null || data.isEmpty) {
      return const <String, dynamic>{};
    }

    return Map<String, dynamic>.fromEntries(
      data.entries.where(
        (MapEntry<String, dynamic> entry) => entry.key != 'deepLink',
      ),
    );
  }
}
