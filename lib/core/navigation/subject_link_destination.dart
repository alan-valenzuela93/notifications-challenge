import 'package:notifications_challenge/core/navigation/notification_link_destination.dart';

class SubjectLinkDestination extends NotificationLinkDestination {
  final String subjectId;

  const SubjectLinkDestination({
    required super.uri,
    required super.path,
    required this.subjectId,
  });

  @override
  List<Object?> get props => <Object?>[...super.props, subjectId];
}
