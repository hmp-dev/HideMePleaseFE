import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/features/space/domain/entities/current_group_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/check_in_user_dto.dart';

part 'current_group_dto.g.dart';

@JsonSerializable()
class CurrentGroupDto {
  final String groupId;
  final String progress;
  final bool isCompleted;
  final List<CheckInUserDto> members;
  final int bonusPoints;

  CurrentGroupDto({
    required this.groupId,
    required this.progress,
    required this.isCompleted,
    required this.members,
    required this.bonusPoints,
  });

  factory CurrentGroupDto.fromJson(Map<String, dynamic> json) =>
      _$CurrentGroupDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CurrentGroupDtoToJson(this);

  CurrentGroupEntity toEntity() {
    return CurrentGroupEntity(
      groupId: groupId,
      progress: progress,
      isCompleted: isCompleted,
      members: members.map((e) => e.toEntity()).toList(),
      bonusPoints: bonusPoints,
    );
  }
}
