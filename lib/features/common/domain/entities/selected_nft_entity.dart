import 'package:equatable/equatable.dart';

class SelectedNFTEntity extends Equatable {
  final String id;
  final int order;
  final String name;
  final String symbol;
  final String chain;
  final String imageUrl;

  const SelectedNFTEntity({
    required this.id,
    required this.order,
    required this.name,
    required this.symbol,
    required this.chain,
    required this.imageUrl,
  });

  const SelectedNFTEntity.empty()
      : id = '',
        order = 0,
        name = '',
        symbol = '',
        chain = '',
        imageUrl = '';

  @override
  List<Object?> get props => [
        id,
        order,
        name,
        symbol,
        chain,
        imageUrl,
      ];

  SelectedNFTEntity copyWith({
    required String id,
    required int order,
    required String name,
    required String symbol,
    required String chain,
    required String imageUrl,
  }) {
    return SelectedNFTEntity(
      id: id,
      order: order,
      name: name,
      symbol: symbol,
      chain: chain,
      imageUrl: imageUrl,
    );
  }

  
}


