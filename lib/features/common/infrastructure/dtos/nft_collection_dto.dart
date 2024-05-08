import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/common/domain/entities/nft_collection_entity.dart';
import 'package:mobile/features/common/infrastructure/dtos/nft_token_dto.dart';

part 'nft_collection_dto.g.dart';

@JsonSerializable()
class NftCollectionDto extends Equatable {
  @JsonKey(name: "symbol")
  final String? symbol;
  @JsonKey(name: "chain")
  final String? chain;
  @JsonKey(name: "tokenAddress")
  final String? tokenAddress;
  @JsonKey(name: "contractType")
  final String? contractType;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "collectionLogo")
  final String? collectionLogo;
  @JsonKey(name: "chainSymbol")
  final String? chainSymbol;
  @JsonKey(name: "tokens")
  final List<NftTokenDto>? tokens;

  const NftCollectionDto({
    this.symbol,
    this.chain,
    this.tokenAddress,
    this.contractType,
    this.name,
    this.collectionLogo,
    this.chainSymbol,
    this.tokens,
  });

  factory NftCollectionDto.fromJson(Map<String, dynamic> json) =>
      _$NftCollectionDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftCollectionDtoToJson(this);

  NftCollectionEntity toEntity() {
    return NftCollectionEntity(
      symbol: symbol ?? '',
      chain: chain ?? '',
      tokenAddress: tokenAddress ?? '',
      contractType: contractType ?? '',
      name: name ?? '',
      collectionLogo: collectionLogo ?? '',
      chainSymbol: chainSymbol ?? '',
      tokens: tokens?.map((e) => e.toEntity()).toList() ?? [],
    );
  }

  @override
  List<Object?> get props {
    return [
      symbol,
      chain,
      tokenAddress,
      contractType,
      name,
      collectionLogo,
      chainSymbol,
      tokens,
    ];
  }
}
