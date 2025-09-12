import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/space_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/business_hours_dto.dart';
import 'package:mobile/features/space/infrastructure/dtos/space_event_category_dto.dart';

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
  @JsonKey(name: "latitude")
  final double? latitude;
  @JsonKey(name: "longitude")
  final double? longitude;
  @JsonKey(name: "SpaceBusinessHours")
  final List<BusinessHoursDto>? businessHours;
  @JsonKey(name: "isTemporarilyClosed")
  final bool? isTemporarilyClosed;
  @JsonKey(name: "SpaceEventCategory")
  final List<SpaceEventCategoryDto>? spaceEventCategories;
  @JsonKey(name: "currentGroupProgress")
  final String? currentGroupProgress;

  const SpaceDto({
    this.id,
    this.name,
    this.image,
    this.category,
    this.benefitDescription,
    this.hot,
    this.hotPoints,
    this.hidingCount,
    this.latitude,
    this.longitude,
    this.businessHours,
    this.isTemporarilyClosed,
    this.spaceEventCategories,
    this.currentGroupProgress,
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
      latitude,
      longitude,
      businessHours,
      isTemporarilyClosed,
      spaceEventCategories,
      currentGroupProgress,
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
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        businessHours: businessHours?.map((e) => e.toEntity()).toList() ?? [],
        isTemporarilyClosed: isTemporarilyClosed ?? false,
        spaceEventCategories: spaceEventCategories?.map((e) => e.toEntity()).toList() ?? [],
        currentGroupProgress: currentGroupProgress ?? '',
      );
}
