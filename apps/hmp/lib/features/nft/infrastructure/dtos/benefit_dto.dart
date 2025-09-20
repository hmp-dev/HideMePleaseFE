import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/nft/domain/entities/benefit_entity.dart';

part 'benefit_dto.g.dart';

@JsonSerializable()
class NftBenefitsResponseDto extends Equatable {
  final List<BenefitDto>? benefits;
  final int benefitCount;

  const NftBenefitsResponseDto({
    this.benefits,
    required this.benefitCount,
  });

  factory NftBenefitsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$NftBenefitsResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftBenefitsResponseDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      benefits,
      benefitCount,
    ];
  }
}

@JsonSerializable()
class BenefitDto extends Equatable {
  final String? id;
  final String? description;
  @JsonKey(name: "descriptionEn")
  final String? descriptionEn;
  final bool? singleUse;
  final String? spaceId;
  final String? spaceName;
  @JsonKey(name: "spaceNameEn")
  final String? spaceNameEn;
  final String? spaceImage;
  final bool? used;
  final String? state;
  final String? tokenAddress;
  final String? nftCollectionName;
  final String? termsUrl;
  final String? nftCollectionImage;
  final String? nftCollectionVideo;
  final String? nftCollectionChain;

  const BenefitDto({
    this.id,
    this.description,
    this.descriptionEn,
    this.singleUse,
    this.spaceId,
    this.spaceName,
    this.spaceNameEn,
    this.spaceImage,
    this.used,
    this.state,
    this.tokenAddress,
    this.nftCollectionName,
    this.termsUrl,
    this.nftCollectionImage,
    this.nftCollectionVideo,
    this.nftCollectionChain,
  });

  factory BenefitDto.fromJson(Map<String, dynamic> json) =>
      _$BenefitDtoFromJson(json);

  Map<String, dynamic> toJson() => _$BenefitDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      description,
      descriptionEn,
      singleUse,
      spaceId,
      spaceName,
      spaceNameEn,
      spaceImage,
      used,
      state,
      tokenAddress,
      nftCollectionName,
      termsUrl,
      nftCollectionImage,
      nftCollectionVideo,
      nftCollectionChain,
    ];
  }

  BenefitEntity toEntity() {
    return BenefitEntity(
      id: id ?? '',
      description: description ?? '',
      descriptionEn: descriptionEn ?? '',
      singleUse: singleUse ?? false,
      spaceId: spaceId ?? '',
      spaceName: spaceName ?? '',
      spaceNameEn: spaceNameEn ?? '',
      spaceImage: spaceImage ?? '',
      used: used ?? false,
      state: state ?? '',
      tokenAddress: tokenAddress ?? '',
      nftCollectionName: nftCollectionName ?? '',
      termsUrl: termsUrl ?? '',
      nftCollectionImage: nftCollectionImage ?? '',
      nftCollectionVideo: nftCollectionVideo ?? '',
      nftCollectionChain: nftCollectionChain ?? '',
    );
  }
}
