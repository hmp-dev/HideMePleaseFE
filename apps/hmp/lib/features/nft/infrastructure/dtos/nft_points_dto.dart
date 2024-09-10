import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/nft/domain/entities/nft_points_entity.dart';

part 'nft_points_dto.g.dart';

@JsonSerializable()
class NftPointsDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "imageUrl")
  final String? imageUrl;
  @JsonKey(name: "videoUrl")
  final String? videoUrl;
  @JsonKey(name: "tokenAddress")
  final String? tokenAddress;
  @JsonKey(name: "totalPoints")
  final int? totalPoints;

  const NftPointsDto({
    this.id,
    this.name,
    this.imageUrl,
    this.videoUrl,
    this.tokenAddress,
    this.totalPoints,
  });

  factory NftPointsDto.fromJson(Map<String, dynamic> json) =>
      _$NftPointsDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftPointsDtoToJson(this);

  @override
  List<Object?> get props {
    return [
      id,
      name,
      imageUrl,
      videoUrl,
      tokenAddress,
      totalPoints,
    ];
  }

  NftPointsEntity toEntity() => NftPointsEntity(
        id: id!,
        name: name ?? '',
        imageUrl: imageUrl ?? '',
        videoUrl: videoUrl ?? '',
        tokenAddress: tokenAddress ?? '',
        totalPoints: totalPoints ?? 0,
      );
}
