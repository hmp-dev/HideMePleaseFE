import 'package:equatable/equatable.dart';

class FriendUserEntity extends Equatable {
  final String userId;
  final String nickName;
  final String profileImageUrl;
  final String introduction;

  const FriendUserEntity({
    required this.userId,
    required this.nickName,
    required this.profileImageUrl,
    required this.introduction,
  });

  const FriendUserEntity.empty()
      : userId = '',
        nickName = '',
        profileImageUrl = '',
        introduction = '';

  @override
  List<Object?> get props => [userId, nickName, profileImageUrl, introduction];
}
