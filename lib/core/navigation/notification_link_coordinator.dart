import 'package:flutter/material.dart';
import 'package:notifications_challenge/core/navigation/notification_link_destination.dart';
import 'package:notifications_challenge/core/navigation/notification_link_failure.dart';
import 'package:notifications_challenge/core/navigation/notification_link_parser.dart';
import 'package:notifications_challenge/core/navigation/notifications_link_destination.dart';

class NotificationLinkCoordinator {
  final NotificationLinkParser parser;

  const NotificationLinkCoordinator({
    this.parser = const NotificationLinkParser(),
  });

  void open(
    BuildContext context,
    String notificationLink, {
    required VoidCallback onUnavailableDestination,
    required VoidCallback onInvalidLink,
  }) {
    parser
        .parse(notificationLink)
        .fold(
          (NotificationLinkFailure _) {
            onInvalidLink();
          },
          (NotificationLinkDestination destination) {
            _openDestination(
              context,
              destination,
              onUnavailableDestination: onUnavailableDestination,
            );
          },
        );
  }

  void _openDestination(
    BuildContext context,
    NotificationLinkDestination destination, {
    required VoidCallback onUnavailableDestination,
  }) {
    if (destination is NotificationsLinkDestination) {
      Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
      return;
    }

    onUnavailableDestination();
  }
}
