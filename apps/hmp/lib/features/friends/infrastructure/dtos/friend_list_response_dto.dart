import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/friend_list_response_entity.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friendship_dto.dart';
import 'package:mobile/features/friends/infrastructure/dtos/pagination_dto.dart';

part 'friend_list_response_dto.g.dart';

@JsonSerializable()
class FriendListResponseDto extends Equatable {
  @JsonKey(name: "friends")
  final List<FriendshipDto>? friends;

  @JsonKey(name: "pagination")
  final PaginationDto? pagination;

  const FriendListResponseDto({
    this.friends,
    this.pagination,
  });

  factory FriendListResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FriendListResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendListResponseDtoToJson(this);

  FriendListResponseEntity toEntity() {
    return FriendListResponseEntity(
      friends: friends?.map((e) => e.toEntity()).toList() ?? [],
      pagination: pagination?.toEntity() ?? const PaginationDto().toEntity(),
    );
  }

  @override
  List<Object?> get props => [friends, pagination];
}
