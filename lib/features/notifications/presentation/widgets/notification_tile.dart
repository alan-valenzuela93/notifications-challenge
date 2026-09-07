import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_priority_chip.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_status_chip.dart';

class NotificationTile extends StatelessWidget {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy · HH:mm');

  final api.Notification notification;
  final VoidCallback? onTap;

  const NotificationTile({required this.notification, super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isUnread = notification.status == api.NotificationStatus.unread;

    return Card(
      color: theme.colorScheme.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppResponsive.spacing(context, 12)),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(AppResponsive.spacing(context, 16)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: AppResponsive.spacing(context, 8),
                  ),
                  child: Icon(
                    isUnread ? Icons.circle : Icons.circle_outlined,
                    size: AppResponsive.iconSize(context, 10),
                    color: isUnread
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                  ),
                ),
                SizedBox(width: AppResponsive.spacing(context, 12)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppResponsive.spacing(context, 4)),
                      AppText(
                        notification.body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(height: AppResponsive.spacing(context, 12)),
                      Wrap(
                        spacing: AppResponsive.spacing(context, 8),
                        runSpacing: AppResponsive.spacing(context, 8),
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          NotificationPriorityChip(
                            priority: notification.priority,
                          ),
                          NotificationStatusChip(status: notification.status),
                          AppText(
                            _formattedDate,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onTap != null) ...[
                  SizedBox(width: AppResponsive.spacing(context, 8)),
                  Padding(
                    padding: EdgeInsets.only(
                      top: AppResponsive.spacing(context, 4),
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      size: AppResponsive.iconSize(context, 22),
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String get _formattedDate {
    return _dateFormat.format(notification.createdAt.toLocal());
  }
}
