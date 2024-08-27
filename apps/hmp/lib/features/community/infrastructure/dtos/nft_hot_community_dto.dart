import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'nft_hot_community_dto.g.dart';

@JsonSerializable()
class NftHotCommunityDto extends Equatable {
  @JsonKey(name: "tokenAddress")
  final String? tokenAddress;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "collectionLogo")
  final String? collectionLogo;
  @JsonKey(name: "chain")
  final String? chain;

  const NftHotCommunityDto({
    this.tokenAddress,
    this.name,
    this.collectionLogo,
    this.chain,
  });

  factory NftHotCommunityDto.fromJson(Map<String, dynamic> json) =>
      _$NftHotCommunityDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftHotCommunityDtoToJson(this);

  @override
  List<Object?> get props => [
        tokenAddress,
        name,
        collectionLogo,
        chain,
      ];

  NftHotCommunityDto toEntity() => NftHotCommunityDto(
        tokenAddress: tokenAddress ?? '',
        name: name ?? '',
        collectionLogo: collectionLogo ?? '',
        chain: chain ?? '',
      );
}
