import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/app/core/helpers/translation_helper.dart';
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
  @JsonKey(name: "nameEn")
  final String? nameEn;
  @JsonKey(name: "image")
  final String? image;
  @JsonKey(name: "category")
  final String? category;
  @JsonKey(name: "benefitDescription")
  final String? benefitDescription;
  @JsonKey(name: "benefitDescriptionEn")
  final String? benefitDescriptionEn;
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
  @JsonKey(name: "maxCheckInCapacity")
  final int? maxCheckInCapacity;

  const SpaceDto({
    this.id,
    this.name,
    this.nameEn,
    this.image,
    this.category,
    this.benefitDescription,
    this.benefitDescriptionEn,
    this.hot,
    this.hotPoints,
    this.hidingCount,
    this.latitude,
    this.longitude,
    this.businessHours,
    this.isTemporarilyClosed,
    this.spaceEventCategories,
    this.currentGroupProgress,
    this.maxCheckInCapacity,
  });

  factory SpaceDto.fromJson(Map<String, dynamic> json) =>
      _$SpaceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SpaceDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      name,
      nameEn,
      image,
      category,
      benefitDescription,
      benefitDescriptionEn,
      hot,
      hotPoints,
      hidingCount,
      latitude,
      longitude,
      businessHours,
      isTemporarilyClosed,
      spaceEventCategories,
      currentGroupProgress,
      maxCheckInCapacity,
    ];
  }

  SpaceEntity toEntity() {
    // Handle benefit description with fallback to extracting English from combined text
    String processedBenefitDescriptionEn = benefitDescriptionEn ?? "";

    // If English description is empty, try to extract from combined field
    if (processedBenefitDescriptionEn.isEmpty && benefitDescription != null) {
      processedBenefitDescriptionEn = TranslationHelper.extractEnglishFromCombinedText(benefitDescription);
    }

    return SpaceEntity(
      id: id ?? "",
      name: name ?? "",
      nameEn: nameEn ?? "",
      image: image ?? "",
      category: category ?? "",
      benefitDescription: benefitDescription ?? "",
      benefitDescriptionEn: processedBenefitDescriptionEn,
      hot: hot ?? false,
      hotPoints: hotPoints ?? 0,
      hidingCount: hidingCount ?? 0,
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      businessHours: businessHours?.map((e) => e.toEntity()).toList() ?? [],
      isTemporarilyClosed: isTemporarilyClosed ?? false,
      spaceEventCategories: spaceEventCategories?.map((e) => e.toEntity()).toList() ?? [],
      currentGroupProgress: currentGroupProgress ?? '',
      maxCapacity: maxCheckInCapacity ?? 0,
    );
  }
}
