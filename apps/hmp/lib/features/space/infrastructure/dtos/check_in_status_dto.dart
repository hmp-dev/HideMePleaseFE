import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/check_in_status_entity.dart';

part 'check_in_status_dto.g.dart';

@JsonSerializable()
class CheckInStatusDto extends Equatable {
  @JsonKey(name: "isCheckedIn")
  final bool? isCheckedIn;
  @JsonKey(name: "checkedInAt")
  final String? checkedInAt;
  @JsonKey(name: "groupProgress")
  final String? groupProgress;
  @JsonKey(name: "earnedPoints")
  final int? earnedPoints;
  @JsonKey(name: "groupId")
  final String? groupId;

  const CheckInStatusDto({
    this.isCheckedIn,
    this.checkedInAt,
    this.groupProgress,
    this.earnedPoints,
    this.groupId,
  });

  factory CheckInStatusDto.fromJson(Map<String, dynamic> json) =>
      _$CheckInStatusDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInStatusDtoToJson(this);

  @override
  List<Object?> get props => [
        isCheckedIn,
        checkedInAt,
        groupProgress,
        earnedPoints,
        groupId,
      ];

  CheckInStatusEntity toEntity() => CheckInStatusEntity(
        isCheckedIn: isCheckedIn ?? false,
        checkedInAt:
            checkedInAt != null ? DateTime.tryParse(checkedInAt!) : null,
        groupProgress: groupProgress ?? "",
        earnedPoints: earnedPoints ?? 0,
        groupId: groupId ?? "",
      );
}