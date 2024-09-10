import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/nft/domain/entities/nft_token_entity.dart';

part 'nft_token_dto.g.dart';

@JsonSerializable()
class NftTokenDto extends Equatable {
  @JsonKey(name: "id")
  final String? id;
  @JsonKey(name: "tokenId")
  final String? tokenId;
  @JsonKey(name: "name")
  final String? name;
  @JsonKey(name: "imageUrl")
  final String? imageUrl;
  @JsonKey(name: "videoUrl")
  final String? videoUrl;
  @JsonKey(name: "selected")
  final bool? selected;
  @JsonKey(name: "updatedAt")
  final String? updatedAt;

  const NftTokenDto({
    this.id,
    this.tokenId,
    this.name,
    this.imageUrl,
    this.videoUrl,
    this.selected,
    this.updatedAt,
  });

  factory NftTokenDto.fromJson(Map<String, dynamic> json) =>
      _$NftTokenDtoFromJson(json);

  Map<String, dynamic> toJson() => _$NftTokenDtoToJson(this);

  @override
  List<Object?> get props => [id, tokenId, name, imageUrl, selected];

  NftTokenEntity toEntity() => NftTokenEntity(
        id: id!,
        tokenId: tokenId ?? '',
        name: name ?? '',
        imageUrl: imageUrl ?? '',
        videoUrl: videoUrl ?? '',
        selected: selected ?? false,
        updatedAt: updatedAt ?? '',
      );
}
