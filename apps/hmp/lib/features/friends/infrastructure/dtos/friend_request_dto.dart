import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/friend_request_entity.dart';
import 'package:mobile/features/friends/domain/entities/friendship_entity.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_user_dto.dart';

part 'friend_request_dto.g.dart';

@JsonSerializable()
class FriendRequestDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "status")
  final String? status;

  @JsonKey(name: "createdAt")
  final String? createdAt;

  @JsonKey(name: "requester")
  final FriendUserDto? requester;

  const FriendRequestDto({
    this.id,
    this.status,
    this.createdAt,
    this.requester,
  });

  factory FriendRequestDto.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestDtoToJson(this);

  FriendRequestEntity toEntity() {
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

    return FriendRequestEntity(
      id: id ?? '',
      status: statusEnum,
      createdAt: createdAt ?? '',
      requester: requester?.toEntity() ?? const FriendUserDto().toEntity(),
    );
  }

  @override
  List<Object?> get props => [id, status, createdAt, requester];
}
