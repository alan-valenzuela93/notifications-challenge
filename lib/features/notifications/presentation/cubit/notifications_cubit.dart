import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/get_notifications_params.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notifications_list.dart';
import 'package:notifications_challenge/core/notifications_api/usecases/get_notifications.dart';
import 'package:notifications_challenge/core/presentation/state/view_status.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notification_filter.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_state.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  static const int pageLimit = 4;

  final GetNotifications _getNotifications;
  int _offset = 0;
  int _requestVersion = 0;

  NotificationsCubit(this._getNotifications)
    : super(const NotificationsState.initial());

  Future<void> loadInitial() async {
    await _loadFirstPage(showLoading: true);
  }

  Future<void> retry() async {
    await _loadFirstPage(showLoading: true);
  }

  Future<void> refresh() async {
    await _loadFirstPage(showLoading: state.notifications.isEmpty);
  }

  Future<void> selectFilter(NotificationFilter filter) async {
    if (filter == state.selectedFilter && state.status != ViewStatus.initial) {
      return;
    }

    emit(
      state.copyWith(
        selectedFilter: filter,
        notifications: [],
        unreadCount: 0,
        hasMore: true,
        isLoadingMore: false,
        errorMessage: null,
        loadMoreError: null,
      ),
    );
    await _loadFirstPage(showLoading: true);
  }

  Future<void> loadMore() async {
    if (state.status != ViewStatus.success ||
        !state.hasMore ||
        state.isLoadingMore) {
      return;
    }

    final int requestVersion = _requestVersion;
    final int requestedOffset = _offset;
    emit(state.copyWith(isLoadingMore: true, loadMoreError: null));

    final Either<ApiError, NotificationsList> result = await _getNotifications(
      _buildParams(offset: requestedOffset),
    );

    if (!_isCurrent(requestVersion)) {
      return;
    }

    result.fold(
      (ApiError error) {
        emit(
          state.copyWith(isLoadingMore: false, loadMoreError: error.message),
        );
      },
      (NotificationsList response) {
        _offset = requestedOffset + response.notifications.length;
        emit(
          state.copyWith(
            notifications: List<Notification>.unmodifiable([
              ...state.notifications,
              ...response.notifications,
            ]),
            unreadCount: response.meta.unreadCount,
            hasMore: response.meta.hasMore,
            isLoadingMore: false,
            loadMoreError: null,
          ),
        );
      },
    );
  }

  Future<void> _loadFirstPage({required bool showLoading}) async {
    final int requestVersion = ++_requestVersion;
    _offset = 0;

    if (showLoading) {
      emit(
        state.copyWith(
          status: ViewStatus.loading,
          notifications: [],
          unreadCount: 0,
          hasMore: true,
          isLoadingMore: false,
          errorMessage: null,
          loadMoreError: null,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: null,
          loadMoreError: null,
        ),
      );
    }

    final Either<ApiError, NotificationsList> result = await _getNotifications(
      _buildParams(offset: 0),
    );

    if (!_isCurrent(requestVersion)) {
      return;
    }

    result.fold(
      (ApiError error) {
        if (state.notifications.isEmpty) {
          emit(
            state.copyWith(
              status: ViewStatus.error,
              hasMore: false,
              errorMessage: error.message,
            ),
          );
          return;
        }

        emit(state.copyWith(loadMoreError: error.message));
      },
      (NotificationsList response) {
        _offset = response.notifications.length;
        emit(
          state.copyWith(
            status: response.notifications.isEmpty
                ? ViewStatus.empty
                : ViewStatus.success,
            notifications: List<Notification>.unmodifiable(
              response.notifications,
            ),
            unreadCount: response.meta.unreadCount,
            hasMore: response.meta.hasMore,
            isLoadingMore: false,
            errorMessage: null,
            loadMoreError: null,
          ),
        );
      },
    );
  }

  GetNotificationsParams _buildParams({required int offset}) {
    final NotificationFilter filter = state.selectedFilter;

    return GetNotificationsParams(
      status: switch (filter) {
        NotificationFilter.unread => NotificationStatus.unread,
        NotificationFilter.read => NotificationStatus.read,
        _ => null,
      },
      priority: switch (filter) {
        NotificationFilter.high => PriorityEnum.high,
        NotificationFilter.normal => PriorityEnum.normal,
        NotificationFilter.low => PriorityEnum.low,
        _ => null,
      },
      limit: pageLimit,
      offset: offset,
    );
  }

  bool _isCurrent(int requestVersion) {
    return !isClosed && requestVersion == _requestVersion;
  }
}
