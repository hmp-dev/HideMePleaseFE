import 'package:equatable/equatable.dart';

class SelectedNFTEntity extends Equatable {
  final String id;
  final int order;
  final String name;
  final String symbol;
  final String collectionLogoUrl;
  final String chain;
  final String nftName;
  final String nftImageUrl;

  const SelectedNFTEntity({
    required this.id,
    required this.order,
    required this.name,
    required this.symbol,
    required this.collectionLogoUrl,
    required this.chain,
    required this.nftName,
    required this.nftImageUrl,
  });

  const SelectedNFTEntity.empty()
      : id = '',
        order = 0,
        name = '',
        symbol = '',
        collectionLogoUrl = '',
        chain = '',
        nftName = '',
        nftImageUrl = '';

  @override
  List<Object?> get props => [
        id,
        order,
        name,
        symbol,
        collectionLogoUrl,
        chain,
        nftName,
        nftImageUrl,
      ];

  SelectedNFTEntity copyWith({
    required String id,
    required int order,
    required String name,
    required String symbol,
    required String collectionLogoUrl,
    required String chain,
    required String nftName,
    required String nftImageUrl,
  }) {
    return SelectedNFTEntity(
      id: id,
      order: order,
      name: name,
      symbol: symbol,
      collectionLogoUrl: collectionLogoUrl,
      chain: chain,
      nftName: nftName,
      nftImageUrl: nftImageUrl,
    );
  }
}
