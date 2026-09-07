import 'package:equatable/equatable.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/presentation/state/view_status.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notification_filter.dart';

const Object _notProvided = Object();

class NotificationsState extends Equatable {
  final ViewStatus status;
  final List<Notification> notifications;
  final int unreadCount;
  final bool hasMore;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? loadMoreError;
  final NotificationFilter selectedFilter;

  const NotificationsState({
    required this.status,
    required this.notifications,
    required this.unreadCount,
    required this.hasMore,
    required this.isLoadingMore,
    required this.selectedFilter,
    this.errorMessage,
    this.loadMoreError,
  });

  const NotificationsState.initial()
    : status = ViewStatus.initial,
      notifications = const <Notification>[],
      unreadCount = 0,
      hasMore = true,
      isLoadingMore = false,
      errorMessage = null,
      loadMoreError = null,
      selectedFilter = NotificationFilter.all;

  NotificationsState copyWith({
    ViewStatus? status,
    List<Notification>? notifications,
    int? unreadCount,
    bool? hasMore,
    bool? isLoadingMore,
    Object? errorMessage = _notProvided,
    Object? loadMoreError = _notProvided,
    NotificationFilter? selectedFilter,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: identical(errorMessage, _notProvided)
          ? this.errorMessage
          : errorMessage as String?,
      loadMoreError: identical(loadMoreError, _notProvided)
          ? this.loadMoreError
          : loadMoreError as String?,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    notifications,
    unreadCount,
    hasMore,
    isLoadingMore,
    errorMessage,
    loadMoreError,
    selectedFilter,
  ];
}
