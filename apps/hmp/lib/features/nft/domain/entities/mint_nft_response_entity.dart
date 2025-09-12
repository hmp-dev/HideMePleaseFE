import 'package:equatable/equatable.dart';

class MintNftResponseEntity extends Equatable {
  final bool success;
  final String nftId;
  final int tokenId;
  final String tokenAddress;
  final String transactionHash;
  final String imageUrl;
  final String chain;
  final String message;

  const MintNftResponseEntity({
    required this.success,
    required this.nftId,
    required this.tokenId,
    required this.tokenAddress,
    required this.transactionHash,
    required this.imageUrl,
    required this.chain,
    required this.message,
  });

  @override
  List<Object?> get props => [
        success,
        nftId,
        tokenId,
        tokenAddress,
        transactionHash,
        imageUrl,
        chain,
        message,
      ];
}