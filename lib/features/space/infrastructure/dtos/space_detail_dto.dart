import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';

part 'space_detail_dto.g.dart';

@JsonSerializable()
class SpaceDetailDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "latitude")
  final double? latitude;
  @JsonKey(name: "longitude")
  final double? longitude;
  @JsonKey(name: "address")
  final String? address;
  @JsonKey(name: "businessHoursStart")
  final String? businessHoursStart;
  @JsonKey(name: "businessHoursEnd")
  final String? businessHoursEnd;
  @JsonKey(name: "category")
  final String? category;
  @JsonKey(name: "introduction")
  final String? introduction;
  @JsonKey(name: "locationDescription")
  final String? locationDescription;
  @JsonKey(name: "image")
  final String? image;

  const SpaceDetailDto({
    this.id,
    this.name,
    this.latitude,
    this.longitude,
    this.address,
    this.businessHoursStart,
    this.businessHoursEnd,
    this.category,
    this.introduction,
    this.locationDescription,
    this.image,
  });

  factory SpaceDetailDto.fromJson(Map<String, dynamic> json) =>
      _$SpaceDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SpaceDetailDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      name,
      latitude,
      longitude,
      address,
      businessHoursStart,
      businessHoursEnd,
      category,
      introduction,
      locationDescription,
      image,
    ];
  }

  SpaceDetailEntity toEntity() => SpaceDetailEntity(
        id: id ?? "",
        name: name ?? "",
        latitude: latitude ?? 0,
        longitude: longitude ?? 0,
        address: address ?? "",
        businessHoursStart: businessHoursStart ?? "",
        businessHoursEnd: businessHoursEnd ?? "",
        category: category ?? "",
        introduction: introduction ?? "",
        locationDescription: locationDescription ?? "",
        image: image ?? "",
      );
}
