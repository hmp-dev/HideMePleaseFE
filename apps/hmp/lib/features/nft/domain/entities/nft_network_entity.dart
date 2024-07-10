import 'package:equatable/equatable.dart';

class NftNetworkEntity extends Equatable {
  final String network;
  final String holderCount;
  final String floorPrice;
  final String symbol;

  const NftNetworkEntity({
    required this.network,
    required this.holderCount,
    required this.floorPrice,
    required this.symbol,
  });

  @override
  List<Object?> get props => [network, holderCount, floorPrice];

  NftNetworkEntity copyWith({
    String? network,
    String? holderCount,
    String? floorPrice,
    String? symbol,
  }) {
    return NftNetworkEntity(
      network: network ?? this.network,
      holderCount: holderCount ?? this.holderCount,
      floorPrice: floorPrice ?? this.floorPrice,
      symbol: symbol ?? this.symbol,
    );
  }

  const NftNetworkEntity.empty()
      : network = '',
        holderCount = '',
        floorPrice = '0',
        symbol = '';
}
