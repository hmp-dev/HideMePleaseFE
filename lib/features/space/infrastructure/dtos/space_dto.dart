import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';

part 'space_dto.g.dart';

@JsonSerializable()
class SpaceDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "image")
  final String? image;
  @JsonKey(name: "category")
  final String? category;
  @JsonKey(name: "benefitDescription")
  final String? benefitDescription;
  @JsonKey(name: "hot")
  final bool? hot;
  @JsonKey(name: "hotPoints")
  final int? hotPoints;
  @JsonKey(name: "hidingCount")
  final int? hidingCount;

  const SpaceDto({
    this.id,
    this.name,
    this.image,
    this.category,
    this.benefitDescription,
    this.hot,
    this.hotPoints,
    this.hidingCount,
  });

  factory SpaceDto.fromJson(Map<String, dynamic> json) =>
      _$SpaceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SpaceDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      category,
      benefitDescription,
      hot,
      hotPoints,
      hidingCount,
    ];
  }

  SpaceEntity toEntity() => SpaceEntity(
        id: id ?? "",
        name: name ?? "",
        image: image ?? "",
        category: category ?? "",
        benefitDescription: benefitDescription ?? "",
        hot: hot ?? false,
        hotPoints: hotPoints ?? 0,
        hidingCount: hidingCount ?? 0,
      );
}
