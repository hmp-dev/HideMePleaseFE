import 'package:equatable/equatable.dart';
import 'package:mobile/features/friends/domain/entities/friend_user_entity.dart';
import 'package:mobile/features/friends/domain/entities/friendship_entity.dart';

class FriendRequestEntity extends Equatable {
  final String id;
  final FriendshipStatus status;
  final String createdAt;
  final FriendUserEntity requester;

  const FriendRequestEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.requester,
  });

  const FriendRequestEntity.empty()
      : id = '',
        status = FriendshipStatus.PENDING,
        createdAt = '',
        requester = const FriendUserEntity.empty();

  @override
  List<Object?> get props => [id, status, createdAt, requester];
}
