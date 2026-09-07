import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/presentation/state/view_status.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_empty_view.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_error_view.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_loading_view.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notification_filter.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_inbox_list.dart';

class NotificationsContent extends StatelessWidget {
  final NotificationsState state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<api.Notification>? onNotificationTap;

  const NotificationsContent({
    super.key,
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.onRetry,
    required this.onLoadMore,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state.status) {
      ViewStatus.initial || ViewStatus.loading => const AppLoadingView(),
      ViewStatus.empty => AppEmptyView(
        icon: Icons.notifications_none,
        message: state.selectedFilter == NotificationFilter.all
            ? 'No hay notificaciones.'
            : 'No hay notificaciones para este filtro.',
      ),
      ViewStatus.error => AppErrorView(
        message: state.errorMessage,
        onRetry: onRetry,
      ),
      ViewStatus.success => NotificationInboxList(
        state: state,
        scrollController: scrollController,
        onRefresh: onRefresh,
        onLoadMore: onLoadMore,
        onNotificationTap: onNotificationTap,
      ),
    };
  }
}
