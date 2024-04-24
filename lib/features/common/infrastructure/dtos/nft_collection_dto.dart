import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/domain/entities/nft_collection_entity.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_token_dto.dart';

part 'nft_collection_dto.g.dart';

@JsonSerializable()
class NftCollectionDto extends Equatable {
  @JsonKey(name: "tokenAddress")
  final String? tokenAddress;
  @JsonKey(name: "possibleSpam")
  final bool? possibleSpam;
  @JsonKey(name: "contractType")
  final String? contractType;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "symbol")
  final String? symbol;
  @JsonKey(name: "verifiedCollection")
  final bool? verifiedCollection;
  @JsonKey(name: "collectionLogo")
  final String? collectionLogo;
  @JsonKey(name: "collectionBannerImage")
  final String? collectionBannerImage;
  @JsonKey(name: "chain")
  final String? chain;
  @JsonKey(name: "walletAddress")
  final String? walletAddress;
  @JsonKey(name: "tokens")
  final List<NftTokenDto>? tokens;
  @JsonKey(name: "chainSymbol")
  final String? chainSymbol;

  const NftCollectionDto({
    this.tokenAddress,
    this.possibleSpam,
    this.contractType,
    this.name,
    this.symbol,
    this.verifiedCollection,
    this.collectionLogo,
    this.collectionBannerImage,
    this.chain,
    this.walletAddress,
    this.tokens,
    this.chainSymbol,
  });

  factory NftCollectionDto.fromJson(Map<String, dynamic> json) =>
      _$NftCollectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftCollectionDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      tokenAddress,
      possibleSpam,
      contractType,
      name,
      symbol,
      verifiedCollection,
      collectionLogo,
      collectionBannerImage,
      chain,
      walletAddress,
      tokens,
      chainSymbol,
    ];
  }

  NftCollectionEntity toEntity() {
    return NftCollectionEntity(
      tokenAddress: tokenAddress ?? '',
      possibleSpam: possibleSpam ?? false,
      contractType: contractType ?? '',
      name: name ?? '',
      symbol: symbol ?? '',
      verifiedCollection: verifiedCollection ?? false,
      collectionLogo: collectionLogo ?? "",
      collectionBannerImage: collectionBannerImage ?? "",
      chain: chain ?? '',
      walletAddress: walletAddress ?? '',
      tokens: tokens?.map((dto) => dto.toEntity()).toList() ?? [],
      chainSymbol: chainSymbol ?? '',
    );
  }
}
