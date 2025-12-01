import 'package:equatable/equatable.dart';
import 'package:mobile/features/friends/domain/entities/active_check_in_entity.dart';

class FriendUserEntity extends Equatable {
  final String userId;
  final String nickName;
  final String profileImageUrl;
  final String introduction;
  final ActiveCheckInEntity? activeCheckIn;

  const FriendUserEntity({
    required this.userId,
    required this.nickName,
    required this.profileImageUrl,
    required this.introduction,
    this.activeCheckIn,
  });

  const FriendUserEntity.empty()
      : userId = '',
        nickName = '',
        profileImageUrl = '',
        introduction = '',
        activeCheckIn = null;

  @override
  List<Object?> get props => [userId, nickName, profileImageUrl, introduction, activeCheckIn];
}
