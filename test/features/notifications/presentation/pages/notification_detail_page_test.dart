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
import 'package:notifications_challenge/features/notifications/presentation/pages/notification_detail_page.dart';
import 'package:notifications_challenge/features/notifications/presentation/pages/notifications_page.dart';
import 'package:notifications_challenge/features/notifications/presentation/widgets/notification_tile.dart';

void main() {
  testWidgets('renderiza título, body e información principal', (
    WidgetTester tester,
  ) async {
    final api.Notification notification = _notification();

    await _pumpDetail(tester, notification);

    expect(find.text(notification.title), findsOneWidget);
    expect(find.text(notification.body), findsOneWidget);
    expect(find.text('Alta'), findsOneWidget);
    expect(find.text('No leída'), findsOneWidget);
    expect(find.text('06/09/2026 · 12:30'), findsOneWidget);
    expect(find.text(notification.recipientId), findsOneWidget);
  });

  testWidgets('muestra scheduledAt cuando existe', (WidgetTester tester) async {
    await _pumpDetail(
      tester,
      _notification(scheduledAt: DateTime(2026, 9, 6, 18)),
    );

    expect(find.text('Programada para'), findsOneWidget);
    expect(find.text('06/09/2026 · 18:00'), findsOneWidget);
  });

  testWidgets('oculta scheduledAt cuando es null', (WidgetTester tester) async {
    await _pumpDetail(tester, _notification());

    expect(find.text('Programada para'), findsNothing);
  });

  testWidgets('muestra data simple y anidada de forma legible', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      _notification(
        data: <String, dynamic>{
          'subjectId': 'MAT-123',
          'active': true,
          'context': <String, dynamic>{'classroom': 'Aula 12'},
        },
      ),
    );

    expect(find.text('Datos adicionales'), findsOneWidget);
    expect(find.text('subjectId'), findsOneWidget);
    expect(find.text('MAT-123'), findsOneWidget);
    expect(find.text('active'), findsOneWidget);
    expect(find.text('true'), findsOneWidget);
    expect(find.textContaining('"classroom": "Aula 12"'), findsOneWidget);
  });

  testWidgets('oculta data cuando es null o está vacía', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(tester, _notification(data: <String, dynamic>{}));

    expect(find.text('Datos adicionales'), findsNothing);
  });

  testWidgets('muestra y procesa deepLink cuando existe', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      _notification(data: <String, dynamic>{'deepLink': 'app://orders/1234'}),
    );

    expect(find.text('Deep link'), findsOneWidget);
    expect(find.text('app://orders/1234'), findsOneWidget);
    expect(find.text('Procesar deep link'), findsOneWidget);

    await tester.ensureVisible(find.text('Procesar deep link'));
    await tester.tap(find.text('Procesar deep link'));
    await tester.pumpAndSettle();

    expect(
      find.text('El destino app://orders/1234 fue reconocido'),
      findsOneWidget,
    );
  });

  testWidgets('un deepLink inválido no rompe y muestra feedback', (
    WidgetTester tester,
  ) async {
    await _pumpDetail(
      tester,
      _notification(data: <String, dynamic>{'deepLink': 'http://[invalid'}),
    );

    await tester.ensureVisible(find.text('Procesar deep link'));
    await tester.tap(find.text('Procesar deep link'));
    await tester.pumpAndSettle();

    expect(find.text('El deep link no es válido.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tocar un NotificationTile abre el detalle correcto', (
    WidgetTester tester,
  ) async {
    final api.Notification notification = _notification();
    final NotificationsCubit cubit = NotificationsCubit(
      _SingleNotificationUseCase(notification),
    );
    addTearDown(cubit.close);
    await cubit.loadInitial();

    await tester.pumpWidget(
      MaterialApp(home: NotificationsPage(cubit: cubit, loadOnStart: false)),
    );
    final BuildContext listContext = tester.element(
      find.text(notification.title),
    );
    final Card notificationCard = tester.widget<Card>(find.byType(Card));
    expect(
      notificationCard.color,
      Theme.of(listContext).colorScheme.surfaceContainerLow,
    );
    expect(
      find.descendant(
        of: find.byType(NotificationTile),
        matching: find.byIcon(Icons.chevron_right),
      ),
      findsOneWidget,
    );

    await tester.tap(find.text(notification.title));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationDetailPage), findsOneWidget);
    expect(find.text('Detalle de notificación'), findsOneWidget);
    expect(find.text(notification.body), findsOneWidget);
  });
}

Future<void> _pumpDetail(
  WidgetTester tester,
  api.Notification notification,
) async {
  await tester.pumpWidget(
    MaterialApp(home: NotificationDetailPage(notification: notification)),
  );
}

api.Notification _notification({
  DateTime? scheduledAt,
  Map<String, dynamic>? data,
}) {
  return api.Notification(
    id: 'notification-1',
    groupId: 'group-1',
    title: 'Tu cursada fue actualizada',
    body:
        'Se modificaron los horarios de la materia. Revisá toda la información.',
    recipientId: 'student-123',
    priority: PriorityEnum.high,
    status: api.NotificationStatus.unread,
    scheduledAt: scheduledAt,
    notificationAdditionalData: data,
    createdAt: DateTime(2026, 9, 6, 12, 30),
  );
}

class _SingleNotificationUseCase extends GetNotifications {
  final api.Notification notification;

  _SingleNotificationUseCase(this.notification) : super();

  @override
  Future<Either<ApiError, NotificationsList>> call([
    GetNotificationsParams params = const GetNotificationsParams(),
  ]) async {
    return Right<ApiError, NotificationsList>(
      NotificationsList(
        notifications: <api.Notification>[notification],
        meta: const PaginationMeta(
          total: 1,
          limit: 20,
          offset: 0,
          hasMore: false,
          unreadCount: 1,
        ),
      ),
    );
  }
}
