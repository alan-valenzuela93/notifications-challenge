import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/get_notifications_params.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/notifications_api/models/notifications_list.dart';
import 'package:notifications_challenge/core/notifications_api/models/pagination_meta.dart';
import 'package:notifications_challenge/core/notifications_api/usecases/get_notifications.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:notifications_challenge/features/notifications/presentation/pages/create_notification_page.dart';
import 'package:notifications_challenge/features/notifications/presentation/pages/notifications_page.dart';

void main() {
  testWidgets('shows notifications inbox structure', (
    WidgetTester tester,
  ) async {
    final NotificationsCubit cubit = NotificationsCubit(GetNotifications());

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(cubit: cubit, loadOnStart: false)),
    );

    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Todas'), findsOneWidget);
    expect(find.text('No leídas'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    expect(find.byType(CreateNotificationPage), findsOneWidget);
    expect(find.text('Crear notificación'), findsWidgets);

    await cubit.close();
  });

  testWidgets('loads the next page only after the user scrolls near the end', (
    WidgetTester tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 320);
    addTearDown(() {
      tester.view
        ..resetDevicePixelRatio()
        ..resetPhysicalSize();
    });

    final _PagedGetNotifications useCase = _PagedGetNotifications();
    final NotificationsCubit cubit = NotificationsCubit(useCase);
    addTearDown(cubit.close);
    await cubit.loadInitial();

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(cubit: cubit, loadOnStart: false)),
    );
    await tester.pumpAndSettle();

    expect(
      useCase.requests.map((GetNotificationsParams request) => request.offset),
      <int?>[0],
    );
    expect(cubit.state.notifications, hasLength(2));
    expect(find.byKey(const Key('notifications-load-more')), findsNothing);

    await tester.drag(
      find.byKey(const PageStorageKey<String>('notifications-list')),
      const Offset(0, -240),
    );
    await tester.pumpAndSettle();

    expect(
      useCase.requests.map((GetNotificationsParams request) => request.offset),
      <int?>[0, 2],
    );
    expect(cubit.state.notifications, hasLength(4));
  });

  testWidgets(
    'offers manual pagination when the first page does not fill the screen',
    (WidgetTester tester) async {
      tester.view
        ..devicePixelRatio = 1
        ..physicalSize = const Size(390, 1000);
      addTearDown(() {
        tester.view
          ..resetDevicePixelRatio()
          ..resetPhysicalSize();
      });

      final _PagedGetNotifications useCase = _PagedGetNotifications();
      final NotificationsCubit cubit = NotificationsCubit(useCase);
      addTearDown(cubit.close);
      await cubit.loadInitial();

      await tester.pumpWidget(
        MaterialApp(home: NotificationsPage(cubit: cubit, loadOnStart: false)),
      );
      await tester.pumpAndSettle();

      expect(
        useCase.requests.map(
          (GetNotificationsParams request) => request.offset,
        ),
        <int?>[0],
      );
      expect(find.byKey(const Key('notifications-load-more')), findsOneWidget);

      await tester.tap(find.byKey(const Key('notifications-load-more')));
      await tester.pumpAndSettle();

      expect(
        useCase.requests.map(
          (GetNotificationsParams request) => request.offset,
        ),
        <int?>[0, 2],
      );
      expect(cubit.state.notifications, hasLength(4));
      expect(find.byKey(const Key('notifications-load-more')), findsNothing);
    },
  );

  testWidgets('pull to refresh does not request the next page', (
    WidgetTester tester,
  ) async {
    tester.view
      ..devicePixelRatio = 1
      ..physicalSize = const Size(390, 1000);
    addTearDown(() {
      tester.view
        ..resetDevicePixelRatio()
        ..resetPhysicalSize();
    });

    final _PagedGetNotifications useCase = _PagedGetNotifications();
    final NotificationsCubit cubit = NotificationsCubit(useCase);
    addTearDown(cubit.close);
    await cubit.loadInitial();

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(cubit: cubit, loadOnStart: false)),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(const PageStorageKey<String>('notifications-list')),
      const Offset(0, 300),
    );
    await tester.pumpAndSettle();

    expect(
      useCase.requests.map((GetNotificationsParams request) => request.offset),
      <int?>[0, 0],
    );
    expect(cubit.state.notifications, hasLength(2));
  });
}

class _PagedGetNotifications extends GetNotifications {
  final List<GetNotificationsParams> requests = <GetNotificationsParams>[];

  @override
  Future<Either<ApiError, NotificationsList>> call([
    GetNotificationsParams params = const GetNotificationsParams(),
  ]) async {
    requests.add(params);
    final bool firstPage = params.offset == 0;

    return Right<ApiError, NotificationsList>(
      NotificationsList(
        notifications: firstPage
            ? <api.Notification>[_notification(1), _notification(2)]
            : <api.Notification>[_notification(3), _notification(4)],
        meta: PaginationMeta(
          total: 4,
          limit: NotificationsCubit.pageLimit,
          offset: params.offset ?? 0,
          hasMore: firstPage,
          unreadCount: 4,
        ),
      ),
    );
  }
}

api.Notification _notification(int id) {
  return api.Notification(
    id: 'notification-$id',
    groupId: 'group-$id',
    title: 'Notificación $id',
    body: 'Contenido $id',
    recipientId: 'user-1',
    priority: PriorityEnum.normal,
    status: api.NotificationStatus.unread,
    createdAt: DateTime.utc(2026, 9, 6, 12),
  );
}
