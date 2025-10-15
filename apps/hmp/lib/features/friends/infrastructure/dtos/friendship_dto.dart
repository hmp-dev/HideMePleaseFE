import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/friendship_entity.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_user_dto.dart';

part 'friendship_dto.g.dart';

@JsonSerializable()
class FriendshipDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "status")
  final String? status;

  @JsonKey(name: "createdAt")
  final String? createdAt;

  @JsonKey(name: "friend")
  final FriendUserDto? friend;

  const FriendshipDto({
    this.id,
    this.status,
    this.createdAt,
    this.friend,
  });

  factory FriendshipDto.fromJson(Map<String, dynamic> json) =>
      _$FriendshipDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendshipDtoToJson(this);

  FriendshipEntity toEntity() {
    FriendshipStatus statusEnum;
    switch (status?.toUpperCase()) {
      case 'PENDING':
        statusEnum = FriendshipStatus.PENDING;
        break;
      case 'ACCEPTED':
        statusEnum = FriendshipStatus.ACCEPTED;
        break;
      case 'REJECTED':
        statusEnum = FriendshipStatus.REJECTED;
        break;
      case 'BLOCKED':
        statusEnum = FriendshipStatus.BLOCKED;
        break;
      default:
        statusEnum = FriendshipStatus.PENDING;
    }

    return FriendshipEntity(
      id: id ?? '',
      status: statusEnum,
      createdAt: createdAt ?? '',
      friend: friend?.toEntity() ?? const FriendUserDto().toEntity(),
    );
  }

  @override
  List<Object?> get props => [id, status, createdAt, friend];
}
