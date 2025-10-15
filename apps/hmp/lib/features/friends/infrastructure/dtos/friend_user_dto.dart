import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/friend_user_entity.dart';

part 'friend_user_dto.g.dart';

@JsonSerializable()
class FriendUserDto extends Equatable {
  @JsonKey(name: "userId")
  final String? userId;

  @JsonKey(name: "nickName")
  final String? nickName;

  @JsonKey(name: "profileImageUrl")
  final String? profileImageUrl;

  @JsonKey(name: "introduction")
  final String? introduction;

  const FriendUserDto({
    this.userId,
    this.nickName,
    this.profileImageUrl,
    this.introduction,
  });

  factory FriendUserDto.fromJson(Map<String, dynamic> json) =>
      _$FriendUserDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendUserDtoToJson(this);

  FriendUserEntity toEntity() {
    return FriendUserEntity(
      userId: userId ?? '',
      nickName: nickName ?? '',
      profileImageUrl: profileImageUrl ?? '',
      introduction: introduction ?? '',
    );
  }

  @override
  List<Object?> get props => [userId, nickName, profileImageUrl, introduction];
}
