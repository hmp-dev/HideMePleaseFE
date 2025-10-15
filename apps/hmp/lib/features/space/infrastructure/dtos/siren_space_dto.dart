import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/siren_space_entity.dart';

part 'siren_space_dto.g.dart';

@JsonSerializable()
class SirenSpaceDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;

  @JsonKey(name: "name")
  final String? name;

  @JsonKey(name: "nameEn")
  final String? nameEn;

  @JsonKey(name: "image")
  final String? image;

  @JsonKey(name: "latitude")
  final double? latitude;

  @JsonKey(name: "longitude")
  final double? longitude;

  @JsonKey(name: "category")
  final String? category;

  const SirenSpaceDto({
    this.id,
    this.name,
    this.nameEn,
    this.image,
    this.latitude,
    this.longitude,
    this.category,
  });

  factory SirenSpaceDto.fromJson(Map<String, dynamic> json) =>
      _$SirenSpaceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SirenSpaceDtoToJson(this);

  SirenSpaceEntity toEntity() {
    return SirenSpaceEntity(
      id: id ?? '',
      name: name ?? '',
      nameEn: nameEn ?? '',
      image: image ?? '',
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      category: category ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, nameEn, image, latitude, longitude, category];
}
