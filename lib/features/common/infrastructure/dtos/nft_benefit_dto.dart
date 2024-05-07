import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/domain/entities/nft_benefit_entity.dart';

part 'nft_benefit_dto.g.dart';

@JsonSerializable()
class NftBenefitDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "description")
  final String? description;
  @JsonKey(name: "singleUse")
  final bool? singleUse;
  @JsonKey(name: "spaceId")
  final String? spaceId;
  @JsonKey(name: "spaceName")
  final String? spaceName;
  @JsonKey(name: "spaceImage")
  final String? spaceImage;
  @JsonKey(name: "used")
  final bool? used;

  const NftBenefitDto({
    this.id,
    this.description,
    this.singleUse,
    this.spaceId,
    this.spaceName,
    this.spaceImage,
    this.used,
  });

  factory NftBenefitDto.fromJson(Map<String, dynamic> json) =>
      _$NftBenefitDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftBenefitDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      description,
      singleUse,
      spaceId,
      spaceName,
      spaceImage,
      used,
    ];
  }

  NftBenefitEntity toEntity() {
    return NftBenefitEntity(
      id: id ?? '',
      description: description ?? '',
      singleUse: singleUse ?? false,
      spaceId: spaceId ?? '',
      spaceName: spaceName ?? '',
      spaceImage: spaceImage ?? '',
      used: used ?? false,
    );
  }
}
