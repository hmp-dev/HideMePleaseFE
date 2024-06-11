import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/community/domain/entities/top_collection_nft_entity.dart';

part 'top_collection_nft_dto.g.dart';

@JsonSerializable()
class TopCollectionNftDto extends Equatable {
  final int? pointFluctuation;
  final int? totalPoints;
  final String? tokenAddress;
  final String? collectionLogo;
  final String? name;
  final String? chain;
  final bool? ownedCollection;
  final int? communityRank;

  const TopCollectionNftDto({
    this.pointFluctuation,
    this.totalPoints,
    this.tokenAddress,
    this.collectionLogo,
    this.name,
    this.chain,
    this.ownedCollection,
    this.communityRank,
  });

  factory TopCollectionNftDto.fromJson(Map<String, dynamic> json) =>
      _$TopCollectionNftDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TopCollectionNftDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      pointFluctuation,
      totalPoints,
      tokenAddress,
      collectionLogo,
      name,
      chain,
      ownedCollection,
      communityRank,
    ];
  }

  TopCollectionNftEntity toEntity() => TopCollectionNftEntity(
        pointFluctuation: pointFluctuation ?? 0,
        totalPoints: totalPoints ?? 0,
        tokenAddress: tokenAddress ?? '',
        collectionLogo: collectionLogo ?? '',
        name: name ?? '',
        chain: chain ?? '',
        ownedCollection: ownedCollection ?? false,
        communityRank: communityRank ?? 0,
      );
}
