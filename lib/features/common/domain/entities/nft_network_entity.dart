import 'package:equatable/equatable.dart';

class NftNetworkEntity extends Equatable {
  final String network;
  final String holderCount;
  final int floorPrice;

  const NftNetworkEntity({
    required this.network,
    required this.holderCount,
    required this.floorPrice,
  });

  @override
  List<Object?> get props => [network, holderCount, floorPrice];

  NftNetworkEntity copyWith({
    String? network,
    String? holderCount,
    int? floorPrice,
  }) {
    return NftNetworkEntity(
      network: network ?? this.network,
      holderCount: holderCount ?? this.holderCount,
      floorPrice: floorPrice ?? this.floorPrice,
    );
  }

  const NftNetworkEntity.empty()
      : network = '',
        holderCount = '',
        floorPrice = 0;
}
