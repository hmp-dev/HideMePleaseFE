import 'package:equatable/equatable.dart';
import 'package:mobile/features/friends/domain/entities/friendship_entity.dart';
import 'package:mobile/features/friends/domain/entities/pagination_entity.dart';

class FriendListResponseEntity extends Equatable {
  final List<FriendshipEntity> friends;
  final PaginationEntity pagination;

  const FriendListResponseEntity({
    required this.friends,
    required this.pagination,
  });

  const FriendListResponseEntity.empty()
      : friends = const [],
        pagination = const PaginationEntity.empty();

  @override
  List<Object?> get props => [friends, pagination];
}
