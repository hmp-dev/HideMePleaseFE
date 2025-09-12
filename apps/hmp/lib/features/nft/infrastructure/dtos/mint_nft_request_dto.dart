import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/features/nft/domain/entities/mint_nft_request_entity.dart';

part 'mint_nft_request_dto.g.dart';

@JsonSerializable()
class MintNftRequestDto {
  final String walletAddress;
  final String imageUrl;
  final String metadataUrl;

  MintNftRequestDto({
    required this.walletAddress,
    required this.imageUrl,
    required this.metadataUrl,
  });

  factory MintNftRequestDto.fromJson(Map<String, dynamic> json) =>
      _$MintNftRequestDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MintNftRequestDtoToJson(this);

  factory MintNftRequestDto.fromEntity(MintNftRequestEntity entity) {
    return MintNftRequestDto(
      walletAddress: entity.walletAddress,
      imageUrl: entity.imageUrl,
      metadataUrl: entity.metadataUrl,
    );
  }

  MintNftRequestEntity toEntity() {
    return MintNftRequestEntity(
      walletAddress: walletAddress,
      imageUrl: imageUrl,
      metadataUrl: metadataUrl,
    );
  }
}