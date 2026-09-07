import 'package:equatable/equatable.dart';

abstract class NotificationLinkDestination extends Equatable {
  final Uri uri;
  final String path;

  const NotificationLinkDestination({required this.uri, required this.path});

  @override
  List<Object?> get props => <Object?>[uri, path];
}
