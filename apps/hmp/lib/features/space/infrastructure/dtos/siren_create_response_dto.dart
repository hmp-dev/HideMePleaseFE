import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/siren_create_response_entity.dart';

part 'siren_create_response_dto.g.dart';

@JsonSerializable()
class SirenCreateResponseDto extends Equatable {
  @JsonKey(name: "success")
  final bool? success;

  @JsonKey(name: "sirenId")
  final String? sirenId;

  @JsonKey(name: "pointsSpent")
  final int? pointsSpent;

  @JsonKey(name: "remainingBalance")
  final int? remainingBalance;

  const SirenCreateResponseDto({
    this.success,
    this.sirenId,
    this.pointsSpent,
    this.remainingBalance,
  });

  factory SirenCreateResponseDto.fromJson(Map<String, dynamic> json) =>
      _$SirenCreateResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SirenCreateResponseDtoToJson(this);

  SirenCreateResponseEntity toEntity() {
    return SirenCreateResponseEntity(
      success: success ?? false,
      sirenId: sirenId ?? '',
      pointsSpent: pointsSpent ?? 0,
      remainingBalance: remainingBalance ?? 0,
    );
  }

  @override
  List<Object?> get props => [success, sirenId, pointsSpent, remainingBalance];
}
