import 'dart:async';

import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/notifications_api/errors/api_error.dart';
import 'package:notifications_challenge/core/notifications_api/models/create_notification.dart';
import 'package:notifications_challenge/core/notifications_api/models/notification.dart'
    as api;
import 'package:notifications_challenge/core/notifications_api/usecases/create_notifications.dart';
import 'package:notifications_challenge/features/notifications/presentation/cubit/create_notification_cubit.dart';
import 'package:notifications_challenge/features/notifications/presentation/pages/create_notification_page.dart';

void main() {
  testWidgets('valida los campos obligatorios antes de enviar', (
    WidgetTester tester,
  ) async {
    final _FakeCreateNotification useCase = _FakeCreateNotification(
      (_) async =>
          Right<ApiError, List<api.Notification>>(<api.Notification>[]),
    );
    final CreateNotificationCubit cubit = CreateNotificationCubit(useCase);
    addTearDown(cubit.close);

    await _pumpPage(tester, cubit: cubit);
    await _tapSubmit(tester);

    expect(find.text('Ingresá un destinatario.'), findsOneWidget);
    expect(find.text('Ingresá un título.'), findsOneWidget);
    expect(find.text('Ingresá el cuerpo de la notificación.'), findsOneWidget);
    expect(useCase.receivedNotification, isNull);
  });

  testWidgets(
    'seleccionar fecha no valida una fila adicional que todavía no se editó',
    (WidgetTester tester) async {
      final _FakeCreateNotification useCase = _FakeCreateNotification(
        (_) async =>
            Right<ApiError, List<api.Notification>>(<api.Notification>[]),
      );
      final CreateNotificationCubit cubit = CreateNotificationCubit(useCase);
      addTearDown(cubit.close);

      await _pumpPage(tester, cubit: cubit);
      await _addAdditionalDataEntry(tester);

      final Finder schedule = find.byKey(
        const Key('create-notification-schedule'),
      );
      await tester.ensureVisible(schedule);
      await tester.tap(schedule);
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Ingresá una clave.'), findsNothing);
      expect(find.text('Ingresá un valor.'), findsNothing);
    },
  );

  testWidgets('envía el DTO tipado y muestra progreso durante el POST', (
    WidgetTester tester,
  ) async {
    final Completer<Either<ApiError, List<api.Notification>>> completer =
        Completer<Either<ApiError, List<api.Notification>>>();
    final _FakeCreateNotification useCase = _FakeCreateNotification(
      (_) => completer.future,
    );
    final CreateNotificationCubit cubit = CreateNotificationCubit(useCase);
    addTearDown(cubit.close);
    bool created = false;

    await _pumpPage(
      tester,
      cubit: cubit,
      onCreated: () {
        created = true;
      },
    );
    await _fillRequiredFields(tester);
    await _addAdditionalDataEntry(tester);
    await tester.enterText(_editableField('additional-data-key-0'), 'orderId');
    await tester.enterText(_editableField('additional-data-value-0'), '1234');
    await tester.ensureVisible(
      find.byKey(const Key('create-notification-priority')),
    );
    await tester.tap(find.byKey(const Key('create-notification-priority')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alta').last);
    await tester.pumpAndSettle();

    await _tapSubmit(tester, settle: false);
    await tester.pump();

    expect(find.text('Creando notificación...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.byKey(const Key('create-notification-submit')),
          )
          .onPressed,
      isNull,
    );

    completer.complete(
      Right<ApiError, List<api.Notification>>(<api.Notification>[
        _notification,
      ]),
    );
    await tester.pumpAndSettle();

    final CreateNotificationDto request = useCase.receivedNotification!;
    expect(request.recipientIds, <String>['usr_123']);
    expect(request.title, 'Título de prueba');
    expect(request.body, 'Cuerpo de prueba');
    expect(request.priority, PriorityEnum.high);
    expect(request.scheduledAt, isNull);
    expect(request.data, <String, dynamic>{'orderId': '1234'});
    expect(created, isTrue);
  });

  testWidgets('valida que las claves adicionales no estén duplicadas', (
    WidgetTester tester,
  ) async {
    final _FakeCreateNotification useCase = _FakeCreateNotification(
      (_) async =>
          Right<ApiError, List<api.Notification>>(<api.Notification>[]),
    );
    final CreateNotificationCubit cubit = CreateNotificationCubit(useCase);
    addTearDown(cubit.close);

    await _pumpPage(tester, cubit: cubit);
    await _fillRequiredFields(tester);
    await _addAdditionalDataEntry(tester);
    await _addAdditionalDataEntry(tester);
    await tester.enterText(_editableField('additional-data-key-0'), 'orderId');
    await tester.enterText(_editableField('additional-data-value-0'), '1234');
    await tester.enterText(_editableField('additional-data-key-1'), 'orderId');
    await tester.enterText(_editableField('additional-data-value-1'), '5678');
    await _tapSubmit(tester);

    expect(find.text('La clave no puede repetirse.'), findsNWidgets(2));
    expect(useCase.receivedNotification, isNull);
  });

  testWidgets('muestra el error entregado por la API', (
    WidgetTester tester,
  ) async {
    const ApiError apiError = ApiError(
      message: 'No se pudo crear la notificación.',
      type: ApiErrorType.badResponse,
      statusCode: 400,
    );
    final _FakeCreateNotification useCase = _FakeCreateNotification(
      (_) async => const Left<ApiError, List<api.Notification>>(apiError),
    );
    final CreateNotificationCubit cubit = CreateNotificationCubit(useCase);
    addTearDown(cubit.close);

    await _pumpPage(tester, cubit: cubit);
    await _fillRequiredFields(tester);
    await _tapSubmit(tester);

    expect(find.text(apiError.message), findsOneWidget);
    expect(useCase.receivedNotification?.data, isNull);
  });
}

Future<void> _pumpPage(
  WidgetTester tester, {
  required CreateNotificationCubit cubit,
  VoidCallback? onCreated,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: CreateNotificationPage(cubit: cubit, onCreated: onCreated),
    ),
  );
}

Future<void> _fillRequiredFields(WidgetTester tester) async {
  await tester.enterText(
    _editableField('create-notification-recipient'),
    'usr_123',
  );
  await tester.enterText(
    _editableField('create-notification-title'),
    'Título de prueba',
  );
  await tester.enterText(
    _editableField('create-notification-body'),
    'Cuerpo de prueba',
  );
}

Future<void> _addAdditionalDataEntry(WidgetTester tester) async {
  final Finder addButton = find.byKey(const Key('additional-data-add'));
  await tester.ensureVisible(addButton);
  await tester.tap(addButton);
  await tester.pump();
}

Future<void> _tapSubmit(WidgetTester tester, {bool settle = true}) async {
  final Finder submit = find.byKey(const Key('create-notification-submit'));
  await tester.ensureVisible(submit);
  await tester.tap(submit);
  if (settle) {
    await tester.pumpAndSettle();
  }
}

Finder _editableField(String key) {
  return find.descendant(
    of: find.byKey(Key(key)),
    matching: find.byType(EditableText),
  );
}

class _FakeCreateNotification extends CreateNotification {
  final Future<Either<ApiError, List<api.Notification>>> Function(
    CreateNotificationDto notification,
  )
  handler;
  CreateNotificationDto? receivedNotification;

  _FakeCreateNotification(this.handler);

  @override
  Future<Either<ApiError, List<api.Notification>>> call(
    CreateNotificationDto notification,
  ) async {
    receivedNotification = notification;
    return await handler(notification);
  }
}

final api.Notification _notification = api.Notification(
  id: 'notification-1',
  groupId: 'group-1',
  title: 'Título de prueba',
  body: 'Cuerpo de prueba',
  recipientId: 'usr_123',
  priority: PriorityEnum.high,
  status: api.NotificationStatus.unread,
  createdAt: DateTime.utc(2026, 9, 6, 12),
);
