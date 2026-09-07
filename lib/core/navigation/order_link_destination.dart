import 'package:notifications_challenge/core/navigation/notification_link_destination.dart';

class OrderLinkDestination extends NotificationLinkDestination {
  final String orderId;

  const OrderLinkDestination({
    required super.uri,
    required super.path,
    required this.orderId,
  });

  @override
  List<Object?> get props => <Object?>[...super.props, orderId];
}
