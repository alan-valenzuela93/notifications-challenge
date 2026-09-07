import 'package:equatable/equatable.dart';

enum NotificationLinkFailureType { empty, malformed, unsupportedScheme }

class NotificationLinkFailure extends Equatable {
  final NotificationLinkFailureType type;

  const NotificationLinkFailure(this.type);

  @override
  List<Object?> get props => <Object?>[type];
}
