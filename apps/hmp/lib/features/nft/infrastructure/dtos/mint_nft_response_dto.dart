import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/features/nft/domain/entities/mint_nft_response_entity.dart';

part 'mint_nft_response_dto.g.dart';

@JsonSerializable()
class MintNftResponseDto {
  final bool success;
  final String nftId;
  final int tokenId;
  final String tokenAddress;
  final String transactionHash;
  final String imageUrl;
  final String chain;
  final String message;

  MintNftResponseDto({
    required this.success,
    required this.nftId,
    required this.tokenId,
    required this.tokenAddress,
    required this.transactionHash,
    required this.imageUrl,
    required this.chain,
    required this.message,
  });

  factory MintNftResponseDto.fromJson(Map<String, dynamic> json) =>
      _$MintNftResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$MintNftResponseDtoToJson(this);

  MintNftResponseEntity toEntity() {
    return MintNftResponseEntity(
      success: success,
      nftId: nftId,
      tokenId: tokenId,
      tokenAddress: tokenAddress,
      transactionHash: transactionHash,
      imageUrl: imageUrl,
      chain: chain,
      message: message,
    );
  }
}