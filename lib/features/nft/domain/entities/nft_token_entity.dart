import 'package:equatable/equatable.dart';

class NftTokenEntity extends Equatable {
  final String id;
  final String tokenId;
  final String name;
  final String imageUrl;
  final bool selected;
  final String updatedAt;

  const NftTokenEntity({
    required this.id,
    required this.tokenId,
    required this.name,
    required this.imageUrl,
    required this.selected,
    required this.updatedAt,
  });

  const NftTokenEntity.empty()
      : id = '',
        tokenId = '',
        name = '',
        imageUrl = '',
        selected = false,
        updatedAt = '';

  @override
  List<Object?> get props => [tokenId, name, imageUrl, selected];

  NftTokenEntity copyWith({
    required String tokenId,
    required String name,
    required String imageUrl,
    required bool selected,
    required String updatedAt,
  }) {
    return NftTokenEntity(
      id: id,
      tokenId: tokenId,
      name: name,
      imageUrl: imageUrl,
      selected: selected,
      updatedAt: updatedAt,
    );
  }
}
