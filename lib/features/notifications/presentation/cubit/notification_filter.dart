enum NotificationFilter { all, unread, read, high, normal, low }

extension NotificationFilterLabel on NotificationFilter {
  String get label {
    return switch (this) {
      NotificationFilter.all => 'Todas',
      NotificationFilter.unread => 'No leídas',
      NotificationFilter.read => 'Leídas',
      NotificationFilter.high => 'Alta',
      NotificationFilter.normal => 'Normal',
      NotificationFilter.low => 'Baja',
    };
  }
}
