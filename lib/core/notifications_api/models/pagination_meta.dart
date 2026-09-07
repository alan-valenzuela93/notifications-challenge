import 'package:equatable/equatable.dart';

class PaginationMeta extends Equatable {
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;
  final int unreadCount;

  const PaginationMeta({
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
    required this.unreadCount,
  });

  factory PaginationMeta.fromMap(Map<String, dynamic> map) {
    return PaginationMeta(
      total: map['total'] as int,
      limit: map['limit'] as int,
      offset: map['offset'] as int,
      hasMore: map['hasMore'] as bool,
      unreadCount: map['unreadCount'] as int,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    total,
    limit,
    offset,
    hasMore,
    unreadCount,
  ];
}
