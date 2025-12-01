import 'package:equatable/equatable.dart';
import 'package:mobile/features/friends/domain/entities/friend_user_entity.dart';

enum FriendshipStatus {
  PENDING,           // 구버전 호환용 (deprecated)
  PENDING_SENT,      // 내가 보낸 신청 (대기 중)
  PENDING_RECEIVED,  // 받은 신청 (수락 가능)
  ACCEPTED,
  REJECTED,
  BLOCKED,
}

class FriendshipEntity extends Equatable {
  final String id;
  final FriendshipStatus status;
  final String createdAt;
  final FriendUserEntity friend;

  const FriendshipEntity({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.friend,
  });

  const FriendshipEntity.empty()
      : id = '',
        status = FriendshipStatus.PENDING,
        createdAt = '',
        friend = const FriendUserEntity.empty();

  @override
  List<Object?> get props => [id, status, createdAt, friend];
}
