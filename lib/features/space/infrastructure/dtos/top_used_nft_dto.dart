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
  @JsonKey(name: "collectionLogo")
  final String? collectionLogo;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "chain")
  final String? chain;

  const TopUsedNftDto({
    this.pointFluctuation,
    this.totalPoints,
    this.tokenAddress,
    this.collectionLogo,
    this.name,
    this.chain,
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
      collectionLogo,
      name,
      chain,
    ];
  }

  TopUsedNftEntity toEntity() => TopUsedNftEntity(
        pointFluctuation: pointFluctuation ?? 0,
        totalPoints: totalPoints ?? 0,
        tokenAddress: tokenAddress ?? '',
        collectionLogo: collectionLogo ?? '',
        name: name ?? '',
        chain: chain ?? '',
      );
}
