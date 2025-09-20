import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/near_by_space_entity.dart';

part 'near_by_space_dto.g.dart';

@JsonSerializable()
class NearBySpaceDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "nameEn")
  final String? nameEn;
  @JsonKey(name: "latitude")
  final double? latitude;
  @JsonKey(name: "longitude")
  final double? longitude;
  @JsonKey(name: "address")
  final String? address;
  @JsonKey(name: "image")
  final String? image;
  @JsonKey(name: "distance")
  final int? distance;

  const NearBySpaceDto({
    this.id,
    this.name,
    this.nameEn,
    this.latitude,
    this.longitude,
    this.address,
    this.image,
    this.distance,
  });

  factory NearBySpaceDto.fromJson(Map<String, dynamic> json) =>
      _$NearBySpaceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NearBySpaceDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      name,
      nameEn,
      latitude,
      longitude,
      address,
      image,
      distance,
    ];
  }

  NearBySpaceEntity toEntity() => NearBySpaceEntity(
        id: id ?? "",
        name: name ?? "",
        nameEn: nameEn ?? "",
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        address: address ?? "",
        image: image ?? "",
        distance: distance ?? 0,
      );
}
