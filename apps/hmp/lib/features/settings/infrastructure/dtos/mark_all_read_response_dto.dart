import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'mark_all_read_response_dto.g.dart';

@JsonSerializable()
class MarkAllReadResponseDto extends Equatable {
  @JsonKey(name: "success")
  final bool? success;

  @JsonKey(name: "updatedCount")
  final int? updatedCount;

  const MarkAllReadResponseDto({
    this.success,
    this.updatedCount,
  });

  factory MarkAllReadResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MarkAllReadResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MarkAllReadResponseDtoToJson(this);

  @override
  List<Object?> get props => [success, updatedCount];
}
