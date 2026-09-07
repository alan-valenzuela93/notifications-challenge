import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/presentation/responsive/app_responsive.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_list_footer.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_tile.dart';

class NotificationInboxList extends StatelessWidget {
  final NotificationsState state;
  final ScrollController scrollController;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final ValueChanged<api.Notification>? onNotificationTap;

  const NotificationInboxList({
    required this.state,
    required this.scrollController,
    required this.onRefresh,
    required this.onLoadMore,
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final double horizontalPadding = AppResponsive.horizontalPadding(context);
    final double bottomPadding = AppResponsive.spacing(context, 96);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        key: const PageStorageKey<String>('notifications-list'),
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppResponsive.spacing(context, 4),
              horizontalPadding,
              0,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((
                BuildContext context,
                int index,
              ) {
                final api.Notification notification =
                    state.notifications[index];
                return NotificationTile(
                  notification: notification,
                  onTap: onNotificationTap == null
                      ? null
                      : () => onNotificationTap!(notification),
                );
              }, childCount: state.notifications.length),
            ),
          ),
          if (state.isLoadingMore || state.loadMoreError != null)
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                bottomPadding,
              ),
              sliver: SliverToBoxAdapter(
                child: NotificationListFooter(
                  isLoading: state.isLoadingMore,
                  errorMessage: state.loadMoreError,
                  onLoadMore: onLoadMore,
                ),
              ),
            )
          else if (state.hasMore)
            SliverLayoutBuilder(
              builder: (BuildContext context, SliverConstraints constraints) {
                final bool notificationsCanScroll =
                    constraints.precedingScrollExtent >
                    constraints.viewportMainAxisExtent;

                if (notificationsCanScroll) {
                  return SliverToBoxAdapter(
                    child: SizedBox(height: bottomPadding),
                  );
                }

                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      bottomPadding,
                    ),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: NotificationListFooter(
                        isLoading: false,
                        onLoadMore: onLoadMore,
                      ),
                    ),
                  ),
                );
              },
            )
          else
            SliverToBoxAdapter(child: SizedBox(height: bottomPadding)),
        ],
      ),
    );
  }
}
