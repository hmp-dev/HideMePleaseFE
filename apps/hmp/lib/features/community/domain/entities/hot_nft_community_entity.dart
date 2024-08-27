import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class NftHotCommunityEntity extends Equatable {
  final String tokenAddress;
  final String name;
  final String collectionLogo;
  final String chain;

  const NftHotCommunityEntity({
    required this.tokenAddress,
    required this.name,
    required this.collectionLogo,
    required this.chain,
  });

  @override
  List<Object?> get props => [
        tokenAddress,
        name,
        collectionLogo,
        chain,
      ];

  const NftHotCommunityEntity.empty()
      : tokenAddress = '',
        name = '',
        collectionLogo = '',
        chain = '';

  NftHotCommunityEntity copyWith({
    String? tokenAddress,
    String? name,
    String? collectionLogo,
    String? chain,
  }) {
    return NftHotCommunityEntity(
      tokenAddress: tokenAddress ?? this.tokenAddress,
      name: name ?? this.name,
      collectionLogo: collectionLogo ?? this.collectionLogo,
      chain: chain ?? this.chain,
    );
  }
}
