import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/check_in_response_entity.dart';

part 'check_in_response_dto.g.dart';

@JsonSerializable()
class CheckInResponseDto extends Equatable {
  @JsonKey(name: "success")
  final bool? success;
  @JsonKey(name: "checkInId")
  final String? checkInId;
  @JsonKey(name: "groupProgress")
  final String? groupProgress;
  @JsonKey(name: "earnedPoints")
  final int? earnedPoints;

  const CheckInResponseDto({
    this.success,
    this.checkInId,
    this.groupProgress,
    this.earnedPoints,
  });

  factory CheckInResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CheckInResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckInResponseDtoToJson(this);

  @override
  List<Object?> get props => [
        success,
        checkInId,
        groupProgress,
        earnedPoints,
      ];

  CheckInResponseEntity toEntity() => CheckInResponseEntity(
        success: success ?? false,
        checkInId: checkInId ?? "",
        groupProgress: groupProgress ?? "",
        earnedPoints: earnedPoints ?? 0,
      );
}
