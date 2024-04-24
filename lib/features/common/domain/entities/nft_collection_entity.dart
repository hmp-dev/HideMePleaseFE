import 'package:equatable/equatable.dart';
import 'package:mobile/features/common/domain/entities/nft_token_entity.dart';

class NftCollectionEntity extends Equatable {
  final String tokenAddress;
  final bool possibleSpam;
  final String contractType;
  final String name;
  final String symbol;
  final bool verifiedCollection;
  final String collectionLogo;
  final String collectionBannerImage;
  final String chain;
  final String walletAddress;
  final List<NftTokenEntity> tokens;
  final String chainSymbol;

  const NftCollectionEntity({
    required this.tokenAddress,
    required this.possibleSpam,
    required this.contractType,
    required this.name,
    required this.symbol,
    required this.verifiedCollection,
    required this.collectionLogo,
    required this.collectionBannerImage,
    required this.chain,
    required this.walletAddress,
    required this.tokens,
    required this.chainSymbol,
  });

  @override
  List<Object> get props {
    return [
      tokenAddress,
      possibleSpam,
      contractType,
      name,
      symbol,
      verifiedCollection,
      collectionLogo,
      collectionBannerImage,
      chain,
      walletAddress,
      tokens,
      chainSymbol,
    ];
  }

  NftCollectionEntity copyWith({
    String? tokenAddress,
    bool? possibleSpam,
    String? contractType,
    String? name,
    String? symbol,
    bool? verifiedCollection,
    dynamic collectionLogo,
    dynamic collectionBannerImage,
    String? chain,
    String? walletAddress,
    List<NftTokenEntity>? tokens,
    String? chainSymbol,
  }) {
    return NftCollectionEntity(
      tokenAddress: tokenAddress ?? this.tokenAddress,
      possibleSpam: possibleSpam ?? this.possibleSpam,
      contractType: contractType ?? this.contractType,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      verifiedCollection: verifiedCollection ?? this.verifiedCollection,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      collectionBannerImage:
          collectionBannerImage ?? this.collectionBannerImage,
      chain: chain ?? this.chain,
      walletAddress: walletAddress ?? this.walletAddress,
      tokens: tokens ?? this.tokens,
      chainSymbol: chainSymbol ?? this.chainSymbol,
    );
  }
}
