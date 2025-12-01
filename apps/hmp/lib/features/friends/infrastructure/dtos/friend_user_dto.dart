import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/friend_user_entity.dart';
import 'package:mobile/features/friends/infrastructure/dtos/active_check_in_dto.dart';

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

  @JsonKey(name: "activeCheckIn")
  final ActiveCheckInDto? activeCheckIn;

  const FriendUserDto({
    this.userId,
    this.nickName,
    this.profileImageUrl,
    this.introduction,
    this.activeCheckIn,
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
      activeCheckIn: activeCheckIn?.toEntity(),
    );
  }

  @override
  List<Object?> get props => [userId, nickName, profileImageUrl, introduction, activeCheckIn];
}
