import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/features/space/domain/entities/check_in_users_response_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_in_user_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/current_group_dto.dart';

part 'check_in_users_response_dto.g.dart';

@JsonSerializable()
class CheckInUsersResponseDto {
  final int totalCount;
  final List<CheckInUserDto> users;
  final CurrentGroupDto? currentGroup;

  CheckInUsersResponseDto({
    required this.totalCount,
    required this.users,
    this.currentGroup,
  });

  factory CheckInUsersResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CheckInUsersResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInUsersResponseDtoToJson(this);

  CheckInUsersResponseEntity toEntity() {
    return CheckInUsersResponseEntity(
      totalCount: totalCount,
      users: users.map((e) => e.toEntity()).toList(),
      currentGroup: currentGroup?.toEntity(),
    );
  }
}
