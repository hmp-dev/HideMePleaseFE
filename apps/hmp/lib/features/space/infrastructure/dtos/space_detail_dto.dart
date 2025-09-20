import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/space_detail_entity.dart';
import 'package:mobile/features/space/infrastructure/dtos/checked_in_user_dto.dart';

part 'space_detail_dto.g.dart';

@JsonSerializable()
class SpaceDetailDto extends Equatable {
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
  @JsonKey(name: "addressEn")
  final String? addressEn;
  @JsonKey(name: "businessHoursStart")
  final String? businessHoursStart;
  @JsonKey(name: "businessHoursEnd")
  final String? businessHoursEnd;
  @JsonKey(name: "category")
  final String? category;
  @JsonKey(name: "introduction")
  final String? introduction;
  @JsonKey(name: "introductionEn")
  final String? introductionEn;
  @JsonKey(name: "locationDescription")
  final String? locationDescription;
  @JsonKey(name: "image")
  final String? image;
  @JsonKey(name: "checkInCount")
  final int? checkInCount;
  final bool? spaceOpen;
  @JsonKey(name: "checkedInUsers")
  final List<CheckedInUserDto>? checkedInUsers;
  @JsonKey(name: "currentGroupProgress")
  final String? currentGroupProgress;

  const SpaceDetailDto({
    this.id,
    this.name,
    this.nameEn,
    this.latitude,
    this.longitude,
    this.address,
    this.addressEn,
    this.businessHoursStart,
    this.businessHoursEnd,
    this.category,
    this.introduction,
    this.introductionEn,
    this.locationDescription,
    this.image,
    this.checkInCount,
    this.spaceOpen,
    this.checkedInUsers,
    this.currentGroupProgress,
  });

  factory SpaceDetailDto.fromJson(Map<String, dynamic> json) =>
      _$SpaceDetailDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SpaceDetailDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      name,
      nameEn,
      latitude,
      longitude,
      address,
      addressEn,
      businessHoursStart,
      businessHoursEnd,
      category,
      introduction,
      introductionEn,
      locationDescription,
      image,
      checkInCount,
      spaceOpen,
      checkedInUsers,
      currentGroupProgress,
    ];
  }

  SpaceDetailEntity toEntity() => SpaceDetailEntity(
        id: id ?? "",
        name: name ?? "",
        nameEn: nameEn ?? "",
        latitude: latitude ?? 0,
        longitude: longitude ?? 0,
        address: address ?? "",
        addressEn: addressEn ?? "",
        businessHoursStart: businessHoursStart ?? "",
        businessHoursEnd: businessHoursEnd ?? "",
        category: category ?? "",
        introduction: introduction ?? "",
        introductionEn: introductionEn ?? "",
        locationDescription: locationDescription ?? "",
        image: image ?? "",
        checkInCount: checkInCount ?? 0,
        spaceOpen: spaceOpen ?? false,
        checkedInUsers:
            checkedInUsers?.map((e) => e.toEntity()).toList() ?? [],
        currentGroupProgress: currentGroupProgress ?? "",
      );
}
