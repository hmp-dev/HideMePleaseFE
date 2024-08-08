import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'package:mobile/features/settings/domain/entities/model_banner_entity.dart';

part 'model_banner_dto.g.dart';

@JsonSerializable()
class ModelBannerDto extends Equatable {
  @JsonKey(name: "image")
  final String? image;
  @JsonKey(name: "startDate")
  final String? startDate;
  @JsonKey(name: "endDate")
  final String? endDate;

  const ModelBannerDto({
    this.image,
    this.startDate,
    this.endDate,
  });

  factory ModelBannerDto.fromJson(Map<String, dynamic> json) =>
      _$ModelBannerDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ModelBannerDtoToJson(this);

  ModelBannerEntity toEntity() => ModelBannerEntity(
        image: image ?? "",
        startDate: startDate ?? "",
        endDate: endDate ?? "",
      );

  @override
  List<Object?> get props => [
        image,
        startDate,
        endDate,
      ];
}
