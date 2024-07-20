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
    String? id,
    String? tokenId,
    String? name,
    String? imageUrl,
    bool? selected,
    String? updatedAt,
  }) {
    return NftTokenEntity(
      id: id ?? this.id,
      tokenId: tokenId ?? this.tokenId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      selected: selected ?? this.selected,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NftTokenEntity(id: $id, tokenId: $tokenId, name: $name, imageUrl: $imageUrl, selected: $selected, updatedAt: $updatedAt)';
  }
}
