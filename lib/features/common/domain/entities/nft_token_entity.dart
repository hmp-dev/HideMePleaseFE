import 'package:equatable/equatable.dart';

class NftTokenEntity extends Equatable {
  final String tokenId;
  final String name;
  final String imageUrl;
  final bool selected;

  const NftTokenEntity({
    required this.tokenId,
    required this.name,
    required this.imageUrl,
    required this.selected,
  });

  const NftTokenEntity.empty()
      : tokenId = '',
        name = '',
        imageUrl = '',
        selected = false;

  @override
  List<Object?> get props => [tokenId, name, imageUrl, selected];

  NftTokenEntity copyWith({
    required String tokenId,
    required String name,
    required String imageUrl,
    required bool selected,
  }) {
    return NftTokenEntity(
      tokenId: tokenId,
      name: name,
      imageUrl: imageUrl,
      selected: selected,
    );
  }
}
