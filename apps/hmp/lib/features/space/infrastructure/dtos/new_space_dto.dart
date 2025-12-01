import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/new_space_entity.dart';

part 'new_space_dto.g.dart';

@JsonSerializable()
class NewSpaceDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "image")
  final String? image;
  @JsonKey(name: "mainBenefitDescription")
  final String? mainBenefitDescription;
  @JsonKey(name: "remainingBenefitCount")
  final int? remainingBenefitCount;
  @JsonKey(name: "hidingCount")
  final int? hidingCount;
  @JsonKey(name: "maxCheckInCapacity")
  final int? maxCheckInCapacity;

  const NewSpaceDto({
    this.id,
    this.name,
    this.image,
    this.mainBenefitDescription,
    this.remainingBenefitCount,
    this.hidingCount,
    this.maxCheckInCapacity,
  });

  factory NewSpaceDto.fromJson(Map<String, dynamic> json) =>
      _$NewSpaceDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NewSpaceDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      name,
      image,
      mainBenefitDescription,
      remainingBenefitCount,
      hidingCount,
      maxCheckInCapacity,
    ];
  }

  NewSpaceEntity toEntity() => NewSpaceEntity(
        id: id ?? "",
        name: name ?? "",
        image: image ?? "",
        mainBenefitDescription: mainBenefitDescription ?? "",
        remainingBenefitCount: remainingBenefitCount ?? 0,
        hidingCount: hidingCount ?? 0,
        maxCapacity: maxCheckInCapacity ?? 0,
      );
}
