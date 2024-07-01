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
  final bool? singleUse;
  final String? spaceId;
  final String? spaceName;
  final String? spaceImage;
  final bool? used;
  final String? state;
  final String? tokenAddress;
  final String? nftCollectionName;
  final String? termsUrl;
  final String? nftCollectionImage;
  final String? nftCollectionChain;

  const BenefitDto({
    this.id,
    this.description,
    this.singleUse,
    this.spaceId,
    this.spaceName,
    this.spaceImage,
    this.used,
    this.state,
    this.tokenAddress,
    this.nftCollectionName,
    this.termsUrl,
    this.nftCollectionImage,
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
      singleUse,
      spaceId,
      spaceName,
      spaceImage,
      used,
      state,
      tokenAddress,
      nftCollectionName,
      termsUrl,
      nftCollectionImage,
      nftCollectionChain,
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
      state: state ?? '',
      tokenAddress: tokenAddress ?? '',
      nftCollectionName: nftCollectionName ?? '',
      termsUrl: termsUrl ?? '',
      nftCollectionImage: nftCollectionImage ?? '',
      nftCollectionChain: nftCollectionChain ?? '',
    );
  }
}
