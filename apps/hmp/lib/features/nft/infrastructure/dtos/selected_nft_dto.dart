import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/nft/domain/entities/selected_nft_entity.dart';
part 'selected_nft_dto.g.dart';

@JsonSerializable()
class SelectedNFTDto extends Equatable {
  final String? id;
  final String? name;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;
  @JsonKey(name: 'videoUrl')
  final String? videoUrl;
  final int? order;
  @JsonKey(name: 'tokenAddress')
  final String? tokenAddress;
  final String? symbol;
  final String? chain;
  @JsonKey(name: 'totalPoints')
  final int? totalPoints;
  @JsonKey(name: 'communityRank')
  final int? communityRank;
  @JsonKey(name: 'totalMembers')
  final int? totalMembers;
  @JsonKey(name: 'pointFluctuation')
  final int? pointFluctuation;

  const SelectedNFTDto({
    this.id,
    this.order,
    this.name,
    this.tokenAddress,
    this.symbol,
    this.chain,
    this.imageUrl,
    this.videoUrl,
    this.totalPoints,
    this.communityRank,
    this.totalMembers,
    this.pointFluctuation,
  });

  factory SelectedNFTDto.fromJson(Map<String, dynamic> json) =>
      _$SelectedNFTDtoFromJson(json);

  Map<String, dynamic> toJson() => _$SelectedNFTDtoToJson(this);

  @override
  List<Object?> get props => [
        id,
        order,
        name,
        symbol,
        chain,
        imageUrl,
        videoUrl,
        tokenAddress,
        totalPoints,
        communityRank,
        totalMembers,
        pointFluctuation,
      ];

  SelectedNFTEntity toEntity() => SelectedNFTEntity(
        id: id ?? "",
        order: order ?? 0,
        name: name ?? '',
        symbol: symbol ?? '',
        chain: chain ?? "",
        imageUrl: imageUrl ?? "",
        videoUrl: videoUrl ?? "",
        tokenAddress: tokenAddress ?? "",
        totalPoints: totalPoints ?? 0,
        communityRank: communityRank ?? 0,
        totalMembers: totalMembers ?? 0,
        pointFluctuation: pointFluctuation ?? 0,
      );
}
