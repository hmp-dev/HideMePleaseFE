import 'package:equatable/equatable.dart';
import 'package:mobile/features/friends/domain/entities/friend_request_entity.dart';
import 'package:mobile/features/friends/domain/entities/pagination_entity.dart';

class FriendRequestResponseEntity extends Equatable {
  final List<FriendRequestEntity> requests;
  final PaginationEntity pagination;

  const FriendRequestResponseEntity({
    required this.requests,
    required this.pagination,
  });

  const FriendRequestResponseEntity.empty()
      : requests = const [],
        pagination = const PaginationEntity.empty();

  @override
  List<Object?> get props => [requests, pagination];
}
