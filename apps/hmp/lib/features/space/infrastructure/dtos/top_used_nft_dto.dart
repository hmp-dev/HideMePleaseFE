import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/space/domain/entities/top_used_nft_entity.dart';

part 'top_used_nft_dto.g.dart';

@JsonSerializable()
class TopUsedNftDto extends Equatable {
  @JsonKey(name: "pointFluctuation")
  final int? pointFluctuation;
  @JsonKey(name: "totalPoints")
  final int? totalPoints;
  @JsonKey(name: "tokenAddress")
  final String? tokenAddress;
  @JsonKey(name: "totalMembers")
  final int? totalMembers;
  @JsonKey(name: "communityRank")
  final int? communityRank;
  @JsonKey(name: "collectionLogo")
  final String? collectionLogo;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "chain")
  final String? chain;
  @JsonKey(name: "ownedCollection")
  final bool? ownedCollection;

  const TopUsedNftDto({
    this.pointFluctuation,
    this.totalPoints,
    this.tokenAddress,
    this.totalMembers,
    this.communityRank,
    this.collectionLogo,
    this.name,
    this.chain,
    this.ownedCollection,
  });

  factory TopUsedNftDto.fromJson(Map<String, dynamic> json) =>
      _$TopUsedNftDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TopUsedNftDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      pointFluctuation,
      totalPoints,
      tokenAddress,
      totalMembers,
      communityRank,
      collectionLogo,
      name,
      chain,
      ownedCollection,
    ];
  }

  TopUsedNftEntity toEntity() => TopUsedNftEntity(
        pointFluctuation: pointFluctuation ?? 0,
        totalPoints: totalPoints ?? 0,
        tokenAddress: tokenAddress ?? '',
        totalMembers: totalMembers ?? 0,
        communityRank: communityRank ?? 0,
        collectionLogo: collectionLogo ?? '',
        name: name ?? '',
        chain: chain ?? '',
        ownedCollection: ownedCollection ?? false,
      );
}
