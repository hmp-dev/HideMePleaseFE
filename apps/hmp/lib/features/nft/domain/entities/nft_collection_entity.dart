import 'package:equatable/equatable.dart';
import 'package:mobile/features/nft/domain/entities/nft_token_entity.dart';

class NftCollectionEntity extends Equatable {
  final String symbol;
  final String chain;
  final String tokenAddress;
  final String contractType;
  final String name;
  final String collectionLogo;
  final String chainSymbol;
  final List<NftTokenEntity> tokens;

  const NftCollectionEntity({
    required this.tokenAddress,
    required this.contractType,
    required this.name,
    required this.symbol,
    required this.collectionLogo,
    required this.chain,
    required this.tokens,
    required this.chainSymbol,
  });

  @override
  List<Object?> get props {
    return [
      symbol,
      chain,
      tokenAddress,
      contractType,
      name,
      collectionLogo,
      chainSymbol,
      tokens,
    ];
  }

  NftCollectionEntity copyWith({
    String? symbol,
    String? chain,
    String? tokenAddress,
    String? contractType,
    String? name,
    String? collectionLogo,
    String? chainSymbol,
    List<NftTokenEntity>? tokens,
  }) {
    return NftCollectionEntity(
      symbol: symbol ?? this.symbol,
      chain: chain ?? this.chain,
      tokenAddress: tokenAddress ?? this.tokenAddress,
      contractType: contractType ?? this.contractType,
      name: name ?? this.name,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      chainSymbol: chainSymbol ?? this.chainSymbol,
      tokens: tokens ?? this.tokens,
    );
  }
}
