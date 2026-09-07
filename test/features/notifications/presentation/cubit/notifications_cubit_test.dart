import 'dart:async';
import 'dart:collection';

import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/get_notifications_params.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notifications_list.dart';
import 'package:notifications_challenge/core/notifications_api/models/pagination_meta.dart';
import 'package:notifications_challenge/core/notifications_api/usecases/get_notifications.dart';
import 'package:notifications_challenge/core/presentation/state/view_status.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notification_filter.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_cubit.dart';

void main() {
  const ApiError apiError = ApiError(
    message: 'No se pudo cargar.',
    type: ApiErrorType.connection,
  );

  test('carga inicial exitosa', () async {
    final _ScriptedGetNotifications useCase = _ScriptedGetNotifications(
      <Either<ApiError, NotificationsList>>[
        Right<ApiError, NotificationsList>(
          _page(<Notification>[_notification('1')], unreadCount: 8),
        ),
      ],
    );
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    await cubit.loadInitial();

    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.notifications, hasLength(1));
    expect(useCase.requests.single.limit, NotificationsCubit.pageLimit);
    expect(useCase.requests.single.offset, 0);
    await cubit.close();
  });

  test('carga inicial vacía', () async {
    final _ScriptedGetNotifications useCase = _ScriptedGetNotifications(
      <Either<ApiError, NotificationsList>>[
        Right<ApiError, NotificationsList>(_page(const <Notification>[])),
      ],
    );
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    await cubit.loadInitial();

    expect(cubit.state.status, ViewStatus.empty);
    expect(cubit.state.notifications, isEmpty);
    await cubit.close();
  });

  test('error inicial', () async {
    final _ScriptedGetNotifications useCase = _ScriptedGetNotifications(
      <Either<ApiError, NotificationsList>>[
        const Left<ApiError, NotificationsList>(apiError),
      ],
    );
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    await cubit.loadInitial();

    expect(cubit.state.status, ViewStatus.error);
    expect(cubit.state.errorMessage, apiError.message);
    expect(cubit.state.notifications, isEmpty);
    await cubit.close();
  });

  test('cambiar filtro reinicia offset y solicita datos al backend', () async {
    final _ScriptedGetNotifications useCase = _ScriptedGetNotifications(
      <Either<ApiError, NotificationsList>>[
        Right<ApiError, NotificationsList>(
          _page(<Notification>[
            _notification('1'),
            _notification('2'),
          ], hasMore: true),
        ),
        Right<ApiError, NotificationsList>(
          _page(<Notification>[_notification('3')], hasMore: true),
        ),
        Right<ApiError, NotificationsList>(
          _page(<Notification>[_notification('4')]),
        ),
      ],
    );
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    await cubit.loadInitial();
    await cubit.loadMore();
    await cubit.selectFilter(NotificationFilter.high);

    expect(
      useCase.requests.map((GetNotificationsParams params) => params.offset),
      <int?>[0, 2, 0],
    );
    expect(useCase.requests.last.priority, PriorityEnum.high);
    expect(cubit.state.selectedFilter, NotificationFilter.high);
    expect(cubit.state.notifications.single.id, '4');
    await cubit.close();
  });

  test('loadMore concatena la página recibida', () async {
    final _ScriptedGetNotifications useCase = _ScriptedGetNotifications(
      <Either<ApiError, NotificationsList>>[
        Right<ApiError, NotificationsList>(
          _page(<Notification>[_notification('1')], hasMore: true),
        ),
        Right<ApiError, NotificationsList>(
          _page(<Notification>[_notification('2')]),
        ),
      ],
    );
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    await cubit.loadInitial();
    await cubit.loadMore();

    expect(
      cubit.state.notifications.map((Notification item) => item.id),
      <String>['1', '2'],
    );
    expect(useCase.requests.last.offset, 1);
    await cubit.close();
  });

  test('meta.hasMore false evita nuevas cargas', () async {
    final _ScriptedGetNotifications useCase = _ScriptedGetNotifications(
      <Either<ApiError, NotificationsList>>[
        Right<ApiError, NotificationsList>(
          _page(<Notification>[_notification('1')]),
        ),
      ],
    );
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    await cubit.loadInitial();
    await cubit.loadMore();

    expect(cubit.state.hasMore, isFalse);
    expect(useCase.requests, hasLength(1));
    await cubit.close();
  });

  test('error de loadMore conserva contenido y permite reintentar', () async {
    final _ScriptedGetNotifications useCase = _ScriptedGetNotifications(
      <Either<ApiError, NotificationsList>>[
        Right<ApiError, NotificationsList>(
          _page(<Notification>[_notification('1')], hasMore: true),
        ),
        const Left<ApiError, NotificationsList>(apiError),
        Right<ApiError, NotificationsList>(
          _page(<Notification>[_notification('2')]),
        ),
      ],
    );
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    await cubit.loadInitial();
    await cubit.loadMore();

    expect(cubit.state.status, ViewStatus.success);
    expect(cubit.state.notifications.single.id, '1');
    expect(cubit.state.loadMoreError, apiError.message);

    await cubit.loadMore();

    expect(cubit.state.notifications, hasLength(2));
    expect(cubit.state.loadMoreError, isNull);
    expect(useCase.requests[1].offset, 1);
    expect(useCase.requests[2].offset, 1);
    await cubit.close();
  });

  test('unreadCount usa metadata en vez de contar elementos locales', () async {
    final _ScriptedGetNotifications useCase = _ScriptedGetNotifications(
      <Either<ApiError, NotificationsList>>[
        Right<ApiError, NotificationsList>(
          _page(<Notification>[
            _notification('1'),
            _notification('2'),
            _notification('3'),
          ], unreadCount: 17),
        ),
      ],
    );
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    await cubit.loadInitial();

    expect(cubit.state.notifications, hasLength(3));
    expect(cubit.state.unreadCount, 17);
    await cubit.close();
  });

  test('una respuesta obsoleta no sobrescribe el filtro actual', () async {
    final _ControlledGetNotifications useCase = _ControlledGetNotifications();
    final NotificationsCubit cubit = NotificationsCubit(useCase);

    final Future<void> highRequest = cubit.selectFilter(
      NotificationFilter.high,
    );
    final Future<void> unreadRequest = cubit.selectFilter(
      NotificationFilter.unread,
    );

    useCase.requests[1].complete(
      Right<ApiError, NotificationsList>(
        _page(<Notification>[_notification('unread-result')]),
      ),
    );
    await unreadRequest;
    useCase.requests[0].complete(
      Right<ApiError, NotificationsList>(
        _page(<Notification>[_notification('stale-high-result')]),
      ),
    );
    await highRequest;

    expect(cubit.state.selectedFilter, NotificationFilter.unread);
    expect(cubit.state.notifications.single.id, 'unread-result');
    expect(useCase.params[0].priority, PriorityEnum.high);
    expect(useCase.params[1].status, NotificationStatus.unread);
    await cubit.close();
  });
}

class _ScriptedGetNotifications extends GetNotifications {
  final Queue<Either<ApiError, NotificationsList>> _responses;
  final List<GetNotificationsParams> requests = <GetNotificationsParams>[];

  _ScriptedGetNotifications(List<Either<ApiError, NotificationsList>> responses)
    : _responses = Queue<Either<ApiError, NotificationsList>>.of(responses),
      super();

  @override
  Future<Either<ApiError, NotificationsList>> call([
    GetNotificationsParams params = const GetNotificationsParams(),
  ]) async {
    requests.add(params);
    return _responses.removeFirst();
  }
}

class _ControlledGetNotifications extends GetNotifications {
  final List<Completer<Either<ApiError, NotificationsList>>> requests =
      <Completer<Either<ApiError, NotificationsList>>>[];
  final List<GetNotificationsParams> params = <GetNotificationsParams>[];

  _ControlledGetNotifications() : super();

  @override
  Future<Either<ApiError, NotificationsList>> call([
    GetNotificationsParams params = const GetNotificationsParams(),
  ]) {
    final Completer<Either<ApiError, NotificationsList>> completer =
        Completer<Either<ApiError, NotificationsList>>();
    this.params.add(params);
    requests.add(completer);
    return completer.future;
  }
}

NotificationsList _page(
  List<Notification> notifications, {
  bool hasMore = false,
  int unreadCount = 0,
}) {
  return NotificationsList(
    notifications: notifications,
    meta: PaginationMeta(
      total: notifications.length,
      limit: NotificationsCubit.pageLimit,
      offset: 0,
      hasMore: hasMore,
      unreadCount: unreadCount,
    ),
  );
}

Notification _notification(String id) {
  return Notification(
    id: id,
    groupId: 'group-$id',
    title: 'Notificación $id',
    body: 'Contenido de la notificación $id',
    recipientId: 'user-1',
    priority: PriorityEnum.normal,
    status: NotificationStatus.unread,
    createdAt: DateTime.utc(2026, 9, 5, 12),
  );
}
