import 'package:either_dart/either.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notifications_challenge/core/navigation/notification_link_destination.dart';
import 'package:notifications_challenge/core/navigation/notification_link_failure.dart';
import 'package:notifications_challenge/core/navigation/notification_link_parser.dart';
import 'package:notifications_challenge/core/navigation/notifications_link_destination.dart';
import 'package:notifications_challenge/core/navigation/order_link_destination.dart';
import 'package:notifications_challenge/core/navigation/subject_link_destination.dart';
import 'package:notifications_challenge/core/navigation/unavailable_link_destination.dart';

void main() {
  const NotificationLinkParser parser = NotificationLinkParser();

  test('devuelve el destino de la bandeja para una ruta relativa', () {
    final Either<NotificationLinkFailure, NotificationLinkDestination> result =
        parser.parse('/notifications');

    expect(result.isRight, isTrue);
    expect(result.right, isA<NotificationsLinkDestination>());
    expect(result.right.path, '/notifications');
  });

  test('extrae orderId del formato documentado por la API', () {
    final Either<NotificationLinkFailure, NotificationLinkDestination> result =
        parser.parse('app://orders/1234');

    expect(result.isRight, isTrue);
    expect(result.right, isA<OrderLinkDestination>());
    expect((result.right as OrderLinkDestination).orderId, '1234');
    expect(result.right.path, '/orders/1234');
  });

  test('extrae subjectId de una ruta interna relativa', () {
    final Either<NotificationLinkFailure, NotificationLinkDestination> result =
        parser.parse('/subjects/123');

    expect(result.isRight, isTrue);
    expect(result.right, isA<SubjectLinkDestination>());
    expect((result.right as SubjectLinkDestination).subjectId, '123');
  });

  test('mantiene tipado un destino interno todavía desconocido', () {
    final Either<NotificationLinkFailure, NotificationLinkDestination> result =
        parser.parse('app://calendar/events/42');

    expect(result.isRight, isTrue);
    expect(result.right, isA<UnavailableLinkDestination>());
    expect(result.right.path, '/calendar/events/42');
  });

  test('rechaza links externos y valores malformados', () {
    final Either<NotificationLinkFailure, NotificationLinkDestination>
    externalResult = parser.parse('https://example.com/orders/1234');
    final Either<NotificationLinkFailure, NotificationLinkDestination>
    malformedResult = parser.parse('http://[invalid');

    expect(externalResult.isLeft, isTrue);
    expect(
      externalResult.left.type,
      NotificationLinkFailureType.unsupportedScheme,
    );
    expect(malformedResult.isLeft, isTrue);
    expect(malformedResult.left.type, NotificationLinkFailureType.malformed);
  });
}
