import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/friends/domain/entities/friend_request_response_entity.dart';
import 'package:mobile/features/friends/infrastructure/dtos/friend_request_dto.dart';
import 'package:mobile/features/friends/infrastructure/dtos/pagination_dto.dart';

part 'friend_request_response_dto.g.dart';

@JsonSerializable()
class FriendRequestResponseDto extends Equatable {
  @JsonKey(name: "requests")
  final List<FriendRequestDto>? requests;

  @JsonKey(name: "pagination")
  final PaginationDto? pagination;

  const FriendRequestResponseDto({
    this.requests,
    this.pagination,
  });

  factory FriendRequestResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FriendRequestResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FriendRequestResponseDtoToJson(this);

  FriendRequestResponseEntity toEntity() {
    return FriendRequestResponseEntity(
      requests: requests?.map((e) => e.toEntity()).toList() ?? [],
      pagination: pagination?.toEntity() ?? const PaginationDto().toEntity(),
    );
  }

  @override
  List<Object?> get props => [requests, pagination];
}
