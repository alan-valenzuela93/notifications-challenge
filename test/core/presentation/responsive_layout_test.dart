import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/presentation/state/view_status.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_empty_view.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_error_view.dart';
import 'package:notifications_challenge/core/presentation/widgets/app_responsive_container.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notification_filter.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/notifications_state.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notifications_content.dart';

void main() {
  testWidgets('compact layout supports large accessible text', (
    WidgetTester tester,
  ) async {
    _setViewport(tester, const Size(320, 568));
    final ScrollController controller = ScrollController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _testApp(
        size: const Size(320, 568),
        textScaler: const TextScaler.linear(2),
        child: NotificationsContent(
          state: NotificationsState(
            status: ViewStatus.success,
            notifications: <api.Notification>[_longNotification],
            unreadCount: 12,
            hasMore: false,
            isLoadingMore: false,
            selectedFilter: NotificationFilter.all,
          ),
          scrollController: controller,
          onRefresh: () async {},
          onRetry: () {},
          onLoadMore: () {},
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text(_longNotification.title), findsOneWidget);
  });

  testWidgets('empty and error views do not overflow in short landscape', (
    WidgetTester tester,
  ) async {
    _setViewport(tester, const Size(720, 240));
    await tester.pumpWidget(
      _testApp(
        size: const Size(720, 240),
        textScaler: const TextScaler.linear(2),
        child: const AppEmptyView(
          icon: Icons.notifications_none,
          message: 'No hay notificaciones para este filtro.',
        ),
      ),
    );
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _testApp(
        size: const Size(720, 240),
        textScaler: const TextScaler.linear(2),
        child: AppErrorView(
          message: 'No se pudo cargar el contenido. Intentalo nuevamente.',
          onRetry: () {},
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('expanded layout constrains content width', (
    WidgetTester tester,
  ) async {
    _setViewport(tester, const Size(1440, 900));
    const Key contentKey = Key('responsive-content');

    await tester.pumpWidget(
      _testApp(
        size: const Size(1440, 900),
        child: const AppResponsiveContainer(
          child: ColoredBox(key: contentKey, color: Colors.transparent),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(contentKey)).width, 960);
    expect(tester.takeException(), isNull);
  });
}

void _setViewport(WidgetTester tester, Size size) {
  tester.view
    ..devicePixelRatio = 1
    ..physicalSize = size;
  addTearDown(() {
    tester.view
      ..resetDevicePixelRatio()
      ..resetPhysicalSize();
  });
}

Widget _testApp({
  required Size size,
  required Widget child,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(size: size, textScaler: textScaler),
      child: Scaffold(body: child),
    ),
  );
}

final api.Notification _longNotification = api.Notification(
  id: 'notification-1',
  groupId: 'group-1',
  title: 'Una notificación con un título suficientemente largo para probar',
  body:
      'Este contenido también es extenso para verificar el comportamiento '
      'responsive con escalado de texto accesible.',
  recipientId: 'user-1',
  priority: PriorityEnum.high,
  status: api.NotificationStatus.unread,
  createdAt: DateTime.utc(2026, 9, 6, 12),
);
