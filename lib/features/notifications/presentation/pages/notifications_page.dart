import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/notifications_api/usecases/get_notifications.dart';
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_responsive_container.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_text.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notification_filter.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:notifications_challenge/features/notifications/presentation/pages/create_notification_page.dart';
import 'package:notifications_challenge/features/notifications/presentation/pages/notification_detail_page.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_filters.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notifications_content.dart';

class NotificationsPage extends StatefulWidget {
  final NotificationsCubit? cubit;
  final bool loadOnStart;
  final ValueChanged<api.Notification>? onNotificationTap;
  final VoidCallback? onCreateTap;

  const NotificationsPage({
    super.key,
    this.cubit,
    this.loadOnStart = true,
    this.onNotificationTap,
    this.onCreateTap,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late final NotificationsCubit _cubit;
  late final bool _ownsCubit;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ownsCubit = widget.cubit == null;
    _cubit = widget.cubit ?? NotificationsCubit(GetNotifications());
    _scrollController.addListener(_onScroll);

    if (widget.loadOnStart) {
      unawaited(_cubit.loadInitial());
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    if (_ownsCubit) {
      unawaited(_cubit.close());
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final ScrollPosition position = _scrollController.position;
    if (!position.hasContentDimensions ||
        position.userScrollDirection != ScrollDirection.reverse) {
      return;
    }

    const double loadMoreThreshold = 240;
    if (position.extentAfter < loadMoreThreshold) {
      unawaited(_cubit.loadMore());
    }
  }

  void _openNotificationDetail(api.Notification notification) {
    if (widget.onNotificationTap != null) {
      widget.onNotificationTap!(notification);
      return;
    }

    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: '/notifications/detail'),
          builder: (BuildContext context) {
            return NotificationDetailPage(notification: notification);
          },
        ),
      ),
    );
  }

  void _handleCreateTap() {
    if (widget.onCreateTap != null) {
      widget.onCreateTap!();
      return;
    }
    unawaited(_openCreateNotification());
  }

  void _selectFilter(NotificationFilter filter) {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
    unawaited(_cubit.selectFilter(filter));
  }

  Future<void> _openCreateNotification() async {
    final bool? created = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        settings: const RouteSettings(name: '/notifications/create'),
        builder: (BuildContext context) {
          return const CreateNotificationPage();
        },
      ),
    );

    if (!mounted || created != true) {
      return;
    }

    await _cubit.refresh();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: AppText('La notificación fue creada correctamente.'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<NotificationsState>(
      stream: _cubit.stream,
      initialData: _cubit.state,
      builder:
          (BuildContext context, AsyncSnapshot<NotificationsState> snapshot) {
            final NotificationsState state = snapshot.requireData;

            return Scaffold(
              appBar: AppBar(
                title: const AppText(
                  'Notificaciones',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                actions: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppResponsive.horizontalPadding(context),
                    ),
                    child: Center(
                      child: Badge(
                        isLabelVisible: state.unreadCount > 0,
                        label: AppText(state.unreadCount.toString()),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                    ),
                  ),
                ],
              ),
              body: SafeArea(
                child: AppResponsiveContainer(
                  child: Column(
                    children: [
                      NotificationFilters(
                        selectedFilter: state.selectedFilter,
                        onSelected: _selectFilter,
                      ),
                      Expanded(
                        child: NotificationsContent(
                          state: state,
                          scrollController: _scrollController,
                          onRefresh: _cubit.refresh,
                          onRetry: () => unawaited(_cubit.retry()),
                          onLoadMore: () => unawaited(_cubit.loadMore()),
                          onNotificationTap: _openNotificationDetail,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: _handleCreateTap,
                tooltip: 'Crear notificación',
                child: const Icon(Icons.add),
              ),
            );
          },
    );
  }
}
