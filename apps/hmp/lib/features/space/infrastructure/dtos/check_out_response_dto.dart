import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_out_response_dto.g.dart';

@JsonSerializable()
class CheckOutResponseDto {
  final bool success;

  CheckOutResponseDto({
    required this.success,
  });

  factory CheckOutResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CheckOutResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CheckOutResponseDtoToJson(this);
}