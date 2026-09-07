import 'package:either_dart/either.dart';
import 'package:notifications_challenge/core/navigation/notification_link_destination.dart';
import 'package:notifications_challenge/core/navigation/notification_link_failure.dart';
import 'package:notifications_challenge/core/navigation/notifications_link_destination.dart';
import 'package:notifications_challenge/core/navigation/order_link_destination.dart';
import 'package:notifications_challenge/core/navigation/subject_link_destination.dart';
import 'package:notifications_challenge/core/navigation/unavailable_link_destination.dart';

class NotificationLinkParser {
  const NotificationLinkParser();

  Either<NotificationLinkFailure, NotificationLinkDestination> parse(
    String notificationLink,
  ) {
    final String value = notificationLink.trim();
    if (value.isEmpty) {
      return const Left<NotificationLinkFailure, NotificationLinkDestination>(
        NotificationLinkFailure(NotificationLinkFailureType.empty),
      );
    }

    if (value.contains(RegExp(r'\s'))) {
      return const Left<NotificationLinkFailure, NotificationLinkDestination>(
        NotificationLinkFailure(NotificationLinkFailureType.malformed),
      );
    }

    final Uri? uri = Uri.tryParse(value);
    if (uri == null) {
      return const Left<NotificationLinkFailure, NotificationLinkDestination>(
        NotificationLinkFailure(NotificationLinkFailureType.malformed),
      );
    }

    final String? internalPath = _internalPath(uri, value);
    if (internalPath == null) {
      return const Left<NotificationLinkFailure, NotificationLinkDestination>(
        NotificationLinkFailure(NotificationLinkFailureType.unsupportedScheme),
      );
    }

    final List<String> segments = Uri(path: internalPath).pathSegments;
    if (segments.length == 1 && segments.first == 'notifications') {
      return Right<NotificationLinkFailure, NotificationLinkDestination>(
        NotificationsLinkDestination(uri: uri, path: internalPath),
      );
    }

    if (segments.length == 2 && segments.first == 'orders') {
      return Right<NotificationLinkFailure, NotificationLinkDestination>(
        OrderLinkDestination(
          uri: uri,
          path: internalPath,
          orderId: segments.last,
        ),
      );
    }

    if (segments.length == 2 && segments.first == 'subjects') {
      return Right<NotificationLinkFailure, NotificationLinkDestination>(
        SubjectLinkDestination(
          uri: uri,
          path: internalPath,
          subjectId: segments.last,
        ),
      );
    }

    return Right<NotificationLinkFailure, NotificationLinkDestination>(
      UnavailableLinkDestination(uri: uri, path: internalPath),
    );
  }

  String? _internalPath(Uri uri, String originalValue) {
    if (!uri.hasScheme) {
      if (!originalValue.startsWith('/') ||
          uri.hasAuthority ||
          uri.pathSegments.isEmpty) {
        return null;
      }
      return _normalizedPath(uri.pathSegments);
    }

    if (uri.scheme.toLowerCase() != 'app' || uri.host.isEmpty) {
      return null;
    }

    return _normalizedPath(<String>[uri.host, ...uri.pathSegments]);
  }

  String _normalizedPath(List<String> segments) {
    return '/${segments.join('/')}';
  }
}
