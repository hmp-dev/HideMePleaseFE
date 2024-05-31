import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';

part 'benefit_dto.g.dart';

@JsonSerializable()
class BenefitDto extends Equatable {
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
  @JsonKey(name: "tokenAddress")
  final String? tokenAddress;

  const BenefitDto({
    this.id,
    this.description,
    this.singleUse,
    this.spaceId,
    this.spaceName,
    this.spaceImage,
    this.used,
    this.tokenAddress,
  });

  factory BenefitDto.fromJson(Map<String, dynamic> json) =>
      _$BenefitDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BenefitDtoToJson(this);

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
      tokenAddress,
    ];
  }

  BenefitEntity toEntity() {
    return BenefitEntity(
      id: id ?? '',
      description: description ?? '',
      singleUse: singleUse ?? false,
      spaceId: spaceId ?? '',
      spaceName: spaceName ?? '',
      spaceImage: spaceImage ?? '',
      used: used ?? false,
      tokenAddress: tokenAddress ?? '',
    );
  }
}
